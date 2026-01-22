package com.studyroom.dto.reservation;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class CreateReviewRequest {
    
    @NotNull(message = "预约ID不能为空")
    private Long reservationId;
    
    @NotNull(message = "评分不能为空")
    @Min(value = 1, message = "评分最低为1")
    @Max(value = 5, message = "评分最高为5")
    private Integer rating;
    
    private String content;
    
    private String tags;
}
