# 🎨 图标使用指南 - Lucide Icons

## 一、为什么选择 Lucide

| 优势 | 说明 |
|------|------|
| 🎯 **简洁现代** | 统一的2px描边，视觉一致性强 |
| 📦 **1400+ 图标** | 覆盖绝大多数使用场景 |
| 🔄 **持续更新** | 社区活跃，每周都有新图标 |
| 📐 **24x24 标准** | 完美适配设计规范 |
| 🪶 **体积小** | 按需引入，打包体积小 |
| 🎨 **易于定制** | 支持颜色、大小、描边宽度调整 |

**官网**: https://lucide.dev/icons/

---

## 二、安装配置

### 方式一：直接安装 lucide-vue-next（推荐）

```bash
npm install lucide-vue-next
```

### 方式二：使用 unplugin-icons（按需自动导入）

```bash
npm install -D unplugin-icons @iconify-json/lucide
```

**vite.config.js**:
```javascript
import Icons from 'unplugin-icons/vite'
import IconsResolver from 'unplugin-icons/resolver'
import Components from 'unplugin-vue-components/vite'

export default defineConfig({
  plugins: [
    vue(),
    Components({
      resolvers: [
        IconsResolver({
          prefix: 'i',
          enabledCollections: ['lucide'],
        }),
      ],
    }),
    Icons({
      compiler: 'vue3',
      autoInstall: true,
    }),
  ],
})
```

---

## 三、使用方式

### 方式一：具名导入（推荐，Tree-shaking友好）

```vue
<template>
  <div class="nav-item">
    <Home :size="20" />
    <span>首页</span>
  </div>
</template>

<script setup>
import { Home, Calendar, User, Settings } from 'lucide-vue-next'
</script>
```

### 方式二：动态图标组件

```vue
<template>
  <component :is="icons[iconName]" :size="size" :color="color" />
</template>

<script setup>
import { Home, Calendar, User } from 'lucide-vue-next'

const props = defineProps({
  iconName: String,
  size: { type: Number, default: 20 },
  color: { type: String, default: 'currentColor' }
})

const icons = { Home, Calendar, User }
</script>
```

### 方式三：使用 unplugin-icons（无需导入）

```vue
<template>
  <!-- 自动导入，无需import -->
  <i-lucide-home />
  <i-lucide-calendar />
  <i-lucide-user />
</template>
```

---

## 四、图标属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `size` | number/string | 24 | 图标尺寸 |
| `color` | string | currentColor | 图标颜色 |
| `stroke-width` | number | 2 | 描边宽度 |
| `absolute-stroke-width` | boolean | false | 固定描边宽度 |

```vue
<!-- 示例 -->
<Home :size="32" color="#3FB19E" :stroke-width="1.5" />
```

---

## 五、项目图标映射表

### 🧭 导航图标

| 功能 | 图标名称 | 预览 | 使用场景 |
|------|----------|------|----------|
| 首页 | `Home` | 🏠 | 首页导航 |
| 自习室 | `BookOpen` | 📖 | 自习室列表 |
| 预约 | `Calendar` | 📅 | 我的预约 |
| 目标 | `Target` | 🎯 | 学习目标 |
| 成就 | `Trophy` | 🏆 | 成就中心 |
| 好友 | `Users` | 👥 | 好友列表 |
| 小组 | `UsersRound` | 👨‍👩‍👧‍👦 | 学习小组 |
| 商城 | `ShoppingCart` | 🛒 | 积分商城 |
| 排行榜 | `Medal` | 🥇 | 排行榜 |
| 消息 | `Bell` | 🔔 | 通知消息 |
| 私信 | `MessageCircle` | 💬 | 私信聊天 |
| 设置 | `Settings` | ⚙️ | 系统设置 |
| 个人 | `User` | 👤 | 个人中心 |

### 📅 预约相关

| 功能 | 图标名称 | 使用场景 |
|------|----------|----------|
| 创建预约 | `CalendarPlus` | 新建预约按钮 |
| 取消预约 | `CalendarX` | 取消预约 |
| 预约成功 | `CalendarCheck` | 预约成功状态 |
| 时间段 | `Clock` | 时间段选择 |
| 日期 | `CalendarDays` | 日期选择器 |
| 定时 | `Timer` | 计时器 |
| 闹钟 | `AlarmClock` | 提醒设置 |

### 🪑 座位相关

| 功能 | 图标名称 | 使用场景 |
|------|----------|----------|
| 座位 | `Armchair` | 座位图标 |
| 电源座 | `PlugZap` | 有电源的座位 |
| 靠窗座 | `Sun` | 靠窗座位 |
| 安静区 | `VolumeX` | 静音区域 |
| 讨论区 | `MessagesSquare` | 可讨论区域 |
| 签到 | `ScanLine` | 扫码签到 |
| 签退 | `LogOut` | 离开签退 |
| 暂离 | `Clock3` | 暂时离开 |

### ✅ 状态图标

| 状态 | 图标名称 | 颜色 | 使用场景 |
|------|----------|------|----------|
| 成功 | `CheckCircle` | #34C759 | 操作成功 |
| 警告 | `AlertTriangle` | #FFAB00 | 警告提示 |
| 错误 | `XCircle` | #FF3B30 | 错误状态 |
| 信息 | `Info` | #2196F3 | 信息提示 |
| 加载 | `Loader2` | - | 加载动画 |
| 待处理 | `CircleDot` | #9E9E9E | 等待状态 |

