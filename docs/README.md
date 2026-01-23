# 📚 智慧自习室座位预约系统 - 开发手册

## 项目概述

### 项目信息
- **项目名称**：智慧自习室座位预约系统 (Smart Study Room Reservation System)
- **仓库名称**：studyroom-reservation
- **技术栈**：Vue 3 + TypeScript + Spring Boot 3.2 + MySQL 8.0
- **目标用户**：高校学生、自习室管理员、系统管理员
- **数据库表数量**：27张表
- **功能模块数量**：15个模块

### 项目背景
解决高校自习室管理中的痛点：
1. 占座现象严重，座位利用率低
2. 学生找座位耗时，体验差
3. 管理人员无法有效监控使用情况
4. 缺乏数据支持决策
5. 学生学习激励机制不足

### 功能亮点
- 🪑 **可视化选座预约** - 直观的座位图界面，实时显示座位状态
- ✅ **签到签退管理** - 扫码/手动签到签退，暂离功能
- 📊 **信用积分体系** - 约束违约行为，激励守约
- 🏆 **成就系统** - 游戏化设计，激励学习
- 👥 **学习小组** - 组建学习团队，互相激励
- 🎯 **学习目标** - 设定目标，跟踪进度
- 🛒 **积分商城** - 积分兑换奖品
- 📈 **数据统计分析** - 多维度数据看板
- 📱 **消息通知提醒** - 及时推送预约状态

---

## 快速开始

### 环境要求

| 工具 | 版本要求 | 说明 |
|-----|---------|-----|
| JDK | 21+ | 推荐 OpenJDK 21 |
| Node.js | 18+ | 推荐 Node.js 20 LTS |
| MySQL | 8.0+ | 数据库 |
| Maven | 3.9+ | 后端构建 |
| Git | 2.40+ | 版本控制 |

### 方式一：使用脚本一键启动（推荐）

#### macOS/Linux
```bash
# 1. 克隆项目
git clone https://github.com/Garrick777/studyroom-reservation.git
cd studyroom-reservation

# 2. 初始化数据库（首次运行）
./scripts/init_db.sh

# 3. 启动服务
./scripts/start.sh

# 4. 停止服务
./scripts/stop.sh

# 5. 清理项目（可选）
./scripts/clean.sh
```

#### Windows
```batch
:: 1. 克隆项目
git clone https://github.com/Garrick777/studyroom-reservation.git
cd studyroom-reservation

:: 2. 初始化数据库（首次运行）
scripts\init_db.bat

:: 3. 启动服务
scripts\start.bat

:: 4. 停止服务
scripts\stop.bat

:: 5. 清理项目（可选）
scripts\clean.bat
```

### 方式二：手动启动

#### 1. 数据库初始化
```bash
# 创建数据库并导入数据
mysql -u root -p < sql/studyroom_full.sql
```

#### 2. 启动后端
```bash
cd backend
# 修改 application.yml 中的数据库配置（如需要）
mvn spring-boot:run -DskipTests
```

#### 3. 启动前端
```bash
cd frontend
npm install
npm run dev
```

### 访问地址

| 服务 | 地址 |
|-----|-----|
| 前端 | http://localhost:3000 |
| 后端API | http://localhost:9090/api |
| API文档 | http://localhost:9090/doc.html |

### 测试账号

| 角色 | 用户名 | 密码 | 说明 |
|-----|-------|-----|-----|
| 超级管理员 | superadmin | 123456 | 系统最高权限 |
| 自习室管理员 | admin1 | 123456 | 管理自习室 |
| 学生 | zhangsan | 123456 | 普通学生 |
| 学生 | lisi | 123456 | 普通学生 |

---

## 项目结构

