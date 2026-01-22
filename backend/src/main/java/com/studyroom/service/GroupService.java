package com.studyroom.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.common.ResultCode;
import com.studyroom.entity.GroupMember;
import com.studyroom.entity.Message;
import com.studyroom.entity.StudyGroup;
import com.studyroom.entity.User;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.GroupMemberMapper;
import com.studyroom.mapper.MessageMapper;
import com.studyroom.mapper.StudyGroupMapper;
import com.studyroom.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 学习小组服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GroupService {

    private final StudyGroupMapper studyGroupMapper;
    private final GroupMemberMapper groupMemberMapper;
    private final UserMapper userMapper;
    private final MessageMapper messageMapper;
    private final AchievementService achievementService;

    /**
     * 创建学习小组
     */
    @Transactional
    public StudyGroup createGroup(Long userId, Map<String, Object> params) {
        String name = (String) params.get("name");
        String description = (String) params.get("description");
        String avatar = (String) params.get("avatar");
        String coverImage = (String) params.get("coverImage");
        Integer maxMembers = params.get("maxMembers") != null ? Integer.valueOf(params.get("maxMembers").toString()) : 50;
        Boolean isPublic = params.get("isPublic") != null ? (Boolean) params.get("isPublic") : true;
        Boolean needApprove = params.get("needApprove") != null ? (Boolean) params.get("needApprove") : false;
        String tags = (String) params.get("tags");

        // 创建小组
        StudyGroup group = new StudyGroup();
        group.setName(name);
        group.setDescription(description);
        group.setAvatar(avatar);
        group.setCoverImage(coverImage);
        group.setCreatorId(userId);
        group.setMaxMembers(maxMembers);
        group.setMemberCount(1);
        group.setTotalHours(BigDecimal.ZERO);
        group.setWeeklyHours(BigDecimal.ZERO);
        group.setIsPublic(isPublic ? 1 : 0);
        group.setNeedApprove(needApprove ? 1 : 0);
        group.setTags(tags);
        group.setStatus(1);
        group.setCreatedAt(LocalDateTime.now());
        group.setUpdatedAt(LocalDateTime.now());
        studyGroupMapper.insert(group);

        // 创建创建者成员记录
        GroupMember creator = GroupMember.createCreator(group.getId(), userId);
        groupMemberMapper.insert(creator);

        // 触发成就检查
        try {
            achievementService.triggerCreateGroup(userId);
        } catch (Exception e) {
            log.warn("触发小组成就失败", e);
        }

        log.info("用户{}创建小组: {}", userId, name);
        return group;
    }

    /**
     * 获取小组详情
     */
    public Map<String, Object> getGroupDetail(Long groupId, Long currentUserId) {
        StudyGroup group = studyGroupMapper.selectById(groupId);
        if (group == null || group.getStatus() == 0) {
            throw new BusinessException(ResultCode.NOT_FOUND, "小组不存在或已解散");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", group.getId());
        result.put("name", group.getName());
        result.put("description", group.getDescription());
        result.put("avatar", group.getAvatar());
        result.put("coverImage", group.getCoverImage());
        result.put("creatorId", group.getCreatorId());
        result.put("maxMembers", group.getMaxMembers());
        result.put("memberCount", group.getMemberCount());
        result.put("totalHours", group.getTotalHours());
        result.put("weeklyHours", group.getWeeklyHours());
        result.put("isPublic", group.getIsPublic() == 1);
        result.put("needApprove", group.getNeedApprove() == 1);
        result.put("tags", group.getTags());
        result.put("createdAt", group.getCreatedAt());

        // 获取创建者信息
        User creator = userMapper.selectById(group.getCreatorId());
        if (creator != null) {
            Map<String, Object> creatorInfo = new HashMap<>();
            creatorInfo.put("id", creator.getId());
            creatorInfo.put("username", creator.getUsername());
            creatorInfo.put("nickname", creator.getRealName());
            creatorInfo.put("avatar", creator.getAvatar());
            result.put("creator", creatorInfo);
        }

        // 检查当前用户的成员状态
        if (currentUserId != null) {
            GroupMember member = groupMemberMapper.selectByGroupAndUser(groupId, currentUserId);
            if (member != null) {
                result.put("memberStatus", member.getStatus());
                result.put("memberRole", member.getRole());
                result.put("isAdmin", member.isAdmin());
            } else {
                result.put("memberStatus", -1); // 非成员
                result.put("memberRole", null);
                result.put("isAdmin", false);
            }
        }

        return result;
    }

    /**
     * 获取小组成员列表
     */
    public List<GroupMember> getGroupMembers(Long groupId) {
        return groupMemberMapper.selectMembersWithDetail(groupId);
    }

    /**
     * 获取待审批成员列表
     */
    public List<GroupMember> getPendingMembers(Long groupId, Long currentUserId) {
        // 检查权限
        checkAdminPermission(groupId, currentUserId);
        return groupMemberMapper.selectPendingMembers(groupId);
    }

    /**
     * 加入小组
     */
    @Transactional
    public void joinGroup(Long userId, Long groupId) {
        StudyGroup group = studyGroupMapper.selectById(groupId);
        if (group == null || group.getStatus() == 0) {
            throw new BusinessException(ResultCode.NOT_FOUND, "小组不存在或已解散");
        }

        // 检查是否已是成员
        GroupMember existMember = groupMemberMapper.selectByGroupAndUser(groupId, userId);
        if (existMember != null) {
            if (existMember.getStatus() == GroupMember.STATUS_ACTIVE) {
                throw new BusinessException(ResultCode.BAD_REQUEST, "已经是小组成员");
            } else if (existMember.getStatus() == GroupMember.STATUS_PENDING) {
                throw new BusinessException(ResultCode.BAD_REQUEST, "已提交加入申请，请等待审批");
            }
        }

        // 检查人数限制
        if (group.getMemberCount() >= group.getMaxMembers()) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "小组人数已满");
        }

        // 创建成员记录
        boolean needApprove = group.getNeedApprove() == 1;
        GroupMember member = GroupMember.createMember(groupId, userId, needApprove);
        groupMemberMapper.insert(member);

        if (needApprove) {
            // 发送通知给管理员
            User user = userMapper.selectById(userId);
            sendGroupNotification(group.getCreatorId(), Message.TYPE_GROUP,
                    "新的入组申请",
                    String.format("%s 申请加入小组「%s」", 
                            user.getRealName() != null ? user.getRealName() : user.getUsername(), 
                            group.getName()),
                    groupId);
            log.info("用户{}申请加入小组{}", userId, groupId);
        } else {
            // 直接加入，更新小组人数
            group.setMemberCount(group.getMemberCount() + 1);
            studyGroupMapper.updateById(group);
            log.info("用户{}加入小组{}", userId, groupId);
        }
    }

    /**
     * 审批加入申请
     */
    @Transactional
    public void approveJoin(Long adminId, Long groupId, Long memberId, boolean approve) {
        // 检查权限
        checkAdminPermission(groupId, adminId);

        GroupMember member = groupMemberMapper.selectById(memberId);
        if (member == null || !member.getGroupId().equals(groupId)) {
            throw new BusinessException(ResultCode.NOT_FOUND, "申请记录不存在");
        }

        if (member.getStatus() != GroupMember.STATUS_PENDING) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "申请已处理");
        }

        StudyGroup group = studyGroupMapper.selectById(groupId);
        User user = userMapper.selectById(member.getUserId());

        if (approve) {
            // 检查人数限制
            if (group.getMemberCount() >= group.getMaxMembers()) {
                throw new BusinessException(ResultCode.BAD_REQUEST, "小组人数已满");
            }

            member.approve();
            groupMemberMapper.updateById(member);

            // 更新小组人数
            group.setMemberCount(group.getMemberCount() + 1);
            studyGroupMapper.updateById(group);

            // 通知用户
            sendGroupNotification(member.getUserId(), Message.TYPE_GROUP,
                    "入组申请已通过",
                    String.format("你加入小组「%s」的申请已通过", group.getName()),
                    groupId);

            log.info("管理员{}批准用户{}加入小组{}", adminId, member.getUserId(), groupId);
        } else {
            // 拒绝申请
            member.leave();
            groupMemberMapper.updateById(member);

            // 通知用户
            sendGroupNotification(member.getUserId(), Message.TYPE_GROUP,
                    "入组申请被拒绝",
                    String.format("你加入小组「%s」的申请被拒绝", group.getName()),
                    groupId);

            log.info("管理员{}拒绝用户{}加入小组{}", adminId, member.getUserId(), groupId);
        }
    }

    /**
     * 退出小组
     */
    @Transactional
    public void leaveGroup(Long userId, Long groupId) {
        GroupMember member = groupMemberMapper.selectByGroupAndUser(groupId, userId);
        if (member == null || member.getStatus() != GroupMember.STATUS_ACTIVE) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "你不是该小组成员");
        }

        if (GroupMember.ROLE_CREATOR.equals(member.getRole())) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "创建者不能退出小组，请先转让或解散");
        }

        member.leave();
        groupMemberMapper.updateById(member);

        // 更新小组人数
        StudyGroup group = studyGroupMapper.selectById(groupId);
        group.setMemberCount(group.getMemberCount() - 1);
        studyGroupMapper.updateById(group);

        log.info("用户{}退出小组{}", userId, groupId);
    }

    /**
     * 移除成员
     */
    @Transactional
    public void removeMember(Long adminId, Long groupId, Long memberId) {
        // 检查权限
        checkAdminPermission(groupId, adminId);

        GroupMember member = groupMemberMapper.selectById(memberId);
        if (member == null || !member.getGroupId().equals(groupId)) {
            throw new BusinessException(ResultCode.NOT_FOUND, "成员不存在");
        }

        if (GroupMember.ROLE_CREATOR.equals(member.getRole())) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "不能移除创建者");
        }

        // 管理员不能移除其他管理员
        GroupMember adminMember = groupMemberMapper.selectByGroupAndUser(groupId, adminId);
        if (GroupMember.ROLE_ADMIN.equals(adminMember.getRole()) && GroupMember.ROLE_ADMIN.equals(member.getRole())) {
            throw new BusinessException(ResultCode.FORBIDDEN, "管理员不能移除其他管理员");
        }

        member.leave();
        groupMemberMapper.updateById(member);

        // 更新小组人数
        StudyGroup group = studyGroupMapper.selectById(groupId);
        group.setMemberCount(group.getMemberCount() - 1);
        studyGroupMapper.updateById(group);

        // 通知被移除的用户
        sendGroupNotification(member.getUserId(), Message.TYPE_GROUP,
                "你已被移出小组",
                String.format("你已被移出小组「%s」", group.getName()),
                groupId);

        log.info("管理员{}将用户{}移出小组{}", adminId, member.getUserId(), groupId);
    }

    /**
     * 设置管理员
     */
    @Transactional
    public void setAdmin(Long creatorId, Long groupId, Long userId, boolean isAdmin) {
        // 只有创建者可以设置管理员
        StudyGroup group = studyGroupMapper.selectById(groupId);
        if (group == null || !group.getCreatorId().equals(creatorId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "只有创建者可以设置管理员");
        }

        GroupMember member = groupMemberMapper.selectByGroupAndUser(groupId, userId);
        if (member == null || member.getStatus() != GroupMember.STATUS_ACTIVE) {
            throw new BusinessException(ResultCode.NOT_FOUND, "成员不存在");
        }

        if (GroupMember.ROLE_CREATOR.equals(member.getRole())) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "不能修改创建者角色");
        }

        member.setRole(isAdmin ? GroupMember.ROLE_ADMIN : GroupMember.ROLE_MEMBER);
        groupMemberMapper.updateById(member);

        // 通知用户
        sendGroupNotification(userId, Message.TYPE_GROUP,
                isAdmin ? "你已被设为管理员" : "你的管理员权限已被取消",
                String.format("你在小组「%s」的角色已更新为%s", group.getName(), isAdmin ? "管理员" : "普通成员"),
                groupId);

        log.info("创建者{}将用户{}在小组{}的角色设为{}", creatorId, userId, groupId, isAdmin ? "管理员" : "成员");
    }

    /**
     * 解散小组
     */
    @Transactional
    public void dissolveGroup(Long creatorId, Long groupId) {
        StudyGroup group = studyGroupMapper.selectById(groupId);
        if (group == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "小组不存在");
        }

        if (!group.getCreatorId().equals(creatorId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "只有创建者可以解散小组");
        }

        // 更新小组状态
        group.setStatus(0);
        group.setUpdatedAt(LocalDateTime.now());
        studyGroupMapper.updateById(group);

        // 通知所有成员
        List<GroupMember> members = groupMemberMapper.selectMembersWithDetail(groupId);
        for (GroupMember member : members) {
            if (!member.getUserId().equals(creatorId)) {
                sendGroupNotification(member.getUserId(), Message.TYPE_GROUP,
                        "小组已解散",
                        String.format("小组「%s」已被创建者解散", group.getName()),
                        groupId);
            }
        }

        log.info("创建者{}解散了小组{}", creatorId, groupId);
    }

    /**
     * 转让小组
     */
    @Transactional
    public void transferGroup(Long creatorId, Long groupId, Long newCreatorId) {
        StudyGroup group = studyGroupMapper.selectById(groupId);
        if (group == null || group.getStatus() == 0) {
            throw new BusinessException(ResultCode.NOT_FOUND, "小组不存在或已解散");
        }

        if (!group.getCreatorId().equals(creatorId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "只有创建者可以转让小组");
        }

        if (creatorId.equals(newCreatorId)) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "不能转让给自己");
        }

        // 检查新创建者是否是小组成员
        GroupMember newCreatorMember = groupMemberMapper.selectByGroupAndUser(groupId, newCreatorId);
        if (newCreatorMember == null || newCreatorMember.getStatus() != GroupMember.STATUS_ACTIVE) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "目标用户不是小组成员");
        }

        // 更新小组创建者
        group.setCreatorId(newCreatorId);
        group.setUpdatedAt(LocalDateTime.now());
        studyGroupMapper.updateById(group);

        // 更新原创建者角色为普通成员
        GroupMember oldCreatorMember = groupMemberMapper.selectByGroupAndUser(groupId, creatorId);
        if (oldCreatorMember != null) {
            oldCreatorMember.setRole(GroupMember.ROLE_ADMIN); // 原创建者变为管理员
            groupMemberMapper.updateById(oldCreatorMember);
        }

        // 更新新创建者角色
        newCreatorMember.setRole(GroupMember.ROLE_CREATOR);
        groupMemberMapper.updateById(newCreatorMember);

        // 通知新创建者
        sendGroupNotification(newCreatorId, Message.TYPE_GROUP,
                "小组转让通知",
                String.format("您已成为小组「%s」的新创建者", group.getName()),
                groupId);

        log.info("用户{}将小组{}转让给了用户{}", creatorId, groupId, newCreatorId);
    }

    /**
     * 更新小组信息
     */
    @Transactional
    public void updateGroup(Long adminId, Long groupId, Map<String, Object> params) {
        // 检查权限
        checkAdminPermission(groupId, adminId);

        StudyGroup group = studyGroupMapper.selectById(groupId);
        if (group == null || group.getStatus() == 0) {
            throw new BusinessException(ResultCode.NOT_FOUND, "小组不存在或已解散");
        }

        if (params.containsKey("name")) {
            group.setName((String) params.get("name"));
        }
        if (params.containsKey("description")) {
            group.setDescription((String) params.get("description"));
        }
        if (params.containsKey("avatar")) {
            group.setAvatar((String) params.get("avatar"));
        }
        if (params.containsKey("coverImage")) {
            group.setCoverImage((String) params.get("coverImage"));
        }
        if (params.containsKey("maxMembers")) {
            group.setMaxMembers(Integer.valueOf(params.get("maxMembers").toString()));
        }
        if (params.containsKey("isPublic")) {
            group.setIsPublic((Boolean) params.get("isPublic") ? 1 : 0);
        }
        if (params.containsKey("needApprove")) {
            group.setNeedApprove((Boolean) params.get("needApprove") ? 1 : 0);
        }
        if (params.containsKey("tags")) {
            group.setTags((String) params.get("tags"));
        }

        group.setUpdatedAt(LocalDateTime.now());
        studyGroupMapper.updateById(group);

        log.info("管理员{}更新了小组{}信息", adminId, groupId);
    }

    /**
     * 获取公开小组列表
     */
    public IPage<StudyGroup> getPublicGroups(int page, int size, String keyword) {
        Page<StudyGroup> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<StudyGroup> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StudyGroup::getIsPublic, 1)
                .eq(StudyGroup::getStatus, 1);
        
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w
                    .like(StudyGroup::getName, keyword)
                    .or()
                    .like(StudyGroup::getDescription, keyword)
                    .or()
                    .like(StudyGroup::getTags, keyword));
        }
        
        wrapper.orderByDesc(StudyGroup::getMemberCount);
        return studyGroupMapper.selectPage(pageParam, wrapper);
    }

    /**
     * 获取用户加入的小组
     */
    public List<Map<String, Object>> getUserGroups(Long userId) {
        LambdaQueryWrapper<GroupMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(GroupMember::getUserId, userId)
                .eq(GroupMember::getStatus, GroupMember.STATUS_ACTIVE);
        
        List<GroupMember> memberships = groupMemberMapper.selectList(wrapper);
        
        if (memberships.isEmpty()) {
            return Collections.emptyList();
        }

        Set<Long> groupIds = memberships.stream()
                .map(GroupMember::getGroupId)
                .collect(Collectors.toSet());
        
        Map<Long, GroupMember> memberMap = memberships.stream()
                .collect(Collectors.toMap(GroupMember::getGroupId, m -> m));

        List<StudyGroup> groups = studyGroupMapper.selectBatchIds(groupIds);
        
        return groups.stream()
                .filter(g -> g.getStatus() == 1)
                .map(group -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", group.getId());
                    map.put("name", group.getName());
                    map.put("description", group.getDescription());
                    map.put("avatar", group.getAvatar());
                    map.put("memberCount", group.getMemberCount());
                    map.put("totalHours", group.getTotalHours());
                    map.put("weeklyHours", group.getWeeklyHours());
                    map.put("role", memberMap.get(group.getId()).getRole());
                    map.put("joinTime", memberMap.get(group.getId()).getJoinTime());
                    map.put("contributionHours", memberMap.get(group.getId()).getContributionHours());
                    return map;
                }).collect(Collectors.toList());
    }

    /**
     * 获取用户创建的小组
     */
    public List<StudyGroup> getCreatedGroups(Long userId) {
        LambdaQueryWrapper<StudyGroup> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StudyGroup::getCreatorId, userId)
                .eq(StudyGroup::getStatus, 1)
                .orderByDesc(StudyGroup::getCreatedAt);
        return studyGroupMapper.selectList(wrapper);
    }

    /**
     * 检查管理员权限
     */
    private void checkAdminPermission(Long groupId, Long userId) {
        GroupMember member = groupMemberMapper.selectByGroupAndUser(groupId, userId);
        if (member == null || !member.isAdmin()) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权执行此操作");
        }
    }

    /**
     * 发送小组通知
     */
    private void sendGroupNotification(Long userId, String type, String title, String content, Long groupId) {
        Message msg = Message.createWithRelation(userId, type, title, content, Message.RELATED_GROUP, groupId);
        messageMapper.insert(msg);
    }

    /**
     * 获取小组成员数量
     */
    public int getGroupMemberCount(Long groupId) {
        return groupMemberMapper.countActiveMembers(groupId);
    }

    /**
     * 获取待审批数量
     */
    public int getPendingMemberCount(Long groupId) {
        return groupMemberMapper.countPendingMembers(groupId);
    }
}
