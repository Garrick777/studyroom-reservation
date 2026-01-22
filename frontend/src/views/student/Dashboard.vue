<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { getDashboardStats, getHotRooms, getRanking, getAchievements } from '@/api/stats'
import type { DashboardStats, HotRoom, RankingItem, Achievement } from '@/api/stats'
import { ElMessage } from 'element-plus'
import {
  Building2,
  Calendar,
  Clock,
  Flame,
  Target,
  Trophy,
  Medal,
  ChevronRight,
  Play,
  Pause,
  Square,
  Star,
  TrendingUp
} from 'lucide-vue-next'

const router = useRouter()
const userStore = useUserStore()

// 加载状态
const loading = ref(true)

// 计时器状态
const isStudying = ref(false)
const isPaused = ref(false)
const studyTime = ref(0) // 秒
let timerInterval: number | null = null

// 真实数据
const stats = ref<DashboardStats>({
  creditScore: 0,
  totalPoints: 0,
  totalStudyTime: 0,
  totalStudyHours: 0,
  consecutiveDays: 0,
  totalCheckIns: 0,
  currentStreak: 0,
  maxStreak: 0,
  todayStudyTime: 0,
  todayStudyHours: 0,
  dailyGoalHours: 4,
  dailyGoalProgress: 0
})

const hotRooms = ref<HotRoom[]>([])
const rankingList = ref<RankingItem[]>([])
const achievements = ref<Achievement[]>([])
const myRank = ref<number | string>('--')

// 计算属性
const userName = computed(() => userStore.userInfo?.realName || userStore.userInfo?.username || '用户')
const userAvatar = computed(() => userStore.userInfo?.realName?.charAt(0) || 'U')

// 加载仪表盘数据
const loadDashboardData = async () => {
  loading.value = true
  try {
    // 并行加载所有数据
    const [statsData, roomsData, rankingData, achievementsData] = await Promise.all([
      getDashboardStats(),
      getHotRooms(),
      getRanking('today', 3),
      getAchievements()
    ])
    
    stats.value = statsData
    hotRooms.value = roomsData
    rankingList.value = rankingData.list.slice(0, 3)
    myRank.value = rankingData.myRank
    achievements.value = achievementsData.list.slice(0, 2)
    
  } catch (error) {
    console.error('加载仪表盘数据失败:', error)
    ElMessage.error('加载数据失败，请刷新重试')
  } finally {
    loading.value = false
  }
}

