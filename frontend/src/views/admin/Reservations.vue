<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getAdminReservations, getAdminReservationStats, type ReservationVO } from '@/api/reservation'
import { getRoomList } from '@/api/room'
import { ElMessage } from 'element-plus'
import {
  Calendar, Search, RefreshCw, Users, Clock, CheckCircle, XCircle, AlertTriangle
} from 'lucide-vue-next'

const loading = ref(false)
const reservations = ref<ReservationVO[]>([])
const total = ref(0)
const rooms = ref<{ id: number, name: string }[]>([])

// 查询参数
const query = ref({
  roomId: undefined as number | undefined,
  status: '',
  startDate: '',
  endDate: '',
  keyword: '',
  pageNum: 1,
  pageSize: 20
})

// 今日统计
const stats = ref({
  total: 0,
  pending: 0,
  inUse: 0,
  completed: 0,
  cancelled: 0,
  noShow: 0
})

// 状态选项
const statusOptions = [
  { label: '全部', value: '' },
  { label: '待签到', value: 'PENDING' },
  { label: '使用中', value: 'SIGNED_IN' },
  { label: '暂离', value: 'LEAVING' },
  { label: '已完成', value: 'COMPLETED' },
  { label: '已取消', value: 'CANCELLED' },
  { label: '爽约', value: 'NO_SHOW' },
  { label: '违约', value: 'VIOLATION' }
]

// 状态样式
const statusType = (status: string) => {
  const map: Record<string, string> = {
    PENDING: 'warning',
    SIGNED_IN: 'success',
    LEAVING: 'warning',
    COMPLETED: 'info',
    CANCELLED: '',
    NO_SHOW: 'danger',
    VIOLATION: 'danger'
  }
  return map[status] || ''
}

onMounted(async () => {
  await Promise.all([loadRooms(), loadStats(), loadReservations()])
})

async function loadRooms() {
  try {
    const result = await getRoomList({ pageSize: 100 })
    rooms.value = result.records.map((r: any) => ({ id: r.id, name: r.name }))
  } catch (error) {
    console.error('加载自习室列表失败:', error)
  }
}

async function loadStats() {
  try {
    const data = await getAdminReservationStats()
    stats.value = {
      total: data.total,
      pending: data.pending,
      inUse: data.inUse,
      completed: data.completed,
      cancelled: data.cancelled,
      noShow: data.noShow
    }
  } catch (error) {
    console.error('加载统计失败:', error)
  }
}

