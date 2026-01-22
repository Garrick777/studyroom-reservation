-- =====================================================
-- 智慧自习室座位预约系统 - 初始化数据脚本 v2.0
-- =====================================================

USE `study_room_db`;

-- =====================================================
-- 1. 时段数据
-- =====================================================
INSERT INTO `time_slot` (`name`, `start_time`, `end_time`, `duration`, `sort_order`, `status`) VALUES
('早间', '08:00:00', '10:00:00', 120, 1, 1),
('上午', '10:00:00', '12:00:00', 120, 2, 1),
('中午', '12:00:00', '14:00:00', 120, 3, 1),
('下午', '14:00:00', '16:00:00', 120, 4, 1),
('傍晚', '16:00:00', '18:00:00', 120, 5, 1),
('晚间A', '18:00:00', '20:00:00', 120, 6, 1),
('晚间B', '20:00:00', '22:00:00', 120, 7, 1);

-- =====================================================
-- 2. 系统配置数据
-- =====================================================
INSERT INTO `system_config` (`config_key`, `config_value`, `config_type`, `category`, `description`, `editable`) VALUES
-- 预约相关
('max_advance_days', '7', 'NUMBER', 'RESERVATION', '最大提前预约天数', 1),
('max_daily_reservations', '2', 'NUMBER', 'RESERVATION', '每日最大预约次数', 1),
('min_credit_score', '60', 'NUMBER', 'RESERVATION', '最低预约信用分', 1),
('sign_in_advance_minutes', '15', 'NUMBER', 'RESERVATION', '提前签到分钟数', 1),
('sign_in_timeout_minutes', '30', 'NUMBER', 'RESERVATION', '签到超时分钟数', 1),
('leave_max_minutes', '30', 'NUMBER', 'RESERVATION', '暂离最大分钟数', 1),
('leave_max_times', '2', 'NUMBER', 'RESERVATION', '最大暂离次数', 1),
('free_cancel_minutes', '60', 'NUMBER', 'RESERVATION', '免费取消提前分钟数', 1),
-- 信用相关
('blacklist_days', '7', 'NUMBER', 'CREDIT', '黑名单天数', 1),
('monthly_recover_score', '5', 'NUMBER', 'CREDIT', '月度恢复积分', 1),
('sign_out_reward_score', '2', 'NUMBER', 'CREDIT', '签退奖励积分', 1),
('no_sign_in_deduct', '10', 'NUMBER', 'CREDIT', '未签到扣分', 1),
('late_cancel_deduct', '5', 'NUMBER', 'CREDIT', '迟取消扣分', 1),
('leave_timeout_deduct', '8', 'NUMBER', 'CREDIT', '暂离超时扣分', 1),
-- 积分相关
('check_in_base_points', '5', 'NUMBER', 'POINTS', '每日签到基础积分', 1),
('check_in_continuous_bonus', '2', 'NUMBER', 'POINTS', '连续签到额外积分', 1),
('study_hour_points', '10', 'NUMBER', 'POINTS', '每小时学习积分', 1),
('goal_complete_bonus', '50', 'NUMBER', 'POINTS', '目标完成奖励积分', 1),
-- 等级相关
('level_exp_base', '100', 'NUMBER', 'LEVEL', '升级基础经验', 1),
('level_exp_factor', '1.5', 'NUMBER', 'LEVEL', '升级经验系数', 1),
-- 系统相关
('system_name', '智慧自习室座位预约系统', 'STRING', 'SYSTEM', '系统名称', 0),
('system_version', '2.0.0', 'STRING', 'SYSTEM', '系统版本', 0),
('maintenance_mode', 'false', 'BOOLEAN', 'SYSTEM', '维护模式', 1),
('register_enabled', 'true', 'BOOLEAN', 'SYSTEM', '是否开放注册', 1);

