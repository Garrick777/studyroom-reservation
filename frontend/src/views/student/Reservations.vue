<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { 
  getMyReservations, getCurrentReservation, signIn, signOut, 
  leave, returnFromLeave, cancelReservation,
  type ReservationVO 
} from '@/api/reservation'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Calendar, Clock, MapPin, Armchair, Play, Square, Coffee, X,
  ChevronRight, AlertCircle, CheckCircle, XCircle, Hourglass
} from 'lucide-vue-next'

const router = useRouter()
const loading = ref(false)
const activeTab = ref('active')

const currentReservation = ref<ReservationVO | null>(null)
const reservations = ref<ReservationVO[]>([])
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(10)

// 状态配置
const statusConfig: Record<string, { color: string, icon: any, bgColor: string }> = {
  PENDING: { color: '#FFCB2F', icon: Hourglass, bgColor: '#FFF8E1' },
  SIGNED_IN: { color: '#3FB19E', icon: Play, bgColor: '#E8F5F3' },
  LEAVING: { color: '#FF7A45', icon: Coffee, bgColor: '#FFF3E0' },
  COMPLETED: { color: '#4A9FFF', icon: CheckCircle, bgColor: '#E3F2FD' },
  CANCELLED: { color: '#9CA3AF', icon: XCircle, bgColor: '#F4F5F7' },
  NO_SHOW: { color: '#FF4D4F', icon: AlertCircle, bgColor: '#FEE2E2' },
  VIOLATION: { color: '#FF4D4F', icon: AlertCircle, bgColor: '#FEE2E2' }
}

onMounted(() => {
  loadCurrentReservation()
  loadReservations()
})

async function loadCurrentReservation() {
  try {
    currentReservation.value = await getCurrentReservation()
  } catch (error) {
    console.error('获取当前预约失败:', error)
  }
}

async function loadReservations() {
  loading.value = true
  try {
    const status = activeTab.value === 'active' ? 'ACTIVE' : 'HISTORY'
    const result = await getMyReservations({
      status,
      pageNum: pageNum.value,
      pageSize: pageSize.value
    })
    reservations.value = result.records
    total.value = result.total
  } catch (error) {
    ElMessage.error('加载预约列表失败')
  } finally {
    loading.value = false
  }
}

function handleTabChange() {
  pageNum.value = 1
  loadReservations()
}

function handlePageChange(page: number) {
  pageNum.value = page
  loadReservations()
}

// 签到
async function handleSignIn(reservation: ReservationVO) {
  try {
    await ElMessageBox.confirm('确认签到？', '签到确认', { type: 'info' })
    await signIn(reservation.id)
    ElMessage.success('签到成功！')
    loadCurrentReservation()
    loadReservations()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '签到失败')
    }
  }
}

// 签退
async function handleSignOut(reservation: ReservationVO) {
  try {
    await ElMessageBox.confirm('确认签退？学习时长将被记录。', '签退确认', { type: 'info' })
    await signOut(reservation.id)
    ElMessage.success('签退成功！')
    loadCurrentReservation()
    loadReservations()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '签退失败')
    }
  }
}

// 暂离
async function handleLeave(reservation: ReservationVO) {
  try {
    await ElMessageBox.confirm(
      '暂离后请在30分钟内返回，否则预约将自动结束并扣除信用分。',
      '暂离提醒',
      { type: 'warning', confirmButtonText: '确认暂离', cancelButtonText: '取消' }
    )
    await leave(reservation.id)
    ElMessage.success('已标记暂离，请在30分钟内返回')
    loadCurrentReservation()
    loadReservations()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '暂离失败')
    }
  }
}

// 返回
async function handleReturn(reservation: ReservationVO) {
  try {
    await returnFromLeave(reservation.id)
    ElMessage.success('欢迎回来！')
    loadCurrentReservation()
    loadReservations()
  } catch (error: any) {
    ElMessage.error(error.message || '返回失败')
  }
}

// 取消预约
async function handleCancel(reservation: ReservationVO) {
  try {
    const { value: reason } = await ElMessageBox.prompt(
      '取消原因（选填）',
      '取消预约',
      { confirmButtonText: '确认取消', cancelButtonText: '返回', type: 'warning' }
    )
    await cancelReservation(reservation.id, reason || undefined)
    ElMessage.success('预约已取消')
    loadReservations()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '取消失败')
    }
  }
}

