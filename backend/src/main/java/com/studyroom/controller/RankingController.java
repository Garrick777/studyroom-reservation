package com.studyroom.controller;

import com.studyroom.common.Result;
import com.studyroom.service.RankingService;
import com.studyroom.security.SecurityUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 排行榜控制器
 */
@Tag(name = "排行榜", description = "排行榜相关接口")
@RestController
@RequestMapping("/ranking")
@RequiredArgsConstructor
public class RankingController {

    private final RankingService rankingService;

    @Operation(summary = "获取学习时长排行榜")
    @GetMapping("/study-time")
    public Result<List<Map<String, Object>>> getStudyTimeRanking(
            @RequestParam(defaultValue = "weekly") String period,
            @RequestParam(defaultValue = "20") int limit) {
        return Result.success(rankingService.getStudyTimeRanking(period, limit));
    }

    @Operation(summary = "获取连续打卡排行榜")
    @GetMapping("/checkin-streak")
    public Result<List<Map<String, Object>>> getCheckInStreakRanking(
            @RequestParam(defaultValue = "20") int limit) {
        return Result.success(rankingService.getCheckInStreakRanking(limit));
    }

    @Operation(summary = "获取积分排行榜")
    @GetMapping("/points")
    public Result<List<Map<String, Object>>> getPointsRanking(
            @RequestParam(defaultValue = "20") int limit) {
        return Result.success(rankingService.getPointsRanking(limit));
    }

    @Operation(summary = "获取成就排行榜")
    @GetMapping("/achievement")
    public Result<List<Map<String, Object>>> getAchievementRanking(
            @RequestParam(defaultValue = "20") int limit) {
        return Result.success(rankingService.getAchievementRanking(limit));
    }

    @Operation(summary = "获取我的排名信息")
    @GetMapping("/my-rank")
    public Result<Map<String, Object>> getMyRankInfo(
            @RequestParam(defaultValue = "study_time") String type) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(rankingService.getUserRankInfo(userId, type));
    }

    @Operation(summary = "获取综合排行榜")
    @GetMapping("/overview")
    public Result<Map<String, Object>> getRankingOverview() {
        Map<String, Object> result = new HashMap<>();
        
        // 各类排行榜前5名
        result.put("studyTime", rankingService.getStudyTimeRanking("weekly", 5));
        result.put("checkIn", rankingService.getCheckInStreakRanking(5));
        result.put("points", rankingService.getPointsRanking(5));
        result.put("achievement", rankingService.getAchievementRanking(5));
        
        // 当前用户排名
        Long userId = SecurityUtil.getCurrentUserId();
        if (userId != null) {
            Map<String, Object> myRanks = new HashMap<>();
            myRanks.put("studyTime", rankingService.getUserRankInfo(userId, "study_time"));
            myRanks.put("checkIn", rankingService.getUserRankInfo(userId, "checkin_streak"));
            myRanks.put("points", rankingService.getUserRankInfo(userId, "points"));
            result.put("myRanks", myRanks);
        }
        
        return Result.success(result);
    }

    @Operation(summary = "刷新排行榜缓存(管理端)")
    @PostMapping("/admin/refresh")
    public Result<Void> refreshRankings() {
        rankingService.refreshAllRankings();
        return Result.success();
    }
}
