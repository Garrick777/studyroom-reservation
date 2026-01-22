package com.studyroom.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.common.ResultCode;
import com.studyroom.dto.UpdatePasswordRequest;
import com.studyroom.dto.UpdateProfileRequest;
import com.studyroom.entity.User;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.UserMapper;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 用户服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    @Override
    public User getUserById(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        return user;
    }

    @Override
    public User getUserByUsername(String username) {
        User user = userMapper.findByUsername(username);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        return user;
    }

    @Override
    public User getCurrentUser() {
        Long userId = SecurityUtil.getCurrentUserId();
        if (userId == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        return getUserById(userId);
    }

    @Override
    @Transactional
    public User updateProfile(Long userId, UpdateProfileRequest request) {
        User user = getUserById(userId);

        // 检查邮箱是否被其他用户使用
        if (StringUtils.hasText(request.getEmail()) && !request.getEmail().equals(user.getEmail())) {
            User existUser = userMapper.findByEmail(request.getEmail());
            if (existUser != null && !existUser.getId().equals(userId)) {
                throw new BusinessException(ResultCode.EMAIL_EXISTS);
            }
            user.setEmail(request.getEmail());
        }

        // 检查手机号是否被其他用户使用
        if (StringUtils.hasText(request.getPhone()) && !request.getPhone().equals(user.getPhone())) {
            User existUser = userMapper.findByPhone(request.getPhone());
            if (existUser != null && !existUser.getId().equals(userId)) {
                throw new BusinessException(ResultCode.PHONE_EXISTS);
            }
            user.setPhone(request.getPhone());
        }

        // 更新其他字段
        if (StringUtils.hasText(request.getRealName())) {
            user.setRealName(request.getRealName());
        }
        if (StringUtils.hasText(request.getAvatar())) {
            user.setAvatar(request.getAvatar());
        }
        if (request.getGender() != null) {
            user.setGender(request.getGender());
        }
        if (StringUtils.hasText(request.getCollege())) {
            user.setCollege(request.getCollege());
        }
        if (StringUtils.hasText(request.getMajor())) {
            user.setMajor(request.getMajor());
        }
        if (StringUtils.hasText(request.getGrade())) {
            user.setGrade(request.getGrade());
        }
        if (StringUtils.hasText(request.getClassNo())) {
            user.setClassNo(request.getClassNo());
        }

        userMapper.updateById(user);
        log.info("用户更新个人信息: {}", userId);
        
        return user;
    }

    @Override
    @Transactional
    public void updatePassword(Long userId, UpdatePasswordRequest request) {
        User user = getUserById(userId);

        // 验证旧密码
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new BusinessException(ResultCode.OLD_PASSWORD_ERROR);
        }

        // 更新密码
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userMapper.updateById(user);
        
        log.info("用户修改密码: {}", userId);
    }

    @Override
    @Transactional
    public String updateAvatar(Long userId, String avatarUrl) {
        User user = getUserById(userId);
        user.setAvatar(avatarUrl);
        userMapper.updateById(user);
        log.info("用户更新头像: {}", userId);
        return avatarUrl;
    }

    @Override
    @Transactional
    public void updateCreditScore(Long userId, int delta, String reason) {
        User user = getUserById(userId);
        int newScore = user.getCreditScore() + delta;
        // 信用分范围限制在0-100
        newScore = Math.max(0, Math.min(100, newScore));
        user.setCreditScore(newScore);
        
        // 如果信用分低于60，自动加入黑名单7天
        if (newScore < 60 && user.getStatus() != 2) {
            addToBlacklist(userId, 7, "信用分过低自动加入黑名单");
        }
        
        userMapper.updateById(user);
        log.info("用户信用分变更: {} {} {} ({})", userId, delta > 0 ? "+" : "", delta, reason);
    }

    @Override
    @Transactional
    public void addStudyTime(Long userId, int minutes) {
        User user = getUserById(userId);
        user.setTotalStudyTime(user.getTotalStudyTime() + minutes);
        userMapper.updateById(user);
        log.info("用户学习时长增加: {} +{}分钟", userId, minutes);
    }

    @Override
    @Transactional
    public void addPoints(Long userId, int points, String reason) {
        User user = getUserById(userId);
        user.setTotalPoints(user.getTotalPoints() + points);
        userMapper.updateById(user);
        log.info("用户积分变更: {} +{} ({})", userId, points, reason);
    }

    @Override
    @Transactional
    public void checkIn(Long userId) {
        User user = getUserById(userId);
        LocalDate today = LocalDate.now();
        LocalDate lastCheckIn = user.getLastCheckInDate() != null 
                ? user.getLastCheckInDate().toLocalDate() 
                : null;

        // 检查是否已经签到
        if (lastCheckIn != null && lastCheckIn.equals(today)) {
            throw new BusinessException("今天已经签到过了");
        }

        // 更新签到信息
        user.setTotalCheckIns(user.getTotalCheckIns() + 1);
        user.setLastCheckInDate(LocalDateTime.now());

        // 检查是否连续签到
        if (lastCheckIn != null && lastCheckIn.equals(today.minusDays(1))) {
            user.setConsecutiveDays(user.getConsecutiveDays() + 1);
            user.setCurrentStreak(user.getCurrentStreak() + 1);
        } else {
            user.setConsecutiveDays(1);
            user.setCurrentStreak(1);
        }

        // 更新最长连续签到天数
        if (user.getCurrentStreak() > user.getMaxStreak()) {
            user.setMaxStreak(user.getCurrentStreak());
        }

        userMapper.updateById(user);
        log.info("用户签到: {} 连续{}天", userId, user.getConsecutiveDays());
    }

    @Override
    public Page<User> getUserList(int page, int size, String keyword, String role, Integer status) {
        Page<User> pageParam = new Page<>(page, size);
        
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        
        // 关键词搜索（用户名、学号、姓名）
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                    .like(User::getUsername, keyword)
                    .or().like(User::getStudentId, keyword)
                    .or().like(User::getRealName, keyword)
            );
        }
        
        // 角色筛选
        if (StringUtils.hasText(role)) {
            wrapper.eq(User::getRole, role);
        }
        
        // 状态筛选
        if (status != null) {
            wrapper.eq(User::getStatus, status);
        }
        
        wrapper.orderByDesc(User::getCreateTime);
        
        return userMapper.selectPage(pageParam, wrapper);
    }

    @Override
    @Transactional
    public void updateUserStatus(Long userId, Integer status) {
        User user = getUserById(userId);
        user.setStatus(status);
        userMapper.updateById(user);
        log.info("用户状态变更: {} -> {}", userId, status);
    }

    @Override
    @Transactional
    public void addToBlacklist(Long userId, int days, String reason) {
        User user = getUserById(userId);
        user.setStatus(2);  // 黑名单状态
        user.setBlacklistEndTime(LocalDateTime.now().plusDays(days));
        userMapper.updateById(user);
        log.info("用户加入黑名单: {} {}天 ({})", userId, days, reason);
    }

    @Override
    @Transactional
    public void removeFromBlacklist(Long userId) {
        User user = getUserById(userId);
        user.setStatus(1);  // 正常状态
        user.setBlacklistEndTime(null);
        userMapper.updateById(user);
        log.info("用户移出黑名单: {}", userId);
    }
}
