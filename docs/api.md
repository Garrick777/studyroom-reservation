# 📡 API接口文档

## 接口规范

### 基础信息

| 项目 | 值 |
|-----|---|
| 基础URL | `/api` |
| 协议 | HTTP/HTTPS |
| 数据格式 | JSON |
| 字符编码 | UTF-8 |
| 认证方式 | JWT Bearer Token |

### 请求头

```
Content-Type: application/json
Authorization: Bearer <token>
```

### 响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1705800000000
}
```

### 分页响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "list": [],
    "total": 100,
    "page": 1,
    "size": 10,
    "pages": 10
  }
}
```

### 状态码

| 状态码 | 说明 |
|-------|-----|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未登录/Token过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 500 | 服务器错误 |

### 业务错误码

| 错误码 | 说明 |
|-------|-----|
| 10001 | 用户名或密码错误 |
| 10002 | 用户已存在 |
| 10003 | 用户不存在 |
| 10004 | 信用分不足 |
| 10005 | 已在黑名单 |
| 20001 | 自习室不存在 |
| 20002 | 自习室已关闭 |
| 20003 | 座位不可用 |
| 30001 | 预约冲突 |
| 30002 | 预约不存在 |
| 30003 | 预约状态错误 |
| 30004 | 签到时间未到 |
| 30005 | 签到已超时 |
| 40001 | 积分不足 |
| 40002 | 商品已售罄 |

---

## 一、认证模块 `/api/auth`

### 1.1 用户登录

**POST** `/api/auth/login`

**请求参数**：
```json
{
  "studentNo": "2021001001",
  "password": "123456"
}
```

**响应数据**：
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "tokenType": "Bearer",
    "expiresIn": 86400,
    "user": {
      "id": 1,
      "studentNo": "2021001001",
      "username": "张三",
      "avatar": "/avatars/1.jpg",
      "role": "STUDENT",
      "creditScore": 100,
      "points": 500,
      "level": 3,
      "exp": 450
    }
  }
}
```

### 1.2 用户注册

**POST** `/api/auth/register`

**请求参数**：
```json
{
  "studentNo": "2021001001",
  "username": "张三",
  "password": "123456",
  "confirmPassword": "123456",
  "phone": "13800138000",
  "email": "zhangsan@example.com",
  "college": "计算机学院",
  "major": "软件工程",
  "grade": "2021级",
  "className": "软工1班"
}
```

**响应数据**：
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "id": 1,
    "studentNo": "2021001001",
    "username": "张三"
  }
}
```

### 1.3 获取当前用户信息

**GET** `/api/auth/info`

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "studentNo": "2021001001",
    "username": "张三",
    "phone": "13800138000",
    "email": "zhangsan@example.com",
    "avatar": "/avatars/1.jpg",
    "gender": 1,
    "college": "计算机学院",
    "major": "软件工程",
    "grade": "2021级",
    "className": "软工1班",
    "creditScore": 100,
    "totalHours": 56.5,
    "totalReservations": 45,
    "totalCheckIns": 30,
    "continuousCheckIns": 7,
    "points": 500,
    "level": 3,
    "exp": 450,
    "bio": "努力学习中...",
    "role": "STUDENT",
    "status": 1,
    "lastLoginTime": "2026-01-21 10:30:00"
  }
}
```

### 1.4 修改密码

**PUT** `/api/auth/password`

**请求参数**：
```json
{
  "oldPassword": "123456",
  "newPassword": "654321",
  "confirmPassword": "654321"
}
```

### 1.5 退出登录

**POST** `/api/auth/logout`

---

## 二、自习室模块 `/api/rooms`

### 2.1 获取自习室列表

**GET** `/api/rooms`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| page | int | 否 | 页码，默认1 |
| size | int | 否 | 每页数量，默认10 |
| keyword | string | 否 | 关键词搜索 |
| building | string | 否 | 建筑筛选 |
| status | int | 否 | 状态：1开放 |
| orderBy | string | 否 | 排序：rating/distance |

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "id": 1,
        "name": "图书馆A101自习室",
        "code": "LIB-A101",
        "building": "图书馆A座",
        "floor": "1楼",
        "roomNumber": "101",
        "capacity": 60,
        "availableSeats": 25,
        "description": "安静舒适的自习环境",
        "facilities": ["空调", "WiFi", "电源", "台灯"],
        "coverImage": "/images/rooms/1.jpg",
        "openTime": "08:00",
        "closeTime": "22:00",
        "rating": 4.5,
        "ratingCount": 120,
        "todayReservations": 35,
        "status": 1,
        "isFavorite": true
      }
    ],
    "total": 50,
    "page": 1,
    "size": 10
  }
}
```