```
studyroom-reservation/
├── backend/                          # 后端项目
│   ├── src/main/java/com/studyroom/
│   │   ├── StudyRoomApplication.java # 启动类
│   │   ├── config/                   # 配置类
│   │   │   ├── SecurityConfig.java
│   │   │   ├── CorsConfig.java
│   │   │   └── SwaggerConfig.java
│   │   ├── controller/               # 控制器
│   │   │   ├── AuthController.java
│   │   │   ├── RoomController.java
│   │   │   ├── ReservationController.java
│   │   │   ├── UserController.java
│   │   │   ├── CheckInController.java
│   │   │   ├── GoalController.java
│   │   │   ├── AchievementController.java
│   │   │   ├── GroupController.java
│   │   │   ├── FriendController.java
│   │   │   ├── ShopController.java
│   │   │   └── SuperAdminController.java
│   │   ├── service/                  # 服务层
│   │   ├── mapper/                   # MyBatis Mapper
│   │   ├── entity/                   # 实体类
│   │   ├── common/                   # 公共组件
│   │   ├── exception/                # 异常处理
│   │   ├── security/                 # 安全相关
│   │   └── util/                     # 工具类
│   ├── src/main/resources/
│   │   └── application.yml           # 配置文件
│   └── pom.xml
│
├── frontend/                         # 前端项目
│   ├── src/
│   │   ├── main.ts                   # 入口文件
│   │   ├── App.vue                   # 根组件
│   │   ├── api/                      # API接口
│   │   ├── views/                    # 页面
│   │   │   ├── auth/                 # 登录注册
│   │   │   ├── student/              # 学生端页面
│   │   │   ├── admin/                # 管理员页面
│   │   │   └── super-admin/          # 超管页面
│   │   ├── components/               # 组件
│   │   │   └── layout/               # 布局组件
│   │   ├── stores/                   # Pinia状态
│   │   ├── router/                   # 路由
│   │   ├── utils/                    # 工具
│   │   └── styles/                   # 样式
│   ├── public/
│   │   └── images/                   # 静态图片
│   ├── vite.config.ts
│   └── package.json
│
├── sql/                              # SQL脚本
│   └── studyroom_full.sql            # 完整数据库脚本
│
├── scripts/                          # 启动脚本
│   ├── start.sh / start.bat          # 启动服务
│   ├── stop.sh / stop.bat            # 停止服务
│   ├── init_db.sh / init_db.bat      # 初始化数据库
│   └── clean.sh / clean.bat          # 清理项目
│
└── docs/                             # 文档
    ├── README.md                     # 开发手册(本文档)
    ├── database.md                   # 数据库设计
    ├── api.md                        # API文档
    └── todo.md                       # 任务清单
```

---

## 功能模块

### 模块清单

| 序号 | 模块名称 | 核心功能 | 相关表 |
|-----|---------|---------|-------|
| 1 | 认证模块 | 登录、注册、JWT | user |
| 2 | 自习室管理 | 自习室CRUD、座位管理 | study_room, seat |
| 3 | 预约管理 | 预约、签到、签退、暂离 | reservation, time_slot |
| 4 | 信用积分 | 积分变动、违约处理 | credit_record, violation_record |
| 5 | 黑名单管理 | 黑名单加入/解除 | blacklist |
| 6 | 公告管理 | 公告发布、查看 | notice |
| 7 | 消息通知 | 站内消息、提醒 | message |
| 8 | 收藏功能 | 收藏自习室/座位 | favorite |
| 9 | 每日打卡 | 打卡签到、连续打卡 | check_in_record |
| 10 | 学习目标 | 目标设定、进度跟踪 | study_goal |
| 11 | 成就系统 | 成就解锁、奖励领取 | achievement, user_achievement |
| 12 | 座位评价 | 评价、评分 | seat_review |
| 13 | 好友系统 | 好友添加、动态 | friendship |
| 14 | 学习小组 | 小组创建、成员管理 | study_group, group_member |
| 15 | 积分商城 | 商品管理、积分兑换 | point_product, point_exchange |

### 用户角色

| 角色 | 代码 | 权限说明 |
|-----|-----|---------|
| 学生 | STUDENT | 预约、签到、打卡、加入小组等 |
| 自习室管理员 | ADMIN | 管理指定自习室、处理违约 |
| 超级管理员 | SUPER_ADMIN | 系统配置、用户管理、数据统计 |

---

## 端口配置

| 服务 | 端口 | 说明 |
|-----|-----|-----|
| 前端 | 3000 | Vite开发服务器 |
| 后端 | 9090 | Spring Boot |
| MySQL | 3306 | 数据库 |

---

## 数据库设计

详见 [database.md](./database.md)

### 数据库表清单（27张表）

