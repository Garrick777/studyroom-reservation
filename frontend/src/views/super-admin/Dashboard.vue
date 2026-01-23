<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import {
  Users,
  Building2,
  UserCog,
  Settings,
  Shield,
  Trophy,
  TrendingUp,
  Activity,
  Database,
  Server,
  AlertCircle,
  CheckCircle,
  Calendar,
  Clock,
  BarChart3
} from 'lucide-vue-next'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart, LineChart, PieChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
} from 'echarts/components'
import VChart from 'vue-echarts'
import { getSuperAdminStats, getChartData } from '@/api/super-admin'

// 注册 ECharts 组件
use([
  CanvasRenderer,
  BarChart,
  LineChart,
  PieChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
])

const router = useRouter()

// 统计数据
const stats = ref({
  totalUsers: 0,
  activeUsers: 0,
  totalAdmins: 0,
  totalRooms: 0,
  totalSeats: 0,
  blacklistCount: 0,
  todayCheckIns: 0,
  totalAchievements: 0
})

// 系统状态
const systemStatus = ref({
  database: 'healthy',
  redis: 'healthy',
  storage: 'healthy'
})

// 待办事项
const pendingTasks = ref({
  appeals: 0,
  blacklistExpiring: 0,
  newUsers: 0
})

// 图表数据
const chartData = ref({
  userGrowth: [] as { date: string; count: number }[],
  reservationTrend: [] as { date: string; count: number }[],
  roomUsage: [] as { name: string; usage: number }[],
  categoryDistribution: [] as { name: string; value: number }[]
})

const loading = ref(false)
const chartLoading = ref(false)

// 模块列表
const modules = [
  { path: '/super/users', icon: Users, label: '用户管理', color: '#4A9FFF', badge: 'pendingTasks.newUsers' },
  { path: '/super/admins', icon: UserCog, label: '管理员管理', color: '#7C5CFF', badge: null },
  { path: '/super/rooms', icon: Building2, label: '自习室管理', color: '#00C48C', badge: null },
  { path: '/super/blacklist', icon: Shield, label: '黑名单管理', color: '#FF4D4F', badge: 'pendingTasks.blacklistExpiring' },
  { path: '/super/achievements', icon: Trophy, label: '成就管理', color: '#FFB020', badge: null },
  { path: '/super/settings', icon: Settings, label: '系统设置', color: '#6B7280', badge: null }
]

// 用户增长折线图配置
const userGrowthOption = computed(() => ({
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    borderColor: '#e5e7eb',
    textStyle: { color: '#374151' }
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '3%',
    top: '10%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    boundaryGap: false,
    data: chartData.value.userGrowth.map(d => d.date),
    axisLine: { lineStyle: { color: '#e5e7eb' } },
    axisLabel: { color: '#6b7280', fontSize: 11 }
  },
  yAxis: {
    type: 'value',
    axisLine: { show: false },
    axisTick: { show: false },
    splitLine: { lineStyle: { color: '#f3f4f6' } },
    axisLabel: { color: '#6b7280', fontSize: 11 }
  },
  series: [{
    name: '新增用户',
    type: 'line',
    smooth: true,
    data: chartData.value.userGrowth.map(d => d.count),
    areaStyle: {
      color: {
        type: 'linear',
        x: 0, y: 0, x2: 0, y2: 1,
        colorStops: [
          { offset: 0, color: 'rgba(74, 159, 255, 0.3)' },
          { offset: 1, color: 'rgba(74, 159, 255, 0.05)' }
        ]
      }
    },
    lineStyle: { color: '#4A9FFF', width: 2 },
    itemStyle: { color: '#4A9FFF' }
  }]
}))

// 预约趋势柱状图配置
const reservationTrendOption = computed(() => ({
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    borderColor: '#e5e7eb',
    textStyle: { color: '#374151' }
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '3%',
    top: '10%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: chartData.value.reservationTrend.map(d => d.date),
    axisLine: { lineStyle: { color: '#e5e7eb' } },
    axisLabel: { color: '#6b7280', fontSize: 11 }
  },
  yAxis: {
    type: 'value',
    axisLine: { show: false },
    axisTick: { show: false },
    splitLine: { lineStyle: { color: '#f3f4f6' } },
    axisLabel: { color: '#6b7280', fontSize: 11 }
  },
  series: [{
    name: '预约数',
    type: 'bar',
    data: chartData.value.reservationTrend.map(d => d.count),
    barWidth: '60%',
    itemStyle: {
      color: {
        type: 'linear',
        x: 0, y: 0, x2: 0, y2: 1,
        colorStops: [
          { offset: 0, color: '#00C48C' },
          { offset: 1, color: '#00A86B' }
        ]
      },
      borderRadius: [4, 4, 0, 0]
    }
  }]
}))

