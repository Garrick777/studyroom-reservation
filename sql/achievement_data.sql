-- 成就数据初始化（UTF-8编码）
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 清空现有数据
DELETE FROM user_achievement;
DELETE FROM achievement;

-- 重新插入成就数据
INSERT INTO achievement (name, description, icon, badge_color, category, condition_type, condition_value, reward_points, reward_exp, rarity, is_hidden, sort_order) VALUES
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

SELECT COUNT(*) as total FROM achievement;
