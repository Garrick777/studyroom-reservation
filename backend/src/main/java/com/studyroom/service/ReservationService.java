package com.studyroom.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.studyroom.common.PageResult;
import com.studyroom.common.ResultCode;
import com.studyroom.dto.reservation.*;
import com.studyroom.entity.*;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.*;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReservationService extends ServiceImpl<ReservationMapper, Reservation> {

    private final ReservationMapper reservationMapper;
    private final UserMapper userMapper;
    private final StudyRoomMapper studyRoomMapper;
    private final SeatMapper seatMapper;
    private final TimeSlotMapper timeSlotMapper;

    private static final int MAX_DAILY_RESERVATIONS = 3;
    private static final int MIN_CREDIT_SCORE = 60;
    private static final int SIGN_IN_ADVANCE_MINUTES = 15;
    private static final int SIGN_IN_TIMEOUT_MINUTES = 15;
    private static final int LEAVE_TIMEOUT_MINUTES = 30;
    private static final int MAX_LEAVE_COUNT = 2;
    private static final int FREE_CANCEL_MINUTES = 30;
    private static final int POINTS_PER_HOUR = 10;
    private static final int EXP_PER_HOUR = 5;

    @Transactional
    public ReservationVO createReservation(Long userId, CreateReservationRequest request) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        if (user.getCreditScore() < MIN_CREDIT_SCORE) {
            throw new BusinessException("信用分不足，无法预约。最低要求: " + MIN_CREDIT_SCORE + " 分");
        }

        // 检查黑名单
        if (user.isInBlacklist()) {
            throw new BusinessException("您已被加入黑名单，解禁时间: " + user.getBlacklistEndTime());
        }

        int dailyCount = reservationMapper.countUserDailyReservations(userId, request.getDate());
        if (dailyCount >= MAX_DAILY_RESERVATIONS) {
            throw new BusinessException("已达到每日最大预约数量: " + MAX_DAILY_RESERVATIONS + " 次");
        }

        StudyRoom room = studyRoomMapper.selectById(request.getRoomId());
        if (room == null) {
            throw new BusinessException("自习室不存在");
        }
        if (room.getStatus() != 1) {
            throw new BusinessException("自习室当前不可用");
        }

        Seat seat = seatMapper.selectById(request.getSeatId());
        if (seat == null) {
            throw new BusinessException("座位不存在");
        }
        if (!seat.getRoomId().equals(request.getRoomId())) {
            throw new BusinessException("座位不属于该自习室");
        }
        if (seat.getStatus() != 1) {
            throw new BusinessException("座位当前不可用");
        }

        TimeSlot timeSlot = timeSlotMapper.selectById(request.getTimeSlotId());
        if (timeSlot == null) {
            throw new BusinessException("时段不存在");
        }
        if (timeSlot.getStatus() != 1) {
            throw new BusinessException("该时段当前不可预约");
        }

        LocalDate today = LocalDate.now();
        if (request.getDate().isBefore(today)) {
            throw new BusinessException("不能预约过去的日期");
        }
        if (request.getDate().isAfter(today.plusDays(7))) {
            throw new BusinessException("最多只能提前7天预约");
        }

        if (request.getDate().equals(today)) {
            LocalTime now = LocalTime.now();
            if (timeSlot.getEndTime().isBefore(now)) {
                throw new BusinessException("该时段已结束");
            }
        }

        int conflict = reservationMapper.checkConflict(
            request.getSeatId(), request.getDate(), request.getTimeSlotId()
        );
        if (conflict > 0) {
            throw new BusinessException("该座位在此时段已被预约");
        }

        LocalDateTime startTime = LocalDateTime.of(request.getDate(), timeSlot.getStartTime());
        LocalDateTime endTime = LocalDateTime.of(request.getDate(), timeSlot.getEndTime());

        Reservation reservation = Reservation.builder()
                .reservationNo(Reservation.generateReservationNo())
                .userId(userId)
                .roomId(request.getRoomId())
                .seatId(request.getSeatId())
                .date(request.getDate())
                .timeSlotId(request.getTimeSlotId())
                .startTime(startTime)
                .endTime(endTime)
                .status(Reservation.Status.PENDING.name())
                .leaveCount(0)
                .earnedPoints(0)
                .earnedExp(0)
                .remark(request.getRemark())
                .source(request.getSource() != null ? request.getSource() : "WEB")
                .build();

        save(reservation);
        log.info("用户 {} 创建预约成功, 预约号: {}", userId, reservation.getReservationNo());

        return buildReservationVO(reservation, user, room, seat, timeSlot);
    }

    @Transactional
    public ReservationVO signIn(Long userId, Long reservationId) {
        Reservation reservation = getById(reservationId);
        if (reservation == null) {
            throw new BusinessException("预约不存在");
        }
        if (!reservation.getUserId().equals(userId)) {
            throw new BusinessException("无权操作此预约");
        }
        if (!Reservation.Status.PENDING.name().equals(reservation.getStatus())) {
            throw new BusinessException("当前状态无法签到");
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime earliestSignIn = reservation.getStartTime().minusMinutes(SIGN_IN_ADVANCE_MINUTES);
        LocalDateTime latestSignIn = reservation.getStartTime().plusMinutes(SIGN_IN_TIMEOUT_MINUTES);
        
        if (now.isBefore(earliestSignIn)) {
            throw new BusinessException("签到时间未到，最早可签到时间: " + earliestSignIn.toLocalTime());
        }
        if (now.isAfter(latestSignIn)) {
            throw new BusinessException("已超过签到时间");
        }

        reservation.setStatus(Reservation.Status.CHECKED_IN.name());
        reservation.setSignInTime(now);
        updateById(reservation);

        log.info("用户 {} 签到成功, 预约号: {}", userId, reservation.getReservationNo());
        return getReservationDetail(reservationId);
    }

    @Transactional
    public ReservationVO signOut(Long userId, Long reservationId) {
        Reservation reservation = getById(reservationId);
        if (reservation == null) {
            throw new BusinessException("预约不存在");
        }
        if (!reservation.getUserId().equals(userId)) {
            throw new BusinessException("无权操作此预约");
        }
        
        String status = reservation.getStatus();
        if (!Reservation.Status.CHECKED_IN.name().equals(status) && 
            !Reservation.Status.LEAVING.name().equals(status)) {
            throw new BusinessException("当前状态无法签退");
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime signInTime = reservation.getSignInTime();
        
        long actualMinutes = ChronoUnit.MINUTES.between(signInTime, now);
        int hours = (int) Math.max(1, actualMinutes / 60);
        int earnedPoints = hours * POINTS_PER_HOUR;
        int earnedExp = hours * EXP_PER_HOUR;

        reservation.setStatus(Reservation.Status.COMPLETED.name());
        reservation.setSignOutTime(now);
        reservation.setActualDuration((int) actualMinutes);
        reservation.setEarnedPoints(earnedPoints);
        reservation.setEarnedExp(earnedExp);
        
        if (reservation.getLeaveTime() != null) {
            reservation.setReturnTime(now);
        }
        
        updateById(reservation);

        User user = userMapper.selectById(userId);
        if (user != null) {
            user.setTotalStudyTime((user.getTotalStudyTime() != null ? user.getTotalStudyTime() : 0) + (int) actualMinutes);
            user.setTotalPoints((user.getTotalPoints() != null ? user.getTotalPoints() : 0) + earnedPoints);
            userMapper.updateById(user);
        }

        log.info("用户 {} 签退成功, 学习时长: {} 分钟, 获得积分: {}", userId, actualMinutes, earnedPoints);
        return getReservationDetail(reservationId);
    }

    @Transactional
    public ReservationVO leave(Long userId, Long reservationId) {
        Reservation reservation = getById(reservationId);
        if (reservation == null) {
            throw new BusinessException("预约不存在");
        }
        if (!reservation.getUserId().equals(userId)) {
            throw new BusinessException("无权操作此预约");
        }
        if (!Reservation.Status.CHECKED_IN.name().equals(reservation.getStatus())) {
            throw new BusinessException("当前状态无法暂离");
        }
        if (reservation.getLeaveCount() >= MAX_LEAVE_COUNT) {
            throw new BusinessException("已达到最大暂离次数: " + MAX_LEAVE_COUNT + " 次");
        }

        LocalDateTime now = LocalDateTime.now();
        reservation.setStatus(Reservation.Status.LEAVING.name());
        reservation.setLeaveTime(now);
        reservation.setLeaveCount(reservation.getLeaveCount() + 1);
        updateById(reservation);

        log.info("用户 {} 暂离, 预约号: {}, 暂离次数: {}", userId, reservation.getReservationNo(), reservation.getLeaveCount());
        return getReservationDetail(reservationId);
    }

    @Transactional
    public ReservationVO returnFromLeave(Long userId, Long reservationId) {
        Reservation reservation = getById(reservationId);
        if (reservation == null) {
            throw new BusinessException("预约不存在");
        }
        if (!reservation.getUserId().equals(userId)) {
            throw new BusinessException("无权操作此预约");
        }
        if (!Reservation.Status.LEAVING.name().equals(reservation.getStatus())) {
            throw new BusinessException("当前状态无法返回");
        }

        LocalDateTime now = LocalDateTime.now();
        long leaveMinutes = ChronoUnit.MINUTES.between(reservation.getLeaveTime(), now);
        if (leaveMinutes > LEAVE_TIMEOUT_MINUTES) {
            throw new BusinessException("暂离超时，预约已自动结束");
        }

        reservation.setStatus(Reservation.Status.CHECKED_IN.name());
        reservation.setReturnTime(now);
        updateById(reservation);

        log.info("用户 {} 暂离返回, 预约号: {}", userId, reservation.getReservationNo());
        return getReservationDetail(reservationId);
    }

    @Transactional
    public ReservationVO cancel(Long userId, Long reservationId, String reason) {
        Reservation reservation = getById(reservationId);
        if (reservation == null) {
            throw new BusinessException("预约不存在");
        }
        if (!reservation.getUserId().equals(userId)) {
            throw new BusinessException("无权操作此预约");
        }
        
        String status = reservation.getStatus();
        if (!Reservation.Status.PENDING.name().equals(status)) {
            throw new BusinessException("当前状态无法取消");
        }

        LocalDateTime now = LocalDateTime.now();
        long minutesBeforeStart = ChronoUnit.MINUTES.between(now, reservation.getStartTime());

        reservation.setStatus(Reservation.Status.CANCELLED.name());
        reservation.setCancelTime(now);
        reservation.setCancelReason(reason);

        if (minutesBeforeStart < FREE_CANCEL_MINUTES && minutesBeforeStart > 0) {
            reservation.setViolationType(Reservation.ViolationType.LATE_CANCEL.name());
            User user = userMapper.selectById(userId);
            if (user != null) {
                user.setCreditScore(Math.max(0, user.getCreditScore() - 5));
                userMapper.updateById(user);
                log.info("用户 {} 迟取消预约，扣除5信用分", userId);
            }
        }

        updateById(reservation);

        log.info("用户 {} 取消预约, 预约号: {}", userId, reservation.getReservationNo());
        return getReservationDetail(reservationId);
    }

    public ReservationVO getReservationDetail(Long reservationId) {
        Reservation reservation = getById(reservationId);
        if (reservation == null) {
            return null;
        }
        
        User user = userMapper.selectById(reservation.getUserId());
        StudyRoom room = studyRoomMapper.selectById(reservation.getRoomId());
        Seat seat = seatMapper.selectById(reservation.getSeatId());
        TimeSlot timeSlot = timeSlotMapper.selectById(reservation.getTimeSlotId());
        
        return buildReservationVO(reservation, user, room, seat, timeSlot);
    }

    public PageResult<ReservationVO> getUserReservations(Long userId, ReservationQueryRequest query) {
        LambdaQueryWrapper<Reservation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Reservation::getUserId, userId);
        
        if (query.getStatus() != null && !query.getStatus().isEmpty()) {
            if ("ACTIVE".equals(query.getStatus())) {
                wrapper.in(Reservation::getStatus, "PENDING", "CHECKED_IN", "LEAVING");
            } else if ("HISTORY".equals(query.getStatus())) {
                wrapper.in(Reservation::getStatus, "COMPLETED", "CANCELLED", "NO_SHOW", "VIOLATION");
            } else {
                wrapper.eq(Reservation::getStatus, query.getStatus());
            }
        }
        
        if (query.getStartDate() != null) {
            wrapper.ge(Reservation::getDate, query.getStartDate());
        }
        if (query.getEndDate() != null) {
            wrapper.le(Reservation::getDate, query.getEndDate());
        }
        
        wrapper.orderByDesc(Reservation::getCreatedAt);

        Page<Reservation> page = new Page<>(query.getPageNum(), query.getPageSize());
        IPage<Reservation> result = page(page, wrapper);

        List<ReservationVO> voList = result.getRecords().stream()
                .map(r -> getReservationDetail(r.getId()))
                .collect(Collectors.toList());

        return PageResult.of((long) query.getPageNum(), (long) query.getPageSize(), result.getTotal(), voList);
    }

    public ReservationVO getCurrentReservation(Long userId) {
        Reservation reservation = reservationMapper.selectCurrentByUserId(userId);
        if (reservation == null) {
            return null;
        }
        return getReservationDetail(reservation.getId());
    }

    public PageResult<ReservationVO> getAdminReservations(ReservationQueryRequest query) {
        LambdaQueryWrapper<Reservation> wrapper = new LambdaQueryWrapper<>();
        
        if (query.getUserId() != null) {
            wrapper.eq(Reservation::getUserId, query.getUserId());
        }
        if (query.getRoomId() != null) {
            wrapper.eq(Reservation::getRoomId, query.getRoomId());
        }
        if (query.getSeatId() != null) {
            wrapper.eq(Reservation::getSeatId, query.getSeatId());
        }
        if (query.getStatus() != null && !query.getStatus().isEmpty()) {
            wrapper.eq(Reservation::getStatus, query.getStatus());
        }
        if (query.getStartDate() != null) {
            wrapper.ge(Reservation::getDate, query.getStartDate());
        }
        if (query.getEndDate() != null) {
            wrapper.le(Reservation::getDate, query.getEndDate());
        }
        
        wrapper.orderByDesc(Reservation::getCreatedAt);

        Page<Reservation> page = new Page<>(query.getPageNum(), query.getPageSize());
        IPage<Reservation> result = page(page, wrapper);

        List<ReservationVO> voList = result.getRecords().stream()
                .map(r -> getReservationDetail(r.getId()))
                .collect(Collectors.toList());

        return PageResult.of((long) query.getPageNum(), (long) query.getPageSize(), result.getTotal(), voList);
    }

    private ReservationVO buildReservationVO(Reservation reservation, User user, 
                                             StudyRoom room, Seat seat, TimeSlot timeSlot) {
        ReservationVO vo = new ReservationVO();
        BeanUtils.copyProperties(reservation, vo);
        
        if (user != null) {
            vo.setUserName(user.getRealName());
            vo.setStudentId(user.getStudentId());
        }
        if (room != null) {
            vo.setRoomName(room.getName());
            vo.setRoomLocation(room.getBuilding() + " " + room.getFloor() + " " + room.getRoomNumber());
        }
        if (seat != null) {
            vo.setSeatNo(seat.getSeatNo());
            vo.setSeatType(seat.getSeatType());
        }
        if (timeSlot != null) {
            vo.setTimeSlotName(timeSlot.getName());
        }
        
        try {
            vo.setStatusText(Reservation.Status.valueOf(reservation.getStatus()).getDescription());
        } catch (Exception e) {
            vo.setStatusText(reservation.getStatus());
        }
        
        LocalDateTime now = LocalDateTime.now();
        String status = reservation.getStatus();
        
        boolean isPending = Reservation.Status.PENDING.name().equals(status);
        boolean isSignedIn = Reservation.Status.CHECKED_IN.name().equals(status);
        boolean isLeaving = Reservation.Status.LEAVING.name().equals(status);
        
        LocalDateTime earliestSignIn = reservation.getStartTime().minusMinutes(SIGN_IN_ADVANCE_MINUTES);
        LocalDateTime latestSignIn = reservation.getStartTime().plusMinutes(SIGN_IN_TIMEOUT_MINUTES);
        vo.setCanSignIn(isPending && now.isAfter(earliestSignIn) && now.isBefore(latestSignIn));
        
        vo.setCanSignOut(isSignedIn || isLeaving);
        vo.setCanLeave(isSignedIn && reservation.getLeaveCount() < MAX_LEAVE_COUNT);
        vo.setCanReturn(isLeaving);
        vo.setCanCancel(isPending);
        
        if (isPending) {
            vo.setRemainingMinutes(ChronoUnit.MINUTES.between(now, reservation.getStartTime()));
        } else if (isSignedIn || isLeaving) {
            vo.setRemainingMinutes(ChronoUnit.MINUTES.between(now, reservation.getEndTime()));
        }
        
        return vo;
    }

    /**
     * 管理员取消预约
     */
    @Transactional
    public void adminCancelReservation(Long reservationId, String reason) {
        Reservation reservation = reservationMapper.selectById(reservationId);
        if (reservation == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "预约不存在");
        }
        
        String status = reservation.getStatus();
        if (!Reservation.Status.PENDING.name().equals(status)) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "只能取消待签到的预约");
        }
        
        reservation.setStatus(Reservation.Status.CANCELLED.name());
        reservation.setRemark(reason != null ? "管理员取消: " + reason : "管理员取消");
        reservationMapper.updateById(reservation);
        
        log.info("管理员取消预约: reservationId={}, reason={}", reservationId, reason);
    }

    /**
     * 管理员强制签退
     */
    @Transactional
    public void adminForceSignOut(Long reservationId) {
        Reservation reservation = reservationMapper.selectById(reservationId);
        if (reservation == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "预约不存在");
        }
        
        String status = reservation.getStatus();
        if (!Reservation.Status.CHECKED_IN.name().equals(status) && !Reservation.Status.LEAVING.name().equals(status)) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "只能签退使用中或暂离的预约");
        }
        
        LocalDateTime now = LocalDateTime.now();
        reservation.setStatus(Reservation.Status.COMPLETED.name());
        reservation.setSignOutTime(now);
        
        // 计算实际使用时长
        if (reservation.getSignInTime() != null) {
            long minutes = ChronoUnit.MINUTES.between(reservation.getSignInTime(), now);
            reservation.setActualDuration((int) minutes);
            
            // 计算积分（每小时10积分）
            int points = (int) (minutes / 60) * POINTS_PER_HOUR;
            reservation.setEarnedPoints(points);
            
            // 更新用户学习时长和积分
            User user = userMapper.selectById(reservation.getUserId());
            if (user != null) {
                user.setTotalStudyTime((user.getTotalStudyTime() != null ? user.getTotalStudyTime() : 0) + (int) minutes);
                user.setTotalPoints((user.getTotalPoints() != null ? user.getTotalPoints() : 0) + points);
                userMapper.updateById(user);
            }
        }
        
        reservation.setRemark("管理员强制签退");
        reservationMapper.updateById(reservation);
        
        log.info("管理员强制签退: reservationId={}", reservationId);
    }
}
