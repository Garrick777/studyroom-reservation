package com.studyroom.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.common.ResultCode;
import com.studyroom.entity.*;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.*;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.RoomService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 自习室服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class RoomServiceImpl implements RoomService {

    private final StudyRoomMapper studyRoomMapper;
    private final SeatMapper seatMapper;
    private final TimeSlotMapper timeSlotMapper;
    private final UserFavoriteMapper userFavoriteMapper;

    // ========== 自习室查询 ==========

    @Override
    public Page<StudyRoom> getRoomList(int page, int size, String keyword, String building, Integer status) {
        Page<StudyRoom> pageParam = new Page<>(page, size);

        LambdaQueryWrapper<StudyRoom> wrapper = new LambdaQueryWrapper<>();

        // 关键词搜索
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                    .like(StudyRoom::getName, keyword)
                    .or().like(StudyRoom::getCode, keyword)
                    .or().like(StudyRoom::getBuilding, keyword)
            );
        }

        // 建筑筛选
        if (StringUtils.hasText(building)) {
            wrapper.eq(StudyRoom::getBuilding, building);
        }

        // 状态筛选
        if (status != null) {
            wrapper.eq(StudyRoom::getStatus, status);
        }

        wrapper.orderByAsc(StudyRoom::getSortOrder)
                .orderByDesc(StudyRoom::getRating);

        Page<StudyRoom> result = studyRoomMapper.selectPage(pageParam, wrapper);

        // 填充额外信息
        Long currentUserId = SecurityUtil.getCurrentUserId();
        Set<Long> favoriteRoomIds = currentUserId != null
                ? userFavoriteMapper.findRoomIdsByUserId(currentUserId).stream().collect(Collectors.toSet())
                : Set.of();

        result.getRecords().forEach(room -> {
            room.setAvailableSeats(seatMapper.countAvailableByRoomId(room.getId()));
            room.setIsFavorite(favoriteRoomIds.contains(room.getId()));
        });

        return result;
    }

    @Override
    public StudyRoom getRoomById(Long roomId) {
        StudyRoom room = studyRoomMapper.selectById(roomId);
        if (room == null) {
            throw new BusinessException(ResultCode.ROOM_NOT_FOUND);
        }

        // 填充可用座位数
        room.setAvailableSeats(seatMapper.countAvailableByRoomId(roomId));

        // 填充收藏状态
        Long currentUserId = SecurityUtil.getCurrentUserId();
        if (currentUserId != null) {
            room.setIsFavorite(userFavoriteMapper.findByUserIdAndRoomId(currentUserId, roomId) != null);
        }

        return room;
    }

    @Override
    public List<StudyRoom> getHotRooms(int limit) {
        List<StudyRoom> rooms = studyRoomMapper.findTopByReservations(limit);
        rooms.forEach(room -> room.setAvailableSeats(seatMapper.countAvailableByRoomId(room.getId())));
        return rooms;
    }

    @Override
    public List<StudyRoom> getTopRatedRooms(int limit) {
        List<StudyRoom> rooms = studyRoomMapper.findTopByRating(limit);
        rooms.forEach(room -> room.setAvailableSeats(seatMapper.countAvailableByRoomId(room.getId())));
        return rooms;
    }

    // ========== 座位查询 ==========

    @Override
    public List<Seat> getSeatsByRoomId(Long roomId) {
        // 验证自习室存在
        getRoomById(roomId);
        return seatMapper.findByRoomId(roomId);
    }

    @Override
    public List<Seat> getSeatsWithStatus(Long roomId, LocalDate date, Long timeSlotId) {
        // 验证自习室存在
        getRoomById(roomId);

        List<Seat> seats = seatMapper.findByRoomId(roomId);

        // TODO: 根据预约记录填充座位实时状态
        // 这里暂时设置所有可用座位为 AVAILABLE
        seats.forEach(seat -> {
            if (seat.getStatus() == 1) {
                seat.setCurrentStatus(Seat.UseStatus.AVAILABLE.name());
            } else {
                seat.setCurrentStatus("UNAVAILABLE");
            }
        });

        return seats;
    }

    @Override
    public Seat getSeatById(Long seatId) {
        Seat seat = seatMapper.selectById(seatId);
        if (seat == null) {
            throw new BusinessException(ResultCode.SEAT_NOT_FOUND);
        }
        return seat;
    }

    // ========== 时段查询 ==========

    @Override
    public List<TimeSlot> getTimeSlots() {
        return timeSlotMapper.findAllActive();
    }

    @Override
    public List<TimeSlot> getAvailableTimeSlots(Long roomId, LocalDate date) {
        StudyRoom room = getRoomById(roomId);
        List<TimeSlot> slots = timeSlotMapper.findAllActive();

        LocalTime now = LocalTime.now();
        boolean isToday = date.equals(LocalDate.now());

        slots.forEach(slot -> {
            // 判断时段是否可预约
            boolean available = true;

            // 如果是今天，过去的时段不可预约
            if (isToday && slot.getStartTime().isBefore(now)) {
                available = false;
            }

            // 检查时段是否在自习室开放时间内
            if (slot.getStartTime().isBefore(room.getOpenTime()) ||
                    slot.getEndTime().isAfter(room.getCloseTime())) {
                available = false;
            }

            slot.setAvailable(available);

            // TODO: 计算该时段剩余座位数
            if (available) {
                slot.setAvailableSeats(seatMapper.countAvailableByRoomId(roomId));
            } else {
                slot.setAvailableSeats(0);
            }
        });

        return slots;
    }

    // ========== 收藏功能 ==========

    @Override
    @Transactional
    public void addFavorite(Long userId, Long roomId) {
        // 验证自习室存在
        getRoomById(roomId);

        // 检查是否已收藏
        if (userFavoriteMapper.findByUserIdAndRoomId(userId, roomId) != null) {
            throw new BusinessException("已经收藏过了");
        }

        UserFavorite favorite = UserFavorite.builder()
                .userId(userId)
                .roomId(roomId)
                .build();

        userFavoriteMapper.insert(favorite);
        log.info("用户 {} 收藏了自习室 {}", userId, roomId);
    }

    @Override
    @Transactional
    public void removeFavorite(Long userId, Long roomId) {
        int deleted = userFavoriteMapper.deleteByUserIdAndRoomId(userId, roomId);
        if (deleted == 0) {
            throw new BusinessException("尚未收藏该自习室");
        }
        log.info("用户 {} 取消收藏自习室 {}", userId, roomId);
    }

    @Override
    public List<StudyRoom> getUserFavorites(Long userId) {
        List<Long> roomIds = userFavoriteMapper.findRoomIdsByUserId(userId);
        if (roomIds.isEmpty()) {
            return List.of();
        }

        LambdaQueryWrapper<StudyRoom> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(StudyRoom::getId, roomIds);

        List<StudyRoom> rooms = studyRoomMapper.selectList(wrapper);
        rooms.forEach(room -> {
            room.setAvailableSeats(seatMapper.countAvailableByRoomId(room.getId()));
            room.setIsFavorite(true);
        });

        return rooms;
    }

    @Override
    public boolean isFavorite(Long userId, Long roomId) {
        return userFavoriteMapper.findByUserIdAndRoomId(userId, roomId) != null;
    }

    // ========== 统计功能 ==========

    @Override
    public int getAvailableSeatCount(Long roomId) {
        return seatMapper.countAvailableByRoomId(roomId);
    }

    @Override
    public int getAvailableSeatCount(Long roomId, LocalDate date, Long timeSlotId) {
        // TODO: 根据预约记录计算实际可用座位数
        return seatMapper.countAvailableByRoomId(roomId);
    }
}
