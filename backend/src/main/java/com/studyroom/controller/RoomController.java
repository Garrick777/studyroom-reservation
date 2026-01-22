package com.studyroom.controller;

import com.studyroom.common.PageResult;
import com.studyroom.common.Result;
import com.studyroom.entity.Seat;
import com.studyroom.entity.StudyRoom;
import com.studyroom.entity.TimeSlot;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.RoomService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * 自习室控制器
 */
@Tag(name = "自习室管理", description = "自习室查询、收藏等接口")
@RestController
@RequestMapping("/rooms")
@RequiredArgsConstructor
public class RoomController {

    private final RoomService roomService;

    // ========== 自习室查询 ==========

    @Operation(summary = "获取自习室列表")
    @GetMapping
    public Result<PageResult<StudyRoom>> getRoomList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String building,
            @RequestParam(required = false) Integer status) {
        var pageResult = roomService.getRoomList(page, size, keyword, building, status);
        return Result.success(PageResult.of(pageResult));
    }

    @Operation(summary = "获取自习室详情")
    @GetMapping("/{roomId}")
    public Result<StudyRoom> getRoomDetail(@PathVariable Long roomId) {
        StudyRoom room = roomService.getRoomById(roomId);
        return Result.success(room);
    }

    @Operation(summary = "获取热门自习室")
    @GetMapping("/hot")
    public Result<List<StudyRoom>> getHotRooms(
            @RequestParam(defaultValue = "6") int limit) {
        List<StudyRoom> rooms = roomService.getHotRooms(limit);
        return Result.success(rooms);
    }

    @Operation(summary = "获取评分最高的自习室")
    @GetMapping("/top-rated")
    public Result<List<StudyRoom>> getTopRatedRooms(
            @RequestParam(defaultValue = "6") int limit) {
        List<StudyRoom> rooms = roomService.getTopRatedRooms(limit);
        return Result.success(rooms);
    }

    // ========== 座位查询 ==========

    @Operation(summary = "获取自习室座位列表")
    @GetMapping("/{roomId}/seats")
    public Result<List<Seat>> getRoomSeats(@PathVariable Long roomId) {
        List<Seat> seats = roomService.getSeatsByRoomId(roomId);
        return Result.success(seats);
    }

    @Operation(summary = "获取座位实时状态")
    @GetMapping("/{roomId}/seats/status")
    public Result<List<Seat>> getSeatsWithStatus(
            @PathVariable Long roomId,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date,
            @RequestParam Long timeSlotId) {
        List<Seat> seats = roomService.getSeatsWithStatus(roomId, date, timeSlotId);
        return Result.success(seats);
    }

    // ========== 时段查询 ==========

    @Operation(summary = "获取所有时段")
    @GetMapping("/time-slots")
    public Result<List<TimeSlot>> getTimeSlots() {
        List<TimeSlot> slots = roomService.getTimeSlots();
        return Result.success(slots);
    }

    @Operation(summary = "获取自习室可用时段")
    @GetMapping("/{roomId}/time-slots")
    public Result<List<TimeSlot>> getAvailableTimeSlots(
            @PathVariable Long roomId,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date) {
        List<TimeSlot> slots = roomService.getAvailableTimeSlots(roomId, date);
        return Result.success(slots);
    }

    // ========== 收藏功能 ==========

    @Operation(summary = "收藏自习室")
    @PostMapping("/{roomId}/favorite")
    public Result<Void> addFavorite(@PathVariable Long roomId) {
        Long userId = SecurityUtil.getCurrentUserId();
        roomService.addFavorite(userId, roomId);
        return Result.success("收藏成功", null);
    }

    @Operation(summary = "取消收藏")
    @DeleteMapping("/{roomId}/favorite")
    public Result<Void> removeFavorite(@PathVariable Long roomId) {
        Long userId = SecurityUtil.getCurrentUserId();
        roomService.removeFavorite(userId, roomId);
        return Result.success("已取消收藏", null);
    }

    @Operation(summary = "获取我的收藏列表")
    @GetMapping("/favorites")
    public Result<List<StudyRoom>> getUserFavorites() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<StudyRoom> rooms = roomService.getUserFavorites(userId);
        return Result.success(rooms);
    }

    @Operation(summary = "检查是否已收藏")
    @GetMapping("/{roomId}/is-favorite")
    public Result<Boolean> isFavorite(@PathVariable Long roomId) {
        Long userId = SecurityUtil.getCurrentUserId();
        boolean isFavorite = roomService.isFavorite(userId, roomId);
        return Result.success(isFavorite);
    }
}
