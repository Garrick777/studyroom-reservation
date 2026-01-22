-- =====================================================
-- 智慧自习室座位预约系统 - 测试数据库脚本
-- 用于第二阶段认证模块测试
-- =====================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `studyroom` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `studyroom`;

-- =====================================================
-- 1. 用户表
-- =====================================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码(BCrypt加密)',
  `student_id` VARCHAR(20) UNIQUE NOT NULL COMMENT '学号',
  `real_name` VARCHAR(50) NOT NULL COMMENT '真实姓名',
  `email` VARCHAR(100) COMMENT '邮箱',
  `phone` VARCHAR(20) COMMENT '手机号',
  `avatar` VARCHAR(255) COMMENT '头像URL',
  `gender` TINYINT DEFAULT 0 COMMENT '性别: 0未知 1男 2女',
  `college` VARCHAR(100) COMMENT '学院',
  `major` VARCHAR(100) COMMENT '专业',
  `grade` VARCHAR(20) COMMENT '年级',
  `class_no` VARCHAR(50) COMMENT '班级',
  `credit_score` INT DEFAULT 100 COMMENT '信用积分(0-100)',
  `total_study_time` INT DEFAULT 0 COMMENT '累计学习时长(分钟)',
  `total_points` INT DEFAULT 0 COMMENT '总积分',
  `consecutive_days` INT DEFAULT 0 COMMENT '连续签到天数',
  `total_check_ins` INT DEFAULT 0 COMMENT '总签到天数',
  `current_streak` INT DEFAULT 0 COMMENT '当前连续学习天数',
  `max_streak` INT DEFAULT 0 COMMENT '最长连续学习天数',
  `last_check_in_date` DATETIME COMMENT '上次签到日期',
  `role` VARCHAR(20) DEFAULT 'STUDENT' COMMENT '角色: STUDENT/ADMIN/SUPER_ADMIN',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0禁用 1正常 2黑名单',
  `blacklist_end_time` DATETIME COMMENT '黑名单结束时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除: 0未删除 1已删除',
  INDEX `idx_username` (`username`),
  INDEX `idx_student_id` (`student_id`),
  INDEX `idx_role` (`role`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- =====================================================
-- 2. 插入测试用户数据
-- 密码都是: 123456 (BCrypt加密)
-- =====================================================
INSERT INTO `user` (`username`, `password`, `student_id`, `real_name`, `email`, `phone`, `role`, `gender`, `college`, `major`, `grade`, `class_no`, `credit_score`, `total_study_time`, `total_points`, `consecutive_days`, `total_check_ins`) VALUES
-- 超级管理员
('superadmin', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '00000001', '超级管理员', 'superadmin@studyroom.com', '13800000001', 'SUPER_ADMIN', 1, '信息学院', '计算机科学', '2020级', '1班', 100, 0, 0, 0, 0),

-- 自习室管理员
('admin01', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '00000002', '李管理', 'admin01@studyroom.com', '13800000002', 'ADMIN', 1, '信息学院', '软件工程', '2019级', '2班', 100, 0, 0, 0, 0),
('admin02', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '00000003', '王管理', 'admin02@studyroom.com', '13800000003', 'ADMIN', 2, '信息学院', '信息安全', '2019级', '1班', 100, 0, 0, 0, 0),

-- 学生用户
('student01', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '20210001', '张三', 'zhangsan@example.com', '13900000001', 'STUDENT', 1, '计算机学院', '软件工程', '2021级', '1班', 95, 3600, 1280, 7, 30),
('student02', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '20210002', '李四', 'lisi@example.com', '13900000002', 'STUDENT', 1, '计算机学院', '计算机科学', '2021级', '2班', 88, 2400, 960, 3, 20),
('student03', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '20210003', '王五', 'wangwu@example.com', '13900000003', 'STUDENT', 2, '数学学院', '应用数学', '2021级', '1班', 100, 5400, 2100, 15, 45),
('student04', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '20210004', '赵六', 'zhaoliu@example.com', '13900000004', 'STUDENT', 1, '物理学院', '应用物理', '2021级', '3班', 72, 1800, 720, 1, 15),
('student05', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '20210005', '孙七', 'sunqi@example.com', '13900000005', 'STUDENT', 2, '外国语学院', '英语', '2021级', '2班', 55, 600, 240, 0, 8),
('student06', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '20220001', '周八', 'zhouba@example.com', '13900000006', 'STUDENT', 1, '经济学院', '金融学', '2022级', '1班', 100, 4200, 1680, 10, 35),
('student07', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '20220002', '吴九', 'wujiu@example.com', '13900000007', 'STUDENT', 2, '法学院', '法学', '2022级', '2班', 90, 3000, 1200, 5, 25),
('student08', '$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu', '20220003', '郑十', 'zhengshi@example.com', '13900000008', 'STUDENT', 1, '艺术学院', '设计学', '2022级', '1班', 85, 1500, 600, 2, 12);

-- =====================================================
-- 3. 自习室表
-- =====================================================
DROP TABLE IF EXISTS `study_room`;
CREATE TABLE `study_room` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '自习室ID',
  `name` VARCHAR(100) NOT NULL COMMENT '自习室名称',
  `code` VARCHAR(20) UNIQUE COMMENT '自习室编号',
  `building` VARCHAR(100) COMMENT '所在建筑',
  `floor` VARCHAR(20) COMMENT '楼层',
  `room_number` VARCHAR(20) COMMENT '房间号',
  `capacity` INT NOT NULL COMMENT '座位总数',
  `row_count` INT NOT NULL COMMENT '座位行数',
  `col_count` INT NOT NULL COMMENT '座位列数',
  `description` TEXT COMMENT '描述信息',
  `facilities` JSON COMMENT '设施(JSON数组)',
  `cover_image` VARCHAR(255) COMMENT '封面图片',
  `images` JSON COMMENT '图片集(JSON数组)',
  `open_time` TIME NOT NULL COMMENT '开放时间',
  `close_time` TIME NOT NULL COMMENT '关闭时间',
  `advance_days` INT DEFAULT 7 COMMENT '最大提前预约天数',
  `max_duration` INT DEFAULT 4 COMMENT '单次最大预约时长(小时)',
  `min_credit_score` INT DEFAULT 60 COMMENT '最低信用分要求',
  `need_approve` TINYINT DEFAULT 0 COMMENT '是否需要审批',
  `allow_temp` TINYINT DEFAULT 1 COMMENT '是否允许临时预约',
  `rating` DECIMAL(2,1) DEFAULT 5.0 COMMENT '评分',
  `rating_count` INT DEFAULT 0 COMMENT '评分人数',
  `today_reservations` INT DEFAULT 0 COMMENT '今日预约数',
  `total_reservations` INT DEFAULT 0 COMMENT '总预约数',
  `manager_id` BIGINT COMMENT '管理员ID',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0关闭 1开放 2维护中',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
  INDEX `idx_status` (`status`),
  INDEX `idx_building` (`building`),
  INDEX `idx_rating` (`rating`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='自习室表';

-- =====================================================
-- 4. 座位表
-- =====================================================
DROP TABLE IF EXISTS `seat`;
CREATE TABLE `seat` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '座位ID',
  `room_id` BIGINT NOT NULL COMMENT '自习室ID',
  `seat_no` VARCHAR(20) NOT NULL COMMENT '座位编号',
  `row_num` INT NOT NULL COMMENT '行号',
  `col_num` INT NOT NULL COMMENT '列号',
  `seat_type` VARCHAR(20) DEFAULT 'NORMAL' COMMENT '座位类型: NORMAL/WINDOW/POWER/VIP',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0不可用 1可用 2维修中',
  `remark` VARCHAR(200) COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
  INDEX `idx_room_id` (`room_id`),
  INDEX `idx_status` (`status`),
  UNIQUE KEY `uk_room_seat` (`room_id`, `seat_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='座位表';

-- =====================================================
-- 5. 时段表
-- =====================================================
DROP TABLE IF EXISTS `time_slot`;
CREATE TABLE `time_slot` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '时段ID',
  `name` VARCHAR(50) NOT NULL COMMENT '时段名称',
  `start_time` TIME NOT NULL COMMENT '开始时间',
  `end_time` TIME NOT NULL COMMENT '结束时间',
  `duration` INT NOT NULL COMMENT '时长(分钟)',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0禁用 1启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='时段表';

-- =====================================================
-- 6. 用户收藏表
-- =====================================================
DROP TABLE IF EXISTS `user_favorite`;
CREATE TABLE `user_favorite` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '收藏ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `room_id` BIGINT NOT NULL COMMENT '自习室ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY `uk_user_room` (`user_id`, `room_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_room_id` (`room_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户收藏表';

-- =====================================================
-- 7. 插入时段数据
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
-- 8. 插入自习室数据
-- =====================================================
INSERT INTO `study_room` (`name`, `code`, `building`, `floor`, `room_number`, `capacity`, `row_count`, `col_count`, `description`, `facilities`, `open_time`, `close_time`, `rating`, `rating_count`, `total_reservations`, `manager_id`, `status`, `sort_order`) VALUES
('图书馆三楼A区', 'LIB-3A', '图书馆', '3楼', 'A区', 120, 10, 12, '安静舒适的学习环境，配备空调和充电插座', '["空调", "WiFi", "电源", "饮水机"]', '08:00:00', '22:00:00', 4.8, 156, 2340, 2, 1, 1),
('图书馆三楼B区', 'LIB-3B', '图书馆', '3楼', 'B区', 80, 8, 10, '靠窗座位，采光良好', '["空调", "WiFi", "电源"]', '08:00:00', '22:00:00', 4.6, 98, 1520, 2, 1, 2),
('图书馆四楼自习室', 'LIB-4', '图书馆', '4楼', '401', 100, 10, 10, '独立自习室，环境安静', '["空调", "WiFi", "电源", "打印机"]', '08:00:00', '22:00:00', 4.9, 210, 3100, 2, 1, 3),
('教学楼A座自习室', 'TEA-A', '教学楼A座', '1楼', '101', 60, 6, 10, '教学楼自习室，位置便利', '["空调", "WiFi"]', '07:00:00', '21:00:00', 4.3, 67, 890, 3, 1, 4),
('教学楼B座自习室', 'TEA-B', '教学楼B座', '2楼', '201', 50, 5, 10, '小型自习室，适合小组学习', '["空调", "WiFi", "白板"]', '07:00:00', '21:00:00', 4.5, 45, 670, 3, 1, 5),
('计算机学院机房', 'CS-LAB', '计算机学院', '3楼', '301', 40, 4, 10, '配备电脑的机房，适合编程学习', '["空调", "WiFi", "电脑", "投影仪"]', '09:00:00', '21:00:00', 4.7, 89, 1200, 3, 1, 6),
('研究生自习室', 'GRAD', '研究生院', '2楼', '202', 30, 5, 6, '研究生专用自习室', '["空调", "WiFi", "电源", "储物柜"]', '08:00:00', '23:00:00', 4.9, 120, 1800, 2, 1, 7),
('24小时自习室', 'H24', '学生活动中心', '1楼', '102', 40, 4, 10, '全天候开放的自习室', '["空调", "WiFi", "电源", "自动售货机"]', '00:00:00', '23:59:00', 4.4, 180, 4500, 2, 1, 8);

-- =====================================================
-- 9. 为每个自习室生成座位
-- =====================================================
-- 图书馆三楼A区 (10行12列)
INSERT INTO `seat` (`room_id`, `seat_no`, `row_num`, `col_num`, `seat_type`, `status`)
SELECT 1, CONCAT('A', LPAD(r.n, 2, '0'), '-', LPAD(c.n, 2, '0')), r.n, c.n,
       CASE 
           WHEN c.n = 1 OR c.n = 12 THEN 'WINDOW'
           WHEN c.n = 6 OR c.n = 7 THEN 'POWER'
           ELSE 'NORMAL'
       END,
       1
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) r,
     (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
      UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12) c;

-- 图书馆三楼B区 (8行10列)
INSERT INTO `seat` (`room_id`, `seat_no`, `row_num`, `col_num`, `seat_type`, `status`)
SELECT 2, CONCAT('B', LPAD(r.n, 2, '0'), '-', LPAD(c.n, 2, '0')), r.n, c.n,
       CASE WHEN c.n = 1 OR c.n = 10 THEN 'WINDOW' ELSE 'NORMAL' END, 1
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8) r,
     (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) c;

-- 图书馆四楼自习室 (10行10列)
INSERT INTO `seat` (`room_id`, `seat_no`, `row_num`, `col_num`, `seat_type`, `status`)
SELECT 3, CONCAT('C', LPAD(r.n, 2, '0'), '-', LPAD(c.n, 2, '0')), r.n, c.n,
       CASE WHEN r.n = 1 THEN 'VIP' WHEN c.n = 5 OR c.n = 6 THEN 'POWER' ELSE 'NORMAL' END, 1
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) r,
     (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) c;

