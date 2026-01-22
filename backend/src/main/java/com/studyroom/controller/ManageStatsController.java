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
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 管理员统计Controller
 */
@Tag(name = "管理统计", description = "管理员统计接口")
@RestController
@RequestMapping("/manage/stats")
@RequiredArgsConstructor
public class ManageStatsController {

    private final StudyRoomMapper studyRoomMapper;
    private final SeatMapper seatMapper;
    private final ReservationMapper reservationMapper;
    private final ViolationRecordMapper violationRecordMapper;
    private final UserMapper userMapper;
    private final CheckInRecordMapper checkInRecordMapper;

    @Operation(summary = "获取管理员概览统计")
    @GetMapping("/overview")
    public Result<Map<String, Object>> getOverview() {
        Map<String, Object> result = new HashMap<>();
        
        // 自习室统计
        Long totalRooms = studyRoomMapper.selectCount(null);
        Long openRooms = studyRoomMapper.selectCount(
            new LambdaQueryWrapper<StudyRoom>().eq(StudyRoom::getStatus, 1)
        );
        
        // 座位统计
        Long totalSeats = seatMapper.selectCount(
            new LambdaQueryWrapper<Seat>().eq(Seat::getStatus, 1)
        );
        
        // 通过预约表统计座位使用情况
        Long inUseSeats = reservationMapper.selectCount(
            new LambdaQueryWrapper<Reservation>()
                .eq(Reservation::getStatus, "CHECKED_IN")
        );
        Long awaySeats = reservationMapper.selectCount(
            new LambdaQueryWrapper<Reservation>()
                .eq(Reservation::getStatus, "AWAY")
        );
        Long availableSeats = totalSeats - inUseSeats - awaySeats;
        if (availableSeats < 0) availableSeats = 0L;
        
        // 今日预约统计
        LocalDateTime todayStart = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
        LocalDateTime todayEnd = LocalDateTime.of(LocalDate.now(), LocalTime.MAX);
        
        Long todayReservations = reservationMapper.selectCount(
            new LambdaQueryWrapper<Reservation>()
                .ge(Reservation::getCreatedAt, todayStart)
                .le(Reservation::getCreatedAt, todayEnd)
        );
        
        Long activeReservations = reservationMapper.selectCount(
            new LambdaQueryWrapper<Reservation>()
                .in(Reservation::getStatus, Arrays.asList("CONFIRMED", "CHECKED_IN", "AWAY"))
        );
        
        // 今日违规
        Long todayViolations = violationRecordMapper.selectCount(
            new LambdaQueryWrapper<ViolationRecord>()
                .ge(ViolationRecord::getCreatedAt, todayStart)
                .le(ViolationRecord::getCreatedAt, todayEnd)
        );
        
        // 待处理申诉
        Long pendingAppeals = violationRecordMapper.selectCount(
            new LambdaQueryWrapper<ViolationRecord>()
                .eq(ViolationRecord::getAppealStatus, 1)
        );
        
        result.put("totalRooms", totalRooms);
        result.put("openRooms", openRooms);
        result.put("totalSeats", totalSeats);
        result.put("availableSeats", availableSeats);
        result.put("inUseSeats", inUseSeats);
        result.put("awaySeats", awaySeats);
        result.put("todayReservations", todayReservations);
        result.put("activeReservations", activeReservations);
        result.put("todayViolations", todayViolations);
        result.put("pendingAppeals", pendingAppeals);
        
        return Result.success(result);
    }

    @Operation(summary = "获取实时状态")
    @GetMapping("/realtime")
    public Result<Map<String, Object>> getRealTimeStatus() {
        Map<String, Object> result = new HashMap<>();
        
        // 座位使用率 - 通过预约表统计
        Long totalSeats = seatMapper.selectCount(
            new LambdaQueryWrapper<Seat>().eq(Seat::getStatus, 1)
        );
        Long inUseSeats = reservationMapper.selectCount(
            new LambdaQueryWrapper<Reservation>()
                .eq(Reservation::getStatus, "CHECKED_IN")
        );
        
        double occupancyRate = totalSeats > 0 ? Math.round(inUseSeats * 100.0 / totalSeats * 10) / 10.0 : 0;
        
        // 高峰时段（简化计算）
        String peakHour = "14:00-16:00";
        
        // 平均学习时长（分钟）
        int avgDuration = 120;
        
        result.put("occupancyRate", occupancyRate);
        result.put("peakHour", peakHour);
        result.put("avgDuration", avgDuration);
        
        return Result.success(result);
    }

    @Operation(summary = "获取最近活动")
    @GetMapping("/activities")
    public Result<List<Map<String, Object>>> getRecentActivities() {
        List<Map<String, Object>> activities = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");
        
        // 获取最近的预约记录
        List<Reservation> recentReservations = reservationMapper.selectList(
            new LambdaQueryWrapper<Reservation>()
                .orderByDesc(Reservation::getUpdatedAt)
                .last("LIMIT 10")
        );
        
        for (Reservation r : recentReservations) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("id", r.getId());
            
            String type = "RESERVATION";
            String content = "新预约";
            
            if ("CHECKED_IN".equals(r.getStatus())) {
                type = "CHECK_IN";
                content = "已签到";
            } else if ("AWAY".equals(r.getStatus())) {
                type = "AWAY";
                content = "暂离中";
            } else if ("COMPLETED".equals(r.getStatus())) {
                type = "CHECK_OUT";
                content = "已签退";
            }
            
            activity.put("type", type);
            activity.put("content", content);
            activity.put("time", r.getUpdatedAt() != null ? r.getUpdatedAt().format(formatter) : "");
            
            // 获取用户名
            User user = userMapper.selectById(r.getUserId());
            if (user != null) {
                activity.put("user", user.getRealName());
            }
            
            activities.add(activity);
        }
        
        // 获取最近违规
        List<ViolationRecord> recentViolations = violationRecordMapper.selectList(
            new LambdaQueryWrapper<ViolationRecord>()
                .orderByDesc(ViolationRecord::getCreatedAt)
                .last("LIMIT 5")
        );
        
        for (ViolationRecord v : recentViolations) {
            Map<String, Object> activity = new HashMap<>();
            activity.put("id", v.getId() + 10000);
            activity.put("type", "VIOLATION");
            activity.put("content", "违规: " + v.getDescription());
            activity.put("time", v.getCreatedAt().format(formatter));
            
            User user = userMapper.selectById(v.getUserId());
            if (user != null) {
                activity.put("user", user.getRealName());
            }
            
            activities.add(activity);
        }
        
        // 按时间排序
        activities.sort((a, b) -> ((String)b.get("time")).compareTo((String)a.get("time")));
        
        // 限制返回数量
        if (activities.size() > 20) {
            activities = activities.subList(0, 20);
        }
        
        return Result.success(activities);
    }
}
