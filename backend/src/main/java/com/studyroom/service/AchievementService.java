package com.studyroom.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.exception.BusinessException;
import com.studyroom.common.ResultCode;
import com.studyroom.entity.*;
import com.studyroom.mapper.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 成就服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AchievementService {

    private final AchievementMapper achievementMapper;
    private final UserAchievementMapper userAchievementMapper;
    private final UserMapper userMapper;
    private final ReservationMapper reservationMapper;
    private final CheckInRecordMapper checkInRecordMapper;

    /**
     * 获取所有成就列表（带用户进度）
     */
    public List<Achievement> getAllAchievements(Long userId, String category, String rarity) {
        // 获取所有启用的成就
        LambdaQueryWrapper<Achievement> query = new LambdaQueryWrapper<>();
        query.eq(Achievement::getStatus, 1);
        if (category != null && !category.isEmpty()) {
            query.eq(Achievement::getCategory, category);
        }
        if (rarity != null && !rarity.isEmpty()) {
            query.eq(Achievement::getRarity, rarity);
        }
        // 隐藏成就只在已完成时显示
        query.orderByAsc(Achievement::getCategory)
             .orderByAsc(Achievement::getSortOrder);
        
        List<Achievement> achievements = achievementMapper.selectList(query);
        
        // 获取用户进度
        if (userId != null) {
            List<Long> achievementIds = achievements.stream()
                    .map(Achievement::getId)
                    .collect(Collectors.toList());
            
            if (!achievementIds.isEmpty()) {
                List<UserAchievement> userProgress = userAchievementMapper
                        .selectByUserAndAchievements(userId, achievementIds);
                Map<Long, UserAchievement> progressMap = userProgress.stream()
                        .collect(Collectors.toMap(UserAchievement::getAchievementId, ua -> ua));
                
                // 过滤隐藏成就（未完成的隐藏成就不显示）
                achievements = achievements.stream()
                        .filter(a -> {
                            if (a.getIsHidden() == 1) {
                                UserAchievement ua = progressMap.get(a.getId());
                                return ua != null && ua.getIsCompleted() == 1;
                            }
                            return true;
                        })
                        .peek(a -> a.setUserProgress(progressMap.get(a.getId())))
                        .collect(Collectors.toList());
            }
        }
        
        return achievements;
    }

    /**
     * 获取用户的成就统计
     */
    public Map<String, Object> getUserAchievementStats(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        
        // 总成就数
        int totalCount = Math.toIntExact(achievementMapper.selectCount(
                new LambdaQueryWrapper<Achievement>().eq(Achievement::getStatus, 1)));
        
        // 已完成成就数
        int completedCount = userAchievementMapper.countCompletedByUser(userId);
        
        // 待领取奖励数
        int unclaimedCount = userAchievementMapper.countUnclaimedByUser(userId);
        
        // 各稀有度完成数量
        List<Map<String, Object>> rarityStats = userAchievementMapper.countByRarity(userId);
        Map<String, Integer> rarityCount = new HashMap<>();
        rarityCount.put("COMMON", 0);
        rarityCount.put("RARE", 0);
        rarityCount.put("EPIC", 0);
        rarityCount.put("LEGENDARY", 0);
        for (Map<String, Object> rs : rarityStats) {
            String rarity = (String) rs.get("rarity");
            Long count = (Long) rs.get("count");
            rarityCount.put(rarity, count.intValue());
        }
        
        stats.put("totalCount", totalCount);
        stats.put("completedCount", completedCount);
        stats.put("unclaimedCount", unclaimedCount);
        stats.put("completionRate", totalCount > 0 ? (completedCount * 100 / totalCount) : 0);
        stats.put("rarityStats", rarityCount);
        
        return stats;
    }

    /**
     * 获取用户的成就列表（带进度）
     */
    public List<UserAchievement> getUserAchievements(Long userId) {
        return userAchievementMapper.selectUserAchievementsWithDetail(userId);
    }

    /**
     * 获取待领取奖励的成就
     */
    public List<UserAchievement> getUnclaimedAchievements(Long userId) {
        return userAchievementMapper.selectUnclaimedByUser(userId);
    }

    /**
     * 领取成就奖励
     */
    @Transactional
    public Map<String, Object> claimReward(Long userId, Long achievementId) {
        // 检查用户成就记录
        UserAchievement ua = userAchievementMapper.selectByUserAndAchievement(userId, achievementId);
        if (ua == null) {
            throw new BusinessException(ResultCode.ACHIEVEMENT_NOT_FOUND);
        }
        
        if (ua.getIsCompleted() != 1) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "成就尚未完成");
        }
        
        if (ua.getIsClaimed() == 1) {
            throw new BusinessException(ResultCode.ACHIEVEMENT_ALREADY_UNLOCKED);
        }
        
        // 获取成就信息
        Achievement achievement = achievementMapper.selectById(achievementId);
        if (achievement == null) {
            throw new BusinessException(ResultCode.ACHIEVEMENT_NOT_FOUND);
        }
        
        // 更新领取状态
        ua.claimReward();
        userAchievementMapper.updateById(ua);
        
        // 发放奖励
        User user = userMapper.selectById(userId);
        int points = achievement.getRewardPoints();
        int exp = achievement.getRewardExp();
        
        user.setTotalPoints(user.getTotalPoints() + points);
        user.setExp(user.getExp() + exp);
        userMapper.updateById(user);
        
        log.info("用户{}领取成就{}奖励: {}积分, {}经验", userId, achievement.getName(), points, exp);
        
        Map<String, Object> result = new HashMap<>();
        result.put("achievementName", achievement.getName());
        result.put("points", points);
        result.put("exp", exp);
        result.put("totalPoints", user.getTotalPoints());
        result.put("totalExp", user.getExp());
        
        return result;
    }

    /**
     * 检查并更新成就进度（触发器核心方法）
     */
    @Transactional
    public List<Achievement> checkAndUpdateProgress(Long userId, String conditionType, int currentValue) {
        List<Achievement> newlyCompleted = new ArrayList<>();
        
        // 获取该条件类型的所有成就
        List<Achievement> achievements = achievementMapper.selectByConditionType(conditionType);
        
        for (Achievement achievement : achievements) {
            // 获取或创建用户成就记录
            UserAchievement ua = userAchievementMapper.selectByUserAndAchievement(userId, achievement.getId());
            
            if (ua == null) {
                ua = UserAchievement.create(userId, achievement.getId());
                ua.setProgress(currentValue);
                
                // 检查是否直接完成
                if (currentValue >= achievement.getConditionValue()) {
                    ua.setIsCompleted(1);
                    ua.setCompletedAt(LocalDateTime.now());
                    newlyCompleted.add(achievement);
                }
                
                userAchievementMapper.insert(ua);
            } else if (ua.getIsCompleted() == 0) {
                // 更新进度
                boolean wasCompleted = ua.getIsCompleted() == 1;
                ua.updateProgress(currentValue, achievement.getConditionValue());
                userAchievementMapper.updateById(ua);
                
                // 检查是否新完成
                if (!wasCompleted && ua.getIsCompleted() == 1) {
                    newlyCompleted.add(achievement);
                }
            }
        }
        
        // 记录新解锁的成就
        for (Achievement a : newlyCompleted) {
            log.info("用户{}解锁成就: {}", userId, a.getName());
        }
        
        return newlyCompleted;
    }

    // ========== 成就触发器方法 ==========

    /**
     * 预约完成触发器
     */
    @Transactional
    public List<Achievement> triggerReservationComplete(Long userId) {
        // 统计用户完成的预约总数
        Long totalReservations = reservationMapper.selectCount(
                new LambdaQueryWrapper<Reservation>()
                        .eq(Reservation::getUserId, userId)
                        .eq(Reservation::getStatus, Reservation.Status.COMPLETED.name())
        );
        
        return checkAndUpdateProgress(userId, Achievement.CONDITION_TOTAL_RESERVATIONS, totalReservations.intValue());
    }

    /**
     * 学习时长触发器
     */
    @Transactional
    public List<Achievement> triggerStudyHours(Long userId, int totalHours) {
        return checkAndUpdateProgress(userId, Achievement.CONDITION_TOTAL_HOURS, totalHours);
    }

    /**
     * 打卡触发器
     */
    @Transactional
    public List<Achievement> triggerCheckIn(Long userId, int totalCheckIns, int continuousDays) {
        List<Achievement> completed = new ArrayList<>();
        
        // 累计打卡次数
        completed.addAll(checkAndUpdateProgress(userId, Achievement.CONDITION_TOTAL_CHECK_INS, totalCheckIns));
        
        // 连续打卡天数
        completed.addAll(checkAndUpdateProgress(userId, Achievement.CONDITION_CONTINUOUS_CHECK_INS, continuousDays));
        
        return completed;
    }

    /**
     * 好友数量触发器
     */
    @Transactional
    public List<Achievement> triggerFriendsCount(Long userId, int totalFriends) {
        return checkAndUpdateProgress(userId, Achievement.CONDITION_TOTAL_FRIENDS, totalFriends);
    }

    /**
     * 创建小组触发器
     */
    @Transactional
    public List<Achievement> triggerCreateGroup(Long userId) {
        return checkAndUpdateProgress(userId, Achievement.CONDITION_CREATE_GROUP, 1);
    }

    /**
     * 早签到触发器（8点前）
     */
    @Transactional
    public List<Achievement> triggerEarlySignIn(Long userId, int count) {
        return checkAndUpdateProgress(userId, Achievement.CONDITION_EARLY_SIGN_IN, count);
    }

    /**
     * 晚签退触发器（22点后）
     */
    @Transactional
    public List<Achievement> triggerLateSignOut(Long userId, int count) {
        return checkAndUpdateProgress(userId, Achievement.CONDITION_LATE_SIGN_OUT, count);
    }

    /**
     * 无违约连续次数触发器
     */
    @Transactional
    public List<Achievement> triggerNoViolationStreak(Long userId, int streak) {
        return checkAndUpdateProgress(userId, Achievement.CONDITION_NO_VIOLATION_STREAK, streak);
    }

    /**
     * 周末学习触发器
     */
    @Transactional
    public List<Achievement> triggerWeekendStudy(Long userId, int count) {
        return checkAndUpdateProgress(userId, Achievement.CONDITION_WEEKEND_STUDY, count);
    }

    /**
     * 目标完成触发器
     */
    @Transactional
    public List<Achievement> triggerGoalCompleted(Long userId, int totalGoals) {
        return checkAndUpdateProgress(userId, Achievement.CONDITION_GOALS_COMPLETED, totalGoals);
    }

    /**
     * 评价数量触发器
     */
    @Transactional
    public List<Achievement> triggerReviewCount(Long userId, int totalReviews) {
        return checkAndUpdateProgress(userId, Achievement.CONDITION_TOTAL_REVIEWS, totalReviews);
    }

    // ========== 管理端方法 ==========

    /**
     * 分页查询成就（管理端）
     */
    public Page<Achievement> getAchievementPage(int page, int size, String category, String rarity, String keyword) {
        Page<Achievement> pageParam = new Page<>(page, size);
        return achievementMapper.selectPage(pageParam, category, rarity, keyword);
    }

    /**
     * 获取成就详情
     */
    public Achievement getAchievementById(Long id) {
        return achievementMapper.selectById(id);
    }

    /**
     * 创建成就
     */
    @Transactional
    public Achievement createAchievement(Achievement achievement) {
        achievement.setCreatedAt(LocalDateTime.now());
        if (achievement.getStatus() == null) {
            achievement.setStatus(1);
        }
        if (achievement.getIsHidden() == null) {
            achievement.setIsHidden(0);
        }
        if (achievement.getRewardPoints() == null) {
            achievement.setRewardPoints(0);
        }
        if (achievement.getRewardExp() == null) {
            achievement.setRewardExp(0);
        }
        achievementMapper.insert(achievement);
        return achievement;
    }

    /**
     * 更新成就
     */
    @Transactional
    public Achievement updateAchievement(Achievement achievement) {
        Achievement existing = achievementMapper.selectById(achievement.getId());
        if (existing == null) {
            throw new BusinessException(ResultCode.ACHIEVEMENT_NOT_FOUND);
        }
        achievementMapper.updateById(achievement);
        return achievementMapper.selectById(achievement.getId());
    }

    /**
     * 删除成就
     */
    @Transactional
    public void deleteAchievement(Long id) {
        Achievement existing = achievementMapper.selectById(id);
        if (existing == null) {
            throw new BusinessException(ResultCode.ACHIEVEMENT_NOT_FOUND);
        }
        achievementMapper.deleteById(id);
        // 同时删除用户成就记录
        userAchievementMapper.delete(new LambdaQueryWrapper<UserAchievement>()
                .eq(UserAchievement::getAchievementId, id));
    }

    /**
     * 切换成就状态
     */
    @Transactional
    public void toggleStatus(Long id) {
        Achievement achievement = achievementMapper.selectById(id);
        if (achievement == null) {
            throw new BusinessException(ResultCode.ACHIEVEMENT_NOT_FOUND);
        }
        achievement.setStatus(achievement.getStatus() == 1 ? 0 : 1);
        achievementMapper.updateById(achievement);
    }

    /**
     * 初始化用户所有成就进度
     */
    @Transactional
    public void initUserAchievements(Long userId) {
        // 获取用户当前数据
        User user = userMapper.selectById(userId);
        if (user == null) return;
        
        // 统计预约完成数
        Long totalReservations = reservationMapper.selectCount(
                new LambdaQueryWrapper<Reservation>()
                        .eq(Reservation::getUserId, userId)
                        .eq(Reservation::getStatus, Reservation.Status.COMPLETED.name())
        );
        if (totalReservations > 0) {
            checkAndUpdateProgress(userId, Achievement.CONDITION_TOTAL_RESERVATIONS, totalReservations.intValue());
        }
        
        // 统计打卡数
        Long totalCheckIns = checkInRecordMapper.selectCount(
                new LambdaQueryWrapper<CheckInRecord>()
                        .eq(CheckInRecord::getUserId, userId)
        );
        if (totalCheckIns > 0) {
            checkAndUpdateProgress(userId, Achievement.CONDITION_TOTAL_CHECK_INS, totalCheckIns.intValue());
        }
        
        // 连续打卡
        if (user.getCurrentStreak() != null && user.getCurrentStreak() > 0) {
            checkAndUpdateProgress(userId, Achievement.CONDITION_CONTINUOUS_CHECK_INS, user.getCurrentStreak());
        }
        
        log.info("初始化用户{}的成就进度完成", userId);
    }
}
