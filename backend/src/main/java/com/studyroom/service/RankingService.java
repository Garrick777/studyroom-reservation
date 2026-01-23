package com.studyroom.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.studyroom.entity.CheckInRecord;
import com.studyroom.entity.Reservation;
import com.studyroom.entity.User;
import com.studyroom.entity.UserAchievement;
import com.studyroom.mapper.CheckInRecordMapper;
import com.studyroom.mapper.ReservationMapper;
import com.studyroom.mapper.UserAchievementMapper;
import com.studyroom.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 排行榜服务
 */
@Service
@RequiredArgsConstructor
public class RankingService {

    private final UserMapper userMapper;
    private final ReservationMapper reservationMapper;
    private final CheckInRecordMapper checkInRecordMapper;
    private final UserAchievementMapper userAchievementMapper;
    private final RedisTemplate<String, Object> redisTemplate;

    private static final String RANKING_KEY_PREFIX = "ranking:";
    private static final int DEFAULT_TOP_SIZE = 50;

    /**
     * 获取学习时长排行榜
     */
    public List<Map<String, Object>> getStudyTimeRanking(String period, int limit) {
        String cacheKey = RANKING_KEY_PREFIX + "study_time:" + period;
        
        // 尝试从缓存获取
        List<Map<String, Object>> cached = getCachedRanking(cacheKey, limit);
        if (cached != null) {
            return cached;
        }

        // 计算排行榜
        LocalDateTime startTime = getStartTimeByPeriod(period);
        List<Map<String, Object>> ranking = calculateStudyTimeRanking(startTime, limit);
        
        // 缓存结果
        cacheRanking(cacheKey, ranking, getExpireMinutes(period));
        
        return ranking;
    }

    /**
     * 获取连续打卡排行榜
     */
    public List<Map<String, Object>> getCheckInStreakRanking(int limit) {
        String cacheKey = RANKING_KEY_PREFIX + "checkin_streak";
        
        List<Map<String, Object>> cached = getCachedRanking(cacheKey, limit);
        if (cached != null) {
            return cached;
        }

        // 基于用户的连续打卡天数排序
        List<User> users = userMapper.selectList(
            new LambdaQueryWrapper<User>()
                .eq(User::getStatus, 1)
                .orderByDesc(User::getCurrentStreak)
                .last("LIMIT " + limit)
        );

        List<Map<String, Object>> ranking = new ArrayList<>();
        int rank = 1;
        for (User user : users) {
            Map<String, Object> item = new HashMap<>();
            item.put("rank", rank++);
            item.put("userId", user.getId());
            item.put("username", user.getUsername());
            item.put("realName", user.getRealName());
            item.put("avatar", user.getAvatar());
            item.put("value", user.getCurrentStreak());
            item.put("unit", "天");
            ranking.add(item);
        }

        cacheRanking(cacheKey, ranking, 60);
        return ranking;
    }

    /**
     * 获取积分排行榜
     */
    public List<Map<String, Object>> getPointsRanking(int limit) {
        String cacheKey = RANKING_KEY_PREFIX + "points";
        
        List<Map<String, Object>> cached = getCachedRanking(cacheKey, limit);
        if (cached != null) {
            return cached;
        }

        List<User> users = userMapper.selectList(
            new LambdaQueryWrapper<User>()
                .eq(User::getStatus, 1)
                .orderByDesc(User::getTotalPoints)
                .last("LIMIT " + limit)
        );

        List<Map<String, Object>> ranking = new ArrayList<>();
        int rank = 1;
        for (User user : users) {
            Map<String, Object> item = new HashMap<>();
            item.put("rank", rank++);
            item.put("userId", user.getId());
            item.put("username", user.getUsername());
            item.put("realName", user.getRealName());
            item.put("avatar", user.getAvatar());
            item.put("value", user.getTotalPoints());
            item.put("unit", "积分");
            ranking.add(item);
        }

        cacheRanking(cacheKey, ranking, 30);
        return ranking;
    }

    /**
     * 获取成就排行榜
     */
    public List<Map<String, Object>> getAchievementRanking(int limit) {
        String cacheKey = RANKING_KEY_PREFIX + "achievement";
        
        List<Map<String, Object>> cached = getCachedRanking(cacheKey, limit);
        if (cached != null) {
            return cached;
        }

        // 统计每个用户的成就数量
        List<Map<String, Object>> achievementCounts = userAchievementMapper.selectMaps(
            new LambdaQueryWrapper<UserAchievement>()
                .select(UserAchievement::getUserId)
                .groupBy(UserAchievement::getUserId)
                .orderByDesc(UserAchievement::getUserId)
        );

        // 这里需要自定义SQL，简化处理
        List<User> users = userMapper.selectList(
            new LambdaQueryWrapper<User>()
                .eq(User::getStatus, 1)
                .orderByDesc(User::getTotalPoints) // 暂时用积分代替
                .last("LIMIT " + limit)
        );

        List<Map<String, Object>> ranking = new ArrayList<>();
        int rank = 1;
        for (User user : users) {
            // 查询用户成就数量
            Long achievementCount = userAchievementMapper.selectCount(
                new LambdaQueryWrapper<UserAchievement>().eq(UserAchievement::getUserId, user.getId())
            );
            
            Map<String, Object> item = new HashMap<>();
            item.put("rank", rank++);
            item.put("userId", user.getId());
            item.put("username", user.getUsername());
            item.put("realName", user.getRealName());
            item.put("avatar", user.getAvatar());
            item.put("value", achievementCount);
            item.put("unit", "个成就");
            ranking.add(item);
        }

        // 按成就数量重新排序
        ranking.sort((a, b) -> {
            Long va = (Long) a.get("value");
            Long vb = (Long) b.get("value");
            return vb.compareTo(va);
        });
        
        // 重新设置排名
        for (int i = 0; i < ranking.size(); i++) {
            ranking.get(i).put("rank", i + 1);
        }

        cacheRanking(cacheKey, ranking, 60);
        return ranking;
    }

