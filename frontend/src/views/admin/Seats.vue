<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Armchair,
  RefreshCw,
  Filter,
  CheckSquare,
  Square,
  User,
  Clock,
  Zap,
  Wrench,
  Eye
} from 'lucide-vue-next'
import { getAdminRoomList, getSeatList, batchUpdateSeatStatus } from '@/api/admin-room'
import { getSeatsWithStatus } from '@/api/room'
import type { Room, Seat } from '@/types'

// 自习室列表
const rooms = ref<Room[]>([])
const selectedRoomId = ref<number | null>(null)
const selectedRoom = computed(() => rooms.value.find(r => r.id === selectedRoomId.value))

// 座位数据
const seats = ref<Seat[]>([])
const loading = ref(false)
const refreshing = ref(false)

// 选择模式
const selectionMode = ref(false)
const selectedSeatIds = ref<number[]>([])

// 座位详情弹窗
const showDetailDialog = ref(false)
const selectedSeat = ref<Seat | null>(null)

// 统计数据
const stats = computed(() => {
  const total = seats.value.length
  const available = seats.value.filter(s => s.status === 1 && (!s.currentStatus || s.currentStatus === 'AVAILABLE')).length
  const inUse = seats.value.filter(s => s.currentStatus === 'IN_USE' || s.currentStatus === 'RESERVED').length
  const leaving = seats.value.filter(s => s.currentStatus === 'LEAVING').length
  const disabled = seats.value.filter(s => s.status === 0 || s.status === 2).length
  return { total, available, inUse, leaving, disabled }
})

// 座位网格
const seatGrid = computed(() => {
  if (!selectedRoom.value || seats.value.length === 0) return []
  
  const maxRow = Math.max(...seats.value.map(s => s.rowNum || 1))
  const maxCol = Math.max(...seats.value.map(s => s.colNum || 1))
  
  const grid: (Seat | null)[][] = []
  for (let r = 1; r <= maxRow; r++) {
    const row: (Seat | null)[] = []
    for (let c = 1; c <= maxCol; c++) {
      const seat = seats.value.find(s => s.rowNum === r && s.colNum === c)
      row.push(seat || null)
    }
    grid.push(row)
  }
  return grid
})

// 加载自习室列表
const loadRooms = async () => {
  try {
    const res = await getAdminRoomList({ pageNum: 1, pageSize: 100 })
    rooms.value = res.records || []
    if (rooms.value.length > 0 && !selectedRoomId.value) {
      selectedRoomId.value = rooms.value[0].id
    }
  } catch (error) {
    console.error('加载自习室失败:', error)
  }
}

// 加载座位数据
const loadSeats = async () => {
  if (!selectedRoomId.value) return
  
  loading.value = true
  try {
    // 获取基础座位信息
    const baseSeats = await getSeatList(selectedRoomId.value)
    
    // 获取今日实时状态（使用本地日期）
    const now = new Date()
    const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
    try {
      const seatsWithStatus = await getSeatsWithStatus(selectedRoomId.value, today, 0)
      // 合并状态
      seats.value = baseSeats.map(seat => {
        const statusSeat = seatsWithStatus.find(s => s.id === seat.id)
        return {
          ...seat,
          currentStatus: statusSeat?.currentStatus || 'AVAILABLE'
        }
      })
    } catch {
      // 如果获取实时状态失败，使用基础数据
      seats.value = baseSeats.map(seat => ({
        ...seat,
        currentStatus: seat.status === 1 ? 'AVAILABLE' : 'UNAVAILABLE'
      }))
    }
  } catch (error) {
    console.error('加载座位失败:', error)
    ElMessage.error('加载座位数据失败')
  } finally {
    loading.value = false
  }
}

// 刷新数据
const refresh = async () => {
  refreshing.value = true
  await loadSeats()
  refreshing.value = false
}

// 自动刷新
let refreshTimer: ReturnType<typeof setInterval> | null = null

// 切换自习室
const handleRoomChange = () => {
  selectedSeatIds.value = []
  loadSeats()
}

// 获取座位状态样式
const getSeatClass = (seat: Seat | null) => {
  if (!seat) return 'empty'
  if (seat.status === 0 || seat.status === 2) return 'disabled'
  
  switch (seat.currentStatus) {
    case 'IN_USE':
    case 'RESERVED':
      return 'in-use'
    case 'LEAVING':
      return 'leaving'
    default:
      return 'available'
  }
}

// 获取座位类型标签
const getSeatTypeLabel = (type: string) => {
  const types: Record<string, string> = {
    'NORMAL': '普通',
    'WINDOW': '靠窗',
    'POWER': '电源',
    'VIP': 'VIP'
  }
  return types[type] || type
}

