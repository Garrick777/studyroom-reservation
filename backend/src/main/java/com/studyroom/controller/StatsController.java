package com.studyroom.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.studyroom.common.Result;
import com.studyroom.entity.*;
import com.studyroom.mapper.*;
import com.studyroom.security.SecurityUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 统计Controller - 为工作台提供数据
 */
@Tag(name = "统计", description = "统计相关接口")
@RestController
@RequestMapping("/stats")
@RequiredArgsConstructor
public class StatsController {

    private final UserMapper userMapper;
    private final StudyRoomMapper studyRoomMapper;
    private final SeatMapper seatMapper;
    private final ReservationMapper reservationMapper;
    private final CheckInRecordMapper checkInRecordMapper;
    private final StudyGoalMapper studyGoalMapper;
    private final AchievementMapper achievementMapper;
    private final UserAchievementMapper userAchievementMapper;

    @Operation(summary = "获取仪表盘统计数据")
    @GetMapping("/dashboard")
    public Result<Map<String, Object>> getDashboardStats() {
        Long userId = SecurityUtil.getCurrentUserId();
        User user = userMapper.selectById(userId);
        
        Map<String, Object> stats = new HashMap<>();
        
        // 用户基本统计
        stats.put("creditScore", user.getCreditScore() != null ? user.getCreditScore() : 100);
        stats.put("totalPoints", user.getTotalPoints() != null ? user.getTotalPoints() : 0);
        stats.put("totalStudyTime", user.getTotalStudyTime() != null ? user.getTotalStudyTime() : 0);
        stats.put("totalStudyHours", user.getTotalStudyTime() != null ? 
            Math.round(user.getTotalStudyTime() / 60.0 * 10) / 10.0 : 0);
        stats.put("consecutiveDays", user.getConsecutiveDays() != null ? user.getConsecutiveDays() : 0);
        stats.put("totalCheckIns", user.getTotalCheckIns() != null ? user.getTotalCheckIns() : 0);
        stats.put("currentStreak", user.getCurrentStreak() != null ? user.getCurrentStreak() : 0);
        stats.put("maxStreak", user.getMaxStreak() != null ? user.getMaxStreak() : 0);
        
        // 今日学习时间 - 从今日预约中计算
        LocalDateTime todayStart = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
        LocalDateTime todayEnd = LocalDateTime.of(LocalDate.now(), LocalTime.MAX);
        
        List<Reservation> todayReservations = reservationMapper.selectList(
            new LambdaQueryWrapper<Reservation>()
                .eq(Reservation::getUserId, userId)
                .eq(Reservation::getStatus, 3) // 已完成
                .ge(Reservation::getStartTime, todayStart)
                .le(Reservation::getEndTime, todayEnd)
        );
        
        int todayMinutes = todayReservations.stream()
            .mapToInt(r -> r.getActualDuration() != null ? r.getActualDuration() : 0)
            .sum();
        
        stats.put("todayStudyTime", todayMinutes);
        stats.put("todayStudyHours", Math.round(todayMinutes / 60.0 * 10) / 10.0);
        
        // 今日目标 - 查找当前有效的每日学习目标
        StudyGoal todayGoal = studyGoalMapper.selectOne(
            new LambdaQueryWrapper<StudyGoal>()
                .eq(StudyGoal::getUserId, userId)
                .eq(StudyGoal::getType, StudyGoal.TYPE_DAILY_HOURS)
                .eq(StudyGoal::getStatus, StudyGoal.STATUS_ACTIVE)
                .le(StudyGoal::getStartDate, LocalDate.now())
                .ge(StudyGoal::getEndDate, LocalDate.now())
                .last("LIMIT 1")
        );
        
        int dailyGoalHours = 4; // 默认4小时
        double dailyGoalProgress = 0;
        
        if (todayGoal != null && todayGoal.getTargetValue() != null) {
            dailyGoalHours = todayGoal.getTargetValue().intValue();
            if (dailyGoalHours > 0) {
                dailyGoalProgress = Math.min(1.0, todayMinutes / 60.0 / dailyGoalHours);
            }
        }
        
        stats.put("dailyGoalHours", dailyGoalHours);
        stats.put("dailyGoalProgress", dailyGoalProgress);
        
        return Result.success(stats);
    }

