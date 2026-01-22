package com.studyroom.controller;

import com.studyroom.common.PageResult;
import com.studyroom.common.Result;
import com.studyroom.dto.reservation.*;
import com.studyroom.service.ReservationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@Tag(name = "管理端-预约管理", description = "管理员预约管理接口")
@RestController
@RequestMapping("/manage/reservations")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
public class AdminReservationController {

    private final ReservationService reservationService;

    @Operation(summary = "查询所有预约")
    @GetMapping
    public Result<PageResult<ReservationVO>> list(ReservationQueryRequest query) {
        PageResult<ReservationVO> result = reservationService.getAdminReservations(query);
        return Result.success(result);
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

    @Operation(summary = "获取今日预约统计")
    @GetMapping("/stats/today")
    public Result<Map<String, Object>> getTodayStats() {
        ReservationQueryRequest query = new ReservationQueryRequest();
        query.setStartDate(LocalDate.now());
        query.setEndDate(LocalDate.now());
        query.setPageSize(1000);
        
        PageResult<ReservationVO> all = reservationService.getAdminReservations(query);
        
        long total = all.getTotal();
        long pending = all.getRecords().stream().filter(r -> "PENDING".equals(r.getStatus())).count();
        long signedIn = all.getRecords().stream().filter(r -> "SIGNED_IN".equals(r.getStatus())).count();
        long leaving = all.getRecords().stream().filter(r -> "LEAVING".equals(r.getStatus())).count();
        long completed = all.getRecords().stream().filter(r -> "COMPLETED".equals(r.getStatus())).count();
        long cancelled = all.getRecords().stream().filter(r -> "CANCELLED".equals(r.getStatus())).count();
        long noShow = all.getRecords().stream().filter(r -> "NO_SHOW".equals(r.getStatus())).count();
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", total);
        stats.put("pending", pending);
        stats.put("signedIn", signedIn);
        stats.put("leaving", leaving);
        stats.put("inUse", signedIn + leaving);
        stats.put("completed", completed);
        stats.put("cancelled", cancelled);
        stats.put("noShow", noShow);
        
        return Result.success(stats);
    }
}
