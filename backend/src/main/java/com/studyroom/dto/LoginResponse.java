package com.studyroom.dto;

import com.studyroom.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 登录响应DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {

    /**
     * 访问Token
     */
    private String token;

    /**
     * 刷新Token
     */
    private String refreshToken;

    /**
     * Token过期时间(毫秒)
     */
    private Long expiresIn;

    /**
     * 用户信息
     */
    private UserVO user;

    /**
     * 用户VO（隐藏敏感信息）
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserVO {
        private Long id;
        private String username;
        private String studentId;
        private String realName;
        private String email;
        private String phone;
        private String avatar;
        private String role;
        private Integer gender;
        private String college;
        private String major;
        private String grade;
        private String classNo;
        private Integer creditScore;
        private Integer totalStudyTime;
        private Integer totalPoints;
        private Integer consecutiveDays;
        private Integer totalCheckIns;
        private Integer status;

        /**
         * 从User实体转换
         */
        public static UserVO fromUser(User user) {
            if (user == null) {
                return null;
            }
            return UserVO.builder()
                    .id(user.getId())
                    .username(user.getUsername())
                    .studentId(user.getStudentId())
                    .realName(user.getRealName())
                    .email(user.getEmail())
                    .phone(user.getPhone())
                    .avatar(user.getAvatar())
                    .role(user.getRole())
                    .gender(user.getGender())
                    .college(user.getCollege())
                    .major(user.getMajor())
                    .grade(user.getGrade())
                    .classNo(user.getClassNo())
                    .creditScore(user.getCreditScore())
                    .totalStudyTime(user.getTotalStudyTime())
                    .totalPoints(user.getTotalPoints())
                    .consecutiveDays(user.getConsecutiveDays())
                    .totalCheckIns(user.getTotalCheckIns())
                    .status(user.getStatus())
                    .build();
        }
    }
}
