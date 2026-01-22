<script setup lang="ts">
import { ref, onMounted, watch, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { getSeatList, batchCreateSeats, batchUpdateSeatStatus } from '@/api/admin-room'
import type { Seat } from '@/types'

const props = defineProps<{
  roomId: number
}>()

const loading = ref(false)
const seats = ref<Seat[]>([])
const selectedSeats = ref<number[]>([])

// 批量生成参数
const batchParams = ref({
  rowCount: 10,
  colCount: 10,
  clearExisting: true
})

// 加载座位
const loadSeats = async () => {
  loading.value = true
  try {
    seats.value = await getSeatList(props.roomId)
  } catch (error) {
    console.error('加载座位失败:', error)
  } finally {
    loading.value = false
  }
}

// 批量生成
const handleBatchCreate = async () => {
  loading.value = true
  try {
    const count = await batchCreateSeats(props.roomId, batchParams.value)
    ElMessage.success(`成功生成 ${count} 个座位`)
    loadSeats()
  } catch (error) {
    // 错误已在拦截器处理
  } finally {
    loading.value = false
  }
}

// 切换座位选中
const toggleSeatSelect = (seat: Seat) => {
  const index = selectedSeats.value.indexOf(seat.id)
  if (index === -1) {
    selectedSeats.value.push(seat.id)
  } else {
    selectedSeats.value.splice(index, 1)
  }
}

// 批量启用
const handleBatchEnable = async () => {
  if (selectedSeats.value.length === 0) {
    ElMessage.warning('请先选择座位')
    return
  }
  await batchUpdateSeatStatus(props.roomId, selectedSeats.value, 1)
  ElMessage.success('已启用')
  selectedSeats.value = []
  loadSeats()
}

// 批量禁用
const handleBatchDisable = async () => {
  if (selectedSeats.value.length === 0) {
    ElMessage.warning('请先选择座位')
    return
  }
  await batchUpdateSeatStatus(props.roomId, selectedSeats.value, 0)
  ElMessage.success('已禁用')
  selectedSeats.value = []
  loadSeats()
}

// 获取座位样式类
const getSeatClass = (seat: Seat) => {
  const classes = ['seat-item']
  if (seat.status === 0) classes.push('disabled')
  if (seat.status === 1) classes.push('available')
  if (selectedSeats.value.includes(seat.id)) classes.push('selected')
  return classes.join(' ')
}

// 计算座位网格
const seatGrid = computed(() => {
  if (seats.value.length === 0) return []
  
  const grid: Seat[][] = []
  const maxRow = Math.max(...seats.value.map(s => s.rowNum || 0), 0)
  
  for (let row = 1; row <= maxRow; row++) {
    grid.push(seats.value.filter(s => s.rowNum === row).sort((a, b) => (a.colNum || 0) - (b.colNum || 0)))
  }
  
  return grid
})

// 清除选择
const clearSelection = () => {
  selectedSeats.value = []
}

onMounted(loadSeats)
</script>

<template>
  <div class="seat-config-panel" v-loading="loading">
    <!-- 批量生成 -->
    <div class="batch-create-section">
      <el-row :gutter="20" align="middle">
        <el-col :span="5">
          <el-input-number v-model="batchParams.rowCount" :min="1" :max="50" />
          <span class="label">行</span>
        </el-col>
        <el-col :span="1">×</el-col>
        <el-col :span="5">
          <el-input-number v-model="batchParams.colCount" :min="1" :max="50" />
          <span class="label">列</span>
        </el-col>
        <el-col :span="5">
          <el-checkbox v-model="batchParams.clearExisting">清除原有</el-checkbox>
        </el-col>
        <el-col :span="8">
          <el-button type="primary" @click="handleBatchCreate">生成座位</el-button>
          <el-button @click="loadSeats">刷新</el-button>
        </el-col>
      </el-row>
    </div>
    
    <!-- 批量操作 -->
    <div class="batch-actions" v-if="selectedSeats.length > 0">
      <span>已选 {{ selectedSeats.length }} 个座位</span>
      <el-button size="small" type="success" @click="handleBatchEnable">启用</el-button>
      <el-button size="small" type="warning" @click="handleBatchDisable">禁用</el-button>
      <el-button size="small" @click="clearSelection">取消选择</el-button>
    </div>
    
    <!-- 座位图 -->
    <div class="seat-map-container">
      <div class="seat-legend">
        <span class="legend-item"><i class="dot available"></i> 可用</span>
        <span class="legend-item"><i class="dot disabled"></i> 禁用</span>
        <span class="legend-item"><i class="dot selected"></i> 已选</span>
      </div>
      
      <div class="seat-grid" v-if="seatGrid.length > 0">
        <div class="seat-row" v-for="(row, rowIndex) in seatGrid" :key="rowIndex">
          <div
            v-for="seat in row"
            :key="seat.id"
            :class="getSeatClass(seat)"
            @click="toggleSeatSelect(seat)"
            :title="seat.seatNo"
          >
            {{ seat.seatNo }}
          </div>
        </div>
      </div>
      
      <div class="empty-seats" v-else>
        <p>暂无座位，请使用上方工具生成座位</p>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.seat-config-panel {
  .batch-create-section {
    margin-bottom: $spacing-4;
    padding: $spacing-4;
    background: $gray-50;
    border-radius: $radius-sm;
    
    .label {
      margin-left: $spacing-2;
      color: $text-secondary;
    }
  }
  
  .batch-actions {
    margin-bottom: $spacing-4;
    padding: $spacing-3;
    background: $primary-light;
    border-radius: $radius-sm;
    display: flex;
    align-items: center;
    gap: $spacing-3;
  }
  
  .seat-map-container {
    border: 1px solid $border-color;
    border-radius: $radius-sm;
    padding: $spacing-4;
    
    .seat-legend {
      display: flex;
      gap: $spacing-4;
      margin-bottom: $spacing-4;
      
      .legend-item {
        display: flex;
        align-items: center;
        gap: $spacing-2;
        font-size: $font-size-sm;
        
        .dot {
          width: 16px;
          height: 16px;
          border-radius: 4px;
          display: inline-block;
          
          &.available {
            background: $success-light;
            border: 1px solid $success;
          }
          &.disabled {
            background: $gray-200;
            border: 1px solid $gray-400;
          }
          &.selected {
            background: $primary;
            border: 1px solid $primary-dark;
          }
        }
      }
    }
    
    .seat-grid {
      display: flex;
      flex-direction: column;
      gap: $spacing-2;
      max-height: 400px;
      overflow: auto;
      
      .seat-row {
        display: flex;
        gap: $spacing-2;
      }
      
      .seat-item {
        width: 48px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: $font-size-xs;
        border-radius: 4px;
        cursor: pointer;
        transition: $transition-fast;
        
        &.available {
          background: $success-light;
          border: 1px solid $success;
          color: $success;
        }
        
        &.disabled {
          background: $gray-200;
          border: 1px solid $gray-400;
          color: $gray-500;
        }
        
        &.selected {
          background: $primary;
          border: 1px solid $primary-dark;
          color: white;
        }
        
        &:hover {
          transform: scale(1.05);
          box-shadow: $shadow-sm;
        }
      }
    }
    
    .empty-seats {
      text-align: center;
      padding: $spacing-10;
      color: $text-muted;
    }
  }
}
</style>
