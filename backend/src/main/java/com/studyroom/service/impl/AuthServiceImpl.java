package com.studyroom.service.impl;

import com.studyroom.common.ResultCode;
import com.studyroom.dto.*;
import com.studyroom.entity.User;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.UserMapper;
import com.studyroom.service.AuthService;
import com.studyroom.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.TimeUnit;

/**
 * 认证服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final RedisTemplate<String, Object> redisTemplate;

    @Value("${jwt.expiration}")
    private Long expiration;

    @Value("${jwt.refresh-expiration}")
    private Long refreshExpiration;

    private static final String TOKEN_BLACKLIST_PREFIX = "token:blacklist:";

    @Override
    public LoginResponse login(LoginRequest request) {
        // 查找用户（支持用户名或学号登录）
        User user = userMapper.findByUsername(request.getUsername());
        if (user == null) {
            user = userMapper.findByStudentId(request.getUsername());
        }
        
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }

        // 检查账号状态
        if (user.getStatus() == 0) {
            throw new BusinessException(ResultCode.ACCOUNT_DISABLED);
        }

        // 检查是否在黑名单中
        if (user.isInBlacklist()) {
            throw new BusinessException(ResultCode.IN_BLACKLIST, 
                    "您已被加入黑名单，解封时间：" + user.getBlacklistEndTime());
        }

        // 验证密码
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException(ResultCode.PASSWORD_ERROR);
        }

        // 生成Token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        String refreshToken = jwtUtil.generateRefreshToken(user.getId());

        log.info("用户登录成功: {} ({})", user.getUsername(), user.getRole());

        return LoginResponse.builder()
                .token(token)
                .refreshToken(refreshToken)
                .expiresIn(expiration)
                .user(LoginResponse.UserVO.fromUser(user))
                .build();
    }

    @Override
    @Transactional
    public Long register(RegisterRequest request) {
        // 检查用户名是否存在
        if (userMapper.countByUsername(request.getUsername()) > 0) {
            throw new BusinessException(ResultCode.USER_EXISTS, "用户名已存在");
        }

        // 检查学号是否存在
        if (userMapper.countByStudentId(request.getStudentId()) > 0) {
            throw new BusinessException(ResultCode.STUDENT_ID_EXISTS);
        }

        // 检查邮箱是否存在
        if (request.getEmail() != null && !request.getEmail().isEmpty()) {
            User existUser = userMapper.findByEmail(request.getEmail());
            if (existUser != null) {
                throw new BusinessException(ResultCode.EMAIL_EXISTS);
            }
        }

        // 检查手机号是否存在
        if (request.getPhone() != null && !request.getPhone().isEmpty()) {
            User existUser = userMapper.findByPhone(request.getPhone());
            if (existUser != null) {
                throw new BusinessException(ResultCode.PHONE_EXISTS);
            }
        }

        // 创建用户
        User user = User.builder()
                .username(request.getUsername())
                .password(passwordEncoder.encode(request.getPassword()))
                .studentId(request.getStudentId())
                .realName(request.getRealName())
                .email(request.getEmail())
                .phone(request.getPhone())
                .gender(request.getGender() != null ? request.getGender() : 0)
                .college(request.getCollege())
                .major(request.getMajor())
                .grade(request.getGrade())
                .classNo(request.getClassNo())
                .role("STUDENT")
                .creditScore(100)  // 初始信用分
                .totalStudyTime(0)
                .totalPoints(0)
                .consecutiveDays(0)
                .totalCheckIns(0)
                .currentStreak(0)
                .maxStreak(0)
                .status(1)  // 正常状态
                .build();

        userMapper.insert(user);
        
        log.info("用户注册成功: {} ({})", user.getUsername(), user.getStudentId());

        return user.getId();
    }

    @Override
    public LoginResponse refreshToken(String refreshToken) {
        // 验证刷新Token
        if (!jwtUtil.validateToken(refreshToken)) {
            throw new BusinessException(ResultCode.TOKEN_INVALID);
        }

        // 检查Token是否在黑名单中
        String blacklistKey = TOKEN_BLACKLIST_PREFIX + refreshToken;
        if (Boolean.TRUE.equals(redisTemplate.hasKey(blacklistKey))) {
            throw new BusinessException(ResultCode.TOKEN_INVALID, "Token已失效");
        }

        // 获取用户ID
        Long userId = jwtUtil.getUserIdFromToken(refreshToken);
        if (userId == null) {
            throw new BusinessException(ResultCode.TOKEN_INVALID);
        }

        // 查找用户
        User user = userMapper.selectById(userId);
        if (user == null || user.getStatus() == 0) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }

        // 将旧的刷新Token加入黑名单
        redisTemplate.opsForValue().set(blacklistKey, "1", refreshExpiration, TimeUnit.MILLISECONDS);

        // 生成新Token
        String newToken = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        String newRefreshToken = jwtUtil.generateRefreshToken(user.getId());

        return LoginResponse.builder()
                .token(newToken)
                .refreshToken(newRefreshToken)
                .expiresIn(expiration)
                .user(LoginResponse.UserVO.fromUser(user))
                .build();
    }

    @Override
    public void logout(Long userId) {
        // 这里可以将用户的Token加入黑名单
        // 由于JWT是无状态的，登出主要依赖前端删除Token
        log.info("用户登出: {}", userId);
    }
}
