package com.studyroom.dto;

import lombok.Data;

/**
 * 更新自习室请求
 */
@Data
public class RoomUpdateRequest {
    
    private String name;
    private String code;
    private String building;
    private String floor;
    private String roomNumber;
    private Integer capacity;
    private String description;
    private String facilities;
    private String openTime;
    private String closeTime;
    private Integer rowCount;
    private Integer colCount;
    private String coverImage;
    private Integer status;
}
