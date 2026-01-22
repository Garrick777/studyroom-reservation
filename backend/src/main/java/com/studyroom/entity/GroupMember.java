package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 小组成员实体
 */
@Data
@TableName("group_member")
public class GroupMember {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 小组ID
     */
    private Long groupId;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 角色: CREATOR创建者/ADMIN管理员/MEMBER成员
     */
    private String role;

    /**
     * 小组内昵称
     */
    private String nickname;

    /**
     * 贡献时长
     */
    private BigDecimal contributionHours;

    /**
     * 加入时间
     */
    private LocalDateTime joinTime;

    /**
     * 状态: 0待审批 1正常 2已退出
     */
    private Integer status;

    @TableField("created_at")
    private LocalDateTime createdAt;

    // ========== 非数据库字段 ==========

    /**
     * 用户信息
     */
    @TableField(exist = false)
    private User user;

    /**
     * 小组信息
     */
    @TableField(exist = false)
    private StudyGroup group;

    // ========== 角色常量 ==========

    public static final String ROLE_CREATOR = "CREATOR";   // 创建者
    public static final String ROLE_ADMIN = "ADMIN";       // 管理员
    public static final String ROLE_MEMBER = "MEMBER";     // 普通成员

    // ========== 状态常量 ==========

    public static final int STATUS_PENDING = 0;    // 待审批
    public static final int STATUS_ACTIVE = 1;     // 正常
    public static final int STATUS_LEFT = 2;       // 已退出

    /**
     * 获取角色名称
     */
    public static String getRoleName(String role) {
        return switch (role) {
            case ROLE_CREATOR -> "创建者";
            case ROLE_ADMIN -> "管理员";
            case ROLE_MEMBER -> "成员";
            default -> "成员";
        };
    }

    /**
     * 创建创建者成员记录
     */
    public static GroupMember createCreator(Long groupId, Long userId) {
        GroupMember member = new GroupMember();
        member.setGroupId(groupId);
        member.setUserId(userId);
        member.setRole(ROLE_CREATOR);
        member.setContributionHours(BigDecimal.ZERO);
        member.setJoinTime(LocalDateTime.now());
        member.setStatus(STATUS_ACTIVE);
        member.setCreatedAt(LocalDateTime.now());
        return member;
    }

    /**
     * 创建普通成员记录
     */
    public static GroupMember createMember(Long groupId, Long userId, boolean needApprove) {
        GroupMember member = new GroupMember();
        member.setGroupId(groupId);
        member.setUserId(userId);
        member.setRole(ROLE_MEMBER);
        member.setContributionHours(BigDecimal.ZERO);
        member.setJoinTime(LocalDateTime.now());
        member.setStatus(needApprove ? STATUS_PENDING : STATUS_ACTIVE);
        member.setCreatedAt(LocalDateTime.now());
        return member;
    }

    /**
     * 是否为管理员（创建者或管理员）
     */
    public boolean isAdmin() {
        return ROLE_CREATOR.equals(this.role) || ROLE_ADMIN.equals(this.role);
    }

    /**
     * 批准加入
     */
    public void approve() {
        this.status = STATUS_ACTIVE;
        this.joinTime = LocalDateTime.now();
    }

    /**
     * 退出小组
     */
    public void leave() {
        this.status = STATUS_LEFT;
    }
}
