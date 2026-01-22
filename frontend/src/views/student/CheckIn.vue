<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  CalendarCheck,
  Flame,
  Star,
  Zap,
  Gift,
  ChevronLeft,
  ChevronRight,
  Check
} from 'lucide-vue-next'
import {
  dailyCheckIn,
  getTodayStatus,
  getMonthCalendar,
  getCheckInStats,
  type TodayStatus,
  type MonthCalendar,
  type CheckInStats
} from '@/api/checkin'

// 今日状态
const todayStatus = ref<TodayStatus | null>(null)
const loading = ref(false)
const checkingIn = ref(false)

// 日历数据
const calendar = ref<MonthCalendar | null>(null)
const currentYear = ref(new Date().getFullYear())
const currentMonth = ref(new Date().getMonth() + 1)

// 统计数据
const stats = ref<CheckInStats | null>(null)

// 日历天数数组
const calendarDays = computed(() => {
  if (!calendar.value) return []
  
  const days = []
  const firstDay = new Date(calendar.value.year, calendar.value.month - 1, 1).getDay()
  const daysInMonth = calendar.value.daysInMonth
  
  // 填充前面的空白
  for (let i = 0; i < firstDay; i++) {
    days.push({ day: 0, checked: false, isToday: false })
  }
  
  // 填充日期
  const today = new Date()
  for (let i = 1; i <= daysInMonth; i++) {
    const isToday = calendar.value.year === today.getFullYear() 
      && calendar.value.month === today.getMonth() + 1 
      && i === today.getDate()
    days.push({
      day: i,
      checked: calendar.value.checkedDays.includes(i),
      isToday
    })
  }
  
  return days
})

// 月份显示
const monthDisplay = computed(() => {
  const months = ['一月', '二月', '三月', '四月', '五月', '六月',
                  '七月', '八月', '九月', '十月', '十一月', '十二月']
  return `${currentYear.value}年${months[currentMonth.value - 1]}`
})

