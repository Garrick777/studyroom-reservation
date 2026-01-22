package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 时段实体类
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("time_slot")
public class TimeSlot implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 时段名称
     */
    private String name;

    /**
     * 开始时间
     */
    @JsonFormat(pattern = "HH:mm")
    private LocalTime startTime;

    /**
     * 结束时间
     */
    @JsonFormat(pattern = "HH:mm")
    private LocalTime endTime;

    /**
     * 时长(分钟)
     */
    private Integer duration;

    /**
     * 排序
     */
    private Integer sortOrder;

    /**
     * 状态: 0禁用 1启用
     */
    private Integer status;

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

    // ========== 非数据库字段 ==========

    /**
     * 是否可预约 (根据当前时间判断)
     */
    @TableField(exist = false)
    private Boolean available;

    /**
     * 该时段剩余座位数 (实时计算)
     */
    @TableField(exist = false)
    private Integer availableSeats;
}