| 分类 | 表名 | 说明 |
|-----|-----|-----|
| **用户相关** | user | 用户表 |
| | blacklist | 黑名单表 |
| | friendship | 好友关系表 |
| **自习室相关** | study_room | 自习室表 |
| | seat | 座位表 |
| | time_slot | 时段表 |
| | favorite | 收藏表 |
| | seat_review | 座位评价表 |
| **预约相关** | reservation | 预约表 |
| **信用积分** | credit_record | 积分记录表 |
| | violation_record | 违约记录表 |
| **打卡目标** | check_in_record | 签到打卡表 |
| | study_goal | 学习目标表 |
| **成就系统** | achievement | 成就定义表 |
| | user_achievement | 用户成就表 |
| **社交相关** | study_group | 学习小组表 |
| | group_member | 小组成员表 |
| **消息公告** | message | 消息表 |
| | notice | 公告表 |
| **积分商城** | point_product | 商品表 |
| | point_exchange | 兑换记录表 |

---

## API接口

详见 [api.md](./api.md)

### 接口规范

**基础URL**：`/api`

**响应格式**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {}
}
```

### 核心接口

#### 认证模块 `/api/auth`
```
POST   /login              用户登录
POST   /register           用户注册
GET    /info               获取当前用户信息
PUT    /password           修改密码
```

#### 自习室模块 `/api/rooms`
```
GET    /                   获取自习室列表
GET    /{id}               获取自习室详情
GET    /{id}/seats         获取座位列表
```

#### 预约模块 `/api/reservations`
```
POST   /                   创建预约
GET    /                   获取我的预约列表
PUT    /{id}/sign-in       签到
PUT    /{id}/sign-out      签退
PUT    /{id}/leave         暂离
PUT    /{id}/return        暂离返回
PUT    /{id}/cancel        取消预约
```

#### 超级管理员 `/api/super-admin`
```
GET    /stats              获取统计数据
GET    /chart-data         获取图表数据
GET    /users              用户管理
GET    /admins             管理员管理
DELETE /shop/products/{id} 删除商品
```

---

## 业务规则

### 预约规则

| 规则项 | 默认值 | 说明 |
|-------|-------|-----|
| 最大提前预约天数 | 7天 | 最多提前7天预约 |
| 每日最大预约次数 | 2次 | 同一天最多预约2个时段 |
| 最低信用分要求 | 60分 | 低于60分禁止预约 |
| 签到提前时间 | 15分钟 | 开始前15分钟可签到 |
| 签到超时时间 | 30分钟 | 超过30分钟未签到自动违约 |
| 免费取消时间 | 1小时 | 开始前1小时可免费取消 |
| 暂离最大时长 | 30分钟 | 暂离超过30分钟自动签退 |

### 信用积分规则

| 行为 | 积分变动 | 说明 |
|-----|---------|-----|
| 按时签退完成 | +2 | 奖励守约行为 |
| 未签到违约 | -10 | 浪费座位资源 |
| 迟取消(1小时内) | -5 | 影响他人预约 |
| 暂离超时 | -8 | 占用座位不使用 |
| 每月自动恢复 | +5 | 最高恢复至100分 |

---

## 常见问题

### Q1: JAVA_HOME 未设置
脚本会自动检测并设置 JAVA_HOME。如果仍有问题，手动设置：

**macOS:**
```bash
export JAVA_HOME=$(/usr/libexec/java_home)
```

**Windows:**
```batch
set JAVA_HOME=C:\Program Files\Java\jdk-21
```

### Q2: 数据库连接失败
检查 `backend/src/main/resources/application.yml` 中的配置：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/studyroom?useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: 123456789
```

### Q3: 端口被占用
使用停止脚本释放端口：
```bash
./scripts/stop.sh    # macOS/Linux
scripts\stop.bat     # Windows
```

### Q4: 前端跨域问题
开发环境已配置 Vite 代理，生产环境需配置 Nginx：
```nginx
location /api {
    proxy_pass http://localhost:9090;
}
```

---

## Git 提交规范

```
feat: 新功能
fix: Bug修复
docs: 文档更新
style: 代码格式
refactor: 代码重构
test: 测试相关
chore: 构建/工具
```

---

## 更新日志

### v2.1.0 (当前版本) - 2026-01-23
- 添加 Windows 系统启动脚本
- 修复商城商品删除功能
- 修复路由跳转问题
- 修复好友管理功能
- 优化 JAVA_HOME 自动检测

### v2.0.0 - 2026-01-21
- 完整27张数据库表
- 15个功能模块
- 添加成就系统、学习小组、积分商城等特色功能

### v1.0.0 - 初始版本
- 基础预约功能
- 信用积分体系

---

**作者**：Gavin  
**更新日期**：2026-01-23
