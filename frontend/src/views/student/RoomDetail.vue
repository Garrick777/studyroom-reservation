<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getRoomDetail, getRoomSeats, getAvailableTimeSlots, addFavorite, removeFavorite, type StudyRoom, type Seat, type TimeSlot } from '@/api/room'
import { createReservation, type CreateReservationParams } from '@/api/reservation'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  ArrowLeft, MapPin, Clock, Users, Star, Heart, Wifi, Zap, Coffee, 
  Monitor, ChevronLeft, ChevronRight, Calendar, Info, Check
} from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const roomId = Number(route.params.id)

const loading = ref(true)
const room = ref<StudyRoom | null>(null)
const seats = ref<Seat[]>([])
const timeSlots = ref<TimeSlot[]>([])

const selectedDate = ref(new Date().toISOString().split('T')[0])
const selectedTimeSlot = ref<number | null>(null)
const selectedSeat = ref<Seat | null>(null)

// 座位地图配置
const seatMap = computed(() => {
  if (!room.value || seats.value.length === 0) return []
  
  const map: (Seat | null)[][] = []
  for (let r = 1; r <= room.value.rowCount; r++) {
    const row: (Seat | null)[] = []
    for (let c = 1; c <= room.value.colCount; c++) {
      const seat = seats.value.find(s => s.rowNum === r && s.colNum === c)
      row.push(seat || null)
    }
    map.push(row)
  }
  return map
})

// 座位类型统计
const seatStats = computed(() => {
  const stats = { NORMAL: 0, WINDOW: 0, POWER: 0, VIP: 0 }
  seats.value.forEach(seat => {
    if (seat.seatType in stats) {
      stats[seat.seatType as keyof typeof stats]++
    }
  })
  return stats
})

// 设施图标映射
const facilityIcons: Record<string, any> = {
  '空调': Coffee,
  'WiFi': Wifi,
  '电源': Zap,
  '饮水机': Coffee,
  '电脑': Monitor,
  '打印机': Monitor,
  '投影仪': Monitor,
  '白板': Monitor,
}

onMounted(async () => {
  await loadRoom()
})

async function loadRoom() {
  loading.value = true
  try {
    const [roomData, seatsData, slotsData] = await Promise.all([
      getRoomDetail(roomId),
      getRoomSeats(roomId),
      getAvailableTimeSlots(roomId, selectedDate.value)
    ])
    room.value = roomData
    seats.value = seatsData
    timeSlots.value = slotsData
    
    // 默认选中第一个可用时段
    const firstAvailable = slotsData.find(s => s.available)
    if (firstAvailable) {
      selectedTimeSlot.value = firstAvailable.id
    }
  } catch (error) {
    ElMessage.error('加载自习室信息失败')
    router.push('/rooms')
  } finally {
    loading.value = false
  }
}

async function handleDateChange() {
  try {
    timeSlots.value = await getAvailableTimeSlots(roomId, selectedDate.value)
    selectedTimeSlot.value = null
    selectedSeat.value = null
  } catch (error) {
    ElMessage.error('加载时段失败')
  }
}

function selectTimeSlot(slot: TimeSlot) {
  if (!slot.available) return
  selectedTimeSlot.value = slot.id
  selectedSeat.value = null
}

function selectSeat(seat: Seat | null) {
  if (!seat || seat.status !== 1) return
  if (seat.currentStatus && seat.currentStatus !== 'AVAILABLE') return
  selectedSeat.value = selectedSeat.value?.id === seat.id ? null : seat
}

async function toggleFavorite() {
  if (!room.value) return
  try {
    if (room.value.isFavorite) {
      await removeFavorite(room.value.id)
      room.value.isFavorite = false
      ElMessage.success('已取消收藏')
    } else {
      await addFavorite(room.value.id)
      room.value.isFavorite = true
      ElMessage.success('收藏成功')
    }
  } catch (error) {
    // 错误已在拦截器处理
  }
}

const reserving = ref(false)