// 计时器控制
const formatTime = (seconds: number) => {
  const hrs = Math.floor(seconds / 3600)
  const mins = Math.floor((seconds % 3600) / 60)
  const secs = seconds % 60
  return `${hrs.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
}

const startTimer = () => {
  if (timerInterval) return
  isStudying.value = true
  isPaused.value = false
  timerInterval = window.setInterval(() => {
    studyTime.value++
  }, 1000)
}

const pauseTimer = () => {
  if (timerInterval) {
    clearInterval(timerInterval)
    timerInterval = null
    isPaused.value = true
  }
}

const stopTimer = () => {
  if (timerInterval) {
    clearInterval(timerInterval)
    timerInterval = null
  }
  isStudying.value = false
  isPaused.value = false
  studyTime.value = 0
}

// 导航
const goToRooms = () => router.push('/rooms')
const goToRoom = (id: number) => router.push(`/rooms/${id}`)
const goToRanking = () => router.push('/ranking')
const goToAchievements = () => router.push('/achievements')
const goToProfile = () => router.push('/profile')

// 检查是否已签到
const hasCheckedIn = computed(() => stats.value.totalCheckIns > 0)

onMounted(() => {
  loadDashboardData()
})

onUnmounted(() => {
  if (timerInterval) {
    clearInterval(timerInterval)
  }
})
</script>

<template>
  <div class="dashboard" v-loading="loading">
    <!-- 欢迎卡片 -->
    <div class="bento-card welcome-card" @click="goToRooms">
      <div class="welcome-content">
        <div class="welcome-emoji">👋</div>
        <h1>你好，{{ userName }}</h1>
      </div>
      <p class="welcome-subtitle">今天也要加油学习哦！</p>
      <div class="welcome-stats">
        <div class="stat-item">
          <Clock :size="16" />
          <span>今日学习 {{ stats.todayStudyHours.toFixed(1) }}h</span>
        </div>
        <div class="stat-item">
          <Flame :size="16" />
          <span>连续 {{ stats.consecutiveDays }} 天</span>
        </div>
      </div>
      <button class="reserve-btn" @click.stop="goToRooms">
        <Calendar :size="18" />
        立即预约座位
      </button>
    </div>

    <!-- 用户数据卡片 -->
    <div class="bento-card user-card" @click="goToProfile">
      <div class="user-info">
        <div class="user-avatar">{{ userAvatar }}</div>
        <div class="credit-score">
          <span class="label">信用分</span>
          <span class="value">{{ stats.creditScore }}</span>
        </div>
      </div>
      <div class="user-stats">
        <div class="stat">
          <span class="number">{{ stats.totalStudyHours.toFixed(0) }}h</span>
          <span class="text">累计学习</span>
        </div>
        <div class="stat">
          <span class="number">{{ stats.totalPoints }}</span>
          <span class="text">积分</span>
        </div>
      </div>
    </div>

    <!-- 学习计时器 -->
    <div class="bento-card timer-card" @click="!isStudying && startTimer()">
      <div class="timer-display">
        <span class="time">{{ formatTime(studyTime) }}</span>
        <span class="status">{{ isStudying ? (isPaused ? '已暂停' : '学习中') : '未开始' }}</span>
      </div>
      <div class="timer-controls">
        <button v-if="!isStudying" class="control-btn play" @click.stop="startTimer">
          <Play :size="24" />
        </button>
        <template v-else>
          <button v-if="!isPaused" class="control-btn pause" @click.stop="pauseTimer">
            <Pause :size="24" />
          </button>
          <button v-else class="control-btn play" @click.stop="startTimer">
            <Play :size="24" />
          </button>
          <button class="control-btn stop" @click.stop="stopTimer">
            <Square :size="20" />
          </button>
        </template>
      </div>
    </div>

    <!-- 今日打卡 -->
    <div class="bento-card checkin-card" @click="goToProfile">
      <Calendar :size="32" class="checkin-icon" />
      <div class="checkin-info">
        <span class="label">今日打卡</span>
        <span class="status">{{ hasCheckedIn ? '已签到' : '未签到' }}</span>
      </div>
      <ChevronRight :size="20" class="arrow" />
    </div>

    <!-- 最新成就 -->
    <div class="bento-card achievements-card" @click="goToAchievements">
      <div class="card-header">
        <Medal :size="20" />
        <span>最新成就</span>
        <ChevronRight :size="18" class="arrow" />
      </div>
      <div class="achievement-list" v-if="achievements.length > 0">
        <div 
          v-for="ach in achievements" 
          :key="ach.id" 
          class="achievement-item"
          :class="ach.rarity.toLowerCase()"
        >
          <span class="icon">{{ ach.icon }}</span>
          <span class="name">{{ ach.name }}</span>
        </div>
      </div>
      <div class="empty-tip" v-else>
        暂无成就，快去解锁吧！
      </div>
    </div>

    <!-- 热门自习室 -->
    <div class="bento-card rooms-card">
      <div class="card-header">
        <Building2 :size="20" />
        <span>热门自习室</span>
        <button class="view-all" @click="goToRooms">
          查看全部
          <ChevronRight :size="16" />
        </button>
      </div>
      <div class="room-list" v-if="hotRooms.length > 0">
        <div 
          v-for="room in hotRooms.slice(0, 3)" 
          :key="room.id" 
          class="room-item"
          @click="goToRoom(room.id)"
        >
          <span class="name">{{ room.name }}</span>
          <span class="seats">{{ room.availableSeats }} / {{ room.totalSeats }} 空位</span>
        </div>
      </div>
      <div class="empty-tip" v-else>
        暂无开放的自习室
      </div>
    </div>

    <!-- 今日目标 -->
    <div class="bento-card goal-card">
      <div class="card-header">
        <Target :size="20" />
        <span>今日目标</span>
      </div>
      <div class="goal-progress">
        <TrendingUp :size="32" class="goal-icon" />
        <div class="progress-text">
          <span class="current">{{ stats.todayStudyHours.toFixed(1) }}h</span>
          <span class="divider">/ {{ stats.dailyGoalHours }}h</span>
        </div>
      </div>
    </div>

    <!-- 今日榜单 -->
    <div class="bento-card ranking-card" @click="goToRanking">
      <div class="card-header">
        <Trophy :size="20" />
        <span>今日榜单</span>
        <ChevronRight :size="18" class="arrow" />
      </div>
      <div class="ranking-list" v-if="rankingList.length > 0">
        <div 
          v-for="item in rankingList" 
          :key="item.rank" 
          class="ranking-item"
        >
          <span class="rank" :class="'rank-' + item.rank">{{ item.rank }}</span>
          <span class="avatar">{{ item.realName?.charAt(0) || 'U' }}</span>
          <span class="name">{{ item.realName || item.username }}</span>
          <span class="hours">{{ item.totalStudyHours }}h</span>
        </div>
      </div>
      <div class="empty-tip" v-else>
        暂无排行数据
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
@import '@/styles/variables.scss';

.dashboard {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: auto;
  gap: $spacing-4;
  padding: $spacing-4;
  min-height: calc(100vh - 60px);
  background: $bg-page;

  @media (max-width: 1200px) {
    grid-template-columns: repeat(2, 1fr);
  }

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.bento-card {
  background: $bg-card;
  border-radius: $radius-lg;
  padding: $spacing-5;
  box-shadow: $shadow-card;
  cursor: pointer;
  transition: $transition-normal;

  &:hover {
    transform: translateY(-2px);
    box-shadow: $shadow-card-hover;
  }
}

// 欢迎卡片
.welcome-card {
  grid-column: span 2;
  background: $gradient-hero;
  color: white;
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: -50%;
    right: -50%;
    width: 100%;
    height: 100%;
    background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
    border-radius: 50%;
  }

  .welcome-content {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    margin-bottom: $spacing-2;

    .welcome-emoji {
      font-size: 28px;
    }

    h1 {
      font-size: $font-size-3xl;
      font-weight: $font-weight-bold;
      margin: 0;
    }
  }

  .welcome-subtitle {
    opacity: 0.9;
    margin-bottom: $spacing-4;
  }

  .welcome-stats {
    display: flex;
    gap: $spacing-4;
    margin-bottom: $spacing-5;

    .stat-item {
      display: flex;
      align-items: center;
      gap: $spacing-1;
      font-size: $font-size-sm;
      opacity: 0.9;
    }
  }

  .reserve-btn {
    display: inline-flex;
    align-items: center;
    gap: $spacing-2;
    padding: $spacing-3 $spacing-5;
    background: white;
    color: $primary;
    border: none;
    border-radius: $radius-md;
    font-weight: $font-weight-medium;
    cursor: pointer;
    transition: $transition-fast;

    &:hover {
      transform: scale(1.02);
      box-shadow: $shadow-md;
    }
  }
}

// 用户数据卡片
.user-card {
  background: $gradient-purple;
  color: white;

  .user-info {
    display: flex;
    align-items: center;
    gap: $spacing-3;
    margin-bottom: $spacing-4;

    .user-avatar {
      width: 48px;
      height: 48px;
      border-radius: 50%;
      background: rgba(255,255,255,0.2);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: $font-size-xl;
      font-weight: $font-weight-bold;
    }

    .credit-score {
      .label {
        display: block;
        font-size: $font-size-sm;
        opacity: 0.8;
      }
      .value {
        font-size: $font-size-4xl;
        font-weight: $font-weight-bold;
      }
    }
  }

  .user-stats {
    display: flex;
    gap: $spacing-6;

    .stat {
      .number {
        display: block;
        font-size: $font-size-xl;
        font-weight: $font-weight-bold;
      }
      .text {
        font-size: $font-size-sm;
        opacity: 0.8;
      }
    }
  }
}

// 计时器卡片
.timer-card {
  background: $gradient-dark;
  color: white;
  display: flex;
  align-items: center;
  justify-content: space-between;

  .timer-display {
    .time {
      display: block;
      font-size: $font-size-5xl;
      font-weight: $font-weight-bold;
      font-family: $font-mono;
      letter-spacing: 2px;
    }
    .status {
      font-size: $font-size-sm;
      opacity: 0.7;
    }
  }

  .timer-controls {
    display: flex;
    gap: $spacing-2;

    .control-btn {
      width: 48px;
      height: 48px;
      border-radius: 50%;
      border: none;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: $transition-fast;

      &.play {
        background: $success;
        color: white;
      }
      &.pause {
        background: $warning;
        color: white;
      }
      &.stop {
        background: $error;
        color: white;
      }

      &:hover {
        transform: scale(1.1);
      }
    }
  }
}

// 打卡卡片
.checkin-card {
  background: $gradient-orange;
  color: white;
  display: flex;
  align-items: center;
  gap: $spacing-3;

  .checkin-icon {
    opacity: 0.9;
  }

  .checkin-info {
    flex: 1;
    .label {
      display: block;
      font-size: $font-size-sm;
      opacity: 0.8;
    }
    .status {
      font-size: $font-size-lg;
      font-weight: $font-weight-bold;
    }
  }

  .arrow {
    opacity: 0.7;
  }
}

// 成就卡片
.achievements-card {
  .card-header {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    margin-bottom: $spacing-4;
    color: $text-primary;
    font-weight: $font-weight-semibold;

    .arrow {
      margin-left: auto;
      color: $text-muted;
    }
  }

  .achievement-list {
    display: flex;
    flex-direction: column;
    gap: $spacing-2;
  }

  .achievement-item {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    padding: $spacing-2 $spacing-3;
    background: $gray-50;
    border-radius: $radius-sm;

    .icon {
      font-size: $font-size-lg;
    }
    .name {
      font-size: $font-size-sm;
      color: $text-secondary;
    }

    &.rare {
      background: linear-gradient(135deg, #E3F2FD, #BBDEFB);
    }
    &.epic {
      background: linear-gradient(135deg, #F3E5F5, #E1BEE7);
    }
    &.legendary {
      background: linear-gradient(135deg, #FFF8E1, #FFECB3);
    }
  }
}

// 自习室卡片
.rooms-card {
  grid-column: span 2;

  .card-header {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    margin-bottom: $spacing-4;
    color: $text-primary;
    font-weight: $font-weight-semibold;

    .view-all {
      margin-left: auto;
      display: flex;
      align-items: center;
      gap: $spacing-1;
      background: none;
      border: none;
      color: $primary;
      font-size: $font-size-sm;
      cursor: pointer;

      &:hover {
        text-decoration: underline;
      }
    }
  }

  .room-list {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: $spacing-3;

    @media (max-width: 768px) {
      grid-template-columns: 1fr;
    }
  }

  .room-item {
    padding: $spacing-3;
    background: $gradient-seat-available;
    border-radius: $radius-sm;
    cursor: pointer;
    transition: $transition-fast;

    &:hover {
      transform: translateY(-2px);
      box-shadow: $shadow-sm;
    }

    .name {
      display: block;
      font-weight: $font-weight-medium;
      color: $text-primary;
      margin-bottom: $spacing-1;
    }
    .seats {
      font-size: $font-size-sm;
      color: $primary;
    }
  }
}

// 目标卡片
.goal-card {
  .card-header {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    margin-bottom: $spacing-4;
    color: $text-primary;
    font-weight: $font-weight-semibold;
  }

  .goal-progress {
    display: flex;
    align-items: center;
    gap: $spacing-3;

    .goal-icon {
      color: $primary;
    }

    .progress-text {
      .current {
        font-size: $font-size-3xl;
        font-weight: $font-weight-bold;
        color: $primary;
      }
      .divider {
        font-size: $font-size-lg;
        color: $text-muted;
      }
    }
  }
}

// 排行榜卡片
.ranking-card {
  .card-header {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    margin-bottom: $spacing-4;
    color: $text-primary;
    font-weight: $font-weight-semibold;

    .arrow {
      margin-left: auto;
      color: $text-muted;
    }
  }

  .ranking-list {
    display: flex;
    flex-direction: column;
    gap: $spacing-2;
  }

  .ranking-item {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    padding: $spacing-2 0;

    .rank {
      width: 24px;
      height: 24px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: $font-size-sm;
      font-weight: $font-weight-bold;
      background: $gray-200;
      color: $text-secondary;

      &.rank-1 {
        background: $gradient-rank-gold;
        color: white;
      }
      &.rank-2 {
        background: $gradient-rank-silver;
        color: white;
      }
      &.rank-3 {
        background: $gradient-rank-bronze;
        color: white;
      }
    }

    .avatar {
      width: 28px;
      height: 28px;
      border-radius: 50%;
      background: $primary-light;
      color: $primary;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: $font-size-sm;
      font-weight: $font-weight-medium;
    }

    .name {
      flex: 1;
      font-size: $font-size-sm;
      color: $text-primary;
    }

    .hours {
      font-size: $font-size-sm;
      font-weight: $font-weight-semibold;
      color: $primary;
    }
  }
}

.empty-tip {
  text-align: center;
  color: $text-muted;
  font-size: $font-size-sm;
  padding: $spacing-4 0;
}
</style>
