package com.studyroom.dto.reservation;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class ReservationVO {
    private Long id;
    private String reservationNo;
    private Long userId;
    private String userName;
    private String studentId;
    private Long roomId;
    private String roomName;
    private String roomLocation;
    private Long seatId;
    private String seatNo;
    private String seatType;
    
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;
    
    private Long timeSlotId;
    private String timeSlotName;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;
    
    private String status;
    private String statusText;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime signInTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime signOutTime;
    
    private Integer actualDuration;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime leaveTime;
    
    private Integer leaveCount;
    private String violationType;
    private Integer earnedPoints;
    private Integer earnedExp;
    private String remark;
    private String source;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    // 计算属性
    private Boolean canSignIn;     // 能否签到
    private Boolean canSignOut;    // 能否签退
    private Boolean canLeave;      // 能否暂离
    private Boolean canReturn;     // 能否返回
    private Boolean canCancel;     // 能否取消
    private Long remainingMinutes; // 距离开始/结束的剩余时间
}
