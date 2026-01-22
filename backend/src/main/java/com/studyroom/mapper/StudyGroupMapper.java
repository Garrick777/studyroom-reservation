package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.StudyGroup;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 学习小组Mapper
 */
@Mapper
public interface StudyGroupMapper extends BaseMapper<StudyGroup> {

    /**
     * 获取公开小组列表（带创建者信息）
     */
    @Select("<script>" +
            "SELECT g.*, u.nickname as creator_name, u.avatar as creator_avatar " +
            "FROM study_group g " +
            "LEFT JOIN user u ON g.creator_id = u.id " +
            "WHERE g.status = 1 AND g.is_public = 1 " +
            "<if test='keyword != null and keyword != \"\"'>" +
            "  AND (g.name LIKE CONCAT('%',#{keyword},'%') OR g.tags LIKE CONCAT('%',#{keyword},'%')) " +
            "</if>" +
            "ORDER BY g.member_count DESC, g.created_at DESC" +
            "</script>")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "name", column = "name"),
            @Result(property = "description", column = "description"),
            @Result(property = "avatar", column = "avatar"),
            @Result(property = "coverImage", column = "cover_image"),
            @Result(property = "creatorId", column = "creator_id"),
            @Result(property = "maxMembers", column = "max_members"),
            @Result(property = "memberCount", column = "member_count"),
            @Result(property = "totalHours", column = "total_hours"),
            @Result(property = "weeklyHours", column = "weekly_hours"),
            @Result(property = "isPublic", column = "is_public"),
            @Result(property = "needApprove", column = "need_approve"),
            @Result(property = "tags", column = "tags"),
            @Result(property = "status", column = "status"),
            @Result(property = "createdAt", column = "created_at"),
            @Result(property = "creator.nickname", column = "creator_name"),
            @Result(property = "creator.avatar", column = "creator_avatar")
    })
    Page<StudyGroup> selectPublicGroups(Page<StudyGroup> page, @Param("keyword") String keyword);

    /**
     * 获取用户加入的小组列表
     */
    @Select("SELECT g.*, u.nickname as creator_name, gm.role as my_role " +
            "FROM study_group g " +
            "LEFT JOIN user u ON g.creator_id = u.id " +
            "INNER JOIN group_member gm ON g.id = gm.group_id " +
            "WHERE gm.user_id = #{userId} AND gm.status = 1 AND g.status = 1 " +
            "ORDER BY gm.join_time DESC")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "name", column = "name"),
            @Result(property = "description", column = "description"),
            @Result(property = "avatar", column = "avatar"),
            @Result(property = "creatorId", column = "creator_id"),
            @Result(property = "memberCount", column = "member_count"),
            @Result(property = "totalHours", column = "total_hours"),
            @Result(property = "weeklyHours", column = "weekly_hours"),
            @Result(property = "status", column = "status"),
            @Result(property = "createdAt", column = "created_at"),
            @Result(property = "creator.nickname", column = "creator_name"),
            @Result(property = "currentMember.role", column = "my_role")
    })
    List<StudyGroup> selectMyGroups(@Param("userId") Long userId);

    /**
     * 获取小组详情（带创建者信息）
     */
    @Select("SELECT g.*, u.id as creator_user_id, u.nickname, u.avatar, u.student_id " +
            "FROM study_group g " +
            "LEFT JOIN user u ON g.creator_id = u.id " +
            "WHERE g.id = #{id}")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "name", column = "name"),
            @Result(property = "description", column = "description"),
            @Result(property = "avatar", column = "avatar"),
            @Result(property = "coverImage", column = "cover_image"),
            @Result(property = "creatorId", column = "creator_id"),
            @Result(property = "maxMembers", column = "max_members"),
            @Result(property = "memberCount", column = "member_count"),
            @Result(property = "totalHours", column = "total_hours"),
            @Result(property = "weeklyHours", column = "weekly_hours"),
            @Result(property = "isPublic", column = "is_public"),
            @Result(property = "needApprove", column = "need_approve"),
            @Result(property = "tags", column = "tags"),
            @Result(property = "status", column = "status"),
            @Result(property = "createdAt", column = "created_at"),
            @Result(property = "updatedAt", column = "updated_at"),
            @Result(property = "creator.id", column = "creator_user_id"),
            @Result(property = "creator.nickname", column = "nickname"),
            @Result(property = "creator.avatar", column = "avatar"),
            @Result(property = "creator.studentNo", column = "student_id")
    })
    StudyGroup selectDetailById(@Param("id") Long id);

    /**
     * 统计用户加入的小组数量
     */
    @Select("SELECT COUNT(*) FROM group_member WHERE user_id = #{userId} AND status = 1")
    int countMyGroups(@Param("userId") Long userId);
}
