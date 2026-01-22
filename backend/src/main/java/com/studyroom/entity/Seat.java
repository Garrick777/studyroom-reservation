package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 座位实体类
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("seat")
public class Seat implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 自习室ID
     */
    private Long roomId;

    /**
     * 座位编号
     */
    private String seatNo;

    /**
     * 行号(从1开始)
     */
    private Integer rowNum;

    /**
     * 列号(从1开始)
     */
    private Integer colNum;

    /**
     * 座位类型: NORMAL普通 WINDOW靠窗 POWER带电源 VIP贵宾
     */
    private String seatType;

    /**
     * 状态: 0不可用 1可用 2维修中
     */
    private Integer status;

    /**
     * 备注
     */
    private String remark;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /**
     * 逻辑删除
     */
    @TableLogic
    private Integer deleted;

    // ========== 非数据库字段 ==========

    /**
     * 当前使用状态 (实时计算)
     * AVAILABLE-空闲 RESERVED-已预约 IN_USE-使用中 LEAVING-暂离
     */
    @TableField(exist = false)
    private String currentStatus;

    /**
     * 当前预约信息
     */
    @TableField(exist = false)
    private Object currentReservation;

    /**
     * 自习室名称
     */
    @TableField(exist = false)
    private String roomName;

    /**
     * 座位类型枚举
     */
    public enum SeatType {
        NORMAL("普通座位"),
        WINDOW("靠窗座位"),
        POWER("带电源座位"),
        VIP("VIP座位");

        private final String description;

        SeatType(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    /**
     * 座位状态枚举
     */
    public enum SeatStatus {
        UNAVAILABLE(0, "不可用"),
        AVAILABLE(1, "可用"),
        MAINTENANCE(2, "维修中");

        private final int code;
        private final String description;

        SeatStatus(int code, String description) {
            this.code = code;
            this.description = description;
        }

        public int getCode() {
            return code;
        }

        public String getDescription() {
            return description;
        }
    }

    /**
     * 实时使用状态枚举
     */
    public enum UseStatus {
        AVAILABLE("空闲"),
        RESERVED("已预约"),
        IN_USE("使用中"),
        LEAVING("暂离");

        private final String description;

        UseStatus(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }
}