// 自习室使用率图配置
const roomUsageOption = computed(() => ({
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    borderColor: '#e5e7eb',
    textStyle: { color: '#374151' },
    formatter: (params: any) => {
      return `${params[0].name}<br/>使用率: <strong>${params[0].value}%</strong>`
    }
  },
  grid: {
    left: '3%',
    right: '10%',
    bottom: '3%',
    top: '3%',
    containLabel: true
  },
  xAxis: {
    type: 'value',
    max: 100,
    axisLine: { show: false },
    axisTick: { show: false },
    splitLine: { lineStyle: { color: '#f3f4f6' } },
    axisLabel: { color: '#6b7280', fontSize: 11, formatter: '{value}%' }
  },
  yAxis: {
    type: 'category',
    data: chartData.value.roomUsage.map(d => d.name),
    axisLine: { show: false },
    axisTick: { show: false },
    axisLabel: { color: '#374151', fontSize: 12 }
  },
  series: [{
    name: '使用率',
    type: 'bar',
    data: chartData.value.roomUsage.map(d => d.usage),
    barWidth: 16,
    itemStyle: {
      color: (params: any) => {
        const value = params.value
        if (value >= 80) return '#ef4444'
        if (value >= 60) return '#f59e0b'
        return '#10b981'
      },
      borderRadius: [0, 4, 4, 0]
    },
    label: {
      show: true,
      position: 'right',
      formatter: '{c}%',
      color: '#6b7280',
      fontSize: 11
    }
  }]
}))