    /**
     * 获取用户在排行榜中的位置
     */
    public Map<String, Object> getUserRankInfo(Long userId, String type) {
        Map<String, Object> result = new HashMap<>();
        
        User user = userMapper.selectById(userId);
        if (user == null) {
            return result;
        }

        switch (type) {
            case "study_time":
                // 数据库存的是分钟，转换为小时（保留1位小数）
                int totalMinutes = user.getTotalStudyTime() != null ? user.getTotalStudyTime() : 0;
                double hours = Math.round(totalMinutes / 6.0) / 10.0;
                result.put("value", hours);
                result.put("unit", "小时");
                // 计算排名
                Long studyTimeRank = userMapper.selectCount(
                    new LambdaQueryWrapper<User>()
                        .gt(User::getTotalStudyTime, user.getTotalStudyTime())
                        .eq(User::getStatus, 1)
                ) + 1;
                result.put("rank", studyTimeRank);
                break;
            case "checkin_streak":
                result.put("value", user.getCurrentStreak());
                result.put("unit", "天");
                Long checkInRank = userMapper.selectCount(
                    new LambdaQueryWrapper<User>()
                        .gt(User::getCurrentStreak, user.getCurrentStreak())
                        .eq(User::getStatus, 1)
                ) + 1;
                result.put("rank", checkInRank);
                break;
            case "points":
                result.put("value", user.getTotalPoints());
                result.put("unit", "积分");
                Long pointsRank = userMapper.selectCount(
                    new LambdaQueryWrapper<User>()
                        .gt(User::getTotalPoints, user.getTotalPoints())
                        .eq(User::getStatus, 1)
                ) + 1;
                result.put("rank", pointsRank);
                break;
            default:
                break;
        }

        result.put("userId", userId);
        result.put("username", user.getUsername());
        result.put("realName", user.getRealName());
        result.put("avatar", user.getAvatar());
        
        return result;
    }

    /**
     * 刷新所有排行榜缓存
     */
    public void refreshAllRankings() {
        // 清除缓存
        Set<String> keys = redisTemplate.keys(RANKING_KEY_PREFIX + "*");
        if (keys != null && !keys.isEmpty()) {
            redisTemplate.delete(keys);
        }

        // 预热排行榜
        getStudyTimeRanking("daily", DEFAULT_TOP_SIZE);
        getStudyTimeRanking("weekly", DEFAULT_TOP_SIZE);
        getStudyTimeRanking("monthly", DEFAULT_TOP_SIZE);
        getStudyTimeRanking("all", DEFAULT_TOP_SIZE);
        getCheckInStreakRanking(DEFAULT_TOP_SIZE);
        getPointsRanking(DEFAULT_TOP_SIZE);
        getAchievementRanking(DEFAULT_TOP_SIZE);
    }

    // ========== 私有方法 ==========

    private LocalDateTime getStartTimeByPeriod(String period) {
        LocalDate today = LocalDate.now();
        switch (period) {
            case "daily":
                return today.atStartOfDay();
            case "weekly":
                return today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)).atStartOfDay();
            case "monthly":
                return today.withDayOfMonth(1).atStartOfDay();
            default:
                return LocalDateTime.of(2020, 1, 1, 0, 0);
        }
    }

    private int getExpireMinutes(String period) {
        switch (period) {
            case "daily":
                return 10;
            case "weekly":
                return 30;
            case "monthly":
                return 60;
            default:
                return 120;
        }
    }

    private List<Map<String, Object>> calculateStudyTimeRanking(LocalDateTime startTime, int limit) {
        // 基于用户累计学习时间排序
        List<User> users = userMapper.selectList(
            new LambdaQueryWrapper<User>()
                .eq(User::getStatus, 1)
                .orderByDesc(User::getTotalStudyTime)
                .last("LIMIT " + limit)
        );

        List<Map<String, Object>> ranking = new ArrayList<>();
        int rank = 1;
        for (User user : users) {
            Map<String, Object> item = new HashMap<>();
            item.put("rank", rank++);
            item.put("userId", user.getId());
            item.put("username", user.getUsername());
            item.put("realName", user.getRealName());
            item.put("avatar", user.getAvatar());
            // 数据库存的是分钟，转换为小时（保留1位小数）
            int totalMinutes = user.getTotalStudyTime() != null ? user.getTotalStudyTime() : 0;
            double hours = Math.round(totalMinutes / 6.0) / 10.0;  // 保留1位小数
            item.put("value", hours);
            item.put("unit", "小时");
            ranking.add(item);
        }

        return ranking;
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> getCachedRanking(String key, int limit) {
        try {
            Object cached = redisTemplate.opsForValue().get(key);
            if (cached != null) {
                List<Map<String, Object>> list = (List<Map<String, Object>>) cached;
                return list.stream().limit(limit).collect(Collectors.toList());
            }
        } catch (Exception e) {
            // 缓存获取失败，继续从数据库查询
        }
        return null;
    }

    private void cacheRanking(String key, List<Map<String, Object>> ranking, int expireMinutes) {
        try {
            redisTemplate.opsForValue().set(key, ranking, expireMinutes, TimeUnit.MINUTES);
        } catch (Exception e) {
            // 缓存失败，不影响业务
        }
    }
}
