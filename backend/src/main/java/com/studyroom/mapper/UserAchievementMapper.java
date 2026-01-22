package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.studyroom.entity.UserAchievement;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 用户成就Mapper
 */
@Mapper
public interface UserAchievementMapper extends BaseMapper<UserAchievement> {

    /**
     * 获取用户某个成就的进度
     */
    @Select("SELECT * FROM user_achievement WHERE user_id = #{userId} AND achievement_id = #{achievementId}")
    UserAchievement selectByUserAndAchievement(@Param("userId") Long userId, @Param("achievementId") Long achievementId);

    /**
     * 获取用户的所有成就进度（带成就详情）
     */
    @Select("SELECT ua.*, a.name as achievement_name, a.description as achievement_description, " +
            "a.icon as achievement_icon, a.badge_color, a.category, a.condition_type, a.condition_value, " +
            "a.reward_points, a.reward_exp, a.rarity, a.is_hidden " +
            "FROM user_achievement ua " +
            "LEFT JOIN achievement a ON ua.achievement_id = a.id " +
            "WHERE ua.user_id = #{userId} " +
            "ORDER BY ua.is_completed DESC, ua.completed_at DESC")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "userId", column = "user_id"),
            @Result(property = "achievementId", column = "achievement_id"),
            @Result(property = "progress", column = "progress"),
            @Result(property = "isCompleted", column = "is_completed"),
            @Result(property = "completedAt", column = "completed_at"),
            @Result(property = "isClaimed", column = "is_claimed"),
            @Result(property = "claimedAt", column = "claimed_at"),
            @Result(property = "createdAt", column = "created_at"),
            @Result(property = "updatedAt", column = "updated_at"),
            @Result(property = "achievement.id", column = "achievement_id"),
            @Result(property = "achievement.name", column = "achievement_name"),
            @Result(property = "achievement.description", column = "achievement_description"),
            @Result(property = "achievement.icon", column = "achievement_icon"),
            @Result(property = "achievement.badgeColor", column = "badge_color"),
            @Result(property = "achievement.category", column = "category"),
            @Result(property = "achievement.conditionType", column = "condition_type"),
            @Result(property = "achievement.conditionValue", column = "condition_value"),
            @Result(property = "achievement.rewardPoints", column = "reward_points"),
            @Result(property = "achievement.rewardExp", column = "reward_exp"),
            @Result(property = "achievement.rarity", column = "rarity"),
            @Result(property = "achievement.isHidden", column = "is_hidden")
    })
    List<UserAchievement> selectUserAchievementsWithDetail(@Param("userId") Long userId);

    /**
     * 获取用户已完成的成就数量
     */
    @Select("SELECT COUNT(*) FROM user_achievement WHERE user_id = #{userId} AND is_completed = 1")
    int countCompletedByUser(@Param("userId") Long userId);

    /**
     * 获取用户待领取奖励的成就数量
     */
    @Select("SELECT COUNT(*) FROM user_achievement WHERE user_id = #{userId} AND is_completed = 1 AND is_claimed = 0")
    int countUnclaimedByUser(@Param("userId") Long userId);

    /**
     * 获取用户待领取奖励的成就列表
     */
    @Select("SELECT ua.*, a.name as achievement_name, a.description as achievement_description, " +
            "a.icon as achievement_icon, a.badge_color, a.reward_points, a.reward_exp, a.rarity " +
            "FROM user_achievement ua " +
            "LEFT JOIN achievement a ON ua.achievement_id = a.id " +
            "WHERE ua.user_id = #{userId} AND ua.is_completed = 1 AND ua.is_claimed = 0 " +
            "ORDER BY ua.completed_at DESC")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "userId", column = "user_id"),
            @Result(property = "achievementId", column = "achievement_id"),
            @Result(property = "isCompleted", column = "is_completed"),
            @Result(property = "completedAt", column = "completed_at"),
            @Result(property = "isClaimed", column = "is_claimed"),
            @Result(property = "claimedAt", column = "claimed_at"),
            @Result(property = "achievement.id", column = "achievement_id"),
            @Result(property = "achievement.name", column = "achievement_name"),
            @Result(property = "achievement.description", column = "achievement_description"),
            @Result(property = "achievement.icon", column = "achievement_icon"),
            @Result(property = "achievement.badgeColor", column = "badge_color"),
            @Result(property = "achievement.rewardPoints", column = "reward_points"),
            @Result(property = "achievement.rewardExp", column = "reward_exp"),
            @Result(property = "achievement.rarity", column = "rarity")
    })
    List<UserAchievement> selectUnclaimedByUser(@Param("userId") Long userId);

    /**
     * 批量获取用户的成就进度
     */
    @Select("<script>" +
            "SELECT * FROM user_achievement " +
            "WHERE user_id = #{userId} AND achievement_id IN " +
            "<foreach collection='achievementIds' item='id' open='(' separator=',' close=')'>" +
            "#{id}" +
            "</foreach>" +
            "</script>")
    List<UserAchievement> selectByUserAndAchievements(@Param("userId") Long userId, 
                                                       @Param("achievementIds") List<Long> achievementIds);

    /**
     * 统计用户各稀有度成就完成数量
     */
    @Select("SELECT a.rarity, COUNT(*) as count " +
            "FROM user_achievement ua " +
            "JOIN achievement a ON ua.achievement_id = a.id " +
            "WHERE ua.user_id = #{userId} AND ua.is_completed = 1 " +
            "GROUP BY a.rarity")
    @Results({
            @Result(property = "rarity", column = "rarity"),
            @Result(property = "count", column = "count")
    })
    List<java.util.Map<String, Object>> countByRarity(@Param("userId") Long userId);
}
