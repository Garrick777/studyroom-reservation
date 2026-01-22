package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.StudyRoom;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 自习室Mapper接口
 */
@Mapper
public interface StudyRoomMapper extends BaseMapper<StudyRoom> {

    /**
     * 根据编号查找自习室
     */
    @Select("SELECT * FROM study_room WHERE code = #{code} AND deleted = 0")
    StudyRoom findByCode(@Param("code") String code);

    /**
     * 根据管理员ID查找自习室
     */
    @Select("SELECT * FROM study_room WHERE manager_id = #{managerId} AND deleted = 0")
    List<StudyRoom> findByManagerId(@Param("managerId") Long managerId);

    /**
     * 查询热门自习室(按预约数排序)
     */
    @Select("SELECT * FROM study_room WHERE status = 1 AND deleted = 0 ORDER BY total_reservations DESC LIMIT #{limit}")
    List<StudyRoom> findTopByReservations(@Param("limit") int limit);

    /**
     * 查询评分最高的自习室
     */
    @Select("SELECT * FROM study_room WHERE status = 1 AND deleted = 0 ORDER BY rating DESC LIMIT #{limit}")
    List<StudyRoom> findTopByRating(@Param("limit") int limit);

    /**
     * 更新今日预约数
     */
    @Update("UPDATE study_room SET today_reservations = today_reservations + 1 WHERE id = #{roomId}")
    int incrementTodayReservations(@Param("roomId") Long roomId);

    /**
     * 重置所有自习室今日预约数
     */
    @Update("UPDATE study_room SET today_reservations = 0 WHERE deleted = 0")
    int resetTodayReservations();
}
