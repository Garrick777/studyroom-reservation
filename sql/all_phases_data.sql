-- =============================================
-- 智慧自习室系统 - 全阶段测试数据
-- =============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 第一阶段：用户模块数据
-- =============================================

TRUNCATE TABLE user;

-- 密码统一为: password123 (BCrypt加密)
-- BCrypt hash: $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi

INSERT INTO user (id, username, password, real_name, student_id, email, phone, avatar, role, credit_score, total_study_hours, total_points, exp, status, created_at, updated_at) VALUES
-- 普通学生用户
(1, 'zhangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张三', '2022001001', 'zhangsan@edu.cn', '13800001001', NULL, 'STUDENT', 95, 256.5, 2850, 5120, 1, NOW() - INTERVAL 180 DAY, NOW()),
(2, 'lisi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '李四', '2022001002', 'lisi@edu.cn', '13800001002', NULL, 'STUDENT', 88, 198.3, 2150, 4280, 1, NOW() - INTERVAL 175 DAY, NOW()),
(3, 'wangwu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '王五', '2022001003', 'wangwu@edu.cn', '13800001003', NULL, 'STUDENT', 100, 312.8, 3560, 6850, 1, NOW() - INTERVAL 170 DAY, NOW()),
(4, 'zhaoliu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '赵六', '2022001004', 'zhaoliu@edu.cn', '13800001004', NULL, 'STUDENT', 92, 225.6, 2680, 5460, 1, NOW() - INTERVAL 165 DAY, NOW()),
(5, 'sunqi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '孙七', '2022001005', 'sunqi@edu.cn', '13800001005', NULL, 'STUDENT', 85, 165.2, 1850, 3520, 1, NOW() - INTERVAL 160 DAY, NOW()),
(6, 'zhouba', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '周八', '2022001006', 'zhouba@edu.cn', '13800001006', NULL, 'STUDENT', 78, 142.5, 1580, 2960, 1, NOW() - INTERVAL 155 DAY, NOW()),
(7, 'wujiu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '吴九', '2022001007', 'wujiu@edu.cn', '13800001007', NULL, 'STUDENT', 100, 285.3, 3250, 6280, 1, NOW() - INTERVAL 150 DAY, NOW()),
(8, 'zhengshi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '郑十', '2022001008', 'zhengshi@edu.cn', '13800001008', NULL, 'STUDENT', 90, 178.6, 2050, 4150, 1, NOW() - INTERVAL 145 DAY, NOW()),
(9, 'chenyi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '陈一', '2022001009', 'chenyi@edu.cn', '13800001009', NULL, 'STUDENT', 97, 245.8, 2780, 5560, 1, NOW() - INTERVAL 140 DAY, NOW()),
(10, 'liner', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '林二', '2022001010', 'liner@edu.cn', '13800001010', NULL, 'STUDENT', 82, 135.2, 1450, 2850, 1, NOW() - INTERVAL 135 DAY, NOW()),
-- 更多学生 (11-30)
(11, 'huangsan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黄三', '2022001011', 'huangsan@edu.cn', '13800001011', NULL, 'STUDENT', 100, 298.5, 3380, 6520, 1, NOW() - INTERVAL 130 DAY, NOW()),
(12, 'xusi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '徐四', '2022001012', 'xusi@edu.cn', '13800001012', NULL, 'STUDENT', 75, 98.6, 1120, 2150, 1, NOW() - INTERVAL 125 DAY, NOW()),
(13, 'mawu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '马五', '2022001013', 'mawu@edu.cn', '13800001013', NULL, 'STUDENT', 93, 215.8, 2450, 4850, 1, NOW() - INTERVAL 120 DAY, NOW()),
(14, 'gaoliu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '高六', '2022001014', 'gaoliu@edu.cn', '13800001014', NULL, 'STUDENT', 88, 168.5, 1920, 3850, 1, NOW() - INTERVAL 115 DAY, NOW()),
(15, 'liuqi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '刘七', '2022001015', 'liuqi@edu.cn', '13800001015', NULL, 'STUDENT', 100, 325.6, 3680, 7150, 1, NOW() - INTERVAL 110 DAY, NOW()),
(16, 'yangba', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '杨八', '2022001016', 'yangba@edu.cn', '13800001016', NULL, 'STUDENT', 68, 85.3, 980, 1850, 1, NOW() - INTERVAL 105 DAY, NOW()),
(17, 'hujiu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '胡九', '2022001017', 'hujiu@edu.cn', '13800001017', NULL, 'STUDENT', 95, 265.8, 3020, 5980, 1, NOW() - INTERVAL 100 DAY, NOW()),
(18, 'zhushi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '朱十', '2022001018', 'zhushi@edu.cn', '13800001018', NULL, 'STUDENT', 85, 156.2, 1780, 3520, 1, NOW() - INTERVAL 95 DAY, NOW()),
(19, 'qianyi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '钱一', '2022001019', 'qianyi@edu.cn', '13800001019', NULL, 'STUDENT', 91, 198.5, 2280, 4520, 1, NOW() - INTERVAL 90 DAY, NOW()),
(20, 'fenger', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '冯二', '2022001020', 'fenger@edu.cn', '13800001020', NULL, 'STUDENT', 72, 78.5, 920, 1680, 1, NOW() - INTERVAL 85 DAY, NOW()),
-- 研究生用户 (21-25)
(21, 'wangyanyi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '王研一', 'G2024001', 'wangyanyi@edu.cn', '13800002001', NULL, 'STUDENT', 98, 356.8, 4050, 7850, 1, NOW() - INTERVAL 200 DAY, NOW()),
(22, 'liyaner', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '李研二', 'G2024002', 'liyaner@edu.cn', '13800002002', NULL, 'STUDENT', 100, 412.5, 4680, 8950, 1, NOW() - INTERVAL 195 DAY, NOW()),
(23, 'zhangyansan', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '张研三', 'G2024003', 'zhangyansan@edu.cn', '13800002003', NULL, 'STUDENT', 95, 285.6, 3250, 6480, 1, NOW() - INTERVAL 190 DAY, NOW()),
(24, 'zhaoyensi', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '赵研四', 'G2024004', 'zhaoyensi@edu.cn', '13800002004', NULL, 'STUDENT', 88, 225.8, 2580, 5120, 1, NOW() - INTERVAL 185 DAY, NOW()),
(25, 'sunyanwu', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '孙研五', 'G2024005', 'sunyanwu@edu.cn', '13800002005', NULL, 'STUDENT', 92, 265.3, 3020, 5980, 1, NOW() - INTERVAL 180 DAY, NOW()),
-- 黑名单用户 (26-28)
(26, 'heiming1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黑名单用户一', '2022002001', 'heiming1@edu.cn', '13800003001', NULL, 'STUDENT', 45, 25.5, 280, 520, 2, NOW() - INTERVAL 60 DAY, NOW()),
(27, 'heiming2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黑名单用户二', '2022002002', 'heiming2@edu.cn', '13800003002', NULL, 'STUDENT', 55, 32.8, 350, 680, 2, NOW() - INTERVAL 55 DAY, NOW()),
(28, 'heiming3', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '黑名单用户三', '2022002003', 'heiming3@edu.cn', '13800003003', NULL, 'STUDENT', 38, 18.5, 180, 350, 2, NOW() - INTERVAL 50 DAY, NOW()),
-- 管理员用户 (29-31)
(29, 'admin1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '管理员一', 'A001', 'admin1@edu.cn', '13800009001', NULL, 'ADMIN', 100, 0, 0, 0, 1, NOW() - INTERVAL 365 DAY, NOW()),
(30, 'admin2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '管理员二', 'A002', 'admin2@edu.cn', '13800009002', NULL, 'ADMIN', 100, 0, 0, 0, 1, NOW() - INTERVAL 360 DAY, NOW()),
(31, 'superadmin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '超级管理员', 'SA001', 'superadmin@edu.cn', '13800009999', NULL, 'SUPER_ADMIN', 100, 0, 0, 0, 1, NOW() - INTERVAL 400 DAY, NOW());

-- =============================================
-- 第二阶段：教学楼、自习室、座位数据
-- =============================================

TRUNCATE TABLE seat;
TRUNCATE TABLE room;
TRUNCATE TABLE building;

-- 教学楼数据
INSERT INTO building (id, name, code, description, location, floors, open_time, close_time, status, created_at, updated_at) VALUES
(1, '图书馆', 'LIB', '校园主图书馆，含多个自习区域', '校园中心区域', 5, '07:00', '23:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(2, '教学楼A', 'TA', '主教学楼，含教室和自习室', '校园东区', 6, '06:30', '22:30', 1, NOW() - INTERVAL 365 DAY, NOW()),
(3, '教学楼B', 'TB', '副教学楼，含实验室和自习室', '校园东区', 5, '07:00', '22:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(4, '研究生楼', 'GR', '研究生专用教学楼', '校园北区', 8, '06:00', '24:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(5, '综合楼', 'CO', '综合教学办公楼', '校园西区', 4, '08:00', '21:00', 1, NOW() - INTERVAL 365 DAY, NOW());

-- 自习室数据
INSERT INTO room (id, building_id, name, code, floor, capacity, description, facilities, open_time, close_time, status, created_at, updated_at) VALUES
-- 图书馆自习室
(1, 1, '图书馆一楼大厅自习区', 'LIB-1F-A', 1, 80, '开放式自习区，环境明亮', '空调,WiFi,充电插座', '07:00', '23:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(2, 1, '图书馆二楼电子阅览室', 'LIB-2F-E', 2, 60, '配备电脑的阅览室', '空调,WiFi,电脑,打印机', '07:30', '22:30', 1, NOW() - INTERVAL 365 DAY, NOW()),
(3, 1, '图书馆三楼静音自习室A', 'LIB-3F-A', 3, 50, '严格静音区域', '空调,WiFi,台灯', '07:00', '23:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(4, 1, '图书馆三楼静音自习室B', 'LIB-3F-B', 3, 50, '严格静音区域', '空调,WiFi,台灯', '07:00', '23:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(5, 1, '图书馆四楼自习室', 'LIB-4F', 4, 100, '大型自习室', '空调,WiFi,充电插座', '07:00', '23:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(6, 1, '图书馆五楼考研自习室', 'LIB-5F', 5, 80, '考研专用自习室', '空调,WiFi,独立书桌', '06:30', '23:30', 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 教学楼A自习室
(7, 2, '教A-101自习室', 'TA-101', 1, 60, '普通自习室', '空调,WiFi', '06:30', '22:30', 1, NOW() - INTERVAL 365 DAY, NOW()),
(8, 2, '教A-201多媒体自习室', 'TA-201', 2, 45, '配有投影设备', '空调,WiFi,投影仪', '07:00', '22:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(9, 2, '教A-301自习室', 'TA-301', 3, 55, '普通自习室', '空调,WiFi', '07:00', '22:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(10, 2, '教A-401自习室', 'TA-401', 4, 50, '普通自习室', '空调,WiFi', '07:00', '22:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 教学楼B自习室
(11, 3, '教B-102计算机自习室', 'TB-102', 1, 40, '配备计算机', '空调,WiFi,电脑', '07:00', '22:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(12, 3, '教B-203自习室', 'TB-203', 2, 48, '普通自习室', '空调,WiFi', '07:00', '21:30', 1, NOW() - INTERVAL 365 DAY, NOW()),
(13, 3, '教B-304自习室', 'TB-304', 3, 52, '普通自习室', '空调,WiFi', '07:00', '21:30', 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 研究生楼自习室
(14, 4, '研究生自习室A', 'GR-201', 2, 70, '研究生专用', '空调,WiFi,独立桌椅', '06:00', '24:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(15, 4, '研究生自习室B', 'GR-301', 3, 65, '研究生专用', '空调,WiFi,独立桌椅', '06:00', '24:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(16, 4, '研究生静音室', 'GR-401', 4, 40, '研究生静音学习区', '空调,WiFi,台灯', '06:00', '24:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
(17, 4, '博士研讨室', 'GR-501', 5, 25, '博士生专用', '空调,WiFi,投影,白板', '08:00', '23:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 综合楼自习室
(18, 5, '综合楼自习室', 'CO-201', 2, 35, '小型自习室', '空调,WiFi', '08:00', '21:00', 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 维护中的自习室
(19, 2, '教A-501自习室', 'TA-501', 5, 45, '普通自习室（维护中）', '空调,WiFi', '07:00', '22:00', 0, NOW() - INTERVAL 365 DAY, NOW()),
(20, 3, '教B-401实验室', 'TB-401', 4, 30, '实验室（维护中）', '空调,WiFi,实验设备', '08:00', '20:00', 0, NOW() - INTERVAL 365 DAY, NOW());

-- 座位数据生成 (为每个自习室生成座位)
-- 使用存储过程批量生成座位
DELIMITER //
DROP PROCEDURE IF EXISTS generate_seats//
CREATE PROCEDURE generate_seats()
BEGIN
    DECLARE room_id INT;
    DECLARE room_capacity INT;
    DECLARE room_status INT;
    DECLARE seat_num INT;
    DECLARE row_num INT;
    DECLARE col_num INT;
    DECLARE seat_type VARCHAR(20);
    DECLARE has_power INT;
    DECLARE has_usb INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE room_cursor CURSOR FOR SELECT id, capacity, status FROM room;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN room_cursor;
    
    room_loop: LOOP
        FETCH room_cursor INTO room_id, room_capacity, room_status;
        IF done THEN
            LEAVE room_loop;
        END IF;
        
        SET seat_num = 1;
        SET row_num = 1;
        SET col_num = 1;
        
        WHILE seat_num <= room_capacity DO
            -- 随机分配座位类型
            SET seat_type = CASE 
                WHEN RAND() < 0.6 THEN 'NORMAL'
                WHEN RAND() < 0.8 THEN 'WINDOW'
                WHEN RAND() < 0.95 THEN 'CORNER'
                ELSE 'ACCESSIBLE'
            END;
            
            -- 随机分配电源和USB
            SET has_power = IF(RAND() < 0.7, 1, 0);
            SET has_usb = IF(RAND() < 0.5, 1, 0);
            
            INSERT INTO seat (room_id, seat_number, row_num, col_num, seat_type, has_power, has_usb, status, created_at, updated_at)
            VALUES (room_id, CONCAT('S', LPAD(seat_num, 3, '0')), row_num, col_num, seat_type, has_power, has_usb, 
                    CASE 
                        WHEN room_status = 0 THEN 2  -- 维护中的房间，座位也维护中
                        WHEN RAND() < 0.05 THEN 2   -- 5%概率维护中
                        ELSE 1 
                    END,
                    NOW() - INTERVAL 365 DAY, NOW());
            
            SET seat_num = seat_num + 1;
            SET col_num = col_num + 1;
            IF col_num > 10 THEN
                SET col_num = 1;
                SET row_num = row_num + 1;
            END IF;
        END WHILE;
    END LOOP;
    
    CLOSE room_cursor;
END//
DELIMITER ;

CALL generate_seats();
DROP PROCEDURE generate_seats;

-- =============================================
-- 第四阶段：预约数据
-- =============================================

TRUNCATE TABLE reservation;

-- 生成历史预约数据 (过去60天)
DELIMITER //
DROP PROCEDURE IF EXISTS generate_reservations//
CREATE PROCEDURE generate_reservations()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE user_id INT;
    DECLARE seat_id INT;
    DECLARE res_date DATE;
    DECLARE start_time TIME;
    DECLARE end_time TIME;
    DECLARE res_status INT;
    DECLARE check_in_time DATETIME;
    DECLARE check_out_time DATETIME;
    DECLARE study_hours DECIMAL(4,2);
    
    -- 生成2000条历史预约记录
    WHILE i < 2000 DO
        SET user_id = FLOOR(1 + RAND() * 25);  -- 用户1-25
        SET seat_id = FLOOR(1 + RAND() * 900);  -- 假设有约900个座位
        SET res_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 60) DAY);
        
        -- 随机时间段
        CASE FLOOR(RAND() * 5)
            WHEN 0 THEN SET start_time = '08:00:00', end_time = '12:00:00';
            WHEN 1 THEN SET start_time = '09:00:00', end_time = '12:00:00';
            WHEN 2 THEN SET start_time = '14:00:00', end_time = '18:00:00';
            WHEN 3 THEN SET start_time = '18:30:00', end_time = '21:30:00';
            ELSE SET start_time = '19:00:00', end_time = '22:00:00';
        END CASE;
        
        -- 随机状态 (已完成70%, 已取消15%, 未签到10%, 其他5%)
        SET res_status = CASE 
            WHEN RAND() < 0.70 THEN 4  -- COMPLETED
            WHEN RAND() < 0.85 THEN 3  -- CANCELLED
            WHEN RAND() < 0.95 THEN 5  -- NO_SHOW
            ELSE 2  -- CHECKED_IN (少量当前进行中)
        END;
        
        -- 计算学习时长和签到签退时间
        IF res_status = 4 THEN
            SET study_hours = TIMESTAMPDIFF(MINUTE, start_time, end_time) / 60.0;
            SET check_in_time = TIMESTAMP(res_date, ADDTIME(start_time, SEC_TO_TIME(FLOOR(RAND() * 600))));  -- 签到时间略有延迟
            SET check_out_time = TIMESTAMP(res_date, SUBTIME(end_time, SEC_TO_TIME(FLOOR(RAND() * 600))));  -- 签退时间略早
        ELSEIF res_status = 2 THEN
            SET study_hours = 0;
            SET check_in_time = NOW() - INTERVAL FLOOR(RAND() * 120) MINUTE;
            SET check_out_time = NULL;
        ELSE
            SET study_hours = 0;
            SET check_in_time = NULL;
            SET check_out_time = NULL;
        END IF;
        
        INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, check_in_time, check_out_time, actual_hours, created_at, updated_at)
        VALUES (user_id, seat_id, res_date, start_time, end_time, res_status, check_in_time, check_out_time, study_hours,
                TIMESTAMP(res_date, SUBTIME(start_time, '01:00:00')), 
                CASE WHEN res_status IN (4, 3, 5) THEN TIMESTAMP(res_date, end_time) ELSE NOW() END)
        ON DUPLICATE KEY UPDATE id = id;  -- 忽略重复
        
        SET i = i + 1;
    END WHILE;
    
    -- 生成今天和未来几天的预约
    SET i = 0;
    WHILE i < 200 DO
        SET user_id = FLOOR(1 + RAND() * 25);
        SET seat_id = FLOOR(1 + RAND() * 900);
        SET res_date = DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 7) DAY);
        
        CASE FLOOR(RAND() * 5)
            WHEN 0 THEN SET start_time = '08:00:00', end_time = '12:00:00';
            WHEN 1 THEN SET start_time = '09:00:00', end_time = '12:00:00';
            WHEN 2 THEN SET start_time = '14:00:00', end_time = '18:00:00';
            WHEN 3 THEN SET start_time = '18:30:00', end_time = '21:30:00';
            ELSE SET start_time = '19:00:00', end_time = '22:00:00';
        END CASE;
        
        INSERT INTO reservation (user_id, seat_id, reservation_date, start_time, end_time, status, created_at, updated_at)
        VALUES (user_id, seat_id, res_date, start_time, end_time, 
                CASE WHEN res_date = CURDATE() AND start_time < CURTIME() THEN 2 ELSE 1 END,  -- 今天已过时间的为已签到，否则待签到
                NOW() - INTERVAL FLOOR(RAND() * 48) HOUR, NOW())
        ON DUPLICATE KEY UPDATE id = id;
        
        SET i = i + 1;
    END WHILE;
END//
DELIMITER ;

CALL generate_reservations();
DROP PROCEDURE generate_reservations;

-- =============================================
-- 第五阶段：信用积分与违规记录
-- =============================================

TRUNCATE TABLE credit_record;
TRUNCATE TABLE violation_record;

-- 信用记录数据
INSERT INTO credit_record (user_id, change_type, change_value, before_score, after_score, reason, related_type, related_id, created_at) VALUES
-- 用户1的信用记录
(1, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 15, NOW() - INTERVAL 45 DAY),
(1, 'RECOVER', 5, 90, 95, '月度信用恢复', 'SYSTEM', NULL, NOW() - INTERVAL 15 DAY),
-- 用户2的信用记录
(2, 'DEDUCT', -5, 100, 95, '预约后取消', 'RESERVATION', 28, NOW() - INTERVAL 50 DAY),
(2, 'DEDUCT', -10, 95, 85, '未按时签到', 'RESERVATION', 42, NOW() - INTERVAL 35 DAY),
(2, 'RECOVER', 3, 85, 88, '月度信用恢复', 'SYSTEM', NULL, NOW() - INTERVAL 5 DAY),
-- 用户5的信用记录
(5, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 88, NOW() - INTERVAL 40 DAY),
(5, 'DEDUCT', -5, 90, 85, '暂离超时', 'RESERVATION', 95, NOW() - INTERVAL 25 DAY),
(5, 'RECOVER', 0, 85, 85, '信用恢复失败（有违规）', 'SYSTEM', NULL, NOW() - INTERVAL 15 DAY),
-- 用户6的信用记录
(6, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 102, NOW() - INTERVAL 55 DAY),
(6, 'DEDUCT', -5, 90, 85, '预约后取消', 'RESERVATION', 115, NOW() - INTERVAL 40 DAY),
(6, 'DEDUCT', -5, 85, 80, '暂离超时', 'RESERVATION', 128, NOW() - INTERVAL 28 DAY),
(6, 'DEDUCT', -2, 80, 78, '迟到', 'RESERVATION', 135, NOW() - INTERVAL 15 DAY),
-- 用户10的信用记录  
(10, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 145, NOW() - INTERVAL 48 DAY),
(10, 'DEDUCT', -5, 90, 85, '预约后取消', 'RESERVATION', 155, NOW() - INTERVAL 32 DAY),
(10, 'DEDUCT', -3, 85, 82, '暂离超时', 'RESERVATION', 168, NOW() - INTERVAL 18 DAY),
-- 用户12的信用记录
(12, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 178, NOW() - INTERVAL 52 DAY),
(12, 'DEDUCT', -10, 90, 80, '未按时签到', 'RESERVATION', 188, NOW() - INTERVAL 38 DAY),
(12, 'DEDUCT', -5, 80, 75, '预约后取消', 'RESERVATION', 198, NOW() - INTERVAL 22 DAY),
-- 用户16的信用记录
(16, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 208, NOW() - INTERVAL 58 DAY),
(16, 'DEDUCT', -10, 90, 80, '未按时签到', 'RESERVATION', 218, NOW() - INTERVAL 45 DAY),
(16, 'DEDUCT', -10, 80, 70, '未按时签到', 'RESERVATION', 228, NOW() - INTERVAL 30 DAY),
(16, 'DEDUCT', -2, 70, 68, '迟到', 'RESERVATION', 238, NOW() - INTERVAL 15 DAY),
-- 用户20的信用记录
(20, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 248, NOW() - INTERVAL 55 DAY),
(20, 'DEDUCT', -10, 90, 80, '未按时签到', 'RESERVATION', 258, NOW() - INTERVAL 42 DAY),
(20, 'DEDUCT', -5, 80, 75, '预约后取消', 'RESERVATION', 268, NOW() - INTERVAL 28 DAY),
(20, 'DEDUCT', -3, 75, 72, '暂离超时', 'RESERVATION', 278, NOW() - INTERVAL 12 DAY),
-- 黑名单用户的信用记录
(26, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 288, NOW() - INTERVAL 50 DAY),
(26, 'DEDUCT', -10, 90, 80, '未按时签到', 'RESERVATION', 298, NOW() - INTERVAL 40 DAY),
(26, 'DEDUCT', -10, 80, 70, '未按时签到', 'RESERVATION', 308, NOW() - INTERVAL 32 DAY),
(26, 'DEDUCT', -10, 70, 60, '未按时签到', 'RESERVATION', 318, NOW() - INTERVAL 25 DAY),
(26, 'DEDUCT', -10, 60, 50, '未按时签到', 'RESERVATION', 328, NOW() - INTERVAL 18 DAY),
(26, 'DEDUCT', -5, 50, 45, '预约后取消', 'RESERVATION', 338, NOW() - INTERVAL 10 DAY),
(27, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 348, NOW() - INTERVAL 48 DAY),
(27, 'DEDUCT', -10, 90, 80, '未按时签到', 'RESERVATION', 358, NOW() - INTERVAL 38 DAY),
(27, 'DEDUCT', -10, 80, 70, '未按时签到', 'RESERVATION', 368, NOW() - INTERVAL 28 DAY),
(27, 'DEDUCT', -10, 70, 60, '未按时签到', 'RESERVATION', 378, NOW() - INTERVAL 18 DAY),
(27, 'DEDUCT', -5, 60, 55, '预约后取消', 'RESERVATION', 388, NOW() - INTERVAL 8 DAY),
(28, 'DEDUCT', -10, 100, 90, '未按时签到', 'RESERVATION', 398, NOW() - INTERVAL 55 DAY),
(28, 'DEDUCT', -10, 90, 80, '未按时签到', 'RESERVATION', 408, NOW() - INTERVAL 45 DAY),
(28, 'DEDUCT', -10, 80, 70, '未按时签到', 'RESERVATION', 418, NOW() - INTERVAL 35 DAY),
(28, 'DEDUCT', -10, 70, 60, '未按时签到', 'RESERVATION', 428, NOW() - INTERVAL 25 DAY),
(28, 'DEDUCT', -10, 60, 50, '未按时签到', 'RESERVATION', 438, NOW() - INTERVAL 15 DAY),
(28, 'DEDUCT', -10, 50, 40, '未按时签到', 'RESERVATION', 448, NOW() - INTERVAL 8 DAY),
(28, 'DEDUCT', -2, 40, 38, '迟到', 'RESERVATION', 458, NOW() - INTERVAL 3 DAY);

-- 违规记录数据
INSERT INTO violation_record (user_id, type, description, penalty_score, reservation_id, handled, handled_by, handled_at, handled_remark, created_at, updated_at) VALUES
-- 对应上述信用扣分的违规记录
(1, 'NO_SHOW', '未按时签到，预约自动取消', 10, 15, 1, 29, NOW() - INTERVAL 44 DAY, '系统自动处理', NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 44 DAY),
(2, 'LATE_CANCEL', '预约开始前30分钟内取消', 5, 28, 1, 29, NOW() - INTERVAL 49 DAY, '系统自动处理', NOW() - INTERVAL 50 DAY, NOW() - INTERVAL 49 DAY),
(2, 'NO_SHOW', '未按时签到，预约自动取消', 10, 42, 1, 29, NOW() - INTERVAL 34 DAY, '系统自动处理', NOW() - INTERVAL 35 DAY, NOW() - INTERVAL 34 DAY),
(5, 'NO_SHOW', '未按时签到，预约自动取消', 10, 88, 1, 29, NOW() - INTERVAL 39 DAY, '系统自动处理', NOW() - INTERVAL 40 DAY, NOW() - INTERVAL 39 DAY),
(5, 'OVERTIME_LEAVE', '暂离超过规定时间，自动签退', 5, 95, 1, 29, NOW() - INTERVAL 24 DAY, '系统自动处理', NOW() - INTERVAL 25 DAY, NOW() - INTERVAL 24 DAY),
(6, 'NO_SHOW', '未按时签到，预约自动取消', 10, 102, 1, 30, NOW() - INTERVAL 54 DAY, '系统自动处理', NOW() - INTERVAL 55 DAY, NOW() - INTERVAL 54 DAY),
(6, 'LATE_CANCEL', '预约开始前30分钟内取消', 5, 115, 1, 30, NOW() - INTERVAL 39 DAY, '系统自动处理', NOW() - INTERVAL 40 DAY, NOW() - INTERVAL 39 DAY),
(6, 'OVERTIME_LEAVE', '暂离超过规定时间，自动签退', 5, 128, 1, 30, NOW() - INTERVAL 27 DAY, '系统自动处理', NOW() - INTERVAL 28 DAY, NOW() - INTERVAL 27 DAY),
(6, 'LATE', '签到迟到15分钟', 2, 135, 1, 30, NOW() - INTERVAL 14 DAY, '系统自动处理', NOW() - INTERVAL 15 DAY, NOW() - INTERVAL 14 DAY),
(10, 'NO_SHOW', '未按时签到，预约自动取消', 10, 145, 1, 29, NOW() - INTERVAL 47 DAY, '系统自动处理', NOW() - INTERVAL 48 DAY, NOW() - INTERVAL 47 DAY),
(10, 'LATE_CANCEL', '预约开始前30分钟内取消', 5, 155, 1, 29, NOW() - INTERVAL 31 DAY, '系统自动处理', NOW() - INTERVAL 32 DAY, NOW() - INTERVAL 31 DAY),
(10, 'OVERTIME_LEAVE', '暂离超过规定时间，自动签退', 3, 168, 1, 29, NOW() - INTERVAL 17 DAY, '系统自动处理', NOW() - INTERVAL 18 DAY, NOW() - INTERVAL 17 DAY),
-- 更多违规记录
(12, 'NO_SHOW', '未按时签到，预约自动取消', 10, 178, 1, 30, NOW() - INTERVAL 51 DAY, '系统自动处理', NOW() - INTERVAL 52 DAY, NOW() - INTERVAL 51 DAY),
(12, 'NO_SHOW', '未按时签到，预约自动取消', 10, 188, 1, 30, NOW() - INTERVAL 37 DAY, '系统自动处理', NOW() - INTERVAL 38 DAY, NOW() - INTERVAL 37 DAY),
(12, 'LATE_CANCEL', '预约开始前30分钟内取消', 5, 198, 1, 30, NOW() - INTERVAL 21 DAY, '系统自动处理', NOW() - INTERVAL 22 DAY, NOW() - INTERVAL 21 DAY),
(16, 'NO_SHOW', '未按时签到，预约自动取消', 10, 208, 1, 29, NOW() - INTERVAL 57 DAY, '系统自动处理', NOW() - INTERVAL 58 DAY, NOW() - INTERVAL 57 DAY),
(16, 'NO_SHOW', '未按时签到，预约自动取消', 10, 218, 1, 29, NOW() - INTERVAL 44 DAY, '系统自动处理', NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 44 DAY),
(16, 'NO_SHOW', '未按时签到，预约自动取消', 10, 228, 1, 29, NOW() - INTERVAL 29 DAY, '系统自动处理', NOW() - INTERVAL 30 DAY, NOW() - INTERVAL 29 DAY),
(16, 'LATE', '签到迟到10分钟', 2, 238, 1, 29, NOW() - INTERVAL 14 DAY, '系统自动处理', NOW() - INTERVAL 15 DAY, NOW() - INTERVAL 14 DAY),
-- 待处理的违规（未处理）
(20, 'OVERTIME_LEAVE', '暂离超过规定时间', 3, 278, 0, NULL, NULL, NULL, NOW() - INTERVAL 12 DAY, NOW() - INTERVAL 12 DAY),
-- 黑名单用户的违规记录
(26, 'NO_SHOW', '多次未按时签到', 10, 328, 1, 29, NOW() - INTERVAL 17 DAY, '系统自动处理，已加入黑名单', NOW() - INTERVAL 18 DAY, NOW() - INTERVAL 17 DAY),
(27, 'NO_SHOW', '多次未按时签到', 10, 378, 1, 30, NOW() - INTERVAL 17 DAY, '系统自动处理，已加入黑名单', NOW() - INTERVAL 18 DAY, NOW() - INTERVAL 17 DAY),
(28, 'NO_SHOW', '多次未按时签到，已加入黑名单', 10, 448, 1, 29, NOW() - INTERVAL 7 DAY, '系统自动处理', NOW() - INTERVAL 8 DAY, NOW() - INTERVAL 7 DAY);

-- 黑名单数据
TRUNCATE TABLE blacklist;
INSERT INTO blacklist (user_id, reason, start_time, end_time, status, created_by, created_at, updated_at) VALUES
(26, '信用分过低（45分），多次未按时签到', NOW() - INTERVAL 10 DAY, NOW() + INTERVAL 4 DAY, 1, 29, NOW() - INTERVAL 10 DAY, NOW()),
(27, '信用分过低（55分），累计违规5次', NOW() - INTERVAL 8 DAY, NOW() + INTERVAL 6 DAY, 1, 30, NOW() - INTERVAL 8 DAY, NOW()),
(28, '信用分过低（38分），严重违规', NOW() - INTERVAL 3 DAY, NOW() + INTERVAL 11 DAY, 1, 29, NOW() - INTERVAL 3 DAY, NOW());

-- =============================================
-- 第六阶段：打卡与目标数据
-- =============================================

TRUNCATE TABLE daily_checkin;
TRUNCATE TABLE study_goal;

-- 每日打卡数据 (过去60天)
DELIMITER //
DROP PROCEDURE IF EXISTS generate_checkins//
CREATE PROCEDURE generate_checkins()
BEGIN
    DECLARE user_id INT;
    DECLARE checkin_date DATE;
    DECLARE day_offset INT;
    DECLARE streak INT;
    DECLARE study_hours DECIMAL(4,2);
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE user_cursor CURSOR FOR SELECT id FROM user WHERE role = 'STUDENT' AND status = 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN user_cursor;
    
    user_loop: LOOP
        FETCH user_cursor INTO user_id;
        IF done THEN
            LEAVE user_loop;
        END IF;
        
        SET day_offset = 0;
        SET streak = 0;
        
        -- 为每个用户生成过去60天的打卡记录（随机打卡率70%）
        WHILE day_offset < 60 DO
            SET checkin_date = DATE_SUB(CURDATE(), INTERVAL day_offset DAY);
            
            -- 70%概率打卡
            IF RAND() < 0.7 THEN
                SET streak = streak + 1;
                SET study_hours = 2 + RAND() * 8;  -- 2-10小时学习时长
                
                INSERT INTO daily_checkin (user_id, checkin_date, checkin_time, study_hours, continuous_days, is_makeup, created_at)
                VALUES (user_id, checkin_date, 
                        TIME(CONCAT(FLOOR(6 + RAND() * 4), ':', LPAD(FLOOR(RAND() * 60), 2, '0'), ':00')),  -- 6:00-10:00打卡
                        study_hours, streak, 0, 
                        TIMESTAMP(checkin_date, TIME(CONCAT(FLOOR(6 + RAND() * 4), ':', LPAD(FLOOR(RAND() * 60), 2, '0'), ':00'))))
                ON DUPLICATE KEY UPDATE study_hours = VALUES(study_hours);
            ELSE
                SET streak = 0;  -- 断签重置
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
INSERT INTO study_goal (user_id, goal_type, target_value, current_value, start_date, end_date, status, created_at, updated_at) VALUES
-- 用户1的学习目标
(1, 'DAILY_HOURS', 6.0, 5.5, CURDATE(), CURDATE(), 1, NOW() - INTERVAL 1 HOUR, NOW()),
(1, 'WEEKLY_HOURS', 30.0, 28.5, DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 1, NOW() - INTERVAL 5 DAY, NOW()),
(1, 'MONTHLY_HOURS', 120.0, 95.5, DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 1, NOW() - INTERVAL 20 DAY, NOW()),
(1, 'CONTINUOUS_DAYS', 30.0, 18.0, DATE_SUB(CURDATE(), INTERVAL 18 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), 1, NOW() - INTERVAL 18 DAY, NOW()),
-- 用户2的学习目标
(2, 'DAILY_HOURS', 5.0, 5.0, CURDATE(), CURDATE(), 2, NOW() - INTERVAL 2 HOUR, NOW()),  -- 已完成
(2, 'WEEKLY_HOURS', 25.0, 22.3, DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 1, NOW() - INTERVAL 4 DAY, NOW()),
(2, 'MONTHLY_HOURS', 100.0, 78.6, DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 1, NOW() - INTERVAL 18 DAY, NOW()),
-- 用户3的学习目标（学霸目标更高）
(3, 'DAILY_HOURS', 8.0, 7.5, CURDATE(), CURDATE(), 1, NOW() - INTERVAL 30 MINUTE, NOW()),
(3, 'WEEKLY_HOURS', 45.0, 42.8, DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 1, NOW() - INTERVAL 6 DAY, NOW()),
(3, 'MONTHLY_HOURS', 180.0, 165.3, DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 1, NOW() - INTERVAL 22 DAY, NOW()),
(3, 'CONTINUOUS_DAYS', 60.0, 45.0, DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 1, NOW() - INTERVAL 45 DAY, NOW()),
-- 用户4的学习目标
(4, 'DAILY_HOURS', 6.0, 6.5, CURDATE(), CURDATE(), 2, NOW() - INTERVAL 3 HOUR, NOW()),  -- 已完成
(4, 'WEEKLY_HOURS', 35.0, 38.2, DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 2, NOW() - INTERVAL 3 DAY, NOW()),  -- 已完成
-- 用户5-10的学习目标
(5, 'DAILY_HOURS', 4.0, 3.2, CURDATE(), CURDATE(), 1, NOW() - INTERVAL 45 MINUTE, NOW()),
(5, 'WEEKLY_HOURS', 20.0, 15.5, DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 1, NOW() - INTERVAL 5 DAY, NOW()),
(6, 'DAILY_HOURS', 5.0, 4.8, CURDATE(), CURDATE(), 1, NOW() - INTERVAL 2 HOUR, NOW()),
(6, 'MONTHLY_HOURS', 80.0, 58.5, DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 1, NOW() - INTERVAL 15 DAY, NOW()),
(7, 'DAILY_HOURS', 7.0, 8.2, CURDATE(), CURDATE(), 2, NOW() - INTERVAL 1 HOUR, NOW()),
(7, 'CONTINUOUS_DAYS', 45.0, 32.0, DATE_SUB(CURDATE(), INTERVAL 32 DAY), DATE_ADD(CURDATE(), INTERVAL 13 DAY), 1, NOW() - INTERVAL 32 DAY, NOW()),
(8, 'DAILY_HOURS', 5.0, 2.5, CURDATE(), CURDATE(), 1, NOW() - INTERVAL 4 HOUR, NOW()),
(8, 'WEEKLY_HOURS', 28.0, 18.6, DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 1, NOW() - INTERVAL 4 DAY, NOW()),
(9, 'DAILY_HOURS', 6.0, 5.8, CURDATE(), CURDATE(), 1, NOW() - INTERVAL 50 MINUTE, NOW()),
(9, 'MONTHLY_HOURS', 140.0, 125.8, DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 1, NOW() - INTERVAL 20 DAY, NOW()),
(10, 'DAILY_HOURS', 4.0, 3.5, CURDATE(), CURDATE(), 1, NOW() - INTERVAL 3 HOUR, NOW()),
-- 研究生的学习目标
(21, 'DAILY_HOURS', 8.0, 8.5, CURDATE(), CURDATE(), 2, NOW() - INTERVAL 1 HOUR, NOW()),
(21, 'WEEKLY_HOURS', 50.0, 48.5, DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), DATE_ADD(DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY), INTERVAL 6 DAY), 1, NOW() - INTERVAL 5 DAY, NOW()),
(21, 'MONTHLY_HOURS', 200.0, 185.6, DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 1, NOW() - INTERVAL 22 DAY, NOW()),
(22, 'DAILY_HOURS', 10.0, 9.5, CURDATE(), CURDATE(), 1, NOW() - INTERVAL 30 MINUTE, NOW()),
(22, 'CONTINUOUS_DAYS', 90.0, 75.0, DATE_SUB(CURDATE(), INTERVAL 75 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 1, NOW() - INTERVAL 75 DAY, NOW()),
-- 已失败的目标
(12, 'WEEKLY_HOURS', 25.0, 12.5, DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 7 DAY), DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) + 1 DAY), 3, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 3 DAY),  -- 上周未完成
(16, 'MONTHLY_HOURS', 80.0, 45.3, DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01'), LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)), 3, NOW() - INTERVAL 35 DAY, NOW() - INTERVAL 5 DAY);  -- 上月未完成

-- =============================================
-- 第七阶段：成就系统数据
-- =============================================

TRUNCATE TABLE user_achievement;
TRUNCATE TABLE achievement;

-- 成就定义
INSERT INTO achievement (id, name, description, icon, category, type, target_value, points, exp, badge_color, badge_level, sort_order, status, created_at, updated_at) VALUES
-- 学习时长成就
(1, '学习新手', '累计学习时长达到10小时', 'mdi-clock-outline', 'STUDY', 'CUMULATIVE', 10, 50, 100, '#4CAF50', 'BRONZE', 1, 1, NOW() - INTERVAL 365 DAY, NOW()),
(2, '学习达人', '累计学习时长达到100小时', 'mdi-clock-check', 'STUDY', 'CUMULATIVE', 100, 200, 400, '#2196F3', 'SILVER', 2, 1, NOW() - INTERVAL 365 DAY, NOW()),
(3, '学习精英', '累计学习时长达到500小时', 'mdi-clock-star', 'STUDY', 'CUMULATIVE', 500, 500, 1000, '#FF9800', 'GOLD', 3, 1, NOW() - INTERVAL 365 DAY, NOW()),
(4, '学习大师', '累计学习时长达到1000小时', 'mdi-star', 'STUDY', 'CUMULATIVE', 1000, 1000, 2000, '#9C27B0', 'PLATINUM', 4, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 打卡成就
(5, '初次打卡', '完成第一次打卡', 'mdi-checkbox-marked-circle', 'CHECKIN', 'MILESTONE', 1, 20, 50, '#4CAF50', 'BRONZE', 10, 1, NOW() - INTERVAL 365 DAY, NOW()),
(6, '坚持一周', '连续打卡7天', 'mdi-calendar-week', 'CHECKIN', 'CONTINUOUS', 7, 100, 200, '#4CAF50', 'BRONZE', 11, 1, NOW() - INTERVAL 365 DAY, NOW()),
(7, '坚持一月', '连续打卡30天', 'mdi-calendar-month', 'CHECKIN', 'CONTINUOUS', 30, 300, 600, '#2196F3', 'SILVER', 12, 1, NOW() - INTERVAL 365 DAY, NOW()),
(8, '百日坚持', '连续打卡100天', 'mdi-calendar-check', 'CHECKIN', 'CONTINUOUS', 100, 800, 1500, '#FF9800', 'GOLD', 13, 1, NOW() - INTERVAL 365 DAY, NOW()),
(9, '打卡王者', '连续打卡365天', 'mdi-crown', 'CHECKIN', 'CONTINUOUS', 365, 2000, 4000, '#9C27B0', 'PLATINUM', 14, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 预约成就
(10, '首次预约', '完成第一次座位预约', 'mdi-calendar-plus', 'RESERVATION', 'MILESTONE', 1, 20, 50, '#4CAF50', 'BRONZE', 20, 1, NOW() - INTERVAL 365 DAY, NOW()),
(11, '预约达人', '累计完成50次预约', 'mdi-calendar-multiple', 'RESERVATION', 'CUMULATIVE', 50, 200, 400, '#2196F3', 'SILVER', 21, 1, NOW() - INTERVAL 365 DAY, NOW()),
(12, '预约专家', '累计完成200次预约', 'mdi-calendar-star', 'RESERVATION', 'CUMULATIVE', 200, 500, 1000, '#FF9800', 'GOLD', 22, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 早起成就
(13, '早起鸟', '早上7点前签到', 'mdi-weather-sunny', 'SPECIAL', 'MILESTONE', 1, 30, 60, '#FFC107', 'BRONZE', 30, 1, NOW() - INTERVAL 365 DAY, NOW()),
(14, '早起达人', '累计30次早上7点前签到', 'mdi-weather-sunset-up', 'SPECIAL', 'CUMULATIVE', 30, 200, 400, '#FF9800', 'SILVER', 31, 1, NOW() - INTERVAL 365 DAY, NOW()),
(15, '早起王者', '累计100次早上7点前签到', 'mdi-white-balance-sunny', 'SPECIAL', 'CUMULATIVE', 100, 500, 1000, '#FF5722', 'GOLD', 32, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 夜猫子成就
(16, '夜猫子', '晚上10点后还在学习', 'mdi-weather-night', 'SPECIAL', 'MILESTONE', 1, 30, 60, '#3F51B5', 'BRONZE', 33, 1, NOW() - INTERVAL 365 DAY, NOW()),
(17, '深夜学霸', '累计30次晚上10点后学习', 'mdi-moon-waning-crescent', 'SPECIAL', 'CUMULATIVE', 30, 200, 400, '#673AB7', 'SILVER', 34, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 社交成就
(18, '社交新星', '添加第一个好友', 'mdi-account-plus', 'SOCIAL', 'MILESTONE', 1, 20, 50, '#4CAF50', 'BRONZE', 40, 1, NOW() - INTERVAL 365 DAY, NOW()),
(19, '社交达人', '好友数量达到10人', 'mdi-account-group', 'SOCIAL', 'CUMULATIVE', 10, 100, 200, '#2196F3', 'SILVER', 41, 1, NOW() - INTERVAL 365 DAY, NOW()),
(20, '社交明星', '好友数量达到50人', 'mdi-account-star', 'SOCIAL', 'CUMULATIVE', 50, 300, 600, '#FF9800', 'GOLD', 42, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 小组成就
(21, '小组成员', '加入第一个学习小组', 'mdi-account-multiple-plus', 'SOCIAL', 'MILESTONE', 1, 30, 60, '#4CAF50', 'BRONZE', 43, 1, NOW() - INTERVAL 365 DAY, NOW()),
(22, '小组创建者', '创建一个学习小组', 'mdi-account-multiple-check', 'SOCIAL', 'MILESTONE', 1, 50, 100, '#2196F3', 'SILVER', 44, 1, NOW() - INTERVAL 365 DAY, NOW()),
(23, '小组领袖', '创建的小组成员超过20人', 'mdi-star-circle', 'SOCIAL', 'CUMULATIVE', 20, 200, 400, '#FF9800', 'GOLD', 45, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 信用成就
(24, '信用满分', '信用分保持100分', 'mdi-shield-check', 'CREDIT', 'MILESTONE', 100, 100, 200, '#4CAF50', 'BRONZE', 50, 1, NOW() - INTERVAL 365 DAY, NOW()),
(25, '信用模范', '连续30天信用分100分', 'mdi-shield-star', 'CREDIT', 'CONTINUOUS', 30, 300, 600, '#FF9800', 'GOLD', 51, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 目标成就
(26, '目标新手', '完成第一个学习目标', 'mdi-flag-checkered', 'GOAL', 'MILESTONE', 1, 30, 60, '#4CAF50', 'BRONZE', 60, 1, NOW() - INTERVAL 365 DAY, NOW()),
(27, '目标达人', '累计完成20个学习目标', 'mdi-flag-variant', 'GOAL', 'CUMULATIVE', 20, 150, 300, '#2196F3', 'SILVER', 61, 1, NOW() - INTERVAL 365 DAY, NOW()),
(28, '目标大师', '累计完成100个学习目标', 'mdi-trophy', 'GOAL', 'CUMULATIVE', 100, 500, 1000, '#FF9800', 'GOLD', 62, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 积分成就
(29, '积分新秀', '累计获得1000积分', 'mdi-coin', 'POINTS', 'CUMULATIVE', 1000, 50, 100, '#4CAF50', 'BRONZE', 70, 1, NOW() - INTERVAL 365 DAY, NOW()),
(30, '积分达人', '累计获得5000积分', 'mdi-gold', 'POINTS', 'CUMULATIVE', 5000, 200, 400, '#2196F3', 'SILVER', 71, 1, NOW() - INTERVAL 365 DAY, NOW()),
(31, '积分富翁', '累计获得20000积分', 'mdi-diamond', 'POINTS', 'CUMULATIVE', 20000, 500, 1000, '#FF9800', 'GOLD', 72, 1, NOW() - INTERVAL 365 DAY, NOW()),
-- 特殊成就
(32, '周末战士', '周末学习满8小时', 'mdi-sword', 'SPECIAL', 'MILESTONE', 8, 50, 100, '#E91E63', 'BRONZE', 80, 1, NOW() - INTERVAL 365 DAY, NOW()),
(33, '马拉松学习者', '单日学习超过12小时', 'mdi-run-fast', 'SPECIAL', 'MILESTONE', 12, 100, 200, '#9C27B0', 'SILVER', 81, 1, NOW() - INTERVAL 365 DAY, NOW()),
(34, '全勤奖', '一个月每天都打卡', 'mdi-medal', 'SPECIAL', 'CONTINUOUS', 30, 500, 1000, '#FF9800', 'GOLD', 82, 1, NOW() - INTERVAL 365 DAY, NOW()),
(35, '年度学霸', '年度学习时长排名前10', 'mdi-trophy-award', 'SPECIAL', 'RANK', 10, 1000, 2000, '#9C27B0', 'PLATINUM', 83, 1, NOW() - INTERVAL 365 DAY, NOW());

-- 用户成就数据
INSERT INTO user_achievement (user_id, achievement_id, progress, unlocked, unlock_time, created_at, updated_at) VALUES
-- 用户1的成就
(1, 1, 256.5, 1, NOW() - INTERVAL 150 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 2, 256.5, 1, NOW() - INTERVAL 80 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 5, 1, 1, NOW() - INTERVAL 178 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 6, 7, 1, NOW() - INTERVAL 170 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 7, 30, 1, NOW() - INTERVAL 140 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 10, 1, 1, NOW() - INTERVAL 179 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 11, 85, 1, NOW() - INTERVAL 60 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 13, 1, 1, NOW() - INTERVAL 165 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 18, 1, 1, NOW() - INTERVAL 150 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 21, 1, 1, NOW() - INTERVAL 120 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 26, 1, 1, NOW() - INTERVAL 100 DAY, NOW() - INTERVAL 180 DAY, NOW()),
(1, 29, 2850, 1, NOW() - INTERVAL 90 DAY, NOW() - INTERVAL 180 DAY, NOW()),
-- 用户2的成就
(2, 1, 198.3, 1, NOW() - INTERVAL 145 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 2, 198.3, 1, NOW() - INTERVAL 85 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 5, 1, 1, NOW() - INTERVAL 173 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 6, 7, 1, NOW() - INTERVAL 165 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 10, 1, 1, NOW() - INTERVAL 174 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 11, 62, 1, NOW() - INTERVAL 70 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 16, 1, 1, NOW() - INTERVAL 160 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 18, 1, 1, NOW() - INTERVAL 145 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 22, 1, 1, NOW() - INTERVAL 100 DAY, NOW() - INTERVAL 175 DAY, NOW()),
(2, 29, 2150, 1, NOW() - INTERVAL 95 DAY, NOW() - INTERVAL 175 DAY, NOW()),
-- 用户3的成就（学霸）
(3, 1, 312.8, 1, NOW() - INTERVAL 155 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 2, 312.8, 1, NOW() - INTERVAL 75 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 3, 312.8, 0, NULL, NOW() - INTERVAL 170 DAY, NOW()),  -- 进行中
(3, 5, 1, 1, NOW() - INTERVAL 168 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 6, 7, 1, NOW() - INTERVAL 160 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 7, 30, 1, NOW() - INTERVAL 130 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 8, 45, 0, NULL, NOW() - INTERVAL 170 DAY, NOW()),  -- 进行中
(3, 10, 1, 1, NOW() - INTERVAL 169 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 11, 120, 1, NOW() - INTERVAL 50 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 12, 120, 0, NULL, NOW() - INTERVAL 170 DAY, NOW()),  -- 进行中
(3, 13, 1, 1, NOW() - INTERVAL 155 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 14, 45, 1, NOW() - INTERVAL 80 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 18, 1, 1, NOW() - INTERVAL 140 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 19, 10, 1, NOW() - INTERVAL 100 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 21, 1, 1, NOW() - INTERVAL 110 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 22, 1, 1, NOW() - INTERVAL 90 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 24, 100, 1, NOW() - INTERVAL 120 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 26, 1, 1, NOW() - INTERVAL 95 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 27, 28, 1, NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 29, 3560, 1, NOW() - INTERVAL 85 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 30, 3560, 0, NULL, NOW() - INTERVAL 170 DAY, NOW()),  -- 进行中
(3, 32, 1, 1, NOW() - INTERVAL 135 DAY, NOW() - INTERVAL 170 DAY, NOW()),
(3, 33, 1, 1, NOW() - INTERVAL 60 DAY, NOW() - INTERVAL 170 DAY, NOW()),
-- 用户4-10的基础成就
(4, 1, 225.6, 1, NOW() - INTERVAL 140 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 2, 225.6, 1, NOW() - INTERVAL 78 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 5, 1, 1, NOW() - INTERVAL 163 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 6, 7, 1, NOW() - INTERVAL 155 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 10, 1, 1, NOW() - INTERVAL 164 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 11, 75, 1, NOW() - INTERVAL 55 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 18, 1, 1, NOW() - INTERVAL 135 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 21, 1, 1, NOW() - INTERVAL 105 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 22, 1, 1, NOW() - INTERVAL 85 DAY, NOW() - INTERVAL 165 DAY, NOW()),
(4, 29, 2680, 1, NOW() - INTERVAL 80 DAY, NOW() - INTERVAL 165 DAY, NOW()),

(5, 1, 165.2, 1, NOW() - INTERVAL 135 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 2, 165.2, 1, NOW() - INTERVAL 82 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 5, 1, 1, NOW() - INTERVAL 158 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 6, 7, 1, NOW() - INTERVAL 150 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 10, 1, 1, NOW() - INTERVAL 159 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 18, 1, 1, NOW() - INTERVAL 130 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 21, 1, 1, NOW() - INTERVAL 100 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 22, 1, 1, NOW() - INTERVAL 80 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 23, 28, 1, NOW() - INTERVAL 30 DAY, NOW() - INTERVAL 160 DAY, NOW()),
(5, 29, 1850, 1, NOW() - INTERVAL 75 DAY, NOW() - INTERVAL 160 DAY, NOW()),

(6, 1, 142.5, 1, NOW() - INTERVAL 130 DAY, NOW() - INTERVAL 155 DAY, NOW()),
(6, 2, 142.5, 1, NOW() - INTERVAL 88 DAY, NOW() - INTERVAL 155 DAY, NOW()),
(6, 5, 1, 1, NOW() - INTERVAL 153 DAY, NOW() - INTERVAL 155 DAY, NOW()),
(6, 10, 1, 1, NOW() - INTERVAL 154 DAY, NOW() - INTERVAL 155 DAY, NOW()),
(6, 18, 1, 1, NOW() - INTERVAL 125 DAY, NOW() - INTERVAL 155 DAY, NOW()),
(6, 29, 1580, 1, NOW() - INTERVAL 70 DAY, NOW() - INTERVAL 155 DAY, NOW()),

(7, 1, 285.3, 1, NOW() - INTERVAL 125 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 2, 285.3, 1, NOW() - INTERVAL 72 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 5, 1, 1, NOW() - INTERVAL 148 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 6, 7, 1, NOW() - INTERVAL 140 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 7, 32, 1, NOW() - INTERVAL 115 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 10, 1, 1, NOW() - INTERVAL 149 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 11, 92, 1, NOW() - INTERVAL 48 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 13, 1, 1, NOW() - INTERVAL 138 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 14, 35, 1, NOW() - INTERVAL 75 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 18, 1, 1, NOW() - INTERVAL 120 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 24, 100, 1, NOW() - INTERVAL 100 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 29, 3250, 1, NOW() - INTERVAL 65 DAY, NOW() - INTERVAL 150 DAY, NOW()),
(7, 30, 3250, 0, NULL, NOW() - INTERVAL 150 DAY, NOW()),

(8, 1, 178.6, 1, NOW() - INTERVAL 120 DAY, NOW() - INTERVAL 145 DAY, NOW()),
(8, 2, 178.6, 1, NOW() - INTERVAL 76 DAY, NOW() - INTERVAL 145 DAY, NOW()),
(8, 5, 1, 1, NOW() - INTERVAL 143 DAY, NOW() - INTERVAL 145 DAY, NOW()),
(8, 6, 7, 1, NOW() - INTERVAL 135 DAY, NOW() - INTERVAL 145 DAY, NOW()),
(8, 10, 1, 1, NOW() - INTERVAL 144 DAY, NOW() - INTERVAL 145 DAY, NOW()),
(8, 11, 58, 1, NOW() - INTERVAL 52 DAY, NOW() - INTERVAL 145 DAY, NOW()),
(8, 16, 1, 1, NOW() - INTERVAL 130 DAY, NOW() - INTERVAL 145 DAY, NOW()),
(8, 18, 1, 1, NOW() - INTERVAL 115 DAY, NOW() - INTERVAL 145 DAY, NOW()),
(8, 21, 1, 1, NOW() - INTERVAL 90 DAY, NOW() - INTERVAL 145 DAY, NOW()),
(8, 29, 2050, 1, NOW() - INTERVAL 60 DAY, NOW() - INTERVAL 145 DAY, NOW()),

(9, 1, 245.8, 1, NOW() - INTERVAL 115 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 2, 245.8, 1, NOW() - INTERVAL 70 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 5, 1, 1, NOW() - INTERVAL 138 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 6, 7, 1, NOW() - INTERVAL 130 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 7, 28, 0, NULL, NOW() - INTERVAL 140 DAY, NOW()),
(9, 10, 1, 1, NOW() - INTERVAL 139 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 11, 78, 1, NOW() - INTERVAL 45 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 13, 1, 1, NOW() - INTERVAL 125 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 18, 1, 1, NOW() - INTERVAL 110 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 21, 1, 1, NOW() - INTERVAL 85 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 22, 1, 1, NOW() - INTERVAL 60 DAY, NOW() - INTERVAL 140 DAY, NOW()),
(9, 29, 2780, 1, NOW() - INTERVAL 55 DAY, NOW() - INTERVAL 140 DAY, NOW()),

(10, 1, 135.2, 1, NOW() - INTERVAL 110 DAY, NOW() - INTERVAL 135 DAY, NOW()),
(10, 2, 135.2, 1, NOW() - INTERVAL 92 DAY, NOW() - INTERVAL 135 DAY, NOW()),
(10, 5, 1, 1, NOW() - INTERVAL 133 DAY, NOW() - INTERVAL 135 DAY, NOW()),
(10, 10, 1, 1, NOW() - INTERVAL 134 DAY, NOW() - INTERVAL 135 DAY, NOW()),
(10, 18, 1, 1, NOW() - INTERVAL 105 DAY, NOW() - INTERVAL 135 DAY, NOW()),
(10, 19, 12, 1, NOW() - INTERVAL 50 DAY, NOW() - INTERVAL 135 DAY, NOW()),
(10, 21, 1, 1, NOW() - INTERVAL 80 DAY, NOW() - INTERVAL 135 DAY, NOW()),
(10, 22, 1, 1, NOW() - INTERVAL 55 DAY, NOW() - INTERVAL 135 DAY, NOW()),
(10, 29, 1450, 1, NOW() - INTERVAL 65 DAY, NOW() - INTERVAL 135 DAY, NOW()),

-- 研究生用户的成就（更多高级成就）
(21, 1, 356.8, 1, NOW() - INTERVAL 180 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 2, 356.8, 1, NOW() - INTERVAL 100 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 3, 356.8, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 5, 1, 1, NOW() - INTERVAL 198 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 6, 7, 1, NOW() - INTERVAL 190 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 7, 30, 1, NOW() - INTERVAL 160 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 8, 62, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 10, 1, 1, NOW() - INTERVAL 199 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 11, 145, 1, NOW() - INTERVAL 70 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 12, 145, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 13, 1, 1, NOW() - INTERVAL 185 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 14, 52, 1, NOW() - INTERVAL 95 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 15, 52, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 16, 1, 1, NOW() - INTERVAL 180 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 17, 38, 1, NOW() - INTERVAL 85 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 18, 1, 1, NOW() - INTERVAL 170 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 19, 15, 1, NOW() - INTERVAL 120 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 21, 1, 1, NOW() - INTERVAL 140 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 24, 98, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 26, 1, 1, NOW() - INTERVAL 125 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 27, 35, 1, NOW() - INTERVAL 65 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 29, 4050, 1, NOW() - INTERVAL 105 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 30, 4050, 0, NULL, NOW() - INTERVAL 200 DAY, NOW()),
(21, 32, 1, 1, NOW() - INTERVAL 165 DAY, NOW() - INTERVAL 200 DAY, NOW()),
(21, 33, 1, 1, NOW() - INTERVAL 80 DAY, NOW() - INTERVAL 200 DAY, NOW()),

(22, 1, 412.5, 1, NOW() - INTERVAL 175 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 2, 412.5, 1, NOW() - INTERVAL 95 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 3, 412.5, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 5, 1, 1, NOW() - INTERVAL 193 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 6, 7, 1, NOW() - INTERVAL 185 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 7, 30, 1, NOW() - INTERVAL 155 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 8, 75, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 10, 1, 1, NOW() - INTERVAL 194 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 11, 168, 1, NOW() - INTERVAL 62 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 12, 168, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 13, 1, 1, NOW() - INTERVAL 180 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 14, 65, 1, NOW() - INTERVAL 88 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 15, 65, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 18, 1, 1, NOW() - INTERVAL 165 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 19, 18, 1, NOW() - INTERVAL 110 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 21, 1, 1, NOW() - INTERVAL 135 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 24, 100, 1, NOW() - INTERVAL 145 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 25, 45, 1, NOW() - INTERVAL 100 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 26, 1, 1, NOW() - INTERVAL 120 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 27, 42, 1, NOW() - INTERVAL 55 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 28, 42, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 29, 4680, 1, NOW() - INTERVAL 98 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 30, 4680, 0, NULL, NOW() - INTERVAL 195 DAY, NOW()),
(22, 32, 1, 1, NOW() - INTERVAL 158 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 33, 1, 1, NOW() - INTERVAL 72 DAY, NOW() - INTERVAL 195 DAY, NOW()),
(22, 34, 1, 1, NOW() - INTERVAL 85 DAY, NOW() - INTERVAL 195 DAY, NOW());

-- =============================================
-- 统计信息
-- =============================================

SET FOREIGN_KEY_CHECKS = 1;

SELECT '====== 全阶段数据插入完成 ======' AS message;
SELECT '第一阶段 - 用户数据：' AS phase, COUNT(*) AS count FROM user;
SELECT '第二阶段 - 教学楼数据：' AS phase, COUNT(*) AS count FROM building;
SELECT '第二阶段 - 自习室数据：' AS phase, COUNT(*) AS count FROM room;
SELECT '第二阶段 - 座位数据：' AS phase, COUNT(*) AS count FROM seat;
SELECT '第四阶段 - 预约数据：' AS phase, COUNT(*) AS count FROM reservation;
SELECT '第五阶段 - 信用记录：' AS phase, COUNT(*) AS count FROM credit_record;
SELECT '第五阶段 - 违规记录：' AS phase, COUNT(*) AS count FROM violation_record;
SELECT '第五阶段 - 黑名单数据：' AS phase, COUNT(*) AS count FROM blacklist;
SELECT '第六阶段 - 打卡数据：' AS phase, COUNT(*) AS count FROM daily_checkin;
SELECT '第六阶段 - 目标数据：' AS phase, COUNT(*) AS count FROM study_goal;
SELECT '第七阶段 - 成就定义：' AS phase, COUNT(*) AS count FROM achievement;
SELECT '第七阶段 - 用户成就：' AS phase, COUNT(*) AS count FROM user_achievement;