-- =====================================================
-- 3. 成就定义数据
-- =====================================================
INSERT INTO `achievement` (`name`, `description`, `icon`, `badge_color`, `category`, `condition_type`, `condition_value`, `reward_points`, `reward_exp`, `rarity`, `is_hidden`, `sort_order`) VALUES
-- 学习成就
('初出茅庐', '完成第一次自习', '🎓', '#4CAF50', 'STUDY', 'TOTAL_RESERVATIONS', 1, 10, 20, 'COMMON', 0, 1),
('学习达人', '累计完成50次自习', '📚', '#2196F3', 'STUDY', 'TOTAL_RESERVATIONS', 50, 100, 200, 'RARE', 0, 2),
('学霸养成', '累计完成100次自习', '🏆', '#9C27B0', 'STUDY', 'TOTAL_RESERVATIONS', 100, 200, 400, 'EPIC', 0, 3),
('学神降临', '累计完成500次自习', '👑', '#FF9800', 'STUDY', 'TOTAL_RESERVATIONS', 500, 500, 1000, 'LEGENDARY', 0, 4),
('小时工', '累计学习10小时', '⏰', '#607D8B', 'STUDY', 'TOTAL_HOURS', 10, 20, 40, 'COMMON', 0, 5),
('时间管理者', '累计学习100小时', '⏱️', '#00BCD4', 'STUDY', 'TOTAL_HOURS', 100, 150, 300, 'RARE', 0, 6),
('时间大师', '累计学习500小时', '🕐', '#E91E63', 'STUDY', 'TOTAL_HOURS', 500, 300, 600, 'EPIC', 0, 7),
('时间领主', '累计学习1000小时', '⌛', '#673AB7', 'STUDY', 'TOTAL_HOURS', 1000, 600, 1200, 'LEGENDARY', 0, 8),
-- 打卡成就
('初次打卡', '完成第一次每日打卡', '✅', '#8BC34A', 'CHECK_IN', 'TOTAL_CHECK_INS', 1, 5, 10, 'COMMON', 0, 10),
('坚持一周', '连续打卡7天', '📅', '#03A9F4', 'CHECK_IN', 'CONTINUOUS_CHECK_INS', 7, 30, 60, 'COMMON', 0, 11),
('月度坚持', '连续打卡30天', '🗓️', '#FF5722', 'CHECK_IN', 'CONTINUOUS_CHECK_INS', 30, 100, 200, 'RARE', 0, 12),
('季度达人', '连续打卡90天', '📆', '#9C27B0', 'CHECK_IN', 'CONTINUOUS_CHECK_INS', 90, 300, 600, 'EPIC', 0, 13),
('年度坚持', '连续打卡365天', '🎊', '#FFD700', 'CHECK_IN', 'CONTINUOUS_CHECK_INS', 365, 1000, 2000, 'LEGENDARY', 0, 14),
-- 社交成就
('初识好友', '添加第一个好友', '👋', '#4CAF50', 'SOCIAL', 'TOTAL_FRIENDS', 1, 10, 20, 'COMMON', 0, 20),
('社交达人', '拥有10个好友', '👥', '#2196F3', 'SOCIAL', 'TOTAL_FRIENDS', 10, 50, 100, 'RARE', 0, 21),
('人气王', '拥有50个好友', '🌟', '#FF9800', 'SOCIAL', 'TOTAL_FRIENDS', 50, 200, 400, 'EPIC', 0, 22),
('组建小队', '创建学习小组', '🎯', '#00BCD4', 'SOCIAL', 'CREATE_GROUP', 1, 30, 60, 'COMMON', 0, 23),
-- 特殊成就
('早起鸟', '早上8点前签到10次', '🐦', '#FF9800', 'SPECIAL', 'EARLY_SIGN_IN', 10, 50, 100, 'RARE', 0, 30),
('夜猫子', '晚上10点后签退10次', '🦉', '#3F51B5', 'SPECIAL', 'LATE_SIGN_OUT', 10, 50, 100, 'RARE', 0, 31),
('完美守约', '连续50次无违约', '💯', '#4CAF50', 'SPECIAL', 'NO_VIOLATION_STREAK', 50, 100, 200, 'RARE', 0, 32),
('周末战士', '累计周末学习20次', '⚔️', '#F44336', 'SPECIAL', 'WEEKEND_STUDY', 20, 80, 160, 'RARE', 0, 33),
('目标达成', '完成10个学习目标', '🎯', '#E91E63', 'SPECIAL', 'GOALS_COMPLETED', 10, 100, 200, 'RARE', 0, 34),
('评价达人', '发表20条座位评价', '💬', '#795548', 'SPECIAL', 'TOTAL_REVIEWS', 20, 60, 120, 'RARE', 0, 35),
('隐藏高手', '连续100次无违约', '🏅', '#FFD700', 'SPECIAL', 'NO_VIOLATION_STREAK', 100, 300, 600, 'LEGENDARY', 1, 40);

