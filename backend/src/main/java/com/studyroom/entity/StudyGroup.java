package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 学习小组实体
 */
@Data
@TableName("study_group")
public class StudyGroup {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 小组名称
     */
    private String name;

    /**
     * 小组描述
     */
    private String description;

    /**
     * 小组头像
     */
    private String avatar;

    /**
     * 封面图
     */
    private String coverImage;

    /**
     * 创建者ID
     */
    private Long creatorId;

    /**
     * 最大成员数
     */
    private Integer maxMembers;

    /**
     * 当前成员数
     */
    private Integer memberCount;

    /**
     * 小组总学习时长
     */
    private BigDecimal totalHours;

    /**
     * 本周学习时长
     */
    private BigDecimal weeklyHours;

    /**
     * 是否公开: 0私密 1公开
     */
    private Integer isPublic;

    /**
     * 加入需审批
     */
    private Integer needApprove;

    /**
     * 标签（逗号分隔）
     */
    private String tags;

    /**
     * 状态: 0已解散 1正常
     */
    private Integer status;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;

    // ========== 非数据库字段 ==========

    /**
     * 创建者信息
     */
    @TableField(exist = false)
    private User creator;

    /**
     * 成员列表
     */
    @TableField(exist = false)
    private List<GroupMember> members;

    /**
     * 当前用户的成员信息
     */
    @TableField(exist = false)
    private GroupMember currentMember;

    /**
     * 是否已加入
     */
    @TableField(exist = false)
    private Boolean joined;

    // ========== 状态常量 ==========

    public static final int STATUS_DISBANDED = 0;    // 已解散
    public static final int STATUS_ACTIVE = 1;       // 正常

    /**
     * 创建小组
     */
    public static StudyGroup create(Long creatorId, String name, String description) {
        StudyGroup group = new StudyGroup();
        group.setCreatorId(creatorId);
        group.setName(name);
        group.setDescription(description);
        group.setMaxMembers(50);
        group.setMemberCount(1);
        group.setTotalHours(BigDecimal.ZERO);
        group.setWeeklyHours(BigDecimal.ZERO);
        group.setIsPublic(1);
        group.setNeedApprove(0);
        group.setStatus(STATUS_ACTIVE);
        group.setCreatedAt(LocalDateTime.now());
        group.setUpdatedAt(LocalDateTime.now());
        return group;
    }

    /**
     * 是否可加入
     */
    public boolean canJoin() {
        return this.status == STATUS_ACTIVE && this.memberCount < this.maxMembers;
    }

    /**
     * 增加成员
     */
    public void addMember() {
        this.memberCount = this.memberCount + 1;
        this.updatedAt = LocalDateTime.now();
    }

    /**
     * 减少成员
     */
    public void removeMember() {
        this.memberCount = Math.max(0, this.memberCount - 1);
        this.updatedAt = LocalDateTime.now();
    }
}
