-- =====================================================
-- 智慧自习室座位预约系统 - 数据库建表脚本 v2.0
-- 数据库: study_room_db
-- 字符集: utf8mb4
-- 表数量: 22张
-- =====================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `study_room_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `study_room_db`;

-- =====================================================
-- 1. 用户表
-- =====================================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
  `student_no` VARCHAR(20) UNIQUE NOT NULL COMMENT '学号',
  `username` VARCHAR(50) NOT NULL COMMENT '姓名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码(BCrypt加密)',
  `phone` VARCHAR(20) COMMENT '手机号',
  `email` VARCHAR(100) COMMENT '邮箱',
  `avatar` VARCHAR(255) COMMENT '头像URL',
  `gender` TINYINT COMMENT '性别: 0女 1男',
  `college` VARCHAR(100) COMMENT '学院',
  `major` VARCHAR(100) COMMENT '专业',
  `grade` VARCHAR(20) COMMENT '年级',
  `class_name` VARCHAR(50) COMMENT '班级',
  `credit_score` INT DEFAULT 100 COMMENT '信用积分(0-100)',
  `total_hours` DECIMAL(10,2) DEFAULT 0 COMMENT '累计学习时长(小时)',
  `total_reservations` INT DEFAULT 0 COMMENT '累计预约次数',
  `total_check_ins` INT DEFAULT 0 COMMENT '累计打卡天数',
  `continuous_check_ins` INT DEFAULT 0 COMMENT '连续打卡天数',
  `points` INT DEFAULT 0 COMMENT '积分(可兑换)',
  `level` INT DEFAULT 1 COMMENT '等级',
  `exp` INT DEFAULT 0 COMMENT '经验值',
  `bio` VARCHAR(255) COMMENT '个人简介',
  `role` VARCHAR(20) DEFAULT 'STUDENT' COMMENT '角色: STUDENT/ADMIN/SUPER_ADMIN',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0禁用 1正常',
  `last_login_time` DATETIME COMMENT '最后登录时间',
  `last_login_ip` VARCHAR(50) COMMENT '最后登录IP',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_student_no` (`student_no`),
  INDEX `idx_role` (`role`),
  INDEX `idx_credit_score` (`credit_score`),
  INDEX `idx_status` (`status`),
  INDEX `idx_college` (`college`),
  INDEX `idx_level` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- =====================================================