-- =====================================================
-- 4. 积分商城商品数据
-- =====================================================
INSERT INTO `point_product` (`name`, `description`, `image`, `category`, `points_required`, `stock`, `limit_per_user`, `status`, `sort_order`) VALUES
('精美书签套装', '5枚装精美金属书签，学习伴侣', '/images/products/bookmark.jpg', 'STATIONERY', 100, 50, 2, 1, 1),
('高级笔记本', 'A5精装笔记本，160页优质纸张', '/images/products/notebook.jpg', 'STATIONERY', 150, 100, 3, 1, 2),
('荧光笔套装', '6色荧光笔套装，标注利器', '/images/products/highlighter.jpg', 'STATIONERY', 80, 200, 5, 1, 3),
('便利贴大礼包', '多种规格便利贴组合', '/images/products/sticky-notes.jpg', 'STATIONERY', 60, 300, 10, 1, 4),
('定制帆布袋', '系统定制款环保帆布袋', '/images/products/bag.jpg', 'GIFT', 200, 30, 1, 1, 5),
('保温杯', '316不锈钢保温杯500ml', '/images/products/thermos.jpg', 'GIFT', 300, 20, 1, 1, 6),
('护眼台灯', 'LED护眼台灯，三档调节', '/images/products/lamp.jpg', 'ELECTRONICS', 500, 10, 1, 1, 7),
('蓝牙耳机', '入耳式降噪蓝牙耳机', '/images/products/earphone.jpg', 'ELECTRONICS', 800, 5, 1, 1, 8),
('优先预约权(7天)', '获得7天优先预约特权', '/images/products/vip-7.jpg', 'PRIVILEGE', 200, -1, 0, 1, 9),
('VIP座位体验券', '体验VIP座位一次', '/images/products/vip-seat.jpg', 'PRIVILEGE', 150, -1, 0, 1, 10),
('信用分恢复卡', '恢复5点信用分', '/images/products/credit-card.jpg', 'PRIVILEGE', 100, -1, 3, 1, 11),
('双倍积分卡(3天)', '3天内学习积分翻倍', '/images/products/double-points.jpg', 'PRIVILEGE', 180, -1, 0, 1, 12);

-- =====================================================
-- 创建座位生成存储过程
-- =====================================================
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS generate_seats(IN p_room_id BIGINT, IN p_rows INT, IN p_cols INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1;
    DECLARE v_seat_no VARCHAR(20);
    DECLARE v_seat_type VARCHAR(20);
    DECLARE v_has_power TINYINT;
    DECLARE v_has_lamp TINYINT;
    
    WHILE i <= p_rows DO
        SET j = 1;
        WHILE j <= p_cols DO
            SET v_seat_no = CONCAT(CHAR(64 + i), LPAD(j, 2, '0'));
            
            -- 第一行和最后一行靠墙有电源和台灯
            IF i = 1 OR i = p_rows THEN
                SET v_seat_type = 'POWER';
                SET v_has_power = 1;
                SET v_has_lamp = 1;
            -- 靠窗位置
            ELSEIF j = p_cols THEN
                SET v_seat_type = 'WINDOW';
                SET v_has_power = 0;
                SET v_has_lamp = 0;
            -- 角落位置
            ELSEIF (i = 1 OR i = p_rows) AND (j = 1 OR j = p_cols) THEN
                SET v_seat_type = 'CORNER';
                SET v_has_power = 1;
                SET v_has_lamp = 1;
            ELSE
                SET v_seat_type = 'NORMAL';
                SET v_has_power = 0;
                SET v_has_lamp = 0;
            END IF;
            
            INSERT INTO `seat` (`room_id`, `seat_no`, `row_num`, `col_num`, `seat_type`, `has_power`, `has_lamp`, `status`)
            VALUES (p_room_id, v_seat_no, i, j, v_seat_type, v_has_power, v_has_lamp, 1);
            
            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- =====================================================
-- 数据初始化完成提示
-- =====================================================
SELECT '基础配置数据初始化完成!' AS '提示';
