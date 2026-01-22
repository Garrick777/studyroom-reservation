package com.studyroom.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * 缓存服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CacheService {

    private final RedisTemplate<String, Object> redisTemplate;

    // ========== 缓存Key前缀 ==========
    public static final String USER_KEY = "user:";
    public static final String ROOM_KEY = "room:";
    public static final String SEAT_STATUS_KEY = "seat:status:";
    public static final String RANKING_KEY = "ranking:";
    public static final String TOKEN_KEY = "token:";
    public static final String VERIFICATION_CODE_KEY = "verify:";

    /**
     * 设置缓存
     */
    public void set(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    /**
     * 设置缓存（带过期时间）
     */
    public void set(String key, Object value, long timeout, TimeUnit unit) {
        redisTemplate.opsForValue().set(key, value, timeout, unit);
    }

    /**
     * 获取缓存
     */
    @SuppressWarnings("unchecked")
    public <T> T get(String key) {
        return (T) redisTemplate.opsForValue().get(key);
    }

    /**
     * 删除缓存
     */
    public Boolean delete(String key) {
        return redisTemplate.delete(key);
    }

    /**
     * 批量删除缓存
     */
    public Long deleteByPattern(String pattern) {
        Set<String> keys = redisTemplate.keys(pattern);
        if (keys != null && !keys.isEmpty()) {
            return redisTemplate.delete(keys);
        }
        return 0L;
    }

    /**
     * 判断key是否存在
     */
    public Boolean hasKey(String key) {
        return redisTemplate.hasKey(key);
    }

    /**
     * 设置过期时间
     */
    public Boolean expire(String key, long timeout, TimeUnit unit) {
        return redisTemplate.expire(key, timeout, unit);
    }

    /**
     * 获取过期时间
     */
    public Long getExpire(String key) {
        return redisTemplate.getExpire(key);
    }

    /**
     * 递增
     */
    public Long increment(String key, long delta) {
        return redisTemplate.opsForValue().increment(key, delta);
    }

    /**
     * 递减
     */
    public Long decrement(String key, long delta) {
        return redisTemplate.opsForValue().decrement(key, delta);
    }

    // ========== 用户缓存操作 ==========

    /**
     * 缓存用户信息
     */
    public void cacheUser(Long userId, Object user) {
        set(USER_KEY + userId, user, 1, TimeUnit.HOURS);
    }

    /**
     * 获取用户缓存
     */
    public <T> T getUser(Long userId) {
        return get(USER_KEY + userId);
    }

    /**
     * 删除用户缓存
     */
    public void deleteUser(Long userId) {
        delete(USER_KEY + userId);
    }

    // ========== 自习室缓存操作 ==========

    /**
     * 缓存自习室信息
     */
    public void cacheRoom(Long roomId, Object room) {
        set(ROOM_KEY + roomId, room, 10, TimeUnit.MINUTES);
    }

    /**
     * 获取自习室缓存
     */
    public <T> T getRoom(Long roomId) {
        return get(ROOM_KEY + roomId);
    }

    /**
     * 删除自习室缓存
     */
    public void deleteRoom(Long roomId) {
        delete(ROOM_KEY + roomId);
    }

    /**
     * 清除所有自习室缓存
     */
    public void clearRoomCache() {
        deleteByPattern(ROOM_KEY + "*");
    }

    // ========== 座位状态缓存 ==========

    /**
     * 缓存座位状态
     */
    public void cacheSeatStatus(Long roomId, Object status) {
        set(SEAT_STATUS_KEY + roomId, status, 1, TimeUnit.MINUTES);
    }

    /**
     * 获取座位状态缓存
     */
    public <T> T getSeatStatus(Long roomId) {
        return get(SEAT_STATUS_KEY + roomId);
    }

    /**
     * 清除座位状态缓存
     */
    public void clearSeatStatus(Long roomId) {
        delete(SEAT_STATUS_KEY + roomId);
    }

    // ========== Token缓存 ==========

    /**
     * 缓存Token（黑名单，用于登出）
     */
    public void blacklistToken(String token, long expireSeconds) {
        set(TOKEN_KEY + "blacklist:" + token, true, expireSeconds, TimeUnit.SECONDS);
    }

    /**
     * 检查Token是否在黑名单
     */
    public boolean isTokenBlacklisted(String token) {
        return Boolean.TRUE.equals(hasKey(TOKEN_KEY + "blacklist:" + token));
    }

    // ========== 验证码缓存 ==========

    /**
     * 缓存验证码
     */
    public void cacheVerificationCode(String key, String code) {
        set(VERIFICATION_CODE_KEY + key, code, 5, TimeUnit.MINUTES);
    }

    /**
     * 获取验证码
     */
    public String getVerificationCode(String key) {
        return get(VERIFICATION_CODE_KEY + key);
    }

    /**
     * 删除验证码
     */
    public void deleteVerificationCode(String key) {
        delete(VERIFICATION_CODE_KEY + key);
    }

    // ========== 排行榜缓存 ==========

    /**
     * 缓存排行榜
     */
    public void cacheRanking(String type, Object data) {
        set(RANKING_KEY + type, data, 5, TimeUnit.MINUTES);
    }

    /**
     * 获取排行榜缓存
     */
    public <T> T getRanking(String type) {
        return get(RANKING_KEY + type);
    }

    /**
     * 清除排行榜缓存
     */
    public void clearRankingCache() {
        deleteByPattern(RANKING_KEY + "*");
    }
}
