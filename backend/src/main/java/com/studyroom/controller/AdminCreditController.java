package com.studyroom.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.studyroom.common.PageResult;
import com.studyroom.common.Result;
import com.studyroom.entity.Blacklist;
import com.studyroom.entity.ViolationRecord;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.CreditService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 管理端信用积分控制器
 */
@Tag(name = "管理端-信用管理", description = "违约处理、黑名单管理、积分调整")
@RestController
@RequestMapping("/manage/credit")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
public class AdminCreditController {

    private final CreditService creditService;

    // ==================== 违约管理 ====================

    @Operation(summary = "查询违约记录列表")
    @GetMapping("/violations")
    public Result<PageResult<ViolationRecord>> getViolations(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) Integer appealStatus) {
        IPage<ViolationRecord> page = creditService.getAllViolations(pageNum, pageSize, userId, type, appealStatus);
        return Result.success(PageResult.of(page));
    }

    @Operation(summary = "处理申诉")
    @PostMapping("/violations/{id}/process-appeal")
    public Result<Void> processAppeal(
            @PathVariable Long id,
            @RequestBody ProcessAppealRequest request) {
        Long operatorId = SecurityUtil.getCurrentUserId();
        creditService.processAppeal(id, request.isApproved(), request.getResult(), operatorId);
        return Result.success();
    }

    // ==================== 黑名单管理 ====================

    @Operation(summary = "查询黑名单列表")
    @GetMapping("/blacklist")
    public Result<PageResult<Blacklist>> getBlacklist(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) Integer released,
            @RequestParam(required = false) String keyword) {
        IPage<Blacklist> page = creditService.getBlacklistPage(pageNum, pageSize, released, keyword);
        return Result.success(PageResult.of(page));
    }

    @Operation(summary = "添加到黑名单")
    @PostMapping("/blacklist")
    public Result<Void> addToBlacklist(@RequestBody AddBlacklistRequest request) {
        Long operatorId = SecurityUtil.getCurrentUserId();
        creditService.addToBlacklist(request.getUserId(), request.getReason(), 
                request.getDurationDays(), operatorId);
        return Result.success();
    }

    @Operation(summary = "从黑名单解除")
    @DeleteMapping("/blacklist/{userId}")
    public Result<Void> releaseFromBlacklist(
            @PathVariable Long userId,
            @RequestParam(required = false) String reason) {
        Long operatorId = SecurityUtil.getCurrentUserId();
        creditService.releaseFromBlacklist(userId, operatorId, 
                reason != null ? reason : "管理员手动解除");
        return Result.success();
    }

    @Operation(summary = "检查用户是否在黑名单")
    @GetMapping("/blacklist/check/{userId}")
    public Result<Map<String, Object>> checkBlacklist(@PathVariable Long userId) {
        boolean isBlacklisted = creditService.isInBlacklist(userId);
        Blacklist blacklist = creditService.getActiveBlacklist(userId);
        return Result.success(Map.of(
                "isBlacklisted", isBlacklisted,
                "blacklist", blacklist != null ? blacklist : Map.of()
        ));
    }

    // ==================== 积分调整 ====================

    @Operation(summary = "调整用户积分")
    @PostMapping("/adjust")
    public Result<Void> adjustCreditScore(@RequestBody AdjustCreditRequest request) {
        Long operatorId = SecurityUtil.getCurrentUserId();
        creditService.adjustCreditScore(request.getUserId(), request.getNewScore(), 
                operatorId, request.getReason());
        return Result.success();
    }

    @Operation(summary = "获取用户信用统计")
    @GetMapping("/stats/{userId}")
    public Result<Map<String, Object>> getUserStats(@PathVariable Long userId) {
        return Result.success(creditService.getUserCreditStats(userId));
    }

    // ==================== 请求DTO ====================

    @Data
    public static class ProcessAppealRequest {
        private boolean approved;
        private String result;
    }

    @Data
    public static class AddBlacklistRequest {
        private Long userId;
        private String reason;
        private Integer durationDays; // null表示永久
    }

    @Data
    public static class AdjustCreditRequest {
        private Long userId;
        private Integer newScore;
        private String reason;
    }
}
