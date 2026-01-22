package com.studyroom.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 成就定义实体
 */
@Data
@TableName("achievement")
public class Achievement {

    /**
     * 成就ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 成就名称
     */
    private String name;

    /**
     * 成就描述
     */
    private String description;

    /**
     * 图标
     */
    private String icon;

    /**
     * 徽章颜色
     */
    private String badgeColor;

    /**
     * 分类
     */
    private String category;

    /**
     * 条件类型
     */
    private String conditionType;

    /**
     * 条件值
     */
    private Integer conditionValue;

    /**
     * 奖励积分
     */
    private Integer rewardPoints;

    /**
     * 奖励经验
     */
    private Integer rewardExp;

    /**
     * 稀有度
     */
    private String rarity;

    /**
     * 是否隐藏成就
     */
    private Integer isHidden;

    /**
     * 排序
     */
    private Integer sortOrder;

    /**
     * 状态
     */
    private Integer status;

    /**
     * 创建时间
     */
    @TableField("created_at")
    private LocalDateTime createdAt;

    // ========== 非数据库字段 ==========

    /**
     * 用户成就进度信息
     */
    @TableField(exist = false)
    private UserAchievement userProgress;

    // ========== 常量定义 ==========

    // 分类
    public static final String CATEGORY_STUDY = "STUDY";           // 学习
    public static final String CATEGORY_CHECK_IN = "CHECK_IN";     // 打卡
    public static final String CATEGORY_SOCIAL = "SOCIAL";         // 社交
    public static final String CATEGORY_SPECIAL = "SPECIAL";       // 特殊

    // 条件类型
    public static final String CONDITION_TOTAL_RESERVATIONS = "TOTAL_RESERVATIONS";       // 累计预约次数
    public static final String CONDITION_TOTAL_HOURS = "TOTAL_HOURS";                     // 累计学习时长
    public static final String CONDITION_TOTAL_CHECK_INS = "TOTAL_CHECK_INS";             // 累计打卡次数
    public static final String CONDITION_CONTINUOUS_CHECK_INS = "CONTINUOUS_CHECK_INS";   // 连续打卡天数
    public static final String CONDITION_TOTAL_FRIENDS = "TOTAL_FRIENDS";                 // 好友数量
    public static final String CONDITION_CREATE_GROUP = "CREATE_GROUP";                   // 创建小组
    public static final String CONDITION_EARLY_SIGN_IN = "EARLY_SIGN_IN";                 // 早起签到
    public static final String CONDITION_LATE_SIGN_OUT = "LATE_SIGN_OUT";                 // 晚间签退
    public static final String CONDITION_NO_VIOLATION_STREAK = "NO_VIOLATION_STREAK";     // 连续无违约
    public static final String CONDITION_WEEKEND_STUDY = "WEEKEND_STUDY";                 // 周末学习
    public static final String CONDITION_GOALS_COMPLETED = "GOALS_COMPLETED";             // 完成目标数
    public static final String CONDITION_TOTAL_REVIEWS = "TOTAL_REVIEWS";                 // 评价数量

    // 稀有度
    public static final String RARITY_COMMON = "COMMON";           // 普通
    public static final String RARITY_RARE = "RARE";               // 稀有
    public static final String RARITY_EPIC = "EPIC";               // 史诗
    public static final String RARITY_LEGENDARY = "LEGENDARY";     // 传说

    /**
     * 获取分类中文名称
     */
    public static String getCategoryName(String category) {
        return switch (category) {
            case CATEGORY_STUDY -> "学习成就";
            case CATEGORY_CHECK_IN -> "打卡成就";
            case CATEGORY_SOCIAL -> "社交成就";
            case CATEGORY_SPECIAL -> "特殊成就";
            default -> "未知分类";
        };
    }

    /**
     * 获取稀有度中文名称
     */
    public static String getRarityName(String rarity) {
        return switch (rarity) {
            case RARITY_COMMON -> "普通";
            case RARITY_RARE -> "稀有";
            case RARITY_EPIC -> "史诗";
            case RARITY_LEGENDARY -> "传说";
            default -> "未知";
        };
    }

    /**
     * 获取稀有度颜色
     */
    public static String getRarityColor(String rarity) {
        return switch (rarity) {
            case RARITY_COMMON -> "#9E9E9E";
            case RARITY_RARE -> "#2196F3";
            case RARITY_EPIC -> "#9C27B0";
            case RARITY_LEGENDARY -> "#FFD700";
            default -> "#9E9E9E";
        };
    }
}
