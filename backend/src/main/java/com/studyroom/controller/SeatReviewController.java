package com.studyroom.controller;

import com.studyroom.common.Result;
import com.studyroom.dto.reservation.CreateReviewRequest;
import com.studyroom.entity.SeatReview;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.SeatReviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Tag(name = "座位评价", description = "座位评价相关接口")
@RestController
@RequiredArgsConstructor
public class SeatReviewController {

    private final SeatReviewService seatReviewService;

    @Operation(summary = "提交评价")
    @PostMapping("/reservations/{id}/review")
    public Result<SeatReview> createReview(@PathVariable Long id, 
                                           @Valid @RequestBody CreateReviewRequest request) {
        request.setReservationId(id);
        Long userId = SecurityUtil.getCurrentUserId();
        SeatReview review = seatReviewService.createReview(userId, request);
        return Result.success(review);
    }

    @Operation(summary = "获取座位评价列表")
    @GetMapping("/seats/{seatId}/reviews")
    public Result<Map<String, Object>> getSeatReviews(
            @PathVariable Long seatId,
            @RequestParam(defaultValue = "10") int limit) {
        List<SeatReview> reviews = seatReviewService.getSeatReviews(seatId, limit);
        Double averageRating = seatReviewService.getSeatAverageRating(seatId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("reviews", reviews);
        result.put("averageRating", averageRating);
        result.put("totalCount", reviews.size());
        
        return Result.success(result);
    }
}
