package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 黑名单实体
 */
@Data
@TableName("blacklist")
public class Blacklist {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 原因
     */
    private String reason;

    /**
     * 加入时信用分
     */
    private Integer creditScoreWhenAdded;

    /**
     * 开始时间
     */
    private LocalDateTime startTime;

    /**
     * 结束时间(永久为null)
     */
    private LocalDateTime endTime;

    /**
     * 是否已解除: 0-否 1-是
     */
    private Integer released;

    /**
     * 解除时间
     */
    private LocalDateTime releaseTime;

    /**
     * 解除原因
     */
    private String releaseReason;

    /**
     * 操作人ID
     */
    private Long createdBy;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    // ========== 非数据库字段 ==========

    /**
     * 用户信息
     */
    @TableField(exist = false)
    private User user;

    /**
     * 操作人信息
     */
    @TableField(exist = false)
    private User operator;

    // ========== 常量定义 ==========

    public static final int RELEASED_NO = 0;   // 未解除
    public static final int RELEASED_YES = 1;  // 已解除

    /**
     * 默认黑名单时长(天)
     */
    public static final int DEFAULT_DURATION_DAYS = 7;

    /**
     * 触发黑名单的信用分阈值
     */
    public static final int TRIGGER_SCORE_THRESHOLD = 60;

    /**
     * 创建自动黑名单
     */
    public static Blacklist createAuto(Long userId, Integer creditScore) {
        Blacklist blacklist = new Blacklist();
        blacklist.setUserId(userId);
        blacklist.setReason("信用积分低于" + TRIGGER_SCORE_THRESHOLD + "分，自动加入黑名单");
        blacklist.setCreditScoreWhenAdded(creditScore);
        blacklist.setStartTime(LocalDateTime.now());
        blacklist.setEndTime(LocalDateTime.now().plusDays(DEFAULT_DURATION_DAYS));
        blacklist.setReleased(RELEASED_NO);
        return blacklist;
    }

    /**
     * 创建手动黑名单
     */
    public static Blacklist createManual(Long userId, String reason, Integer durationDays, Long operatorId) {
        Blacklist blacklist = new Blacklist();
        blacklist.setUserId(userId);
        blacklist.setReason(reason);
        blacklist.setStartTime(LocalDateTime.now());
        if (durationDays != null && durationDays > 0) {
            blacklist.setEndTime(LocalDateTime.now().plusDays(durationDays));
        }
        blacklist.setCreatedBy(operatorId);
        blacklist.setReleased(RELEASED_NO);
        return blacklist;
    }

    /**
     * 是否已过期
     */
    public boolean isExpired() {
        return endTime != null && LocalDateTime.now().isAfter(endTime);
    }

    /**
     * 是否在有效期内
     */
    public boolean isActive() {
        return released == RELEASED_NO && (endTime == null || !isExpired());
    }
}
