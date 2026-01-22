package com.studyroom.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.studyroom.common.Result;
import com.studyroom.entity.GroupMember;
import com.studyroom.entity.StudyGroup;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.GroupService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 学习小组Controller
 */
@Tag(name = "学习小组", description = "学习小组相关接口")
@RestController
@RequestMapping("/groups")
@RequiredArgsConstructor
public class GroupController {

    private final GroupService groupService;

    @Operation(summary = "创建小组")
    @PostMapping
    public Result<StudyGroup> createGroup(@RequestBody Map<String, Object> params) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(groupService.createGroup(userId, params));
    }

    @Operation(summary = "获取小组详情")
    @GetMapping("/{groupId}")
    public Result<Map<String, Object>> getGroupDetail(@PathVariable Long groupId) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(groupService.getGroupDetail(groupId, userId));
    }

    @Operation(summary = "获取小组成员列表")
    @GetMapping("/{groupId}/members")
    public Result<List<GroupMember>> getGroupMembers(@PathVariable Long groupId) {
        return Result.success(groupService.getGroupMembers(groupId));
    }

    @Operation(summary = "获取待审批成员列表")
    @GetMapping("/{groupId}/members/pending")
    public Result<List<GroupMember>> getPendingMembers(@PathVariable Long groupId) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(groupService.getPendingMembers(groupId, userId));
    }

    @Operation(summary = "加入小组")
    @PostMapping("/{groupId}/join")
    public Result<Void> joinGroup(@PathVariable Long groupId) {
        Long userId = SecurityUtil.getCurrentUserId();
        groupService.joinGroup(userId, groupId);
        return Result.success();
    }

    @Operation(summary = "审批加入申请")
    @PostMapping("/{groupId}/members/{memberId}/approve")
    public Result<Void> approveJoin(@PathVariable Long groupId,
                                     @PathVariable Long memberId,
                                     @RequestParam boolean approve) {
        Long userId = SecurityUtil.getCurrentUserId();
        groupService.approveJoin(userId, groupId, memberId, approve);
        return Result.success();
    }

    @Operation(summary = "退出小组")
    @PostMapping("/{groupId}/leave")
    public Result<Void> leaveGroup(@PathVariable Long groupId) {
        Long userId = SecurityUtil.getCurrentUserId();
        groupService.leaveGroup(userId, groupId);
        return Result.success();
    }

    @Operation(summary = "移除成员")
    @DeleteMapping("/{groupId}/members/{memberId}")
    public Result<Void> removeMember(@PathVariable Long groupId, @PathVariable Long memberId) {
        Long userId = SecurityUtil.getCurrentUserId();
        groupService.removeMember(userId, groupId, memberId);
        return Result.success();
    }

    @Operation(summary = "设置/取消管理员")
    @PostMapping("/{groupId}/members/{targetUserId}/admin")
    public Result<Void> setAdmin(@PathVariable Long groupId,
                                  @PathVariable Long targetUserId,
                                  @RequestParam boolean isAdmin) {
        Long userId = SecurityUtil.getCurrentUserId();
        groupService.setAdmin(userId, groupId, targetUserId, isAdmin);
        return Result.success();
    }

    @Operation(summary = "解散小组")
    @DeleteMapping("/{groupId}")
    public Result<Void> dissolveGroup(@PathVariable Long groupId) {
        Long userId = SecurityUtil.getCurrentUserId();
        groupService.dissolveGroup(userId, groupId);
        return Result.success();
    }

    @Operation(summary = "更新小组信息")
    @PutMapping("/{groupId}")
    public Result<Void> updateGroup(@PathVariable Long groupId, @RequestBody Map<String, Object> params) {
        Long userId = SecurityUtil.getCurrentUserId();
        groupService.updateGroup(userId, groupId, params);
        return Result.success();
    }

    @Operation(summary = "获取公开小组列表")
    @GetMapping("/public")
    public Result<IPage<StudyGroup>> getPublicGroups(@RequestParam(defaultValue = "1") int page,
                                                      @RequestParam(defaultValue = "10") int size,
                                                      @RequestParam(required = false) String keyword) {
        return Result.success(groupService.getPublicGroups(page, size, keyword));
    }

    @Operation(summary = "获取我加入的小组")
    @GetMapping("/my")
    public Result<List<Map<String, Object>>> getMyGroups() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(groupService.getUserGroups(userId));
    }

    @Operation(summary = "获取我创建的小组")
    @GetMapping("/created")
    public Result<List<StudyGroup>> getCreatedGroups() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(groupService.getCreatedGroups(userId));
    }

    @Operation(summary = "获取待审批数量")
    @GetMapping("/{groupId}/pending/count")
    public Result<Integer> getPendingMemberCount(@PathVariable Long groupId) {
        return Result.success(groupService.getPendingMemberCount(groupId));
    }
}