### 🏆 成就相关

| 功能 | 图标名称 | 使用场景 |
|------|----------|----------|
| 奖杯 | `Trophy` | 成就徽章 |
| 奖牌 | `Medal` | 排名奖励 |
| 皇冠 | `Crown` | 第一名 |
| 星星 | `Star` | 收藏/评分 |
| 火焰 | `Flame` | 连续打卡 |
| 闪电 | `Zap` | 极速成就 |
| 心形 | `Heart` | 喜欢/感谢 |
| 钻石 | `Gem` | 稀有成就 |

### 🔧 操作图标

| 操作 | 图标名称 | 使用场景 |
|------|----------|----------|
| 添加 | `Plus` | 新增按钮 |
| 删除 | `Trash2` | 删除操作 |
| 编辑 | `Pencil` | 编辑按钮 |
| 搜索 | `Search` | 搜索框 |
| 筛选 | `Filter` | 筛选条件 |
| 排序 | `ArrowUpDown` | 排序切换 |
| 刷新 | `RefreshCw` | 刷新数据 |
| 导出 | `Download` | 下载/导出 |
| 分享 | `Share2` | 分享功能 |
| 复制 | `Copy` | 复制内容 |
| 更多 | `MoreHorizontal` | 更多操作 |
| 返回 | `ArrowLeft` | 返回上页 |
| 关闭 | `X` | 关闭弹窗 |

### 📊 数据图标

| 功能 | 图标名称 | 使用场景 |
|------|----------|----------|
| 图表 | `BarChart3` | 统计图表 |
| 趋势 | `TrendingUp` | 上升趋势 |
| 下降 | `TrendingDown` | 下降趋势 |
| 饼图 | `PieChart` | 占比分析 |
| 活动 | `Activity` | 实时动态 |
| 数据 | `Database` | 数据管理 |

### 🏢 自习室图标

| 类型 | 图标名称 | 使用场景 |
|------|----------|----------|
| 图书馆 | `Library` | 图书馆自习室 |
| 教学楼 | `GraduationCap` | 教学楼 |
| 综合楼 | `Building` | 综合楼 |
| 位置 | `MapPin` | 地点标记 |
| 容量 | `Users` | 座位容量 |
| 开放时间 | `Clock` | 开放时间 |

---

## 六、封装图标组件

创建统一的图标组件，便于管理和复用：

**components/AppIcon.vue**:
```vue
<template>
  <component 
    :is="iconComponent" 
    :size="size" 
    :color="color" 
    :stroke-width="strokeWidth"
    :class="['app-icon', { 'app-icon--spin': spin }]"
  />
</template>

<script setup>
import { computed } from 'vue'
import * as icons from 'lucide-vue-next'

const props = defineProps({
  name: {
    type: String,
    required: true
  },
  size: {
    type: [Number, String],
    default: 20
  },
  color: {
    type: String,
    default: 'currentColor'
  },
  strokeWidth: {
    type: Number,
    default: 2
  },
  spin: {
    type: Boolean,
    default: false
  }
})

const iconComponent = computed(() => {
  const iconName = props.name
    .split('-')
    .map(part => part.charAt(0).toUpperCase() + part.slice(1))
    .join('')
  return icons[iconName] || icons.CircleHelp
})
</script>

<style scoped>
.app-icon--spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>
```

**使用**:
```vue
<template>
  <AppIcon name="home" :size="24" />
  <AppIcon name="calendar-plus" color="#3FB19E" />
  <AppIcon name="loader-2" :spin="true" />
</template>
```

---

## 七、图标尺寸规范

| 场景 | 尺寸 | 说明 |
|------|------|------|
| 导航图标 | 20px | 侧边栏/底部导航 |
| 按钮图标 | 16-18px | 配合文字的按钮 |
| 标题图标 | 24px | 卡片标题装饰 |
| 状态图标 | 14-16px | 标签/状态指示 |
| 大型展示 | 32-48px | 空状态/成就展示 |
| 表格操作 | 16px | 表格行操作按钮 |

---

## 八、颜色规范

```scss
// 图标颜色变量
$icon-primary: #3FB19E;      // 主色
$icon-secondary: #7195B9;    // 辅助色
$icon-accent: #FFCB2F;       // 强调色
$icon-success: #34C759;      // 成功
$icon-warning: #FFAB00;      // 警告
$icon-error: #FF3B30;        // 错误
$icon-info: #2196F3;         // 信息
$icon-disabled: #9E9E9E;     // 禁用
$icon-default: currentColor; // 继承文字颜色
```

---

## 九、常用图标速查

```vue
<script setup>
// 一次性导入常用图标
import {
  // 导航
  Home, BookOpen, Calendar, Target, Trophy, Users, 
  ShoppingCart, Bell, Settings, User,
  
  // 操作
  Plus, Trash2, Pencil, Search, Filter, RefreshCw,
  X, ArrowLeft, MoreHorizontal,
  
  // 状态
  CheckCircle, AlertTriangle, XCircle, Info, Loader2,
  
  // 预约
  CalendarPlus, CalendarX, CalendarCheck, Clock, Timer,
  
  // 成就
  Medal, Crown, Star, Flame, Zap, Gem,
  
  // 数据
  BarChart3, TrendingUp, TrendingDown, Activity
  
} from 'lucide-vue-next'
</script>
```

---

**文档版本**: v1.0  
**更新日期**: 2026-01-21  
**图标库版本**: lucide-vue-next@latest