// 加载今日状态
const loadTodayStatus = async () => {
  loading.value = true
  try {
    todayStatus.value = await getTodayStatus()
  } catch (error) {
    console.error('加载今日状态失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载日历
const loadCalendar = async () => {
  try {
    calendar.value = await getMonthCalendar(currentYear.value, currentMonth.value)
  } catch (error) {
    console.error('加载日历失败:', error)
  }
}

// 加载统计
const loadStats = async () => {
  try {
    stats.value = await getCheckInStats()
  } catch (error) {
    console.error('加载统计失败:', error)
  }
}

// 打卡
const handleCheckIn = async () => {
  if (todayStatus.value?.checkedIn) return
  
  checkingIn.value = true
  try {
    const record = await dailyCheckIn('WEB')
    ElMessage.success(`打卡成功！获得${record.earnedPoints}积分，${record.earnedExp}经验`)
    
    // 重新加载数据
    await Promise.all([loadTodayStatus(), loadCalendar(), loadStats()])
  } catch (error) {
    // 错误已在拦截器中处理
  } finally {
    checkingIn.value = false
  }
}

// 切换月份
const changeMonth = (delta: number) => {
  currentMonth.value += delta
  if (currentMonth.value > 12) {
    currentMonth.value = 1
    currentYear.value++
  } else if (currentMonth.value < 1) {
    currentMonth.value = 12
    currentYear.value--
  }
  loadCalendar()
}

onMounted(() => {
  loadTodayStatus()
  loadCalendar()
  loadStats()
})
</script>

<template>
  <div class="checkin-page">
    <!-- 打卡主区域 -->
    <div class="checkin-hero">
      <div class="hero-content">
        <div class="streak-badge" v-if="todayStatus?.continuousDays">
          <Flame :size="20" />
          <span>连续{{ todayStatus.continuousDays }}天</span>
        </div>
        
        <div 
          class="checkin-button"
          :class="{ checked: todayStatus?.checkedIn, checking: checkingIn }"
          @click="handleCheckIn"
        >
          <div class="button-inner">
            <Check v-if="todayStatus?.checkedIn" :size="48" />
            <CalendarCheck v-else :size="48" />
            <span class="button-text">
              {{ todayStatus?.checkedIn ? '已打卡' : '立即打卡' }}
            </span>
          </div>
          <div class="ripple" v-if="checkingIn"></div>
        </div>
        
        <div class="reward-preview" v-if="!todayStatus?.checkedIn && todayStatus">
          <span>打卡可获得</span>
          <span class="reward">
            <Star :size="14" /> {{ todayStatus.expectedPoints || 5 }}积分
          </span>
          <span class="reward">
            <Zap :size="14" /> {{ todayStatus.expectedExp || 10 }}经验
          </span>
        </div>
        
        <div class="check-result" v-else-if="todayStatus?.checkedIn">
          <span>今日已获得</span>
          <span class="reward earned">
            <Star :size="14" /> {{ todayStatus.earnedPoints }}积分
          </span>
          <span class="reward earned">
            <Zap :size="14" /> {{ todayStatus.earnedExp }}经验
          </span>
        </div>
      </div>
    </div>
    
    <!-- 统计卡片 -->
    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-icon total">
          <CalendarCheck :size="24" />
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats?.totalDays || 0 }}</span>
          <span class="stat-label">累计打卡</span>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon streak">
          <Flame :size="24" />
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats?.maxContinuousDays || 0 }}</span>
          <span class="stat-label">最长连续</span>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon points">
          <Star :size="24" />
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats?.totalPoints || 0 }}</span>
          <span class="stat-label">获得积分</span>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon exp">
          <Zap :size="24" />
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats?.totalExp || 0 }}</span>
          <span class="stat-label">获得经验</span>
        </div>
      </div>
    </div>
    
    <!-- 打卡日历 -->
    <div class="calendar-card">
      <div class="calendar-header">
        <button class="nav-btn" @click="changeMonth(-1)">
          <ChevronLeft :size="20" />
        </button>
        <span class="month-title">{{ monthDisplay }}</span>
        <button class="nav-btn" @click="changeMonth(1)">
          <ChevronRight :size="20" />
        </button>
      </div>
      
      <div class="calendar-weekdays">
        <span v-for="day in ['日', '一', '二', '三', '四', '五', '六']" :key="day">
          {{ day }}
        </span>
      </div>
      
      <div class="calendar-grid">
        <div
          v-for="(item, index) in calendarDays"
          :key="index"
          class="calendar-day"
          :class="{
            empty: item.day === 0,
            checked: item.checked,
            today: item.isToday
          }"
        >
          <span v-if="item.day > 0">{{ item.day }}</span>
          <Check v-if="item.checked" :size="12" class="check-icon" />
        </div>
      </div>
      
      <div class="calendar-footer" v-if="calendar">
        <span>本月打卡 <strong>{{ calendar.totalDays }}</strong> 天</span>
        <span>获得 <strong>{{ calendar.totalPoints }}</strong> 积分</span>
        <span>获得 <strong>{{ calendar.totalExp }}</strong> 经验</span>
      </div>
    </div>
    
    <!-- 连续打卡奖励说明 -->
    <div class="bonus-card">
      <div class="bonus-header">
        <Gift :size="20" />
        <span>连续打卡奖励</span>
      </div>
      <div class="bonus-list">
        <div class="bonus-item">
          <span class="days">3天</span>
          <span class="bonus">+2积分 +5经验</span>
        </div>
        <div class="bonus-item">
          <span class="days">7天</span>
          <span class="bonus">+5积分 +15经验</span>
        </div>
        <div class="bonus-item">
          <span class="days">14天</span>
          <span class="bonus">+10积分 +25经验</span>
        </div>
        <div class="bonus-item highlight">
          <span class="days">30天</span>
          <span class="bonus">+20积分 +50经验</span>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.checkin-page {
  max-width: 800px;
  margin: 0 auto;
}

.checkin-hero {
  background: $gradient-hero;
  border-radius: $radius-xl;
  padding: $spacing-10 $spacing-6;
  margin-bottom: $spacing-6;
  text-align: center;
  
  .hero-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: $spacing-4;
  }
  
  .streak-badge {
    display: inline-flex;
    align-items: center;
    gap: $spacing-2;
    padding: $spacing-2 $spacing-4;
    background: rgba(255, 255, 255, 0.2);
    border-radius: $radius-full;
    color: white;
    font-size: $font-size-sm;
    font-weight: $font-weight-medium;
  }
  
  .checkin-button {
    width: 160px;
    height: 160px;
    border-radius: $radius-full;
    background: white;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    position: relative;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
    transition: all 0.3s ease;
    
    &:hover:not(.checked) {
      transform: scale(1.05);
      box-shadow: 0 12px 40px rgba(0, 0, 0, 0.25);
    }
    
    &.checked {
      background: $success;
      cursor: default;
      
      .button-inner {
        color: white;
      }
    }
    
    &.checking {
      pointer-events: none;
    }
    
    .button-inner {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: $spacing-2;
      color: $primary;
      
      .button-text {
        font-size: $font-size-md;
        font-weight: $font-weight-bold;
      }
    }
    
    .ripple {
      position: absolute;
      inset: 0;
      border-radius: $radius-full;
      border: 3px solid white;
      animation: ripple 1s ease-out infinite;
    }
  }
  
  .reward-preview, .check-result {
    display: flex;
    align-items: center;
    gap: $spacing-3;
    color: rgba(255, 255, 255, 0.9);
    font-size: $font-size-sm;
    
    .reward {
      display: flex;
      align-items: center;
      gap: $spacing-1;
      background: rgba(255, 255, 255, 0.2);
      padding: $spacing-1 $spacing-2;
      border-radius: $radius-sm;
      
      &.earned {
        background: rgba(255, 255, 255, 0.3);
        color: white;
      }
    }
  }
}

