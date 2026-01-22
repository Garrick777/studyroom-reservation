-- =====================================================
-- 智慧自习室座位预约系统 - 索引优化脚本
-- Smart Study Room Seat Reservation System - Indexes
-- 
-- 用于优化数据库查询性能
-- 注意: 部分索引可能已存在，执行时会报错但不影响
-- 
-- 使用方法 (可选):
--   mysql -u root -p studyroom < 03_indexes.sql
-- =====================================================

-- 用户表索引（忽略已存在的索引错误）
CREATE INDEX idx_user_username ON user(username);
CREATE INDEX idx_user_student_id ON user(student_id);
CREATE INDEX idx_user_status ON user(status);
CREATE INDEX idx_user_role ON user(role);
CREATE INDEX idx_user_credit_score ON user(credit_score DESC);
CREATE INDEX idx_user_total_study_time ON user(total_study_time DESC);
CREATE INDEX idx_user_total_points ON user(total_points DESC);

-- 自习室表索引
CREATE INDEX idx_study_room_status ON study_room(status);
CREATE INDEX idx_study_room_building ON study_room(building);

-- 座位表索引
CREATE INDEX idx_seat_room_id ON seat(room_id);
CREATE INDEX idx_seat_status ON seat(status);
CREATE INDEX idx_seat_room_status ON seat(room_id, status);

-- 预约表索引（高频查询优化）
CREATE INDEX idx_reservation_user_id ON reservation(user_id);
CREATE INDEX idx_reservation_seat_id ON reservation(seat_id);
CREATE INDEX idx_reservation_status ON reservation(status);
CREATE INDEX idx_reservation_date ON reservation(reservation_date);
CREATE INDEX idx_reservation_user_status ON reservation(user_id, status);
CREATE INDEX idx_reservation_seat_date ON reservation(seat_id, reservation_date);
CREATE INDEX idx_reservation_time_range ON reservation(start_time, end_time);
CREATE INDEX idx_reservation_created_at ON reservation(created_at DESC);

-- 违规记录表索引
CREATE INDEX idx_violation_user_id ON violation_record(user_id);
CREATE INDEX idx_violation_type ON violation_record(type);
CREATE INDEX idx_violation_created_at ON violation_record(created_at DESC);

-- 信用记录表索引
CREATE INDEX idx_credit_user_id ON credit_record(user_id);
CREATE INDEX idx_credit_type ON credit_record(type);
CREATE INDEX idx_credit_created_at ON credit_record(created_at DESC);

-- 打卡记录表索引
CREATE INDEX idx_checkin_user_id ON check_in_record(user_id);
CREATE INDEX idx_checkin_date ON check_in_record(check_in_date);
CREATE INDEX idx_checkin_user_date ON check_in_record(user_id, check_in_date);

-- 学习目标表索引
CREATE INDEX idx_goal_user_id ON study_goal(user_id);
CREATE INDEX idx_goal_type ON study_goal(type);
CREATE INDEX idx_goal_status ON study_goal(status);
CREATE INDEX idx_goal_user_type ON study_goal(user_id, type);

-- 成就表索引
CREATE INDEX idx_achievement_type ON achievement(type);
CREATE INDEX idx_achievement_rarity ON achievement(rarity);

-- 用户成就表索引
CREATE INDEX idx_user_achievement_user ON user_achievement(user_id);
CREATE INDEX idx_user_achievement_achievement ON user_achievement(achievement_id);

-- 好友关系表索引
CREATE INDEX idx_friendship_user_id ON friendship(user_id);
CREATE INDEX idx_friendship_friend_id ON friendship(friend_id);
CREATE INDEX idx_friendship_status ON friendship(status);

-- 学习小组表索引
CREATE INDEX idx_group_creator_id ON study_group(creator_id);
CREATE INDEX idx_group_status ON study_group(status);

-- 小组成员表索引
CREATE INDEX idx_group_member_group_id ON group_member(group_id);
CREATE INDEX idx_group_member_user_id ON group_member(user_id);

-- 消息表索引
CREATE INDEX idx_message_user_id ON message(user_id);
CREATE INDEX idx_message_type ON message(type);
CREATE INDEX idx_message_is_read ON message(is_read);
CREATE INDEX idx_message_created_at ON message(created_at DESC);

-- 积分商品表索引
CREATE INDEX idx_product_category ON point_product(category);
CREATE INDEX idx_product_status ON point_product(status);
CREATE INDEX idx_product_sort ON point_product(sort_order);

-- 积分兑换表索引
CREATE INDEX idx_exchange_user_id ON point_exchange(user_id);
CREATE INDEX idx_exchange_product_id ON point_exchange(product_id);
CREATE INDEX idx_exchange_status ON point_exchange(status);
CREATE INDEX idx_exchange_created_at ON point_exchange(create_time DESC);

-- 时段表索引
CREATE INDEX idx_time_slot_room_id ON time_slot(room_id);

-- 黑名单表索引
CREATE INDEX idx_blacklist_user_id ON blacklist(user_id);
CREATE INDEX idx_blacklist_end_time ON blacklist(end_time);

-- 申诉表索引（如果存在）
-- CREATE INDEX idx_appeal_user_id ON appeal(user_id);
-- CREATE INDEX idx_appeal_status ON appeal(status);

-- ============================================
-- 查询优化建议
-- ============================================

-- 1. 对于分页查询，使用覆盖索引
-- 2. 避免在索引列上使用函数
-- 3. 使用EXPLAIN分析慢查询
-- 4. 定期执行ANALYZE TABLE更新统计信息

-- 查看表索引状态
-- SHOW INDEX FROM user;
-- SHOW INDEX FROM reservation;

-- 分析表性能
-- ANALYZE TABLE user, reservation, seat, study_room;
