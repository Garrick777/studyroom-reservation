package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 消息实体
 */
@Data
@TableName("message")
public class Message {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 接收用户ID
     */
    private Long userId;

    /**
     * 标题
     */
    private String title;

    /**
     * 内容
     */
    private String content;

    /**
     * 类型
     */
    private String type;

    /**
     * 关联类型
     */
    private String relatedType;

    /**
     * 关联ID
     */
    private Long relatedId;

    /**
     * 是否已读
     */
    private Integer isRead;

    /**
     * 阅读时间
     */
    private LocalDateTime readTime;

    @TableField("created_at")
    private LocalDateTime createdAt;

    // ========== 类型常量 ==========

    public static final String TYPE_SYSTEM = "SYSTEM";               // 系统消息
    public static final String TYPE_RESERVATION = "RESERVATION";     // 预约消息
    public static final String TYPE_VIOLATION = "VIOLATION";         // 违约消息
    public static final String TYPE_ACHIEVEMENT = "ACHIEVEMENT";     // 成就消息
    public static final String TYPE_FRIEND = "FRIEND";               // 好友消息
    public static final String TYPE_GROUP = "GROUP";                 // 小组消息
    public static final String TYPE_NOTICE = "NOTICE";               // 公告

    // ========== 关联类型常量 ==========

    public static final String RELATED_RESERVATION = "RESERVATION";
    public static final String RELATED_ACHIEVEMENT = "ACHIEVEMENT";
    public static final String RELATED_FRIEND = "FRIEND";
    public static final String RELATED_GROUP = "GROUP";

    /**
     * 获取类型名称
     */
    public static String getTypeName(String type) {
        return switch (type) {
            case TYPE_SYSTEM -> "系统消息";
            case TYPE_RESERVATION -> "预约消息";
            case TYPE_VIOLATION -> "违约消息";
            case TYPE_ACHIEVEMENT -> "成就消息";
            case TYPE_FRIEND -> "好友消息";
            case TYPE_GROUP -> "小组消息";
            case TYPE_NOTICE -> "公告";
            default -> "消息";
        };
    }

    /**
     * 创建消息
     */
    public static Message create(Long userId, String type, String title, String content) {
        Message msg = new Message();
        msg.setUserId(userId);
        msg.setType(type);
        msg.setTitle(title);
        msg.setContent(content);
        msg.setIsRead(0);
        msg.setCreatedAt(LocalDateTime.now());
        return msg;
    }

    /**
     * 创建带关联的消息
     */
    public static Message createWithRelation(Long userId, String type, String title, String content,
                                              String relatedType, Long relatedId) {
        Message msg = create(userId, type, title, content);
        msg.setRelatedType(relatedType);
        msg.setRelatedId(relatedId);
        return msg;
    }

    /**
     * 标记已读
     */
    public void markAsRead() {
        this.isRead = 1;
        this.readTime = LocalDateTime.now();
    }

    /**
     * 类型统计结果
     */
    @Data
    public static class TypeCount {
        private String type;
        private Integer count;
    }
}
