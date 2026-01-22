package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.Achievement;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 成就Mapper
 */
@Mapper
public interface AchievementMapper extends BaseMapper<Achievement> {

    /**
     * 获取所有启用的成就列表
     */
    @Select("SELECT * FROM achievement WHERE status = 1 ORDER BY category, sort_order")
    List<Achievement> selectAllEnabled();

    /**
     * 按分类获取成就列表
     */
    @Select("SELECT * FROM achievement WHERE status = 1 AND category = #{category} ORDER BY sort_order")
    List<Achievement> selectByCategory(@Param("category") String category);

    /**
     * 按条件类型获取成就列表
     */
    @Select("SELECT * FROM achievement WHERE status = 1 AND condition_type = #{conditionType} ORDER BY condition_value")
    List<Achievement> selectByConditionType(@Param("conditionType") String conditionType);

    /**
     * 分页查询成就（管理端）
     */
    @Select("<script>" +
            "SELECT * FROM achievement " +
            "<where>" +
            "  <if test='category != null and category != \"\"'> AND category = #{category}</if>" +
            "  <if test='rarity != null and rarity != \"\"'> AND rarity = #{rarity}</if>" +
            "  <if test='keyword != null and keyword != \"\"'> AND (name LIKE CONCAT('%',#{keyword},'%') OR description LIKE CONCAT('%',#{keyword},'%'))</if>" +
            "</where>" +
            "ORDER BY category, sort_order" +
            "</script>")
    Page<Achievement> selectPage(Page<Achievement> page,
                                 @Param("category") String category,
                                 @Param("rarity") String rarity,
                                 @Param("keyword") String keyword);
}
