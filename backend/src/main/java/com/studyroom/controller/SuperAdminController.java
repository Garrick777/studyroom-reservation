package com.studyroom.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.studyroom.common.Result;
import com.studyroom.entity.*;
import com.studyroom.mapper.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

/**
 * 超级管理员Controller
 */
@Tag(name = "超级管理员", description = "超级管理员相关接口")
@RestController
@RequestMapping("/super-admin")
@RequiredArgsConstructor
public class SuperAdminController {

    private final UserMapper userMapper;
    private final StudyRoomMapper studyRoomMapper;
    private final SeatMapper seatMapper;
    private final ViolationRecordMapper violationRecordMapper;
    private final BlacklistMapper blacklistMapper;
    private final CheckInRecordMapper checkInRecordMapper;
    private final AchievementMapper achievementMapper;

    @Operation(summary = "获取超管统计数据")
    @GetMapping("/stats")
    public Result<Map<String, Object>> getStats() {
        Map<String, Object> result = new HashMap<>();
        
        // 用户统计
        Long totalUsers = userMapper.selectCount(
            new LambdaQueryWrapper<User>().eq(User::getRole, "STUDENT")
        );
        
        // 活跃用户（最近7天有登录或打卡）
        LocalDateTime weekAgo = LocalDateTime.now().minusDays(7);
        Long activeUsers = checkInRecordMapper.selectCount(
            new LambdaQueryWrapper<CheckInRecord>()
                .ge(CheckInRecord::getCheckInTime, weekAgo)
        );
        
        // 管理员数量
        Long totalAdmins = userMapper.selectCount(
            new LambdaQueryWrapper<User>().eq(User::getRole, "ADMIN")
        );
        
        // 自习室统计
        Long totalRooms = studyRoomMapper.selectCount(null);
        Long totalSeats = seatMapper.selectCount(null);
        
        // 黑名单数量
        Long blacklistCount = blacklistMapper.selectCount(
            new LambdaQueryWrapper<Blacklist>().eq(Blacklist::getReleased, 0)
        );
        
        // 今日打卡
        LocalDateTime todayStart = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
        Long todayCheckIns = checkInRecordMapper.selectCount(
            new LambdaQueryWrapper<CheckInRecord>()
                .ge(CheckInRecord::getCheckInTime, todayStart)
        );
        
        // 成就总数
        Long totalAchievements = achievementMapper.selectCount(null);
        
        // 待处理申诉
        Long pendingAppeals = violationRecordMapper.selectCount(
            new LambdaQueryWrapper<ViolationRecord>()
                .eq(ViolationRecord::getAppealStatus, 1)
        );
        
        // 即将到期的黑名单（7天内）
        LocalDateTime weekLater = LocalDateTime.now().plusDays(7);
        Long blacklistExpiring = blacklistMapper.selectCount(
            new LambdaQueryWrapper<Blacklist>()
                .eq(Blacklist::getReleased, 0)
                .le(Blacklist::getEndTime, weekLater)
        );
        
        // 最近7天新用户
        Long newUsers = userMapper.selectCount(
            new LambdaQueryWrapper<User>()
                .eq(User::getRole, "STUDENT")
                .ge(User::getCreateTime, weekAgo)
        );
        
        // 组装结果
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", totalUsers);
        stats.put("activeUsers", activeUsers);
        stats.put("totalAdmins", totalAdmins);
        stats.put("totalRooms", totalRooms);
        stats.put("totalSeats", totalSeats);
        stats.put("blacklistCount", blacklistCount);
        stats.put("todayCheckIns", todayCheckIns);
        stats.put("totalAchievements", totalAchievements);
        
        Map<String, Object> pendingTasks = new HashMap<>();
        pendingTasks.put("appeals", pendingAppeals);
        pendingTasks.put("blacklistExpiring", blacklistExpiring);
        pendingTasks.put("newUsers", newUsers);
        
        Map<String, String> systemStatus = new HashMap<>();
        systemStatus.put("database", "healthy");
        systemStatus.put("redis", "healthy");
        systemStatus.put("storage", "healthy");
        
        result.put("stats", stats);
        result.put("pendingTasks", pendingTasks);
        result.put("systemStatus", systemStatus);
        
        return Result.success(result);
    }
}
