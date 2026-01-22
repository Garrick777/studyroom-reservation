package com.studyroom.dto.reservation;

import lombok.Data;
import java.time.LocalDate;

@Data
public class ReservationQueryRequest {
    private Long userId;
    private Long roomId;
    private Long seatId;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
    private String keyword;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
