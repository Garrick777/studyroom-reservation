package com.studyroom.controller;

import com.studyroom.common.Result;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.FriendService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 好友Controller
 */
@Tag(name = "好友管理", description = "好友相关接口")
@RestController
@RequestMapping("/friends")
@RequiredArgsConstructor
public class FriendController {

    private final FriendService friendService;

    @Operation(summary = "获取好友列表")
    @GetMapping("/list")
    public Result<List<Map<String, Object>>> getFriendList() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(friendService.getFriendList(userId));
    }

    @Operation(summary = "发送好友请求")
    @PostMapping("/request")
    public Result<Void> sendFriendRequest(@RequestBody Map<String, Object> params) {
        Long userId = SecurityUtil.getCurrentUserId();
        Long friendId = Long.valueOf(params.get("friendId").toString());
        String remark = params.get("remark") != null ? params.get("remark").toString() : null;
        friendService.sendFriendRequest(userId, friendId, remark);
        return Result.success();
    }

    @Operation(summary = "接受好友请求")
    @PostMapping("/accept/{requestId}")
    public Result<Void> acceptFriendRequest(@PathVariable Long requestId) {
        Long userId = SecurityUtil.getCurrentUserId();
        friendService.acceptFriendRequest(userId, requestId);
        return Result.success();
    }

    @Operation(summary = "拒绝好友请求")
    @PostMapping("/reject/{requestId}")
    public Result<Void> rejectFriendRequest(@PathVariable Long requestId) {
        Long userId = SecurityUtil.getCurrentUserId();
        friendService.rejectFriendRequest(userId, requestId);
        return Result.success();
    }

    @Operation(summary = "删除好友")
    @DeleteMapping("/{friendId}")
    public Result<Void> deleteFriend(@PathVariable Long friendId) {
        Long userId = SecurityUtil.getCurrentUserId();
        friendService.deleteFriend(userId, friendId);
        return Result.success();
    }

    @Operation(summary = "获取收到的好友请求")
    @GetMapping("/requests/received")
    public Result<List<Map<String, Object>>> getReceivedRequests() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(friendService.getReceivedRequests(userId));
    }

    @Operation(summary = "获取发出的好友请求")
    @GetMapping("/requests/sent")
    public Result<List<Map<String, Object>>> getSentRequests() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(friendService.getSentRequests(userId));
    }

    @Operation(summary = "搜索用户")
    @GetMapping("/search")
    public Result<List<Map<String, Object>>> searchUsers(@RequestParam String keyword) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(friendService.searchUsers(userId, keyword));
    }

    @Operation(summary = "更新好友备注")
    @PutMapping("/{friendId}/remark")
    public Result<Void> updateRemark(@PathVariable Long friendId, @RequestBody Map<String, String> params) {
        Long userId = SecurityUtil.getCurrentUserId();
        String remark = params.get("remark");
        friendService.updateRemark(userId, friendId, remark);
        return Result.success();
    }

    @Operation(summary = "获取待处理请求数量")
    @GetMapping("/requests/pending/count")
    public Result<Integer> getPendingRequestCount() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(friendService.getPendingRequestCount(userId));
    }

    @Operation(summary = "获取好友数量")
    @GetMapping("/count")
    public Result<Integer> getFriendCount() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(friendService.getFriendCount(userId));
    }

    @Operation(summary = "检查是否为好友")
    @GetMapping("/check/{targetId}")
    public Result<Boolean> checkIsFriend(@PathVariable Long targetId) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(friendService.isFriend(userId, targetId));
    }
}
