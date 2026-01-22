<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  Building2,
  Users,
  Calendar,
  AlertTriangle,
  Armchair,
  Clock,
  CheckCircle,
  XCircle,
  Coffee,
  TrendingUp,
  Activity,
  RefreshCw
} from 'lucide-vue-next'
import { getAdminStats, getRealTimeStatus, getRecentActivities } from '@/api/admin'

const router = useRouter()

// 统计数据
const stats = ref({
  totalRooms: 0,
  openRooms: 0,
  totalSeats: 0,
  availableSeats: 0,
  inUseSeats: 0,
  awaySeats: 0,
  todayReservations: 0,
  activeReservations: 0,
  todayViolations: 0,
  pendingAppeals: 0
})

// 实时状态
const realTimeStatus = ref({
  occupancyRate: 0,
  peakHour: '',
  avgDuration: 0
})

// 最近活动
const activities = ref<Array<{
  id: number
  type: string
  content: string
  time: string
  user?: string
}>>([])

const loading = ref(false)
const refreshing = ref(false)
let refreshTimer: ReturnType<typeof setInterval> | null = null

// 加载统计数据
const loadStats = async () => {
  try {
    const data = await getAdminStats()
    stats.value = data
  } catch (error) {
    console.error('加载统计失败:', error)
  }
}

// 加载实时状态
const loadRealTimeStatus = async () => {
  try {
    const data = await getRealTimeStatus()
    realTimeStatus.value = data
  } catch (error) {
    console.error('加载实时状态失败:', error)
  }
}

// 加载最近活动
const loadActivities = async () => {
  try {
    const data = await getRecentActivities()
    activities.value = data
  } catch (error) {
    console.error('加载活动失败:', error)
  }
}

// 刷新数据
const refresh = async () => {
  refreshing.value = true
  await Promise.all([loadStats(), loadRealTimeStatus(), loadActivities()])
  refreshing.value = false
}

// 获取活动图标
const getActivityIcon = (type: string) => {
  const icons: Record<string, any> = {
    'CHECK_IN': CheckCircle,
    'CHECK_OUT': XCircle,
    'AWAY': Coffee,
    'RESERVATION': Calendar,
    'VIOLATION': AlertTriangle
  }
  return icons[type] || Activity
}

// 获取活动类型颜色
const getActivityColor = (type: string) => {
  const colors: Record<string, string> = {
    'CHECK_IN': '#00C48C',
    'CHECK_OUT': '#4A9FFF',
    'AWAY': '#FFB020',
    'RESERVATION': '#7C5CFF',
    'VIOLATION': '#FF4D4F'
  }
  return colors[type] || '#6B7280'
}

// 导航
const navigateTo = (path: string) => {
  router.push(path)
}

onMounted(async () => {
  loading.value = true
  await refresh()
  loading.value = false
  
  // 每30秒自动刷新
  refreshTimer = setInterval(refresh, 30000)
})

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
})
</script>