### 2.2 获取自习室详情

**GET** `/api/rooms/{id}`

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "name": "图书馆A101自习室",
    "code": "LIB-A101",
    "building": "图书馆A座",
    "floor": "1楼",
    "roomNumber": "101",
    "capacity": 60,
    "rowCount": 6,
    "colCount": 10,
    "description": "安静舒适的自习环境，配备空调和WiFi",
    "facilities": ["空调", "WiFi", "电源", "台灯"],
    "coverImage": "/images/rooms/1.jpg",
    "images": ["/images/rooms/1-1.jpg", "/images/rooms/1-2.jpg"],
    "openTime": "08:00",
    "closeTime": "22:00",
    "advanceDays": 7,
    "maxDuration": 4,
    "minCreditScore": 60,
    "needApprove": false,
    "rating": 4.5,
    "ratingCount": 120,
    "status": 1,
    "isFavorite": false,
    "manager": {
      "id": 10,
      "username": "管理员A"
    }
  }
}
```

### 2.3 获取座位列表(含状态)

**GET** `/api/rooms/{id}/seats`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| date | string | 是 | 日期，格式：2026-01-21 |
| timeSlotId | long | 是 | 时段ID |

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "roomId": 1,
    "rowCount": 6,
    "colCount": 10,
    "seats": [
      {
        "id": 1,
        "seatNo": "A01",
        "rowNum": 1,
        "colNum": 1,
        "seatType": "POWER",
        "hasPower": true,
        "hasLamp": true,
        "hasComputer": false,
        "rating": 4.8,
        "status": 1,
        "reservationStatus": "AVAILABLE"
      },
      {
        "id": 2,
        "seatNo": "A02",
        "rowNum": 1,
        "colNum": 2,
        "seatType": "NORMAL",
        "hasPower": false,
        "hasLamp": false,
        "hasComputer": false,
        "rating": 4.5,
        "status": 1,
        "reservationStatus": "OCCUPIED",
        "reservedBy": "张*"
      }
    ]
  }
}
```

**reservationStatus说明**：
| 状态 | 说明 |
|-----|-----|
| AVAILABLE | 可预约 |
| OCCUPIED | 已被预约 |
| USING | 使用中 |
| LEAVING | 暂离中 |
| DISABLED | 不可用 |
| SELF | 自己预约 |

### 2.4 获取可用时段

**GET** `/api/rooms/{id}/available`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| date | string | 是 | 日期 |

**响应数据**：
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "早间",
      "startTime": "08:00",
      "endTime": "10:00",
      "availableSeats": 30,
      "totalSeats": 60,
      "isAvailable": true
    },
    {
      "id": 2,
      "name": "上午",
      "startTime": "10:00",
      "endTime": "12:00",
      "availableSeats": 0,
      "totalSeats": 60,
      "isAvailable": false
    }
  ]
}
```

### 2.5 收藏自习室

**POST** `/api/rooms/{id}/favorite`

### 2.6 取消收藏

**DELETE** `/api/rooms/{id}/favorite`

### 2.7 获取收藏列表

**GET** `/api/user/favorites`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| type | string | 否 | 类型：ROOM/SEAT，默认全部 |

---

## 三、预约模块 `/api/reservations`

### 3.1 创建预约

**POST** `/api/reservations`

**请求参数**：
```json
{
  "roomId": 1,
  "seatId": 15,
  "date": "2026-01-22",
  "timeSlotId": 3,
  "remark": "备注信息"
}
```

**响应数据**：
```json
{
  "code": 200,
  "message": "预约成功",
  "data": {
    "id": 100,
    "reservationNo": "RSV20260121100001",
    "roomName": "图书馆A101自习室",
    "seatNo": "B05",
    "date": "2026-01-22",
    "timeSlotName": "中午",
    "startTime": "2026-01-22 12:00:00",
    "endTime": "2026-01-22 14:00:00",
    "status": "PENDING"
  }
}
```

### 3.2 获取我的预约列表

**GET** `/api/reservations`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| page | int | 否 | 页码 |
| size | int | 否 | 每页数量 |
| status | string | 否 | 状态筛选：PENDING/COMPLETED等 |
| type | string | 否 | 类型：current当前/history历史 |

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "id": 100,
        "reservationNo": "RSV20260121100001",
        "room": {
          "id": 1,
          "name": "图书馆A101自习室",
          "building": "图书馆A座"
        },
        "seat": {
          "id": 15,
          "seatNo": "B05",
          "seatType": "POWER"
        },
        "date": "2026-01-22",
        "timeSlot": {
          "id": 3,
          "name": "中午",
          "startTime": "12:00",
          "endTime": "14:00"
        },
        "startTime": "2026-01-22 12:00:00",
        "endTime": "2026-01-22 14:00:00",
        "status": "PENDING",
        "signInTime": null,
        "signOutTime": null,
        "leaveCount": 0,
        "earnedPoints": 0,
        "earnedExp": 0,
        "canSignIn": true,
        "canSignOut": false,
        "canLeave": false,
        "canCancel": true,
        "createdAt": "2026-01-21 10:30:00"
      }
    ],
    "total": 45,
    "page": 1,
    "size": 10
  }
}
```

