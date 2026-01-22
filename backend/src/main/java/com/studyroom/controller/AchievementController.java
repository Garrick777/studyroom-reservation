package com.studyroom.controller;

import com.studyroom.common.Result;
import com.studyroom.entity.Achievement;
import com.studyroom.entity.UserAchievement;
import com.studyroom.service.AchievementService;
import com.studyroom.security.SecurityUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 成就控制器
 */
@Tag(name = "成就系统", description = "成就相关接口")
@RestController
@RequestMapping("/achievements")
@RequiredArgsConstructor
public class AchievementController {

    private final AchievementService achievementService;

    @Operation(summary = "获取所有成就列表")
    @GetMapping
    public Result<Map<String, Object>> getAllAchievements(
            @Parameter(description = "分类") @RequestParam(required = false) String category,
            @Parameter(description = "稀有度") @RequestParam(required = false) String rarity) {
        Long userId = SecurityUtil.getCurrentUserId();
        List<Achievement> achievements = achievementService.getAllAchievements(userId, category, rarity);
        
        // 按分类分组
        Map<String, List<Achievement>> grouped = new LinkedHashMap<>();
        grouped.put("STUDY", new ArrayList<>());
        grouped.put("CHECK_IN", new ArrayList<>());
        grouped.put("SOCIAL", new ArrayList<>());
        grouped.put("SPECIAL", new ArrayList<>());
        
        for (Achievement a : achievements) {
            String cat = a.getCategory();
            if (grouped.containsKey(cat)) {
                grouped.get(cat).add(a);
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", achievements);
        result.put("total", achievements.size());
        result.put("grouped", grouped);
        
        return Result.success(result);
    }

    @Operation(summary = "获取用户成就统计")
    @GetMapping("/stats")
    public Result<Map<String, Object>> getAchievementStats() {
        Long userId = SecurityUtil.getCurrentUserId();
        Map<String, Object> stats = achievementService.getUserAchievementStats(userId);
        return Result.success(stats);
    }

    @Operation(summary = "获取我的成就列表")
    @GetMapping("/my")
    public Result<Map<String, Object>> getMyAchievements() {
        Long userId = SecurityUtil.getCurrentUserId();
        
        List<UserAchievement> userAchievements = achievementService.getUserAchievements(userId);
        Map<String, Object> stats = achievementService.getUserAchievementStats(userId);
        
        // 分组：已完成、进行中
        List<UserAchievement> completed = new ArrayList<>();
        List<UserAchievement> inProgress = new ArrayList<>();
        List<UserAchievement> unclaimed = new ArrayList<>();
        
        for (UserAchievement ua : userAchievements) {
            if (ua.getIsCompleted() == 1) {
                completed.add(ua);
                if (ua.getIsClaimed() == 0) {
                    unclaimed.add(ua);
                }
            } else {
                inProgress.add(ua);
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("achievements", userAchievements);
        result.put("completed", completed);
        result.put("inProgress", inProgress);
        result.put("unclaimed", unclaimed);
        result.put("stats", stats);
        
        return Result.success(result);
    }

    @Operation(summary = "获取待领取奖励的成就")
    @GetMapping("/unclaimed")
    public Result<List<UserAchievement>> getUnclaimedAchievements() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<UserAchievement> unclaimed = achievementService.getUnclaimedAchievements(userId);
        return Result.success(unclaimed);
    }

    @Operation(summary = "领取成就奖励")
    @PostMapping("/{id}/claim")
    public Result<Map<String, Object>> claimReward(
            @Parameter(description = "成就ID") @PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        Map<String, Object> reward = achievementService.claimReward(userId, id);
        return Result.success(reward);
    }

    @Operation(summary = "初始化我的成就进度")
    @PostMapping("/init")
    public Result<Void> initMyAchievements() {
        Long userId = SecurityUtil.getCurrentUserId();
        achievementService.initUserAchievements(userId);
        return Result.success();
    }

    @Operation(summary = "获取成就详情")
    @GetMapping("/{id}")
    public Result<Achievement> getAchievementDetail(
            @Parameter(description = "成就ID") @PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        Achievement achievement = achievementService.getAchievementById(id);
        if (achievement == null) {
            return Result.error(404, "成就不存在");
        }
        
        // 获取用户进度
        List<Achievement> withProgress = achievementService.getAllAchievements(userId, null, null);
        for (Achievement a : withProgress) {
            if (a.getId().equals(id)) {
                achievement.setUserProgress(a.getUserProgress());
                break;
            }
        }
        
        return Result.success(achievement);
    }
}
