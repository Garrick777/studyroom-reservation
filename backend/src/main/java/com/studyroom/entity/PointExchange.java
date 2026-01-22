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
 * 积分兑换记录实体类
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("point_exchange")
public class PointExchange implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 兑换单号
     */
    private String exchangeNo;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 商品ID
     */
    private Long productId;

    /**
     * 商品名称(冗余)
     */
    private String productName;

    /**
     * 商品图片(冗余)
     */
    private String productImage;

    /**
     * 消耗积分
     */
    private Integer pointsCost;

    /**
     * 兑换数量
     */
    private Integer quantity;

    /**
     * 状态: PENDING待处理 PROCESSING处理中 COMPLETED已完成 CANCELLED已取消
     */
    private String status;

    /**
     * 收货人姓名(实物商品)
     */
    private String receiverName;

    /**
     * 收货人电话
     */
    private String receiverPhone;

    /**
     * 收货地址
     */
    private String receiverAddress;

    /**
     * 物流单号
     */
    private String trackingNo;

    /**
     * 兑换码(虚拟商品)
     */
    private String redeemCode;

    /**
     * 备注
     */
    private String remark;

    /**
     * 处理时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime processTime;

    /**
     * 完成时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime completeTime;

    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    // ========== 非数据库字段 ==========
    
    @TableField(exist = false)
    private User user;

    @TableField(exist = false)
    private PointProduct product;

    // ========== 状态枚举 ==========
    
    public enum Status {
        PENDING("待处理"),
        PROCESSING("处理中"),
        COMPLETED("已完成"),
        CANCELLED("已取消");

        private final String description;

        Status(String description) {
            this.description = description;
        }

        public String getDescription() {
            return description;
        }
    }

    /**
     * 生成兑换单号
     */
    public static String generateExchangeNo() {
        return "EX" + System.currentTimeMillis() + String.format("%04d", (int)(Math.random() * 10000));
    }

    /**
     * 创建兑换记录
     */
    public static PointExchange create(Long userId, PointProduct product, int quantity) {
        return PointExchange.builder()
                .exchangeNo(generateExchangeNo())
                .userId(userId)
                .productId(product.getId())
                .productName(product.getName())
                .productImage(product.getImage())
                .pointsCost(product.getPointsCost() * quantity)
                .quantity(quantity)
                .status(Status.PENDING.name())
                .build();
    }
}