async function loadReservations() {
  loading.value = true
  try {
    const result = await getAdminReservations({
      ...query.value,
      status: query.value.status || undefined
    })
    reservations.value = result.records
    total.value = result.total
  } catch (error) {
    ElMessage.error('加载预约列表失败')
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  query.value.pageNum = 1
  loadReservations()
}

function handleReset() {
  query.value = {
    roomId: undefined,
    status: '',
    startDate: '',
    endDate: '',
    keyword: '',
    pageNum: 1,
    pageSize: 20
  }
  loadReservations()
}

function handlePageChange(page: number) {
  query.value.pageNum = page
  loadReservations()
}

function formatDateTime(dt: string | null) {
  if (!dt) return '-'
  return new Date(dt).toLocaleString('zh-CN')
}
</script>

<template>
  <div class="admin-reservations">
    <h2 class="page-title">预约管理</h2>

    <!-- 今日统计 -->
    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-icon total"><Calendar :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.total }}</span>
          <span class="stat-label">今日预约</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon pending"><Clock :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.pending }}</span>
          <span class="stat-label">待签到</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon active"><Users :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.inUse }}</span>
          <span class="stat-label">使用中</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon completed"><CheckCircle :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.completed }}</span>
          <span class="stat-label">已完成</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon cancelled"><XCircle :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.cancelled }}</span>
          <span class="stat-label">已取消</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon noshow"><AlertTriangle :size="24" /></div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.noShow }}</span>
          <span class="stat-label">爽约</span>
        </div>
      </div>
    </div>

    <!-- 搜索筛选 -->
    <div class="search-bar">
      <el-select v-model="query.roomId" placeholder="选择自习室" clearable style="width: 180px">
        <el-option v-for="room in rooms" :key="room.id" :label="room.name" :value="room.id" />
      </el-select>
      
      <el-select v-model="query.status" placeholder="预约状态" clearable style="width: 120px">
        <el-option v-for="opt in statusOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
      </el-select>
      
      <el-date-picker
        v-model="query.startDate"
        type="date"
        placeholder="开始日期"
        value-format="YYYY-MM-DD"
        style="width: 150px"
      />
      
      <el-date-picker
        v-model="query.endDate"
        type="date"
        placeholder="结束日期"
        value-format="YYYY-MM-DD"
        style="width: 150px"
      />
      
      <el-button type="primary" @click="handleSearch">
        <Search :size="16" /> 搜索
      </el-button>
      
      <el-button @click="handleReset">
        <RefreshCw :size="16" /> 重置
      </el-button>
    </div>

    <!-- 预约列表 -->
    <el-table v-loading="loading" :data="reservations" stripe>
      <el-table-column prop="reservationNo" label="预约编号" width="160" />
      <el-table-column prop="userName" label="用户" width="100" />
      <el-table-column prop="roomName" label="自习室" width="150" />
      <el-table-column prop="seatNo" label="座位" width="80" />
      <el-table-column prop="date" label="日期" width="110" />
      <el-table-column prop="timeSlotName" label="时段" width="140" />
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-tag :type="statusType(row.status)" size="small">{{ row.statusText }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="签到时间" width="160">
        <template #default="{ row }">{{ formatDateTime(row.signInTime) }}</template>
      </el-table-column>
      <el-table-column label="签退时间" width="160">
        <template #default="{ row }">{{ formatDateTime(row.signOutTime) }}</template>
      </el-table-column>
      <el-table-column label="时长(分钟)" width="100">
        <template #default="{ row }">{{ row.actualDuration || '-' }}</template>
      </el-table-column>
      <el-table-column label="积分" width="80">
        <template #default="{ row }">
          <span v-if="row.earnedPoints > 0" style="color: #3FB19E">+{{ row.earnedPoints }}</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination">
      <el-pagination
        v-model:current-page="query.pageNum"
        :page-size="query.pageSize"
        :total="total"
        layout="total, prev, pager, next"
        @current-change="handlePageChange"
      />
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.admin-reservations {
  padding: $spacing-4;
}

.page-title {
  font-size: $font-size-2xl;
  font-weight: $font-weight-bold;
  margin-bottom: $spacing-5;
  color: $text-primary;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: $spacing-4;
  margin-bottom: $spacing-5;
  
  .stat-card {
    background: white;
    border-radius: $radius-md;
    padding: $spacing-4;
    display: flex;
    align-items: center;
    gap: $spacing-3;
    box-shadow: $shadow-xs;
    
    .stat-icon {
      width: 48px;
      height: 48px;
      border-radius: $radius-sm;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      
      &.total { background: $gradient-blue; }
      &.pending { background: $gradient-yellow; }
      &.active { background: $gradient-green; }
      &.completed { background: $gradient-purple; }
      &.cancelled { background: linear-gradient(135deg, $gray-400, $gray-500); }
      &.noshow { background: linear-gradient(135deg, $error, #FF6B6B); }
    }
    
    .stat-info {
      .stat-value {
        display: block;
        font-size: $font-size-2xl;
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

.search-bar {
  display: flex;
  flex-wrap: wrap;
  gap: $spacing-3;
  margin-bottom: $spacing-4;
  padding: $spacing-4;
  background: white;
  border-radius: $radius-md;
  
  .el-button {
    display: flex;
    align-items: center;
    gap: 4px;
  }
}

.el-table {
  border-radius: $radius-md;
  overflow: hidden;
}

.pagination {
  margin-top: $spacing-4;
  display: flex;
  justify-content: flex-end;
}
</style>
