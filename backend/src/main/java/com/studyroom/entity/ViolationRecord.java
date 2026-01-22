package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 违约记录实体
 */
@Data
@TableName("violation_record")
public class ViolationRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 关联预约ID
     */
    private Long reservationId;

    /**
     * 违约类型
     * NO_SIGN_IN - 未签到
     * LATE_CANCEL - 迟取消(1小时内)
     * LEAVE_TIMEOUT - 暂离超时
     * EARLY_LEAVE - 提前离开未签退
     */
    private String type;

    /**
     * 违约描述
     */
    private String description;

    /**
     * 扣除积分(正数)
     */
    private Integer deductScore;

    /**
     * 扣除前积分
     */
    private Integer beforeScore;

    /**
     * 扣除后积分
     */
    private Integer afterScore;

    /**
     * 申诉状态: 0-未申诉 1-申诉中 2-申诉通过 3-申诉驳回
     */
    private Integer appealStatus;

    /**
     * 申诉理由
     */
    private String appealReason;

    /**
     * 申诉时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime appealTime;

    /**
     * 申诉结果说明
     */
    private String appealResult;

    /**
     * 处理人ID
     */
    private Long processedBy;

    /**
     * 处理时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime processedTime;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    // ========== 非数据库字段 ==========

    /**
     * 用户信息
     */
    @TableField(exist = false)
    private User user;

    /**
     * 预约信息
     */
    @TableField(exist = false)
    private Reservation reservation;

    /**
     * 处理人信息
     */
    @TableField(exist = false)
    private User processor;

    // ========== 常量定义 ==========

    /**
     * 违约类型常量
     */
    public static final String TYPE_NO_SIGN_IN = "NO_SIGN_IN";       // 未签到 -10
    public static final String TYPE_LATE_CANCEL = "LATE_CANCEL";     // 迟取消 -5
    public static final String TYPE_LEAVE_TIMEOUT = "LEAVE_TIMEOUT"; // 暂离超时 -8
    public static final String TYPE_EARLY_LEAVE = "EARLY_LEAVE";     // 提前离开 -3

    /**
     * 申诉状态常量
     */
    public static final int APPEAL_NONE = 0;       // 未申诉
    public static final int APPEAL_PENDING = 1;    // 申诉中
    public static final int APPEAL_APPROVED = 2;   // 申诉通过
    public static final int APPEAL_REJECTED = 3;   // 申诉驳回

    /**
     * 获取违约类型对应的扣分
     */
    public static int getDeductScore(String type) {
        return switch (type) {
            case TYPE_NO_SIGN_IN -> 10;
            case TYPE_LATE_CANCEL -> 5;
            case TYPE_LEAVE_TIMEOUT -> 8;
            case TYPE_EARLY_LEAVE -> 3;
            default -> 0;
        };
    }

    /**
     * 获取违约类型描述
     */
    public static String getTypeDescription(String type) {
        return switch (type) {
            case TYPE_NO_SIGN_IN -> "预约未签到";
            case TYPE_LATE_CANCEL -> "临时取消预约（1小时内）";
            case TYPE_LEAVE_TIMEOUT -> "暂离超时未返回";
            case TYPE_EARLY_LEAVE -> "提前离开未签退";
            default -> "未知违约";
        };
    }
}
