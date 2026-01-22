package com.studyroom.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.studyroom.common.PageResult;
import com.studyroom.common.Result;
import com.studyroom.entity.CreditRecord;
import com.studyroom.entity.ViolationRecord;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.CreditService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 信用积分控制器 - 用户端
 */
@Tag(name = "信用积分", description = "信用积分相关接口")
@RestController
@RequestMapping("/credit")
@RequiredArgsConstructor
public class CreditController {

    private final CreditService creditService;

    @Operation(summary = "获取信用统计")
    @GetMapping("/stats")
    public Result<Map<String, Object>> getStats() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(creditService.getUserCreditStats(userId));
    }

    @Operation(summary = "获取积分记录")
    @GetMapping("/records")
    public Result<PageResult<CreditRecord>> getRecords(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String type) {
        Long userId = SecurityUtil.getCurrentUserId();
        IPage<CreditRecord> page = creditService.getUserCreditRecords(userId, pageNum, pageSize, type);
        return Result.success(PageResult.of(page));
    }

    @Operation(summary = "获取违约记录")
    @GetMapping("/violations")
    public Result<PageResult<ViolationRecord>> getViolations(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String type) {
        Long userId = SecurityUtil.getCurrentUserId();
        IPage<ViolationRecord> page = creditService.getUserViolations(userId, pageNum, pageSize, type);
        return Result.success(PageResult.of(page));
    }

    @Operation(summary = "提交申诉")
    @PostMapping("/violations/{id}/appeal")
    public Result<Void> submitAppeal(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        Long userId = SecurityUtil.getCurrentUserId();
        String reason = body.get("reason");
        if (reason == null || reason.trim().isEmpty()) {
            return Result.error("申诉理由不能为空");
        }
        creditService.submitAppeal(id, userId, reason);
        return Result.success();
    }
}
