package com.studyroom.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.studyroom.common.PageResult;
import com.studyroom.common.Result;
import com.studyroom.entity.StudyGoal;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.StudyGoalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * 学习目标控制器
 */
@Tag(name = "学习目标", description = "学习目标创建、查询、进度跟踪")
@RestController
@RequestMapping("/goals")
@RequiredArgsConstructor
public class StudyGoalController {

    private final StudyGoalService studyGoalService;

    @Operation(summary = "创建学习目标")
    @PostMapping
    public Result<StudyGoal> createGoal(@RequestBody CreateGoalRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        
        StudyGoal goal = new StudyGoal();
        goal.setName(request.getName());
        goal.setType(request.getType());
        goal.setTargetValue(request.getTargetValue());
        goal.setUnit(request.getUnit());
        goal.setStartDate(request.getStartDate() != null ? request.getStartDate() : LocalDate.now());
        goal.setEndDate(request.getEndDate());
        goal.setDescription(request.getDescription());
        goal.setRewardPoints(request.getRewardPoints());
        goal.setRewardExp(request.getRewardExp());
        
        StudyGoal created = studyGoalService.createGoal(userId, goal);
        return Result.success(created);
    }

    @Operation(summary = "获取目标列表")
    @GetMapping
    public Result<PageResult<StudyGoal>> getGoals(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String type) {
        Long userId = SecurityUtil.getCurrentUserId();
        IPage<StudyGoal> page = studyGoalService.getUserGoals(userId, pageNum, pageSize, status, type);
        return Result.success(PageResult.of(page));
    }

    @Operation(summary = "获取进行中的目标")
    @GetMapping("/active")
    public Result<List<StudyGoal>> getActiveGoals() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(studyGoalService.getActiveGoals(userId));
    }

    @Operation(summary = "获取目标详情")
    @GetMapping("/{id}")
    public Result<StudyGoal> getGoalDetail(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(studyGoalService.getGoalById(id, userId));
    }

    @Operation(summary = "领取目标奖励")
    @PostMapping("/{id}/claim")
    public Result<Map<String, Object>> claimReward(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(studyGoalService.claimReward(id, userId));
    }

    @Operation(summary = "取消目标")
    @PostMapping("/{id}/cancel")
    public Result<Void> cancelGoal(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        studyGoalService.cancelGoal(id, userId);
        return Result.success();
    }

    @Operation(summary = "获取目标统计")
    @GetMapping("/stats")
    public Result<Map<String, Object>> getStats() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(studyGoalService.getGoalStats(userId));
    }

    // ==================== 请求DTO ====================

    @Data
    public static class CreateGoalRequest {
        private String name;
        private String type;
        private BigDecimal targetValue;
        private String unit;
        private LocalDate startDate;
        private LocalDate endDate;
        private String description;
        private Integer rewardPoints;
        private Integer rewardExp;
    }
}