// 预约分类分布饼图配置
const categoryDistributionOption = computed(() => ({
  tooltip: {
    trigger: 'item',
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    borderColor: '#e5e7eb',
    textStyle: { color: '#374151' },
    formatter: '{b}: {c} ({d}%)'
  },
  legend: {
    orient: 'vertical',
    right: '5%',
    top: 'center',
    textStyle: { color: '#374151', fontSize: 12 }
  },
  series: [{
    name: '预约分类',
    type: 'pie',
    radius: ['40%', '70%'],
    center: ['35%', '50%'],
    avoidLabelOverlap: false,
    itemStyle: {
      borderRadius: 8,
      borderColor: '#fff',
      borderWidth: 2
    },
    label: {
      show: false
    },
    emphasis: {
      label: {
        show: true,
        fontSize: 14,
        fontWeight: 'bold'
      }
    },
    labelLine: { show: false },
    data: chartData.value.categoryDistribution,
    color: ['#4A9FFF', '#00C48C', '#FFB020', '#7C5CFF', '#FF6B6B']
  }]
}))

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const data = await getSuperAdminStats()
    stats.value = data.stats || {}
    systemStatus.value = data.systemStatus || systemStatus.value
    pendingTasks.value = data.pendingTasks || {}
  } catch (error) {
    console.error('加载数据失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载图表数据
const loadChartData = async () => {
  chartLoading.value = true
  try {
    const data = await getChartData()
    chartData.value = data
  } catch (error) {
    console.error('加载图表数据失败:', error)
    // 使用模拟数据
    chartData.value = generateMockChartData()
  } finally {
    chartLoading.value = false
  }
}

// 生成模拟数据（后端API不可用时使用）
const generateMockChartData = () => {
  const today = new Date()
  const userGrowth = []
  const reservationTrend = []
  
  for (let i = 6; i >= 0; i--) {
    const date = new Date(today)
    date.setDate(date.getDate() - i)
    const dateStr = `${date.getMonth() + 1}/${date.getDate()}`
    
    userGrowth.push({
      date: dateStr,
      count: Math.floor(Math.random() * 20) + 5
    })
    
    reservationTrend.push({
      date: dateStr,
      count: Math.floor(Math.random() * 100) + 50
    })
  }
  
  return {
    userGrowth,
    reservationTrend,
    roomUsage: [
      { name: '图书馆A区', usage: 85 },
      { name: '图书馆B区', usage: 72 },
      { name: '教学楼自习室', usage: 65 },
      { name: '综合楼一楼', usage: 58 },
      { name: '科技楼研讨室', usage: 45 }
    ],
    categoryDistribution: [
      { name: '普通座位', value: 350 },
      { name: '靠窗座位', value: 120 },
      { name: '电源座位', value: 180 },
      { name: 'VIP座位', value: 50 }
    ]
  }
}

// 导航
const navigateTo = (path: string) => {
  router.push(path)
}

// 获取徽章数量
const getBadgeCount = (badgeKey: string | null) => {
  if (!badgeKey) return 0
  const keys = badgeKey.split('.')
  let value: any = pendingTasks.value
  for (const key of keys.slice(1)) {
    value = value?.[key]
  }
  return value || 0
}

onMounted(() => {
  loadData()
  loadChartData()
})
</script>

<template>
  <div class="super-dashboard" v-loading="loading">
    <!-- 页头 -->
    <div class="page-header">
      <div class="header-content">
        <h1><BarChart3 :size="28" class="title-icon" /> 数据中心</h1>
        <p>系统管理与数据监控</p>
      </div>
      <div class="system-status">
        <div class="status-item" :class="systemStatus.database">
          <Database :size="16" />
          <span>数据库</span>
        </div>
        <div class="status-item" :class="systemStatus.redis">
          <Server :size="16" />
          <span>缓存</span>
        </div>
        <div class="status-item" :class="systemStatus.storage">
          <Activity :size="16" />
          <span>存储</span>
        </div>
      </div>
    </div>
    
    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div class="stat-card users">
        <div class="card-header">
          <div class="card-icon">
            <Users :size="24" />
          </div>
          <div class="card-trend up">
            <TrendingUp :size="14" />
            活跃
          </div>
        </div>
        <div class="card-value">{{ stats.totalUsers }}</div>
        <div class="card-label">注册用户</div>
        <div class="card-sub">活跃用户: {{ stats.activeUsers }}</div>
      </div>
      
      <div class="stat-card admins">
        <div class="card-header">
          <div class="card-icon">
            <UserCog :size="24" />
          </div>
        </div>
        <div class="card-value">{{ stats.totalAdmins }}</div>
        <div class="card-label">管理员</div>
        <div class="card-sub">自习室管理员</div>
      </div>
      
      <div class="stat-card rooms">
        <div class="card-header">
          <div class="card-icon">
            <Building2 :size="24" />
          </div>
        </div>
        <div class="card-value">{{ stats.totalRooms }}</div>
        <div class="card-label">自习室</div>
        <div class="card-sub">共 {{ stats.totalSeats }} 个座位</div>
      </div>
      
      <div class="stat-card checkins">
        <div class="card-header">
          <div class="card-icon">
            <CheckCircle :size="24" />
          </div>
        </div>
        <div class="card-value">{{ stats.todayCheckIns }}</div>
        <div class="card-label">今日打卡</div>
        <div class="card-sub">用户签到数</div>
      </div>
    </div>
    
    <!-- 图表区域 -->
    <div class="charts-section">
      <div class="charts-row">
        <div class="chart-card">
          <div class="chart-header">
            <h3><Users :size="18" /> 用户增长趋势</h3>
            <span class="chart-period">近7天</span>
          </div>
          <div class="chart-body" v-loading="chartLoading">
            <v-chart :option="userGrowthOption" autoresize />
          </div>
        </div>
        
        <div class="chart-card">
          <div class="chart-header">
            <h3><Calendar :size="18" /> 每日预约趋势</h3>
            <span class="chart-period">近7天</span>
          </div>
          <div class="chart-body" v-loading="chartLoading">
            <v-chart :option="reservationTrendOption" autoresize />
          </div>
        </div>
      </div>
      
      <div class="charts-row">
        <div class="chart-card">
          <div class="chart-header">
            <h3><Building2 :size="18" /> 自习室使用率</h3>
            <span class="chart-period">今日实时</span>
          </div>
          <div class="chart-body" v-loading="chartLoading">
            <v-chart :option="roomUsageOption" autoresize />
          </div>
        </div>
        
        <div class="chart-card">
          <div class="chart-header">
            <h3><Activity :size="18" /> 座位类型分布</h3>
            <span class="chart-period">当前预约</span>
          </div>
          <div class="chart-body" v-loading="chartLoading">
            <v-chart :option="categoryDistributionOption" autoresize />
          </div>
        </div>
      </div>
    </div>
    
    <!-- 功能模块 -->
    <div class="modules-section">
      <h2>功能模块</h2>
      <div class="modules-grid">
        <div 
          v-for="module in modules" 
          :key="module.path"
          class="module-card"
          :style="{ '--accent-color': module.color }"
          @click="navigateTo(module.path)"
        >
          <div class="module-icon" :style="{ backgroundColor: module.color + '15', color: module.color }">
            <component :is="module.icon" :size="28" />
          </div>
          <div class="module-label">{{ module.label }}</div>
          <div 
            v-if="module.badge && getBadgeCount(module.badge) > 0" 
            class="module-badge"
          >
            {{ getBadgeCount(module.badge) }}
          </div>
        </div>
      </div>
    </div>
    
    <!-- 待办提醒 -->
    <div class="pending-section" v-if="pendingTasks.appeals > 0 || pendingTasks.blacklistExpiring > 0">
      <h2><AlertCircle :size="20" /> 待办提醒</h2>
      <div class="pending-list">
        <div 
          v-if="pendingTasks.appeals > 0" 
          class="pending-item"
          @click="navigateTo('/super/blacklist')"
        >
          <Shield :size="18" />
          <span>有 <strong>{{ pendingTasks.appeals }}</strong> 个申诉待处理</span>
        </div>
        <div 
          v-if="pendingTasks.blacklistExpiring > 0" 
          class="pending-item"
          @click="navigateTo('/super/blacklist')"
        >
          <AlertCircle :size="18" />
          <span>有 <strong>{{ pendingTasks.blacklistExpiring }}</strong> 个黑名单即将到期</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.super-dashboard {
  padding: 24px;
  background: $gray-50;
  min-height: calc(100vh - 48px);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  
  .header-content {
    h1 {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 26px;
      font-weight: 700;
      color: $text-primary;
      margin-bottom: 4px;
    }
    
    p {
      color: $text-secondary;
      font-size: 14px;
    }
  }
  
  .system-status {
    display: flex;
    gap: 12px;
    
    .status-item {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 8px 12px;
      background: white;
      border-radius: $radius-sm;
      font-size: 13px;
      color: $text-secondary;
      
      &.healthy {
        color: $success;
        background: $success-light;
      }
      
      &.warning {
        color: $warning;
        background: $warning-light;
      }
      
      &.error {
        color: $error;
        background: $error-light;
      }
    }
  }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  border-radius: $radius-lg;
  padding: 24px;
  position: relative;
  overflow: hidden;
  
  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
  }
  
  &.users::before { background: $gradient-blue; }
  &.admins::before { background: $gradient-purple; }
  &.rooms::before { background: $gradient-green; }
  &.checkins::before { background: linear-gradient(135deg, #FFB020, #FF9500); }
  
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 16px;
  }
  
  .card-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    
    .users & { background: $blue-light; color: $blue; }
    .admins & { background: rgba($purple, 0.1); color: $purple; }
    .rooms & { background: $success-light; color: $success; }
    .checkins & { background: $warning-light; color: $warning; }
  }
  
  .card-trend {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
    padding: 4px 8px;
    border-radius: 4px;
    
    &.up {
      color: $success;
      background: $success-light;
    }
  }
  
  .card-value {
    font-size: 36px;
    font-weight: 700;
    color: $text-primary;
    line-height: 1;
    margin-bottom: 4px;
  }
  
  .card-label {
    font-size: 14px;
    color: $text-secondary;
    margin-bottom: 8px;
  }
  
  .card-sub {
    font-size: 12px;
    color: $text-muted;
  }
}

// 图表区域
.charts-section {
  margin-bottom: 24px;
}

.charts-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
  
  &:last-child {
    margin-bottom: 0;
  }
}

