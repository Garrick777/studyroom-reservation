package com.studyroom.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.common.Result;
import com.studyroom.entity.Achievement;
import com.studyroom.service.AchievementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 管理端成就控制器
 */
@Tag(name = "管理端-成就管理", description = "成就管理相关接口")
@RestController
@RequestMapping("/manage/achievements")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
public class AdminAchievementController {

    private final AchievementService achievementService;

    @Operation(summary = "获取成就列表（分页）")
    @GetMapping
    public Result<Map<String, Object>> getAchievements(
            @Parameter(description = "页码") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "每页数量") @RequestParam(defaultValue = "20") int size,
            @Parameter(description = "分类") @RequestParam(required = false) String category,
            @Parameter(description = "稀有度") @RequestParam(required = false) String rarity,
            @Parameter(description = "关键词") @RequestParam(required = false) String keyword) {
        
        Page<Achievement> pageResult = achievementService.getAchievementPage(page, size, category, rarity, keyword);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", pageResult.getRecords());
        result.put("total", pageResult.getTotal());
        result.put("pages", pageResult.getPages());
        result.put("current", pageResult.getCurrent());
        
        return Result.success(result);
    }

    @Operation(summary = "获取成就详情")
    @GetMapping("/{id}")
    public Result<Achievement> getAchievementDetail(
            @Parameter(description = "成就ID") @PathVariable Long id) {
        Achievement achievement = achievementService.getAchievementById(id);
        if (achievement == null) {
            return Result.error(404, "成就不存在");
        }
        return Result.success(achievement);
    }

    @Operation(summary = "创建成就")
    @PostMapping
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public Result<Achievement> createAchievement(@RequestBody Achievement achievement) {
        Achievement created = achievementService.createAchievement(achievement);
        return Result.success(created);
    }

    @Operation(summary = "更新成就")
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public Result<Achievement> updateAchievement(
            @Parameter(description = "成就ID") @PathVariable Long id,
            @RequestBody Achievement achievement) {
        achievement.setId(id);
        Achievement updated = achievementService.updateAchievement(achievement);
        return Result.success(updated);
    }

    @Operation(summary = "删除成就")
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public Result<Void> deleteAchievement(
            @Parameter(description = "成就ID") @PathVariable Long id) {
        achievementService.deleteAchievement(id);
        return Result.success();
    }

    @Operation(summary = "切换成就状态")
    @PostMapping("/{id}/toggle")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public Result<Void> toggleStatus(
            @Parameter(description = "成就ID") @PathVariable Long id) {
        achievementService.toggleStatus(id);
        return Result.success();
    }

    @Operation(summary = "获取成就分类列表")
    @GetMapping("/categories")
    public Result<Map<String, String>> getCategories() {
        Map<String, String> categories = new HashMap<>();
        categories.put("STUDY", "学习成就");
        categories.put("CHECK_IN", "打卡成就");
        categories.put("SOCIAL", "社交成就");
        categories.put("SPECIAL", "特殊成就");
        return Result.success(categories);
    }

    @Operation(summary = "获取成就稀有度列表")
    @GetMapping("/rarities")
    public Result<Map<String, String>> getRarities() {
        Map<String, String> rarities = new HashMap<>();
        rarities.put("COMMON", "普通");
        rarities.put("RARE", "稀有");
        rarities.put("EPIC", "史诗");
        rarities.put("LEGENDARY", "传说");
        return Result.success(rarities);
    }

    @Operation(summary = "获取条件类型列表")
    @GetMapping("/condition-types")
    public Result<Map<String, String>> getConditionTypes() {
        Map<String, String> types = new HashMap<>();
        types.put("TOTAL_RESERVATIONS", "累计预约次数");
        types.put("TOTAL_HOURS", "累计学习时长");
        types.put("TOTAL_CHECK_INS", "累计打卡次数");
        types.put("CONTINUOUS_CHECK_INS", "连续打卡天数");
        types.put("TOTAL_FRIENDS", "好友数量");
        types.put("CREATE_GROUP", "创建小组");
        types.put("EARLY_SIGN_IN", "早起签到次数");
        types.put("LATE_SIGN_OUT", "晚间签退次数");
        types.put("NO_VIOLATION_STREAK", "连续无违约次数");
        types.put("WEEKEND_STUDY", "周末学习次数");
        types.put("GOALS_COMPLETED", "完成目标数");
        types.put("TOTAL_REVIEWS", "评价数量");
        return Result.success(types);
    }
}
