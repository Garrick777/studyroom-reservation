<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Plus,
  Search,
  Edit,
  Trash2,
  Eye,
  Settings,
  Power,
  RefreshCw
} from 'lucide-vue-next'
import {
  getAdminRoomList,
  getAdminRoomDetail,
  createRoom,
  updateRoom,
  deleteRoom,
  toggleRoomStatus,
  getBuildingList
} from '@/api/admin-room'
import type { Room } from '@/types'
import type { RoomCreateParams, RoomUpdateParams, RoomDetailResponse } from '@/api/admin-room'
import SeatConfigPanel from './components/SeatConfigPanel.vue'

// 列表数据
const loading = ref(false)
const roomList = ref<Room[]>([])
const total = ref(0)
const buildings = ref<string[]>([])

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: '',
  building: '',
  status: undefined as number | undefined
})

// 弹窗状态
const dialogVisible = ref(false)
const dialogTitle = ref('')
const dialogMode = ref<'create' | 'edit' | 'view'>('create')
const detailDialogVisible = ref(false)
const seatDialogVisible = ref(false)

// 表单数据
const formRef = ref()
const formData = reactive<RoomCreateParams>({
  name: '',
  code: '',
  building: '',
  floor: '',
  roomNumber: '',
  capacity: 0,
  description: '',
  facilities: '',
  openTime: '08:00',
  closeTime: '22:00',
  rowCount: 0,
  colCount: 0,
  coverImage: ''
})

const currentRoomId = ref<number | null>(null)
const roomDetail = ref<RoomDetailResponse | null>(null)

// 表单校验规则
const formRules = {
  name: [{ required: true, message: '请输入自习室名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入自习室编号', trigger: 'blur' }],
  building: [{ required: true, message: '请选择或输入建筑', trigger: ['blur', 'change'] }],
  floor: [{ required: true, message: '请输入楼层', trigger: 'blur' }],
  capacity: [{ required: true, message: '请输入容量', trigger: ['blur', 'change'] }],
  openTime: [{ required: true, message: '请选择开放时间', trigger: 'change' }],
  closeTime: [{ required: true, message: '请选择关闭时间', trigger: 'change' }]
}

// 设施选项
const facilityOptions = ['空调', 'WiFi', '电源', '饮水机', '打印机', '储物柜', '台灯', '电脑']

// 选中的设施
const selectedFacilities = ref<string[]>([])

// 计算设施JSON
const facilitiesJson = computed({
  get: () => {
    try {
      return formData.facilities ? JSON.parse(formData.facilities) : []
    } catch {
      return []
    }
  },
  set: (val: string[]) => {
    formData.facilities = JSON.stringify(val)
    selectedFacilities.value = val
  }
})

// 状态选项
const statusOptions = [
  { label: '全部', value: undefined },
  { label: '开放', value: 1 },
  { label: '关闭', value: 0 }
]

// 加载自习室列表
const loadRoomList = async () => {
  loading.value = true
  try {
    const res = await getAdminRoomList(queryParams)
    roomList.value = res.records
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
    buildings.value = await getBuildingList()
  } catch (error) {
    console.error('加载建筑列表失败:', error)
  }
}

// 搜索
const handleSearch = () => {
  queryParams.pageNum = 1
  loadRoomList()
}

// 重置搜索
const handleReset = () => {
  queryParams.keyword = ''
  queryParams.building = ''
  queryParams.status = undefined
  queryParams.pageNum = 1
  loadRoomList()
}

// 分页变化
const handlePageChange = (page: number) => {
  queryParams.pageNum = page
  loadRoomList()
}

// 打开新建弹窗
const handleCreate = () => {
  dialogMode.value = 'create'
  dialogTitle.value = '新建自习室'
  resetForm()
  dialogVisible.value = true
}

// 打开编辑弹窗
const handleEdit = async (row: Room) => {
  dialogMode.value = 'edit'
  dialogTitle.value = '编辑自习室'
  currentRoomId.value = row.id
  
  // 填充表单数据
  Object.assign(formData, {
    name: row.name,
    code: row.code,
    building: row.building,
    floor: row.floor,
    roomNumber: row.roomNumber || '',
    capacity: row.capacity,
    description: row.description || '',
    facilities: row.facilities || '[]',
    openTime: row.openTime,
    closeTime: row.closeTime,
    rowCount: row.rowCount || 0,
    colCount: row.colCount || 0,
    coverImage: row.coverImage || ''
  })
  
  // 设置选中的设施
  try {
    selectedFacilities.value = row.facilities ? JSON.parse(row.facilities) : []
  } catch {
    selectedFacilities.value = []
  }
  
  dialogVisible.value = true
}

// 查看详情
const handleView = async (row: Room) => {
  currentRoomId.value = row.id
  try {
    roomDetail.value = await getAdminRoomDetail(row.id)
    detailDialogVisible.value = true
  } catch (error) {
    console.error('加载详情失败:', error)
  }
}