### 3.3 获取预约详情

**GET** `/api/reservations/{id}`

### 3.4 签到

**PUT** `/api/reservations/{id}/sign-in`

**响应数据**：
```json
{
  "code": 200,
  "message": "签到成功",
  "data": {
    "id": 100,
    "status": "SIGNED_IN",
    "signInTime": "2026-01-22 11:50:00"
  }
}
```

### 3.5 签退

**PUT** `/api/reservations/{id}/sign-out`

**响应数据**：
```json
{
  "code": 200,
  "message": "签退成功",
  "data": {
    "id": 100,
    "status": "COMPLETED",
    "signOutTime": "2026-01-22 13:55:00",
    "actualDuration": 125,
    "earnedPoints": 20,
    "earnedExp": 40,
    "creditChange": 2
  }
}
```

### 3.6 暂离

**PUT** `/api/reservations/{id}/leave`

**响应数据**：
```json
{
  "code": 200,
  "message": "暂离成功，请在30分钟内返回",
  "data": {
    "id": 100,
    "status": "LEAVING",
    "leaveTime": "2026-01-22 13:00:00",
    "leaveCount": 1,
    "returnDeadline": "2026-01-22 13:30:00"
  }
}
```

### 3.7 暂离返回

**PUT** `/api/reservations/{id}/return`

### 3.8 取消预约

**PUT** `/api/reservations/{id}/cancel`

**请求参数**：
```json
{
  "reason": "临时有事"
}
```

**响应数据**：
```json
{
  "code": 200,
  "message": "取消成功",
  "data": {
    "id": 100,
    "status": "CANCELLED",
    "cancelTime": "2026-01-22 10:00:00",
    "creditChange": 0
  }
}
```

### 3.9 评价座位

**POST** `/api/reservations/{id}/review`

**请求参数**：
```json
{
  "rating": 5,
  "content": "座位很舒适，光线好",
  "tags": ["安静", "采光好", "电源充足"],
  "isAnonymous": false
}
```

---

## 四、每日打卡 `/api/checkin`

### 4.1 每日打卡

**POST** `/api/checkin`

**响应数据**：
```json
{
  "code": 200,
  "message": "打卡成功",
  "data": {
    "id": 50,
    "checkInDate": "2026-01-21",
    "checkInTime": "2026-01-21 08:30:00",
    "continuousDays": 8,
    "earnedPoints": 7,
    "earnedExp": 15,
    "todayBonus": "连续7天+额外奖励"
  }
}
```

### 4.2 今日打卡状态

**GET** `/api/checkin/today`

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "hasCheckedIn": true,
    "checkInTime": "2026-01-21 08:30:00",
    "continuousDays": 8,
    "todayPoints": 7
  }
}
```

### 4.3 打卡日历

**GET** `/api/checkin/calendar`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| year | int | 否 | 年份 |
| month | int | 否 | 月份 |

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "year": 2026,
    "month": 1,
    "totalDays": 21,
    "checkedDays": 18,
    "records": [
      {"date": "2026-01-01", "checked": true},
      {"date": "2026-01-02", "checked": true},
      {"date": "2026-01-03", "checked": false}
    ]
  }
}
```

### 4.4 打卡统计

