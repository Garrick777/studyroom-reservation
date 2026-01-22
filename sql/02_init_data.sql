-- =====================================================
-- 智慧自习室座位预约系统 - 数据初始化脚本
-- Smart Study Room Seat Reservation System - Init Data
-- 
-- 包含:
--   阶段1-7: 用户/自习室/座位/时段/预约/信用/打卡/目标/成就
--   阶段8: 社交功能（好友/小组/消息）
--   阶段9: 积分商城
-- 
-- 默认密码: 123456 (BCrypt加密后)
-- 
-- 使用方法 (需先执行01_schema.sql):
--   mysql -u root -p studyroom < 02_init_data.sql
-- =====================================================

SET NAMES utf8mb4;
USE studyroom;
SET FOREIGN_KEY_CHECKS = 0;

SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 第一阶段：用户模块数据
-- =============================================

DELETE FROM user WHERE id > 0;

-- 密码统一为: password123 (BCrypt加密)
INSERT INTO user (id, username, password, real_name, student_id, email, phone, avatar, gender, college, major, grade, role, credit_score, total_study_time, total_points, exp, consecutive_days, total_check_ins, current_streak, max_streak, status, create_time, update_time) VALUES
-- 普通学生用户
(1, 'zhangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张三', '2022001001', 'zhangsan@edu.cn', '13800001001', NULL, 1, '计算机学院', '软件工程', '大三', 'STUDENT', 95, 15390, 2850, 5120, 18, 125, 18, 45, 1, NOW() - INTERVAL 180 DAY, NOW()),
(2, 'lisi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '李四', '2022001002', 'lisi@edu.cn', '13800001002', NULL, 1, '计算机学院', '计算机科学与技术', '大三', 'STUDENT', 88, 11898, 2150, 4280, 12, 98, 12, 32, 1, NOW() - INTERVAL 175 DAY, NOW()),
(3, 'wangwu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '王五', '2022001003', 'wangwu@edu.cn', '13800001003', NULL, 1, '经济管理学院', '会计学', '大二', 'STUDENT', 100, 18768, 3560, 6850, 45, 168, 45, 60, 1, NOW() - INTERVAL 170 DAY, NOW()),
(4, 'zhaoliu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '赵六', '2022001004', 'zhaoliu@edu.cn', '13800001004', NULL, 1, '电子信息学院', '电子工程', '大三', 'STUDENT', 92, 13536, 2680, 5460, 22, 112, 22, 38, 1, NOW() - INTERVAL 165 DAY, NOW()),
(5, 'sunqi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '孙七', '2022001005', 'sunqi@edu.cn', '13800001005', NULL, 2, '外国语学院', '英语', '大二', 'STUDENT', 85, 9912, 1850, 3520, 8, 76, 8, 25, 1, NOW() - INTERVAL 160 DAY, NOW()),
(6, 'zhouba', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '周八', '2022001006', 'zhouba@edu.cn', '13800001006', NULL, 1, '法学院', '法学', '大四', 'STUDENT', 78, 8550, 1580, 2960, 5, 62, 5, 18, 1, NOW() - INTERVAL 155 DAY, NOW()),
(7, 'wujiu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '吴九', '2022001007', 'wujiu@edu.cn', '13800001007', NULL, 1, '数学与统计学院', '应用数学', '大三', 'STUDENT', 100, 17118, 3250, 6280, 32, 145, 32, 55, 1, NOW() - INTERVAL 150 DAY, NOW()),
(8, 'zhengshi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '郑十', '2022001008', 'zhengshi@edu.cn', '13800001008', NULL, 2, '医学院', '临床医学', '大四', 'STUDENT', 90, 10716, 2050, 4150, 15, 88, 15, 28, 1, NOW() - INTERVAL 145 DAY, NOW()),
(9, 'chenyi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '陈一', '2022001009', 'chenyi@edu.cn', '13800001009', NULL, 1, '物理学院', '应用物理', '大三', 'STUDENT', 97, 14748, 2780, 5560, 28, 132, 28, 42, 1, NOW() - INTERVAL 140 DAY, NOW()),
(10, 'liner', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '林二', '2022001010', 'liner@edu.cn', '13800001010', NULL, 2, '艺术学院', '视觉传达设计', '大二', 'STUDENT', 82, 8112, 1450, 2850, 6, 55, 6, 15, 1, NOW() - INTERVAL 135 DAY, NOW()),
-- 更多学生 (11-20)
(11, 'huangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黄三', '2022001011', 'huangsan@edu.cn', '13800001011', NULL, 1, '计算机学院', '人工智能', '大三', 'STUDENT', 100, 17910, 3380, 6520, 35, 152, 35, 48, 1, NOW() - INTERVAL 130 DAY, NOW()),
(12, 'xusi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '徐四', '2022001012', 'xusi@edu.cn', '13800001012', NULL, 1, '化学学院', '化学工程', '大二', 'STUDENT', 75, 5916, 1120, 2150, 3, 42, 3, 12, 1, NOW() - INTERVAL 125 DAY, NOW()),
(13, 'mawu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '马五', '2022001013', 'mawu@edu.cn', '13800001013', NULL, 2, '生命科学学院', '生物技术', '大三', 'STUDENT', 93, 12948, 2450, 4850, 20, 105, 20, 35, 1, NOW() - INTERVAL 120 DAY, NOW()),
(14, 'gaoliu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '高六', '2022001014', 'gaoliu@edu.cn', '13800001014', NULL, 1, '机械工程学院', '机械设计', '大三', 'STUDENT', 88, 10110, 1920, 3850, 14, 82, 14, 26, 1, NOW() - INTERVAL 115 DAY, NOW()),
(15, 'liuqi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '刘七', '2022001015', 'liuqi@edu.cn', '13800001015', NULL, 2, '计算机学院', '数据科学', '大四', 'STUDENT', 100, 19536, 3680, 7150, 52, 175, 52, 65, 1, NOW() - INTERVAL 110 DAY, NOW()),
(16, 'yangba', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '杨八', '2022001016', 'yangba@edu.cn', '13800001016', NULL, 1, '建筑学院', '建筑学', '大二', 'STUDENT', 68, 5118, 980, 1850, 2, 35, 2, 8, 1, NOW() - INTERVAL 105 DAY, NOW()),
(17, 'hujiu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '胡九', '2022001017', 'hujiu@edu.cn', '13800001017', NULL, 1, '环境学院', '环境工程', '大三', 'STUDENT', 95, 15948, 3020, 5980, 25, 128, 25, 40, 1, NOW() - INTERVAL 100 DAY, NOW()),
(18, 'zhushi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '朱十', '2022001018', 'zhushi@edu.cn', '13800001018', NULL, 2, '新闻传播学院', '新闻学', '大二', 'STUDENT', 85, 9372, 1780, 3520, 10, 68, 10, 22, 1, NOW() - INTERVAL 95 DAY, NOW()),
(19, 'qianyi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '钱一', '2022001019', 'qianyi@edu.cn', '13800001019', NULL, 1, '土木工程学院', '土木工程', '大三', 'STUDENT', 91, 11910, 2280, 4520, 18, 95, 18, 30, 1, NOW() - INTERVAL 90 DAY, NOW()),
(20, 'fenger', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '冯二', '2022001020', 'fenger@edu.cn', '13800001020', NULL, 2, '药学院', '药学', '大二', 'STUDENT', 72, 4710, 920, 1680, 1, 28, 1, 5, 1, NOW() - INTERVAL 85 DAY, NOW()),
-- 研究生用户 (21-25)
(21, 'wangyanyi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '王研一', 'G2024001', 'wangyanyi@edu.cn', '13800002001', NULL, 1, '计算机学院', '计算机应用技术', '研一', 'STUDENT', 98, 21408, 4050, 7850, 62, 185, 62, 75, 1, NOW() - INTERVAL 200 DAY, NOW()),
(22, 'liyaner', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '李研二', 'G2024002', 'liyaner@edu.cn', '13800002002', NULL, 1, '经济管理学院', '工商管理', '研二', 'STUDENT', 100, 24750, 4680, 8950, 75, 198, 75, 90, 1, NOW() - INTERVAL 195 DAY, NOW()),
(23, 'zhangyansan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张研三', 'G2024003', 'zhangyansan@edu.cn', '13800002003', NULL, 2, '法学院', '法学', '研一', 'STUDENT', 95, 17136, 3250, 6480, 38, 155, 38, 52, 1, NOW() - INTERVAL 190 DAY, NOW()),
(24, 'zhaoyensi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '赵研四', 'G2024004', 'zhaoyensi@edu.cn', '13800002004', NULL, 1, '电子信息学院', '电子与通信工程', '研二', 'STUDENT', 88, 13548, 2580, 5120, 28, 135, 28, 45, 1, NOW() - INTERVAL 185 DAY, NOW()),
(25, 'sunyanwu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '孙研五', 'G2024005', 'sunyanwu@edu.cn', '13800002005', NULL, 2, '数学与统计学院', '应用统计', '研一', 'STUDENT', 92, 15918, 3020, 5980, 32, 142, 32, 48, 1, NOW() - INTERVAL 180 DAY, NOW()),
-- 黑名单用户 (26-28)
(26, 'heiming1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黑名单用户一', '2022002001', 'heiming1@edu.cn', '13800003001', NULL, 1, '计算机学院', '软件工程', '大二', 'STUDENT', 45, 1530, 280, 520, 0, 15, 0, 3, 1, NOW() - INTERVAL 60 DAY, NOW()),
(27, 'heiming2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黑名单用户二', '2022002002', 'heiming2@edu.cn', '13800003002', NULL, 1, '经济管理学院', '金融学', '大三', 'STUDENT', 55, 1968, 350, 680, 0, 22, 0, 5, 1, NOW() - INTERVAL 55 DAY, NOW()),
(28, 'heiming3', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黑名单用户三', '2022002003', 'heiming3@edu.cn', '13800003003', NULL, 2, '外国语学院', '日语', '大二', 'STUDENT', 38, 1110, 180, 350, 0, 12, 0, 2, 1, NOW() - INTERVAL 50 DAY, NOW()),
-- 管理员用户 (29-31)
(29, 'admin1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '管理员一', 'A001', 'admin1@edu.cn', '13800009001', NULL, 1, NULL, NULL, NULL, 'ADMIN', 100, 0, 0, 0, 0, 0, 0, 0, 1, NOW() - INTERVAL 365 DAY, NOW()),
(30, 'admin2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '管理员二', 'A002', 'admin2@edu.cn', '13800009002', NULL, 2, NULL, NULL, NULL, 'ADMIN', 100, 0, 0, 0, 0, 0, 0, 0, 1, NOW() - INTERVAL 360 DAY, NOW()),
(31, 'superadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '超级管理员', 'SA001', 'superadmin@edu.cn', '13800009999', NULL, 1, NULL, NULL, NULL, 'SUPER_ADMIN', 100, 0, 0, 0, 0, 0, 0, 0, 1, NOW() - INTERVAL 400 DAY, NOW());

-- =============================================
-- 第二阶段：自习室和座位数据
-- =============================================

DELETE FROM seat WHERE id > 0;
DELETE FROM study_room WHERE id > 0;

-- 自习室数据
INSERT INTO study_room (id, name, code, building, floor, room_number, capacity, row_count, col_count, description, facilities, open_time, close_time, advance_days, max_duration, min_credit_score, need_approve, allow_temp, rating, rating_count, status, sort_order, create_time, update_time) VALUES
-- 图书馆自习室
(1, '图书馆一楼大厅自习区', 'LIB-1F-A', '图书馆', '1F', 'A区', 80, 8, 10, '开放式自习区，环境明亮宽敞，适合日常学习', '["空调", "WiFi", "充电插座", "饮水机"]', '07:00:00', '23:00:00', 7, 6, 60, 0, 1, 4.8, 256, 1, 1, NOW() - INTERVAL 365 DAY, NOW()),
(2, '图书馆二楼电子阅览室', 'LIB-2F-E', '图书馆', '2F', 'E区', 60, 6, 10, '配备电脑的阅览室，可上网查阅资料', '["空调", "WiFi", "电脑", "打印机", "充电插座"]', '07:30:00', '22:30:00', 7, 4, 60, 0, 1, 4.6, 188, 1, 2, NOW() - INTERVAL 365 DAY, NOW()),
(3, '图书馆三楼静音自习室A', 'LIB-3F-A', '图书馆', '3F', 'A区', 50, 5, 10, '严格静音区域，禁止交谈和使用手机', '["空调", "WiFi", "台灯", "充电插座"]', '07:00:00', '23:00:00', 7, 6, 70, 0, 0, 4.9, 312, 1, 3, NOW() - INTERVAL 365 DAY, NOW()),
(4, '图书馆三楼静音自习室B', 'LIB-3F-B', '图书馆', '3F', 'B区', 50, 5, 10, '严格静音区域，独立隔间设计', '["空调", "WiFi", "台灯", "充电插座"]', '07:00:00', '23:00:00', 7, 6, 70, 0, 0, 4.9, 298, 1, 4, NOW() - INTERVAL 365 DAY, NOW()),
(5, '图书馆四楼自习室', 'LIB-4F', '图书馆', '4F', '主厅', 100, 10, 10, '大型自习室，座位充足，适合集体学习', '["空调", "WiFi", "充电插座", "饮水机"]', '07:00:00', '23:00:00', 7, 6, 60, 0, 1, 4.7, 425, 1, 5, NOW() - INTERVAL 365 DAY, NOW()),
(6, '图书馆五楼考研自习室', 'LIB-5F', '图书馆', '5F', '考研专区', 80, 8, 10, '考研专用自习室，独立书桌，提供储物柜', '["空调", "WiFi", "独立书桌", "储物柜", "充电插座"]', '06:30:00', '23:30:00', 14, 8, 75, 1, 0, 4.95, 562, 1, 6, NOW() - INTERVAL 365 DAY, NOW()),
-- 教学楼A自习室
(7, '教学楼A-101自习室', 'TA-101', '教学楼A', '1F', '101', 60, 6, 10, '普通自习室，靠近教室，课间休息时可能较嘈杂', '["空调", "WiFi"]', '06:30:00', '22:30:00', 7, 4, 60, 0, 1, 4.3, 168, 1, 7, NOW() - INTERVAL 365 DAY, NOW()),
(8, '教学楼A-201多媒体自习室', 'TA-201', '教学楼A', '2F', '201', 45, 5, 9, '配有投影设备，可用于小组讨论', '["空调", "WiFi", "投影仪", "白板"]', '07:00:00', '22:00:00', 7, 3, 60, 0, 1, 4.5, 145, 1, 8, NOW() - INTERVAL 365 DAY, NOW()),
(9, '教学楼A-301自习室', 'TA-301', '教学楼A', '3F', '301', 55, 5, 11, '普通自习室，安静舒适', '["空调", "WiFi", "充电插座"]', '07:00:00', '22:00:00', 7, 4, 60, 0, 1, 4.4, 132, 1, 9, NOW() - INTERVAL 365 DAY, NOW()),
(10, '教学楼A-401自习室', 'TA-401', '教学楼A', '4F', '401', 50, 5, 10, '普通自习室，较为安静', '["空调", "WiFi", "充电插座"]', '07:00:00', '22:00:00', 7, 4, 60, 0, 1, 4.4, 118, 1, 10, NOW() - INTERVAL 365 DAY, NOW()),
-- 教学楼B自习室
(11, '教学楼B-102计算机自习室', 'TB-102', '教学楼B', '1F', '102', 40, 4, 10, '配备计算机，适合编程和上机练习', '["空调", "WiFi", "电脑", "充电插座"]', '07:00:00', '22:00:00', 7, 4, 65, 0, 1, 4.6, 156, 1, 11, NOW() - INTERVAL 365 DAY, NOW()),
(12, '教学楼B-203自习室', 'TB-203', '教学楼B', '2F', '203', 48, 4, 12, '普通自习室，座位间距较大', '["空调", "WiFi"]', '07:00:00', '21:30:00', 7, 4, 60, 0, 1, 4.3, 98, 1, 12, NOW() - INTERVAL 365 DAY, NOW()),
(13, '教学楼B-304自习室', 'TB-304', '教学楼B', '3F', '304', 52, 4, 13, '普通自习室', '["空调", "WiFi", "充电插座"]', '07:00:00', '21:30:00', 7, 4, 60, 0, 1, 4.2, 86, 1, 13, NOW() - INTERVAL 365 DAY, NOW()),
-- 研究生楼自习室
(14, '研究生自习室A', 'GR-201', '研究生楼', '2F', '201', 70, 7, 10, '研究生专用，独立桌椅，环境安静', '["空调", "WiFi", "独立桌椅", "储物柜", "充电插座"]', '06:00:00', '24:00:00', 14, 8, 70, 1, 0, 4.8, 245, 1, 14, NOW() - INTERVAL 365 DAY, NOW()),
(15, '研究生自习室B', 'GR-301', '研究生楼', '3F', '301', 65, 5, 13, '研究生专用，可24小时使用', '["空调", "WiFi", "独立桌椅", "充电插座"]', '06:00:00', '24:00:00', 14, 8, 70, 1, 0, 4.75, 218, 1, 15, NOW() - INTERVAL 365 DAY, NOW()),
(16, '研究生静音室', 'GR-401', '研究生楼', '4F', '401', 40, 4, 10, '研究生静音学习区，严禁交谈', '["空调", "WiFi", "台灯", "充电插座"]', '06:00:00', '24:00:00', 14, 8, 75, 1, 0, 4.9, 186, 1, 16, NOW() - INTERVAL 365 DAY, NOW()),
(17, '博士研讨室', 'GR-501', '研究生楼', '5F', '501', 25, 5, 5, '博士生专用，可用于学术讨论', '["空调", "WiFi", "投影仪", "白板", "视频会议设备"]', '08:00:00', '23:00:00', 14, 6, 80, 1, 0, 4.85, 92, 1, 17, NOW() - INTERVAL 365 DAY, NOW()),
-- 综合楼自习室
(18, '综合楼自习室', 'CO-201', '综合楼', '2F', '201', 35, 5, 7, '小型自习室，适合课间使用', '["空调", "WiFi"]', '08:00:00', '21:00:00', 7, 3, 60, 0, 1, 4.1, 65, 1, 18, NOW() - INTERVAL 365 DAY, NOW()),
-- 维护中的自习室
(19, '教学楼A-501自习室', 'TA-501', '教学楼A', '5F', '501', 45, 5, 9, '普通自习室（维护中）', '["空调", "WiFi"]', '07:00:00', '22:00:00', 7, 4, 60, 0, 1, 4.0, 45, 0, 19, NOW() - INTERVAL 365 DAY, NOW()),
(20, '教学楼B-401实验室', 'TB-401', '教学楼B', '4F', '401', 30, 3, 10, '实验室（设备维护中）', '["空调", "WiFi", "实验设备"]', '08:00:00', '20:00:00', 7, 3, 65, 0, 1, 4.2, 38, 0, 20, NOW() - INTERVAL 365 DAY, NOW());

-- 座位数据生成
DELIMITER //
DROP PROCEDURE IF EXISTS generate_seats//
CREATE PROCEDURE generate_seats()
BEGIN
    DECLARE room_id INT;
    DECLARE room_row_count INT;
    DECLARE room_col_count INT;
    DECLARE room_status INT;
    DECLARE r INT;
    DECLARE c INT;
    DECLARE seat_type VARCHAR(20);
    DECLARE seat_status INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE room_cursor CURSOR FOR SELECT id, row_count, col_count, status FROM study_room;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN room_cursor;
    
    room_loop: LOOP
        FETCH room_cursor INTO room_id, room_row_count, room_col_count, room_status;
        IF done THEN
            LEAVE room_loop;
        END IF;
        
        SET r = 1;
        WHILE r <= room_row_count DO
            SET c = 1;
            WHILE c <= room_col_count DO
                -- 座位类型：窗边、角落、普通
                SET seat_type = CASE 
                    WHEN c = 1 OR c = room_col_count THEN 'WINDOW'
                    WHEN r = 1 OR r = room_row_count THEN 'AISLE'
                    ELSE 'NORMAL'
                END;
                
                -- 座位状态
                SET seat_status = CASE 
                    WHEN room_status = 0 THEN 0  -- 维护中的房间
                    WHEN RAND() < 0.03 THEN 0   -- 3%概率维护中
                    ELSE 1 
                END;
                
                INSERT INTO seat (room_id, seat_no, row_num, col_num, seat_type, status, create_time, update_time)
                VALUES (room_id, CONCAT(CHAR(64 + r), LPAD(c, 2, '0')), r, c, seat_type, seat_status, 
                        NOW() - INTERVAL 365 DAY, NOW());
                
                SET c = c + 1;
            END WHILE;
            SET r = r + 1;
        END WHILE;
    END LOOP;
    
    CLOSE room_cursor;
END//
DELIMITER ;

CALL generate_seats();
DROP PROCEDURE generate_seats;

-- =============================================
-- 第三阶段：时间段数据
-- =============================================

DELETE FROM time_slot WHERE id > 0;

-- 时间段数据
INSERT INTO time_slot (id, name, start_time, end_time, duration, status, sort_order, create_time, update_time) VALUES
(1, '早晨时段', '07:00:00', '09:00:00', 120, 1, 1, NOW() - INTERVAL 365 DAY, NOW()),
(2, '上午前段', '09:00:00', '11:00:00', 120, 1, 2, NOW() - INTERVAL 365 DAY, NOW()),
(3, '上午后段', '11:00:00', '13:00:00', 120, 1, 3, NOW() - INTERVAL 365 DAY, NOW()),
(4, '下午前段', '13:00:00', '15:00:00', 120, 1, 4, NOW() - INTERVAL 365 DAY, NOW()),
(5, '下午后段', '15:00:00', '17:00:00', 120, 1, 5, NOW() - INTERVAL 365 DAY, NOW()),
(6, '傍晚时段', '17:00:00', '19:00:00', 120, 1, 6, NOW() - INTERVAL 365 DAY, NOW()),
(7, '晚间前段', '19:00:00', '21:00:00', 120, 1, 7, NOW() - INTERVAL 365 DAY, NOW()),
(8, '晚间后段', '21:00:00', '23:00:00', 120, 1, 8, NOW() - INTERVAL 365 DAY, NOW());

-- =============================================
-- 第四阶段：预约数据
-- =============================================

DELETE FROM reservation WHERE id > 0;

-- 生成历史预约数据
DELIMITER //
DROP PROCEDURE IF EXISTS generate_reservations//
CREATE PROCEDURE generate_reservations()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_user_id INT;
    DECLARE v_room_id INT;
    DECLARE v_seat_id INT;
    DECLARE v_date DATE;
    DECLARE v_time_slot_id INT;
    DECLARE v_start_time DATETIME;
    DECLARE v_end_time DATETIME;
    DECLARE v_status VARCHAR(20);
    DECLARE v_sign_in_time DATETIME;
    DECLARE v_sign_out_time DATETIME;
    DECLARE v_actual_duration INT;
    DECLARE v_reservation_no VARCHAR(32);
    DECLARE v_earned_points INT;
    DECLARE v_earned_exp INT;
    
    -- 获取座位总数
    DECLARE seat_count INT;
    SELECT COUNT(*) INTO seat_count FROM seat WHERE status = 1;
    
    -- 生成1500条历史预约记录
    WHILE i < 1500 DO
        SET v_user_id = FLOOR(1 + RAND() * 25);  -- 用户1-25
        SET v_room_id = FLOOR(1 + RAND() * 18);  -- 自习室1-18
        SET v_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(1 + RAND() * 60) DAY);
        SET v_time_slot_id = FLOOR(1 + RAND() * 8);
        
        -- 随机获取该自习室的一个座位
        SELECT id INTO v_seat_id FROM seat WHERE room_id = v_room_id AND status = 1 ORDER BY RAND() LIMIT 1;
        
        IF v_seat_id IS NOT NULL THEN
            -- 计算开始和结束时间
            CASE v_time_slot_id
                WHEN 1 THEN SET v_start_time = TIMESTAMP(v_date, '07:00:00'), v_end_time = TIMESTAMP(v_date, '09:00:00');
                WHEN 2 THEN SET v_start_time = TIMESTAMP(v_date, '09:00:00'), v_end_time = TIMESTAMP(v_date, '11:00:00');
                WHEN 3 THEN SET v_start_time = TIMESTAMP(v_date, '11:00:00'), v_end_time = TIMESTAMP(v_date, '13:00:00');
                WHEN 4 THEN SET v_start_time = TIMESTAMP(v_date, '13:00:00'), v_end_time = TIMESTAMP(v_date, '15:00:00');
                WHEN 5 THEN SET v_start_time = TIMESTAMP(v_date, '15:00:00'), v_end_time = TIMESTAMP(v_date, '17:00:00');
                WHEN 6 THEN SET v_start_time = TIMESTAMP(v_date, '17:00:00'), v_end_time = TIMESTAMP(v_date, '19:00:00');
                WHEN 7 THEN SET v_start_time = TIMESTAMP(v_date, '19:00:00'), v_end_time = TIMESTAMP(v_date, '21:00:00');
                ELSE SET v_start_time = TIMESTAMP(v_date, '21:00:00'), v_end_time = TIMESTAMP(v_date, '23:00:00');
            END CASE;
            
            -- 随机状态
            SET v_status = CASE 
                WHEN RAND() < 0.72 THEN 'COMPLETED'
                WHEN RAND() < 0.85 THEN 'CANCELLED'
                WHEN RAND() < 0.95 THEN 'NO_SHOW'
                ELSE 'EXPIRED'
            END;
            
            -- 生成预约号
            SET v_reservation_no = CONCAT('R', DATE_FORMAT(v_date, '%Y%m%d'), LPAD(i + 1, 6, '0'));
            
            -- 计算签到签退和积分
            IF v_status = 'COMPLETED' THEN
                SET v_actual_duration = 110 + FLOOR(RAND() * 20);  -- 110-130分钟
                SET v_sign_in_time = DATE_ADD(v_start_time, INTERVAL FLOOR(RAND() * 10) MINUTE);
                SET v_sign_out_time = DATE_SUB(v_end_time, INTERVAL FLOOR(RAND() * 10) MINUTE);
                SET v_earned_points = FLOOR(v_actual_duration / 60 * 10);
                SET v_earned_exp = FLOOR(v_actual_duration / 60 * 20);
            ELSE
                SET v_actual_duration = NULL;
                SET v_sign_in_time = NULL;
                SET v_sign_out_time = NULL;
                SET v_earned_points = 0;
                SET v_earned_exp = 0;
            END IF;
            
            INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, 
                status, sign_in_time, sign_out_time, actual_duration, earned_points, earned_exp, source, created_at, updated_at)
            VALUES (v_reservation_no, v_user_id, v_room_id, v_seat_id, v_date, v_time_slot_id, v_start_time, v_end_time,
                v_status, v_sign_in_time, v_sign_out_time, v_actual_duration, v_earned_points, v_earned_exp, 
                CASE WHEN RAND() < 0.8 THEN 'WEB' ELSE 'MOBILE' END,
                DATE_SUB(v_start_time, INTERVAL FLOOR(1 + RAND() * 48) HOUR), 
                CASE WHEN v_status = 'COMPLETED' THEN v_sign_out_time ELSE v_end_time END)
            ON DUPLICATE KEY UPDATE id = id;
        END IF;
        
        SET i = i + 1;
    END WHILE;
    
    -- 生成今天和未来的预约
    SET i = 0;
    WHILE i < 150 DO
        SET v_user_id = FLOOR(1 + RAND() * 25);
        SET v_room_id = FLOOR(1 + RAND() * 18);
        SET v_date = DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 7) DAY);
        SET v_time_slot_id = FLOOR(1 + RAND() * 8);
        
        SELECT id INTO v_seat_id FROM seat WHERE room_id = v_room_id AND status = 1 ORDER BY RAND() LIMIT 1;
        
        IF v_seat_id IS NOT NULL THEN
            CASE v_time_slot_id
                WHEN 1 THEN SET v_start_time = TIMESTAMP(v_date, '07:00:00'), v_end_time = TIMESTAMP(v_date, '09:00:00');
                WHEN 2 THEN SET v_start_time = TIMESTAMP(v_date, '09:00:00'), v_end_time = TIMESTAMP(v_date, '11:00:00');
                WHEN 3 THEN SET v_start_time = TIMESTAMP(v_date, '11:00:00'), v_end_time = TIMESTAMP(v_date, '13:00:00');
                WHEN 4 THEN SET v_start_time = TIMESTAMP(v_date, '13:00:00'), v_end_time = TIMESTAMP(v_date, '15:00:00');
                WHEN 5 THEN SET v_start_time = TIMESTAMP(v_date, '15:00:00'), v_end_time = TIMESTAMP(v_date, '17:00:00');
                WHEN 6 THEN SET v_start_time = TIMESTAMP(v_date, '17:00:00'), v_end_time = TIMESTAMP(v_date, '19:00:00');
                WHEN 7 THEN SET v_start_time = TIMESTAMP(v_date, '19:00:00'), v_end_time = TIMESTAMP(v_date, '21:00:00');
                ELSE SET v_start_time = TIMESTAMP(v_date, '21:00:00'), v_end_time = TIMESTAMP(v_date, '23:00:00');
            END CASE;
            
            SET v_reservation_no = CONCAT('R', DATE_FORMAT(v_date, '%Y%m%d'), LPAD(1500 + i + 1, 6, '0'));
            
            -- 今天已开始的时段为签到中，其他为待签到
            IF v_date = CURDATE() AND v_start_time < NOW() AND v_end_time > NOW() THEN
                SET v_status = 'SIGNED_IN';
                SET v_sign_in_time = DATE_ADD(v_start_time, INTERVAL FLOOR(RAND() * 10) MINUTE);
            ELSEIF v_date = CURDATE() AND v_end_time < NOW() THEN
                SET v_status = 'COMPLETED';
                SET v_sign_in_time = DATE_ADD(v_start_time, INTERVAL FLOOR(RAND() * 10) MINUTE);
                SET v_sign_out_time = DATE_SUB(v_end_time, INTERVAL FLOOR(RAND() * 10) MINUTE);
            ELSE
                SET v_status = 'PENDING';
                SET v_sign_in_time = NULL;
            END IF;
            
            INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, 
                status, sign_in_time, sign_out_time, source, created_at, updated_at)
            VALUES (v_reservation_no, v_user_id, v_room_id, v_seat_id, v_date, v_time_slot_id, v_start_time, v_end_time,
                v_status, v_sign_in_time, v_sign_out_time, 'WEB',
                NOW() - INTERVAL FLOOR(RAND() * 48) HOUR, NOW())
            ON DUPLICATE KEY UPDATE id = id;
        END IF;
        
        SET i = i + 1;
    END WHILE;
END//
DELIMITER ;

CALL generate_reservations();
DROP PROCEDURE generate_reservations;

-- =============================================
-- 第五阶段：信用积分与违规记录
-- =============================================

DELETE FROM credit_record WHERE id > 0;
DELETE FROM violation_record WHERE id > 0;
DELETE FROM blacklist WHERE id > 0;

-- 信用记录数据
INSERT INTO credit_record (user_id, change_score, before_score, after_score, type, source_type, source_id, description, created_at) VALUES
-- 用户1的信用记录
(1, -10, 100, 90, 'DEDUCT', 'VIOLATION', 1, '未按时签到，预约自动取消', NOW() - INTERVAL 45 DAY),
(1, 5, 90, 95, 'RECOVER', 'SYSTEM', NULL, '月度信用恢复', NOW() - INTERVAL 15 DAY),
-- 用户2的信用记录
(2, -5, 100, 95, 'DEDUCT', 'VIOLATION', 2, '预约后临时取消', NOW() - INTERVAL 50 DAY),
(2, -10, 95, 85, 'DEDUCT', 'VIOLATION', 3, '未按时签到', NOW() - INTERVAL 35 DAY),
(2, 3, 85, 88, 'RECOVER', 'SYSTEM', NULL, '月度信用恢复', NOW() - INTERVAL 5 DAY),
-- 用户5的信用记录
(5, -10, 100, 90, 'DEDUCT', 'VIOLATION', 4, '未按时签到', NOW() - INTERVAL 40 DAY),
(5, -5, 90, 85, 'DEDUCT', 'VIOLATION', 5, '暂离超时', NOW() - INTERVAL 25 DAY),
-- 用户6的信用记录
(6, -10, 100, 90, 'DEDUCT', 'VIOLATION', 6, '未按时签到', NOW() - INTERVAL 55 DAY),
(6, -5, 90, 85, 'DEDUCT', 'VIOLATION', 7, '预约后取消', NOW() - INTERVAL 40 DAY),
(6, -5, 85, 80, 'DEDUCT', 'VIOLATION', 8, '暂离超时', NOW() - INTERVAL 28 DAY),
(6, -2, 80, 78, 'DEDUCT', 'VIOLATION', 9, '迟到', NOW() - INTERVAL 15 DAY),
-- 用户10的信用记录
(10, -10, 100, 90, 'DEDUCT', 'VIOLATION', 10, '未按时签到', NOW() - INTERVAL 48 DAY),
(10, -5, 90, 85, 'DEDUCT', 'VIOLATION', 11, '预约后取消', NOW() - INTERVAL 32 DAY),
(10, -3, 85, 82, 'DEDUCT', 'VIOLATION', 12, '暂离超时', NOW() - INTERVAL 18 DAY),
-- 用户12的信用记录
(12, -10, 100, 90, 'DEDUCT', 'VIOLATION', 13, '未按时签到', NOW() - INTERVAL 52 DAY),
(12, -10, 90, 80, 'DEDUCT', 'VIOLATION', 14, '未按时签到', NOW() - INTERVAL 38 DAY),
(12, -5, 80, 75, 'DEDUCT', 'VIOLATION', 15, '预约后取消', NOW() - INTERVAL 22 DAY),
-- 用户16的信用记录
(16, -10, 100, 90, 'DEDUCT', 'VIOLATION', 16, '未按时签到', NOW() - INTERVAL 58 DAY),
(16, -10, 90, 80, 'DEDUCT', 'VIOLATION', 17, '未按时签到', NOW() - INTERVAL 45 DAY),
(16, -10, 80, 70, 'DEDUCT', 'VIOLATION', 18, '未按时签到', NOW() - INTERVAL 30 DAY),
(16, -2, 70, 68, 'DEDUCT', 'VIOLATION', 19, '迟到', NOW() - INTERVAL 15 DAY),
-- 用户20的信用记录
(20, -10, 100, 90, 'DEDUCT', 'VIOLATION', 20, '未按时签到', NOW() - INTERVAL 55 DAY),
(20, -10, 90, 80, 'DEDUCT', 'VIOLATION', 21, '未按时签到', NOW() - INTERVAL 42 DAY),
(20, -5, 80, 75, 'DEDUCT', 'VIOLATION', 22, '预约后取消', NOW() - INTERVAL 28 DAY),
(20, -3, 75, 72, 'DEDUCT', 'VIOLATION', 23, '暂离超时', NOW() - INTERVAL 12 DAY),
-- 黑名单用户的信用记录
(26, -10, 100, 90, 'DEDUCT', 'VIOLATION', 24, '未按时签到', NOW() - INTERVAL 50 DAY),
(26, -10, 90, 80, 'DEDUCT', 'VIOLATION', 25, '未按时签到', NOW() - INTERVAL 40 DAY),
(26, -10, 80, 70, 'DEDUCT', 'VIOLATION', 26, '未按时签到', NOW() - INTERVAL 32 DAY),
(26, -10, 70, 60, 'DEDUCT', 'VIOLATION', 27, '未按时签到', NOW() - INTERVAL 25 DAY),
(26, -10, 60, 50, 'DEDUCT', 'VIOLATION', 28, '未按时签到', NOW() - INTERVAL 18 DAY),
(26, -5, 50, 45, 'DEDUCT', 'VIOLATION', 29, '预约后取消', NOW() - INTERVAL 10 DAY),
(27, -10, 100, 90, 'DEDUCT', 'VIOLATION', 30, '未按时签到', NOW() - INTERVAL 48 DAY),
(27, -10, 90, 80, 'DEDUCT', 'VIOLATION', 31, '未按时签到', NOW() - INTERVAL 38 DAY),
(27, -10, 80, 70, 'DEDUCT', 'VIOLATION', 32, '未按时签到', NOW() - INTERVAL 28 DAY),
(27, -10, 70, 60, 'DEDUCT', 'VIOLATION', 33, '未按时签到', NOW() - INTERVAL 18 DAY),
(27, -5, 60, 55, 'DEDUCT', 'VIOLATION', 34, '预约后取消', NOW() - INTERVAL 8 DAY),
(28, -10, 100, 90, 'DEDUCT', 'VIOLATION', 35, '未按时签到', NOW() - INTERVAL 55 DAY),
(28, -10, 90, 80, 'DEDUCT', 'VIOLATION', 36, '未按时签到', NOW() - INTERVAL 45 DAY),
(28, -10, 80, 70, 'DEDUCT', 'VIOLATION', 37, '未按时签到', NOW() - INTERVAL 35 DAY),
(28, -10, 70, 60, 'DEDUCT', 'VIOLATION', 38, '未按时签到', NOW() - INTERVAL 25 DAY),
(28, -10, 60, 50, 'DEDUCT', 'VIOLATION', 39, '未按时签到', NOW() - INTERVAL 15 DAY),
(28, -10, 50, 40, 'DEDUCT', 'VIOLATION', 40, '未按时签到', NOW() - INTERVAL 8 DAY),
(28, -2, 40, 38, 'DEDUCT', 'VIOLATION', 41, '迟到', NOW() - INTERVAL 3 DAY);

-- 违规记录数据
INSERT INTO violation_record (id, user_id, reservation_id, type, description, deduct_score, before_score, after_score, appeal_status, created_at) VALUES
(1, 1, 15, 'NO_SHOW', '未按时签到，预约自动取消', 10, 100, 90, 0, NOW() - INTERVAL 45 DAY),
(2, 2, 28, 'LATE_CANCEL', '预约开始前30分钟内取消', 5, 100, 95, 0, NOW() - INTERVAL 50 DAY),
(3, 2, 42, 'NO_SHOW', '未按时签到，预约自动取消', 10, 95, 85, 0, NOW() - INTERVAL 35 DAY),
(4, 5, 88, 'NO_SHOW', '未按时签到，预约自动取消', 10, 100, 90, 0, NOW() - INTERVAL 40 DAY),
(5, 5, 95, 'OVERTIME_LEAVE', '暂离超过规定时间，自动签退', 5, 90, 85, 0, NOW() - INTERVAL 25 DAY),
(6, 6, 102, 'NO_SHOW', '未按时签到，预约自动取消', 10, 100, 90, 0, NOW() - INTERVAL 55 DAY),
(7, 6, 115, 'LATE_CANCEL', '预约开始前30分钟内取消', 5, 90, 85, 0, NOW() - INTERVAL 40 DAY),
(8, 6, 128, 'OVERTIME_LEAVE', '暂离超过规定时间，自动签退', 5, 85, 80, 0, NOW() - INTERVAL 28 DAY),
(9, 6, 135, 'LATE', '签到迟到15分钟', 2, 80, 78, 0, NOW() - INTERVAL 15 DAY),
(10, 10, 145, 'NO_SHOW', '未按时签到，预约自动取消', 10, 100, 90, 0, NOW() - INTERVAL 48 DAY),
(11, 10, 155, 'LATE_CANCEL', '预约开始前30分钟内取消', 5, 90, 85, 0, NOW() - INTERVAL 32 DAY),
(12, 10, 168, 'OVERTIME_LEAVE', '暂离超过规定时间', 3, 85, 82, 0, NOW() - INTERVAL 18 DAY),
(13, 12, 178, 'NO_SHOW', '未按时签到', 10, 100, 90, 0, NOW() - INTERVAL 52 DAY),
(14, 12, 188, 'NO_SHOW', '未按时签到', 10, 90, 80, 0, NOW() - INTERVAL 38 DAY),
(15, 12, 198, 'LATE_CANCEL', '预约后取消', 5, 80, 75, 0, NOW() - INTERVAL 22 DAY),
(16, 16, 208, 'NO_SHOW', '未按时签到', 10, 100, 90, 0, NOW() - INTERVAL 58 DAY),
(17, 16, 218, 'NO_SHOW', '未按时签到', 10, 90, 80, 0, NOW() - INTERVAL 45 DAY),
(18, 16, 228, 'NO_SHOW', '未按时签到', 10, 80, 70, 0, NOW() - INTERVAL 30 DAY),
(19, 16, 238, 'LATE', '签到迟到10分钟', 2, 70, 68, 0, NOW() - INTERVAL 15 DAY),
(20, 20, 248, 'NO_SHOW', '未按时签到', 10, 100, 90, 0, NOW() - INTERVAL 55 DAY),
(21, 20, 258, 'NO_SHOW', '未按时签到', 10, 90, 80, 0, NOW() - INTERVAL 42 DAY),
(22, 20, 268, 'LATE_CANCEL', '预约后取消', 5, 80, 75, 0, NOW() - INTERVAL 28 DAY),
(23, 20, 278, 'OVERTIME_LEAVE', '暂离超时', 3, 75, 72, 1, NOW() - INTERVAL 12 DAY),
-- 黑名单用户违规
(24, 26, 288, 'NO_SHOW', '未按时签到', 10, 100, 90, 0, NOW() - INTERVAL 50 DAY),
(25, 26, 298, 'NO_SHOW', '未按时签到', 10, 90, 80, 0, NOW() - INTERVAL 40 DAY),
(26, 26, 308, 'NO_SHOW', '未按时签到', 10, 80, 70, 0, NOW() - INTERVAL 32 DAY),
(27, 26, 318, 'NO_SHOW', '未按时签到', 10, 70, 60, 0, NOW() - INTERVAL 25 DAY),
(28, 26, 328, 'NO_SHOW', '未按时签到', 10, 60, 50, 0, NOW() - INTERVAL 18 DAY),
(29, 26, 338, 'LATE_CANCEL', '预约后取消', 5, 50, 45, 0, NOW() - INTERVAL 10 DAY),
(30, 27, 348, 'NO_SHOW', '未按时签到', 10, 100, 90, 0, NOW() - INTERVAL 48 DAY),
(31, 27, 358, 'NO_SHOW', '未按时签到', 10, 90, 80, 0, NOW() - INTERVAL 38 DAY),
(32, 27, 368, 'NO_SHOW', '未按时签到', 10, 80, 70, 0, NOW() - INTERVAL 28 DAY),
(33, 27, 378, 'NO_SHOW', '未按时签到', 10, 70, 60, 0, NOW() - INTERVAL 18 DAY),
(34, 27, 388, 'LATE_CANCEL', '预约后取消', 5, 60, 55, 0, NOW() - INTERVAL 8 DAY),
(35, 28, 398, 'NO_SHOW', '未按时签到', 10, 100, 90, 0, NOW() - INTERVAL 55 DAY),
(36, 28, 408, 'NO_SHOW', '未按时签到', 10, 90, 80, 0, NOW() - INTERVAL 45 DAY),
(37, 28, 418, 'NO_SHOW', '未按时签到', 10, 80, 70, 0, NOW() - INTERVAL 35 DAY),
(38, 28, 428, 'NO_SHOW', '未按时签到', 10, 70, 60, 0, NOW() - INTERVAL 25 DAY),
(39, 28, 438, 'NO_SHOW', '未按时签到', 10, 60, 50, 0, NOW() - INTERVAL 15 DAY),
(40, 28, 448, 'NO_SHOW', '未按时签到', 10, 50, 40, 0, NOW() - INTERVAL 8 DAY),
(41, 28, 458, 'LATE', '迟到', 2, 40, 38, 0, NOW() - INTERVAL 3 DAY);

-- 黑名单数据
INSERT INTO blacklist (user_id, reason, credit_score_when_added, start_time, end_time, released, created_by, created_at) VALUES
(26, '信用分过低（45分），多次未按时签到', 45, NOW() - INTERVAL 10 DAY, NOW() + INTERVAL 4 DAY, 0, 29, NOW() - INTERVAL 10 DAY),
(27, '信用分过低（55分），累计违规5次', 55, NOW() - INTERVAL 8 DAY, NOW() + INTERVAL 6 DAY, 0, 30, NOW() - INTERVAL 8 DAY),
(28, '信用分过低（38分），严重违规', 38, NOW() - INTERVAL 3 DAY, NOW() + INTERVAL 11 DAY, 0, 29, NOW() - INTERVAL 3 DAY);

-- =============================================
-- 第六阶段：打卡与目标数据
-- =============================================

DELETE FROM check_in_record WHERE id > 0;
DELETE FROM study_goal WHERE id > 0;

-- 打卡数据生成
DELIMITER //
DROP PROCEDURE IF EXISTS generate_checkins//
CREATE PROCEDURE generate_checkins()
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_checkin_date DATE;
    DECLARE day_offset INT;
    DECLARE v_streak INT;
    DECLARE v_earned_points INT;
    DECLARE v_earned_exp INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE user_cursor CURSOR FOR SELECT id FROM user WHERE role = 'STUDENT' AND status = 1 AND id <= 25;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN user_cursor;
    
    user_loop: LOOP
        FETCH user_cursor INTO v_user_id;
        IF done THEN
            LEAVE user_loop;
        END IF;
        
        SET day_offset = 1;
        SET v_streak = 0;
        
        -- 为每个用户生成过去60天的打卡记录（随机打卡率70%）
        WHILE day_offset <= 60 DO
            SET v_checkin_date = DATE_SUB(CURDATE(), INTERVAL day_offset DAY);
            
            -- 70%概率打卡
            IF RAND() < 0.7 THEN
                SET v_streak = v_streak + 1;
                SET v_earned_points = 10 + CASE WHEN v_streak >= 7 THEN 5 WHEN v_streak >= 30 THEN 10 ELSE 0 END;
                SET v_earned_exp = 20 + CASE WHEN v_streak >= 7 THEN 10 WHEN v_streak >= 30 THEN 20 ELSE 0 END;
                
                INSERT INTO check_in_record (user_id, check_in_date, check_in_time, type, earned_points, earned_exp, continuous_days, source, created_at)
                VALUES (v_user_id, v_checkin_date, 
                        TIMESTAMP(v_checkin_date, CONCAT(LPAD(6 + FLOOR(RAND() * 4), 2, '0'), ':', LPAD(FLOOR(RAND() * 60), 2, '0'), ':00')),
                        'DAILY', v_earned_points, v_earned_exp, v_streak, 
                        CASE WHEN RAND() < 0.8 THEN 'WEB' ELSE 'MOBILE' END,
                        TIMESTAMP(v_checkin_date, CONCAT(LPAD(6 + FLOOR(RAND() * 4), 2, '0'), ':', LPAD(FLOOR(RAND() * 60), 2, '0'), ':00')))
                ON DUPLICATE KEY UPDATE continuous_days = VALUES(continuous_days);
            ELSE
                SET v_streak = 0;  -- 断签重置
            END IF;
            
            SET day_offset = day_offset + 1;
        END WHILE;
    END LOOP;
    
    CLOSE user_cursor;
END//
DELIMITER ;

CALL generate_checkins();
DROP PROCEDURE generate_checkins;

-- 学习目标数据
INSERT INTO study_goal (user_id, name, type, target_value, current_value, unit, start_date, end_date, status, reward_points, reward_exp, description, created_at, updated_at) VALUES
-- 用户1的学习目标
(1, '今日学习6小时', 'DAILY', 6.0, 5.5, 'HOUR', CURDATE(), CURDATE(), 'ACTIVE', 20, 40, '每天坚持学习6小时', NOW() - INTERVAL 1 HOUR, NOW()),
(1, '本周学习30小时', 'WEEKLY', 30.0, 28.5, 'HOUR', DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 'ACTIVE', 50, 100, '本周学习目标', NOW() - INTERVAL 5 DAY, NOW()),
(1, '本月学习120小时', 'MONTHLY', 120.0, 95.5, 'HOUR', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 'ACTIVE', 100, 200, '月度学习计划', NOW() - INTERVAL 20 DAY, NOW()),
(1, '连续打卡30天', 'STREAK', 30.0, 18.0, 'DAY', DATE_SUB(CURDATE(), INTERVAL 18 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), 'ACTIVE', 80, 150, '养成学习习惯', NOW() - INTERVAL 18 DAY, NOW()),
-- 用户2的学习目标
(2, '今日学习5小时', 'DAILY', 5.0, 5.0, 'HOUR', CURDATE(), CURDATE(), 'COMPLETED', 15, 30, NULL, NOW() - INTERVAL 2 HOUR, NOW()),
(2, '本周学习25小时', 'WEEKLY', 25.0, 22.3, 'HOUR', DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 'ACTIVE', 40, 80, NULL, NOW() - INTERVAL 4 DAY, NOW()),
(2, '本月学习100小时', 'MONTHLY', 100.0, 78.6, 'HOUR', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 'ACTIVE', 80, 160, NULL, NOW() - INTERVAL 18 DAY, NOW()),
-- 用户3的学习目标（学霸目标更高）
(3, '今日学习8小时', 'DAILY', 8.0, 7.5, 'HOUR', CURDATE(), CURDATE(), 'ACTIVE', 25, 50, '高强度学习日', NOW() - INTERVAL 30 MINUTE, NOW()),
(3, '本周学习45小时', 'WEEKLY', 45.0, 42.8, 'HOUR', DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 'ACTIVE', 70, 140, NULL, NOW() - INTERVAL 6 DAY, NOW()),
(3, '本月学习180小时', 'MONTHLY', 180.0, 165.3, 'HOUR', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 'ACTIVE', 150, 300, '考研冲刺月', NOW() - INTERVAL 22 DAY, NOW()),
(3, '连续打卡60天', 'STREAK', 60.0, 45.0, 'DAY', DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'ACTIVE', 120, 240, NULL, NOW() - INTERVAL 45 DAY, NOW()),
-- 用户4-10的学习目标
(4, '今日学习6小时', 'DAILY', 6.0, 6.5, 'HOUR', CURDATE(), CURDATE(), 'COMPLETED', 20, 40, NULL, NOW() - INTERVAL 3 HOUR, NOW()),
(4, '本周学习35小时', 'WEEKLY', 35.0, 38.2, 'HOUR', DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 'COMPLETED', 55, 110, NULL, NOW() - INTERVAL 3 DAY, NOW()),
(5, '今日学习4小时', 'DAILY', 4.0, 3.2, 'HOUR', CURDATE(), CURDATE(), 'ACTIVE', 12, 24, NULL, NOW() - INTERVAL 45 MINUTE, NOW()),
(5, '本周学习20小时', 'WEEKLY', 20.0, 15.5, 'HOUR', DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 'ACTIVE', 30, 60, NULL, NOW() - INTERVAL 5 DAY, NOW()),
(6, '今日学习5小时', 'DAILY', 5.0, 4.8, 'HOUR', CURDATE(), CURDATE(), 'ACTIVE', 15, 30, NULL, NOW() - INTERVAL 2 HOUR, NOW()),
(6, '本月学习80小时', 'MONTHLY', 80.0, 58.5, 'HOUR', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 'ACTIVE', 60, 120, NULL, NOW() - INTERVAL 15 DAY, NOW()),
(7, '今日学习7小时', 'DAILY', 7.0, 8.2, 'HOUR', CURDATE(), CURDATE(), 'COMPLETED', 22, 44, NULL, NOW() - INTERVAL 1 HOUR, NOW()),
(7, '连续打卡45天', 'STREAK', 45.0, 32.0, 'DAY', DATE_SUB(CURDATE(), INTERVAL 32 DAY), DATE_ADD(CURDATE(), INTERVAL 13 DAY), 'ACTIVE', 90, 180, NULL, NOW() - INTERVAL 32 DAY, NOW()),
(8, '今日学习5小时', 'DAILY', 5.0, 2.5, 'HOUR', CURDATE(), CURDATE(), 'ACTIVE', 15, 30, NULL, NOW() - INTERVAL 4 HOUR, NOW()),
(8, '本周学习28小时', 'WEEKLY', 28.0, 18.6, 'HOUR', DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 'ACTIVE', 42, 84, NULL, NOW() - INTERVAL 4 DAY, NOW()),
(9, '今日学习6小时', 'DAILY', 6.0, 5.8, 'HOUR', CURDATE(), CURDATE(), 'ACTIVE', 18, 36, NULL, NOW() - INTERVAL 50 MINUTE, NOW()),
(9, '本月学习140小时', 'MONTHLY', 140.0, 125.8, 'HOUR', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 'ACTIVE', 110, 220, NULL, NOW() - INTERVAL 20 DAY, NOW()),
(10, '今日学习4小时', 'DAILY', 4.0, 3.5, 'HOUR', CURDATE(), CURDATE(), 'ACTIVE', 12, 24, NULL, NOW() - INTERVAL 3 HOUR, NOW()),
-- 研究生的学习目标
(21, '今日学习8小时', 'DAILY', 8.0, 8.5, 'HOUR', CURDATE(), CURDATE(), 'COMPLETED', 25, 50, NULL, NOW() - INTERVAL 1 HOUR, NOW()),
(21, '本周学习50小时', 'WEEKLY', 50.0, 48.5, 'HOUR', DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 'ACTIVE', 80, 160, NULL, NOW() - INTERVAL 5 DAY, NOW()),
(21, '本月学习200小时', 'MONTHLY', 200.0, 185.6, 'HOUR', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 'ACTIVE', 180, 360, '论文写作月', NOW() - INTERVAL 22 DAY, NOW()),
(22, '今日学习10小时', 'DAILY', 10.0, 9.5, 'HOUR', CURDATE(), CURDATE(), 'ACTIVE', 30, 60, '毕业论文冲刺', NOW() - INTERVAL 30 MINUTE, NOW()),
(22, '连续打卡90天', 'STREAK', 90.0, 75.0, 'DAY', DATE_SUB(CURDATE(), INTERVAL 75 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'ACTIVE', 150, 300, NULL, NOW() - INTERVAL 75 DAY, NOW()),
-- 已失败的目标
(12, '上周学习25小时', 'WEEKLY', 25.0, 12.5, 'HOUR', DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 7 DAY), DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 1 DAY), 'FAILED', 40, 80, NULL, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 3 DAY),
(16, '上月学习80小时', 'MONTHLY', 80.0, 45.3, 'HOUR', DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01'), LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)), 'FAILED', 60, 120, NULL, NOW() - INTERVAL 35 DAY, NOW() - INTERVAL 5 DAY);

-- =============================================
-- 第七阶段：成就系统数据
-- =============================================

DELETE FROM user_achievement WHERE id > 0;
DELETE FROM achievement WHERE id > 0;

-- 成就定义
INSERT INTO achievement (id, name, description, icon, badge_color, category, condition_type, condition_value, reward_points, reward_exp, rarity, is_hidden, sort_order, status, created_at) VALUES
-- 学习时长成就
(1, '学习新手', '累计学习时长达到10小时', 'mdi-clock-outline', '#4CAF50', 'STUDY', 'STUDY_HOURS', 10, 50, 100, 'COMMON', 0, 1, 1, NOW() - INTERVAL 365 DAY),
(2, '学习达人', '累计学习时长达到100小时', 'mdi-clock-check', '#2196F3', 'STUDY', 'STUDY_HOURS', 100, 200, 400, 'RARE', 0, 2, 1, NOW() - INTERVAL 365 DAY),
(3, '学习精英', '累计学习时长达到500小时', 'mdi-clock-star', '#FF9800', 'STUDY', 'STUDY_HOURS', 500, 500, 1000, 'EPIC', 0, 3, 1, NOW() - INTERVAL 365 DAY),
(4, '学习大师', '累计学习时长达到1000小时', 'mdi-star', '#9C27B0', 'STUDY', 'STUDY_HOURS', 1000, 1000, 2000, 'LEGENDARY', 0, 4, 1, NOW() - INTERVAL 365 DAY),
-- 打卡成就
(5, '初次打卡', '完成第一次打卡', 'mdi-checkbox-marked-circle', '#4CAF50', 'CHECKIN', 'TOTAL_CHECKINS', 1, 20, 50, 'COMMON', 0, 10, 1, NOW() - INTERVAL 365 DAY),
(6, '坚持一周', '连续打卡7天', 'mdi-calendar-week', '#4CAF50', 'CHECKIN', 'CONTINUOUS_DAYS', 7, 100, 200, 'COMMON', 0, 11, 1, NOW() - INTERVAL 365 DAY),
(7, '坚持一月', '连续打卡30天', 'mdi-calendar-month', '#2196F3', 'CHECKIN', 'CONTINUOUS_DAYS', 30, 300, 600, 'RARE', 0, 12, 1, NOW() - INTERVAL 365 DAY),
(8, '百日坚持', '连续打卡100天', 'mdi-calendar-check', '#FF9800', 'CHECKIN', 'CONTINUOUS_DAYS', 100, 800, 1500, 'EPIC', 0, 13, 1, NOW() - INTERVAL 365 DAY),
(9, '打卡王者', '连续打卡365天', 'mdi-crown', '#9C27B0', 'CHECKIN', 'CONTINUOUS_DAYS', 365, 2000, 4000, 'LEGENDARY', 0, 14, 1, NOW() - INTERVAL 365 DAY),
-- 预约成就
(10, '首次预约', '完成第一次座位预约', 'mdi-calendar-plus', '#4CAF50', 'RESERVATION', 'TOTAL_RESERVATIONS', 1, 20, 50, 'COMMON', 0, 20, 1, NOW() - INTERVAL 365 DAY),
(11, '预约达人', '累计完成50次预约', 'mdi-calendar-multiple', '#2196F3', 'RESERVATION', 'TOTAL_RESERVATIONS', 50, 200, 400, 'RARE', 0, 21, 1, NOW() - INTERVAL 365 DAY),
(12, '预约专家', '累计完成200次预约', 'mdi-calendar-star', '#FF9800', 'RESERVATION', 'TOTAL_RESERVATIONS', 200, 500, 1000, 'EPIC', 0, 22, 1, NOW() - INTERVAL 365 DAY),
-- 早起成就
(13, '早起鸟', '早上7点前签到', 'mdi-weather-sunny', '#FFC107', 'SPECIAL', 'EARLY_CHECKIN', 1, 30, 60, 'COMMON', 0, 30, 1, NOW() - INTERVAL 365 DAY),
(14, '早起达人', '累计30次早上7点前签到', 'mdi-weather-sunset-up', '#FF9800', 'SPECIAL', 'EARLY_CHECKIN', 30, 200, 400, 'RARE', 0, 31, 1, NOW() - INTERVAL 365 DAY),
(15, '早起王者', '累计100次早上7点前签到', 'mdi-white-balance-sunny', '#FF5722', 'SPECIAL', 'EARLY_CHECKIN', 100, 500, 1000, 'EPIC', 0, 32, 1, NOW() - INTERVAL 365 DAY),
-- 夜猫子成就
(16, '夜猫子', '晚上10点后还在学习', 'mdi-weather-night', '#3F51B5', 'SPECIAL', 'NIGHT_STUDY', 1, 30, 60, 'COMMON', 0, 33, 1, NOW() - INTERVAL 365 DAY),
(17, '深夜学霸', '累计30次晚上10点后学习', 'mdi-moon-waning-crescent', '#673AB7', 'SPECIAL', 'NIGHT_STUDY', 30, 200, 400, 'RARE', 0, 34, 1, NOW() - INTERVAL 365 DAY),
-- 社交成就
(18, '社交新星', '添加第一个好友', 'mdi-account-plus', '#4CAF50', 'SOCIAL', 'TOTAL_FRIENDS', 1, 20, 50, 'COMMON', 0, 40, 1, NOW() - INTERVAL 365 DAY),
(19, '社交达人', '好友数量达到10人', 'mdi-account-group', '#2196F3', 'SOCIAL', 'TOTAL_FRIENDS', 10, 100, 200, 'RARE', 0, 41, 1, NOW() - INTERVAL 365 DAY),
(20, '社交明星', '好友数量达到50人', 'mdi-account-star', '#FF9800', 'SOCIAL', 'TOTAL_FRIENDS', 50, 300, 600, 'EPIC', 0, 42, 1, NOW() - INTERVAL 365 DAY),
-- 小组成就
(21, '小组成员', '加入第一个学习小组', 'mdi-account-multiple-plus', '#4CAF50', 'SOCIAL', 'JOIN_GROUP', 1, 30, 60, 'COMMON', 0, 43, 1, NOW() - INTERVAL 365 DAY),
(22, '小组创建者', '创建一个学习小组', 'mdi-account-multiple-check', '#2196F3', 'SOCIAL', 'CREATE_GROUP', 1, 50, 100, 'RARE', 0, 44, 1, NOW() - INTERVAL 365 DAY),
(23, '小组领袖', '创建的小组成员超过20人', 'mdi-star-circle', '#FF9800', 'SOCIAL', 'GROUP_MEMBERS', 20, 200, 400, 'EPIC', 0, 45, 1, NOW() - INTERVAL 365 DAY),
-- 信用成就
(24, '信用满分', '信用分保持100分', 'mdi-shield-check', '#4CAF50', 'CREDIT', 'CREDIT_SCORE', 100, 100, 200, 'COMMON', 0, 50, 1, NOW() - INTERVAL 365 DAY),
(25, '信用模范', '连续30天信用分100分', 'mdi-shield-star', '#FF9800', 'CREDIT', 'CREDIT_DAYS', 30, 300, 600, 'EPIC', 0, 51, 1, NOW() - INTERVAL 365 DAY),
-- 目标成就
(26, '目标新手', '完成第一个学习目标', 'mdi-flag-checkered', '#4CAF50', 'GOAL', 'TOTAL_GOALS', 1, 30, 60, 'COMMON', 0, 60, 1, NOW() - INTERVAL 365 DAY),
(27, '目标达人', '累计完成20个学习目标', 'mdi-flag-variant', '#2196F3', 'GOAL', 'TOTAL_GOALS', 20, 150, 300, 'RARE', 0, 61, 1, NOW() - INTERVAL 365 DAY),
(28, '目标大师', '累计完成100个学习目标', 'mdi-trophy', '#FF9800', 'GOAL', 'TOTAL_GOALS', 100, 500, 1000, 'EPIC', 0, 62, 1, NOW() - INTERVAL 365 DAY),
-- 积分成就
(29, '积分新秀', '累计获得1000积分', 'mdi-coin', '#4CAF50', 'POINTS', 'TOTAL_POINTS', 1000, 50, 100, 'COMMON', 0, 70, 1, NOW() - INTERVAL 365 DAY),
(30, '积分达人', '累计获得5000积分', 'mdi-gold', '#2196F3', 'POINTS', 'TOTAL_POINTS', 5000, 200, 400, 'RARE', 0, 71, 1, NOW() - INTERVAL 365 DAY),
(31, '积分富翁', '累计获得20000积分', 'mdi-diamond', '#FF9800', 'POINTS', 'TOTAL_POINTS', 20000, 500, 1000, 'EPIC', 0, 72, 1, NOW() - INTERVAL 365 DAY),
-- 特殊成就
(32, '周末战士', '周末学习满8小时', 'mdi-sword', '#E91E63', 'SPECIAL', 'WEEKEND_STUDY', 8, 50, 100, 'COMMON', 0, 80, 1, NOW() - INTERVAL 365 DAY),
(33, '马拉松学习者', '单日学习超过12小时', 'mdi-run-fast', '#9C27B0', 'SPECIAL', 'DAILY_STUDY_MAX', 12, 100, 200, 'RARE', 0, 81, 1, NOW() - INTERVAL 365 DAY),
(34, '全勤奖', '一个月每天都打卡', 'mdi-medal', '#FF9800', 'SPECIAL', 'MONTHLY_CHECKINS', 30, 500, 1000, 'EPIC', 0, 82, 1, NOW() - INTERVAL 365 DAY),
(35, '年度学霸', '年度学习时长排名前10', 'mdi-trophy-award', '#9C27B0', 'SPECIAL', 'YEARLY_RANK', 10, 1000, 2000, 'LEGENDARY', 1, 83, 1, NOW() - INTERVAL 365 DAY);

-- 用户成就数据
INSERT INTO user_achievement (user_id, achievement_id, progress, is_completed, completed_at, is_claimed, claimed_at, created_at, updated_at) VALUES
-- 用户1的成就
(1, 1, 256, 1, NOW() - INTERVAL 150 DAY, 1, NOW() - INTERVAL 149 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 2, 256, 1, NOW() - INTERVAL 80 DAY, 1, NOW() - INTERVAL 79 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 5, 125, 1, NOW() - INTERVAL 178 DAY, 1, NOW() - INTERVAL 177 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 6, 45, 1, NOW() - INTERVAL 170 DAY, 1, NOW() - INTERVAL 169 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 7, 45, 1, NOW() - INTERVAL 140 DAY, 1, NOW() - INTERVAL 139 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 10, 85, 1, NOW() - INTERVAL 179 DAY, 1, NOW() - INTERVAL 178 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 11, 85, 1, NOW() - INTERVAL 60 DAY, 1, NOW() - INTERVAL 59 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 13, 38, 1, NOW() - INTERVAL 165 DAY, 1, NOW() - INTERVAL 164 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 18, 8, 1, NOW() - INTERVAL 150 DAY, 1, NOW() - INTERVAL 149 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 21, 3, 1, NOW() - INTERVAL 120 DAY, 1, NOW() - INTERVAL 119 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 26, 28, 1, NOW() - INTERVAL 100 DAY, 1, NOW() - INTERVAL 99 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 29, 2850, 1, NOW() - INTERVAL 90 DAY, 1, NOW() - INTERVAL 89 DAY, NOW() - INTERVAL 180 DAY, NOW()),
-- 用户2的成就
(2, 1, 198, 1, NOW() - INTERVAL 145 DAY, 1, NOW() - INTERVAL 144 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 2, 198, 1, NOW() - INTERVAL 85 DAY, 1, NOW() - INTERVAL 84 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 5, 98, 1, NOW() - INTERVAL 173 DAY, 1, NOW() - INTERVAL 172 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 6, 32, 1, NOW() - INTERVAL 165 DAY, 1, NOW() - INTERVAL 164 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 10, 62, 1, NOW() - INTERVAL 174 DAY, 1, NOW() - INTERVAL 173 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 11, 62, 1, NOW() - INTERVAL 70 DAY, 1, NOW() - INTERVAL 69 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 16, 25, 1, NOW() - INTERVAL 160 DAY, 1, NOW() - INTERVAL 159 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 18, 6, 1, NOW() - INTERVAL 145 DAY, 1, NOW() - INTERVAL 144 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 22, 1, 1, NOW() - INTERVAL 100 DAY, 1, NOW() - INTERVAL 99 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 29, 2150, 1, NOW() - INTERVAL 95 DAY, 1, NOW() - INTERVAL 94 DAY, NOW() - INTERVAL 175 DAY, NOW()),
-- 用户3的成就（学霸）
(3, 1, 312, 1, NOW() - INTERVAL 155 DAY, 1, NOW() - INTERVAL 154 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 2, 312, 1, NOW() - INTERVAL 75 DAY, 1, NOW() - INTERVAL 74 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 3, 312, 0, NULL, 0, NULL, NOW() - INTERVAL 170 DAY, NOW()),
(3, 5, 168, 1, NOW() - INTERVAL 168 DAY, 1, NOW() - INTERVAL 167 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 6, 60, 1, NOW() - INTERVAL 160 DAY, 1, NOW() - INTERVAL 159 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 7, 60, 1, NOW() - INTERVAL 130 DAY, 1, NOW() - INTERVAL 129 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 8, 60, 0, NULL, 0, NULL, NOW() - INTERVAL 170 DAY, NOW()),
(3, 10, 120, 1, NOW() - INTERVAL 169 DAY, 1, NOW() - INTERVAL 168 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 11, 120, 1, NOW() - INTERVAL 50 DAY, 1, NOW() - INTERVAL 49 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 12, 120, 0, NULL, 0, NULL, NOW() - INTERVAL 170 DAY, NOW()),
(3, 13, 45, 1, NOW() - INTERVAL 155 DAY, 1, NOW() - INTERVAL 154 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 14, 45, 1, NOW() - INTERVAL 80 DAY, 1, NOW() - INTERVAL 79 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 18, 10, 1, NOW() - INTERVAL 140 DAY, 1, NOW() - INTERVAL 139 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 19, 10, 1, NOW() - INTERVAL 100 DAY, 1, NOW() - INTERVAL 99 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 21, 4, 1, NOW() - INTERVAL 110 DAY, 1, NOW() - INTERVAL 109 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 22, 1, 1, NOW() - INTERVAL 90 DAY, 1, NOW() - INTERVAL 89 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 24, 100, 1, NOW() - INTERVAL 120 DAY, 1, NOW() - INTERVAL 119 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 26, 42, 1, NOW() - INTERVAL 95 DAY, 1, NOW() - INTERVAL 94 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 27, 42, 1, NOW() - INTERVAL 45 DAY, 1, NOW() - INTERVAL 44 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 29, 3560, 1, NOW() - INTERVAL 85 DAY, 1, NOW() - INTERVAL 84 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 30, 3560, 0, NULL, 0, NULL, NOW() - INTERVAL 170 DAY, NOW()),
(3, 32, 12, 1, NOW() - INTERVAL 135 DAY, 1, NOW() - INTERVAL 134 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 33, 14, 1, NOW() - INTERVAL 60 DAY, 1, NOW() - INTERVAL 59 DAY, NOW() - INTERVAL 170 DAY, NOW()),
-- 用户4-10的基础成就（简化）
(4, 1, 225, 1, NOW() - INTERVAL 140 DAY, 1, NOW() - INTERVAL 139 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 2, 225, 1, NOW() - INTERVAL 78 DAY, 1, NOW() - INTERVAL 77 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 5, 112, 1, NOW() - INTERVAL 163 DAY, 1, NOW() - INTERVAL 162 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 6, 38, 1, NOW() - INTERVAL 155 DAY, 1, NOW() - INTERVAL 154 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 10, 75, 1, NOW() - INTERVAL 164 DAY, 1, NOW() - INTERVAL 163 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 11, 75, 1, NOW() - INTERVAL 55 DAY, 1, NOW() - INTERVAL 54 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 18, 7, 1, NOW() - INTERVAL 135 DAY, 1, NOW() - INTERVAL 134 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 21, 3, 1, NOW() - INTERVAL 105 DAY, 1, NOW() - INTERVAL 104 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 22, 1, 1, NOW() - INTERVAL 85 DAY, 1, NOW() - INTERVAL 84 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 29, 2680, 1, NOW() - INTERVAL 80 DAY, 1, NOW() - INTERVAL 79 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(5, 1, 165, 1, NOW() - INTERVAL 135 DAY, 1, NOW() - INTERVAL 134 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 2, 165, 1, NOW() - INTERVAL 82 DAY, 1, NOW() - INTERVAL 81 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 5, 76, 1, NOW() - INTERVAL 158 DAY, 1, NOW() - INTERVAL 157 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 6, 25, 1, NOW() - INTERVAL 150 DAY, 1, NOW() - INTERVAL 149 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 10, 55, 1, NOW() - INTERVAL 159 DAY, 1, NOW() - INTERVAL 158 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 11, 55, 1, NOW() - INTERVAL 65 DAY, 1, NOW() - INTERVAL 64 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 18, 8, 1, NOW() - INTERVAL 130 DAY, 1, NOW() - INTERVAL 129 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 21, 4, 1, NOW() - INTERVAL 100 DAY, 1, NOW() - INTERVAL 99 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 22, 1, 1, NOW() - INTERVAL 80 DAY, 1, NOW() - INTERVAL 79 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 23, 28, 1, NOW() - INTERVAL 30 DAY, 1, NOW() - INTERVAL 29 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 29, 1850, 1, NOW() - INTERVAL 75 DAY, 1, NOW() - INTERVAL 74 DAY, NOW() - INTERVAL 160 DAY, NOW()),
-- 研究生用户成就（简化）
(21, 1, 356, 1, NOW() - INTERVAL 180 DAY, 1, NOW() - INTERVAL 179 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 2, 356, 1, NOW() - INTERVAL 100 DAY, 1, NOW() - INTERVAL 99 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 3, 356, 0, NULL, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 5, 185, 1, NOW() - INTERVAL 198 DAY, 1, NOW() - INTERVAL 197 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 6, 75, 1, NOW() - INTERVAL 190 DAY, 1, NOW() - INTERVAL 189 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 7, 75, 1, NOW() - INTERVAL 160 DAY, 1, NOW() - INTERVAL 159 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 8, 75, 0, NULL, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 10, 145, 1, NOW() - INTERVAL 199 DAY, 1, NOW() - INTERVAL 198 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 11, 145, 1, NOW() - INTERVAL 70 DAY, 1, NOW() - INTERVAL 69 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 12, 145, 0, NULL, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 13, 52, 1, NOW() - INTERVAL 185 DAY, 1, NOW() - INTERVAL 184 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 14, 52, 1, NOW() - INTERVAL 95 DAY, 1, NOW() - INTERVAL 94 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 15, 52, 0, NULL, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 16, 38, 1, NOW() - INTERVAL 180 DAY, 1, NOW() - INTERVAL 179 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 17, 38, 1, NOW() - INTERVAL 85 DAY, 1, NOW() - INTERVAL 84 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 18, 15, 1, NOW() - INTERVAL 170 DAY, 1, NOW() - INTERVAL 169 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 19, 15, 1, NOW() - INTERVAL 120 DAY, 1, NOW() - INTERVAL 119 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 21, 2, 1, NOW() - INTERVAL 140 DAY, 1, NOW() - INTERVAL 139 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 26, 35, 1, NOW() - INTERVAL 125 DAY, 1, NOW() - INTERVAL 124 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 27, 35, 1, NOW() - INTERVAL 65 DAY, 1, NOW() - INTERVAL 64 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 29, 4050, 1, NOW() - INTERVAL 105 DAY, 1, NOW() - INTERVAL 104 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 30, 4050, 0, NULL, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 32, 10, 1, NOW() - INTERVAL 165 DAY, 1, NOW() - INTERVAL 164 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 33, 13, 1, NOW() - INTERVAL 80 DAY, 1, NOW() - INTERVAL 79 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(22, 1, 412, 1, NOW() - INTERVAL 175 DAY, 1, NOW() - INTERVAL 174 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 2, 412, 1, NOW() - INTERVAL 95 DAY, 1, NOW() - INTERVAL 94 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 3, 412, 0, NULL, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 5, 198, 1, NOW() - INTERVAL 193 DAY, 1, NOW() - INTERVAL 192 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 6, 90, 1, NOW() - INTERVAL 185 DAY, 1, NOW() - INTERVAL 184 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 7, 90, 1, NOW() - INTERVAL 155 DAY, 1, NOW() - INTERVAL 154 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 8, 90, 0, NULL, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 10, 168, 1, NOW() - INTERVAL 194 DAY, 1, NOW() - INTERVAL 193 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 11, 168, 1, NOW() - INTERVAL 62 DAY, 1, NOW() - INTERVAL 61 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 12, 168, 0, NULL, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 13, 65, 1, NOW() - INTERVAL 180 DAY, 1, NOW() - INTERVAL 179 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 14, 65, 1, NOW() - INTERVAL 88 DAY, 1, NOW() - INTERVAL 87 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 15, 65, 0, NULL, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 18, 18, 1, NOW() - INTERVAL 165 DAY, 1, NOW() - INTERVAL 164 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 19, 18, 1, NOW() - INTERVAL 110 DAY, 1, NOW() - INTERVAL 109 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 21, 3, 1, NOW() - INTERVAL 135 DAY, 1, NOW() - INTERVAL 134 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 24, 100, 1, NOW() - INTERVAL 145 DAY, 1, NOW() - INTERVAL 144 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 25, 58, 1, NOW() - INTERVAL 100 DAY, 1, NOW() - INTERVAL 99 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 26, 42, 1, NOW() - INTERVAL 120 DAY, 1, NOW() - INTERVAL 119 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 27, 42, 1, NOW() - INTERVAL 55 DAY, 1, NOW() - INTERVAL 54 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 28, 42, 0, NULL, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 29, 4680, 1, NOW() - INTERVAL 98 DAY, 1, NOW() - INTERVAL 97 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 30, 4680, 0, NULL, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 32, 12, 1, NOW() - INTERVAL 158 DAY, 1, NOW() - INTERVAL 157 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 33, 15, 1, NOW() - INTERVAL 72 DAY, 1, NOW() - INTERVAL 71 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 34, 32, 1, NOW() - INTERVAL 85 DAY, 1, NOW() - INTERVAL 84 DAY, NOW() - INTERVAL 195 DAY, NOW());

-- =============================================
-- 统计信息
-- =============================================

SET FOREIGN_KEY_CHECKS = 1;

SELECT '====== 全阶段数据插入完成 ======' AS message;
SELECT '第一阶段 - 用户数据：' AS phase, COUNT(*) AS count FROM user;
SELECT '第二阶段 - 自习室数据：' AS phase, COUNT(*) AS count FROM study_room;
SELECT '第二阶段 - 座位数据：' AS phase, COUNT(*) AS count FROM seat;
SELECT '第三阶段 - 时间段数据：' AS phase, COUNT(*) AS count FROM time_slot;
SELECT '第四阶段 - 预约数据：' AS phase, COUNT(*) AS count FROM reservation;
SELECT '第五阶段 - 信用记录：' AS phase, COUNT(*) AS count FROM credit_record;
SELECT '第五阶段 - 违规记录：' AS phase, COUNT(*) AS count FROM violation_record;
SELECT '第五阶段 - 黑名单数据：' AS phase, COUNT(*) AS count FROM blacklist;
SELECT '第六阶段 - 打卡数据：' AS phase, COUNT(*) AS count FROM check_in_record;
SELECT '第六阶段 - 目标数据：' AS phase, COUNT(*) AS count FROM study_goal;
SELECT '第七阶段 - 成就定义：' AS phase, COUNT(*) AS count FROM achievement;
SELECT '第七阶段 - 用户成就：' AS phase, COUNT(*) AS count FROM user_achievement;


-- =============================================
-- 1. 好友关系数据
-- =============================================

-- 清空现有数据
TRUNCATE TABLE friendship;

-- 插入好友关系 (status: 0待确认 1已确认 2已拒绝 3已删除)
INSERT INTO friendship (user_id, friend_id, status, remark, created_at, updated_at) VALUES
-- 张三(1)的好友关系
(1, 2, 1, '室友', NOW() - INTERVAL 30 DAY, NOW() - INTERVAL 29 DAY),
(1, 3, 1, '同班同学', NOW() - INTERVAL 25 DAY, NOW() - INTERVAL 24 DAY),
(1, 4, 1, '学习搭档', NOW() - INTERVAL 20 DAY, NOW() - INTERVAL 19 DAY),
(1, 5, 1, NULL, NOW() - INTERVAL 15 DAY, NOW() - INTERVAL 14 DAY),
(1, 6, 1, '图书馆认识的', NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 9 DAY),
-- 李四(2)的好友关系
(2, 3, 1, NULL, NOW() - INTERVAL 28 DAY, NOW() - INTERVAL 27 DAY),
(2, 4, 1, '老乡', NOW() - INTERVAL 22 DAY, NOW() - INTERVAL 21 DAY),
(2, 7, 1, NULL, NOW() - INTERVAL 18 DAY, NOW() - INTERVAL 17 DAY),
(2, 8, 1, '实验室伙伴', NOW() - INTERVAL 12 DAY, NOW() - INTERVAL 11 DAY),
-- 王五(3)的好友关系
(3, 5, 1, NULL, NOW() - INTERVAL 26 DAY, NOW() - INTERVAL 25 DAY),
(3, 6, 1, '社团认识', NOW() - INTERVAL 20 DAY, NOW() - INTERVAL 19 DAY),
(3, 7, 1, NULL, NOW() - INTERVAL 16 DAY, NOW() - INTERVAL 15 DAY),
(3, 9, 1, '考研战友', NOW() - INTERVAL 8 DAY, NOW() - INTERVAL 7 DAY),
-- 赵六(4)的好友关系
(4, 5, 1, NULL, NOW() - INTERVAL 24 DAY, NOW() - INTERVAL 23 DAY),
(4, 8, 1, '打球认识', NOW() - INTERVAL 14 DAY, NOW() - INTERVAL 13 DAY),
(4, 9, 1, NULL, NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 5 DAY),
(4, 10, 1, '竞赛队友', NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 3 DAY),
-- 待确认的好友请求
(5, 10, 0, NULL, NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 2 DAY),
(6, 9, 0, NULL, NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY),
(7, 10, 0, NULL, NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY),
(8, 1, 0, NULL, NOW() - INTERVAL 3 HOUR, NOW() - INTERVAL 3 HOUR),
(9, 2, 0, NULL, NOW() - INTERVAL 2 HOUR, NOW() - INTERVAL 2 HOUR),
(10, 3, 0, NULL, NOW() - INTERVAL 1 HOUR, NOW() - INTERVAL 1 HOUR),
-- 更多已确认好友
(5, 6, 1, NULL, NOW() - INTERVAL 22 DAY, NOW() - INTERVAL 21 DAY),
(5, 7, 1, '学长', NOW() - INTERVAL 18 DAY, NOW() - INTERVAL 17 DAY),
(5, 8, 1, NULL, NOW() - INTERVAL 14 DAY, NOW() - INTERVAL 13 DAY),
(6, 7, 1, NULL, NOW() - INTERVAL 16 DAY, NOW() - INTERVAL 15 DAY),
(6, 8, 1, '同门师兄', NOW() - INTERVAL 12 DAY, NOW() - INTERVAL 11 DAY),
(7, 8, 1, NULL, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 9 DAY),
(7, 9, 1, '健身房认识', NOW() - INTERVAL 8 DAY, NOW() - INTERVAL 7 DAY),
(8, 9, 1, NULL, NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 5 DAY),
(8, 10, 1, '食堂偶遇', NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 3 DAY),
(9, 10, 1, NULL, NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 1 DAY);

-- =============================================
-- 2. 学习小组数据
-- =============================================

-- 清空现有数据
TRUNCATE TABLE group_member;
TRUNCATE TABLE study_group;

-- 插入学习小组
INSERT INTO study_group (id, name, description, avatar, cover_image, creator_id, max_members, member_count, total_hours, weekly_hours, is_public, need_approve, tags, status, created_at, updated_at) VALUES
(1, '考研冲刺小队', '2026年考研备战群，一起加油！每天打卡学习，互相监督，共同进步。目标院校：985/211', NULL, NULL, 1, 30, 8, 256.5, 42.3, 1, 0, '考研,学习,备战', 1, NOW() - INTERVAL 60 DAY, NOW()),
(2, '英语学习角', '每天坚持英语学习，提高听说读写能力。欢迎四六级、雅思托福备考同学加入！', NULL, NULL, 2, 50, 12, 189.0, 35.6, 1, 0, '英语,四六级,雅思', 1, NOW() - INTERVAL 55 DAY, NOW()),
(3, '数学建模训练营', '数学建模竞赛准备群，定期讨论题目，分享解题思路，培养建模能力', NULL, NULL, 3, 20, 6, 120.5, 28.4, 1, 1, '数学建模,竞赛,算法', 1, NOW() - INTERVAL 50 DAY, NOW()),
(4, '编程刷题小组', 'LeetCode每日一题，算法面试准备，大厂实习/秋招备战中', NULL, NULL, 4, 40, 15, 320.8, 55.2, 1, 0, '编程,LeetCode,算法', 1, NOW() - INTERVAL 45 DAY, NOW()),
(5, '图书馆自习联盟', '每天图书馆打卡，互相监督学习，养成良好学习习惯', NULL, NULL, 5, 100, 28, 580.5, 98.7, 1, 0, '自习,图书馆,打卡', 1, NOW() - INTERVAL 40 DAY, NOW()),
(6, '司法考试备考群', '法考备战小组，资料分享，经验交流，一起上岸！', NULL, NULL, 6, 25, 9, 145.2, 31.5, 1, 1, '法考,司法考试,法律', 1, NOW() - INTERVAL 35 DAY, NOW()),
(7, 'CPA学习小组', '注册会计师考试备考群，科目交流，资料共享', NULL, NULL, 7, 30, 11, 210.6, 38.9, 1, 0, 'CPA,会计,财务', 1, NOW() - INTERVAL 30 DAY, NOW()),
(8, '医学生自习室', '医学生专属学习小组，解剖、生理、病理一起学', NULL, NULL, 8, 35, 14, 285.3, 48.6, 1, 1, '医学,考研,临床', 1, NOW() - INTERVAL 25 DAY, NOW()),
(9, '计算机考研408', '计算机408专业课备考群，数据结构、操作系统、计网、组原', NULL, NULL, 9, 40, 18, 356.8, 62.4, 1, 0, '408,计算机,考研', 1, NOW() - INTERVAL 20 DAY, NOW()),
(10, '早起打卡群', '每天6点起床打卡，养成早起习惯，一起成为更好的自己', NULL, NULL, 10, 80, 35, 420.5, 75.3, 1, 0, '早起,打卡,习惯', 1, NOW() - INTERVAL 15 DAY, NOW()),
(11, '晚间自习室', '晚上7-10点固定学习时间，提高学习效率', NULL, NULL, 1, 60, 22, 198.6, 45.2, 1, 0, '晚自习,效率,学习', 1, NOW() - INTERVAL 10 DAY, NOW()),
(12, '周末学习团', '周末不躺平，一起来学习！', NULL, NULL, 2, 45, 16, 125.8, 32.5, 1, 0, '周末,学习,自律', 1, NOW() - INTERVAL 5 DAY, NOW()),
(13, '论文写作互助组', '毕业论文写作交流，互相review，一起顺利毕业', NULL, NULL, 3, 20, 8, 85.3, 22.6, 1, 1, '论文,写作,毕业', 1, NOW() - INTERVAL 3 DAY, NOW()),
(14, '雅思7分冲刺班', '目标雅思7分以上，口语写作重点突破', NULL, NULL, 4, 25, 10, 156.2, 38.5, 1, 1, '雅思,留学,英语', 1, NOW() - INTERVAL 2 DAY, NOW()),
(15, '托福备考小队', '托福100+冲刺，词汇、听力、写作专项训练', NULL, NULL, 5, 25, 7, 98.5, 28.3, 1, 0, '托福,留学,美国', 1, NOW() - INTERVAL 1 DAY, NOW());

-- =============================================
-- 3. 小组成员数据
-- =============================================

-- 考研冲刺小队(1)成员
INSERT INTO group_member (group_id, user_id, role, nickname, contribution_hours, join_time, status, created_at) VALUES
(1, 1, 'CREATOR', NULL, 45.5, NOW() - INTERVAL 60 DAY, 1, NOW() - INTERVAL 60 DAY),
(1, 2, 'ADMIN', '考研先锋', 38.2, NOW() - INTERVAL 58 DAY, 1, NOW() - INTERVAL 58 DAY),
(1, 3, 'MEMBER', NULL, 32.8, NOW() - INTERVAL 55 DAY, 1, NOW() - INTERVAL 55 DAY),
(1, 4, 'MEMBER', '数学小王子', 28.5, NOW() - INTERVAL 50 DAY, 1, NOW() - INTERVAL 50 DAY),
(1, 5, 'MEMBER', NULL, 35.2, NOW() - INTERVAL 45 DAY, 1, NOW() - INTERVAL 45 DAY),
(1, 6, 'MEMBER', NULL, 26.3, NOW() - INTERVAL 40 DAY, 1, NOW() - INTERVAL 40 DAY),
(1, 7, 'MEMBER', '英语达人', 22.8, NOW() - INTERVAL 30 DAY, 1, NOW() - INTERVAL 30 DAY),
(1, 8, 'MEMBER', NULL, 27.2, NOW() - INTERVAL 20 DAY, 1, NOW() - INTERVAL 20 DAY),

-- 英语学习角(2)成员
(2, 2, 'CREATOR', NULL, 28.5, NOW() - INTERVAL 55 DAY, 1, NOW() - INTERVAL 55 DAY),
(2, 1, 'ADMIN', NULL, 22.3, NOW() - INTERVAL 52 DAY, 1, NOW() - INTERVAL 52 DAY),
(2, 3, 'MEMBER', '口语练习者', 18.6, NOW() - INTERVAL 48 DAY, 1, NOW() - INTERVAL 48 DAY),
(2, 4, 'MEMBER', NULL, 15.8, NOW() - INTERVAL 45 DAY, 1, NOW() - INTERVAL 45 DAY),
(2, 5, 'MEMBER', NULL, 20.2, NOW() - INTERVAL 40 DAY, 1, NOW() - INTERVAL 40 DAY),
(2, 6, 'MEMBER', '单词背诵王', 16.5, NOW() - INTERVAL 35 DAY, 1, NOW() - INTERVAL 35 DAY),
(2, 7, 'MEMBER', NULL, 12.8, NOW() - INTERVAL 30 DAY, 1, NOW() - INTERVAL 30 DAY),
(2, 8, 'MEMBER', NULL, 14.3, NOW() - INTERVAL 25 DAY, 1, NOW() - INTERVAL 25 DAY),
(2, 9, 'MEMBER', '听力狂魔', 18.5, NOW() - INTERVAL 20 DAY, 1, NOW() - INTERVAL 20 DAY),
(2, 10, 'MEMBER', NULL, 10.2, NOW() - INTERVAL 15 DAY, 1, NOW() - INTERVAL 15 DAY),

-- 数学建模训练营(3)成员
(3, 3, 'CREATOR', NULL, 35.2, NOW() - INTERVAL 50 DAY, 1, NOW() - INTERVAL 50 DAY),
(3, 1, 'MEMBER', NULL, 22.5, NOW() - INTERVAL 45 DAY, 1, NOW() - INTERVAL 45 DAY),
(3, 4, 'ADMIN', '模型大师', 28.3, NOW() - INTERVAL 40 DAY, 1, NOW() - INTERVAL 40 DAY),
(3, 5, 'MEMBER', NULL, 18.6, NOW() - INTERVAL 35 DAY, 1, NOW() - INTERVAL 35 DAY),
(3, 9, 'MEMBER', 'MATLAB专家', 15.9, NOW() - INTERVAL 20 DAY, 1, NOW() - INTERVAL 20 DAY),

-- 编程刷题小组(4)成员
(4, 4, 'CREATOR', NULL, 42.5, NOW() - INTERVAL 45 DAY, 1, NOW() - INTERVAL 45 DAY),
(4, 1, 'ADMIN', '算法小能手', 35.8, NOW() - INTERVAL 42 DAY, 1, NOW() - INTERVAL 42 DAY),
(4, 2, 'MEMBER', NULL, 28.6, NOW() - INTERVAL 40 DAY, 1, NOW() - INTERVAL 40 DAY),
(4, 3, 'MEMBER', 'Java选手', 32.5, NOW() - INTERVAL 38 DAY, 1, NOW() - INTERVAL 38 DAY),
(4, 5, 'MEMBER', NULL, 25.3, NOW() - INTERVAL 35 DAY, 1, NOW() - INTERVAL 35 DAY),
(4, 6, 'MEMBER', 'Python爱好者', 22.8, NOW() - INTERVAL 32 DAY, 1, NOW() - INTERVAL 32 DAY),
(4, 7, 'MEMBER', NULL, 18.5, NOW() - INTERVAL 28 DAY, 1, NOW() - INTERVAL 28 DAY),
(4, 8, 'MEMBER', 'C++大神', 26.3, NOW() - INTERVAL 25 DAY, 1, NOW() - INTERVAL 25 DAY),
(4, 9, 'MEMBER', NULL, 30.2, NOW() - INTERVAL 20 DAY, 1, NOW() - INTERVAL 20 DAY),
(4, 10, 'MEMBER', '前端工程师', 15.6, NOW() - INTERVAL 15 DAY, 1, NOW() - INTERVAL 15 DAY),

-- 图书馆自习联盟(5)成员
(5, 5, 'CREATOR', NULL, 38.5, NOW() - INTERVAL 40 DAY, 1, NOW() - INTERVAL 40 DAY),
(5, 1, 'ADMIN', NULL, 32.6, NOW() - INTERVAL 38 DAY, 1, NOW() - INTERVAL 38 DAY),
(5, 2, 'ADMIN', '自习室常客', 28.8, NOW() - INTERVAL 36 DAY, 1, NOW() - INTERVAL 36 DAY),
(5, 3, 'MEMBER', NULL, 25.3, NOW() - INTERVAL 34 DAY, 1, NOW() - INTERVAL 34 DAY),
(5, 4, 'MEMBER', '学霸', 35.2, NOW() - INTERVAL 32 DAY, 1, NOW() - INTERVAL 32 DAY),
(5, 6, 'MEMBER', NULL, 22.5, NOW() - INTERVAL 30 DAY, 1, NOW() - INTERVAL 30 DAY),
(5, 7, 'MEMBER', '图书馆守门人', 28.6, NOW() - INTERVAL 28 DAY, 1, NOW() - INTERVAL 28 DAY),
(5, 8, 'MEMBER', NULL, 20.3, NOW() - INTERVAL 25 DAY, 1, NOW() - INTERVAL 25 DAY),
(5, 9, 'MEMBER', NULL, 18.5, NOW() - INTERVAL 22 DAY, 1, NOW() - INTERVAL 22 DAY),
(5, 10, 'MEMBER', '自习达人', 15.8, NOW() - INTERVAL 18 DAY, 1, NOW() - INTERVAL 18 DAY),

-- 早起打卡群(10)成员 - 大群
(10, 10, 'CREATOR', NULL, 25.5, NOW() - INTERVAL 15 DAY, 1, NOW() - INTERVAL 15 DAY),
(10, 1, 'ADMIN', '早起鸟', 22.3, NOW() - INTERVAL 14 DAY, 1, NOW() - INTERVAL 14 DAY),
(10, 2, 'ADMIN', NULL, 18.6, NOW() - INTERVAL 13 DAY, 1, NOW() - INTERVAL 13 DAY),
(10, 3, 'MEMBER', '6点起床党', 15.8, NOW() - INTERVAL 12 DAY, 1, NOW() - INTERVAL 12 DAY),
(10, 4, 'MEMBER', NULL, 20.2, NOW() - INTERVAL 11 DAY, 1, NOW() - INTERVAL 11 DAY),
(10, 5, 'MEMBER', NULL, 16.5, NOW() - INTERVAL 10 DAY, 1, NOW() - INTERVAL 10 DAY),
(10, 6, 'MEMBER', '晨跑达人', 12.8, NOW() - INTERVAL 9 DAY, 1, NOW() - INTERVAL 9 DAY),
(10, 7, 'MEMBER', NULL, 14.3, NOW() - INTERVAL 8 DAY, 1, NOW() - INTERVAL 8 DAY),
(10, 8, 'MEMBER', NULL, 18.5, NOW() - INTERVAL 7 DAY, 1, NOW() - INTERVAL 7 DAY),
(10, 9, 'MEMBER', '早读小组长', 10.2, NOW() - INTERVAL 6 DAY, 1, NOW() - INTERVAL 6 DAY);

-- 待审批的加入申请
INSERT INTO group_member (group_id, user_id, role, nickname, contribution_hours, join_time, status, created_at) VALUES
(3, 6, 'MEMBER', NULL, 0, NULL, 0, NOW() - INTERVAL 2 DAY),
(3, 7, 'MEMBER', NULL, 0, NULL, 0, NOW() - INTERVAL 1 DAY),
(6, 1, 'MEMBER', NULL, 0, NULL, 0, NOW() - INTERVAL 3 DAY),
(6, 2, 'MEMBER', NULL, 0, NULL, 0, NOW() - INTERVAL 2 DAY),
(8, 1, 'MEMBER', NULL, 0, NULL, 0, NOW() - INTERVAL 1 DAY),
(8, 3, 'MEMBER', NULL, 0, NULL, 0, NOW() - INTERVAL 12 HOUR),
(13, 4, 'MEMBER', NULL, 0, NULL, 0, NOW() - INTERVAL 6 HOUR),
(14, 6, 'MEMBER', NULL, 0, NULL, 0, NOW() - INTERVAL 3 HOUR);

-- =============================================
-- 4. 消息数据
-- =============================================

-- 清空现有数据
TRUNCATE TABLE message;

-- 插入系统消息
INSERT INTO message (user_id, title, content, type, related_type, related_id, is_read, read_time, created_at) VALUES
-- 用户1的消息
(1, '欢迎加入智慧自习室', '欢迎您注册智慧自习室座位预约系统！请先完善个人信息，开始您的学习之旅。', 'SYSTEM', NULL, NULL, 1, NOW() - INTERVAL 59 DAY, NOW() - INTERVAL 60 DAY),
(1, '预约成功通知', '您已成功预约图书馆四楼自习室A-15座位，时间：今日14:00-18:00，请准时签到。', 'RESERVATION', 'RESERVATION', 1, 1, NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 7 DAY),
(1, '签到提醒', '您的预约即将开始，请在15分钟内完成签到，否则预约将自动取消。', 'RESERVATION', 'RESERVATION', 1, 1, NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 6 DAY),
(1, '学习目标完成', '恭喜！您已完成本周学习目标：累计学习20小时。继续保持！', 'SYSTEM', NULL, NULL, 1, NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 5 DAY),
(1, '成就解锁通知', '恭喜您解锁成就「初次打卡」！获得50积分奖励。', 'ACHIEVEMENT', 'ACHIEVEMENT', 1, 1, NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 4 DAY),
(1, '好友请求', '用户周八请求添加您为好友', 'FRIEND', 'FRIEND', 22, 0, NULL, NOW() - INTERVAL 3 HOUR),
(1, '小组邀请', '您收到一条加入「考研冲刺小队」的邀请', 'GROUP', 'GROUP', 1, 0, NULL, NOW() - INTERVAL 2 HOUR),
(1, '签退成功', '您已成功签退，本次学习时长4小时，获得积分40分、经验值80。', 'RESERVATION', 'RESERVATION', 1, 0, NULL, NOW() - INTERVAL 1 HOUR),

-- 用户2的消息
(2, '欢迎加入智慧自习室', '欢迎您注册智慧自习室座位预约系统！', 'SYSTEM', NULL, NULL, 1, NOW() - INTERVAL 58 DAY, NOW() - INTERVAL 59 DAY),
(2, '预约成功通知', '您已成功预约研究生自习室B-08座位', 'RESERVATION', 'RESERVATION', 2, 1, NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 5 DAY),
(2, '违约提醒', '您因未按时签到，本次预约已自动取消，信用分-5分。', 'VIOLATION', NULL, NULL, 1, NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 4 DAY),
(2, '好友已通过', '张三已接受您的好友请求', 'FRIEND', 'FRIEND', 1, 1, NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY),
(2, '入组申请通过', '您加入「英语学习角」的申请已通过', 'GROUP', 'GROUP', 2, 0, NULL, NOW() - INTERVAL 2 DAY),
(2, '连续打卡奖励', '恭喜！您已连续打卡7天，获得额外50积分奖励！', 'SYSTEM', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),

-- 用户3的消息
(3, '欢迎加入智慧自习室', '欢迎您注册智慧自习室座位预约系统！', 'SYSTEM', NULL, NULL, 1, NOW() - INTERVAL 57 DAY, NOW() - INTERVAL 58 DAY),
(3, '成就解锁通知', '恭喜您解锁成就「学习达人」！累计学习100小时。', 'ACHIEVEMENT', 'ACHIEVEMENT', 5, 1, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 10 DAY),
(3, '小组数据周报', '本周「数学建模训练营」共学习28.4小时，排名第3！', 'GROUP', 'GROUP', 3, 1, NOW() - INTERVAL 7 DAY, NOW() - INTERVAL 6 DAY),
(3, '好友请求', '用户吴十请求添加您为好友', 'FRIEND', 'FRIEND', 26, 0, NULL, NOW() - INTERVAL 1 HOUR),

-- 用户4的消息
(4, '预约成功通知', '您已成功预约图书馆三楼A区C-22座位', 'RESERVATION', 'RESERVATION', 3, 1, NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY),
(4, '成就解锁通知', '恭喜您解锁成就「编程高手」！刷题满100道。', 'ACHIEVEMENT', 'ACHIEVEMENT', 8, 0, NULL, NOW() - INTERVAL 2 DAY),
(4, '小组成员加入', '新成员「张三」加入了您创建的小组「编程刷题小组」', 'GROUP', 'GROUP', 4, 0, NULL, NOW() - INTERVAL 1 DAY),

-- 用户5的消息
(5, '信用分恢复通知', '根据系统规则，您的信用分已恢复5分，当前信用分95分。', 'SYSTEM', NULL, NULL, 1, NOW() - INTERVAL 15 DAY, NOW() - INTERVAL 15 DAY),
(5, '小组周报', '本周「图书馆自习联盟」表现优秀，总学习时长98.7小时！', 'GROUP', 'GROUP', 5, 0, NULL, NOW() - INTERVAL 7 DAY),
(5, '好友请求待处理', '用户吴十请求添加您为好友', 'FRIEND', 'FRIEND', 19, 0, NULL, NOW() - INTERVAL 2 DAY),

-- 用户6-10的消息
(6, '入组申请待审批', '您申请加入「司法考试备考群」，请等待管理员审核', 'GROUP', 'GROUP', 6, 1, NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY),
(6, '好友请求', '用户郑九请求添加您为好友', 'FRIEND', 'FRIEND', 20, 0, NULL, NOW() - INTERVAL 1 DAY),

(7, '成就解锁通知', '恭喜您解锁成就「早起鸟」！连续7天6点前打卡。', 'ACHIEVEMENT', 'ACHIEVEMENT', 12, 0, NULL, NOW() - INTERVAL 5 DAY),
(7, '好友请求待处理', '用户吴十请求添加您为好友', 'FRIEND', 'FRIEND', 21, 0, NULL, NOW() - INTERVAL 1 DAY),

(8, '预约取消通知', '您的预约已被系统取消，原因：超时未签到。', 'RESERVATION', 'RESERVATION', 5, 1, NOW() - INTERVAL 8 DAY, NOW() - INTERVAL 8 DAY),
(8, '小组成员移除通知', '您已被移出小组「早起打卡群」', 'GROUP', 'GROUP', 10, 0, NULL, NOW() - INTERVAL 2 DAY),

(9, '系统维护通知', '系统将于今晚22:00-24:00进行维护，届时无法预约，请提前安排。', 'NOTICE', NULL, NULL, 1, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 9 DAY),
(9, '好友请求', '用户李四请求添加您为好友', 'FRIEND', 'FRIEND', 23, 0, NULL, NOW() - INTERVAL 2 HOUR),

(10, '小组创建成功', '恭喜！您成功创建了小组「早起打卡群」', 'GROUP', 'GROUP', 10, 1, NOW() - INTERVAL 15 DAY, NOW() - INTERVAL 15 DAY),
(10, '成就解锁通知', '恭喜您解锁成就「社交达人」！好友数量达到10人。', 'ACHIEVEMENT', 'ACHIEVEMENT', 15, 0, NULL, NOW() - INTERVAL 3 DAY),
(10, '入组申请通知', '用户张三申请加入您创建的小组「早起打卡群」', 'GROUP', 'GROUP', 10, 0, NULL, NOW() - INTERVAL 1 DAY);

-- 批量插入更多消息（每个用户多一些历史消息）
INSERT INTO message (user_id, title, content, type, related_type, related_id, is_read, read_time, created_at) VALUES
-- 更多预约相关消息
(1, '预约成功通知', '您已成功预约图书馆四楼自习室A-12座位，时间：2026-01-15 09:00-12:00', 'RESERVATION', 'RESERVATION', 10, 1, NOW() - INTERVAL 20 DAY, NOW() - INTERVAL 21 DAY),
(1, '签退成功', '您已成功签退，本次学习时长3小时。', 'RESERVATION', 'RESERVATION', 10, 1, NOW() - INTERVAL 20 DAY, NOW() - INTERVAL 20 DAY),
(2, '预约成功通知', '您已成功预约研究生自习室B-05座位', 'RESERVATION', 'RESERVATION', 11, 1, NOW() - INTERVAL 18 DAY, NOW() - INTERVAL 18 DAY),
(3, '预约成功通知', '您已成功预约图书馆三楼A区C-18座位', 'RESERVATION', 'RESERVATION', 12, 1, NOW() - INTERVAL 16 DAY, NOW() - INTERVAL 16 DAY),
(4, '座位暂离提醒', '您已暂离30分钟，请尽快返回，超过60分钟将自动签退。', 'RESERVATION', 'RESERVATION', 13, 1, NOW() - INTERVAL 14 DAY, NOW() - INTERVAL 14 DAY),
(5, '预约成功通知', '您已成功预约图书馆四楼自习室A-20座位', 'RESERVATION', 'RESERVATION', 14, 1, NOW() - INTERVAL 12 DAY, NOW() - INTERVAL 12 DAY),

-- 更多成就消息
(1, '成就解锁通知', '恭喜您解锁成就「坚持不懈」！连续打卡30天。', 'ACHIEVEMENT', 'ACHIEVEMENT', 3, 1, NOW() - INTERVAL 30 DAY, NOW() - INTERVAL 30 DAY),
(2, '成就解锁通知', '恭喜您解锁成就「预约达人」！累计预约50次。', 'ACHIEVEMENT', 'ACHIEVEMENT', 6, 1, NOW() - INTERVAL 25 DAY, NOW() - INTERVAL 25 DAY),
(3, '成就解锁通知', '恭喜您解锁成就「积分富翁」！累计获得1000积分。', 'ACHIEVEMENT', 'ACHIEVEMENT', 10, 1, NOW() - INTERVAL 22 DAY, NOW() - INTERVAL 22 DAY),
(4, '成就解锁通知', '恭喜您解锁成就「夜猫子」！累计夜间学习50小时。', 'ACHIEVEMENT', 'ACHIEVEMENT', 11, 0, NULL, NOW() - INTERVAL 8 DAY),
(5, '成就解锁通知', '恭喜您解锁成就「周末战士」！连续4个周末打卡。', 'ACHIEVEMENT', 'ACHIEVEMENT', 13, 0, NULL, NOW() - INTERVAL 5 DAY),

-- 更多小组消息
(1, '小组周报', '本周您在「考研冲刺小队」学习了8.5小时，继续加油！', 'GROUP', 'GROUP', 1, 1, NOW() - INTERVAL 14 DAY, NOW() - INTERVAL 14 DAY),
(2, '小组数据更新', '「英语学习角」本周新增3名成员，大家一起进步！', 'GROUP', 'GROUP', 2, 1, NOW() - INTERVAL 12 DAY, NOW() - INTERVAL 12 DAY),
(3, '小组公告', '「数学建模训练营」将于本周六举行线上交流会，请准时参加。', 'GROUP', 'GROUP', 3, 0, NULL, NOW() - INTERVAL 4 DAY),
(4, '小组排名上升', '恭喜！「编程刷题小组」本周学习时长排名上升至第2名！', 'GROUP', 'GROUP', 4, 0, NULL, NOW() - INTERVAL 3 DAY),
(5, '新成员加入', '欢迎新成员加入「图书馆自习联盟」，目前成员数：28人', 'GROUP', 'GROUP', 5, 0, NULL, NOW() - INTERVAL 2 DAY),

-- 系统公告
(1, '新功能上线通知', '智慧自习室新增「学习小组」功能，快来创建或加入小组，和同学一起学习吧！', 'NOTICE', NULL, NULL, 1, NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 45 DAY),
(2, '新功能上线通知', '智慧自习室新增「学习小组」功能，快来创建或加入小组，和同学一起学习吧！', 'NOTICE', NULL, NULL, 1, NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 44 DAY),
(3, '新功能上线通知', '智慧自习室新增「学习小组」功能，快来创建或加入小组，和同学一起学习吧！', 'NOTICE', NULL, NULL, 1, NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 44 DAY),
(4, '新功能上线通知', '智慧自习室新增「学习小组」功能，快来创建或加入小组，和同学一起学习吧！', 'NOTICE', NULL, NULL, 1, NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 44 DAY),
(5, '新功能上线通知', '智慧自习室新增「学习小组」功能，快来创建或加入小组，和同学一起学习吧！', 'NOTICE', NULL, NULL, 1, NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 44 DAY),

(1, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),
(2, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),
(3, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),
(4, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),
(5, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),
(6, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),
(7, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),
(8, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),
(9, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY),
(10, '期末考试温馨提示', '期末考试周即将来临，自习室将延长开放时间至23:00，请合理安排学习时间。', 'NOTICE', NULL, NULL, 0, NULL, NOW() - INTERVAL 1 DAY);

-- =============================================
-- 5. 统计信息
-- =============================================

SELECT '社交功能数据插入完成！' AS message;
SELECT '好友关系数量：' AS label, COUNT(*) AS count FROM friendship;
SELECT '学习小组数量：' AS label, COUNT(*) AS count FROM study_group;
SELECT '小组成员数量：' AS label, COUNT(*) AS count FROM group_member;
SELECT '消息数量：' AS label, COUNT(*) AS count FROM message;

-- =============================================
-- 第九阶段：积分商城数据
-- =============================================

-- 插入示例商品数据
INSERT INTO `point_product` (`name`, `description`, `image`, `category`, `points_cost`, `stock`, `limit_per_user`, `status`, `sort_order`) VALUES
('VIP学习座位1天', '体验VIP专属座位，享受更舒适的学习环境', '/images/shop/vip-seat.png', 'VIRTUAL', 50, -1, 3, 1, 1),
('延时签到券', '预约后可延迟30分钟签到，不计违约', '/images/shop/delay-ticket.png', 'COUPON', 30, -1, 5, 1, 2),
('优先预约特权', '高峰时段优先预约权限（3天有效）', '/images/shop/priority.png', 'VIRTUAL', 100, -1, 1, 1, 3),
('学习小台灯', '便携式护眼小台灯，USB充电', '/images/shop/lamp.png', 'PHYSICAL', 200, 50, 1, 1, 4),
('精美笔记本', '高品质皮面笔记本，A5尺寸', '/images/shop/notebook.png', 'PHYSICAL', 80, 100, 2, 1, 5),
('定制U盘 32G', '学习资料存储神器，精美定制款', '/images/shop/usb.png', 'PHYSICAL', 150, 30, 1, 1, 6),
('咖啡厅代金券', '校园咖啡厅10元代金券', '/images/shop/coffee.png', 'COUPON', 60, 200, 5, 1, 7),
('打印代金券', '图书馆打印室5元代金券', '/images/shop/print.png', 'COUPON', 25, 500, 10, 1, 8),
('学霸徽章', '限量版学霸徽章，彰显学习成就', '/images/shop/badge.png', 'PHYSICAL', 300, 20, 1, 1, 9),
('年度VIP会员', '一年VIP会员资格，享受所有特权', '/images/shop/vip-year.png', 'VIRTUAL', 500, 10, 1, 1, 10);

-- 插入一些兑换记录示例
INSERT INTO `point_exchange` (`exchange_no`, `user_id`, `product_id`, `product_name`, `product_image`, `points_cost`, `quantity`, `status`, `redeem_code`, `complete_time`, `create_time`) VALUES
('EX1705123456001', 1, 1, 'VIP学习座位1天', '/images/shop/vip-seat.png', 50, 1, 'COMPLETED', 'VIP-ABCD-1234', NOW(), DATE_SUB(NOW(), INTERVAL 5 DAY)),
('EX1705123456002', 1, 2, '延时签到券', '/images/shop/delay-ticket.png', 30, 1, 'COMPLETED', 'DLY-EFGH-5678', NOW(), DATE_SUB(NOW(), INTERVAL 3 DAY)),
('EX1705123456003', 2, 5, '精美笔记本', '/images/shop/notebook.png', 80, 1, 'PROCESSING', NULL, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
('EX1705123456004', 3, 7, '咖啡厅代金券', '/images/shop/coffee.png', 60, 2, 'COMPLETED', 'COF-IJKL-9012', NOW(), DATE_SUB(NOW(), INTERVAL 2 DAY));

-- =====================================================
-- 数据初始化完成
-- =====================================================
SET FOREIGN_KEY_CHECKS = 1;

SELECT '====== 全部数据初始化完成 ======' AS message;
SELECT '用户数据:' AS phase, COUNT(*) AS count FROM user;
SELECT '自习室数据:' AS phase, COUNT(*) AS count FROM study_room;
SELECT '座位数据:' AS phase, COUNT(*) AS count FROM seat;
SELECT '预约数据:' AS phase, COUNT(*) AS count FROM reservation;
SELECT '成就数据:' AS phase, COUNT(*) AS count FROM achievement;
SELECT '好友关系:' AS phase, COUNT(*) AS count FROM friendship;
SELECT '学习小组:' AS phase, COUNT(*) AS count FROM study_group;
SELECT '商城商品:' AS phase, COUNT(*) AS count FROM point_product;
