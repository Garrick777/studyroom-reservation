package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.studyroom.entity.CheckInRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;
import java.util.List;

/**
 * 打卡记录 Mapper
 */
@Mapper
public interface CheckInRecordMapper extends BaseMapper<CheckInRecord> {

    /**
     * 查询用户某天的打卡记录
     */
    @Select("SELECT * FROM check_in_record WHERE user_id = #{userId} AND check_in_date = #{date} AND type = 'DAILY' LIMIT 1")
    CheckInRecord selectByUserIdAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);

    /**
     * 查询用户日期范围内的打卡记录
     */
    @Select("SELECT * FROM check_in_record WHERE user_id = #{userId} " +
            "AND check_in_date BETWEEN #{startDate} AND #{endDate} AND type = 'DAILY' " +
            "ORDER BY check_in_date ASC")
    List<CheckInRecord> selectByUserIdAndDateRange(@Param("userId") Long userId,
                                                    @Param("startDate") LocalDate startDate,
                                                    @Param("endDate") LocalDate endDate);

    /**
     * 统计用户打卡总天数
     */
    @Select("SELECT COUNT(DISTINCT check_in_date) FROM check_in_record WHERE user_id = #{userId} AND type = 'DAILY'")
    int countTotalDays(@Param("userId") Long userId);

    /**
     * 统计用户获得的总积分
     */
    @Select("SELECT COALESCE(SUM(earned_points), 0) FROM check_in_record WHERE user_id = #{userId}")
    int sumEarnedPoints(@Param("userId") Long userId);

    /**
     * 统计用户获得的总经验
     */
    @Select("SELECT COALESCE(SUM(earned_exp), 0) FROM check_in_record WHERE user_id = #{userId}")
    int sumEarnedExp(@Param("userId") Long userId);

    /**
     * 查询用户最大连续打卡天数
     */
    @Select("SELECT COALESCE(MAX(continuous_days), 0) FROM check_in_record WHERE user_id = #{userId} AND type = 'DAILY'")
    int selectMaxContinuousDays(@Param("userId") Long userId);

    /**
     * 查询用户最近一次打卡记录
     */
    @Select("SELECT * FROM check_in_record WHERE user_id = #{userId} AND type = 'DAILY' ORDER BY check_in_date DESC LIMIT 1")
    CheckInRecord selectLatestCheckIn(@Param("userId") Long userId);

    /**
     * 查询某日期打卡的所有用户ID
     */
    @Select("SELECT DISTINCT user_id FROM check_in_record WHERE check_in_date = #{date} AND type = 'DAILY'")
    List<Long> selectCheckedInUserIds(@Param("date") LocalDate date);
}
