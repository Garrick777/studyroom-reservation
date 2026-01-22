package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 信用积分记录实体
 */
@Data
@TableName("credit_record")
public class CreditRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 变动积分(正为加，负为减)
     */
    private Integer changeScore;

    /**
     * 变动前积分
     */
    private Integer beforeScore;

    /**
     * 变动后积分
     */
    private Integer afterScore;

    /**
     * 变动类型
     */
    private String type;

    /**
     * 来源类型
     */
    private String sourceType;

    /**
     * 来源ID
     */
    private Long sourceId;

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

    // ========== 非数据库字段 ==========

    /**
     * 用户信息
     */
    @TableField(exist = false)
    private User user;

    // ========== 常量定义 ==========

    /**
     * 变动类型 - 增加
     */
    public static final String TYPE_COMPLETE_RESERVATION = "COMPLETE_RESERVATION";  // 完成预约 +2
    public static final String TYPE_MONTHLY_RECOVER = "MONTHLY_RECOVER";            // 月度恢复 +5
    public static final String TYPE_APPEAL_APPROVED = "APPEAL_APPROVED";            // 申诉通过
    public static final String TYPE_ADMIN_ADJUST = "ADMIN_ADJUST";                  // 管理员调整
    public static final String TYPE_CONTINUOUS_CHECKIN = "CONTINUOUS_CHECKIN";      // 连续打卡奖励
    public static final String TYPE_ACHIEVEMENT = "ACHIEVEMENT";                     // 成就奖励

    /**
     * 变动类型 - 减少
     */
    public static final String TYPE_NO_SIGN_IN = "NO_SIGN_IN";          // 未签到 -10
    public static final String TYPE_LATE_CANCEL = "LATE_CANCEL";        // 迟取消 -5
    public static final String TYPE_LEAVE_TIMEOUT = "LEAVE_TIMEOUT";    // 暂离超时 -8
    public static final String TYPE_EARLY_LEAVE = "EARLY_LEAVE";        // 提前离开 -3

    /**
     * 来源类型
     */
    public static final String SOURCE_RESERVATION = "RESERVATION";  // 预约
    public static final String SOURCE_VIOLATION = "VIOLATION";      // 违约
    public static final String SOURCE_APPEAL = "APPEAL";            // 申诉
    public static final String SOURCE_SYSTEM = "SYSTEM";            // 系统
    public static final String SOURCE_ADMIN = "ADMIN";              // 管理员
    public static final String SOURCE_CHECKIN = "CHECKIN";          // 打卡
    public static final String SOURCE_ACHIEVEMENT = "ACHIEVEMENT";  // 成就

    /**
     * 获取类型描述
     */
    public static String getTypeDescription(String type) {
        return switch (type) {
            case TYPE_COMPLETE_RESERVATION -> "完成预约";
            case TYPE_MONTHLY_RECOVER -> "月度积分恢复";
            case TYPE_APPEAL_APPROVED -> "申诉通过积分返还";
            case TYPE_ADMIN_ADJUST -> "管理员调整";
            case TYPE_CONTINUOUS_CHECKIN -> "连续打卡奖励";
            case TYPE_ACHIEVEMENT -> "成就奖励";
            case TYPE_NO_SIGN_IN -> "预约未签到扣分";
            case TYPE_LATE_CANCEL -> "临时取消预约扣分";
            case TYPE_LEAVE_TIMEOUT -> "暂离超时扣分";
            case TYPE_EARLY_LEAVE -> "提前离开扣分";
            default -> "积分变动";
        };
    }

    /**
     * 创建记录的工厂方法
     */
    public static CreditRecord create(Long userId, Integer changeScore, Integer beforeScore, 
                                       String type, String sourceType, Long sourceId, String description) {
        CreditRecord record = new CreditRecord();
        record.setUserId(userId);
        record.setChangeScore(changeScore);
        record.setBeforeScore(beforeScore);
        record.setAfterScore(beforeScore + changeScore);
        record.setType(type);
        record.setSourceType(sourceType);
        record.setSourceId(sourceId);
        record.setDescription(description != null ? description : getTypeDescription(type));
        return record;
    }
}
