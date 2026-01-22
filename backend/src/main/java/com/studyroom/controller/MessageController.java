package com.studyroom.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.studyroom.common.Result;
import com.studyroom.entity.Message;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.MessageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 消息Controller
 */
@Tag(name = "消息中心", description = "消息相关接口")
@RestController
@RequestMapping("/messages")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;

    @Operation(summary = "获取消息列表")
    @GetMapping
    public Result<IPage<Message>> getMessages(@RequestParam(defaultValue = "1") int page,
                                               @RequestParam(defaultValue = "20") int size,
                                               @RequestParam(required = false) String type,
                                               @RequestParam(required = false) Integer isRead) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(messageService.getUserMessages(userId, page, size, type, isRead));
    }

    @Operation(summary = "获取最近消息")
    @GetMapping("/recent")
    public Result<List<Message>> getRecentMessages(@RequestParam(defaultValue = "5") int limit) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(messageService.getRecentMessages(userId, limit));
    }

    @Operation(summary = "获取消息详情")
    @GetMapping("/{messageId}")
    public Result<Message> getMessageDetail(@PathVariable Long messageId) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(messageService.getMessageDetail(userId, messageId));
    }

    @Operation(summary = "标记消息已读")
    @PostMapping("/{messageId}/read")
    public Result<Void> markAsRead(@PathVariable Long messageId) {
        Long userId = SecurityUtil.getCurrentUserId();
        messageService.markAsRead(userId, messageId);
        return Result.success();
    }

    @Operation(summary = "标记所有消息已读")
    @PostMapping("/read-all")
    public Result<Integer> markAllRead() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(messageService.markAllRead(userId));
    }

    @Operation(summary = "标记指定类型消息已读")
    @PostMapping("/read-type")
    public Result<Integer> markTypeRead(@RequestParam String type) {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(messageService.markTypeRead(userId, type));
    }

    @Operation(summary = "获取未读消息数量")
    @GetMapping("/unread/count")
    public Result<Integer> getUnreadCount() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(messageService.getUnreadCount(userId));
    }

    @Operation(summary = "按类型统计未读消息")
    @GetMapping("/unread/by-type")
    public Result<Map<String, Integer>> getUnreadCountByType() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(messageService.getUnreadCountByType(userId));
    }

    @Operation(summary = "删除消息")
    @DeleteMapping("/{messageId}")
    public Result<Void> deleteMessage(@PathVariable Long messageId) {
        Long userId = SecurityUtil.getCurrentUserId();
        messageService.deleteMessage(userId, messageId);
        return Result.success();
    }

    @Operation(summary = "获取消息统计")
    @GetMapping("/stats")
    public Result<Map<String, Object>> getMessageStats() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(messageService.getMessageStats(userId));
    }
}
