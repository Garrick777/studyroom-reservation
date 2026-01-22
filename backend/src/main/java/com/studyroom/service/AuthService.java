package com.studyroom.service;

import com.studyroom.dto.*;

/**
 * 认证服务接口
 */
public interface AuthService {

    /**
     * 用户登录
     * @param request 登录请求
     * @return 登录响应（包含Token和用户信息）
     */
    LoginResponse login(LoginRequest request);

    /**
     * 用户注册
     * @param request 注册请求
     * @return 用户ID
     */
    Long register(RegisterRequest request);

    /**
     * 刷新Token
     * @param refreshToken 刷新Token
     * @return 新的登录响应
     */
    LoginResponse refreshToken(String refreshToken);

    /**
     * 登出
     * @param userId 用户ID
     */
    void logout(Long userId);
}
