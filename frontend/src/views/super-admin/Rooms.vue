<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Building2,
  Search,
  RefreshCw,
  Plus,
  Edit,
  Trash2,
  Eye,
  Settings,
  Grid,
  Power,
  PowerOff
} from 'lucide-vue-next'
import { request } from '@/utils/request'

// 类型定义
interface StudyRoom {
  id: number
  name: string
  code: string
  building: string
  floor: string
  roomNumber: string
  capacity: number
  description: string
  facilities: string[]
  openTime: string
  closeTime: string
  rowCount: number
  colCount: number
  coverImage: string
  status: number
  rating: number
  ratingCount: number
  createTime: string
}

interface Seat {
  id: number
  roomId: number
  seatNo: string
  rowNum: number
  colNum: number
  seatType: string
  status: number
  remark: string
}

// 列表数据
const loading = ref(false)
const rooms = ref<StudyRoom[]>([])
const total = ref(0)
const buildings = ref<string[]>([])

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  keyword: '',
  building: '',
  status: undefined as number | undefined
})

// 新增/编辑弹窗
const dialogVisible = ref(false)
const dialogTitle = ref('新增自习室')
const isEdit = ref(false)
const submitLoading = ref(false)

const formData = reactive({
  id: 0,
  name: '',
  code: '',
  building: '',
  floor: '',
  roomNumber: '',
  capacity: 50,
  description: '',
  facilities: [] as string[],
  openTime: '08:00',
  closeTime: '22:00',
  rowCount: 5,
  colCount: 10,
  coverImage: ''
})

// 座位管理弹窗
const seatsDialogVisible = ref(false)
const currentRoom = ref<StudyRoom | null>(null)
const seats = ref<Seat[]>([])
const seatsLoading = ref(false)
const selectedSeats = ref<number[]>([])

// 设施选项
const facilityOptions = [
  { label: 'WiFi', value: 'wifi' },
  { label: '空调', value: 'air_conditioning' },
  { label: '插座', value: 'power_outlet' },
  { label: '台灯', value: 'desk_lamp' },
  { label: '饮水机', value: 'water_dispenser' },
  { label: '打印机', value: 'printer' }
]

// 状态选项
const statusOptions = [
  { label: '全部', value: undefined },
  { label: '开放', value: 1 },
  { label: '关闭', value: 0 }
]

