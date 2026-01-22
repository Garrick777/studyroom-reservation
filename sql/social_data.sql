-- =============================================
-- 第八阶段：社交功能测试数据
-- =============================================

SET NAMES utf8mb4;

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
