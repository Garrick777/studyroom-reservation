package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 预约实体类
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("reservation")
public class Reservation implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private String reservationNo;
    private Long userId;
    private Long roomId;
    private Long seatId;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;

    private Long timeSlotId;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;

    private String status;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime signInTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime signOutTime;

    private Integer actualDuration;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime leaveTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime returnTime;

    private Integer leaveCount;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime cancelTime;

    private String cancelReason;
    private String violationType;
    private Integer earnedPoints;
    private Integer earnedExp;
    private String remark;
    private String source;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;

    // 非数据库字段
    @TableField(exist = false)
    private User user;

    @TableField(exist = false)
    private StudyRoom room;

    @TableField(exist = false)
    private Seat seat;

    @TableField(exist = false)
    private TimeSlot timeSlot;

    @TableField(exist = false)
    private String userName;

    @TableField(exist = false)
    private String roomName;

    @TableField(exist = false)
    private String seatNo;

    @TableField(exist = false)
    private String timeSlotName;

    // 预约状态枚举
    public enum Status {
        PENDING("待签到"),
        SIGNED_IN("已签到/使用中"),
        LEAVING("暂离"),
        COMPLETED("已完成"),
        CANCELLED("已取消"),
        NO_SHOW("未签到/爽约"),
        VIOLATION("违约");

        private final String description;

        Status(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    // 预约来源枚举
    public enum Source {
        WEB("网页端"), APP("手机APP"), WECHAT("微信小程序");

        private final String description;

        Source(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    // 违约类型枚举
    public enum ViolationType {
        NO_SHOW("未签到"), LEAVE_TIMEOUT("暂离超时"), EARLY_LEAVE("提前离开"), LATE_CANCEL("迟取消");

        private final String description;

        ViolationType(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    // 生成预约编号
    public static String generateReservationNo() {
        String datePart = java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd"));
        String randomPart = String.format("%06d", (int)(Math.random() * 1000000));
        return "RS" + datePart + randomPart;
    }
}
