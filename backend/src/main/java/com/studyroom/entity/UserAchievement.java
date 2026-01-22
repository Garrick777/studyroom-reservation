package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 用户成就实体
 */
@Data
@TableName("user_achievement")
public class UserAchievement {

    /**
     * 记录ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 成就ID
     */
    private Long achievementId;

    /**
     * 当前进度
     */
    private Integer progress;

    /**
     * 是否完成
     */
    private Integer isCompleted;

    /**
     * 完成时间
     */
    private LocalDateTime completedAt;

    /**
     * 是否已领取奖励
     */
    private Integer isClaimed;

    /**
     * 领取时间
     */
    private LocalDateTime claimedAt;

    /**
     * 创建时间
     */
    @TableField("created_at")
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField("updated_at")
    private LocalDateTime updatedAt;

    // ========== 非数据库字段 ==========

    /**
     * 成就信息
     */
    @TableField(exist = false)
    private Achievement achievement;

    /**
     * 用户信息
     */
    @TableField(exist = false)
    private User user;

    // ========== 工厂方法 ==========

    /**
     * 创建新的用户成就进度记录
     */
    public static UserAchievement create(Long userId, Long achievementId) {
        UserAchievement ua = new UserAchievement();
        ua.setUserId(userId);
        ua.setAchievementId(achievementId);
        ua.setProgress(0);
        ua.setIsCompleted(0);
        ua.setIsClaimed(0);
        ua.setCreatedAt(LocalDateTime.now());
        ua.setUpdatedAt(LocalDateTime.now());
        return ua;
    }

    /**
     * 更新进度
     */
    public void updateProgress(int newProgress, int targetValue) {
        this.progress = newProgress;
        this.updatedAt = LocalDateTime.now();
        
        // 检查是否完成
        if (newProgress >= targetValue && this.isCompleted == 0) {
            this.isCompleted = 1;
            this.completedAt = LocalDateTime.now();
        }
    }

    /**
     * 领取奖励
     */
    public void claimReward() {
        this.isClaimed = 1;
        this.claimedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * 是否可领取奖励
     */
    public boolean canClaim() {
        return this.isCompleted == 1 && this.isClaimed == 0;
    }

    /**
     * 计算完成进度百分比
     */
    public int getProgressPercent(int targetValue) {
        if (targetValue <= 0) return 0;
        int percent = (int) ((double) this.progress / targetValue * 100);
        return Math.min(percent, 100);
    }
}