@keyframes ripple {
  0% {
    transform: scale(1);
    opacity: 1;
  }
  100% {
    transform: scale(1.5);
    opacity: 0;
  }
}

.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: $spacing-4;
  margin-bottom: $spacing-6;
  
  @media (max-width: 768px) {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .stat-card {
    background: white;
    border-radius: $radius-lg;
    padding: $spacing-4;
    display: flex;
    align-items: center;
    gap: $spacing-3;
    
    .stat-icon {
      width: 48px;
      height: 48px;
      border-radius: $radius-md;
      display: flex;
      align-items: center;
      justify-content: center;
      
      &.total { background: $primary-light; color: $primary; }
      &.streak { background: #FEE2E2; color: #EF4444; }
      &.points { background: $accent-light; color: #F59E0B; }
      &.exp { background: $purple-light; color: $purple; }
    }
    
    .stat-info {
      display: flex;
      flex-direction: column;
      
      .stat-value {
        font-size: $font-size-xl;
        font-weight: $font-weight-bold;
        color: $text-primary;
      }
      
      .stat-label {
        font-size: $font-size-sm;
        color: $text-muted;
      }
    }
  }
}

.calendar-card {
  background: white;
  border-radius: $radius-lg;
  padding: $spacing-6;
  margin-bottom: $spacing-6;
  
  .calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: $spacing-4;
    
    .nav-btn {
      width: 36px;
      height: 36px;
      border-radius: $radius-sm;
      display: flex;
      align-items: center;
      justify-content: center;
      color: $text-secondary;
      transition: all 0.2s;
      
      &:hover {
        background: $gray-100;
        color: $primary;
      }
    }
    
    .month-title {
      font-size: $font-size-lg;
      font-weight: $font-weight-semibold;
      color: $text-primary;
    }
  }
  
  .calendar-weekdays {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    text-align: center;
    margin-bottom: $spacing-2;
    
    span {
      padding: $spacing-2;
      font-size: $font-size-sm;
      color: $text-muted;
    }
  }
  
  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: $spacing-1;
    
    .calendar-day {
      aspect-ratio: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      border-radius: $radius-sm;
      font-size: $font-size-sm;
      color: $text-primary;
      position: relative;
      
      &.empty {
        visibility: hidden;
      }
      
      &.today {
        background: $primary-light;
        color: $primary;
        font-weight: $font-weight-bold;
      }
      
      &.checked {
        background: $success-light;
        color: $success;
        
        .check-icon {
          position: absolute;
          bottom: 2px;
        }
      }
    }
  }
  
  .calendar-footer {
    display: flex;
    justify-content: center;
    gap: $spacing-6;
    margin-top: $spacing-4;
    padding-top: $spacing-4;
    border-top: 1px solid $border-light;
    font-size: $font-size-sm;
    color: $text-secondary;
    
    strong {
      color: $primary;
      font-weight: $font-weight-semibold;
    }
  }
}

.bonus-card {
  background: white;
  border-radius: $radius-lg;
  padding: $spacing-6;
  
  .bonus-header {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    margin-bottom: $spacing-4;
    color: $text-primary;
    font-weight: $font-weight-semibold;
  }
  
  .bonus-list {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: $spacing-3;
    
    @media (max-width: 768px) {
      grid-template-columns: repeat(2, 1fr);
    }
    
    .bonus-item {
      padding: $spacing-3;
      background: $gray-50;
      border-radius: $radius-sm;
      text-align: center;
      
      &.highlight {
        background: $accent-light;
        
        .days {
          color: #F59E0B;
        }
      }
      
      .days {
        display: block;
        font-weight: $font-weight-bold;
        color: $primary;
        margin-bottom: $spacing-1;
      }
      
      .bonus {
        font-size: $font-size-sm;
        color: $text-muted;
      }
    }
  }
}
</style>