// 加载自习室列表
const loadRooms = async () => {
  loading.value = true
  try {
    const res = await request.get('/manage/rooms', { params: queryParams })
    rooms.value = res.records
    total.value = res.total
  } catch (error) {
    console.error('加载自习室列表失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载建筑列表
const loadBuildings = async () => {
  try {
    const res = await request.get('/manage/rooms/buildings')
    buildings.value = res
  } catch (error) {
    console.error('加载建筑列表失败:', error)
  }
}

// 搜索
const handleSearch = () => {
  queryParams.pageNum = 1
  loadRooms()
}

// 重置
const handleReset = () => {
  queryParams.keyword = ''
  queryParams.building = ''
  queryParams.status = undefined
  queryParams.pageNum = 1
  loadRooms()
}

// 打开新增弹窗
const openCreateDialog = () => {
  isEdit.value = false
  dialogTitle.value = '新增自习室'
  Object.assign(formData, {
    id: 0,
    name: '',
    code: '',
    building: '',
    floor: '',
    roomNumber: '',
    capacity: 50,
    description: '',
    facilities: [],
    openTime: '08:00',
    closeTime: '22:00',
    rowCount: 5,
    colCount: 10,
    coverImage: ''
  })
  dialogVisible.value = true
}

// 打开编辑弹窗
const openEditDialog = async (row: StudyRoom) => {
  isEdit.value = true
  dialogTitle.value = '编辑自习室'
  
  try {
    const res = await request.get(`/manage/rooms/${row.id}`)
    const room = res.room as StudyRoom
    
    Object.assign(formData, {
      id: room.id,
      name: room.name,
      code: room.code,
      building: room.building,
      floor: room.floor,
      roomNumber: room.roomNumber,
      capacity: room.capacity,
      description: room.description || '',
      facilities: room.facilities || [],
      openTime: room.openTime,
      closeTime: room.closeTime,
      rowCount: room.rowCount,
      colCount: room.colCount,
      coverImage: room.coverImage || ''
    })
    dialogVisible.value = true
  } catch (error) {
    console.error('获取自习室详情失败:', error)
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formData.name.trim()) {
    ElMessage.warning('请输入自习室名称')
    return
  }
  if (!formData.code.trim()) {
    ElMessage.warning('请输入自习室编号')
    return
  }
  if (!formData.building.trim()) {
    ElMessage.warning('请输入所在建筑')
    return
  }
  
  submitLoading.value = true
  try {
    const data = {
      ...formData,
      facilities: JSON.stringify(formData.facilities)
    }
    
    if (isEdit.value) {
      await request.put(`/manage/rooms/${formData.id}`, data)
      ElMessage.success('更新成功')
    } else {
      await request.post('/manage/rooms', data)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadRooms()
    loadBuildings()
  } catch (error: any) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    submitLoading.value = false
  }
}

// 删除自习室
const handleDelete = async (row: StudyRoom) => {
  try {
    await ElMessageBox.confirm(`确定要删除自习室 ${row.name} 吗？此操作会同时删除所有座位。`, '删除确认', {
      type: 'warning',
      confirmButtonText: '确定删除',
      confirmButtonClass: 'el-button--danger'
    })
    await request.delete(`/manage/rooms/${row.id}`)
    ElMessage.success('删除成功')
    loadRooms()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

// 切换状态
const handleToggleStatus = async (row: StudyRoom) => {
  const newStatus = row.status === 1 ? 0 : 1
  const statusText = newStatus === 1 ? '开放' : '关闭'
  
  try {
    await request.put(`/manage/rooms/${row.id}/status`, null, { params: { status: newStatus } })
    ElMessage.success(`${statusText}成功`)
    loadRooms()
  } catch (error: any) {
    ElMessage.error(error.message || '操作失败')
  }
}

// 打开座位管理
const openSeatsDialog = async (row: StudyRoom) => {
  currentRoom.value = row
  seatsDialogVisible.value = true
  selectedSeats.value = []
  await loadSeats(row.id)
}

// 加载座位
const loadSeats = async (roomId: number) => {
  seatsLoading.value = true
  try {
    seats.value = await request.get(`/manage/rooms/${roomId}/seats`)
  } catch (error) {
    console.error('加载座位失败:', error)
  } finally {
    seatsLoading.value = false
  }
}

// 生成座位布局
const seatLayout = computed(() => {
  if (!currentRoom.value) return []
  
  const layout: (Seat | null)[][] = []
  const rowCount = currentRoom.value.rowCount || 5
  const colCount = currentRoom.value.colCount || 10
  
  for (let r = 0; r < rowCount; r++) {
    const row: (Seat | null)[] = []
    for (let c = 0; c < colCount; c++) {
      const seat = seats.value.find(s => s.rowNum === r + 1 && s.colNum === c + 1)
      row.push(seat || null)
    }
    layout.push(row)
  }
  
  return layout
})

// 切换座位选择
const toggleSeatSelection = (seat: Seat | null) => {
  if (!seat) return
  const index = selectedSeats.value.indexOf(seat.id)
  if (index >= 0) {
    selectedSeats.value.splice(index, 1)
  } else {
    selectedSeats.value.push(seat.id)
  }
}

// 批量更新座位状态
const batchUpdateSeats = async (status: number) => {
  if (selectedSeats.value.length === 0) {
    ElMessage.warning('请先选择座位')
    return
  }
  
  try {
    await request.put(`/manage/rooms/${currentRoom.value!.id}/seats/batch-status`, {
      seatIds: selectedSeats.value,
      status
    })
    ElMessage.success('更新成功')
    selectedSeats.value = []
    await loadSeats(currentRoom.value!.id)
  } catch (error: any) {
    ElMessage.error(error.message || '更新失败')
  }
}

// 重新生成座位
const regenerateSeats = async () => {
  if (!currentRoom.value) return
  
  try {
    await ElMessageBox.confirm('确定要重新生成座位吗？这将删除现有所有座位。', '提示', { type: 'warning' })
    await request.post(`/manage/rooms/${currentRoom.value.id}/seats/batch`, {
      rowCount: currentRoom.value.rowCount,
      colCount: currentRoom.value.colCount,
      clearExisting: true
    })
    ElMessage.success('座位已重新生成')
    await loadSeats(currentRoom.value.id)
    loadRooms()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '生成失败')
    }
  }
}

// 格式化状态
const getStatusTag = (status: number) => {
  return status === 1 
    ? { type: 'success', text: '开放' }
    : { type: 'info', text: '关闭' }
}

// 获取座位样式
const getSeatClass = (seat: Seat | null) => {
  if (!seat) return 'seat empty'
  let classes = ['seat']
  if (seat.status === 0) classes.push('disabled')
  if (selectedSeats.value.includes(seat.id)) classes.push('selected')
  if (seat.seatType === 'WINDOW') classes.push('window')
  if (seat.seatType === 'POWER') classes.push('power')
  if (seat.seatType === 'VIP') classes.push('vip')
  return classes.join(' ')
}

onMounted(() => {
  loadRooms()
  loadBuildings()
})
</script>

<template>
  <div class="rooms-page">
    <div class="page-header">
      <div class="header-left">
        <h2><Building2 :size="24" /> 自习室管理</h2>
        <p>共 {{ total }} 个自习室</p>
      </div>
      <el-button type="primary" @click="openCreateDialog">
        <Plus :size="16" class="mr-1" /> 新增自习室
      </el-button>
    </div>
    
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="关键词">
          <el-input
            v-model="queryParams.keyword"
            placeholder="名称/编号"
            clearable
            style="width: 160px"
            @keyup.enter="handleSearch"
          >
            <template #prefix><Search :size="16" /></template>
          </el-input>
        </el-form-item>
        <el-form-item label="建筑">
          <el-select v-model="queryParams.building" placeholder="全部" clearable style="width: 140px">
            <el-option v-for="b in buildings" :key="b" :label="b" :value="b" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 100px">
            <el-option
              v-for="opt in statusOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <Search :size="16" class="mr-1" /> 搜索
          </el-button>
          <el-button @click="handleReset">
            <RefreshCw :size="16" class="mr-1" /> 重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <!-- 自习室表格 -->
    <el-card class="table-card">
      <el-table :data="rooms" v-loading="loading" stripe table-layout="fixed">
        <el-table-column label="自习室" min-width="150">
          <template #default="{ row }">
            <div class="room-info">
              <div class="room-name">{{ row.name }}</div>
              <div class="room-code">{{ row.code }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="位置" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.building }} {{ row.floor }} {{ row.roomNumber }}
          </template>
        </el-table-column>
        <el-table-column label="布局" width="80" align="center">
          <template #default="{ row }">
            {{ row.rowCount }}×{{ row.colCount }}
          </template>
        </el-table-column>
        <el-table-column prop="capacity" label="座位" width="60" align="center" />
        <el-table-column label="开放时间" min-width="120">
          <template #default="{ row }">
            {{ row.openTime }}-{{ row.closeTime }}
          </template>
        </el-table-column>
        <el-table-column label="评分" width="90">
          <template #default="{ row }">
            <div v-if="row.ratingCount > 0">
              <span class="rating">{{ row.rating?.toFixed(1) }}</span>
              <span class="rating-count">({{ row.ratingCount }})</span>
            </div>
            <span v-else class="no-rating">暂无</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="70" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status).type" size="small">
              {{ getStatusTag(row.status).text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openSeatsDialog(row)">
              <Grid :size="14" /> 座位
            </el-button>
            <el-button link type="primary" size="small" @click="openEditDialog(row)">
              <Edit :size="14" /> 编辑
            </el-button>
            <el-button 
              link 
              :type="row.status === 1 ? 'warning' : 'success'" 
              size="small" 
              @click="handleToggleStatus(row)"
            >
              <template v-if="row.status === 1">
                <PowerOff :size="14" /> 关闭
              </template>
              <template v-else>
                <Power :size="14" /> 开放
              </template>
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">
              <Trash2 :size="14" /> 删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
          :total="total"
          :page-sizes="[10, 20, 50]"
          :page-size="queryParams.pageSize"
          :current-page="queryParams.pageNum"
          @current-change="(page: number) => { queryParams.pageNum = page; loadRooms() }"
          @size-change="(size: number) => { queryParams.pageSize = size; loadRooms() }"
        />
      </div>
    </el-card>
    
    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px">
      <el-form :model="formData" label-width="100px">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="自习室名称" required>
              <el-input v-model="formData.name" placeholder="如：图书馆A区" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="编号" required>
              <el-input v-model="formData.code" placeholder="如：LIB-A" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="16">
          <el-col :span="8">
            <el-form-item label="所在建筑" required>
              <el-input v-model="formData.building" placeholder="如：图书馆" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="楼层">
              <el-input v-model="formData.floor" placeholder="如：3楼" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="房间号">
              <el-input v-model="formData.roomNumber" placeholder="如：301" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="开放时间">
              <el-time-picker v-model="formData.openTime" format="HH:mm" value-format="HH:mm" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="关闭时间">
              <el-time-picker v-model="formData.closeTime" format="HH:mm" value-format="HH:mm" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="座位行数">
              <el-input-number v-model="formData.rowCount" :min="1" :max="20" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="座位列数">
              <el-input-number v-model="formData.colCount" :min="1" :max="20" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="设施">
          <el-checkbox-group v-model="formData.facilities">
            <el-checkbox v-for="f in facilityOptions" :key="f.value" :label="f.value">
              {{ f.label }}
            </el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        
        <el-form-item label="描述">
          <el-input v-model="formData.description" type="textarea" :rows="2" placeholder="自习室描述..." />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">
          {{ isEdit ? '保存' : '创建' }}
        </el-button>
      </template>
    </el-dialog>
    
    <!-- 座位管理弹窗 -->
    <el-dialog v-model="seatsDialogVisible" :title="`座位管理 - ${currentRoom?.name}`" width="800px">
      <div class="seats-toolbar">
        <div class="toolbar-left">
          <el-button type="primary" size="small" @click="regenerateSeats">
            <RefreshCw :size="14" class="mr-1" /> 重新生成座位
          </el-button>
        </div>
        <div class="toolbar-right" v-if="selectedSeats.length > 0">
          <span class="selected-count">已选 {{ selectedSeats.length }} 个座位</span>
          <el-button type="success" size="small" @click="batchUpdateSeats(1)">
            <Power :size="14" /> 启用
          </el-button>
          <el-button type="warning" size="small" @click="batchUpdateSeats(0)">
            <PowerOff :size="14" /> 禁用
          </el-button>
        </div>
      </div>
      
      <div class="seats-legend">
        <div class="legend-item"><span class="seat-demo available"></span> 可用</div>
        <div class="legend-item"><span class="seat-demo disabled"></span> 禁用</div>
        <div class="legend-item"><span class="seat-demo selected"></span> 已选</div>
        <div class="legend-item"><span class="seat-demo window"></span> 靠窗</div>
        <div class="legend-item"><span class="seat-demo power"></span> 电源</div>
      </div>
      
      <div class="seats-grid" v-loading="seatsLoading">
        <div class="seat-row" v-for="(row, ri) in seatLayout" :key="ri">
          <div class="row-label">{{ String.fromCharCode(65 + ri) }}</div>
          <div 
            v-for="(seat, ci) in row" 
            :key="ci"
            :class="getSeatClass(seat)"
            @click="toggleSeatSelection(seat)"
          >
            <span v-if="seat">{{ seat.seatNo }}</span>
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.rooms-page {
  padding: 24px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  
  .header-left {
    h2 {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 22px;
      font-weight: 600;
      color: $text-primary;
      margin-bottom: 4px;
    }
    
    p {
      color: $text-secondary;
      font-size: 14px;
    }
  }
}

.search-card {
  margin-bottom: 16px;
}

.table-card {
  .room-info {
    .room-name {
      font-weight: 500;
      color: $text-primary;
    }
    .room-code {
      font-size: 12px;
      color: $text-muted;
    }
  }
  
  .rating {
    color: $warning;
    font-weight: 500;
  }
  
  .rating-count {
    font-size: 12px;
    color: $text-muted;
  }
  
  .no-rating {
    color: $text-muted;
    font-size: 12px;
  }
}

.pagination {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.seats-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  
  .toolbar-right {
    display: flex;
    align-items: center;
    gap: 12px;
    
    .selected-count {
      color: $primary;
      font-weight: 500;
    }
  }
}

.seats-legend {
  display: flex;
  gap: 20px;
  margin-bottom: 16px;
  padding: 12px;
  background: $gray-50;
  border-radius: 8px;
  
  .legend-item {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: $text-secondary;
  }
  
  .seat-demo {
    width: 20px;
    height: 20px;
    border-radius: 4px;
    
    &.available { background: #e8f5e9; border: 1px solid #4caf50; }
    &.disabled { background: #f5f5f5; border: 1px solid #e0e0e0; }
    &.selected { background: #bbdefb; border: 2px solid #2196f3; }
    &.window { background: #e3f2fd; border: 1px solid #2196f3; }
    &.power { background: #fff3e0; border: 1px solid #ff9800; }
  }
}

.seats-grid {
  padding: 20px;
  background: $gray-50;
  border-radius: 8px;
  overflow-x: auto;
  
  .seat-row {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
    
    .row-label {
      width: 24px;
      text-align: center;
      font-weight: 500;
      color: $text-secondary;
    }
  }
  
  .seat {
    width: 48px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #e8f5e9;
    border: 1px solid #4caf50;
    border-radius: 4px;
    font-size: 11px;
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
      transform: scale(1.05);
    }
    
    &.empty {
      background: transparent;
      border: 1px dashed #e0e0e0;
      cursor: default;
      
      &:hover {
        transform: none;
      }
    }
    
    &.disabled {
      background: #f5f5f5;
      border-color: #e0e0e0;
      color: #9e9e9e;
    }
    
    &.selected {
      background: #bbdefb;
      border: 2px solid #2196f3;
    }
    
    &.window {
      background: #e3f2fd;
      border-color: #2196f3;
    }
    
    &.power {
      background: #fff3e0;
      border-color: #ff9800;
    }
    
    &.vip {
      background: #fce4ec;
      border-color: #e91e63;
    }
  }
}

.mr-1 {
  margin-right: 4px;
}
</style>