function goToRoom(roomId: number) {
  router.push(`/rooms/${roomId}`)
}

function formatTime(time: string | null) {
  if (!time) return '-'
  return new Date(time).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

function formatDuration(minutes: number | null) {
  if (!minutes) return '-'
  const h = Math.floor(minutes / 60)
  const m = minutes % 60
  return h > 0 ? `${h}小时${m > 0 ? m + '分钟' : ''}` : `${m}分钟`
}
</script>

<template>
  <div class="reservations-page">
    <!-- 当前预约卡片 -->
    <div v-if="currentReservation" class="current-reservation">
      <div class="current-header">
        <span class="current-label">当前预约</span>
        <el-tag :color="statusConfig[currentReservation.status]?.bgColor" 
                :style="{ color: statusConfig[currentReservation.status]?.color, border: 'none' }">
          {{ currentReservation.statusText }}
        </el-tag>
      </div>
      
      <div class="current-content">
        <div class="current-info">
          <h3>{{ currentReservation.roomName }}</h3>
          <div class="info-row">
            <MapPin :size="16" />
            <span>{{ currentReservation.roomLocation }}</span>
          </div>
          <div class="info-row">
            <Armchair :size="16" />
            <span>座位 {{ currentReservation.seatNo }}</span>
          </div>
          <div class="info-row">
            <Clock :size="16" />
            <span>{{ currentReservation.timeSlotName }}</span>
          </div>
        </div>
        
        <div class="current-actions">
          <el-button v-if="currentReservation.canSignIn" type="success" @click="handleSignIn(currentReservation)">
            <Play :size="18" /> 签到
          </el-button>
          <el-button v-if="currentReservation.canSignOut" type="primary" @click="handleSignOut(currentReservation)">
            <Square :size="18" /> 签退
          </el-button>
          <el-button v-if="currentReservation.canLeave" type="warning" @click="handleLeave(currentReservation)">
            <Coffee :size="18" /> 暂离
          </el-button>
          <el-button v-if="currentReservation.canReturn" type="success" @click="handleReturn(currentReservation)">
            <Play :size="18" /> 返回
          </el-button>
          <el-button v-if="currentReservation.canCancel" type="danger" plain @click="handleCancel(currentReservation)">
            <X :size="18" /> 取消
          </el-button>
        </div>
      </div>
    </div>

    <!-- 预约列表 -->
    <div class="reservations-list">
      <div class="list-header">
        <el-tabs v-model="activeTab" @tab-change="handleTabChange">
          <el-tab-pane label="进行中" name="active" />
          <el-tab-pane label="历史记录" name="history" />
        </el-tabs>
      </div>

      <div v-loading="loading" class="list-content">
        <template v-if="reservations.length > 0">
          <div v-for="item in reservations" :key="item.id" class="reservation-card">
            <div class="card-left">
              <div class="date-box">
                <span class="day">{{ new Date(item.date).getDate() }}</span>
                <span class="month">{{ new Date(item.date).getMonth() + 1 }}月</span>
              </div>
            </div>
            
            <div class="card-main">
              <div class="card-header">
                <h4>{{ item.roomName }}</h4>
                <el-tag size="small" 
                        :color="statusConfig[item.status]?.bgColor"
                        :style="{ color: statusConfig[item.status]?.color, border: 'none' }">
                  {{ item.statusText }}
                </el-tag>
              </div>
              
              <div class="card-info">
                <span><MapPin :size="14" /> {{ item.roomLocation }}</span>
                <span><Armchair :size="14" /> {{ item.seatNo }}</span>
                <span><Clock :size="14" /> {{ item.timeSlotName }}</span>
              </div>
              
              <div v-if="item.actualDuration" class="card-stats">
                <span>学习时长: {{ formatDuration(item.actualDuration) }}</span>
                <span v-if="item.earnedPoints > 0">获得积分: +{{ item.earnedPoints }}</span>
              </div>
            </div>
            
            <div class="card-actions">
              <el-button v-if="item.canSignIn" type="success" size="small" @click="handleSignIn(item)">签到</el-button>
              <el-button v-if="item.canSignOut" type="primary" size="small" @click="handleSignOut(item)">签退</el-button>
              <el-button v-if="item.canLeave" type="warning" size="small" @click="handleLeave(item)">暂离</el-button>
              <el-button v-if="item.canReturn" type="success" size="small" @click="handleReturn(item)">返回</el-button>
              <el-button v-if="item.canCancel" type="danger" size="small" plain @click="handleCancel(item)">取消</el-button>
              <el-button type="default" size="small" @click="goToRoom(item.roomId)">
                查看 <ChevronRight :size="14" />
              </el-button>
            </div>
          </div>
        </template>
        
        <el-empty v-else :description="activeTab === 'active' ? '暂无进行中的预约' : '暂无历史记录'" />
      </div>

      <div v-if="total > pageSize" class="list-pagination">
        <el-pagination
          v-model:current-page="pageNum"
          :page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          @current-change="handlePageChange"
        />
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.reservations-page {
  max-width: 900px;
  margin: 0 auto;
}

.current-reservation {
  background: linear-gradient(135deg, $primary 0%, #2DD4BF 100%);
  border-radius: $radius-lg;
  padding: $spacing-5;
  color: white;
  margin-bottom: $spacing-6;
  
  .current-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: $spacing-4;
    
    .current-label {
      font-size: $font-size-sm;
      opacity: 0.9;
    }
  }
  
  .current-content {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
    gap: $spacing-4;
    
    @media (max-width: 640px) {
      flex-direction: column;
      align-items: stretch;
    }
  }
  
  .current-info {
    h3 {
      font-size: $font-size-xl;
      font-weight: $font-weight-bold;
      margin-bottom: $spacing-2;
    }
    
    .info-row {
      display: flex;
      align-items: center;
      gap: $spacing-2;
      font-size: $font-size-sm;
      opacity: 0.9;
      margin-bottom: $spacing-1;
    }
  }
  
  .current-actions {
    display: flex;
    gap: $spacing-2;
    flex-wrap: wrap;
    
    .el-button {
      display: flex;
      align-items: center;
      gap: 4px;
    }
  }
}

.reservations-list {
  background: white;
  border-radius: $radius-lg;
  overflow: hidden;
  
  .list-header {
    padding: 0 $spacing-4;
    border-bottom: 1px solid $gray-100;
    
    :deep(.el-tabs__nav-wrap::after) {
      display: none;
    }
    
    :deep(.el-tabs__item) {
      font-weight: $font-weight-medium;
    }
    
    :deep(.el-tabs__item.is-active) {
      color: $primary;
    }
    
    :deep(.el-tabs__active-bar) {
      background-color: $primary;
    }
  }
  
  .list-content {
    min-height: 300px;
    padding: $spacing-4;
  }
  
  .list-pagination {
    padding: $spacing-4;
    display: flex;
    justify-content: center;
    border-top: 1px solid $gray-100;
  }
}

.reservation-card {
  display: flex;
  align-items: stretch;
  gap: $spacing-4;
  padding: $spacing-4;
  background: $gray-50;
  border-radius: $radius-md;
  margin-bottom: $spacing-3;
  transition: $transition-normal;
  
  &:hover {
    background: $gray-100;
  }
  
  @media (max-width: 640px) {
    flex-direction: column;
  }
  
  .card-left {
    .date-box {
      width: 60px;
      height: 60px;
      background: white;
      border-radius: $radius-sm;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      box-shadow: $shadow-xs;
      
      .day {
        font-size: $font-size-2xl;
        font-weight: $font-weight-bold;
        color: $primary;
        line-height: 1;
      }
      
      .month {
        font-size: $font-size-xs;
        color: $text-muted;
      }
    }
  }
  
  .card-main {
    flex: 1;
    
    .card-header {
      display: flex;
      align-items: center;
      gap: $spacing-2;
      margin-bottom: $spacing-2;
      
      h4 {
        font-size: $font-size-md;
        font-weight: $font-weight-semibold;
        color: $text-primary;
        margin: 0;
      }
    }
    
    .card-info {
      display: flex;
      flex-wrap: wrap;
      gap: $spacing-4;
      font-size: $font-size-sm;
      color: $text-secondary;
      margin-bottom: $spacing-2;
      
      span {
        display: flex;
        align-items: center;
        gap: 4px;
      }
    }
    
    .card-stats {
      display: flex;
      gap: $spacing-4;
      font-size: $font-size-sm;
      color: $primary;
    }
  }
  
  .card-actions {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    flex-wrap: wrap;
    
    @media (max-width: 640px) {
      justify-content: flex-end;
    }
  }
}
</style>
