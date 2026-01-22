package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.StudyGoal;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDate;
import java.util.List;

/**
 * 学习目标 Mapper
 */
@Mapper
public interface StudyGoalMapper extends BaseMapper<StudyGoal> {

    /**
     * 分页查询用户目标
     */
    @Select("<script>" +
            "SELECT * FROM study_goal WHERE user_id = #{userId} " +
            "<if test=\"status != null and status != ''\"> AND status = #{status} </if>" +
            "<if test=\"type != null and type != ''\"> AND type = #{type} </if>" +
            "ORDER BY created_at DESC" +
            "</script>")
    IPage<StudyGoal> selectUserGoals(Page<StudyGoal> page,
                                      @Param("userId") Long userId,
                                      @Param("status") String status,
                                      @Param("type") String type);

    /**
     * 查询用户进行中的目标
     */
    @Select("SELECT * FROM study_goal WHERE user_id = #{userId} AND status = 'ACTIVE' ORDER BY end_date ASC")
    List<StudyGoal> selectActiveGoals(@Param("userId") Long userId);

    /**
     * 查询用户已完成的目标数
     */
    @Select("SELECT COUNT(*) FROM study_goal WHERE user_id = #{userId} AND status = 'COMPLETED'")
    int countCompletedGoals(@Param("userId") Long userId);

    /**
     * 查询已过期但未处理的目标
     */
    @Select("SELECT * FROM study_goal WHERE status = 'ACTIVE' AND end_date < #{today}")
    List<StudyGoal> selectExpiredGoals(@Param("today") LocalDate today);

    /**
     * 更新目标进度
     */
    @Update("UPDATE study_goal SET current_value = #{currentValue}, updated_at = NOW() WHERE id = #{id}")
    int updateProgress(@Param("id") Long id, @Param("currentValue") java.math.BigDecimal currentValue);

    /**
     * 将过期目标标记为失败
     */
    @Update("UPDATE study_goal SET status = 'FAILED', updated_at = NOW() WHERE status = 'ACTIVE' AND end_date < #{today}")
    int markExpiredAsFailed(@Param("today") LocalDate today);

    /**
     * 统计用户目标数量
     */
    @Select("SELECT COUNT(*) FROM study_goal WHERE user_id = #{userId}")
    int countByUserId(@Param("userId") Long userId);

    /**
     * 查询用户特定类型的进行中目标
     */
    @Select("SELECT * FROM study_goal WHERE user_id = #{userId} AND type = #{type} AND status = 'ACTIVE' LIMIT 1")
    StudyGoal selectActiveByType(@Param("userId") Long userId, @Param("type") String type);
}
