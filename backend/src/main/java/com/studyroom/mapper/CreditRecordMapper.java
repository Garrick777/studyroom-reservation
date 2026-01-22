package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.CreditRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 信用积分记录 Mapper
 */
@Mapper
public interface CreditRecordMapper extends BaseMapper<CreditRecord> {

    /**
     * 分页查询用户积分记录
     */
    @Select("<script>" +
            "SELECT * FROM credit_record " +
            "WHERE user_id = #{userId} " +
            "<if test='type != null'> AND type = #{type} </if>" +
            "ORDER BY created_at DESC" +
            "</script>")
    IPage<CreditRecord> selectUserRecords(Page<CreditRecord> page,
                                           @Param("userId") Long userId,
                                           @Param("type") String type);

    /**
     * 查询用户最近的积分记录
     */
    @Select("SELECT * FROM credit_record WHERE user_id = #{userId} ORDER BY created_at DESC LIMIT #{limit}")
    List<CreditRecord> selectRecentRecords(@Param("userId") Long userId, @Param("limit") int limit);

    /**
     * 统计用户在时间范围内的积分变动
     */
    @Select("SELECT COALESCE(SUM(change_score), 0) FROM credit_record " +
            "WHERE user_id = #{userId} AND created_at BETWEEN #{startTime} AND #{endTime}")
    int sumScoreChange(@Param("userId") Long userId,
                       @Param("startTime") LocalDateTime startTime,
                       @Param("endTime") LocalDateTime endTime);

    /**
     * 统计用户积分增加总数
     */
    @Select("SELECT COALESCE(SUM(change_score), 0) FROM credit_record WHERE user_id = #{userId} AND change_score > 0")
    int sumPositiveChange(@Param("userId") Long userId);

    /**
     * 统计用户积分扣除总数
     */
    @Select("SELECT COALESCE(SUM(ABS(change_score)), 0) FROM credit_record WHERE user_id = #{userId} AND change_score < 0")
    int sumNegativeChange(@Param("userId") Long userId);

    /**
     * 按月统计积分变动
     */
    @Select("SELECT DATE_FORMAT(created_at, '%Y-%m') as month, " +
            "SUM(CASE WHEN change_score > 0 THEN change_score ELSE 0 END) as gain, " +
            "SUM(CASE WHEN change_score < 0 THEN ABS(change_score) ELSE 0 END) as loss " +
            "FROM credit_record WHERE user_id = #{userId} " +
            "GROUP BY DATE_FORMAT(created_at, '%Y-%m') " +
            "ORDER BY month DESC LIMIT #{months}")
    List<Object[]> monthlyStats(@Param("userId") Long userId, @Param("months") int months);
}