// 点击座位
const handleSeatClick = (seat: Seat | null) => {
  if (!seat) return
  
  if (selectionMode.value) {
    const index = selectedSeatIds.value.indexOf(seat.id)
    if (index > -1) {
      selectedSeatIds.value.splice(index, 1)
    } else {
      selectedSeatIds.value.push(seat.id)
    }
  } else {
    selectedSeat.value = seat
    showDetailDialog.value = true
  }
}

// 切换选择模式
const toggleSelectionMode = () => {
  selectionMode.value = !selectionMode.value
  if (!selectionMode.value) {
    selectedSeatIds.value = []
  }
}

// 全选/取消全选
const toggleSelectAll = () => {
  if (selectedSeatIds.value.length === seats.value.length) {
    selectedSeatIds.value = []
  } else {
    selectedSeatIds.value = seats.value.map(s => s.id)
  }
}

// 批量设置状态
const handleBatchStatus = async (status: number) => {
  if (selectedSeatIds.value.length === 0) {
    ElMessage.warning('请先选择座位')
    return
  }
  
  const statusText = status === 1 ? '启用' : status === 0 ? '禁用' : '维修中'
  
  try {
    await ElMessageBox.confirm(
      `确定要将选中的 ${selectedSeatIds.value.length} 个座位设为"${statusText}"吗？`,
      '批量操作确认',
      { type: 'warning' }
    )
    
    await batchUpdateSeatStatus(selectedRoomId.value!, selectedSeatIds.value, status)
    ElMessage.success('批量更新成功')
    selectedSeatIds.value = []
    selectionMode.value = false
    await loadSeats()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('批量更新失败')
    }
  }
}

// 单个座位设置状态
const handleSingleStatus = async (seat: Seat, status: number) => {
  try {
    await batchUpdateSeatStatus(selectedRoomId.value!, [seat.id], status)
    ElMessage.success('更新成功')
    showDetailDialog.value = false
    await loadSeats()
  } catch (error) {
    ElMessage.error('更新失败')
  }
}

