package com.studyroom.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.common.ResultCode;
import com.studyroom.entity.Message;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.MessageMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 消息服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MessageService {

    private final MessageMapper messageMapper;

    /**
     * 发送消息
     */
    public void sendMessage(Long userId, String type, String title, String content) {
        Message msg = Message.create(userId, type, title, content);
        messageMapper.insert(msg);
        log.debug("发送消息给用户{}: {}", userId, title);
    }

    /**
     * 发送带关联的消息
     */
    public void sendMessageWithRelation(Long userId, String type, String title, String content,
                                         String relatedType, Long relatedId) {
        Message msg = Message.createWithRelation(userId, type, title, content, relatedType, relatedId);
        messageMapper.insert(msg);
        log.debug("发送消息给用户{}: {} (关联: {}:{})", userId, title, relatedType, relatedId);
    }

    /**
     * 获取用户消息列表（分页）
     */
    public IPage<Message> getUserMessages(Long userId, int page, int size, String type, Integer isRead) {
        Page<Message> pageParam = new Page<>(page, size);
        return messageMapper.selectUserMessages(pageParam, userId, type, isRead);
    }

    /**
     * 获取用户最近消息
     */
    public List<Message> getRecentMessages(Long userId, int limit) {
        return messageMapper.selectRecentMessages(userId, limit);
    }

    /**
     * 标记消息已读
     */
    @Transactional
    public void markAsRead(Long userId, Long messageId) {
        Message message = messageMapper.selectById(messageId);
        if (message == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "消息不存在");
        }

        if (!message.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权操作此消息");
        }

        if (message.getIsRead() == 0) {
            message.markAsRead();
            messageMapper.updateById(message);
        }
    }

    /**
     * 标记所有消息已读
     */
    @Transactional
    public int markAllRead(Long userId) {
        return messageMapper.markAllRead(userId);
    }

    /**
     * 标记指定类型消息已读
     */
    @Transactional
    public int markTypeRead(Long userId, String type) {
        return messageMapper.markTypeRead(userId, type);
    }

    /**
     * 获取未读消息数量
     */
    public int getUnreadCount(Long userId) {
        return messageMapper.countUnread(userId);
    }

    /**
     * 按类型统计未读消息
     */
    public Map<String, Integer> getUnreadCountByType(Long userId) {
        List<Message.TypeCount> counts = messageMapper.countUnreadByType(userId);
        Map<String, Integer> result = new HashMap<>();
        
        // 初始化所有类型为0
        result.put(Message.TYPE_SYSTEM, 0);
        result.put(Message.TYPE_RESERVATION, 0);
        result.put(Message.TYPE_VIOLATION, 0);
        result.put(Message.TYPE_ACHIEVEMENT, 0);
        result.put(Message.TYPE_FRIEND, 0);
        result.put(Message.TYPE_GROUP, 0);
        result.put(Message.TYPE_NOTICE, 0);
        
        // 填充实际数量
        for (Message.TypeCount tc : counts) {
            result.put(tc.getType(), tc.getCount());
        }
        
        return result;
    }

    /**
     * 删除消息
     */
    @Transactional
    public void deleteMessage(Long userId, Long messageId) {
        Message message = messageMapper.selectById(messageId);
        if (message == null) {
            return; // 消息不存在，静默处理
        }

        if (!message.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权操作此消息");
        }

        messageMapper.deleteById(messageId);
    }

    /**
     * 获取消息详情
     */
    public Message getMessageDetail(Long userId, Long messageId) {
        Message message = messageMapper.selectById(messageId);
        if (message == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "消息不存在");
        }

        if (!message.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权查看此消息");
        }

        // 自动标记已读
        if (message.getIsRead() == 0) {
            message.markAsRead();
            messageMapper.updateById(message);
        }

        return message;
    }

    // ========== 系统消息发送方法 ==========

    /**
     * 发送系统公告
     */
    public void sendSystemNotice(Long userId, String title, String content) {
        sendMessage(userId, Message.TYPE_NOTICE, title, content);
    }

    /**
     * 发送预约相关消息
     */
    public void sendReservationMessage(Long userId, String title, String content, Long reservationId) {
        sendMessageWithRelation(userId, Message.TYPE_RESERVATION, title, content, 
                Message.RELATED_RESERVATION, reservationId);
    }

    /**
     * 发送违约相关消息
     */
    public void sendViolationMessage(Long userId, String title, String content) {
        sendMessage(userId, Message.TYPE_VIOLATION, title, content);
    }

    /**
     * 发送成就相关消息
     */
    public void sendAchievementMessage(Long userId, String title, String content, Long achievementId) {
        sendMessageWithRelation(userId, Message.TYPE_ACHIEVEMENT, title, content,
                Message.RELATED_ACHIEVEMENT, achievementId);
    }

    /**
     * 发送好友相关消息
     */
    public void sendFriendMessage(Long userId, String title, String content, Long friendshipId) {
        sendMessageWithRelation(userId, Message.TYPE_FRIEND, title, content,
                Message.RELATED_FRIEND, friendshipId);
    }

    /**
     * 发送小组相关消息
     */
    public void sendGroupMessage(Long userId, String title, String content, Long groupId) {
        sendMessageWithRelation(userId, Message.TYPE_GROUP, title, content,
                Message.RELATED_GROUP, groupId);
    }

    /**
     * 批量发送消息
     */
    public void sendBatchMessages(List<Long> userIds, String type, String title, String content) {
        for (Long userId : userIds) {
            sendMessage(userId, type, title, content);
        }
        log.info("批量发送消息给{}位用户: {}", userIds.size(), title);
    }

    /**
     * 获取消息统计
     */
    public Map<String, Object> getMessageStats(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("unreadCount", getUnreadCount(userId));
        stats.put("unreadByType", getUnreadCountByType(userId));
        return stats;
    }
}
