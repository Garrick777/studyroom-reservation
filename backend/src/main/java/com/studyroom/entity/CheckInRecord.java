package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 每日打卡签到记录
 */
@Data
@TableName("check_in_record")
public class CheckInRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 打卡日期
     */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate checkInDate;

    /**
     * 打卡时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime checkInTime;

    /**
     * 打卡类型: DAILY-每日打卡, STUDY_START-开始学习, STUDY_END-结束学习
     */
    private String type;

    /**
     * 获得积分
     */
    private Integer earnedPoints;

    /**
     * 获得经验
     */
    private Integer earnedExp;

    /**
     * 连续打卡天数(打卡时的)
     */
    private Integer continuousDays;

    /**
     * 打卡来源: WEB/APP/WECHAT
     */
    private String source;

    /**
     * 备注
     */
    private String remark;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    // ========== 非数据库字段 ==========

    @TableField(exist = false)
    private User user;

    // ========== 常量定义 ==========

    public static final String TYPE_DAILY = "DAILY";           // 每日打卡
    public static final String TYPE_STUDY_START = "STUDY_START"; // 开始学习
    public static final String TYPE_STUDY_END = "STUDY_END";     // 结束学习

    public static final String SOURCE_WEB = "WEB";
    public static final String SOURCE_APP = "APP";
    public static final String SOURCE_WECHAT = "WECHAT";

    /**
     * 基础打卡奖励
     */
    public static final int BASE_POINTS = 5;
    public static final int BASE_EXP = 10;

    /**
     * 连续打卡额外奖励
     */
    public static int getBonusPoints(int continuousDays) {
        if (continuousDays >= 30) return 20;
        if (continuousDays >= 14) return 10;
        if (continuousDays >= 7) return 5;
        if (continuousDays >= 3) return 2;
        return 0;
    }

    public static int getBonusExp(int continuousDays) {
        if (continuousDays >= 30) return 50;
        if (continuousDays >= 14) return 25;
        if (continuousDays >= 7) return 15;
        if (continuousDays >= 3) return 5;
        return 0;
    }
}