async function confirmReservation() {
  if (!selectedTimeSlot.value || !selectedSeat.value) {
    ElMessage.warning('请先选择时段和座位')
    return
  }
  
  const timeSlot = timeSlots.value.find(s => s.id === selectedTimeSlot.value)
  if (!timeSlot) {
    ElMessage.error('时段信息错误')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确认预约以下信息？
      
自习室：${room.value?.name}
座位号：${selectedSeat.value.seatNo}
日期：${selectedDate.value}
时段：${timeSlot.name} (${timeSlot.startTime}-${timeSlot.endTime})`,
      '确认预约',
      {
        confirmButtonText: '确认预约',
        cancelButtonText: '取消',
        type: 'info'
      }
    )

    reserving.value = true
    const params: CreateReservationParams = {
      roomId: roomId,
      seatId: selectedSeat.value.id,
      date: selectedDate.value,
      timeSlotId: selectedTimeSlot.value
    }

    const reservation = await createReservation(params)
    ElMessage.success(`预约成功！预约编号：${reservation.reservationNo}`)
    
    // 跳转到我的预约页面
    router.push('/reservations')
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('预约失败:', error)
    }
  } finally {
    reserving.value = false
  }
}

function getSeatClass(seat: Seat | null) {
  if (!seat) return 'seat-empty'
  if (seat.status !== 1) return 'seat-unavailable'
  
  const classes = ['seat', `seat-${seat.seatType.toLowerCase()}`]
  
  if (seat.currentStatus === 'RESERVED') classes.push('seat-reserved')
  else if (seat.currentStatus === 'IN_USE') classes.push('seat-in-use')
  else if (seat.currentStatus === 'LEAVING') classes.push('seat-leaving')
  else classes.push('seat-available')
  
  if (selectedSeat.value?.id === seat.id) classes.push('seat-selected')
  
  return classes.join(' ')
}

function goBack() {
  router.push('/rooms')
}
</script>

<template>
  <div class="room-detail-page">
    <!-- 返回按钮 -->
    <div class="back-header">
      <el-button text @click="goBack">
        <ArrowLeft :size="18" />
        返回列表
      </el-button>
    </div>

    <div v-if="loading" class="loading-state">
      <el-skeleton :rows="10" animated />
    </div>

    <template v-else-if="room">
      <!-- 自习室信息头 -->
      <div class="room-header">
        <div class="room-info">
          <div class="room-title">
            <h1>{{ room.name }}</h1>
            <el-tag type="success">开放中</el-tag>
          </div>
          <p class="room-code">{{ room.code }}</p>
          <p class="room-location">
            <MapPin :size="16" />
            {{ room.building }} {{ room.floor }} {{ room.roomNumber }}
          </p>
          <p class="room-time">
            <Clock :size="16" />
            {{ room.openTime }} - {{ room.closeTime }}
          </p>
          <div class="room-rating">
            <Star :size="18" fill="#FFD700" stroke="#FFD700" />
            <span class="score">{{ room.rating }}</span>
            <span class="count">({{ room.ratingCount }}人评价)</span>
          </div>
        </div>
        
        <div class="room-actions">
          <el-button 
            :type="room.isFavorite ? 'danger' : 'default'"
            @click="toggleFavorite"
          >
            <Heart :size="18" :fill="room.isFavorite ? '#fff' : 'none'" />
            {{ room.isFavorite ? '已收藏' : '收藏' }}
          </el-button>
        </div>
      </div>

      <!-- 设施标签 -->
      <div class="facilities-section">
        <h3>设施服务</h3>
        <div class="facilities-list">
          <div v-for="facility in room.facilities" :key="facility" class="facility-item">
            <component :is="facilityIcons[facility] || Info" :size="20" />
            <span>{{ facility }}</span>
          </div>
        </div>
      </div>

      <!-- 预约选择区 -->
      <div class="reservation-section">
        <div class="date-time-picker">
          <!-- 日期选择 -->
          <div class="picker-group">
            <h3>
              <Calendar :size="18" />
              选择日期
            </h3>
            <el-date-picker
              v-model="selectedDate"
              type="date"
              placeholder="选择日期"
              format="YYYY-MM-DD"
              value-format="YYYY-MM-DD"
              :disabled-date="(date: Date) => date < new Date(new Date().setHours(0,0,0,0))"
              @change="handleDateChange"
            />
          </div>

          <!-- 时段选择 -->
          <div class="picker-group">
            <h3>
              <Clock :size="18" />
              选择时段
            </h3>
            <div class="time-slots">
              <div
                v-for="slot in timeSlots"
                :key="slot.id"
                class="time-slot"
                :class="{ 
                  active: selectedTimeSlot === slot.id, 
                  disabled: !slot.available 
                }"
                @click="selectTimeSlot(slot)"
              >
                <span class="slot-name">{{ slot.name }}</span>
                <span class="slot-time">{{ slot.startTime }}-{{ slot.endTime }}</span>
                <span class="slot-seats" v-if="slot.available">
                  剩余 {{ slot.availableSeats }} 座
                </span>
                <span class="slot-seats" v-else>不可预约</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 座位选择 -->
        <div class="seat-picker">
          <div class="seat-header">
            <h3>
              <Users :size="18" />
              选择座位
            </h3>
            <div class="seat-legend">
              <span class="legend-item available">
                <span class="dot"></span> 空闲
              </span>
              <span class="legend-item reserved">
                <span class="dot"></span> 已预约
              </span>
              <span class="legend-item in-use">
                <span class="dot"></span> 使用中
              </span>
              <span class="legend-item selected">
                <span class="dot"></span> 已选择
              </span>
            </div>
          </div>

          <div class="seat-type-legend">
            <span class="type-item normal">普通</span>
            <span class="type-item window">靠窗</span>
            <span class="type-item power">电源</span>
            <span class="type-item vip">VIP</span>
          </div>

          <div class="seat-map-container">
            <div class="seat-map">
              <div class="platform">讲 台</div>
              <div 
                v-for="(row, rowIndex) in seatMap" 
                :key="rowIndex" 
                class="seat-row"
              >
                <span class="row-label">{{ rowIndex + 1 }}</span>
                <div
                  v-for="(seat, colIndex) in row"
                  :key="colIndex"
                  :class="getSeatClass(seat)"
                  @click="selectSeat(seat)"
                >
                  <span v-if="seat">{{ seat.seatNo.split('-')[1] }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 已选座位信息 -->
          <div v-if="selectedSeat" class="selected-info">
            <p>
              已选座位: <strong>{{ selectedSeat.seatNo }}</strong>
              <el-tag size="small" :type="selectedSeat.seatType === 'VIP' ? 'warning' : 'info'">
                {{ selectedSeat.seatType === 'NORMAL' ? '普通' : 
                   selectedSeat.seatType === 'WINDOW' ? '靠窗' :
                   selectedSeat.seatType === 'POWER' ? '电源' : 'VIP' }}座位
              </el-tag>
            </p>
          </div>
        </div>
      </div>

      <!-- 确认预约按钮 -->
      <div class="confirm-section">
        <el-button 
          type="primary" 
          size="large" 
          :disabled="!selectedTimeSlot || !selectedSeat"
          :loading="reserving"
          @click="confirmReservation"
        >
          <Check :size="18" v-if="!reserving" />
          {{ reserving ? '预约中...' : '确认预约' }}
        </el-button>
      </div>
    </template>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';
.room-detail-page {
  max-width: 1200px;
  margin: 0 auto;
  animation: fadeIn 0.5s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.back-header {
  margin-bottom: 20px;
  
  :deep(.el-button) {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
  }
}

.loading-state {
  padding: 40px;
  background: white;
  border-radius: $radius-lg;
}

.room-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 24px;
  background: white;
  border-radius: $radius-lg;
  box-shadow: $shadow-card;
  margin-bottom: 20px;
  
  .room-info {
    .room-title {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 8px;
      
      h1 {
        font-size: 24px;
        font-weight: 700;
        color: $text-primary;
      }
    }
    
    .room-code {
      color: $primary;
      font-weight: 500;
      margin-bottom: 12px;
    }
    
    .room-location,
    .room-time {
      display: flex;
      align-items: center;
      gap: 6px;
      color: $text-secondary;
      margin-bottom: 8px;
    }
    
    .room-rating {
      display: flex;
      align-items: center;
      gap: 6px;
      margin-top: 12px;
      
      .score {
        font-size: 18px;
        font-weight: 700;
        color: $text-primary;
      }
      
      .count {
        color: $text-muted;
        font-size: 14px;
      }
    }
  }
  
  .room-actions {
    :deep(.el-button) {
      display: flex;
      align-items: center;
      gap: 6px;
    }
  }
}

.facilities-section {
  padding: 24px;
  background: white;
  border-radius: $radius-lg;
  box-shadow: $shadow-card;
  margin-bottom: 20px;
  
  h3 {
    font-size: 16px;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 16px;
  }
  
  .facilities-list {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
  }
  
  .facility-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    background: $gray-50;
    border-radius: $radius-sm;
    color: $text-secondary;
    font-size: 14px;
  }
}

.reservation-section {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 20px;
  
  @media (max-width: 1024px) {
    grid-template-columns: 1fr;
  }
}

.date-time-picker {
  background: white;
  border-radius: $radius-lg;
  box-shadow: $shadow-card;
  padding: 24px;
  
  .picker-group {
    margin-bottom: 24px;
    
    &:last-child {
      margin-bottom: 0;
    }
    
    h3 {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 15px;
      font-weight: 600;
      color: $text-primary;
      margin-bottom: 12px;
    }
  }
  
  :deep(.el-date-editor) {
    width: 100%;
  }
}

.time-slots {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.time-slot {
  display: flex;
  flex-direction: column;
  padding: 12px;
  border: 2px solid $gray-200;
  border-radius: $radius-sm;
  cursor: pointer;
  transition: all 0.2s;
  
  &:hover:not(.disabled) {
    border-color: $primary;
  }
  
  &.active {
    border-color: $primary;
    background: $primary-50;
  }
  
  &.disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  .slot-name {
    font-weight: 600;
    color: $text-primary;
  }
  
  .slot-time {
    font-size: 13px;
    color: $text-secondary;
  }
  
  .slot-seats {
    font-size: 12px;
    color: $primary;
    margin-top: 4px;
  }
}

.seat-picker {
  background: white;
  border-radius: $radius-lg;
  box-shadow: $shadow-card;
  padding: 24px;
  
  .seat-header {
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
  }
  
  .seat-legend {
    display: flex;
    gap: 16px;
    font-size: 12px;
    
    .legend-item {
      display: flex;
      align-items: center;
      gap: 4px;
      color: $text-secondary;
      
      .dot {
        width: 12px;
        height: 12px;
        border-radius: 2px;
      }
      
      &.available .dot { background: $seat-available; border: 1px solid $primary; }
      &.reserved .dot { background: $seat-occupied; }
      &.in-use .dot { background: $seat-in-use; }
      &.selected .dot { background: $primary; }
    }
  }
  
  .seat-type-legend {
    display: flex;
    justify-content: center;
    gap: 16px;
    margin-bottom: 20px;
    font-size: 12px;
    
    .type-item {
      padding: 4px 12px;
      border-radius: 4px;
      
      &.normal { background: $gray-100; color: $text-secondary; }
      &.window { background: #E3F2FD; color: #1976D2; }
      &.power { background: #E8F5E9; color: #388E3C; }
      &.vip { background: #FFF8E1; color: #F57C00; }
    }
  }
}

.seat-map-container {
  overflow-x: auto;
  padding: 20px 0;
}

.seat-map {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: max-content;
  
  .platform {
    width: 200px;
    padding: 10px;
    background: $gray-200;
    text-align: center;
    border-radius: $radius-sm;
    margin-bottom: 24px;
    font-weight: 500;
    color: $text-secondary;
  }
  
  .seat-row {
    display: flex;
    align-items: center;
    gap: 6px;
    margin-bottom: 6px;
    
    .row-label {
      width: 24px;
      text-align: center;
      font-size: 12px;
      color: $text-muted;
    }
  }
}

.seat, .seat-empty {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  font-size: 10px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.seat-empty {
  background: transparent;
  cursor: default;
}

.seat-unavailable {
  background: $seat-unavailable;
  color: $text-disabled;
  cursor: not-allowed;
}

.seat-available {
  background: $seat-available;
  border: 1px solid $primary-300;
  color: $text-secondary;
  
  &:hover {
    background: $primary-100;
    transform: scale(1.1);
  }
}

.seat-reserved {
  background: $seat-occupied;
  color: #C62828;
  cursor: not-allowed;
}

.seat-in-use {
  background: $seat-in-use;
  color: #E65100;
  cursor: not-allowed;
}

.seat-leaving {
  background: $seat-leaving;
  color: #F57F17;
  cursor: not-allowed;
}

.seat-selected {
  background: $primary !important;
  color: white !important;
  transform: scale(1.1);
  box-shadow: 0 2px 8px rgba($primary, 0.4);
}

// 座位类型样式
.seat-window.seat-available {
  border-color: #1976D2;
  background: #E3F2FD;
}

.seat-power.seat-available {
  border-color: #388E3C;
  background: #E8F5E9;
}

.seat-vip.seat-available {
  border-color: #F57C00;
  background: #FFF8E1;
}

.selected-info {
  margin-top: 20px;
  padding: 16px;
  background: $primary-50;
  border-radius: $radius-sm;
  
  p {
    display: flex;
    align-items: center;
    gap: 8px;
    color: $text-secondary;
    
    strong {
      color: $primary;
      font-size: 16px;
    }
  }
}

.confirm-section {
  position: sticky;
  bottom: 20px;
  display: flex;
  justify-content: center;
  padding: 20px;
  background: white;
  border-radius: $radius-lg;
  box-shadow: $shadow-lg;
  margin-top: 20px;
  
  :deep(.el-button) {
    width: 200px;
    height: 48px;
    font-size: 16px;
  }
}
</style>
