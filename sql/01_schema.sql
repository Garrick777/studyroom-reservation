-- =====================================================
-- 智慧自习室座位预约系统 - 数据库表结构脚本
-- Smart Study Room Seat Reservation System - Schema
-- 
-- 数据库: studyroom
-- 字符集: utf8mb4
-- 表数量: 17张
-- 
-- 使用方法:
--   mysql -u root -p < 01_schema.sql
-- =====================================================

CREATE DATABASE IF NOT EXISTS `studyroom` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `studyroom`;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `achievement`
--

DROP TABLE IF EXISTS `achievement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievement` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `icon` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `badge_color` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `category` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `condition_type` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `condition_value` int NOT NULL,
  `reward_points` int DEFAULT '0',
  `reward_exp` int DEFAULT '0',
  `rarity` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'COMMON',
  `is_hidden` tinyint DEFAULT '0',
  `sort_order` int DEFAULT '0',
  `status` tinyint DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blacklist`
--

DROP TABLE IF EXISTS `blacklist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blacklist` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'è®°å½•ID',
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `reason` varchar(255) DEFAULT NULL COMMENT 'åŠ å…¥åŽŸå› ',
  `credit_score_when_added` int DEFAULT NULL COMMENT 'åŠ å…¥æ—¶ä¿¡ç”¨åˆ†',
  `start_time` datetime NOT NULL COMMENT 'å¼€å§‹æ—¶é—´',
  `end_time` datetime DEFAULT NULL COMMENT 'ç»“æŸæ—¶é—´',
  `released` tinyint DEFAULT '0' COMMENT 'æ˜¯å¦å·²è§£é™¤',
  `release_time` datetime DEFAULT NULL COMMENT 'è§£é™¤æ—¶é—´',
  `release_reason` varchar(255) DEFAULT NULL COMMENT 'è§£é™¤åŽŸå› ',
  `created_by` bigint DEFAULT NULL COMMENT 'æ“ä½œäººID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_end_time` (`end_time`),
  KEY `idx_released` (`released`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='é»‘åå•è¡¨';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `check_in_record`
--

DROP TABLE IF EXISTS `check_in_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `check_in_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'è®°å½•ID',
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `check_in_date` date NOT NULL COMMENT 'æ‰“å¡æ—¥æœŸ',
  `check_in_time` datetime NOT NULL COMMENT 'æ‰“å¡æ—¶é—´',
  `type` varchar(20) DEFAULT 'DAILY' COMMENT 'æ‰“å¡ç±»åž‹',
  `earned_points` int DEFAULT '0' COMMENT 'èŽ·å¾—ç§¯åˆ†',
  `earned_exp` int DEFAULT '0' COMMENT 'èŽ·å¾—ç»éªŒ',
  `continuous_days` int DEFAULT '1' COMMENT 'è¿žç»­æ‰“å¡å¤©æ•°',
  `source` varchar(20) DEFAULT 'WEB' COMMENT 'æ¥æº',
  `remark` varchar(255) DEFAULT NULL COMMENT 'å¤‡æ³¨',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date_type` (`user_id`,`check_in_date`,`type`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_check_in_date` (`check_in_date`)
) ENGINE=InnoDB AUTO_INCREMENT=1067 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='æ‰“å¡è®°å½•è¡¨';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `credit_record`
--

DROP TABLE IF EXISTS `credit_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `credit_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'è®°å½•ID',
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `change_score` int NOT NULL COMMENT 'å˜åŠ¨ç§¯åˆ†',
  `before_score` int NOT NULL COMMENT 'å˜åŠ¨å‰ç§¯åˆ†',
  `after_score` int NOT NULL COMMENT 'å˜åŠ¨åŽç§¯åˆ†',
  `type` varchar(50) NOT NULL COMMENT 'å˜åŠ¨ç±»åž‹',
  `source_type` varchar(50) DEFAULT NULL COMMENT 'æ¥æºç±»åž‹',
  `source_id` bigint DEFAULT NULL COMMENT 'æ¥æºID',
  `description` varchar(255) DEFAULT NULL COMMENT 'æè¿°',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='ä¿¡ç”¨ç§¯åˆ†è®°å½•è¡¨';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `friendship`