**GET** `/api/checkin/stats`

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "totalCheckIns": 150,
    "continuousDays": 8,
    "maxContinuousDays": 30,
    "totalPoints": 800,
    "totalExp": 1600,
    "thisMonthCheckIns": 18,
    "thisWeekCheckIns": 5
  }
}
```

---

## 五、学习目标 `/api/goals`

### 5.1 创建目标

**POST** `/api/goals`

**请求参数**：
```json
{
  "title": "本周学习20小时",
  "description": "每天至少学习3小时",
  "goalType": "WEEKLY",
  "targetHours": 20,
  "startDate": "2026-01-20",
  "endDate": "2026-01-26"
}
```

### 5.2 获取目标列表

**GET** `/api/goals`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| status | int | 否 | 状态：1进行中 2已完成 |

**响应数据**：
```json
{
  "code": 200,
  "data": [
    {
      "id": 10,
      "title": "本周学习20小时",
      "description": "每天至少学习3小时",
      "goalType": "WEEKLY",
      "targetHours": 20,
      "completedHours": 12.5,
      "progress": 62.5,
      "startDate": "2026-01-20",
      "endDate": "2026-01-26",
      "remainingDays": 5,
      "status": 1,
      "earnedPoints": 0
    }
  ]
}
```

### 5.3 获取目标详情

**GET** `/api/goals/{id}`

### 5.4 更新目标

**PUT** `/api/goals/{id}`

### 5.5 删除目标

**DELETE** `/api/goals/{id}`

---

## 六、成就系统 `/api/achievements`

### 6.1 获取所有成就

**GET** `/api/achievements`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| category | string | 否 | 分类：STUDY/CHECK_IN/SOCIAL/SPECIAL |

**响应数据**：
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "初出茅庐",
      "description": "完成第一次自习",
      "icon": "🎓",
      "badgeColor": "#4CAF50",
      "category": "STUDY",
      "conditionType": "TOTAL_RESERVATIONS",
      "conditionValue": 1,
      "rewardPoints": 10,
      "rewardExp": 20,
      "rarity": "COMMON",
      "isHidden": false,
      "myProgress": 1,
      "isCompleted": true,
      "completedAt": "2026-01-15 14:00:00",
      "isClaimed": false
    }
  ]
}
```

### 6.2 获取我的成就

**GET** `/api/achievements/my`

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "completedCount": 8,
    "totalCount": 25,
    "unclaimedCount": 2,
    "achievements": [
      {
        "id": 1,
        "achievement": {...},
        "progress": 1,
        "isCompleted": true,
        "completedAt": "2026-01-15",
        "isClaimed": false
      }
    ]
  }
}
```

### 6.3 领取成就奖励

**POST** `/api/achievements/{id}/claim`

**响应数据**：
```json
{
  "code": 200,
  "message": "奖励领取成功",
  "data": {
    "achievementName": "初出茅庐",
    "rewardPoints": 10,
    "rewardExp": 20,
    "currentPoints": 510,
    "currentExp": 470
  }
}
```

---

## 七、好友系统 `/api/friends`

### 7.1 发送好友请求

**POST** `/api/friends/request`

**请求参数**：
```json
{
  "targetUserId": 5,
  "message": "我们一起学习吧"
}
```

### 7.2 获取好友请求列表

**GET** `/api/friends/requests`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| type | string | 否 | received收到的/sent发出的 |

### 7.3 处理好友请求

**PUT** `/api/friends/requests/{id}`

**请求参数**：
```json
{
  "action": "accept"
}
```
action可选值：accept/reject

### 7.4 获取好友列表

**GET** `/api/friends`

**响应数据**：
```json
{
  "code": 200,
  "data": [
    {
      "id": 5,
      "userId": 5,
      "username": "李四",
      "avatar": "/avatars/5.jpg",
      "college": "计算机学院",
      "level": 4,
      "remark": "室友",
      "isOnline": true,
      "lastActiveTime": "2026-01-21 10:30:00",
      "createdAt": "2026-01-10"
    }
  ]
}
```

### 7.5 删除好友

**DELETE** `/api/friends/{id}`

### 7.6 搜索用户

**GET** `/api/users/search`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| keyword | string | 是 | 学号或姓名 |

---

## 八、学习小组 `/api/groups`

### 8.1 创建小组

**POST** `/api/groups`

**请求参数**：
```json
{
  "name": "考研冲刺小组",
  "description": "2026考研，一起加油！",
  "avatar": "/images/groups/default.jpg",
  "maxMembers": 30,
  "isPublic": true,
  "needApprove": true,
  "tags": ["考研", "每日打卡"]
}
```

### 8.2 获取小组列表

**GET** `/api/groups`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| page | int | 否 | 页码 |
| size | int | 否 | 每页数量 |
| keyword | string | 否 | 搜索关键词 |
| tag | string | 否 | 标签筛选 |

### 8.3 获取我的小组

**GET** `/api/groups/my`

### 8.4 获取小组详情

**GET** `/api/groups/{id}`

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "name": "考研冲刺小组",
    "description": "2026考研，一起加油！",
    "avatar": "/images/groups/1.jpg",
    "coverImage": "/images/groups/1-cover.jpg",
    "creator": {
      "id": 1,
      "username": "张三",
      "avatar": "/avatars/1.jpg"
    },
    "maxMembers": 30,
    "memberCount": 15,
    "totalHours": 450.5,
    "weeklyHours": 85.5,
    "isPublic": true,
    "needApprove": true,
    "tags": ["考研", "每日打卡"],
    "status": 1,
    "isMember": true,
    "myRole": "MEMBER",
    "members": [
      {
        "id": 1,
        "userId": 1,
        "username": "张三",
        "avatar": "/avatars/1.jpg",
        "role": "CREATOR",
        "contributionHours": 56.5,
        "joinTime": "2026-01-01"
      }
    ],
    "createdAt": "2026-01-01"
  }
}
```

