package com.studyroom.task;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.studyroom.entity.Reservation;
import com.studyroom.entity.User;
import com.studyroom.mapper.ReservationMapper;
import com.studyroom.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class ReservationScheduleTask {

    private final ReservationMapper reservationMapper;
    private final UserMapper userMapper;

    private static final int SIGN_IN_TIMEOUT_MINUTES = 15;
    private static final int LEAVE_TIMEOUT_MINUTES = 30;
    private static final int NO_SHOW_DEDUCT_SCORE = 10;
    private static final int LEAVE_TIMEOUT_DEDUCT_SCORE = 5;

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void handleNoShowReservations() {
        LocalDateTime now = LocalDateTime.now();
        List<Reservation> timeoutList = reservationMapper.selectPendingTimeout(now, SIGN_IN_TIMEOUT_MINUTES);
        
        for (Reservation reservation : timeoutList) {
            try {
                reservation.setStatus(Reservation.Status.NO_SHOW.name());
                reservation.setViolationType(Reservation.ViolationType.NO_SHOW.name());
                reservationMapper.updateById(reservation);
                
                User user = userMapper.selectById(reservation.getUserId());
                if (user != null) {
                    user.setCreditScore(Math.max(0, user.getCreditScore() - NO_SHOW_DEDUCT_SCORE));
                    userMapper.updateById(user);
                    log.info("用户 {} 预约超时未签到，已扣除 {} 信用分", user.getId(), NO_SHOW_DEDUCT_SCORE);
                }
                
                log.info("预约 {} 已标记为未签到(爽约)", reservation.getReservationNo());
            } catch (Exception e) {
                log.error("处理超时预约失败: {}", reservation.getReservationNo(), e);
            }
        }
        
        if (!timeoutList.isEmpty()) {
            log.info("处理完成 {} 条超时未签到预约", timeoutList.size());
        }
    }

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void handleLeaveTimeoutReservations() {
        LocalDateTime now = LocalDateTime.now();
        List<Reservation> timeoutList = reservationMapper.selectLeavingTimeout(now, LEAVE_TIMEOUT_MINUTES);
        
        for (Reservation reservation : timeoutList) {
            try {
                long actualMinutes = Duration.between(
                    reservation.getSignInTime(), reservation.getLeaveTime()
                ).toMinutes();
                
                reservation.setStatus(Reservation.Status.VIOLATION.name());
                reservation.setViolationType(Reservation.ViolationType.LEAVE_TIMEOUT.name());
                reservation.setSignOutTime(now);
                reservation.setActualDuration((int) actualMinutes);
                reservationMapper.updateById(reservation);
                
                User user = userMapper.selectById(reservation.getUserId());
                if (user != null) {
                    user.setCreditScore(Math.max(0, user.getCreditScore() - LEAVE_TIMEOUT_DEDUCT_SCORE));
                    userMapper.updateById(user);
                    log.info("用户 {} 暂离超时，已扣除 {} 信用分", user.getId(), LEAVE_TIMEOUT_DEDUCT_SCORE);
                }
                
                log.info("预约 {} 暂离超时，已标记为违约", reservation.getReservationNo());
            } catch (Exception e) {
                log.error("处理暂离超时预约失败: {}", reservation.getReservationNo(), e);
            }
        }
        
        if (!timeoutList.isEmpty()) {
            log.info("处理完成 {} 条暂离超时预约", timeoutList.size());
        }
    }

    @Scheduled(fixedRate = 300000)
    @Transactional
    public void handleExpiredReservations() {
        LocalDateTime now = LocalDateTime.now();
        
        LambdaQueryWrapper<Reservation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Reservation::getStatus, Reservation.Status.SIGNED_IN.name())
               .lt(Reservation::getEndTime, now);
        
        List<Reservation> expiredList = reservationMapper.selectList(wrapper);
        
        for (Reservation reservation : expiredList) {
            try {
                long actualMinutes = Duration.between(
                    reservation.getSignInTime(), reservation.getEndTime()
                ).toMinutes();
                
                int hours = (int) Math.max(1, actualMinutes / 60);
                int earnedPoints = hours * 10;
                int earnedExp = hours * 5;
                
                reservation.setStatus(Reservation.Status.COMPLETED.name());
                reservation.setSignOutTime(reservation.getEndTime());
                reservation.setActualDuration((int) actualMinutes);
                reservation.setEarnedPoints(earnedPoints);
                reservation.setEarnedExp(earnedExp);
                reservationMapper.updateById(reservation);
                
                User user = userMapper.selectById(reservation.getUserId());
                if (user != null) {
                    user.setTotalStudyTime((user.getTotalStudyTime() != null ? user.getTotalStudyTime() : 0) + (int) actualMinutes);
                    user.setTotalPoints((user.getTotalPoints() != null ? user.getTotalPoints() : 0) + earnedPoints);
                    userMapper.updateById(user);
                }
                
                log.info("预约 {} 已自动完成，学习时长: {} 分钟", reservation.getReservationNo(), actualMinutes);
            } catch (Exception e) {
                log.error("处理过期预约失败: {}", reservation.getReservationNo(), e);
            }
        }
        
        if (!expiredList.isEmpty()) {
            log.info("自动完成 {} 条过期预约", expiredList.size());
        }
    }
}