<template>
  <div class="admin-dashboard" v-loading="loading">
    <!-- 页头 -->
    <div class="page-header">
      <div class="header-left">
        <h1><Activity :size="28" /> 实时监控中心</h1>
        <p>自习室运营状态一览</p>
      </div>
      <div class="header-right">
        <div class="live-indicator">
          <span class="pulse"></span>
          <span>实时更新</span>
        </div>
        <button class="refresh-btn" @click="refresh" :disabled="refreshing">
          <RefreshCw :size="18" :class="{ spinning: refreshing }" />
          刷新
        </button>
      </div>
    </div>
    
    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div class="stat-card rooms" @click="navigateTo('/admin/rooms')">
        <div class="stat-icon">
          <Building2 :size="28" />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.openRooms }}<span class="stat-sub">/{{ stats.totalRooms }}</span></div>
          <div class="stat-label">开放自习室</div>
        </div>
        <div class="stat-trend up">
          <TrendingUp :size="16" />
          运营中
        </div>
      </div>
      
      <div class="stat-card seats" @click="navigateTo('/admin/seats')">
        <div class="stat-icon">
          <Armchair :size="28" />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.inUseSeats }}<span class="stat-sub">/{{ stats.totalSeats }}</span></div>
          <div class="stat-label">在用座位</div>
        </div>
        <div class="occupancy-bar">
          <div class="bar-fill" :style="{ width: (stats.inUseSeats / stats.totalSeats * 100) + '%' }"></div>
        </div>
      </div>
      
      <div class="stat-card reservations" @click="navigateTo('/admin/reservations')">
        <div class="stat-icon">
          <Calendar :size="28" />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.todayReservations }}</div>
          <div class="stat-label">今日预约</div>
        </div>
        <div class="stat-detail">
          <span class="active">{{ stats.activeReservations }} 进行中</span>
        </div>
      </div>
      
      <div class="stat-card violations" @click="navigateTo('/admin/violations')">
        <div class="stat-icon">
          <AlertTriangle :size="28" />
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.todayViolations }}</div>
          <div class="stat-label">今日违规</div>
        </div>
        <div v-if="stats.pendingAppeals > 0" class="stat-badge">
          {{ stats.pendingAppeals }} 待处理
        </div>
      </div>
    </div>
    
    <!-- 主内容区 -->
    <div class="main-content">
      <!-- 座位状态概览 -->
      <div class="section seat-overview">
        <div class="section-header">
          <h2><Armchair :size="20" /> 座位状态概览</h2>
        </div>
        <div class="seat-status-grid">
          <div class="status-card available">
            <div class="status-icon">
              <CheckCircle :size="32" />
            </div>
            <div class="status-value">{{ stats.availableSeats }}</div>
            <div class="status-label">空闲</div>
          </div>
          <div class="status-card in-use">
            <div class="status-icon">
              <Users :size="32" />
            </div>
            <div class="status-value">{{ stats.inUseSeats }}</div>
            <div class="status-label">使用中</div>
          </div>
          <div class="status-card away">
            <div class="status-icon">
              <Coffee :size="32" />
            </div>
            <div class="status-value">{{ stats.awaySeats }}</div>
            <div class="status-label">暂离</div>
          </div>
        </div>
        
        <!-- 实时指标 -->
        <div class="realtime-metrics">
          <div class="metric">
            <span class="metric-label">使用率</span>
            <span class="metric-value">{{ realTimeStatus.occupancyRate }}%</span>
          </div>
          <div class="metric">
            <span class="metric-label">高峰时段</span>
            <span class="metric-value">{{ realTimeStatus.peakHour || '-' }}</span>
          </div>
          <div class="metric">
            <span class="metric-label">平均学习时长</span>
            <span class="metric-value">{{ realTimeStatus.avgDuration }}min</span>
          </div>
        </div>
      </div>
      
      <!-- 实时动态 -->
      <div class="section activity-feed">
        <div class="section-header">
          <h2><Activity :size="20" /> 实时动态</h2>
          <span class="count">最近20条</span>
        </div>
        <div class="activity-list">
          <div 
            v-for="activity in activities" 
            :key="activity.id" 
            class="activity-item"
          >
            <div 
              class="activity-icon" 
              :style="{ backgroundColor: getActivityColor(activity.type) + '20', color: getActivityColor(activity.type) }"
            >
              <component :is="getActivityIcon(activity.type)" :size="16" />
            </div>
            <div class="activity-content">
              <span class="activity-text">{{ activity.content }}</span>
              <span class="activity-user" v-if="activity.user">{{ activity.user }}</span>
            </div>
            <div class="activity-time">{{ activity.time }}</div>
          </div>
          
          <div v-if="activities.length === 0" class="empty-activity">
            <Clock :size="32" />
            <span>暂无最近动态</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 快捷操作 -->
    <div class="quick-actions">
      <button class="action-btn primary" @click="navigateTo('/admin/rooms')">
        <Building2 :size="20" />
        管理自习室
      </button>
      <button class="action-btn" @click="navigateTo('/admin/seats')">
        <Armchair :size="20" />
        座位监控
      </button>
      <button class="action-btn" @click="navigateTo('/admin/reservations')">
        <Calendar :size="20" />
        预约管理
      </button>
      <button class="action-btn warning" @click="navigateTo('/admin/violations')">
        <AlertTriangle :size="20" />
        违规处理
        <span v-if="stats.pendingAppeals > 0" class="badge">{{ stats.pendingAppeals }}</span>
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.admin-dashboard {
  padding: 24px;
  background: $gray-50;
  min-height: calc(100vh - 48px);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  
  .header-left {
    h1 {
      font-size: 24px;
      font-weight: 700;
      color: $text-primary;
      margin-bottom: 4px;
    }
    
    p {
      color: $text-secondary;
      font-size: 14px;
    }
  }
  
  .header-right {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  
  .live-indicator {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    background: $success-light;
    color: $success;
    border-radius: $radius-sm;
    font-size: 13px;
    font-weight: 500;
    
    .pulse {
      width: 8px;
      height: 8px;
      background: $success;
      border-radius: 50%;
      animation: pulse 2s infinite;
    }
  }
  
  .refresh-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    background: white;
    border: 1px solid $gray-200;
    border-radius: $radius-sm;
    color: $text-secondary;
    font-size: 14px;
    transition: all 0.2s;
    
    &:hover {
      color: $blue;
      border-color: $blue;
    }
    
    .spinning {
      animation: spin 1s linear infinite;
    }
  }
}

