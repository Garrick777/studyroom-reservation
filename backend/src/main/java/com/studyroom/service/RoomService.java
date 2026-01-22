package com.studyroom.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.Seat;
import com.studyroom.entity.StudyRoom;
import com.studyroom.entity.TimeSlot;

import java.time.LocalDate;
import java.util.List;

/**
 * 自习室服务接口
 */
public interface RoomService {

    // ========== 自习室查询 ==========

    /**
     * 获取自习室列表(分页)
     */
    Page<StudyRoom> getRoomList(int page, int size, String keyword, String building, Integer status);

    /**
     * 获取自习室详情
     */
    StudyRoom getRoomById(Long roomId);

    /**
     * 获取热门自习室
     */
    List<StudyRoom> getHotRooms(int limit);

    /**
     * 获取评分最高的自习室
     */
    List<StudyRoom> getTopRatedRooms(int limit);

    // ========== 座位查询 ==========

    /**
     * 获取自习室的所有座位
     */
    List<Seat> getSeatsByRoomId(Long roomId);

    /**
     * 获取自习室座位状态(指定日期和时段)
     */
    List<Seat> getSeatsWithStatus(Long roomId, LocalDate date, Long timeSlotId);

    /**
     * 获取座位详情
     */
    Seat getSeatById(Long seatId);

    // ========== 时段查询 ==========

    /**
     * 获取所有可用时段
     */
    List<TimeSlot> getTimeSlots();

    /**
     * 获取指定自习室在指定日期的可用时段
     */
    List<TimeSlot> getAvailableTimeSlots(Long roomId, LocalDate date);

    // ========== 收藏功能 ==========

    /**
     * 收藏自习室
     */
    void addFavorite(Long userId, Long roomId);

    /**
     * 取消收藏
     */
    void removeFavorite(Long userId, Long roomId);

    /**
     * 获取用户收藏的自习室列表
     */
    List<StudyRoom> getUserFavorites(Long userId);

    /**
     * 检查是否已收藏
     */
    boolean isFavorite(Long userId, Long roomId);

    // ========== 统计功能 ==========

    /**
     * 获取自习室可用座位数
     */
    int getAvailableSeatCount(Long roomId);

    /**
     * 获取自习室在指定时段的可用座位数
     */
    int getAvailableSeatCount(Long roomId, LocalDate date, Long timeSlotId);
}