onMounted(async () => {
  await loadRooms()
  if (selectedRoomId.value) {
    await loadSeats()
  }
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
  <div class="seats-monitor">
    <!-- 页头 -->
    <div class="page-header">
      <div class="header-left">
        <h1><Armchair :size="28" /> 座位监控</h1>
        <p>实时监控自习室座位使用情况</p>
      </div>
      <div class="header-right">
        <el-select 
          v-model="selectedRoomId" 
          placeholder="选择自习室"
          style="width: 200px"
          @change="handleRoomChange"
        >
          <el-option 
            v-for="room in rooms" 
            :key="room.id" 
            :label="room.name" 
            :value="room.id"
          />
        </el-select>
        <button class="action-btn" :class="{ active: selectionMode }" @click="toggleSelectionMode">
          <CheckSquare :size="18" />
          {{ selectionMode ? '取消选择' : '批量操作' }}
        </button>
        <button class="refresh-btn" @click="refresh" :disabled="refreshing">
          <RefreshCw :size="18" :class="{ spinning: refreshing }" />
          刷新
        </button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-row">
      <div class="stat-card total">
        <div class="stat-icon"><Armchair :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.total }}</span>
          <span class="stat-label">总座位</span>
        </div>
      </div>
      <div class="stat-card available">
        <div class="stat-icon"><Square :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.available }}</span>
          <span class="stat-label">空闲</span>
        </div>
      </div>
      <div class="stat-card in-use">
        <div class="stat-icon"><User :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.inUse }}</span>
          <span class="stat-label">使用中</span>
        </div>
      </div>
      <div class="stat-card leaving">
        <div class="stat-icon"><Clock :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.leaving }}</span>
          <span class="stat-label">暂离</span>
        </div>
      </div>
      <div class="stat-card disabled">
        <div class="stat-icon"><Wrench :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.disabled }}</span>
          <span class="stat-label">不可用</span>
        </div>
      </div>
    </div>

    <!-- 批量操作栏 -->
    <div v-if="selectionMode" class="batch-toolbar">
      <div class="selection-info">
        <button class="select-all-btn" @click="toggleSelectAll">
          {{ selectedSeatIds.length === seats.length ? '取消全选' : '全选' }}
        </button>
        <span>已选中 <strong>{{ selectedSeatIds.length }}</strong> 个座位</span>
      </div>
      <div class="batch-actions">
        <button class="batch-btn enable" @click="handleBatchStatus(1)">
          <Square :size="16" /> 设为可用
        </button>
        <button class="batch-btn disable" @click="handleBatchStatus(0)">
          <Wrench :size="16" /> 设为禁用
        </button>
        <button class="batch-btn repair" @click="handleBatchStatus(2)">
          <Wrench :size="16" /> 设为维修
        </button>
      </div>
    </div>

    <!-- 座位图例 -->
    <div class="legend">
      <div class="legend-item">
        <span class="legend-dot available"></span>
        <span>空闲</span>
      </div>
      <div class="legend-item">
        <span class="legend-dot in-use"></span>
        <span>使用中</span>
      </div>
      <div class="legend-item">
        <span class="legend-dot leaving"></span>
        <span>暂离</span>
      </div>
      <div class="legend-item">
        <span class="legend-dot disabled"></span>
        <span>不可用</span>
      </div>
    </div>

    <!-- 座位网格 -->
    <div class="seat-grid-container" v-loading="loading">
      <div v-if="selectedRoom" class="room-info">
        <h3>{{ selectedRoom.name }}</h3>
        <p>{{ selectedRoom.building }} {{ selectedRoom.floor }}</p>
      </div>

      <div v-if="seatGrid.length > 0" class="seat-grid">
        <div v-for="(row, rowIndex) in seatGrid" :key="rowIndex" class="seat-row">
          <div class="row-label">{{ rowIndex + 1 }}</div>
          <div 
            v-for="(seat, colIndex) in row" 
            :key="colIndex"
            :class="['seat', getSeatClass(seat), { 
              selected: seat && selectedSeatIds.includes(seat.id),
              'selection-mode': selectionMode
            }]"
            @click="handleSeatClick(seat)"
          >
            <template v-if="seat">
              <span class="seat-no">{{ seat.seatNo }}</span>
              <!-- 只显示电源座位标识 -->
              <div v-if="seat.seatType === 'POWER'" class="seat-badge power">
                <Zap :size="10" />
              </div>
              <div v-if="selectionMode && selectedSeatIds.includes(seat.id)" class="check-mark">✓</div>
            </template>
          </div>
        </div>
        
        <!-- 列标签 -->
        <div class="col-labels">
          <div class="row-label-placeholder"></div>
          <div v-for="col in (seatGrid[0]?.length || 0)" :key="col" class="col-label">
            {{ col }}
          </div>
        </div>
      </div>

      <div v-else-if="!loading" class="empty-state">
        <Armchair :size="48" />
        <p>该自习室暂无座位数据</p>
      </div>
    </div>

    <!-- 座位详情弹窗 -->
    <el-dialog 
      v-model="showDetailDialog" 
      title="座位详情" 
      width="400px"
      :close-on-click-modal="true"
    >
      <div v-if="selectedSeat" class="seat-detail">
        <div class="detail-header">
          <div :class="['seat-preview', getSeatClass(selectedSeat)]">
            {{ selectedSeat.seatNo }}
          </div>
          <div class="seat-basic">
            <h3>{{ selectedSeat.seatNo }}</h3>
            <span class="seat-type">{{ getSeatTypeLabel(selectedSeat.seatType) }}</span>
          </div>
        </div>

        <div class="detail-info">
          <div class="info-row">
            <span class="info-label">位置</span>
            <span class="info-value">第 {{ selectedSeat.rowNum }} 排 第 {{ selectedSeat.colNum }} 列</span>
          </div>
          <div class="info-row">
            <span class="info-label">基础状态</span>
            <span :class="['status-tag', selectedSeat.status === 1 ? 'active' : 'inactive']">
              {{ selectedSeat.status === 1 ? '可用' : selectedSeat.status === 2 ? '维修中' : '禁用' }}
            </span>
          </div>
          <div class="info-row">
            <span class="info-label">实时状态</span>
            <span :class="['status-tag', selectedSeat.currentStatus?.toLowerCase()]">
              {{ 
                selectedSeat.currentStatus === 'IN_USE' ? '使用中' :
                selectedSeat.currentStatus === 'RESERVED' ? '已预约' :
                selectedSeat.currentStatus === 'LEAVING' ? '暂离' :
                selectedSeat.currentStatus === 'UNAVAILABLE' ? '不可用' : '空闲'
              }}
            </span>
          </div>
        </div>

        <div class="detail-actions">
          <span class="action-label">设置状态：</span>
          <button 
            class="status-btn available" 
            :disabled="selectedSeat.status === 1"
            @click="handleSingleStatus(selectedSeat, 1)"
          >
            设为可用
          </button>
          <button 
            class="status-btn disabled" 
            :disabled="selectedSeat.status === 0"
            @click="handleSingleStatus(selectedSeat, 0)"
          >
            设为禁用
          </button>
          <button 
            class="status-btn repair" 
            :disabled="selectedSeat.status === 2"
            @click="handleSingleStatus(selectedSeat, 2)"
          >
            设为维修
          </button>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.seats-monitor {
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
      display: flex;
      align-items: center;
      gap: 8px;
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
    gap: 12px;
  }
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: white;
  border: 1px solid $gray-200;
  border-radius: $radius-sm;
  color: $text-secondary;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
  
  &:hover {
    color: $primary;
    border-color: $primary;
  }
  
  &.active {
    background: $primary;
    color: white;
    border-color: $primary;
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
  cursor: pointer;
  transition: all 0.2s;
  
  &:hover {
    color: $blue;
    border-color: $blue;
  }
  
  .spinning {
    animation: spin 1s linear infinite;
  }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.stats-row {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  background: white;
  border-radius: $radius-md;
  border-left: 4px solid;
  
  &.total {
    border-color: $primary;
    .stat-icon { color: $primary; background: $primary-light; }
  }
  &.available {
    border-color: $success;
    .stat-icon { color: $success; background: $success-light; }
  }
  &.in-use {
    border-color: $blue;
    .stat-icon { color: $blue; background: $blue-light; }
  }
  &.leaving {
    border-color: $warning;
    .stat-icon { color: $warning; background: $warning-light; }
  }
  &.disabled {
    border-color: $gray-400;
    .stat-icon { color: $gray-500; background: $gray-100; }
  }
  
  .stat-icon {
    width: 44px;
    height: 44px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .stat-info {
    display: flex;
    flex-direction: column;
    
    .stat-value {
      font-size: 24px;
      font-weight: 700;
      color: $text-primary;
    }
    
    .stat-label {
      font-size: 13px;
      color: $text-muted;
    }
  }
}

.batch-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: $blue-light;
  border: 1px solid rgba($blue, 0.2);
  border-radius: $radius-md;
  margin-bottom: 16px;
  
  .selection-info {
    display: flex;
    align-items: center;
    gap: 12px;
    color: $text-primary;
    
    strong { color: $blue; }
  }
  
  .select-all-btn {
    padding: 4px 12px;
    background: white;
    border: 1px solid $gray-200;
    border-radius: 4px;
    font-size: 13px;
    cursor: pointer;
    
    &:hover {
      border-color: $blue;
      color: $blue;
    }
  }
  
  .batch-actions {
    display: flex;
    gap: 8px;
  }
  
  .batch-btn {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 6px 12px;
    border-radius: 4px;
    font-size: 13px;
    cursor: pointer;
    transition: all 0.2s;
    
    &.enable {
      background: $success;
      color: white;
      border: none;
      &:hover { background: darken($success, 5%); }
    }
    &.disable {
      background: white;
      color: $gray-600;
      border: 1px solid $gray-300;
      &:hover { border-color: $gray-400; }
    }
    &.repair {
      background: $warning;
      color: white;
      border: none;
      &:hover { background: darken($warning, 5%); }
    }
  }
}

.legend {
  display: flex;
  gap: 24px;
  margin-bottom: 16px;
  padding: 12px 16px;
  background: white;
  border-radius: $radius-md;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: $text-secondary;
  
  .legend-dot {
    width: 16px;
    height: 16px;
    border-radius: 4px;
    
    &.available { background: $success-light; border: 2px solid $success; }
    &.in-use { background: $blue-light; border: 2px solid $blue; }
    &.leaving { background: $warning-light; border: 2px solid $warning; }
    &.disabled { background: $gray-200; border: 2px solid $gray-400; }
  }
}

.seat-grid-container {
  background: white;
  border-radius: $radius-lg;
  padding: 24px;
  min-height: 400px;
}

.room-info {
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid $gray-100;
  
  h3 {
    font-size: 18px;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 4px;
  }
  
  p {
    font-size: 13px;
    color: $text-muted;
  }
}

.seat-grid {
  display: inline-block;
}

.seat-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.row-label {
  width: 24px;
  text-align: center;
  font-size: 12px;
  color: $text-muted;
  flex-shrink: 0;
}

.col-labels {
  display: flex;
  gap: 8px;
  margin-top: 8px;
  margin-left: 32px; // 24px row-label + 8px gap
}

.row-label-placeholder {
  display: none; // 不需要占位符了
}

.col-label {
  width: 48px;
  text-align: center;
  font-size: 12px;
  color: $text-muted;
  flex-shrink: 0;
}

.seat {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  position: relative;
  transition: all 0.2s;
  border: 2px solid transparent;
  
  &.empty {
    background: transparent;
    cursor: default;
  }
  
  &.available {
    background: $success-light;
    border-color: $success;
    
    &:hover {
      transform: scale(1.05);
      box-shadow: 0 4px 12px rgba($success, 0.3);
    }
  }
  
  &.in-use {
    background: $blue-light;
    border-color: $blue;
    
    &:hover {
      transform: scale(1.05);
      box-shadow: 0 4px 12px rgba($blue, 0.3);
    }
  }
  
  &.leaving {
    background: $warning-light;
    border-color: $warning;
    
    &:hover {
      transform: scale(1.05);
      box-shadow: 0 4px 12px rgba($warning, 0.3);
    }
  }
  
  &.disabled {
    background: $gray-200;
    border-color: $gray-400;
    
    &:hover {
      transform: scale(1.05);
    }
  }
  
  &.selection-mode {
    cursor: pointer;
  }
  
  &.selected {
    box-shadow: 0 0 0 3px $primary;
  }
  
  .seat-no {
    font-size: 11px;
    font-weight: 600;
    color: $text-primary;
  }
  
  .seat-badge {
    position: absolute;
    top: 2px;
    right: 2px;
    width: 14px;
    height: 14px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    
    &.power {
      background: $warning;
      color: white;
    }
  }
  
  .check-mark {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 24px;
    height: 24px;
    background: $primary;
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: bold;
  }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px;
  color: $text-muted;
  
  p {
    margin-top: 12px;
    font-size: 14px;
  }
}

// 座位详情弹窗
.seat-detail {
  .detail-header {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-bottom: 20px;
    padding-bottom: 16px;
    border-bottom: 1px solid $gray-100;
  }
  
  .seat-preview {
    width: 64px;
    height: 64px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    font-weight: 700;
    border: 3px solid;
    
    &.available {
      background: $success-light;
      border-color: $success;
      color: $success;
    }
    &.in-use {
      background: $blue-light;
      border-color: $blue;
      color: $blue;
    }
    &.leaving {
      background: $warning-light;
      border-color: $warning;
      color: $warning;
    }
    &.disabled {
      background: $gray-200;
      border-color: $gray-400;
      color: $gray-500;
    }
  }
  
  .seat-basic {
    h3 {
      font-size: 20px;
      font-weight: 600;
      color: $text-primary;
      margin-bottom: 4px;
    }
    
    .seat-type {
      font-size: 13px;
      padding: 2px 8px;
      background: $gray-100;
      border-radius: 4px;
      color: $text-secondary;
    }
  }
}

.detail-info {
  margin-bottom: 20px;
  
  .info-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px solid $gray-50;
    
    &:last-child { border-bottom: none; }
  }
  
  .info-label {
    color: $text-muted;
    font-size: 14px;
  }
  
  .info-value {
    color: $text-primary;
    font-weight: 500;
  }
  
  .status-tag {
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 500;
    
    &.active { background: $success-light; color: $success; }
    &.inactive { background: $gray-100; color: $gray-500; }
    &.available { background: $success-light; color: $success; }
    &.in_use, &.reserved { background: $blue-light; color: $blue; }
    &.leaving { background: $warning-light; color: $warning; }
    &.unavailable { background: $gray-100; color: $gray-500; }
  }
}

