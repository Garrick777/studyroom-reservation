package com.studyroom.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.*;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 信用积分服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CreditService {

    private final UserMapper userMapper;
    private final CreditRecordMapper creditRecordMapper;
    private final ViolationRecordMapper violationRecordMapper;
    private final BlacklistMapper blacklistMapper;

    /**
     * 最大信用分
     */
    private static final int MAX_CREDIT_SCORE = 100;

    /**
     * 最小信用分
     */
    private static final int MIN_CREDIT_SCORE = 0;

    // ==================== 信用分变动 ====================

    /**
     * 增加信用分
     */
    @Transactional
    public void addCreditScore(Long userId, int score, String type, String sourceType, Long sourceId, String description) {
        if (score <= 0) {
            throw new BusinessException("增加的积分必须大于0");
        }
        
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        int beforeScore = user.getCreditScore();
        int afterScore = Math.min(beforeScore + score, MAX_CREDIT_SCORE);
        int actualChange = afterScore - beforeScore;
        
        if (actualChange > 0) {
            // 更新用户信用分
            user.setCreditScore(afterScore);
            userMapper.updateById(user);
            
            // 记录变动
            CreditRecord record = CreditRecord.create(userId, actualChange, beforeScore, 
                    type, sourceType, sourceId, description);
            creditRecordMapper.insert(record);
            
            log.info("用户{}信用分增加: {} -> {} (+{})", userId, beforeScore, afterScore, actualChange);
        }
    }

    /**
     * 扣除信用分
     */
    @Transactional
    public void deductCreditScore(Long userId, int score, String type, String sourceType, Long sourceId, String description) {
        if (score <= 0) {
            throw new BusinessException("扣除的积分必须大于0");
        }
        
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        int beforeScore = user.getCreditScore();
        int afterScore = Math.max(beforeScore - score, MIN_CREDIT_SCORE);
        int actualChange = beforeScore - afterScore;
        
        // 更新用户信用分
        user.setCreditScore(afterScore);
        userMapper.updateById(user);
        
        // 记录变动
        CreditRecord record = CreditRecord.create(userId, -actualChange, beforeScore, 
                type, sourceType, sourceId, description);
        creditRecordMapper.insert(record);
        
        log.info("用户{}信用分扣除: {} -> {} (-{})", userId, beforeScore, afterScore, actualChange);
        
        // 检查是否需要加入黑名单
        if (afterScore < Blacklist.TRIGGER_SCORE_THRESHOLD) {
            checkAndAddToBlacklist(userId, afterScore);
        }
    }

    /**
     * 管理员调整信用分
     */
    @Transactional
    public void adjustCreditScore(Long userId, int newScore, Long operatorId, String reason) {
        if (newScore < MIN_CREDIT_SCORE || newScore > MAX_CREDIT_SCORE) {
            throw new BusinessException("信用分必须在" + MIN_CREDIT_SCORE + "-" + MAX_CREDIT_SCORE + "之间");
        }
        
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        int beforeScore = user.getCreditScore();
        int change = newScore - beforeScore;
        
        if (change == 0) {
            return;
        }
        
        // 更新用户信用分
        user.setCreditScore(newScore);
        userMapper.updateById(user);
        
        // 记录变动
        String description = "管理员调整: " + (reason != null ? reason : "无说明");
        CreditRecord record = CreditRecord.create(userId, change, beforeScore,
                CreditRecord.TYPE_ADMIN_ADJUST, CreditRecord.SOURCE_ADMIN, operatorId, description);
        creditRecordMapper.insert(record);
        
        log.info("管理员{}调整用户{}信用分: {} -> {} ({})", operatorId, userId, beforeScore, newScore, change);
        
        // 检查黑名单状态
        if (newScore >= Blacklist.TRIGGER_SCORE_THRESHOLD) {
            // 如果提升到阈值以上，自动解除黑名单
            releaseFromBlacklist(userId, operatorId, "信用分恢复到" + Blacklist.TRIGGER_SCORE_THRESHOLD + "分以上");
        } else if (beforeScore >= Blacklist.TRIGGER_SCORE_THRESHOLD) {
            // 如果从阈值以上降到以下，加入黑名单
            checkAndAddToBlacklist(userId, newScore);
        }
    }

    // ==================== 违约处理 ====================

    /**
     * 创建违约记录
     */
    @Transactional
    public ViolationRecord createViolation(Long userId, Long reservationId, String type) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        int deductScore = ViolationRecord.getDeductScore(type);
        int beforeScore = user.getCreditScore();
        int afterScore = Math.max(beforeScore - deductScore, MIN_CREDIT_SCORE);
        
        // 创建违约记录
        ViolationRecord violation = new ViolationRecord();
        violation.setUserId(userId);
        violation.setReservationId(reservationId);
        violation.setType(type);
        violation.setDescription(ViolationRecord.getTypeDescription(type));
        violation.setDeductScore(deductScore);
        violation.setBeforeScore(beforeScore);
        violation.setAfterScore(afterScore);
        violation.setAppealStatus(ViolationRecord.APPEAL_NONE);
        violationRecordMapper.insert(violation);
        
        // 扣除信用分
        deductCreditScore(userId, deductScore, type, CreditRecord.SOURCE_VIOLATION, 
                violation.getId(), violation.getDescription());
        
        log.info("用户{}违约[{}]: 扣除{}分, {} -> {}", userId, type, deductScore, beforeScore, afterScore);
        
        return violation;
    }

    // ==================== 申诉处理 ====================

    /**
     * 提交申诉
     */
    @Transactional
    public void submitAppeal(Long violationId, Long userId, String reason) {
        ViolationRecord violation = violationRecordMapper.selectById(violationId);
        if (violation == null) {
            throw new BusinessException("违约记录不存在");
        }
        if (!violation.getUserId().equals(userId)) {
            throw new BusinessException("无权申诉此记录");
        }
        if (violation.getAppealStatus() != ViolationRecord.APPEAL_NONE) {
            throw new BusinessException("该记录已申诉或申诉已处理");
        }
        
        violation.setAppealStatus(ViolationRecord.APPEAL_PENDING);
        violation.setAppealReason(reason);
        violation.setAppealTime(LocalDateTime.now());
        violationRecordMapper.updateById(violation);
        
        log.info("用户{}对违约记录{}提交申诉", userId, violationId);
    }

    /**
     * 处理申诉
     */
    @Transactional
    public void processAppeal(Long violationId, boolean approved, String result, Long operatorId) {
        ViolationRecord violation = violationRecordMapper.selectById(violationId);
        if (violation == null) {
            throw new BusinessException("违约记录不存在");
        }
        if (violation.getAppealStatus() != ViolationRecord.APPEAL_PENDING) {
            throw new BusinessException("该申诉不在待处理状态");
        }
        
        violation.setAppealStatus(approved ? ViolationRecord.APPEAL_APPROVED : ViolationRecord.APPEAL_REJECTED);
        violation.setAppealResult(result);
        violation.setProcessedBy(operatorId);
        violation.setProcessedTime(LocalDateTime.now());
        violationRecordMapper.updateById(violation);
        
        // 如果申诉通过，返还扣除的积分
        if (approved) {
            addCreditScore(violation.getUserId(), violation.getDeductScore(),
                    CreditRecord.TYPE_APPEAL_APPROVED, CreditRecord.SOURCE_APPEAL,
                    violationId, "申诉通过，返还扣分");
        }
        
        log.info("管理员{}处理申诉{}: {}", operatorId, violationId, approved ? "通过" : "驳回");
    }

    // ==================== 黑名单管理 ====================

    /**
     * 检查并自动加入黑名单
     */
    private void checkAndAddToBlacklist(Long userId, int currentScore) {
        // 检查是否已在黑名单中
        Blacklist existing = blacklistMapper.selectActiveByUserId(userId);
        if (existing != null) {
            return;
        }
        
        // 自动加入黑名单
        Blacklist blacklist = Blacklist.createAuto(userId, currentScore);
        blacklistMapper.insert(blacklist);
        
        log.info("用户{}因信用分{}低于阈值，自动加入黑名单", userId, currentScore);
    }

    /**
     * 检查用户是否在黑名单中
     */
    public boolean isInBlacklist(Long userId) {
        return blacklistMapper.selectActiveByUserId(userId) != null;
    }

    /**
     * 获取用户当前黑名单状态
     */
    public Blacklist getActiveBlacklist(Long userId) {
        return blacklistMapper.selectActiveByUserId(userId);
    }

    /**
     * 手动添加到黑名单
     */
    @Transactional
    public void addToBlacklist(Long userId, String reason, Integer durationDays, Long operatorId) {
        // 检查是否已在黑名单中
        Blacklist existing = blacklistMapper.selectActiveByUserId(userId);
        if (existing != null) {
            throw new BusinessException("用户已在黑名单中");
        }
        
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        Blacklist blacklist = Blacklist.createManual(userId, reason, durationDays, operatorId);
        blacklistMapper.insert(blacklist);
        
        log.info("管理员{}将用户{}加入黑名单，时长{}天", operatorId, userId, durationDays);
    }

    /**
     * 解除黑名单
     */
    @Transactional
    public void releaseFromBlacklist(Long userId, Long operatorId, String reason) {
        Blacklist blacklist = blacklistMapper.selectActiveByUserId(userId);
        if (blacklist == null) {
            return; // 不在黑名单中，无需处理
        }
        
        blacklist.setReleased(Blacklist.RELEASED_YES);
        blacklist.setReleaseTime(LocalDateTime.now());
        blacklist.setReleaseReason(reason);
        blacklistMapper.updateById(blacklist);
        
        log.info("用户{}从黑名单解除: {}", userId, reason);
    }

    /**
     * 查询黑名单列表
     */
    public IPage<Blacklist> getBlacklistPage(int pageNum, int pageSize, Integer released, String keyword) {
        return blacklistMapper.selectBlacklist(new Page<>(pageNum, pageSize), released, keyword);
    }

    // ==================== 定时任务 ====================

    /**
     * 每月1日凌晨自动恢复信用分
     */
    @Scheduled(cron = "0 0 0 1 * ?")
    @Transactional
    public void monthlyRecoverCreditScore() {
        log.info("开始执行月度信用分恢复任务...");
        
        // 查询所有信用分低于100的用户
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.lt(User::getCreditScore, MAX_CREDIT_SCORE);
        List<User> users = userMapper.selectList(wrapper);
        
        int count = 0;
        for (User user : users) {
            try {
                addCreditScore(user.getId(), 5, CreditRecord.TYPE_MONTHLY_RECOVER,
                        CreditRecord.SOURCE_SYSTEM, null, "月度积分恢复");
                count++;
            } catch (Exception e) {
                log.error("恢复用户{}积分失败: {}", user.getId(), e.getMessage());
            }
        }
        
        log.info("月度信用分恢复完成，共处理{}个用户", count);
    }

    /**
     * 每天凌晨自动解除过期黑名单
     */
    @Scheduled(cron = "0 0 1 * * ?")
    @Transactional
    public void autoReleaseExpiredBlacklist() {
        log.info("开始执行黑名单自动解除任务...");
        
        int count = blacklistMapper.autoReleaseExpired();
        
        log.info("黑名单自动解除完成，共解除{}条记录", count);
    }

    // ==================== 查询接口 ====================

    /**
     * 获取用户积分记录
     */
    public IPage<CreditRecord> getUserCreditRecords(Long userId, int pageNum, int pageSize, String type) {
        return creditRecordMapper.selectUserRecords(new Page<>(pageNum, pageSize), userId, type);
    }

    /**
     * 获取用户违约记录
     */
    public IPage<ViolationRecord> getUserViolations(Long userId, int pageNum, int pageSize, String type) {
        return violationRecordMapper.selectUserViolations(new Page<>(pageNum, pageSize), userId, type);
    }

    /**
     * 管理员获取所有违约记录
     */
    public IPage<ViolationRecord> getAllViolations(int pageNum, int pageSize, Long userId, String type, Integer appealStatus) {
        return violationRecordMapper.selectAllViolations(new Page<>(pageNum, pageSize), userId, type, appealStatus);
    }

    /**
     * 获取用户信用统计信息
     */
    public Map<String, Object> getUserCreditStats(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("currentScore", user.getCreditScore());
        stats.put("totalGain", creditRecordMapper.sumPositiveChange(userId));
        stats.put("totalLoss", creditRecordMapper.sumNegativeChange(userId));
        stats.put("violationCount", violationRecordMapper.countByUserId(userId));
        stats.put("isBlacklisted", isInBlacklist(userId));
        
        Blacklist blacklist = getActiveBlacklist(userId);
        if (blacklist != null) {
            stats.put("blacklistEndTime", blacklist.getEndTime());
        }
        
        return stats;
    }
}