### 8.5 申请加入小组

**POST** `/api/groups/{id}/join`

**请求参数**：
```json
{
  "message": "请求加入小组"
}
```

### 8.6 审批加入申请

**PUT** `/api/groups/{id}/approve`

**请求参数**：
```json
{
  "memberId": 10,
  "action": "accept"
}
```

### 8.7 退出小组

**DELETE** `/api/groups/{id}/leave`

### 8.8 解散小组

**DELETE** `/api/groups/{id}`

---

## 九、积分商城 `/api/shop`

### 9.1 获取商品列表

**GET** `/api/shop/products`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| page | int | 否 | 页码 |
| size | int | 否 | 每页数量 |
| category | string | 否 | 分类 |
| orderBy | string | 否 | 排序：points/hot |

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "id": 1,
        "name": "精美书签套装",
        "description": "5枚装精美金属书签",
        "image": "/images/products/bookmark.jpg",
        "category": "STATIONERY",
        "pointsRequired": 100,
        "stock": 50,
        "limitPerUser": 2,
        "exchangeCount": 35,
        "status": 1
      }
    ],
    "total": 12,
    "page": 1,
    "size": 10
  }
}
```

### 9.2 获取商品详情

**GET** `/api/shop/products/{id}`

### 9.3 积分兑换

**POST** `/api/shop/exchange`

**请求参数**：
```json
{
  "productId": 1,
  "quantity": 1
}
```

**响应数据**：
```json
{
  "code": 200,
  "message": "兑换成功",
  "data": {
    "exchangeId": 100,
    "productName": "精美书签套装",
    "pointsUsed": 100,
    "remainingPoints": 400,
    "status": "PENDING"
  }
}
```

### 9.4 获取兑换记录

**GET** `/api/shop/exchanges`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| page | int | 否 | 页码 |
| size | int | 否 | 每页数量 |
| status | int | 否 | 状态 |

---

## 十、排行榜 `/api/ranking`

### 10.1 学习时长榜

**GET** `/api/ranking/hours`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| type | string | 否 | daily/weekly/monthly/all |
| limit | int | 否 | 数量，默认10 |

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "type": "weekly",
    "updateTime": "2026-01-21 00:00:00",
    "myRank": 15,
    "myValue": 18.5,
    "list": [
      {
        "rank": 1,
        "userId": 5,
        "username": "李四",
        "avatar": "/avatars/5.jpg",
        "college": "计算机学院",
        "level": 5,
        "value": 42.5,
        "change": 2
      }
    ]
  }
}
```

### 10.2 打卡天数榜

**GET** `/api/ranking/checkin`

### 10.3 积分排行榜

**GET** `/api/ranking/points`

### 10.4 小组排行榜