.detail-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-top: 16px;
  border-top: 1px solid $gray-100;
  
  .action-label {
    font-size: 13px;
    color: $text-muted;
    margin-right: 8px;
  }
  
  .status-btn {
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 13px;
    cursor: pointer;
    transition: all 0.2s;
    
    &.available {
      background: $success-light;
      color: $success;
      border: 1px solid $success;
      
      &:hover:not(:disabled) { background: $success; color: white; }
    }
    
    &.disabled {
      background: $gray-100;
      color: $gray-600;
      border: 1px solid $gray-300;
      
      &:hover:not(:disabled) { background: $gray-200; }
    }
    
    &.repair {
      background: $warning-light;
      color: $warning;
      border: 1px solid $warning;
      
      &:hover:not(:disabled) { background: $warning; color: white; }
    }
    
    &:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
  }
}

// 响应式
@media (max-width: 1200px) {
  .stats-row {
    flex-wrap: wrap;
    
    .stat-card {
      flex: 1 1 calc(33.333% - 12px);
      min-width: 150px;
    }
  }
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
    
    .header-right {
      width: 100%;
      flex-wrap: wrap;
    }
  }
  
  .stats-row .stat-card {
    flex: 1 1 calc(50% - 8px);
  }
  
  .batch-toolbar {
    flex-direction: column;
    gap: 12px;
    
    .batch-actions {
      width: 100%;
      justify-content: center;
    }
  }
}
</style>
