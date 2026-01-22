<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Search,
  RefreshCw,
  CheckCircle,
  XCircle,
  Eye
} from 'lucide-vue-next'
import {
  getAdminViolations,
  processAppeal,
  type ViolationRecord
} from '@/api/credit'

// 列表数据
const loading = ref(false)
const violations = ref<ViolationRecord[]>([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  userId: undefined as number | undefined,
  type: '',
  appealStatus: undefined as number | undefined
})

// 详情弹窗
const detailDialogVisible = ref(false)
const currentViolation = ref<ViolationRecord | null>(null)

// 处理申诉弹窗
const processDialogVisible = ref(false)
const processForm = reactive({
  violationId: 0,
  approved: true,
  result: ''
})

// 违约类型选项
const typeOptions = [
  { label: '全部', value: '' },
  { label: '未签到', value: 'NO_SIGN_IN' },
  { label: '临时取消', value: 'LATE_CANCEL' },
  { label: '暂离超时', value: 'LEAVE_TIMEOUT' },
  { label: '提前离开', value: 'EARLY_LEAVE' }
]

// 申诉状态选项
const appealStatusOptions = [
  { label: '全部', value: undefined },
  { label: '未申诉', value: 0 },
  { label: '申诉中', value: 1 },
  { label: '申诉通过', value: 2 },
  { label: '申诉驳回', value: 3 }
]

