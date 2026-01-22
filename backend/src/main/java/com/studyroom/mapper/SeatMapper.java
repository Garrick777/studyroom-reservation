package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.studyroom.entity.Seat;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 座位Mapper接口
 */
@Mapper
public interface SeatMapper extends BaseMapper<Seat> {

    /**
     * 根据自习室ID查找所有座位
     */
    @Select("SELECT * FROM seat WHERE room_id = #{roomId} AND deleted = 0 ORDER BY row_num, col_num")
    List<Seat> findByRoomId(@Param("roomId") Long roomId);

    /**
     * 根据自习室ID和座位编号查找座位
     */
    @Select("SELECT * FROM seat WHERE room_id = #{roomId} AND seat_no = #{seatNo} AND deleted = 0")
    Seat findByRoomIdAndSeatNo(@Param("roomId") Long roomId, @Param("seatNo") String seatNo);

    /**
     * 统计自习室可用座位数
     */
    @Select("SELECT COUNT(*) FROM seat WHERE room_id = #{roomId} AND status = 1 AND deleted = 0")
    int countAvailableByRoomId(@Param("roomId") Long roomId);

    /**
     * 根据座位类型统计
     */
    @Select("SELECT COUNT(*) FROM seat WHERE room_id = #{roomId} AND seat_type = #{seatType} AND deleted = 0")
    int countByRoomIdAndType(@Param("roomId") Long roomId, @Param("seatType") String seatType);

    /**
     * 批量插入座位
     */
    @Insert("<script>" +
            "INSERT INTO seat (room_id, seat_no, row_num, col_num, seat_type, status) VALUES " +
            "<foreach collection='seats' item='seat' separator=','>" +
            "(#{seat.roomId}, #{seat.seatNo}, #{seat.rowNum}, #{seat.colNum}, #{seat.seatType}, #{seat.status})" +
            "</foreach>" +
            "</script>")
    int batchInsert(@Param("seats") List<Seat> seats);

    /**
     * 根据自习室ID删除所有座位
     */
    @Delete("DELETE FROM seat WHERE room_id = #{roomId}")
    int deleteByRoomId(@Param("roomId") Long roomId);
}
