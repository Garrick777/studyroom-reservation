package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * 自习室实体类
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName(value = "study_room", autoResultMap = true)
public class StudyRoom implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 自习室名称
     */
    private String name;

    /**
     * 自习室编号
     */
    private String code;

    /**
     * 所在建筑
     */
    private String building;

    /**
     * 楼层
     */
    private String floor;

    /**
     * 房间号
     */
    private String roomNumber;

    /**
     * 座位总数
     */
    private Integer capacity;

    /**
     * 座位行数
     */
    private Integer rowCount;

    /**
     * 座位列数
     */
    private Integer colCount;

    /**
     * 描述信息
     */
    private String description;

    /**
     * 设施列表 (JSON数组)
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> facilities;

    /**
     * 封面图片
     */
    private String coverImage;

    /**
     * 图片集 (JSON数组)
     */
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<String> images;

    /**
     * 开放时间
     */
    @JsonFormat(pattern = "HH:mm")
    private LocalTime openTime;

    /**
     * 关闭时间
     */
    @JsonFormat(pattern = "HH:mm")
    private LocalTime closeTime;

    /**
     * 最大提前预约天数
     */
    private Integer advanceDays;

    /**
     * 单次最大预约时长(小时)
     */
    private Integer maxDuration;

    /**
     * 最低信用分要求
     */
    private Integer minCreditScore;

    /**
     * 是否需要审批
     */
    private Boolean needApprove;

    /**
     * 是否允许临时预约
     */
    private Boolean allowTemp;

    /**
     * 评分
     */
    private BigDecimal rating;

    /**
     * 评分人数
     */
    private Integer ratingCount;

    /**
     * 今日预约数
     */
    private Integer todayReservations;

    /**
     * 总预约数
     */
    private Integer totalReservations;

    /**
     * 管理员ID
     */
    private Long managerId;

    /**
     * 状态: 0关闭 1开放 2维护中
     */
    private Integer status;

    /**
     * 排序
     */
    private Integer sortOrder;

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
     * 可用座位数 (实时计算)
     */
    @TableField(exist = false)
    private Integer availableSeats;

    /**
     * 是否已收藏
     */
    @TableField(exist = false)
    private Boolean isFavorite;

    /**
     * 管理员姓名
     */
    @TableField(exist = false)
    private String managerName;
}