// 加载违约记录
const loadViolations = async () => {
  loading.value = true
  try {
    const res = await getAdminViolations(queryParams)
    violations.value = res.records
    total.value = res.total
  } catch (error) {
    console.error('加载违约记录失败:', error)
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
  queryParams.userId = undefined
  queryParams.pageNum = 1
  loadViolations()
}

// 查看详情
const handleViewDetail = (row: ViolationRecord) => {
  currentViolation.value = row
  detailDialogVisible.value = true
}

// 打开处理申诉弹窗
const openProcessDialog = (row: ViolationRecord) => {
  if (row.appealStatus !== 1) {
    ElMessage.warning('该申诉不在待处理状态')
    return
  }
  processForm.violationId = row.id
  processForm.approved = true
  processForm.result = ''
  processDialogVisible.value = true
}

// 处理申诉
const handleProcessAppeal = async () => {
  if (!processForm.result.trim()) {
    ElMessage.warning('请输入处理结果说明')
    return
  }
  
  try {
    await processAppeal(processForm.violationId, processForm.approved, processForm.result)
    ElMessage.success('处理成功')
    processDialogVisible.value = false
    loadViolations()
  } catch (error) {
    console.error('处理失败:', error)
  }
}

// 获取违约类型描述
const getViolationTypeText = (type: string) => {
  const typeMap: Record<string, string> = {
    'NO_SIGN_IN': '预约未签到',
    'LATE_CANCEL': '临时取消预约',
    'LEAVE_TIMEOUT': '暂离超时',
    'EARLY_LEAVE': '提前离开'
  }
  return typeMap[type] || type
}

// 获取申诉状态标签
const getAppealStatusTag = (status: number) => {
  switch (status) {
    case 0: return { type: 'info', text: '未申诉' }
    case 1: return { type: 'warning', text: '申诉中' }
    case 2: return { type: 'success', text: '申诉通过' }
    case 3: return { type: 'danger', text: '申诉驳回' }
    default: return { type: 'info', text: '未知' }
  }
}

onMounted(() => {
  loadViolations()
})
</script>

<template>
  <div class="violations-page">
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="违约类型">
          <el-select v-model="queryParams.type" placeholder="全部" clearable>
            <el-option
              v-for="opt in typeOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="申诉状态">
          <el-select v-model="queryParams.appealStatus" placeholder="全部" clearable>
            <el-option
              v-for="opt in appealStatusOptions"
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
          <span>违约记录列表</span>
          <el-tag type="warning" effect="plain">
            待处理申诉: {{ violations.filter(v => v.appealStatus === 1).length }}
          </el-tag>
        </div>
      </template>
      
      <el-table :data="violations" v-loading="loading" stripe>
        <el-table-column label="用户" width="150">
          <template #default="{ row }">
            <div v-if="row.user">
              <div>{{ row.user.username }}</div>
              <small class="text-muted">{{ row.user.studentNo }}</small>
            </div>
            <span v-else>用户ID: {{ row.userId }}</span>
          </template>
        </el-table-column>
        <el-table-column label="违约类型" width="120">
          <template #default="{ row }">
            {{ getViolationTypeText(row.type) }}
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
        <el-table-column label="扣分" width="80" align="center">
          <template #default="{ row }">
            <el-tag type="danger" size="small">-{{ row.deductScore }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="积分变化" width="120" align="center">
          <template #default="{ row }">
            {{ row.beforeScore }} → {{ row.afterScore }}
          </template>
        </el-table-column>
        <el-table-column label="申诉状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getAppealStatusTag(row.appealStatus).type" size="small">
              {{ getAppealStatusTag(row.appealStatus).text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="发生时间" width="170" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleViewDetail(row)">
              <Eye :size="14" />
              详情
            </el-button>
            <el-button
              v-if="row.appealStatus === 1"
              link
              type="warning"
              size="small"
              @click="openProcessDialog(row)"
            >
              处理
            </el-button>
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
    
    <!-- 详情弹窗 -->
    <el-dialog v-model="detailDialogVisible" title="违约详情" width="600px">
      <template v-if="currentViolation">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="用户">
            {{ currentViolation.user?.username }} ({{ currentViolation.user?.studentNo }})
          </el-descriptions-item>
          <el-descriptions-item label="违约类型">
            {{ getViolationTypeText(currentViolation.type) }}
          </el-descriptions-item>
          <el-descriptions-item label="扣除积分">
            <el-tag type="danger">-{{ currentViolation.deductScore }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="积分变化">
            {{ currentViolation.beforeScore }} → {{ currentViolation.afterScore }}
          </el-descriptions-item>
          <el-descriptions-item label="违约描述" :span="2">
            {{ currentViolation.description }}
          </el-descriptions-item>
          <el-descriptions-item label="发生时间" :span="2">
            {{ currentViolation.createdAt }}
          </el-descriptions-item>
        </el-descriptions>
        
        <el-divider />
        
        <h4>申诉信息</h4>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="申诉状态">
            <el-tag :type="getAppealStatusTag(currentViolation.appealStatus).type">
              {{ getAppealStatusTag(currentViolation.appealStatus).text }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item v-if="currentViolation.appealStatus > 0" label="申诉理由">
            {{ currentViolation.appealReason || '无' }}
          </el-descriptions-item>
          <el-descriptions-item v-if="currentViolation.appealStatus > 0" label="申诉时间">
            {{ currentViolation.appealTime || '-' }}
          </el-descriptions-item>
          <el-descriptions-item v-if="currentViolation.appealStatus > 1" label="处理结果">
            {{ currentViolation.appealResult || '-' }}
          </el-descriptions-item>
          <el-descriptions-item v-if="currentViolation.appealStatus > 1" label="处理时间">
            {{ currentViolation.processedTime || '-' }}
          </el-descriptions-item>
        </el-descriptions>
      </template>
    </el-dialog>
    
    <!-- 处理申诉弹窗 -->
    <el-dialog v-model="processDialogVisible" title="处理申诉" width="500px">
      <el-form label-width="100px">
        <el-form-item label="处理结果">
          <el-radio-group v-model="processForm.approved">
            <el-radio :value="true">
              <CheckCircle :size="16" class="mr-1 text-success" />
              通过申诉（返还扣分）
            </el-radio>
            <el-radio :value="false">
              <XCircle :size="16" class="mr-1 text-danger" />
              驳回申诉
            </el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="结果说明">
          <el-input
            v-model="processForm.result"
            type="textarea"
            :rows="3"
            placeholder="请输入处理结果说明..."
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="processDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleProcessAppeal">确认处理</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.violations-page {
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
    font-size: $font-size-sm;
  }
  
  .text-success {
    color: $success;
  }
  
  .text-danger {
    color: $error;
  }
  
  h4 {
    margin: 0 0 $spacing-4 0;
    color: $text-primary;
  }
}
</style>
