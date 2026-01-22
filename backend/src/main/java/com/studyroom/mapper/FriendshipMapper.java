package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.Friendship;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 好友关系Mapper
 */
@Mapper
public interface FriendshipMapper extends BaseMapper<Friendship> {

    /**
     * 获取好友列表（带用户信息）
     */
    @Select("SELECT f.*, u.id as friend_user_id, u.username, u.nickname, u.avatar, u.student_id " +
            "FROM friendship f " +
            "LEFT JOIN user u ON f.friend_id = u.id " +
            "WHERE f.user_id = #{userId} AND f.status = 1 " +
            "ORDER BY f.updated_at DESC")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "userId", column = "user_id"),
            @Result(property = "friendId", column = "friend_id"),
            @Result(property = "status", column = "status"),
            @Result(property = "remark", column = "remark"),
            @Result(property = "createdAt", column = "created_at"),
            @Result(property = "updatedAt", column = "updated_at"),
            @Result(property = "friend.id", column = "friend_user_id"),
            @Result(property = "friend.username", column = "username"),
            @Result(property = "friend.nickname", column = "nickname"),
            @Result(property = "friend.avatar", column = "avatar"),
            @Result(property = "friend.studentNo", column = "student_id")
    })
    List<Friendship> selectFriendsWithDetail(@Param("userId") Long userId);

    /**
     * 获取待处理的好友请求
     */
    @Select("SELECT f.*, u.id as sender_id, u.username, u.nickname, u.avatar, u.student_id " +
            "FROM friendship f " +
            "LEFT JOIN user u ON f.user_id = u.id " +
            "WHERE f.friend_id = #{userId} AND f.status = 0 " +
            "ORDER BY f.created_at DESC")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "userId", column = "user_id"),
            @Result(property = "friendId", column = "friend_id"),
            @Result(property = "status", column = "status"),
            @Result(property = "createdAt", column = "created_at"),
            @Result(property = "user.id", column = "sender_id"),
            @Result(property = "user.username", column = "username"),
            @Result(property = "user.nickname", column = "nickname"),
            @Result(property = "user.avatar", column = "avatar"),
            @Result(property = "user.studentNo", column = "student_id")
    })
    List<Friendship> selectPendingRequests(@Param("userId") Long userId);

    /**
     * 查找两用户之间的好友关系
     */
    @Select("SELECT * FROM friendship WHERE " +
            "((user_id = #{userId} AND friend_id = #{friendId}) OR " +
            "(user_id = #{friendId} AND friend_id = #{userId})) " +
            "AND status IN (0, 1)")
    Friendship selectByUserPair(@Param("userId") Long userId, @Param("friendId") Long friendId);

    /**
     * 统计好友数量
     */
    @Select("SELECT COUNT(*) FROM friendship WHERE user_id = #{userId} AND status = 1")
    int countFriends(@Param("userId") Long userId);

    /**
     * 统计待处理请求数量
     */
    @Select("SELECT COUNT(*) FROM friendship WHERE friend_id = #{userId} AND status = 0")
    int countPendingRequests(@Param("userId") Long userId);

    /**
     * 搜索用户（排除自己和已是好友的）
     */
    @Select("SELECT u.* FROM user u " +
            "WHERE u.id != #{userId} " +
            "AND u.status = 1 " +
            "AND (u.username LIKE CONCAT('%',#{keyword},'%') " +
            "OR u.nickname LIKE CONCAT('%',#{keyword},'%') " +
            "OR u.student_id LIKE CONCAT('%',#{keyword},'%')) " +
            "AND u.id NOT IN (" +
            "  SELECT friend_id FROM friendship WHERE user_id = #{userId} AND status = 1" +
            ") " +
            "LIMIT 20")
    List<com.studyroom.entity.User> searchUsers(@Param("userId") Long userId, @Param("keyword") String keyword);
}
