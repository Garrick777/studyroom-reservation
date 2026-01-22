package com.studyroom.controller;

import com.studyroom.common.PageResult;
import com.studyroom.common.Result;
import com.studyroom.dto.reservation.*;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.ReservationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "预约管理", description = "座位预约相关接口")
@RestController
@RequestMapping("/reservations")
@RequiredArgsConstructor
public class ReservationController {

    private final ReservationService reservationService;

    @Operation(summary = "创建预约")
    @PostMapping
    public Result<ReservationVO> create(@Valid @RequestBody CreateReservationRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationVO vo = reservationService.createReservation(userId, request);
        return Result.success(vo);
    }

    @Operation(summary = "获取预约详情")
    @GetMapping("/{id}")
    public Result<ReservationVO> getDetail(@PathVariable Long id) {
        ReservationVO vo = reservationService.getReservationDetail(id);
        if (vo == null) {
            return Result.error("预约不存在");
        }
        return Result.success(vo);
    }

    @Operation(summary = "获取当前预约")
    @GetMapping("/current")
    public Result<ReservationVO> getCurrent() {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationVO vo = reservationService.getCurrentReservation(userId);
        return Result.success(vo);
    }

    @Operation(summary = "查询我的预约列表")
    @GetMapping("/my")
    public Result<PageResult<ReservationVO>> getMyReservations(ReservationQueryRequest query) {
        Long userId = SecurityUtil.getCurrentUserId();
        PageResult<ReservationVO> result = reservationService.getUserReservations(userId, query);
        return Result.success(result);
    }

    @Operation(summary = "签到")
    @PostMapping("/{id}/sign-in")
    public Result<ReservationVO> signIn(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationVO vo = reservationService.signIn(userId, id);
        return Result.success(vo);
    }

    @Operation(summary = "签退")
    @PostMapping("/{id}/sign-out")
    public Result<ReservationVO> signOut(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationVO vo = reservationService.signOut(userId, id);
        return Result.success(vo);
    }

    @Operation(summary = "暂离")
    @PostMapping("/{id}/leave")
    public Result<ReservationVO> leave(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationVO vo = reservationService.leave(userId, id);
        return Result.success(vo);
    }

    @Operation(summary = "暂离返回")
    @PostMapping("/{id}/return")
    public Result<ReservationVO> returnFromLeave(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationVO vo = reservationService.returnFromLeave(userId, id);
        return Result.success(vo);
    }

    @Operation(summary = "取消预约")
    @PostMapping("/{id}/cancel")
    public Result<ReservationVO> cancel(@PathVariable Long id, 
                                        @RequestParam(required = false) String reason) {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationVO vo = reservationService.cancel(userId, id, reason);
        return Result.success(vo);
    }
}
