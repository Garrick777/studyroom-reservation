<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Search,
  RefreshCw,
  Plus,
  Unlock,
  UserX
} from 'lucide-vue-next'
import {
  getBlacklist,
  addToBlacklist,
  releaseFromBlacklist,
  type Blacklist
} from '@/api/credit'

// 列表数据
const loading = ref(false)
const blacklist = ref<Blacklist[]>([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  released: undefined as number | undefined,
  keyword: ''
})

// 添加弹窗
const addDialogVisible = ref(false)
const addForm = reactive({
  userId: undefined as number | undefined,
  reason: '',
  durationDays: 7
})

// 加载黑名单
const loadBlacklist = async () => {
  loading.value = true
  try {
    const res = await getBlacklist(queryParams)
    blacklist.value = res.records
    total.value = res.total
  } catch (error) {
    console.error('加载黑名单失败:', error)
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  queryParams.pageNum = 1
  loadBlacklist()
}

// 重置
const handleReset = () => {
  queryParams.released = undefined
  queryParams.keyword = ''
  queryParams.pageNum = 1
  loadBlacklist()
}

// 打开添加弹窗
const openAddDialog = () => {
  addForm.userId = undefined
  addForm.reason = ''
  addForm.durationDays = 7
  addDialogVisible.value = true
}

// 添加黑名单
const handleAddBlacklist = async () => {
  if (!addForm.userId) {
    ElMessage.warning('请输入用户ID')
    return
  }
  if (!addForm.reason.trim()) {
    ElMessage.warning('请输入原因')
    return
  }
  
  try {
    await addToBlacklist({
      userId: addForm.userId,
      reason: addForm.reason,
      durationDays: addForm.durationDays > 0 ? addForm.durationDays : undefined
    })
    ElMessage.success('添加成功')
    addDialogVisible.value = false
    loadBlacklist()
  } catch (error) {
    console.error('添加失败:', error)
  }
}

// 解除黑名单
const handleRelease = async (row: Blacklist) => {
  try {
    await ElMessageBox.prompt('请输入解除原因', '解除黑名单', {
      confirmButtonText: '确认解除',
      cancelButtonText: '取消',
      inputPlaceholder: '解除原因...'
    }).then(async ({ value }) => {
      await releaseFromBlacklist(row.userId, value || '管理员手动解除')
      ElMessage.success('解除成功')
      loadBlacklist()
    })
  } catch {
    // 取消操作
  }
}

// 获取状态标签
const getStatusTag = (row: Blacklist) => {
  if (row.released === 1) {
    return { type: 'info', text: '已解除' }
  }
  if (row.endTime && new Date(row.endTime) < new Date()) {
    return { type: 'warning', text: '已过期' }
  }
  return { type: 'danger', text: '生效中' }
}

// 状态选项
const statusOptions = [
  { label: '全部', value: undefined },
  { label: '生效中', value: 0 },
  { label: '已解除', value: 1 }
]

onMounted(() => {
  loadBlacklist()
})
</script>

<template>
  <div class="blacklist-page">
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="关键词">
          <el-input
            v-model="queryParams.keyword"
            placeholder="姓名/学号"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.released" placeholder="全部" clearable>
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
          <span>黑名单列表</span>
          <el-button type="danger" @click="openAddDialog">
            <Plus :size="16" class="mr-1" />
            添加黑名单
          </el-button>
        </div>
      </template>
      
      <el-table :data="blacklist" v-loading="loading" stripe table-layout="fixed">
        <el-table-column label="用户" width="140">
          <template #default="{ row }">
            <div v-if="row.user">
              <div>{{ row.user.username }}</div>
              <small class="text-muted">{{ row.user.studentNo }}</small>
            </div>
            <span v-else>ID: {{ row.userId }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="reason" label="原因" min-width="150" show-overflow-tooltip />
        <el-table-column label="信用分" width="80" align="center">
          <template #default="{ row }">
            <el-tag type="danger" size="small">{{ row.creditScoreWhenAdded || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="startTime" label="开始时间" width="160" show-overflow-tooltip />
        <el-table-column label="结束时间" width="160" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.endTime || '永久' }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row).type" size="small">
              {{ getStatusTag(row).text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="解除信息" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">
            <template v-if="row.released === 1">
              <div class="text-muted">{{ row.releaseTime }}</div>
              <div class="text-muted">{{ row.releaseReason }}</div>
            </template>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="80" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.released === 0"
              link
              type="success"
              size="small"
              @click="handleRelease(row)"
            >
              <Unlock :size="14" />
              解除
            </el-button>
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
          @current-change="(page: number) => { queryParams.pageNum = page; loadBlacklist() }"
        />
      </div>
    </el-card>
    
    <!-- 添加黑名单弹窗 -->
    <el-dialog v-model="addDialogVisible" title="添加黑名单" width="500px">
      <el-form label-width="100px">
        <el-form-item label="用户ID" required>
          <el-input-number
            v-model="addForm.userId"
            :min="1"
            placeholder="请输入用户ID"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="原因" required>
          <el-input
            v-model="addForm.reason"
            type="textarea"
            :rows="3"
            placeholder="请输入加入黑名单的原因..."
          />
        </el-form-item>
        <el-form-item label="时长(天)">
          <el-input-number
            v-model="addForm.durationDays"
            :min="0"
            placeholder="0表示永久"
          />
          <span class="tip">0或留空表示永久</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addDialogVisible = false">取消</el-button>
        <el-button type="danger" @click="handleAddBlacklist">
          <UserX :size="16" class="mr-1" />
          确认添加
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.blacklist-page {
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
  
  .tip {
    color: $text-muted;
    font-size: $font-size-sm;
    margin-left: $spacing-2;
  }
}
</style>
