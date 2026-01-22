package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.studyroom.entity.GroupMember;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 小组成员Mapper
 */
@Mapper
public interface GroupMemberMapper extends BaseMapper<GroupMember> {

    /**
     * 获取小组成员列表（带用户信息）
     */
    @Select("SELECT gm.*, u.id as member_user_id, u.username, u.nickname, u.avatar, u.student_id " +
            "FROM group_member gm " +
            "LEFT JOIN user u ON gm.user_id = u.id " +
            "WHERE gm.group_id = #{groupId} AND gm.status = 1 " +
            "ORDER BY FIELD(gm.role, 'CREATOR', 'ADMIN', 'MEMBER'), gm.join_time")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "groupId", column = "group_id"),
            @Result(property = "userId", column = "user_id"),
            @Result(property = "role", column = "role"),
            @Result(property = "nickname", column = "nickname"),
            @Result(property = "contributionHours", column = "contribution_hours"),
            @Result(property = "joinTime", column = "join_time"),
            @Result(property = "status", column = "status"),
            @Result(property = "user.id", column = "member_user_id"),
            @Result(property = "user.username", column = "username"),
            @Result(property = "user.nickname", column = "nickname"),
            @Result(property = "user.avatar", column = "avatar"),
            @Result(property = "user.studentNo", column = "student_id")
    })
    List<GroupMember> selectMembersWithDetail(@Param("groupId") Long groupId);

    /**
     * 获取待审批成员列表
     */
    @Select("SELECT gm.*, u.id as member_user_id, u.username, u.nickname, u.avatar " +
            "FROM group_member gm " +
            "LEFT JOIN user u ON gm.user_id = u.id " +
            "WHERE gm.group_id = #{groupId} AND gm.status = 0 " +
            "ORDER BY gm.created_at")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "groupId", column = "group_id"),
            @Result(property = "userId", column = "user_id"),
            @Result(property = "status", column = "status"),
            @Result(property = "createdAt", column = "created_at"),
            @Result(property = "user.id", column = "member_user_id"),
            @Result(property = "user.username", column = "username"),
            @Result(property = "user.nickname", column = "nickname"),
            @Result(property = "user.avatar", column = "avatar")
    })
    List<GroupMember> selectPendingMembers(@Param("groupId") Long groupId);

    /**
     * 查找用户在小组中的成员记录
     */
    @Select("SELECT * FROM group_member WHERE group_id = #{groupId} AND user_id = #{userId}")
    GroupMember selectByGroupAndUser(@Param("groupId") Long groupId, @Param("userId") Long userId);

    /**
     * 统计小组成员数量
     */
    @Select("SELECT COUNT(*) FROM group_member WHERE group_id = #{groupId} AND status = 1")
    int countActiveMembers(@Param("groupId") Long groupId);

    /**
     * 统计待审批成员数量
     */
    @Select("SELECT COUNT(*) FROM group_member WHERE group_id = #{groupId} AND status = 0")
    int countPendingMembers(@Param("groupId") Long groupId);
}
