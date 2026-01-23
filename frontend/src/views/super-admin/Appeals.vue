<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Search,
  RefreshCw,
  CheckCircle,
  XCircle,
  Clock,
  AlertTriangle,
  MessageSquare,
  FileText
} from 'lucide-vue-next'
import request from '@/utils/request'

interface Violation {
  id: number
  userId: number
  type: string
  description: string
  deductedScore: number
  reservationId: number
  appealStatus: number // 0未申诉 1申诉中 2申诉通过 3申诉驳回
  appealReason: string
  appealTime: string
  appealResult: string
  processTime: string
  createTime: string
  user?: {
    username: string
    realName: string
    creditScore: number
  }
}

// 列表数据
const loading = ref(false)
const violations = ref<Violation[]>([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  type: '',
  appealStatus: undefined as number | undefined
})

// 状态选项
const statusOptions = [
  { label: '全部', value: undefined },
  { label: '申诉中', value: 1 },
  { label: '已通过', value: 2 },
  { label: '已驳回', value: 3 }
]

// 类型选项
const typeOptions = [
  { label: '全部', value: '' },
  { label: '未签到', value: 'NO_SHOW' },
  { label: '迟到', value: 'LATE' },
  { label: '早退', value: 'EARLY_LEAVE' },
  { label: '超时离开', value: 'LEAVE_TIMEOUT' },
  { label: '取消预约', value: 'CANCEL' }
]

// 加载违规记录
const loadViolations = async () => {
  loading.value = true
  try {
    const params: any = {
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize
    }
    if (queryParams.type) params.type = queryParams.type
    if (queryParams.appealStatus !== undefined) params.appealStatus = queryParams.appealStatus
    
    const res = await request.get('/manage/credit/violations', { params })
    violations.value = res.records || []
    total.value = res.total || 0
  } catch (error) {
    console.error('加载违规记录失败:', error)
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  queryParams.pageNum = 1
  loadViolations()
}

// 重置
const handleReset = () => {
  queryParams.type = ''
  queryParams.appealStatus = undefined
  queryParams.pageNum = 1
  loadViolations()
}

// 通过申诉
const handleApprove = async (row: Violation) => {
  try {
    const { value } = await ElMessageBox.prompt('请输入审批意见', '通过申诉', {
      confirmButtonText: '确认通过',
      cancelButtonText: '取消',
      inputPlaceholder: '审批意见...',
      inputValue: '申诉理由成立，予以通过'
    })
    await request.post(`/manage/credit/violations/${row.id}/process-appeal`, {
      approved: true,
      result: value || '申诉通过'
    })
    ElMessage.success('申诉已通过')
    loadViolations()
  } catch {
    // 取消
  }
}

// 驳回申诉
const handleReject = async (row: Violation) => {
  try {
    const { value } = await ElMessageBox.prompt('请输入驳回原因', '驳回申诉', {
      confirmButtonText: '确认驳回',
      cancelButtonText: '取消',
      inputPlaceholder: '驳回原因...',
      inputValidator: (val) => !!val?.trim() || '请输入驳回原因'
    })
    await request.post(`/manage/credit/violations/${row.id}/process-appeal`, {
      approved: false,
      result: value
    })
    ElMessage.success('申诉已驳回')
    loadViolations()
  } catch {
    // 取消
  }
}

// 获取类型名称
const getTypeName = (type: string) => {
  const map: Record<string, string> = {
    NO_SHOW: '未签到',
    LATE: '迟到',
    EARLY_LEAVE: '早退',
    LEAVE_TIMEOUT: '超时离开',
    CANCEL: '取消预约'
  }
  return map[type] || type
}

// 获取状态标签
const getStatusTag = (status: number) => {
  const map: Record<number, { type: string; text: string; icon: any }> = {
    0: { type: 'info', text: '未申诉', icon: FileText },
    1: { type: 'warning', text: '申诉中', icon: Clock },
    2: { type: 'success', text: '已通过', icon: CheckCircle },
    3: { type: 'danger', text: '已驳回', icon: XCircle }
  }
  return map[status] || { type: 'info', text: '未知', icon: FileText }
}

onMounted(() => {
  loadViolations()
})
</script>

<template>
  <div class="appeals-page">
    <div class="page-header">
      <h2><MessageSquare :size="24" /> 申诉管理</h2>
      <p>处理用户的信用分申诉</p>
    </div>
    
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="违规类型">
          <el-select v-model="queryParams.type" placeholder="全部" clearable style="width: 140px">
            <el-option
              v-for="opt in typeOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="申诉状态">
          <el-select v-model="queryParams.appealStatus" placeholder="全部" clearable style="width: 120px">
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
    
    <!-- 表格 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>违规记录与申诉</span>
        </div>
      </template>
      
      <el-table :data="violations" v-loading="loading" stripe table-layout="fixed">
        <el-table-column label="用户" width="150">
          <template #default="{ row }">
            <div v-if="row.user">
              <div>{{ row.user.realName || row.user.username }}</div>
              <div class="text-muted">信用分: {{ row.user.creditScore }}</div>
            </div>
            <span v-else>用户ID: {{ row.userId }}</span>
          </template>
        </el-table-column>
        <el-table-column label="违规类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag type="danger" size="small">
              <AlertTriangle :size="12" class="mr-1" />
              {{ getTypeName(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="扣分" width="80" align="center">
          <template #default="{ row }">
            <span class="deduct">-{{ row.deductedScore }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="违规描述" min-width="160" show-overflow-tooltip />
        <el-table-column label="申诉状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.appealStatus).type" size="small">
              <component :is="getStatusTag(row.appealStatus).icon" :size="12" class="mr-1" />
              {{ getStatusTag(row.appealStatus).text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="申诉理由" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">
            <span v-if="row.appealReason">{{ row.appealReason }}</span>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>
        <el-table-column label="处理结果" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">
            <span v-if="row.appealResult">{{ row.appealResult }}</span>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="违规时间" width="160" show-overflow-tooltip />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <template v-if="row.appealStatus === 1">
              <el-button link type="success" size="small" @click="handleApprove(row)">
                <CheckCircle :size="14" />
                通过
              </el-button>
              <el-button link type="danger" size="small" @click="handleReject(row)">
                <XCircle :size="14" />
                驳回
              </el-button>
            </template>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination">
        <el-pagination
          background
          layout="total, prev, pager, next"
          :total="total"
          :page-size="queryParams.pageSize"
          :current-page="queryParams.pageNum"
          @current-change="(page: number) => { queryParams.pageNum = page; loadViolations() }"
        />
      </div>
    </el-card>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.appeals-page {
  .page-header {
    margin-bottom: $spacing-4;
    
    h2 {
      display: flex;
      align-items: center;
      gap: 8px;
      margin: 0 0 4px;
      font-size: 20px;
      color: $text-primary;
    }
    
    p {
      margin: 0;
      color: $text-muted;
      font-size: 14px;
    }
  }
  
  .search-card {
    margin-bottom: $spacing-4;
  }
  
  .table-card {
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
  }
  
  .deduct {
    font-weight: 600;
    color: $danger;
  }
  
  .pagination {
    margin-top: $spacing-4;
    display: flex;
    justify-content: flex-end;
  }
  
  .mr-1 {
    margin-right: $spacing-1;
  }
  
  .text-muted {
    color: $text-muted;
    font-size: 12px;
  }
}
</style>
