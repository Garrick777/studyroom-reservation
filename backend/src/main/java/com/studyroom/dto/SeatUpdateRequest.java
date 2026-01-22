package com.studyroom.dto;

import lombok.Data;

/**
 * 更新座位请求
 */
@Data
public class SeatUpdateRequest {
    
    private String seatNo;
    
    /** 座位类型: NORMAL普通 WINDOW靠窗 POWER带电源 VIP贵宾 */
    private Integer seatType;
    
    /** 状态: 0不可用 1可用 2维修中 */
    private Integer status;
    
    /** 备注 */
    private String remark;
}