@keyframes pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.5; transform: scale(1.2); }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
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
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  cursor: pointer;
  transition: all 0.3s;
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
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: $shadow-lg;
  }
  
  &.rooms::before { background: $gradient-blue; }
  &.seats::before { background: $gradient-green; }
  &.reservations::before { background: $gradient-purple; }
  &.violations::before { background: linear-gradient(135deg, #FF4D4F, #FF7875); }
  
  .stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    
    .rooms & { background: $blue-light; color: $blue; }
    .seats & { background: $success-light; color: $success; }
    .reservations & { background: rgba(124, 92, 255, 0.1); color: $purple; }
    .violations & { background: $error-light; color: $error; }
  }
  
  .stat-content {
    .stat-value {
      font-size: 32px;
      font-weight: 700;
      color: $text-primary;
      line-height: 1;
      
      .stat-sub {
        font-size: 18px;
        color: $text-muted;
        font-weight: 500;
      }
    }
    
    .stat-label {
      font-size: 14px;
      color: $text-secondary;
      margin-top: 4px;
    }
  }
  
  .stat-trend {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
    color: $success;
    
    &.down { color: $error; }
  }
  
  .occupancy-bar {
    height: 6px;
    background: $gray-100;
    border-radius: 3px;
    overflow: hidden;
    
    .bar-fill {
      height: 100%;
      background: $gradient-green;
      border-radius: 3px;
      transition: width 0.5s ease;
    }
  }
  
  .stat-detail {
    font-size: 12px;
    color: $text-muted;
    
    .active {
      color: $success;
      font-weight: 500;
    }
  }
  
  .stat-badge {
    position: absolute;
    top: 12px;
    right: 12px;
    padding: 4px 8px;
    background: $error;
    color: white;
    font-size: 11px;
    font-weight: 600;
    border-radius: 10px;
  }
}

.main-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 24px;
}

.section {
  background: white;
  border-radius: $radius-lg;
  padding: 20px;
  
  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    
    h2 {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 16px;
      font-weight: 600;
      color: $text-primary;
    }
    
    .count {
      font-size: 12px;
      color: $text-muted;
    }
  }
}

.seat-overview {
  .seat-status-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    margin-bottom: 20px;
  }
  
  .status-card {
    text-align: center;
    padding: 20px;
    border-radius: $radius-md;
    
    &.available {
      background: linear-gradient(135deg, $success-light, rgba($success, 0.05));
      .status-icon { color: $success; }
      .status-value { color: $success; }
    }
    
    &.in-use {
      background: linear-gradient(135deg, $blue-light, rgba($blue, 0.05));
      .status-icon { color: $blue; }
      .status-value { color: $blue; }
    }
    
    &.away {
      background: linear-gradient(135deg, $warning-light, rgba($warning, 0.05));
      .status-icon { color: $warning; }
      .status-value { color: $warning; }
    }
    
    .status-icon {
      margin-bottom: 8px;
    }
    
    .status-value {
      font-size: 36px;
      font-weight: 700;
      line-height: 1;
    }
    
    .status-label {
      font-size: 14px;
      color: $text-secondary;
      margin-top: 4px;
    }
  }
  
  .realtime-metrics {
    display: flex;
    justify-content: space-around;
    padding-top: 16px;
    border-top: 1px solid $gray-100;
    
    .metric {
      text-align: center;
      
      .metric-label {
        display: block;
        font-size: 12px;
        color: $text-muted;
        margin-bottom: 4px;
      }
      
      .metric-value {
        font-size: 18px;
        font-weight: 600;
        color: $text-primary;
      }
    }
  }
}

.activity-feed {
  .activity-list {
    max-height: 360px;
    overflow-y: auto;
  }
  
  .activity-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid $gray-50;
    
    &:last-child { border-bottom: none; }
    
    .activity-icon {
      width: 32px;
      height: 32px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }
    
    .activity-content {
      flex: 1;
      min-width: 0;
      
      .activity-text {
        display: block;
        font-size: 13px;
        color: $text-primary;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      
      .activity-user {
        display: block;
        font-size: 12px;
        color: $text-muted;
      }
    }
    
    .activity-time {
      font-size: 12px;
      color: $text-muted;
      flex-shrink: 0;
    }
  }
  
  .empty-activity {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 40px;
    color: $text-muted;
    
    span {
      font-size: 14px;
    }
  }
}

.quick-actions {
  display: flex;
  gap: 12px;
  
  .action-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 20px;
    background: white;
    border: 1px solid $gray-200;
    border-radius: $radius-sm;
    color: $text-secondary;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.2s;
    position: relative;
    
    &:hover {
      color: $blue;
      border-color: $blue;
      background: $blue-light;
    }
    
    &.primary {
      background: $gradient-blue;
      color: white;
      border: none;
      
      &:hover {
        box-shadow: $shadow-blue;
      }
    }
    
    &.warning {
      &:hover {
        color: $error;
        border-color: $error;
        background: $error-light;
      }
    }
    
    .badge {
      position: absolute;
      top: -6px;
      right: -6px;
      min-width: 18px;
      height: 18px;
      padding: 0 5px;
      background: $error;
      color: white;
      font-size: 11px;
      font-weight: 600;
      border-radius: 9px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }
}

// 响应式
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .main-content {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .quick-actions {
    flex-wrap: wrap;
    
    .action-btn {
      flex: 1;
      min-width: 140px;
    }
  }
}
</style>
