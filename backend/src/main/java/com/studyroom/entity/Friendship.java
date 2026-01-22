package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 好友关系实体
 */
@Data
@TableName("friendship")
public class Friendship {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID（发起方）
     */
    private Long userId;

    /**
     * 好友ID（接收方）
     */
    private Long friendId;

    /**
     * 状态: 0待确认 1已确认 2已拒绝 3已删除
     */
    private Integer status;

    /**
     * 备注名
     */
    private String remark;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;

    // ========== 非数据库字段 ==========

    /**
     * 用户信息
     */
    @TableField(exist = false)
    private User user;

    /**
     * 好友信息
     */
    @TableField(exist = false)
    private User friend;

    // ========== 状态常量 ==========

    public static final int STATUS_PENDING = 0;      // 待确认
    public static final int STATUS_ACCEPTED = 1;     // 已确认
    public static final int STATUS_REJECTED = 2;     // 已拒绝
    public static final int STATUS_DELETED = 3;      // 已删除

    /**
     * 获取状态描述
     */
    public static String getStatusName(int status) {
        return switch (status) {
            case STATUS_PENDING -> "待确认";
            case STATUS_ACCEPTED -> "已确认";
            case STATUS_REJECTED -> "已拒绝";
            case STATUS_DELETED -> "已删除";
            default -> "未知";
        };
    }

    /**
     * 创建好友请求
     */
    public static Friendship createRequest(Long userId, Long friendId) {
        Friendship f = new Friendship();
        f.setUserId(userId);
        f.setFriendId(friendId);
        f.setStatus(STATUS_PENDING);
        f.setCreatedAt(LocalDateTime.now());
        f.setUpdatedAt(LocalDateTime.now());
        return f;
    }

    /**
     * 接受请求
     */
    public void accept() {
        this.status = STATUS_ACCEPTED;
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * 拒绝请求
     */
    public void reject() {
        this.status = STATUS_REJECTED;
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * 删除好友
     */
    public void remove() {
        this.status = STATUS_DELETED;
        this.updatedAt = LocalDateTime.now();
    }
}