-- 2. 自习室表
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
  `facilities` VARCHAR(500) COMMENT '设施(JSON): ["空调","WiFi","电源"]',
  `cover_image` VARCHAR(255) COMMENT '封面图片',
  `images` TEXT COMMENT '图片集(JSON数组)',
  `open_time` TIME NOT NULL COMMENT '开放时间',
  `close_time` TIME NOT NULL COMMENT '关闭时间',
  `advance_days` INT DEFAULT 7 COMMENT '最大提前预约天数',
  `max_duration` INT DEFAULT 4 COMMENT '单次最大预约时长(小时)',
  `min_credit_score` INT DEFAULT 60 COMMENT '最低信用分要求',
  `need_approve` TINYINT DEFAULT 0 COMMENT '是否需要审批: 0否 1是',
  `allow_temp` TINYINT DEFAULT 1 COMMENT '是否允许临时预约',
  `rating` DECIMAL(2,1) DEFAULT 5.0 COMMENT '评分',
  `rating_count` INT DEFAULT 0 COMMENT '评分人数',
  `today_reservations` INT DEFAULT 0 COMMENT '今日预约数',
  `total_reservations` INT DEFAULT 0 COMMENT '总预约数',
  `manager_id` BIGINT COMMENT '管理员ID',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0关闭 1开放 2维护中',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_status` (`status`),
  INDEX `idx_building` (`building`),
  INDEX `idx_rating` (`rating`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='自习室表';

-- =====================================================
-- 3. 座位表
-- =====================================================
DROP TABLE IF EXISTS `seat`;
CREATE TABLE `seat` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '座位ID',
  `room_id` BIGINT NOT NULL COMMENT '自习室ID',
  `seat_no` VARCHAR(20) NOT NULL COMMENT '座位编号',
  `row_num` INT NOT NULL COMMENT '行号(从1开始)',
  `col_num` INT NOT NULL COMMENT '列号(从1开始)',
  `seat_type` VARCHAR(20) DEFAULT 'NORMAL' COMMENT '类型: NORMAL普通/POWER有电源/WINDOW靠窗/CORNER角落/VIP贵宾',
  `has_power` TINYINT DEFAULT 0 COMMENT '是否有电源: 0无 1有',
  `has_lamp` TINYINT DEFAULT 0 COMMENT '是否有台灯: 0无 1有',
  `has_computer` TINYINT DEFAULT 0 COMMENT '是否有电脑: 0无 1有',
  `description` VARCHAR(255) COMMENT '备注',
  `rating` DECIMAL(2,1) DEFAULT 5.0 COMMENT '评分',
  `rating_count` INT DEFAULT 0 COMMENT '评分人数',
  `total_reservations` INT DEFAULT 0 COMMENT '总预约数',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0不可用 1可用 2维修中',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_room_id` (`room_id`),
  INDEX `idx_seat_no` (`room_id`, `seat_no`),
  INDEX `idx_seat_type` (`seat_type`),
  UNIQUE KEY `uk_room_seat` (`room_id`, `row_num`, `col_num`),
  FOREIGN KEY (`room_id`) REFERENCES `study_room`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='座位表';

-- =====================================================
-- 4. 时段表
-- =====================================================
DROP TABLE IF EXISTS `time_slot`;
CREATE TABLE `time_slot` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '时段ID',
  `name` VARCHAR(50) NOT NULL COMMENT '时段名称',
  `start_time` TIME NOT NULL COMMENT '开始时间',
  `end_time` TIME NOT NULL COMMENT '结束时间',
  `duration` INT COMMENT '时长(分钟)',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0禁用 1启用',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='时段表';

-- =====================================================
-- 5. 预约表
-- =====================================================
DROP TABLE IF EXISTS `reservation`;
CREATE TABLE `reservation` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '预约ID',
  `reservation_no` VARCHAR(32) UNIQUE NOT NULL COMMENT '预约编号',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `room_id` BIGINT NOT NULL COMMENT '自习室ID',
  `seat_id` BIGINT NOT NULL COMMENT '座位ID',
  `date` DATE NOT NULL COMMENT '预约日期',
  `time_slot_id` BIGINT NOT NULL COMMENT '时段ID',
  `start_time` DATETIME NOT NULL COMMENT '开始时间',
  `end_time` DATETIME NOT NULL COMMENT '结束时间',
  `status` VARCHAR(20) DEFAULT 'PENDING' COMMENT '状态',
  `sign_in_time` DATETIME COMMENT '签到时间',
  `sign_out_time` DATETIME COMMENT '签退时间',
  `actual_duration` INT COMMENT '实际使用时长(分钟)',
  `leave_time` DATETIME COMMENT '暂离时间',
  `return_time` DATETIME COMMENT '暂离返回时间',
  `leave_count` INT DEFAULT 0 COMMENT '暂离次数',
  `cancel_time` DATETIME COMMENT '取消时间',
  `cancel_reason` VARCHAR(255) COMMENT '取消原因',
  `violation_type` VARCHAR(50) COMMENT '违约类型',
  `earned_points` INT DEFAULT 0 COMMENT '获得积分',
  `earned_exp` INT DEFAULT 0 COMMENT '获得经验',
  `remark` VARCHAR(255) COMMENT '备注',
  `source` VARCHAR(20) DEFAULT 'WEB' COMMENT '预约来源: WEB/APP/WECHAT',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_room_id` (`room_id`),
  INDEX `idx_seat_id` (`seat_id`),
  INDEX `idx_date` (`date`),
  INDEX `idx_status` (`status`),
  INDEX `idx_user_date` (`user_id`, `date`),
  INDEX `idx_start_time` (`start_time`),
  UNIQUE KEY `uk_seat_date_slot` (`seat_id`, `date`, `time_slot_id`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`),
  FOREIGN KEY (`room_id`) REFERENCES `study_room`(`id`),
  FOREIGN KEY (`seat_id`) REFERENCES `seat`(`id`),
  FOREIGN KEY (`time_slot_id`) REFERENCES `time_slot`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约表';

