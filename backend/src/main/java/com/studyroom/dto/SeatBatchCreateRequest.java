package com.studyroom.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 批量创建座位请求
 */
@Data
public class SeatBatchCreateRequest {
    
    @NotNull(message = "行数不能为空")
    @Min(value = 1, message = "行数最小为1")
    @Max(value = 50, message = "行数最大为50")
    private Integer rowCount;
    
    @NotNull(message = "列数不能为空")
    @Min(value = 1, message = "列数最小为1")
    @Max(value = 50, message = "列数最大为50")
    private Integer colCount;
    
    /** 是否清除原有座位 */
    private boolean clearExisting = true;
}