**GET** `/api/ranking/groups`

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "type": "weekly",
    "list": [
      {
        "rank": 1,
        "groupId": 1,
        "name": "考研冲刺小组",
        "avatar": "/images/groups/1.jpg",
        "memberCount": 15,
        "totalHours": 450.5,
        "weeklyHours": 85.5
      }
    ]
  }
}
```

---

## 十一、消息中心 `/api/messages`

### 11.1 获取消息列表

**GET** `/api/messages`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| page | int | 否 | 页码 |
| size | int | 否 | 每页数量 |
| type | string | 否 | 类型筛选 |
| isRead | int | 否 | 0未读 1已读 |

### 11.2 获取未读数量

**GET** `/api/messages/unread-count`

**响应数据**：
```json
{
  "code": 200,
  "data": {
    "total": 5,
    "system": 1,
    "reservation": 2,
    "achievement": 2
  }
}
```

### 11.3 标记已读

**PUT** `/api/messages/{id}/read`

### 11.4 全部标记已读

**PUT** `/api/messages/read-all`

---

## 十二、公告 `/api/notices`

### 12.1 获取公告列表

**GET** `/api/notices`

**查询参数**：
| 参数 | 类型 | 必填 | 说明 |
|-----|-----|-----|-----|
| page | int | 否 | 页码 |
| size | int | 否 | 每页数量 |
| type | string | 否 | 类型 |

### 12.2 获取公告详情

**GET** `/api/notices/{id}`

---

## 十三、反馈建议 `/api/feedback`

### 13.1 提交反馈

**POST** `/api/feedback`

**请求参数**：
```json
{
  "type": "SUGGESTION",
  "title": "建议增加夜间模式",
  "content": "希望能增加夜间模式，晚上使用更舒适",
  "images": ["/images/feedback/1.jpg"],
  "contact": "13800138000",
  "relatedRoomId": 1
}
```

### 13.2 获取我的反馈

**GET** `/api/feedback/my`

---

## 十四、管理端接口 `/api/admin`

### 14.1 自习室管理

```
GET    /api/admin/rooms                获取自习室列表(分页)
POST   /api/admin/rooms                新增自习室
PUT    /api/admin/rooms/{id}           修改自习室
DELETE /api/admin/rooms/{id}           删除自习室
PUT    /api/admin/rooms/{id}/status    修改状态
POST   /api/admin/rooms/{id}/seats     批量生成座位
```

### 14.2 用户管理

```
GET    /api/admin/users                获取用户列表
PUT    /api/admin/users/{id}/status    修改用户状态
PUT    /api/admin/users/{id}/credit    调整信用积分
PUT    /api/admin/users/{id}/role      修改角色
```

### 14.3 预约管理

```
GET    /api/admin/reservations         获取所有预约记录
GET    /api/admin/reservations/export  导出预约数据
```

### 14.4 违约管理

```
GET    /api/admin/violations           获取违约记录
PUT    /api/admin/violations/{id}      处理违约申诉
```

### 14.5 黑名单管理

```
GET    /api/admin/blacklist            获取黑名单
POST   /api/admin/blacklist            手动添加
DELETE /api/admin/blacklist/{id}       手动解除
```

### 14.6 公告管理

```
GET    /api/admin/notices              获取公告列表
POST   /api/admin/notices              发布公告
PUT    /api/admin/notices/{id}         修改公告
DELETE /api/admin/notices/{id}         删除公告
```

### 14.7 成就管理

```
GET    /api/admin/achievements         获取成就列表
POST   /api/admin/achievements         新增成就
PUT    /api/admin/achievements/{id}    修改成就
DELETE /api/admin/achievements/{id}    删除成就
```

### 14.8 商城管理

```
GET    /api/admin/shop/products        获取商品列表
POST   /api/admin/shop/products        新增商品
PUT    /api/admin/shop/products/{id}   修改商品
DELETE /api/admin/shop/products/{id}   删除商品
GET    /api/admin/shop/exchanges       获取兑换记录
PUT    /api/admin/shop/exchanges/{id}  处理兑换
```

### 14.9 反馈管理

```
GET    /api/admin/feedback             获取反馈列表
PUT    /api/admin/feedback/{id}        回复反馈
```

### 14.10 统计接口

```
GET    /api/admin/stats/overview       概览统计
GET    /api/admin/stats/usage          使用率统计
GET    /api/admin/stats/trend          趋势统计
GET    /api/admin/stats/rooms          自习室统计
GET    /api/admin/stats/users          用户统计
```

### 14.11 系统配置

```
GET    /api/admin/config               获取配置列表
PUT    /api/admin/config               批量更新配置
```

### 14.12 操作日志

```
GET    /api/admin/logs                 获取操作日志
```

---

**文档版本**：v2.0  
**接口总数**：100+  
**更新日期**：2026-01-21
