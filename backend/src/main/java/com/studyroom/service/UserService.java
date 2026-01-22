package com.studyroom.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.dto.UpdatePasswordRequest;
import com.studyroom.dto.UpdateProfileRequest;
import com.studyroom.entity.User;

/**
 * 用户服务接口
 */
public interface UserService {

    /**
     * 根据ID获取用户
     */
    User getUserById(Long userId);

    /**
     * 根据用户名获取用户
     */
    User getUserByUsername(String username);

    /**
     * 获取当前登录用户信息
     */
    User getCurrentUser();

    /**
     * 更新个人信息
     */
    User updateProfile(Long userId, UpdateProfileRequest request);

    /**
     * 修改密码
     */
    void updatePassword(Long userId, UpdatePasswordRequest request);

    /**
     * 更新头像
     */
    String updateAvatar(Long userId, String avatarUrl);

    /**
     * 更新信用分
     */
    void updateCreditScore(Long userId, int delta, String reason);

    /**
     * 更新学习时长
     */
    void addStudyTime(Long userId, int minutes);

    /**
     * 更新积分
     */
    void addPoints(Long userId, int points, String reason);

    /**
     * 用户签到
     */
    void checkIn(Long userId);

    /**
     * 分页查询用户列表（管理员）
     */
    Page<User> getUserList(int page, int size, String keyword, String role, Integer status);

    /**
     * 禁用/启用用户
     */
    void updateUserStatus(Long userId, Integer status);

    /**
     * 将用户加入黑名单
     */
    void addToBlacklist(Long userId, int days, String reason);

    /**
     * 将用户移出黑名单
     */
    void removeFromBlacklist(Long userId);
}