-- =====================================================
-- 6. 违约记录表
-- =====================================================
DROP TABLE IF EXISTS `violation_record`;
CREATE TABLE `violation_record` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `reservation_id` BIGINT COMMENT '关联预约ID',
  `type` VARCHAR(50) NOT NULL COMMENT '违约类型',
  `description` VARCHAR(255) COMMENT '违约描述',
  `deduct_score` INT NOT NULL COMMENT '扣除积分',
  `before_score` INT COMMENT '扣除前积分',
  `after_score` INT COMMENT '扣除后积分',
  `appeal_status` TINYINT DEFAULT 0 COMMENT '申诉状态: 0未申诉 1申诉中 2申诉成功 3申诉失败',
  `appeal_reason` VARCHAR(500) COMMENT '申诉理由',
  `appeal_time` DATETIME COMMENT '申诉时间',
  `appeal_result` VARCHAR(255) COMMENT '申诉结果',
  `processed_by` BIGINT COMMENT '处理人',
  `processed_time` DATETIME COMMENT '处理时间',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_appeal_status` (`appeal_status`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`),
  FOREIGN KEY (`reservation_id`) REFERENCES `reservation`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='违约记录表';

-- =====================================================
-- 7. 信用积分记录表
-- =====================================================
DROP TABLE IF EXISTS `credit_record`;
CREATE TABLE `credit_record` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `change_score` INT NOT NULL COMMENT '变动积分',
  `before_score` INT NOT NULL COMMENT '变动前积分',
  `after_score` INT NOT NULL COMMENT '变动后积分',
  `type` VARCHAR(50) NOT NULL COMMENT '变动类型',
  `source_type` VARCHAR(50) COMMENT '来源类型',
  `source_id` BIGINT COMMENT '来源ID',
  `description` VARCHAR(255) COMMENT '描述',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_created_at` (`created_at`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='信用积分记录表';

-- =====================================================
-- 8. 公告表
-- =====================================================
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '公告ID',
  `title` VARCHAR(200) NOT NULL COMMENT '标题',
  `content` TEXT NOT NULL COMMENT '内容',
  `summary` VARCHAR(500) COMMENT '摘要',
  `cover_image` VARCHAR(255) COMMENT '封面图',
  `type` VARCHAR(20) DEFAULT 'NORMAL' COMMENT '类型',
  `priority` INT DEFAULT 0 COMMENT '优先级',
  `is_top` TINYINT DEFAULT 0 COMMENT '是否置顶',
  `target_rooms` VARCHAR(500) COMMENT '针对的自习室ID',
  `target_users` VARCHAR(20) DEFAULT 'ALL' COMMENT '目标用户: ALL/STUDENT/ADMIN',
  `publisher_id` BIGINT COMMENT '发布人ID',
  `publisher_name` VARCHAR(50) COMMENT '发布人姓名',
  `publish_time` DATETIME COMMENT '发布时间',
  `expire_time` DATETIME COMMENT '过期时间',
  `view_count` INT DEFAULT 0 COMMENT '查看次数',
  `like_count` INT DEFAULT 0 COMMENT '点赞数',
  `status` TINYINT DEFAULT 1 COMMENT '状态',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_status` (`status`),
  INDEX `idx_type` (`type`),
  INDEX `idx_publish_time` (`publish_time`),
  INDEX `idx_is_top` (`is_top`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告表';

-- =====================================================
-- 9. 系统配置表
-- =====================================================
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '配置ID',
  `config_key` VARCHAR(100) UNIQUE NOT NULL COMMENT '配置键',
  `config_value` VARCHAR(500) NOT NULL COMMENT '配置值',
  `config_type` VARCHAR(20) DEFAULT 'STRING' COMMENT '值类型',
  `category` VARCHAR(50) DEFAULT 'SYSTEM' COMMENT '分类',
  `description` VARCHAR(255) COMMENT '配置描述',
  `editable` TINYINT DEFAULT 1 COMMENT '是否可编辑',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_config_key` (`config_key`),
  INDEX `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- =====================================================
-- 10. 黑名单表
-- =====================================================
DROP TABLE IF EXISTS `blacklist`;
CREATE TABLE `blacklist` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `reason` VARCHAR(255) COMMENT '加入原因',
  `credit_score_when_added` INT COMMENT '加入时信用分',
  `start_time` DATETIME NOT NULL COMMENT '开始时间',
  `end_time` DATETIME COMMENT '结束时间',
  `released` TINYINT DEFAULT 0 COMMENT '是否已解除',
  `release_time` DATETIME COMMENT '解除时间',
  `release_reason` VARCHAR(255) COMMENT '解除原因',
  `created_by` BIGINT COMMENT '操作人ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_end_time` (`end_time`),
  INDEX `idx_released` (`released`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='黑名单表';

-- =====================================================
-- 11. 操作日志表
-- =====================================================
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
  `user_id` BIGINT COMMENT '操作用户ID',
  `username` VARCHAR(50) COMMENT '操作用户名',
  `module` VARCHAR(50) COMMENT '模块',
  `action` VARCHAR(50) COMMENT '操作类型',
  `target_type` VARCHAR(50) COMMENT '目标类型',
  `target_id` BIGINT COMMENT '目标ID',
  `content` TEXT COMMENT '操作内容',
  `request_url` VARCHAR(255) COMMENT '请求URL',
  `request_method` VARCHAR(10) COMMENT '请求方法',
  `request_params` TEXT COMMENT '请求参数',
  `ip` VARCHAR(50) COMMENT 'IP地址',
  `user_agent` VARCHAR(500) COMMENT '浏览器信息',
  `status` TINYINT DEFAULT 1 COMMENT '状态',
  `error_msg` VARCHAR(500) COMMENT '错误信息',
  `duration` INT COMMENT '耗时(毫秒)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_module` (`module`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- =====================================================
-- 12. 收藏表
-- =====================================================
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '收藏ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `target_type` VARCHAR(20) NOT NULL COMMENT '收藏类型: ROOM/SEAT',
  `target_id` BIGINT NOT NULL COMMENT '收藏目标ID',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY `uk_user_target` (`user_id`, `target_type`, `target_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_target` (`target_type`, `target_id`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- =====================================================
-- 13. 每日签到打卡表
-- =====================================================
DROP TABLE IF EXISTS `check_in_record`;
CREATE TABLE `check_in_record` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `check_in_date` DATE NOT NULL COMMENT '签到日期',
  `check_in_time` DATETIME NOT NULL COMMENT '签到时间',
  `continuous_days` INT DEFAULT 1 COMMENT '连续天数',
  `earned_points` INT DEFAULT 0 COMMENT '获得积分',
  `earned_exp` INT DEFAULT 0 COMMENT '获得经验',
  `source` VARCHAR(20) DEFAULT 'MANUAL' COMMENT '来源: MANUAL手动/AUTO自动',
  `remark` VARCHAR(255) COMMENT '备注',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY `uk_user_date` (`user_id`, `check_in_date`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_check_in_date` (`check_in_date`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日签到打卡表';

-- =====================================================
-- 14. 学习目标表
-- =====================================================
DROP TABLE IF EXISTS `study_goal`;
CREATE TABLE `study_goal` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '目标ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `title` VARCHAR(100) NOT NULL COMMENT '目标标题',
  `description` TEXT COMMENT '目标描述',
  `goal_type` VARCHAR(20) NOT NULL COMMENT '类型: DAILY日/WEEKLY周/MONTHLY月/CUSTOM自定义',
  `target_hours` DECIMAL(10,2) NOT NULL COMMENT '目标时长(小时)',
  `completed_hours` DECIMAL(10,2) DEFAULT 0 COMMENT '已完成时长',
  `start_date` DATE NOT NULL COMMENT '开始日期',
  `end_date` DATE NOT NULL COMMENT '结束日期',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0已取消 1进行中 2已完成 3已过期',
  `completed_at` DATETIME COMMENT '完成时间',
  `earned_points` INT DEFAULT 0 COMMENT '完成奖励积分',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_end_date` (`end_date`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习目标表';

-- =====================================================
-- 15. 成就定义表
-- =====================================================
DROP TABLE IF EXISTS `achievement`;
CREATE TABLE `achievement` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成就ID',
  `name` VARCHAR(100) NOT NULL COMMENT '成就名称',
  `description` VARCHAR(255) COMMENT '成就描述',
  `icon` VARCHAR(255) COMMENT '图标',
  `badge_color` VARCHAR(20) COMMENT '徽章颜色',
  `category` VARCHAR(50) NOT NULL COMMENT '分类: STUDY学习/CHECK_IN打卡/SOCIAL社交/SPECIAL特殊',
  `condition_type` VARCHAR(50) NOT NULL COMMENT '条件类型',
  `condition_value` INT NOT NULL COMMENT '条件值',
  `reward_points` INT DEFAULT 0 COMMENT '奖励积分',
  `reward_exp` INT DEFAULT 0 COMMENT '奖励经验',
  `rarity` VARCHAR(20) DEFAULT 'COMMON' COMMENT '稀有度: COMMON普通/RARE稀有/EPIC史诗/LEGENDARY传说',
  `is_hidden` TINYINT DEFAULT 0 COMMENT '是否隐藏成就',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成就定义表';

-- =====================================================
-- 16. 用户成就表
-- =====================================================
DROP TABLE IF EXISTS `user_achievement`;
CREATE TABLE `user_achievement` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `achievement_id` BIGINT NOT NULL COMMENT '成就ID',
  `progress` INT DEFAULT 0 COMMENT '当前进度',
  `is_completed` TINYINT DEFAULT 0 COMMENT '是否完成',
  `completed_at` DATETIME COMMENT '完成时间',
  `is_claimed` TINYINT DEFAULT 0 COMMENT '是否已领取奖励',
  `claimed_at` DATETIME COMMENT '领取时间',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY `uk_user_achievement` (`user_id`, `achievement_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_is_completed` (`is_completed`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`),
  FOREIGN KEY (`achievement_id`) REFERENCES `achievement`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户成就表';

-- =====================================================
-- 17. 消息表
-- =====================================================
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
  `user_id` BIGINT NOT NULL COMMENT '接收用户ID',
  `title` VARCHAR(200) NOT NULL COMMENT '标题',
  `content` TEXT NOT NULL COMMENT '内容',
  `type` VARCHAR(20) NOT NULL COMMENT '类型: SYSTEM系统/RESERVATION预约/VIOLATION违约/ACHIEVEMENT成就/NOTICE公告',
  `related_type` VARCHAR(50) COMMENT '关联类型',
  `related_id` BIGINT COMMENT '关联ID',
  `is_read` TINYINT DEFAULT 0 COMMENT '是否已读',
  `read_time` DATETIME COMMENT '阅读时间',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_created_at` (`created_at`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

-- =====================================================
-- 18. 预约提醒表
-- =====================================================
DROP TABLE IF EXISTS `reminder`;
CREATE TABLE `reminder` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '提醒ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `reservation_id` BIGINT NOT NULL COMMENT '预约ID',
  `remind_type` VARCHAR(20) NOT NULL COMMENT '类型: BEFORE_START开始前/SIGN_IN签到/SIGN_OUT签退',
  `remind_time` DATETIME NOT NULL COMMENT '提醒时间',
  `remind_minutes` INT COMMENT '提前分钟数',
  `is_sent` TINYINT DEFAULT 0 COMMENT '是否已发送',
  `sent_time` DATETIME COMMENT '发送时间',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_remind_time` (`remind_time`),
  INDEX `idx_is_sent` (`is_sent`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`),
  FOREIGN KEY (`reservation_id`) REFERENCES `reservation`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约提醒表';

-- =====================================================
-- 19. 座位评价表
-- =====================================================
DROP TABLE IF EXISTS `seat_review`;
CREATE TABLE `seat_review` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评价ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `reservation_id` BIGINT NOT NULL COMMENT '预约ID',
  `room_id` BIGINT NOT NULL COMMENT '自习室ID',
  `seat_id` BIGINT NOT NULL COMMENT '座位ID',
  `rating` INT NOT NULL COMMENT '评分(1-5)',
  `content` VARCHAR(500) COMMENT '评价内容',
  `tags` VARCHAR(255) COMMENT '标签(JSON): ["安静","采光好"]',
  `images` TEXT COMMENT '图片(JSON数组)',
  `is_anonymous` TINYINT DEFAULT 0 COMMENT '是否匿名',
  `like_count` INT DEFAULT 0 COMMENT '点赞数',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0隐藏 1显示',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_room_id` (`room_id`),
  INDEX `idx_seat_id` (`seat_id`),
  INDEX `idx_rating` (`rating`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`),
  FOREIGN KEY (`reservation_id`) REFERENCES `reservation`(`id`),
  FOREIGN KEY (`room_id`) REFERENCES `study_room`(`id`),
  FOREIGN KEY (`seat_id`) REFERENCES `seat`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='座位评价表';

-- =====================================================
-- 20. 自习室每日统计表
-- =====================================================
DROP TABLE IF EXISTS `room_daily_stats`;
CREATE TABLE `room_daily_stats` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `room_id` BIGINT NOT NULL COMMENT '自习室ID',
  `stats_date` DATE NOT NULL COMMENT '统计日期',
  `total_reservations` INT DEFAULT 0 COMMENT '预约总数',
  `completed_count` INT DEFAULT 0 COMMENT '完成数',
  `cancelled_count` INT DEFAULT 0 COMMENT '取消数',
  `violated_count` INT DEFAULT 0 COMMENT '违约数',
  `total_hours` DECIMAL(10,2) DEFAULT 0 COMMENT '总使用时长',
  `unique_users` INT DEFAULT 0 COMMENT '独立用户数',
  `peak_hour` INT COMMENT '高峰小时(0-23)',
  `peak_count` INT DEFAULT 0 COMMENT '高峰时段预约数',
  `usage_rate` DECIMAL(5,2) DEFAULT 0 COMMENT '使用率(%)',
  `avg_duration` INT DEFAULT 0 COMMENT '平均使用时长(分钟)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY `uk_room_date` (`room_id`, `stats_date`),
  INDEX `idx_room_id` (`room_id`),
  INDEX `idx_stats_date` (`stats_date`),
  FOREIGN KEY (`room_id`) REFERENCES `study_room`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='自习室每日统计表';

-- =====================================================
-- 21. 好友关系表
-- =====================================================
DROP TABLE IF EXISTS `friendship`;
CREATE TABLE `friendship` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `friend_id` BIGINT NOT NULL COMMENT '好友ID',
  `status` TINYINT DEFAULT 0 COMMENT '状态: 0待确认 1已确认 2已拒绝 3已删除',
  `remark` VARCHAR(50) COMMENT '备注名',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY `uk_user_friend` (`user_id`, `friend_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_friend_id` (`friend_id`),
  INDEX `idx_status` (`status`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`),
  FOREIGN KEY (`friend_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='好友关系表';

-- =====================================================
-- 22. 学习小组表
-- =====================================================
DROP TABLE IF EXISTS `study_group`;
CREATE TABLE `study_group` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '小组ID',
  `name` VARCHAR(100) NOT NULL COMMENT '小组名称',
  `description` TEXT COMMENT '小组描述',
  `avatar` VARCHAR(255) COMMENT '小组头像',
  `cover_image` VARCHAR(255) COMMENT '封面图',
  `creator_id` BIGINT NOT NULL COMMENT '创建者ID',
  `max_members` INT DEFAULT 50 COMMENT '最大成员数',
  `member_count` INT DEFAULT 1 COMMENT '当前成员数',
  `total_hours` DECIMAL(10,2) DEFAULT 0 COMMENT '小组总学习时长',
  `weekly_hours` DECIMAL(10,2) DEFAULT 0 COMMENT '本周学习时长',
  `is_public` TINYINT DEFAULT 1 COMMENT '是否公开: 0私密 1公开',
  `need_approve` TINYINT DEFAULT 0 COMMENT '加入需审批',
  `tags` VARCHAR(255) COMMENT '标签',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0已解散 1正常',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_creator_id` (`creator_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_is_public` (`is_public`),
  FOREIGN KEY (`creator_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习小组表';

-- =====================================================
-- 23. 小组成员表
-- =====================================================
DROP TABLE IF EXISTS `group_member`;
CREATE TABLE `group_member` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `group_id` BIGINT NOT NULL COMMENT '小组ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role` VARCHAR(20) DEFAULT 'MEMBER' COMMENT '角色: CREATOR创建者/ADMIN管理员/MEMBER成员',
  `nickname` VARCHAR(50) COMMENT '小组内昵称',
  `contribution_hours` DECIMAL(10,2) DEFAULT 0 COMMENT '贡献时长',
  `join_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0待审批 1正常 2已退出',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY `uk_group_user` (`group_id`, `user_id`),
  INDEX `idx_group_id` (`group_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_role` (`role`),
  FOREIGN KEY (`group_id`) REFERENCES `study_group`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='小组成员表';

-- =====================================================
-- 24. 排行榜快照表
-- =====================================================
DROP TABLE IF EXISTS `ranking_snapshot`;
CREATE TABLE `ranking_snapshot` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `ranking_type` VARCHAR(20) NOT NULL COMMENT '类型: DAILY日/WEEKLY周/MONTHLY月',
  `metric_type` VARCHAR(20) NOT NULL COMMENT '指标: HOURS时长/RESERVATIONS预约数/CHECK_INS打卡',
  `snapshot_date` DATE NOT NULL COMMENT '快照日期',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `rank_position` INT NOT NULL COMMENT '排名',
  `metric_value` DECIMAL(10,2) NOT NULL COMMENT '指标值',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX `idx_type_date` (`ranking_type`, `metric_type`, `snapshot_date`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_rank` (`rank_position`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='排行榜快照表';

-- =====================================================
-- 25. 反馈建议表
-- =====================================================
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '反馈ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `type` VARCHAR(20) NOT NULL COMMENT '类型: SUGGESTION建议/BUG问题/COMPLAINT投诉/OTHER其他',
  `title` VARCHAR(200) NOT NULL COMMENT '标题',
  `content` TEXT NOT NULL COMMENT '内容',
  `images` TEXT COMMENT '图片(JSON)',
  `contact` VARCHAR(100) COMMENT '联系方式',
  `related_room_id` BIGINT COMMENT '相关自习室',
  `status` TINYINT DEFAULT 0 COMMENT '状态: 0待处理 1处理中 2已解决 3已关闭',
  `reply_content` TEXT COMMENT '回复内容',
  `reply_time` DATETIME COMMENT '回复时间',
  `reply_by` BIGINT COMMENT '回复人',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_status` (`status`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='反馈建议表';

-- =====================================================
-- 26. 积分商城-商品表
-- =====================================================
DROP TABLE IF EXISTS `point_product`;
CREATE TABLE `point_product` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '商品ID',
  `name` VARCHAR(100) NOT NULL COMMENT '商品名称',
  `description` TEXT COMMENT '商品描述',
  `image` VARCHAR(255) COMMENT '商品图片',
  `category` VARCHAR(50) COMMENT '分类',
  `points_required` INT NOT NULL COMMENT '所需积分',
  `stock` INT DEFAULT -1 COMMENT '库存(-1为无限)',
  `limit_per_user` INT DEFAULT 0 COMMENT '每人限购(0不限)',
  `start_time` DATETIME COMMENT '上架时间',
  `end_time` DATETIME COMMENT '下架时间',
  `exchange_count` INT DEFAULT 0 COMMENT '兑换次数',
  `status` TINYINT DEFAULT 1 COMMENT '状态: 0下架 1上架',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_category` (`category`),
  INDEX `idx_status` (`status`),
  INDEX `idx_points` (`points_required`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分商城-商品表';

-- =====================================================
-- 27. 积分商城-兑换记录表
-- =====================================================
DROP TABLE IF EXISTS `point_exchange`;
CREATE TABLE `point_exchange` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(100) COMMENT '商品名称',
  `points_used` INT NOT NULL COMMENT '使用积分',
  `quantity` INT DEFAULT 1 COMMENT '数量',
  `status` TINYINT DEFAULT 0 COMMENT '状态: 0待发放 1已发放 2已取消',
  `remark` VARCHAR(255) COMMENT '备注',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_product_id` (`product_id`),
  INDEX `idx_status` (`status`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`),
  FOREIGN KEY (`product_id`) REFERENCES `point_product`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分商城-兑换记录表';

-- =====================================================
-- 创建完成提示
-- =====================================================
SELECT '数据库表创建完成! 共27张表' AS '提示';
