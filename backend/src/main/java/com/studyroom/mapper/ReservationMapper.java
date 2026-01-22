package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.Reservation;
import org.apache.ibatis.annotations.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface ReservationMapper extends BaseMapper<Reservation> {

    /**
     * 查询用户某天的预约列表
     */
    @Select("SELECT * FROM reservation WHERE user_id = #{userId} AND date = #{date}")
    List<Reservation> selectByUserIdAndDate(@Param("userId") Long userId, @Param("date") LocalDate date);

    /**
     * 检查座位时段冲突
     */
    @Select("SELECT COUNT(*) FROM reservation WHERE seat_id = #{seatId} AND date = #{date} " +
            "AND time_slot_id = #{timeSlotId} AND status NOT IN ('CANCELLED', 'NO_SHOW', 'VIOLATION')")
    int checkConflict(@Param("seatId") Long seatId, @Param("date") LocalDate date, 
                      @Param("timeSlotId") Long timeSlotId);

    /**
     * 统计用户当天预约数量
     */
    @Select("SELECT COUNT(*) FROM reservation WHERE user_id = #{userId} AND date = #{date} " +
            "AND status NOT IN ('CANCELLED')")
    int countUserDailyReservations(@Param("userId") Long userId, @Param("date") LocalDate date);

    /**
     * 查询待签到的预约(已过开始时间但未签到)
     */
    @Select("SELECT * FROM reservation WHERE status = 'PENDING' AND start_time <= #{now} " +
            "AND TIMESTAMPDIFF(MINUTE, start_time, #{now}) >= #{timeoutMinutes}")
    List<Reservation> selectPendingTimeout(@Param("now") LocalDateTime now, 
                                           @Param("timeoutMinutes") int timeoutMinutes);

    /**
     * 查询暂离超时的预约
     */
    @Select("SELECT * FROM reservation WHERE status = 'LEAVING' AND leave_time IS NOT NULL " +
            "AND TIMESTAMPDIFF(MINUTE, leave_time, #{now}) >= #{timeoutMinutes}")
    List<Reservation> selectLeavingTimeout(@Param("now") LocalDateTime now, 
                                           @Param("timeoutMinutes") int timeoutMinutes);

    /**
     * 查询座位在指定日期的预约情况
     */
    @Select("SELECT * FROM reservation WHERE seat_id = #{seatId} AND date = #{date} " +
            "AND status NOT IN ('CANCELLED', 'NO_SHOW', 'VIOLATION') ORDER BY start_time")
    List<Reservation> selectBySeatAndDate(@Param("seatId") Long seatId, @Param("date") LocalDate date);

    /**
     * 查询自习室在指定日期指定时段的预约
     */
    @Select("SELECT r.*, u.real_name as user_name, u.student_id, s.seat_no, sr.name as room_name " +
            "FROM reservation r " +
            "LEFT JOIN user u ON r.user_id = u.id " +
            "LEFT JOIN seat s ON r.seat_id = s.id " +
            "LEFT JOIN study_room sr ON r.room_id = sr.id " +
            "WHERE r.room_id = #{roomId} AND r.date = #{date} AND r.time_slot_id = #{timeSlotId} " +
            "AND r.status NOT IN ('CANCELLED', 'NO_SHOW', 'VIOLATION')")
    List<Reservation> selectByRoomDateSlot(@Param("roomId") Long roomId, 
                                           @Param("date") LocalDate date, 
                                           @Param("timeSlotId") Long timeSlotId);

    /**
     * 统计用户总预约数
     */
    @Select("SELECT COUNT(*) FROM reservation WHERE user_id = #{userId} AND status = 'COMPLETED'")
    int countUserCompletedReservations(@Param("userId") Long userId);

    /**
     * 统计用户总学习时长
     */
    @Select("SELECT COALESCE(SUM(actual_duration), 0) FROM reservation WHERE user_id = #{userId} AND status = 'COMPLETED'")
    int sumUserStudyDuration(@Param("userId") Long userId);

    /**
     * 查询用户当前进行中的预约
     */
    @Select("SELECT r.*, s.seat_no, sr.name as room_name, ts.name as time_slot_name " +
            "FROM reservation r " +
            "LEFT JOIN seat s ON r.seat_id = s.id " +
            "LEFT JOIN study_room sr ON r.room_id = sr.id " +
            "LEFT JOIN time_slot ts ON r.time_slot_id = ts.id " +
            "WHERE r.user_id = #{userId} AND r.status IN ('PENDING', 'SIGNED_IN', 'LEAVING') " +
            "AND r.date = CURDATE() " +
            "ORDER BY r.start_time LIMIT 1")
    Reservation selectCurrentByUserId(@Param("userId") Long userId);
}
