package com.studyroom.common;

import lombok.Getter;
import lombok.AllArgsConstructor;

/**
 * 响应状态码枚举
 */
@Getter
@AllArgsConstructor
public enum ResultCode {

    // 成功
    SUCCESS(200, "操作成功"),

    // 客户端错误 4xx
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未授权，请先登录"),
    FORBIDDEN(403, "无权限访问"),
    NOT_FOUND(404, "资源不存在"),
    METHOD_NOT_ALLOWED(405, "请求方法不支持"),
    CONFLICT(409, "数据冲突"),
    VALIDATION_ERROR(422, "数据验证失败"),

    // 服务端错误 5xx
    ERROR(500, "服务器内部错误"),
    SERVICE_UNAVAILABLE(503, "服务暂不可用"),

    // 业务错误 1xxx - 用户相关
    USER_NOT_FOUND(1001, "用户不存在"),
    USER_EXISTS(1002, "用户已存在"),
    PASSWORD_ERROR(1003, "密码错误"),
    ACCOUNT_DISABLED(1004, "账号已禁用"),
    ACCOUNT_LOCKED(1005, "账号已锁定"),
    STUDENT_ID_EXISTS(1006, "学号已被注册"),
    PHONE_EXISTS(1007, "手机号已被注册"),
    EMAIL_EXISTS(1008, "邮箱已被注册"),
    OLD_PASSWORD_ERROR(1009, "原密码错误"),

    // 业务错误 2xxx - 认证相关
    TOKEN_INVALID(2001, "Token无效"),
    TOKEN_EXPIRED(2002, "Token已过期"),
    TOKEN_MISSING(2003, "Token缺失"),
    LOGIN_FAILED(2004, "登录失败"),
    LOGOUT_FAILED(2005, "登出失败"),

    // 业务错误 3xxx - 自习室相关
    ROOM_NOT_FOUND(3001, "自习室不存在"),
    ROOM_CLOSED(3002, "自习室已关闭"),
    ROOM_FULL(3003, "自习室已满"),

    // 业务错误 4xxx - 座位相关
    SEAT_NOT_FOUND(4001, "座位不存在"),
    SEAT_UNAVAILABLE(4002, "座位不可用"),
    SEAT_OCCUPIED(4003, "座位已被占用"),
    SEAT_RESERVED(4004, "座位已被预约"),

    // 业务错误 5xxx - 预约相关
    RESERVATION_NOT_FOUND(5001, "预约记录不存在"),
    RESERVATION_EXISTS(5002, "已有该时段预约"),
    RESERVATION_LIMIT_EXCEEDED(5003, "超出每日预约次数限制"),
    RESERVATION_TIME_INVALID(5004, "预约时间无效"),
    RESERVATION_CANCEL_NOT_ALLOWED(5005, "无法取消预约"),
    RESERVATION_ALREADY_CHECKED_IN(5006, "已经签到"),
    RESERVATION_NOT_STARTED(5007, "预约时段未开始"),
    RESERVATION_ENDED(5008, "预约时段已结束"),
    RESERVATION_CANCELLED(5009, "预约已取消"),

    // 业务错误 6xxx - 签到相关
    CHECKIN_TOO_EARLY(6001, "签到时间过早"),
    CHECKIN_TOO_LATE(6002, "签到时间过晚，预约已失效"),
    CHECKIN_ALREADY(6003, "已经签到"),
    NOT_CHECKED_IN(6004, "未签到"),
    ALREADY_CHECKED_OUT(6005, "已经签退"),

    // 业务错误 7xxx - 暂离相关
    LEAVE_NOT_ALLOWED(7001, "当前状态不允许暂离"),
    LEAVE_LIMIT_EXCEEDED(7002, "暂离次数已达上限"),
    LEAVE_TIMEOUT(7003, "暂离超时"),
    NOT_ON_LEAVE(7004, "当前不在暂离状态"),

    // 业务错误 8xxx - 信用分相关
    CREDIT_INSUFFICIENT(8001, "信用分不足"),
    IN_BLACKLIST(8002, "您在黑名单中，暂时无法预约"),

    // 业务错误 9xxx - 成就相关
    ACHIEVEMENT_NOT_FOUND(9001, "成就不存在"),
    ACHIEVEMENT_ALREADY_UNLOCKED(9002, "成就已解锁"),

    // 业务错误 10xxx - 积分相关
    POINTS_INSUFFICIENT(10001, "积分不足"),
    PRODUCT_NOT_FOUND(10002, "商品不存在"),
    PRODUCT_OUT_OF_STOCK(10003, "商品库存不足"),

    // 业务错误 11xxx - 文件相关
    FILE_UPLOAD_ERROR(11001, "文件上传失败"),
    FILE_TYPE_NOT_ALLOWED(11002, "文件类型不支持"),
    FILE_SIZE_EXCEEDED(11003, "文件大小超出限制"),
    FILE_NOT_FOUND(11004, "文件不存在");

    /**
     * 状态码
     */
    private final Integer code;

    /**
     * 消息
     */
    private final String message;
}
