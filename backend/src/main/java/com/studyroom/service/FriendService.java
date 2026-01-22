package com.studyroom.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.studyroom.common.ResultCode;
import com.studyroom.entity.Friendship;
import com.studyroom.entity.Message;
import com.studyroom.entity.User;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.FriendshipMapper;
import com.studyroom.mapper.MessageMapper;
import com.studyroom.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 好友服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FriendService {

    private final FriendshipMapper friendshipMapper;
    private final UserMapper userMapper;
    private final MessageMapper messageMapper;

    /**
     * 获取好友列表
     */
    public List<Map<String, Object>> getFriendList(Long userId) {
        // 查找已确认的好友关系（双向）
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .eq(Friendship::getUserId, userId)
                .or()
                .eq(Friendship::getFriendId, userId))
                .eq(Friendship::getStatus, Friendship.STATUS_ACCEPTED);
        
        List<Friendship> friendships = friendshipMapper.selectList(wrapper);
        
        // 获取好友ID列表
        Set<Long> friendIds = new HashSet<>();
        Map<Long, String> remarkMap = new HashMap<>();
        Map<Long, LocalDateTime> addTimeMap = new HashMap<>();
        
        for (Friendship f : friendships) {
            Long friendId = f.getUserId().equals(userId) ? f.getFriendId() : f.getUserId();
            friendIds.add(friendId);
            if (f.getUserId().equals(userId) && f.getRemark() != null) {
                remarkMap.put(friendId, f.getRemark());
            }
            addTimeMap.put(friendId, f.getCreatedAt());
        }
        
        if (friendIds.isEmpty()) {
            return Collections.emptyList();
        }
        
        // 查询好友用户信息
        List<User> friends = userMapper.selectBatchIds(friendIds);
        
        // 组装结果
        return friends.stream().map(friend -> {
            Map<String, Object> map = new HashMap<>();
            map.put("userId", friend.getId());
            map.put("username", friend.getUsername());
            map.put("nickname", friend.getRealName());
            map.put("avatar", friend.getAvatar());
            map.put("studentNo", friend.getStudentId());
            map.put("remark", remarkMap.get(friend.getId()));
            map.put("addTime", addTimeMap.get(friend.getId()));
            // 可以添加在线状态等信息
            return map;
        }).collect(Collectors.toList());
    }

    /**
     * 发送好友请求
     */
    @Transactional
    public void sendFriendRequest(Long userId, Long friendId, String remark) {
        if (userId.equals(friendId)) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "不能添加自己为好友");
        }

        // 检查好友是否存在
        User friend = userMapper.selectById(friendId);
        if (friend == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }

        // 检查是否已经是好友
        if (isFriend(userId, friendId)) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "已经是好友了");
        }

        // 检查是否已有待处理的请求
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Friendship::getUserId, userId)
                .eq(Friendship::getFriendId, friendId)
                .eq(Friendship::getStatus, Friendship.STATUS_PENDING);
        
        if (friendshipMapper.selectCount(wrapper) > 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "已发送过好友请求，请等待对方确认");
        }

        // 检查对方是否已经向我发送请求
        LambdaQueryWrapper<Friendship> reverseWrapper = new LambdaQueryWrapper<>();
        reverseWrapper.eq(Friendship::getUserId, friendId)
                .eq(Friendship::getFriendId, userId)
                .eq(Friendship::getStatus, Friendship.STATUS_PENDING);
        
        Friendship reverse = friendshipMapper.selectOne(reverseWrapper);
        if (reverse != null) {
            // 直接接受对方的请求
            acceptFriendRequest(userId, reverse.getId());
            return;
        }

        // 创建好友请求
        Friendship friendship = Friendship.createRequest(userId, friendId);
        friendship.setRemark(remark);
        friendshipMapper.insert(friendship);

        // 发送通知消息
        User currentUser = userMapper.selectById(userId);
        Message msg = Message.createWithRelation(
                friendId,
                Message.TYPE_FRIEND,
                "新的好友请求",
                String.format("%s 请求添加你为好友", currentUser.getRealName() != null ? currentUser.getRealName() : currentUser.getUsername()),
                Message.RELATED_FRIEND,
                friendship.getId()
        );
        messageMapper.insert(msg);

        log.info("用户{}向{}发送好友请求", userId, friendId);
    }

    /**
     * 接受好友请求
     */
    @Transactional
    public void acceptFriendRequest(Long userId, Long friendshipId) {
        Friendship friendship = friendshipMapper.selectById(friendshipId);
        if (friendship == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "好友请求不存在");
        }

        if (!friendship.getFriendId().equals(userId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权操作此请求");
        }

        if (friendship.getStatus() != Friendship.STATUS_PENDING) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "请求已处理");
        }

        // 更新状态
        friendship.accept();
        friendshipMapper.updateById(friendship);

        // 发送通知给请求方
        User currentUser = userMapper.selectById(userId);
        Message msg = Message.createWithRelation(
                friendship.getUserId(),
                Message.TYPE_FRIEND,
                "好友请求已通过",
                String.format("%s 已接受你的好友请求", currentUser.getRealName() != null ? currentUser.getRealName() : currentUser.getUsername()),
                Message.RELATED_FRIEND,
                friendshipId
        );
        messageMapper.insert(msg);

        log.info("用户{}接受了{}的好友请求", userId, friendship.getUserId());
    }

    /**
     * 拒绝好友请求
     */
    @Transactional
    public void rejectFriendRequest(Long userId, Long friendshipId) {
        Friendship friendship = friendshipMapper.selectById(friendshipId);
        if (friendship == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "好友请求不存在");
        }

        if (!friendship.getFriendId().equals(userId)) {
            throw new BusinessException(ResultCode.FORBIDDEN, "无权操作此请求");
        }

        if (friendship.getStatus() != Friendship.STATUS_PENDING) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "请求已处理");
        }

        // 更新状态
        friendship.reject();
        friendshipMapper.updateById(friendship);

        log.info("用户{}拒绝了{}的好友请求", userId, friendship.getUserId());
    }

    /**
     * 删除好友
     */
    @Transactional
    public void deleteFriend(Long userId, Long friendId) {
        // 查找好友关系
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .and(inner -> inner.eq(Friendship::getUserId, userId).eq(Friendship::getFriendId, friendId))
                .or()
                .and(inner -> inner.eq(Friendship::getUserId, friendId).eq(Friendship::getFriendId, userId)))
                .eq(Friendship::getStatus, Friendship.STATUS_ACCEPTED);
        
        Friendship friendship = friendshipMapper.selectOne(wrapper);
        if (friendship == null) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "好友关系不存在");
        }

        // 标记为删除
        friendship.remove();
        friendshipMapper.updateById(friendship);

        log.info("用户{}删除了好友{}", userId, friendId);
    }

    /**
     * 获取收到的好友请求列表
     */
    public List<Map<String, Object>> getReceivedRequests(Long userId) {
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Friendship::getFriendId, userId)
                .eq(Friendship::getStatus, Friendship.STATUS_PENDING)
                .orderByDesc(Friendship::getCreatedAt);
        
        List<Friendship> requests = friendshipMapper.selectList(wrapper);
        
        if (requests.isEmpty()) {
            return Collections.emptyList();
        }

        // 获取请求者信息
        Set<Long> requestUserIds = requests.stream()
                .map(Friendship::getUserId)
                .collect(Collectors.toSet());
        
        Map<Long, User> userMap = userMapper.selectBatchIds(requestUserIds).stream()
                .collect(Collectors.toMap(User::getId, u -> u));

        return requests.stream().map(req -> {
            Map<String, Object> map = new HashMap<>();
            map.put("requestId", req.getId());
            User requester = userMap.get(req.getUserId());
            if (requester != null) {
                map.put("userId", requester.getId());
                map.put("username", requester.getUsername());
                map.put("nickname", requester.getRealName());
                map.put("avatar", requester.getAvatar());
                map.put("studentNo", requester.getStudentId());
            }
            map.put("requestTime", req.getCreatedAt());
            return map;
        }).collect(Collectors.toList());
    }

    /**
     * 获取发出的好友请求列表
     */
    public List<Map<String, Object>> getSentRequests(Long userId) {
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Friendship::getUserId, userId)
                .eq(Friendship::getStatus, Friendship.STATUS_PENDING)
                .orderByDesc(Friendship::getCreatedAt);
        
        List<Friendship> requests = friendshipMapper.selectList(wrapper);
        
        if (requests.isEmpty()) {
            return Collections.emptyList();
        }

        // 获取目标用户信息
        Set<Long> targetUserIds = requests.stream()
                .map(Friendship::getFriendId)
                .collect(Collectors.toSet());
        
        Map<Long, User> userMap = userMapper.selectBatchIds(targetUserIds).stream()
                .collect(Collectors.toMap(User::getId, u -> u));

        return requests.stream().map(req -> {
            Map<String, Object> map = new HashMap<>();
            map.put("requestId", req.getId());
            User target = userMap.get(req.getFriendId());
            if (target != null) {
                map.put("userId", target.getId());
                map.put("username", target.getUsername());
                map.put("nickname", target.getRealName());
                map.put("avatar", target.getAvatar());
            }
            map.put("requestTime", req.getCreatedAt());
            return map;
        }).collect(Collectors.toList());
    }

    /**
     * 搜索用户（用于添加好友）
     */
    public List<Map<String, Object>> searchUsers(Long currentUserId, String keyword) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .like(User::getUsername, keyword)
                .or()
                .like(User::getRealName, keyword)
                .or()
                .like(User::getStudentId, keyword))
                .ne(User::getId, currentUserId)
                .eq(User::getStatus, 1);
        
        List<User> users = userMapper.selectList(wrapper);
        
        // 获取好友状态
        return users.stream().map(user -> {
            Map<String, Object> map = new HashMap<>();
            map.put("userId", user.getId());
            map.put("username", user.getUsername());
            map.put("nickname", user.getRealName());
            map.put("avatar", user.getAvatar());
            map.put("studentNo", user.getStudentId());
            
            // 添加好友状态
            String friendStatus = getFriendStatus(currentUserId, user.getId());
            map.put("friendStatus", friendStatus);
            
            return map;
        }).collect(Collectors.toList());
    }

    /**
     * 获取好友状态
     */
    private String getFriendStatus(Long userId, Long targetId) {
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .and(inner -> inner.eq(Friendship::getUserId, userId).eq(Friendship::getFriendId, targetId))
                .or()
                .and(inner -> inner.eq(Friendship::getUserId, targetId).eq(Friendship::getFriendId, userId)));
        
        Friendship friendship = friendshipMapper.selectOne(wrapper);
        
        if (friendship == null) {
            return "none"; // 无关系
        }
        
        switch (friendship.getStatus()) {
            case Friendship.STATUS_ACCEPTED:
                return "friend"; // 已是好友
            case Friendship.STATUS_PENDING:
                if (friendship.getUserId().equals(userId)) {
                    return "sent"; // 我发送的请求待处理
                } else {
                    return "received"; // 收到的请求待处理
                }
            case Friendship.STATUS_REJECTED:
                return "rejected"; // 被拒绝
            default:
                return "none";
        }
    }

    /**
     * 判断是否为好友
     */
    public boolean isFriend(Long userId, Long friendId) {
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .and(inner -> inner.eq(Friendship::getUserId, userId).eq(Friendship::getFriendId, friendId))
                .or()
                .and(inner -> inner.eq(Friendship::getUserId, friendId).eq(Friendship::getFriendId, userId)))
                .eq(Friendship::getStatus, Friendship.STATUS_ACCEPTED);
        
        return friendshipMapper.selectCount(wrapper) > 0;
    }

    /**
     * 获取好友数量
     */
    public int getFriendCount(Long userId) {
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .eq(Friendship::getUserId, userId)
                .or()
                .eq(Friendship::getFriendId, userId))
                .eq(Friendship::getStatus, Friendship.STATUS_ACCEPTED);
        
        return friendshipMapper.selectCount(wrapper).intValue();
    }

    /**
     * 更新好友备注
     */
    @Transactional
    public void updateRemark(Long userId, Long friendId, String remark) {
        // 查找我发起的好友关系
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Friendship::getUserId, userId)
                .eq(Friendship::getFriendId, friendId)
                .eq(Friendship::getStatus, Friendship.STATUS_ACCEPTED);
        
        Friendship friendship = friendshipMapper.selectOne(wrapper);
        
        if (friendship == null) {
            // 可能是对方发起的好友关系，创建一条我方的记录用于存储备注
            LambdaQueryWrapper<Friendship> reverseWrapper = new LambdaQueryWrapper<>();
            reverseWrapper.eq(Friendship::getUserId, friendId)
                    .eq(Friendship::getFriendId, userId)
                    .eq(Friendship::getStatus, Friendship.STATUS_ACCEPTED);
            
            Friendship reverseFriendship = friendshipMapper.selectOne(reverseWrapper);
            if (reverseFriendship == null) {
                throw new BusinessException(ResultCode.BAD_REQUEST, "好友关系不存在");
            }
            
            // 创建我方的好友关系记录
            friendship = Friendship.createRequest(userId, friendId);
            friendship.setStatus(Friendship.STATUS_ACCEPTED);
            friendship.setRemark(remark);
            friendshipMapper.insert(friendship);
        } else {
            friendship.setRemark(remark);
            friendshipMapper.updateById(friendship);
        }

        log.info("用户{}更新好友{}备注为: {}", userId, friendId, remark);
    }

    /**
     * 获取待处理请求数量
     */
    public int getPendingRequestCount(Long userId) {
        LambdaQueryWrapper<Friendship> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Friendship::getFriendId, userId)
                .eq(Friendship::getStatus, Friendship.STATUS_PENDING);
        
        return friendshipMapper.selectCount(wrapper).intValue();
    }
}
