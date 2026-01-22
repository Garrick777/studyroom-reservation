-- =====================================================
-- 为每个自习室生成使用中的座位预约数据
-- 每个用户只能在一个自习室使用座位
-- =====================================================

-- 清理今天的预约数据
DELETE FROM reservation WHERE date = CURDATE();

-- 设置时间范围
SET @start_time = DATE_SUB(NOW(), INTERVAL 1 HOUR);
SET @end_time = DATE_ADD(NOW(), INTERVAL 6 HOUR);

-- ========================================
-- 自习室2: 图书馆二楼电子阅览室 (58座位)
-- 使用用户 1-50
-- ========================================
SET @room_id = 2;
SET @user_start = 1;

INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT 
    CONCAT('R2-', s.id),
    @user_start + (ROW_NUMBER() OVER (ORDER BY s.id)) - 1,
    @room_id,
    s.id,
    CURDATE(),
    1,
    @start_time,
    @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 45 THEN 'CHECKED_IN' ELSE 'LEAVING' END,
    NOW()
FROM seat s
WHERE s.room_id = @room_id AND s.status = 1
LIMIT 50;

-- ========================================
-- 自习室3: 图书馆三楼静音自习室A (47座位)
-- 使用用户 51-92
-- ========================================
SET @room_id = 3;
SET @user_start = 51;

INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT 
    CONCAT('R3-', s.id),
    @user_start + (ROW_NUMBER() OVER (ORDER BY s.id)) - 1,
    @room_id,
    s.id,
    CURDATE(),
    1,
    @start_time,
    @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 38 THEN 'CHECKED_IN' ELSE 'LEAVING' END,
    NOW()
FROM seat s
WHERE s.room_id = @room_id AND s.status = 1
LIMIT 42;

-- ========================================
-- 自习室4: 图书馆三楼静音自习室B (49座位)
-- 使用用户 93-136
-- ========================================
SET @room_id = 4;
SET @user_start = 93;

INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT 
    CONCAT('R4-', s.id),
    @user_start + (ROW_NUMBER() OVER (ORDER BY s.id)) - 1,
    @room_id,
    s.id,
    CURDATE(),
    1,
    @start_time,
    @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 40 THEN 'CHECKED_IN' ELSE 'LEAVING' END,
    NOW()
FROM seat s
WHERE s.room_id = @room_id AND s.status = 1
LIMIT 44;

-- ========================================
-- 自习室5: 图书馆四楼自习室 (95座位)
-- 使用用户 137-219
-- ========================================
SET @room_id = 5;
SET @user_start = 137;

INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT 
    CONCAT('R5-', s.id),
    @user_start + (ROW_NUMBER() OVER (ORDER BY s.id)) - 1,
    @room_id,
    s.id,
    CURDATE(),
    1,
    @start_time,
    @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 75 THEN 'CHECKED_IN' ELSE 'LEAVING' END,
    NOW()
FROM seat s
WHERE s.room_id = @room_id AND s.status = 1
LIMIT 83;

-- ========================================
-- 自习室6-18 继续分配
-- ========================================

-- 自习室6: 图书馆五楼考研自习室 (77座位) 用户220-280
SET @room_id = 6;
SET @user_start = 220;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R6-', s.id), @user_start + (ROW_NUMBER() OVER (ORDER BY s.id)) - 1, @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 55 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 61;

-- 自习室7-18 使用相同的模式，但用户ID会重复使用（因为用户数量有限）

-- 自习室7: 教学楼A-101自习室 (58座位)
SET @room_id = 7;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R7-', s.id), 281 + (ROW_NUMBER() OVER (ORDER BY s.id)) - 1, @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 45 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 20;

-- 自习室8-18 使用有限的用户，每个自习室分配15-25个座位
SET @room_id = 8;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R8-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 32 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 38;

SET @room_id = 9;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R9-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 42 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 48;

SET @room_id = 10;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R10-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 38 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 44;

SET @room_id = 11;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R11-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 28 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 32;

SET @room_id = 12;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R12-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 36 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 42;

SET @room_id = 13;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R13-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 38 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 44;

SET @room_id = 14;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R14-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 52 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 58;

SET @room_id = 15;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R15-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 48 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 54;

SET @room_id = 16;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R16-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 30 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 35;

SET @room_id = 17;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R17-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 18 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 22;

SET @room_id = 18;
INSERT INTO reservation (reservation_no, user_id, room_id, seat_id, date, time_slot_id, start_time, end_time, status, sign_in_time)
SELECT CONCAT('R18-', s.id), 1 + (s.id % 300), @room_id, s.id, CURDATE(), 1, @start_time, @end_time,
    CASE WHEN (ROW_NUMBER() OVER (ORDER BY s.id)) <= 25 THEN 'CHECKED_IN' ELSE 'LEAVING' END, NOW()
FROM seat s WHERE s.room_id = @room_id AND s.status = 1 LIMIT 28;

-- 查看结果统计
SELECT 
    sr.id as room_id,
    sr.name as room_name,
    (SELECT COUNT(*) FROM seat WHERE room_id = sr.id AND status = 1) as total_seats,
    COUNT(DISTINCT r.id) as reserved_seats,
    SUM(CASE WHEN r.status = 'CHECKED_IN' THEN 1 ELSE 0 END) as in_use,
    SUM(CASE WHEN r.status = 'LEAVING' THEN 1 ELSE 0 END) as leaving
FROM study_room sr
LEFT JOIN reservation r ON sr.id = r.room_id AND r.date = CURDATE()
WHERE sr.status = 1
GROUP BY sr.id, sr.name
ORDER BY sr.id;
