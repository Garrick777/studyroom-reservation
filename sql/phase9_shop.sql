-- ============================================
-- 第九阶段：积分商城与排行榜
-- ============================================

-- 积分商品表
CREATE TABLE IF NOT EXISTS `point_product` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '商品ID',
    `name` varchar(100) NOT NULL COMMENT '商品名称',
    `description` text COMMENT '商品描述',
    `image` varchar(500) DEFAULT NULL COMMENT '商品图片',
    `category` varchar(20) NOT NULL DEFAULT 'VIRTUAL' COMMENT '商品分类: VIRTUAL虚拟 PHYSICAL实物 COUPON优惠券',
    `points_cost` int NOT NULL COMMENT '所需积分',
    `stock` int DEFAULT -1 COMMENT '库存数量(-1无限)',
    `exchanged_count` int DEFAULT 0 COMMENT '已兑换数量',
    `limit_per_user` int DEFAULT 0 COMMENT '每人限兑(0不限)',
    `status` tinyint DEFAULT 1 COMMENT '状态: 0下架 1上架',
    `sort_order` int DEFAULT 0 COMMENT '排序权重',
    `start_time` datetime DEFAULT NULL COMMENT '生效开始时间',
    `end_time` datetime DEFAULT NULL COMMENT '生效结束时间',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` tinyint DEFAULT 0 COMMENT '是否删除',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_status` (`status`),
    KEY `idx_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分商品表';

-- 积分兑换记录表
CREATE TABLE IF NOT EXISTS `point_exchange` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '兑换ID',
    `exchange_no` varchar(50) NOT NULL COMMENT '兑换单号',
    `user_id` bigint NOT NULL COMMENT '用户ID',
    `product_id` bigint NOT NULL COMMENT '商品ID',
    `product_name` varchar(100) DEFAULT NULL COMMENT '商品名称(冗余)',
    `product_image` varchar(500) DEFAULT NULL COMMENT '商品图片(冗余)',
    `points_cost` int NOT NULL COMMENT '消耗积分',
    `quantity` int DEFAULT 1 COMMENT '兑换数量',
    `status` varchar(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING待处理 PROCESSING处理中 COMPLETED已完成 CANCELLED已取消',
    `receiver_name` varchar(50) DEFAULT NULL COMMENT '收货人姓名',
    `receiver_phone` varchar(20) DEFAULT NULL COMMENT '收货人电话',
    `receiver_address` varchar(200) DEFAULT NULL COMMENT '收货地址',
    `tracking_no` varchar(50) DEFAULT NULL COMMENT '物流单号',
    `redeem_code` varchar(50) DEFAULT NULL COMMENT '兑换码(虚拟商品)',
    `remark` varchar(200) DEFAULT NULL COMMENT '备注',
    `process_time` datetime DEFAULT NULL COMMENT '处理时间',
    `complete_time` datetime DEFAULT NULL COMMENT '完成时间',
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_exchange_no` (`exchange_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_product_id` (`product_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='积分兑换记录表';

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
