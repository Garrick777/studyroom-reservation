package com.studyroom.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.studyroom.dto.reservation.CreateReviewRequest;
import com.studyroom.entity.Reservation;
import com.studyroom.entity.SeatReview;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.ReservationMapper;
import com.studyroom.mapper.SeatReviewMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class SeatReviewService extends ServiceImpl<SeatReviewMapper, SeatReview> {

    private final SeatReviewMapper seatReviewMapper;
    private final ReservationMapper reservationMapper;

    @Transactional
    public SeatReview createReview(Long userId, CreateReviewRequest request) {
        // 验证预约
        Reservation reservation = reservationMapper.selectById(request.getReservationId());
        if (reservation == null) {
            throw new BusinessException("预约不存在");
        }
        if (!reservation.getUserId().equals(userId)) {
            throw new BusinessException("无权评价此预约");
        }
        if (!Reservation.Status.COMPLETED.name().equals(reservation.getStatus())) {
            throw new BusinessException("只能评价已完成的预约");
        }
        
        // 检查是否已评价
        int count = seatReviewMapper.countByReservationId(request.getReservationId());
        if (count > 0) {
            throw new BusinessException("该预约已评价过");
        }

        SeatReview review = SeatReview.builder()
                .userId(userId)
                .seatId(reservation.getSeatId())
                .reservationId(request.getReservationId())
                .rating(request.getRating())
                .content(request.getContent())
                .tags(request.getTags())
                .build();

        save(review);
        log.info("用户 {} 对座位 {} 进行了评价，评分: {}", userId, reservation.getSeatId(), request.getRating());
        
        return review;
    }

    public List<SeatReview> getSeatReviews(Long seatId, int limit) {
        return seatReviewMapper.selectBySeatId(seatId, limit);
    }

    public Double getSeatAverageRating(Long seatId) {
        Double rating = seatReviewMapper.getAverageRating(seatId);
        return rating != null ? Math.round(rating * 10) / 10.0 : null;
    }
}
