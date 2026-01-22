package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.studyroom.entity.SeatReview;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface SeatReviewMapper extends BaseMapper<SeatReview> {

    @Select("SELECT sr.*, u.real_name as user_name, u.avatar as user_avatar, s.seat_no, r.name as room_name " +
            "FROM seat_review sr " +
            "LEFT JOIN user u ON sr.user_id = u.id " +
            "LEFT JOIN seat s ON sr.seat_id = s.id " +
            "LEFT JOIN study_room r ON s.room_id = r.id " +
            "WHERE sr.seat_id = #{seatId} ORDER BY sr.created_at DESC LIMIT #{limit}")
    List<SeatReview> selectBySeatId(@Param("seatId") Long seatId, @Param("limit") int limit);

    @Select("SELECT AVG(rating) FROM seat_review WHERE seat_id = #{seatId}")
    Double getAverageRating(@Param("seatId") Long seatId);

    @Select("SELECT COUNT(*) FROM seat_review WHERE reservation_id = #{reservationId}")
    int countByReservationId(@Param("reservationId") Long reservationId);
}
