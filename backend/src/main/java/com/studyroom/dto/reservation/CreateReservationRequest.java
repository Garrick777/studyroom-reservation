package com.studyroom.dto.reservation;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.time.LocalDate;

@Data
public class CreateReservationRequest {
    
    @NotNull(message = "自习室ID不能为空")
    private Long roomId;
    
    @NotNull(message = "座位ID不能为空")
    private Long seatId;
    
    @NotNull(message = "预约日期不能为空")
    private LocalDate date;
    
    @NotNull(message = "时段ID不能为空")
    private Long timeSlotId;
    
    private String remark;
    
    private String source = "WEB";
}
