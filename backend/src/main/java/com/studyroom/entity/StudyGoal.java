package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 学习目标实体
 */
@Data
@TableName("study_goal")
public class StudyGoal implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 目标名称
     */
    private String name;

    /**
     * 目标类型: DAILY_HOURS-每日学习时长, WEEKLY_HOURS-每周学习时长, 
     * MONTHLY_HOURS-每月学习时长, TOTAL_HOURS-累计学习时长,
     * DAILY_CHECKIN-连续打卡天数, RESERVATION_COUNT-预约次数
     */
    private String type;

    /**
     * 目标值(如: 4小时, 7天)
     */
    private BigDecimal targetValue;

    /**
     * 当前进度值
     */
    private BigDecimal currentValue;

    /**
     * 单位: HOUR/DAY/COUNT
     */
    private String unit;

    /**
     * 开始日期
     */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate startDate;

    /**
     * 结束日期
     */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate endDate;

    /**
     * 状态: ACTIVE-进行中, COMPLETED-已完成, FAILED-未完成, CANCELLED-已取消
     */
    private String status;

    /**
     * 完成时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime completedTime;

    /**
     * 完成奖励积分
     */
    private Integer rewardPoints;

    /**
     * 完成奖励经验
     */
    private Integer rewardExp;

    /**
     * 是否已领取奖励
     */
    private Integer rewardClaimed;

    /**
     * 描述
     */
    private String description;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;

    // ========== 非数据库字段 ==========

    @TableField(exist = false)
    private User user;

    /**
     * 进度百分比
     */
    @TableField(exist = false)
    private Integer progressPercent;

    /**
     * 剩余天数
     */
    @TableField(exist = false)
    private Integer remainingDays;

    // ========== 常量定义 ==========

    // 目标类型
    public static final String TYPE_DAILY_HOURS = "DAILY_HOURS";         // 每日学习时长
    public static final String TYPE_WEEKLY_HOURS = "WEEKLY_HOURS";       // 每周学习时长
    public static final String TYPE_MONTHLY_HOURS = "MONTHLY_HOURS";     // 每月学习时长
    public static final String TYPE_TOTAL_HOURS = "TOTAL_HOURS";         // 累计学习时长
    public static final String TYPE_DAILY_CHECKIN = "DAILY_CHECKIN";     // 连续打卡天数
    public static final String TYPE_RESERVATION_COUNT = "RESERVATION_COUNT"; // 预约次数

    // 单位
    public static final String UNIT_HOUR = "HOUR";
    public static final String UNIT_DAY = "DAY";
    public static final String UNIT_COUNT = "COUNT";

    // 状态
    public static final String STATUS_ACTIVE = "ACTIVE";       // 进行中
    public static final String STATUS_COMPLETED = "COMPLETED"; // 已完成
    public static final String STATUS_FAILED = "FAILED";       // 未完成
    public static final String STATUS_CANCELLED = "CANCELLED"; // 已取消

    /**
     * 计算进度百分比
     */
    public int calculateProgress() {
        if (targetValue == null || targetValue.compareTo(BigDecimal.ZERO) == 0) {
            return 0;
        }
        if (currentValue == null) {
            return 0;
        }
        int percent = currentValue.multiply(BigDecimal.valueOf(100))
                .divide(targetValue, 0, BigDecimal.ROUND_DOWN)
                .intValue();
        return Math.min(percent, 100);
    }

    /**
     * 计算剩余天数
     */
    public int calculateRemainingDays() {
        if (endDate == null) {
            return -1; // 无限期
        }
        LocalDate today = LocalDate.now();
        if (today.isAfter(endDate)) {
            return 0;
        }
        return (int) java.time.temporal.ChronoUnit.DAYS.between(today, endDate);
    }

    /**
     * 是否已完成
     */
    public boolean isCompleted() {
        return currentValue != null && targetValue != null 
                && currentValue.compareTo(targetValue) >= 0;
    }

    /**
     * 是否已过期
     */
    public boolean isExpired() {
        return endDate != null && LocalDate.now().isAfter(endDate);
    }

    /**
     * 获取目标类型描述
     */
    public static String getTypeDescription(String type) {
        return switch (type) {
            case TYPE_DAILY_HOURS -> "每日学习时长";
            case TYPE_WEEKLY_HOURS -> "每周学习时长";
            case TYPE_MONTHLY_HOURS -> "每月学习时长";
            case TYPE_TOTAL_HOURS -> "累计学习时长";
            case TYPE_DAILY_CHECKIN -> "连续打卡天数";
            case TYPE_RESERVATION_COUNT -> "预约次数";
            default -> "学习目标";
        };
    }
}