--

DROP TABLE IF EXISTS `friendship`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friendship` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `friend_id` bigint NOT NULL,
  `status` tinyint DEFAULT '0' COMMENT '0待确认 1已确认 2已拒绝 3已删除',
  `remark` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_friend` (`user_id`,`friend_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_friend_id` (`friend_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_member`
--

DROP TABLE IF EXISTS `group_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `group_member` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `role` varchar(20) COLLATE utf8mb4_general_ci DEFAULT 'MEMBER' COMMENT 'CREATOR/ADMIN/MEMBER',
  `nickname` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `contribution_hours` decimal(10,2) DEFAULT '0.00',
  `join_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint DEFAULT '1' COMMENT '0待审批 1正常 2已退出',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_group_user` (`group_id`,`user_id`),
  KEY `idx_group_id` (`group_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `content` text COLLATE utf8mb4_general_ci NOT NULL,
  `type` varchar(20) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'SYSTEM/RESERVATION/VIOLATION/ACHIEVEMENT/FRIEND/GROUP',
  `related_type` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `related_id` bigint DEFAULT NULL,
  `is_read` tinyint DEFAULT '0',
  `read_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `point_exchange`
--

DROP TABLE IF EXISTS `point_exchange`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `point_exchange` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'å…‘æ¢ID',
  `exchange_no` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'å…‘æ¢å•å·',
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `product_id` bigint NOT NULL COMMENT 'å•†å“ID',
  `product_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'å•†å“åç§°(å†—ä½™)',
  `product_image` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'å•†å“å›¾ç‰‡(å†—ä½™)',
  `points_cost` int NOT NULL COMMENT 'æ¶ˆè€—ç§¯åˆ†',
  `quantity` int DEFAULT '1' COMMENT 'å…‘æ¢æ•°é‡',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING' COMMENT 'çŠ¶æ€: PENDINGå¾…å¤„ç† PROCESSINGå¤„ç†ä¸­ COMPLETEDå·²å®Œæˆ CANCELLEDå·²å–æ¶ˆ',
  `receiver_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'æ”¶è´§äººå§“å',
  `receiver_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'æ”¶è´§äººç”µè¯',
  `receiver_address` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'æ”¶è´§åœ°å€',
  `tracking_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ç‰©æµå•å·',
  `redeem_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'å…‘æ¢ç (è™šæ‹Ÿå•†å“)',
  `remark` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'å¤‡æ³¨',
  `process_time` datetime DEFAULT NULL COMMENT 'å¤„ç†æ—¶é—´',
  `complete_time` datetime DEFAULT NULL COMMENT 'å®Œæˆæ—¶é—´',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'æ›´æ–°æ—¶é—´',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_exchange_no` (`exchange_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ç§¯åˆ†å…‘æ¢è®°å½•è¡¨';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `point_product`
--

DROP TABLE IF EXISTS `point_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `point_product` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'å•†å“ID',
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'å•†å“åç§°',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT 'å•†å“æè¿°',
  `image` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'å•†å“å›¾ç‰‡',
  `category` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'VIRTUAL' COMMENT 'å•†å“åˆ†ç±»: VIRTUALè™šæ‹Ÿ PHYSICALå®žç‰© COUPONä¼˜æƒ åˆ¸',
  `points_cost` int NOT NULL COMMENT 'æ‰€éœ€ç§¯åˆ†',
  `stock` int DEFAULT '-1' COMMENT 'åº“å­˜æ•°é‡(-1æ— é™)',
  `exchanged_count` int DEFAULT '0' COMMENT 'å·²å…‘æ¢æ•°é‡',
  `limit_per_user` int DEFAULT '0' COMMENT 'æ¯äººé™å…‘(0ä¸é™)',
  `status` tinyint DEFAULT '1' COMMENT 'çŠ¶æ€: 0ä¸‹æž¶ 1ä¸Šæž¶',
  `sort_order` int DEFAULT '0' COMMENT 'æŽ’åºæƒé‡',
  `start_time` datetime DEFAULT NULL COMMENT 'ç”Ÿæ•ˆå¼€å§‹æ—¶é—´',
  `end_time` datetime DEFAULT NULL COMMENT 'ç”Ÿæ•ˆç»“æŸæ—¶é—´',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'æ›´æ–°æ—¶é—´',
  `deleted` tinyint DEFAULT '0' COMMENT 'æ˜¯å¦åˆ é™¤',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_status` (`status`),
  KEY `idx_sort` (`sort_order`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ç§¯åˆ†å•†å“è¡¨';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'é¢„çº¦ID',
  `reservation_no` varchar(32) NOT NULL COMMENT 'é¢„çº¦ç¼–å·',
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `room_id` bigint NOT NULL COMMENT 'è‡ªä¹ å®¤ID',
  `seat_id` bigint NOT NULL COMMENT 'åº§ä½ID',
  `date` date NOT NULL COMMENT 'é¢„çº¦æ—¥æœŸ',
  `time_slot_id` bigint NOT NULL COMMENT 'æ—¶æ®µID',
  `start_time` datetime NOT NULL COMMENT 'å¼€å§‹æ—¶é—´',
  `end_time` datetime NOT NULL COMMENT 'ç»“æŸæ—¶é—´',
  `status` varchar(20) DEFAULT 'PENDING' COMMENT 'çŠ¶æ€',
  `sign_in_time` datetime DEFAULT NULL COMMENT 'ç­¾åˆ°æ—¶é—´',
  `sign_out_time` datetime DEFAULT NULL COMMENT 'ç­¾é€€æ—¶é—´',
  `actual_duration` int DEFAULT NULL COMMENT 'å®žé™…ä½¿ç”¨æ—¶é•¿(åˆ†é’Ÿ)',
  `leave_time` datetime DEFAULT NULL COMMENT 'æš‚ç¦»æ—¶é—´',
  `return_time` datetime DEFAULT NULL COMMENT 'æš‚ç¦»è¿”å›žæ—¶é—´',
  `leave_count` int DEFAULT '0' COMMENT 'æš‚ç¦»æ¬¡æ•°',
  `cancel_time` datetime DEFAULT NULL COMMENT 'å–æ¶ˆæ—¶é—´',
  `cancel_reason` varchar(255) DEFAULT NULL COMMENT 'å–æ¶ˆåŽŸå› ',
  `violation_type` varchar(50) DEFAULT NULL COMMENT 'è¿çº¦ç±»åž‹',
  `earned_points` int DEFAULT '0' COMMENT 'èŽ·å¾—ç§¯åˆ†',
  `earned_exp` int DEFAULT '0' COMMENT 'èŽ·å¾—ç»éªŒ',
  `remark` varchar(255) DEFAULT NULL COMMENT 'å¤‡æ³¨',
  `source` varchar(20) DEFAULT 'WEB' COMMENT 'é¢„çº¦æ¥æº: WEB/APP/WECHAT',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'æ›´æ–°æ—¶é—´',
  PRIMARY KEY (`id`),
  UNIQUE KEY `reservation_no` (`reservation_no`),
  UNIQUE KEY `uk_seat_date_slot` (`seat_id`,`date`,`time_slot_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_room_id` (`room_id`),
  KEY `idx_seat_id` (`seat_id`),
  KEY `idx_date` (`date`),
  KEY `idx_status` (`status`),
  KEY `idx_user_date` (`user_id`,`date`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_reservation_user_id` (`user_id`),
  KEY `idx_reservation_seat_id` (`seat_id`),
  KEY `idx_reservation_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=1659 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='é¢„çº¦è¡¨';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `seat`
--

DROP TABLE IF EXISTS `seat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seat` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '座位ID',
  `room_id` bigint NOT NULL COMMENT '自习室ID',
  `seat_no` varchar(20) NOT NULL COMMENT '座位编号',
  `row_num` int NOT NULL COMMENT '行号',
  `col_num` int NOT NULL COMMENT '列号',
  `seat_type` varchar(20) DEFAULT 'NORMAL' COMMENT '座位类型: NORMAL/WINDOW/POWER/VIP',
  `status` tinyint DEFAULT '1' COMMENT '状态: 0不可用 1可用 2维修中',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_room_seat` (`room_id`,`seat_no`),
  KEY `idx_room_id` (`room_id`),
  KEY `idx_status` (`status`),
  KEY `idx_seat_room_id` (`room_id`),
  KEY `idx_seat_status` (`status`),
  KEY `idx_seat_room_status` (`room_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2825 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='座位表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `seat_review`
--

DROP TABLE IF EXISTS `seat_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seat_review` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'è¯„ä»·ID',
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `seat_id` bigint NOT NULL COMMENT 'åº§ä½ID',
  `reservation_id` bigint NOT NULL COMMENT 'é¢„çº¦ID',
  `rating` int NOT NULL COMMENT 'è¯„åˆ†(1-5)',
  `content` varchar(500) DEFAULT NULL COMMENT 'è¯„ä»·å†…å®¹',
  `tags` varchar(255) DEFAULT NULL COMMENT 'æ ‡ç­¾(JSONæ•°ç»„)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  PRIMARY KEY (`id`),
  KEY `idx_seat_id` (`seat_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='åº§ä½è¯„ä»·è¡¨';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `study_goal`
--

DROP TABLE IF EXISTS `study_goal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_goal` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ç›®æ ‡ID',
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `name` varchar(100) NOT NULL COMMENT 'ç›®æ ‡åç§°',
  `type` varchar(50) NOT NULL COMMENT 'ç›®æ ‡ç±»åž‹',
  `target_value` decimal(10,2) NOT NULL COMMENT 'ç›®æ ‡å€¼',
  `current_value` decimal(10,2) DEFAULT '0.00' COMMENT 'å½“å‰è¿›åº¦',
  `unit` varchar(20) DEFAULT 'HOUR' COMMENT 'å•ä½',
  `start_date` date DEFAULT NULL COMMENT 'å¼€å§‹æ—¥æœŸ',
  `end_date` date DEFAULT NULL COMMENT 'ç»“æŸæ—¥æœŸ',
  `status` varchar(20) DEFAULT 'ACTIVE' COMMENT 'çŠ¶æ€',
  `completed_time` datetime DEFAULT NULL COMMENT 'å®Œæˆæ—¶é—´',
  `reward_points` int DEFAULT '0' COMMENT 'å¥–åŠ±ç§¯åˆ†',
  `reward_exp` int DEFAULT '0' COMMENT 'å¥–åŠ±ç»éªŒ',
  `reward_claimed` tinyint DEFAULT '0' COMMENT 'æ˜¯å¦å·²é¢†å–å¥–åŠ±',
  `description` varchar(500) DEFAULT NULL COMMENT 'æè¿°',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'æ›´æ–°æ—¶é—´',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_end_date` (`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='å­¦ä¹ ç›®æ ‡è¡¨';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `study_group`
--

DROP TABLE IF EXISTS `study_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_group` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `avatar` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `cover_image` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `creator_id` bigint NOT NULL,
  `max_members` int DEFAULT '50',
  `member_count` int DEFAULT '1',
  `total_hours` decimal(10,2) DEFAULT '0.00',
  `weekly_hours` decimal(10,2) DEFAULT '0.00',
  `is_public` tinyint DEFAULT '1',
  `need_approve` tinyint DEFAULT '0',
  `tags` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` tinyint DEFAULT '1' COMMENT '0已解散 1正常',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_creator_id` (`creator_id`),
  KEY `idx_status` (`status`),
  KEY `idx_is_public` (`is_public`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `study_room`
--

DROP TABLE IF EXISTS `study_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_room` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自习室ID',
  `name` varchar(100) NOT NULL COMMENT '自习室名称',
  `code` varchar(20) DEFAULT NULL COMMENT '自习室编号',
  `building` varchar(100) DEFAULT NULL COMMENT '所在建筑',
  `floor` varchar(20) DEFAULT NULL COMMENT '楼层',
  `room_number` varchar(20) DEFAULT NULL COMMENT '房间号',
  `capacity` int NOT NULL COMMENT '座位总数',
  `row_count` int NOT NULL COMMENT '座位行数',
  `col_count` int NOT NULL COMMENT '座位列数',
  `description` text COMMENT '描述信息',
  `facilities` json DEFAULT NULL COMMENT '设施(JSON数组)',
  `cover_image` varchar(255) DEFAULT NULL COMMENT '封面图片',
  `images` json DEFAULT NULL COMMENT '图片集(JSON数组)',
  `open_time` time NOT NULL COMMENT '开放时间',
  `close_time` time NOT NULL COMMENT '关闭时间',
  `advance_days` int DEFAULT '7' COMMENT '最大提前预约天数',
  `max_duration` int DEFAULT '4' COMMENT '单次最大预约时长(小时)',
  `min_credit_score` int DEFAULT '60' COMMENT '最低信用分要求',
  `need_approve` tinyint DEFAULT '0' COMMENT '是否需要审批',
  `allow_temp` tinyint DEFAULT '1' COMMENT '是否允许临时预约',
  `rating` decimal(2,1) DEFAULT '5.0' COMMENT '评分',
  `rating_count` int DEFAULT '0' COMMENT '评分人数',
  `today_reservations` int DEFAULT '0' COMMENT '今日预约数',
  `total_reservations` int DEFAULT '0' COMMENT '总预约数',
  `manager_id` bigint DEFAULT NULL COMMENT '管理员ID',
  `status` tinyint DEFAULT '1' COMMENT '状态: 0关闭 1开放 2维护中',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint DEFAULT '0' COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_status` (`status`),
  KEY `idx_building` (`building`),
  KEY `idx_rating` (`rating`),
  KEY `idx_study_room_status` (`status`),
  KEY `idx_study_room_building` (`building`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='自习室表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `time_slot`
--

DROP TABLE IF EXISTS `time_slot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `time_slot` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '时段ID',
  `name` varchar(50) NOT NULL COMMENT '时段名称',
  `start_time` time NOT NULL COMMENT '开始时间',
  `end_time` time NOT NULL COMMENT '结束时间',
  `duration` int NOT NULL COMMENT '时长(分钟)',
  `sort_order` int DEFAULT '0' COMMENT '排序',
  `status` tinyint DEFAULT '1' COMMENT '状态: 0禁用 1启用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='时段表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码(BCrypt加密)',
  `student_id` varchar(20) NOT NULL COMMENT '学号',
  `real_name` varchar(50) NOT NULL COMMENT '真实姓名',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `gender` tinyint DEFAULT '0' COMMENT '性别: 0未知 1男 2女',
  `college` varchar(100) DEFAULT NULL COMMENT '学院',
  `major` varchar(100) DEFAULT NULL COMMENT '专业',
  `grade` varchar(20) DEFAULT NULL COMMENT '年级',
  `class_no` varchar(50) DEFAULT NULL COMMENT '班级',
  `credit_score` int DEFAULT '100' COMMENT '信用积分(0-100)',
  `total_study_time` int DEFAULT '0' COMMENT '累计学习时长(分钟)',
  `total_points` int DEFAULT '0' COMMENT '总积分',
  `consecutive_days` int DEFAULT '0' COMMENT '连续签到天数',
  `total_check_ins` int DEFAULT '0' COMMENT '总签到天数',
  `exp` int DEFAULT '0' COMMENT 'ç»éªŒå€¼',
  `current_streak` int DEFAULT '0' COMMENT '当前连续学习天数',
  `max_streak` int DEFAULT '0' COMMENT '最长连续学习天数',
  `last_check_in_date` datetime DEFAULT NULL COMMENT '上次签到日期',
  `role` varchar(20) DEFAULT 'STUDENT' COMMENT '角色: STUDENT/ADMIN/SUPER_ADMIN',
  `status` tinyint DEFAULT '1' COMMENT '状态: 0禁用 1正常 2黑名单',
  `blacklist_end_time` datetime DEFAULT NULL COMMENT '黑名单结束时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint DEFAULT '0' COMMENT '逻辑删除: 0未删除 1已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `student_id` (`student_id`),
  KEY `idx_username` (`username`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_user_username` (`username`),
  KEY `idx_user_student_id` (`student_id`),
  KEY `idx_user_status` (`status`),
  KEY `idx_user_role` (`role`),
  KEY `idx_user_credit_score` (`credit_score` DESC),
  KEY `idx_user_total_study_time` (`total_study_time` DESC),
  KEY `idx_user_total_points` (`total_points` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_achievement`
--

DROP TABLE IF EXISTS `user_achievement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_achievement` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `achievement_id` bigint NOT NULL,
  `progress` int DEFAULT '0',
  `is_completed` tinyint DEFAULT '0',
  `completed_at` datetime DEFAULT NULL,
  `is_claimed` tinyint DEFAULT '0',
  `claimed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_achievement` (`user_id`,`achievement_id`)
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_favorite`
--

DROP TABLE IF EXISTS `user_favorite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_favorite` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `room_id` bigint NOT NULL COMMENT '自习室ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_room` (`user_id`,`room_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_room_id` (`room_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户收藏表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `violation_record`
--

DROP TABLE IF EXISTS `violation_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `violation_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'è®°å½•ID',
  `user_id` bigint NOT NULL COMMENT 'ç”¨æˆ·ID',
  `reservation_id` bigint DEFAULT NULL COMMENT 'å…³è”é¢„çº¦ID',
  `type` varchar(50) NOT NULL COMMENT 'è¿çº¦ç±»åž‹',
  `description` varchar(255) DEFAULT NULL COMMENT 'è¿çº¦æè¿°',
  `deduct_score` int NOT NULL COMMENT 'æ‰£é™¤ç§¯åˆ†',
  `before_score` int DEFAULT NULL COMMENT 'æ‰£é™¤å‰ç§¯åˆ†',
  `after_score` int DEFAULT NULL COMMENT 'æ‰£é™¤åŽç§¯åˆ†',
  `appeal_status` tinyint DEFAULT '0' COMMENT 'ç”³è¯‰çŠ¶æ€: 0æœªç”³è¯‰ 1ç”³è¯‰ä¸­ 2ç”³è¯‰æˆåŠŸ 3ç”³è¯‰å¤±è´¥',
  `appeal_reason` varchar(500) DEFAULT NULL COMMENT 'ç”³è¯‰ç†ç”±',
  `appeal_time` datetime DEFAULT NULL COMMENT 'ç”³è¯‰æ—¶é—´',
  `appeal_result` varchar(255) DEFAULT NULL COMMENT 'ç”³è¯‰ç»“æžœ',
  `processed_by` bigint DEFAULT NULL COMMENT 'å¤„ç†äºº',
  `processed_time` datetime DEFAULT NULL COMMENT 'å¤„ç†æ—¶é—´',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'åˆ›å»ºæ—¶é—´',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_appeal_status` (`appeal_status`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='è¿çº¦è®°å½•è¡¨';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'studyroom'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-22 17:08:03
