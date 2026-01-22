package com.studyroom.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.StudyGoal;
import com.studyroom.entity.User;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.StudyGoalMapper;
import com.studyroom.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 学习目标服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class StudyGoalService {

    private final StudyGoalMapper studyGoalMapper;
    private final UserMapper userMapper;

    /**
     * 创建学习目标
     */
    @Transactional
    public StudyGoal createGoal(Long userId, StudyGoal goal) {
        // 验证用户
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        // 检查是否有相同类型的进行中目标
        StudyGoal existing = studyGoalMapper.selectActiveByType(userId, goal.getType());
        if (existing != null) {
            throw new BusinessException("已有相同类型的进行中目标");
        }
        
        // 设置基本信息
        goal.setUserId(userId);
        goal.setCurrentValue(BigDecimal.ZERO);
        goal.setStatus(StudyGoal.STATUS_ACTIVE);
        goal.setRewardClaimed(0);
        
        // 根据类型设置默认值
        if (goal.getUnit() == null) {
            goal.setUnit(getDefaultUnit(goal.getType()));
        }
        
        // 设置默认奖励
        if (goal.getRewardPoints() == null) {
            goal.setRewardPoints(calculateRewardPoints(goal));
        }
        if (goal.getRewardExp() == null) {
            goal.setRewardExp(calculateRewardExp(goal));
        }
        
        studyGoalMapper.insert(goal);
        
        log.info("用户{}创建学习目标: {}", userId, goal.getName());
        
        return goal;
    }

    /**
     * 获取用户目标列表
     */
    public IPage<StudyGoal> getUserGoals(Long userId, int pageNum, int pageSize, String status, String type) {
        IPage<StudyGoal> page = studyGoalMapper.selectUserGoals(
                new Page<>(pageNum, pageSize), userId, status, type);
        
        // 填充计算字段
        page.getRecords().forEach(goal -> {
            goal.setProgressPercent(goal.calculateProgress());
            goal.setRemainingDays(goal.calculateRemainingDays());
        });
        
        return page;
    }

    /**
     * 获取进行中的目标
     */
    public List<StudyGoal> getActiveGoals(Long userId) {
        List<StudyGoal> goals = studyGoalMapper.selectActiveGoals(userId);
        goals.forEach(goal -> {
            goal.setProgressPercent(goal.calculateProgress());
            goal.setRemainingDays(goal.calculateRemainingDays());
        });
        return goals;
    }

    /**
     * 获取目标详情
     */
    public StudyGoal getGoalById(Long goalId, Long userId) {
        StudyGoal goal = studyGoalMapper.selectById(goalId);
        if (goal == null) {
            throw new BusinessException("目标不存在");
        }
        if (!goal.getUserId().equals(userId)) {
            throw new BusinessException("无权查看此目标");
        }
        goal.setProgressPercent(goal.calculateProgress());
        goal.setRemainingDays(goal.calculateRemainingDays());
        return goal;
    }

    /**
     * 更新目标进度
     */
    @Transactional
    public void updateProgress(Long goalId, BigDecimal newValue) {
        StudyGoal goal = studyGoalMapper.selectById(goalId);
        if (goal == null || !StudyGoal.STATUS_ACTIVE.equals(goal.getStatus())) {
            return;
        }
        
        goal.setCurrentValue(newValue);
        studyGoalMapper.updateProgress(goalId, newValue);
        
        // 检查是否完成
        if (goal.isCompleted()) {
            completeGoal(goal);
        }
    }

    /**
     * 完成目标
     */
    @Transactional
    public void completeGoal(StudyGoal goal) {
        goal.setStatus(StudyGoal.STATUS_COMPLETED);
        goal.setCompletedTime(LocalDateTime.now());
        studyGoalMapper.updateById(goal);
        
        log.info("用户{}完成学习目标: {}", goal.getUserId(), goal.getName());
    }

    /**
     * 领取目标奖励
     */
    @Transactional
    public Map<String, Object> claimReward(Long goalId, Long userId) {
        StudyGoal goal = studyGoalMapper.selectById(goalId);
        if (goal == null) {
            throw new BusinessException("目标不存在");
        }
        if (!goal.getUserId().equals(userId)) {
            throw new BusinessException("无权操作此目标");
        }
        if (!StudyGoal.STATUS_COMPLETED.equals(goal.getStatus())) {
            throw new BusinessException("目标未完成");
        }
        if (goal.getRewardClaimed() == 1) {
            throw new BusinessException("奖励已领取");
        }
        
        // 发放奖励
        User user = userMapper.selectById(userId);
        int points = goal.getRewardPoints() != null ? goal.getRewardPoints() : 0;
        int exp = goal.getRewardExp() != null ? goal.getRewardExp() : 0;
        
        user.setTotalPoints(user.getTotalPoints() + points);
        user.setExp(user.getExp() + exp);
        userMapper.updateById(user);
        
        // 标记已领取
        goal.setRewardClaimed(1);
        studyGoalMapper.updateById(goal);
        
        Map<String, Object> result = new HashMap<>();
        result.put("points", points);
        result.put("exp", exp);
        
        log.info("用户{}领取目标奖励: 积分{}，经验{}", userId, points, exp);
        
        return result;
    }

    /**
     * 取消目标
     */
    @Transactional
    public void cancelGoal(Long goalId, Long userId) {
        StudyGoal goal = studyGoalMapper.selectById(goalId);
        if (goal == null) {
            throw new BusinessException("目标不存在");
        }
        if (!goal.getUserId().equals(userId)) {
            throw new BusinessException("无权操作此目标");
        }
        if (!StudyGoal.STATUS_ACTIVE.equals(goal.getStatus())) {
            throw new BusinessException("目标不在进行中");
        }
        
        goal.setStatus(StudyGoal.STATUS_CANCELLED);
        studyGoalMapper.updateById(goal);
        
        log.info("用户{}取消学习目标: {}", userId, goal.getName());
    }

    /**
     * 获取目标统计
     */
    public Map<String, Object> getGoalStats(Long userId) {
        int totalGoals = studyGoalMapper.countByUserId(userId);
        int completedGoals = studyGoalMapper.countCompletedGoals(userId);
        List<StudyGoal> activeGoals = studyGoalMapper.selectActiveGoals(userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("totalGoals", totalGoals);
        result.put("completedGoals", completedGoals);
        result.put("activeGoals", activeGoals.size());
        result.put("completionRate", totalGoals > 0 ? (completedGoals * 100 / totalGoals) : 0);
        
        return result;
    }

    /**
     * 每天凌晨处理过期目标
     */
    @Scheduled(cron = "0 5 0 * * ?")
    @Transactional
    public void processExpiredGoals() {
        log.info("开始处理过期学习目标...");
        
        int count = studyGoalMapper.markExpiredAsFailed(LocalDate.now());
        
        log.info("处理过期目标完成，共{}个目标标记为失败", count);
    }

    // ==================== 辅助方法 ====================

    private String getDefaultUnit(String type) {
        return switch (type) {
            case StudyGoal.TYPE_DAILY_HOURS, StudyGoal.TYPE_WEEKLY_HOURS, 
                 StudyGoal.TYPE_MONTHLY_HOURS, StudyGoal.TYPE_TOTAL_HOURS -> StudyGoal.UNIT_HOUR;
            case StudyGoal.TYPE_DAILY_CHECKIN -> StudyGoal.UNIT_DAY;
            case StudyGoal.TYPE_RESERVATION_COUNT -> StudyGoal.UNIT_COUNT;
            default -> StudyGoal.UNIT_HOUR;
        };
    }

    private int calculateRewardPoints(StudyGoal goal) {
        // 基于目标值计算奖励
        int baseReward = 20;
        if (goal.getTargetValue() != null) {
            baseReward += goal.getTargetValue().intValue() * 2;
        }
        return Math.min(baseReward, 100); // 最大100积分
    }

    private int calculateRewardExp(StudyGoal goal) {
        int baseReward = 50;
        if (goal.getTargetValue() != null) {
            baseReward += goal.getTargetValue().intValue() * 5;
        }
        return Math.min(baseReward, 200); // 最大200经验
    }
}
