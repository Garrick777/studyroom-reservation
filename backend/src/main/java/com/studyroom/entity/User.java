package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 用户实体类
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("user")
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户名
     */
    @NotBlank(message = "用户名不能为空")
    @Size(min = 4, max = 20, message = "用户名长度为4-20位")
    private String username;

    /**
     * 密码
     */
    @JsonIgnore
    @NotBlank(message = "密码不能为空")
    private String password;

    /**
     * 学号
     */
    @NotBlank(message = "学号不能为空")
    @Pattern(regexp = "^\\d{8,12}$", message = "学号格式不正确")
    private String studentId;

    /**
     * 真实姓名
     */
    @NotBlank(message = "姓名不能为空")
    @Size(min = 2, max = 20, message = "姓名长度为2-20位")
    private String realName;

    /**
     * 邮箱
     */
    @Email(message = "邮箱格式不正确")
    private String email;

    /**
     * 手机号
     */
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    /**
     * 头像URL
     */
    private String avatar;

    /**
     * 角色: STUDENT, ADMIN, SUPER_ADMIN
     */
    private String role;

    /**
     * 性别: 0-未知, 1-男, 2-女
     */
    private Integer gender;

    /**
     * 学院
     */
    private String college;

    /**
     * 专业
     */
    private String major;

    /**
     * 年级
     */
    private String grade;

    /**
     * 班级
     */
    private String classNo;

    /**
     * 信用分
     */
    private Integer creditScore;

    /**
     * 总学习时长(分钟)
     */
    private Integer totalStudyTime;

    /**
     * 总积分
     */
    private Integer totalPoints;

    /**
     * 连续签到天数
     */
    private Integer consecutiveDays;

    /**
     * 总签到天数
     */
    private Integer totalCheckIns;

    /**
     * 经验值
     */
    private Integer exp;

    /**
     * 当前连续学习天数
     */
    private Integer currentStreak;

    /**
     * 最长连续学习天数
     */
    private Integer maxStreak;

    /**
     * 上次签到日期
     */
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDateTime lastCheckInDate;

    /**
     * 今日学习时长(分钟)
     */
    @TableField(exist = false)
    private Integer todayStudyTime;

    /**
     * 状态: 0-禁用, 1-正常, 2-黑名单
     */
    private Integer status;

    /**
     * 黑名单结束时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime blacklistEndTime;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /**
     * 逻辑删除
     */
    @TableLogic
    @JsonIgnore
    private Integer deleted;

    /**
     * 检查是否在黑名单中
     */
    public boolean isInBlacklist() {
        if (status != 2) {
            return false;
        }
        if (blacklistEndTime == null) {
            return false;
        }
        return LocalDateTime.now().isBefore(blacklistEndTime);
    }
}
