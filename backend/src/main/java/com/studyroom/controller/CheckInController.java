package com.studyroom.controller;

import com.studyroom.common.Result;
import com.studyroom.entity.CheckInRecord;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.CheckInService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * 打卡签到控制器
 */
@Tag(name = "打卡签到", description = "每日打卡、打卡记录、打卡统计")
@RestController
@RequestMapping("/checkin")
@RequiredArgsConstructor
public class CheckInController {

    private final CheckInService checkInService;

    @Operation(summary = "每日打卡")
    @PostMapping
    public Result<CheckInRecord> dailyCheckIn(
            @RequestParam(required = false, defaultValue = "WEB") String source) {
        Long userId = SecurityUtil.getCurrentUserId();
        CheckInRecord record = checkInService.dailyCheckIn(userId, source);
        return Result.success(record);
    }

    @Operation(summary = "获取今日打卡状态")
    @GetMapping("/today")
    public Result<Map<String, Object>> getTodayStatus() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(checkInService.getTodayStatus(userId));
    }

    @Operation(summary = "获取月度打卡日历")
    @GetMapping("/calendar")
    public Result<Map<String, Object>> getMonthCalendar(
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer month) {
        Long userId = SecurityUtil.getCurrentUserId();
        
        // 默认当月
        LocalDate now = LocalDate.now();
        if (year == null) year = now.getYear();
        if (month == null) month = now.getMonthValue();
        
        return Result.success(checkInService.getMonthCalendar(userId, year, month));
    }

    @Operation(summary = "获取打卡统计")
    @GetMapping("/stats")
    public Result<Map<String, Object>> getStats() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(checkInService.getCheckInStats(userId));
    }

    @Operation(summary = "获取打卡记录列表")
    @GetMapping("/records")
    public Result<List<CheckInRecord>> getRecords(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate endDate) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(checkInService.getCheckInRecords(userId, startDate, endDate));
    }
}