    @Operation(summary = "获取热门自习室")
    @GetMapping("/hot-rooms")
    public Result<List<Map<String, Object>>> getHotRooms() {
        // 获取开放中的自习室，按评分排序
        List<StudyRoom> rooms = studyRoomMapper.selectList(
            new LambdaQueryWrapper<StudyRoom>()
                .eq(StudyRoom::getStatus, 1)
                .orderByDesc(StudyRoom::getRating)
                .last("LIMIT 4")
        );
        
        List<Map<String, Object>> result = rooms.stream().map(room -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", room.getId());
            map.put("name", room.getName());
            map.put("code", room.getCode());
            map.put("building", room.getBuilding());
            map.put("floor", room.getFloor());
            map.put("capacity", room.getCapacity());
            map.put("rating", room.getRating() != null ? room.getRating() : 4.5);
            map.put("ratingCount", room.getRatingCount() != null ? room.getRatingCount() : 0);
            map.put("openTime", room.getOpenTime());
            map.put("closeTime", room.getCloseTime());
            map.put("coverImage", room.getCoverImage());
            
            // 计算可用座位
            Long availableSeats = seatMapper.selectCount(
                new LambdaQueryWrapper<Seat>()
                    .eq(Seat::getRoomId, room.getId())
                    .eq(Seat::getStatus, 1)
            );
            map.put("availableSeats", availableSeats);
            map.put("totalSeats", room.getCapacity());
            
            return map;
        }).collect(Collectors.toList());
        
        return Result.success(result);
    }

    @Operation(summary = "获取排行榜")
    @GetMapping("/ranking")
    public Result<Map<String, Object>> getRanking(
            @RequestParam(defaultValue = "today") String type,
            @RequestParam(defaultValue = "10") int limit) {
        
        Long currentUserId = SecurityUtil.getCurrentUserId();
        
        // 获取学习时长排行 - 按总学习时间排序
        List<User> topUsers = userMapper.selectList(
            new LambdaQueryWrapper<User>()
                .eq(User::getRole, "STUDENT")
                .eq(User::getStatus, 1)
                .orderByDesc(User::getTotalStudyTime)
                .last("LIMIT " + limit)
        );
        
        List<Map<String, Object>> list = new ArrayList<>();
        int rank = 1;
        for (User user : topUsers) {
            Map<String, Object> item = new HashMap<>();
            item.put("rank", rank);
            item.put("userId", user.getId());
            item.put("username", user.getUsername());
            item.put("realName", user.getRealName());
            item.put("avatar", user.getAvatar());
            item.put("totalStudyTime", user.getTotalStudyTime() != null ? user.getTotalStudyTime() : 0);
            item.put("totalStudyHours", user.getTotalStudyTime() != null ? 
                Math.round(user.getTotalStudyTime() / 60.0 * 10) / 10.0 : 0);
            item.put("totalPoints", user.getTotalPoints() != null ? user.getTotalPoints() : 0);
            list.add(item);
            rank++;
        }
        
        // 获取当前用户排名
        Long myRankCount = userMapper.selectCount(
            new LambdaQueryWrapper<User>()
                .eq(User::getRole, "STUDENT")
                .eq(User::getStatus, 1)
                .gt(User::getTotalStudyTime, 
                    userMapper.selectById(currentUserId).getTotalStudyTime() != null ? 
                    userMapper.selectById(currentUserId).getTotalStudyTime() : 0)
        );
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("type", type);
        result.put("myRank", myRankCount + 1);
        
        return Result.success(result);
    }

    @Operation(summary = "获取用户成就")
    @GetMapping("/achievements")
    public Result<Map<String, Object>> getAchievements() {
        Long userId = SecurityUtil.getCurrentUserId();
        
        // 获取所有成就
        List<Achievement> allAchievements = achievementMapper.selectList(
            new LambdaQueryWrapper<Achievement>()
                .eq(Achievement::getStatus, 1)
                .orderByAsc(Achievement::getSortOrder)
        );
        
        // 获取用户已解锁成就
        List<UserAchievement> userAchievements = userAchievementMapper.selectList(
            new LambdaQueryWrapper<UserAchievement>()
                .eq(UserAchievement::getUserId, userId)
        );
        Set<Long> unlockedIds = userAchievements.stream()
            .map(UserAchievement::getAchievementId)
            .collect(Collectors.toSet());
        
        List<Map<String, Object>> list = allAchievements.stream().map(ach -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", ach.getId());
            item.put("name", ach.getName());
            item.put("description", ach.getDescription());
            item.put("icon", ach.getIcon());
            item.put("rarity", ach.getRarity());
            item.put("unlocked", unlockedIds.contains(ach.getId()));
            
            // 获取解锁时间
            userAchievements.stream()
                .filter(ua -> ua.getAchievementId().equals(ach.getId()))
                .findFirst()
                .ifPresent(ua -> item.put("unlockedAt", ua.getCompletedAt()));
            
            return item;
        }).collect(Collectors.toList());
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", allAchievements.size());
        result.put("unlocked", unlockedIds.size());
        
        return Result.success(result);
    }
}