-- 教学楼A座自习室 (6行10列)
INSERT INTO `seat` (`room_id`, `seat_no`, `row_num`, `col_num`, `seat_type`, `status`)
SELECT 4, CONCAT('D', LPAD(r.n, 2, '0'), '-', LPAD(c.n, 2, '0')), r.n, c.n, 'NORMAL', 1
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) r,
     (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) c;

-- 教学楼B座自习室 (5行10列)
INSERT INTO `seat` (`room_id`, `seat_no`, `row_num`, `col_num`, `seat_type`, `status`)
SELECT 5, CONCAT('E', LPAD(r.n, 2, '0'), '-', LPAD(c.n, 2, '0')), r.n, c.n, 'NORMAL', 1
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) r,
     (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) c;

-- 计算机学院机房 (4行10列)
INSERT INTO `seat` (`room_id`, `seat_no`, `row_num`, `col_num`, `seat_type`, `status`)
SELECT 6, CONCAT('F', LPAD(r.n, 2, '0'), '-', LPAD(c.n, 2, '0')), r.n, c.n, 'POWER', 1
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) r,
     (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) c;

-- 研究生自习室 (5行6列)
INSERT INTO `seat` (`room_id`, `seat_no`, `row_num`, `col_num`, `seat_type`, `status`)
SELECT 7, CONCAT('G', LPAD(r.n, 2, '0'), '-', LPAD(c.n, 2, '0')), r.n, c.n,
       CASE WHEN r.n <= 2 THEN 'VIP' ELSE 'POWER' END, 1
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) r,
     (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) c;

-- 24小时自习室 (4行10列)
INSERT INTO `seat` (`room_id`, `seat_no`, `row_num`, `col_num`, `seat_type`, `status`)
SELECT 8, CONCAT('H', LPAD(r.n, 2, '0'), '-', LPAD(c.n, 2, '0')), r.n, c.n,
       CASE WHEN c.n <= 2 THEN 'WINDOW' ELSE 'POWER' END, 1
FROM (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) r,
     (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) c;

-- 查看结果
SELECT id, name, capacity, (SELECT COUNT(*) FROM seat WHERE room_id = study_room.id) as seat_count FROM study_room;
SELECT room_id, COUNT(*) as seat_count, seat_type FROM seat GROUP BY room_id, seat_type ORDER BY room_id, seat_type;