// 打开座位配置
const handleSeats = (row: Room) => {
  currentRoomId.value = row.id
  // 跳转到座位配置页面或打开弹窗
  seatDialogVisible.value = true
}

// 切换状态
const handleToggleStatus = async (row: Room) => {
  const newStatus = row.status === 1 ? 0 : 1
  const statusText = newStatus === 1 ? '开放' : '关闭'
  
  try {
    await ElMessageBox.confirm(
      `确定要${statusText}自习室"${row.name}"吗？`,
      '提示',
      { type: 'warning' }
    )
    
    await toggleRoomStatus(row.id, newStatus)
    ElMessage.success(`已${statusText}`)
    loadRoomList()
  } catch (error) {
    // 取消操作
  }
}

// 删除
const handleDelete = async (row: Room) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除自习室"${row.name}"吗？此操作将同时删除所有座位数据！`,
      '警告',
      { type: 'error', confirmButtonText: '确定删除', cancelButtonText: '取消' }
    )
    
    await deleteRoom(row.id)
    ElMessage.success('删除成功')
    loadRoomList()
  } catch (error) {
    // 取消操作
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  try {
    const valid = await formRef.value.validate().catch(() => false)
    if (!valid) return
    
    loading.value = true
    // 更新设施JSON
    formData.facilities = JSON.stringify(selectedFacilities.value)
    
    if (dialogMode.value === 'create') {
      await createRoom(formData)
      ElMessage.success('创建成功')
    } else {
      await updateRoom(currentRoomId.value!, formData as RoomUpdateParams)
      ElMessage.success('更新成功')
    }
    
    dialogVisible.value = false
    loadRoomList()
    loadBuildings()
  } catch (error) {
    console.error('提交失败:', error)
  } finally {
    loading.value = false
  }
}

// 重置表单
const resetForm = () => {
  currentRoomId.value = null
  Object.assign(formData, {
    name: '',
    code: '',
    building: '',
    floor: '',
    roomNumber: '',
    capacity: 0,
    description: '',
    facilities: '[]',
    openTime: '08:00',
    closeTime: '22:00',
    rowCount: 0,
    colCount: 0,
    coverImage: ''
  })
  selectedFacilities.value = []
  formRef.value?.resetFields()
}

// 获取状态标签类型
const getStatusType = (status: number) => {
  return status === 1 ? 'success' : 'info'
}

// 获取状态文本
const getStatusText = (status: number) => {
  return status === 1 ? '开放' : '关闭'
}

// 解析设施JSON
const parseFacilities = (facilities: string) => {
  try {
    return JSON.parse(facilities || '[]')
  } catch {
    return []
  }
}

onMounted(() => {
  loadRoomList()
  loadBuildings()
})
</script>

<template>
  <div class="room-manage-page">
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="关键词">
          <el-input
            v-model="queryParams.keyword"
            placeholder="名称/编号"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="建筑">
          <el-select v-model="queryParams.building" placeholder="全部" clearable>
            <el-option
              v-for="b in buildings"
              :key="b"
              :label="b"
              :value="b"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable>
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
            <Search :size="16" class="mr-1" />
            搜索
          </el-button>
          <el-button @click="handleReset">
            <RefreshCw :size="16" class="mr-1" />
            重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作栏 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>自习室列表</span>
          <el-button type="primary" @click="handleCreate">
            <Plus :size="16" class="mr-1" />
            新建自习室
          </el-button>
        </div>
      </template>

      <!-- 表格 -->
      <el-table :data="roomList" v-loading="loading" stripe>
        <el-table-column prop="code" label="编号" width="100" />
        <el-table-column prop="name" label="名称" min-width="150" />
        <el-table-column prop="building" label="建筑" width="120" />
        <el-table-column prop="floor" label="楼层" width="80" />
        <el-table-column prop="capacity" label="容量" width="80" align="center" />
        <el-table-column label="开放时间" width="140" align="center">
          <template #default="{ row }">
            {{ row.openTime }} - {{ row.closeTime }}
          </template>
        </el-table-column>
        <el-table-column label="设施" min-width="200">
          <template #default="{ row }">
            <el-tag
              v-for="f in parseFacilities(row.facilities)"
              :key="f"
              size="small"
              class="mr-1 mb-1"
            >
              {{ f }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="评分" width="100" align="center">
          <template #default="{ row }">
            <span class="rating">
              ⭐ {{ row.rating?.toFixed(1) || '0.0' }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleView(row)">
              <Eye :size="14" />
            </el-button>
            <el-button link type="primary" size="small" @click="handleEdit(row)">
              <Edit :size="14" />
            </el-button>
            <el-button link type="warning" size="small" @click="handleSeats(row)">
              <Settings :size="14" />
            </el-button>
            <el-button link :type="row.status === 1 ? 'warning' : 'success'" size="small" @click="handleToggleStatus(row)">
              <Power :size="14" />
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">
              <Trash2 :size="14" />
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          background
          layout="total, prev, pager, next"
          :total="total"
          :page-size="queryParams.pageSize"
          :current-page="queryParams.pageNum"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <!-- 新建/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="700px"
      destroy-on-close
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="自习室名称" prop="name">
              <el-input v-model="formData.name" placeholder="如：图书馆三楼A区" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="编号" prop="code">
              <el-input v-model="formData.code" placeholder="如：LIB-3A" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="建筑" prop="building">
              <el-select
                v-model="formData.building"
                placeholder="选择或输入"
                filterable
                allow-create
                default-first-option
              >
                <el-option
                  v-for="b in buildings"
                  :key="b"
                  :label="b"
                  :value="b"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="楼层" prop="floor">
              <el-input v-model="formData.floor" placeholder="如：3楼" />
            </el-form-item>
          </el-col>
          <el-col :span="6">
            <el-form-item label="房间号">
              <el-input v-model="formData.roomNumber" placeholder="如：301" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="容量" prop="capacity">
              <el-input-number v-model="formData.capacity" :min="1" :max="500" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="开放时间" prop="openTime">
              <el-time-select
                v-model="formData.openTime"
                start="06:00"
                step="00:30"
                end="12:00"
                placeholder="开放时间"
              />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="关闭时间" prop="closeTime">
              <el-time-select
                v-model="formData.closeTime"
                start="18:00"
                step="00:30"
                end="24:00"
                placeholder="关闭时间"
              />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="座位行数">
              <el-input-number v-model="formData.rowCount" :min="0" :max="50" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="座位列数">
              <el-input-number v-model="formData.colCount" :min="0" :max="50" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="预计座位">
              <span class="computed-seats">
                {{ (formData.rowCount || 0) * (formData.colCount || 0) }} 个
              </span>
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="设施">
          <el-checkbox-group v-model="selectedFacilities">
            <el-checkbox
              v-for="f in facilityOptions"
              :key="f"
              :label="f"
            >
              {{ f }}
            </el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        
        <el-form-item label="描述">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="3"
            placeholder="自习室简介..."
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="loading" @click="handleSubmit">
          {{ dialogMode === 'create' ? '创建' : '保存' }}
        </el-button>
      </template>
    </el-dialog>

    <!-- 详情弹窗 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="自习室详情"
      width="600px"
    >
      <template v-if="roomDetail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="名称">{{ roomDetail.room.name }}</el-descriptions-item>
          <el-descriptions-item label="编号">{{ roomDetail.room.code }}</el-descriptions-item>
          <el-descriptions-item label="建筑">{{ roomDetail.room.building }}</el-descriptions-item>
          <el-descriptions-item label="楼层">{{ roomDetail.room.floor }}</el-descriptions-item>
          <el-descriptions-item label="容量">{{ roomDetail.room.capacity }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusType(roomDetail.room.status)">
              {{ getStatusText(roomDetail.room.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="开放时间" :span="2">
            {{ roomDetail.room.openTime }} - {{ roomDetail.room.closeTime }}
          </el-descriptions-item>
          <el-descriptions-item label="总座位">{{ roomDetail.totalSeats }}</el-descriptions-item>
          <el-descriptions-item label="可用座位">{{ roomDetail.availableSeats }}</el-descriptions-item>
          <el-descriptions-item label="禁用座位">{{ roomDetail.disabledSeats }}</el-descriptions-item>
          <el-descriptions-item label="评分">
            ⭐ {{ roomDetail.room.rating?.toFixed(1) || '0.0' }} ({{ roomDetail.room.ratingCount }}人评价)
          </el-descriptions-item>
          <el-descriptions-item label="设施" :span="2">
            <el-tag
              v-for="f in parseFacilities(roomDetail.room.facilities)"
              :key="f"
              size="small"
              class="mr-1"
            >
              {{ f }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="描述" :span="2">
            {{ roomDetail.room.description || '暂无描述' }}
          </el-descriptions-item>
        </el-descriptions>
      </template>
    </el-dialog>

    <!-- 座位配置弹窗 -->
    <el-dialog
      v-model="seatDialogVisible"
      title="座位配置"
      width="900px"
      destroy-on-close
    >
      <SeatConfigPanel
        v-if="seatDialogVisible && currentRoomId"
        :room-id="currentRoomId"
      />
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.room-manage-page {
  padding: $spacing-4;
  
  .search-card {
    margin-bottom: $spacing-4;
    
    .search-form {
      display: flex;
      flex-wrap: wrap;
      gap: $spacing-2;
    }
  }
  
  .table-card {
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
  }
  
  .pagination-container {
    margin-top: $spacing-4;
    display: flex;
    justify-content: flex-end;
  }
  
  .mr-1 {
    margin-right: $spacing-1;
  }
  
  .mb-1 {
    margin-bottom: $spacing-1;
  }
  
  .rating {
    color: $warning;
    font-weight: $font-weight-medium;
  }
  
  .computed-seats {
    font-size: $font-size-lg;
    font-weight: $font-weight-bold;
    color: $primary;
  }
}
</style>
