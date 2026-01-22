package com.studyroom.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 创建自习室请求
 */
@Data
public class RoomCreateRequest {
    
    @NotBlank(message = "自习室名称不能为空")
    private String name;
    
    @NotBlank(message = "自习室编号不能为空")
    private String code;
    
    @NotBlank(message = "建筑名称不能为空")
    private String building;
    
    @NotBlank(message = "楼层不能为空")
    private String floor;
    
    private String roomNumber;
    
    @NotNull(message = "容量不能为空")
    private Integer capacity;
    
    private String description;
    
    /** 设施JSON，如：["空调", "WiFi", "电源"] */
    private String facilities;
    
    @NotBlank(message = "开放时间不能为空")
    private String openTime;
    
    @NotBlank(message = "关闭时间不能为空")
    private String closeTime;
    
    /** 座位行数 */
    private Integer rowCount;
    
    /** 座位列数 */
    private Integer colCount;
    
    /** 封面图片 */
    private String coverImage;
}