.chart-card {
  background: white;
  border-radius: $radius-lg;
  padding: 20px;
  
  .chart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    
    h3 {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 15px;
      font-weight: 600;
      color: $text-primary;
    }
    
    .chart-period {
      font-size: 12px;
      color: $text-muted;
      padding: 4px 8px;
      background: $gray-100;
      border-radius: 4px;
    }
  }
  
  .chart-body {
    height: 250px;
  }
}

.modules-section {
  margin-bottom: 24px;
  
  h2 {
    font-size: 18px;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 16px;
  }
}

.modules-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 16px;
}

.module-card {
  background: white;
  border-radius: $radius-lg;
  padding: 24px 16px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  position: relative;
  border: 2px solid transparent;
  
  &:hover {
    transform: translateY(-4px);
    border-color: var(--accent-color);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  }
  
  .module-icon {
    width: 56px;
    height: 56px;
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 12px;
  }
  
  .module-label {
    font-size: 14px;
    font-weight: 500;
    color: $text-primary;
  }
  
  .module-badge {
    position: absolute;
    top: 12px;
    right: 12px;
    min-width: 20px;
    height: 20px;
    padding: 0 6px;
    background: $error;
    color: white;
    font-size: 11px;
    font-weight: 600;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}

.pending-section {
  background: white;
  border-radius: $radius-lg;
  padding: 20px;
  
  h2 {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 16px;
    font-weight: 600;
    color: $warning;
    margin-bottom: 16px;
  }
  
  .pending-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .pending-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    background: $warning-light;
    border-radius: $radius-sm;
    color: $text-primary;
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
      background: rgba($warning, 0.2);
    }
    
    strong {
      color: $warning;
    }
  }
}

// 响应式
@media (max-width: 1400px) {
  .modules-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  
  .charts-row {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .modules-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .page-header {
    flex-direction: column;
    gap: 16px;
    
    .system-status {
      width: 100%;
      justify-content: center;
    }
  }
}
</style>
