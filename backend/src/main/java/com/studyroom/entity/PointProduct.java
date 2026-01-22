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
 * 积分商品实体类
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("point_product")
public class PointProduct implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 商品名称
     */
    private String name;

    /**
     * 商品描述
     */
    private String description;

    /**
     * 商品图片
     */
    private String image;

    /**
     * 商品分类: VIRTUAL虚拟商品 PHYSICAL实物商品 COUPON优惠券
     */
    private String category;

    /**
     * 所需积分
     */
    private Integer pointsCost;

    /**
     * 库存数量 (-1表示无限)
     */
    private Integer stock;

    /**
     * 已兑换数量
     */
    private Integer exchangedCount;

    /**
     * 每人限兑数量 (0表示不限)
     */
    private Integer limitPerUser;

    /**
     * 商品状态: 0下架 1上架
     */
    private Integer status;

    /**
     * 排序权重
     */
    private Integer sortOrder;

    /**
     * 生效开始时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;

    /**
     * 生效结束时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    @TableLogic
    private Integer deleted;

    // ========== 分类枚举 ==========
    
    public enum Category {
        VIRTUAL("虚拟商品"),
        PHYSICAL("实物商品"),
        COUPON("优惠券");

        private final String description;

        Category(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    /**
     * 检查是否可兑换
     */
    public boolean isAvailable() {
        if (status != 1) return false;
        if (stock != -1 && stock <= 0) return false;
        LocalDateTime now = LocalDateTime.now();
        if (startTime != null && now.isBefore(startTime)) return false;
        if (endTime != null && now.isAfter(endTime)) return false;
        return true;
    }
}
