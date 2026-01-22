<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Target,
  Plus,
  Clock,
  Check,
  X,
  Trophy,
  Gift,
  TrendingUp
} from 'lucide-vue-next'
import {
  getGoals,
  getActiveGoals,
  getGoalStats,
  createGoal,
  claimGoalReward,
  cancelGoal,
  getGoalTypeLabel,
  getUnitLabel,
  getStatusConfig,
  GOAL_TYPES,
  type StudyGoal,
  type GoalStats,
  type CreateGoalParams
} from '@/api/goal'

// 数据
const loading = ref(false)
const goals = ref<StudyGoal[]>([])
const activeGoals = ref<StudyGoal[]>([])
const stats = ref<GoalStats | null>(null)
const total = ref(0)

// 筛选
const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  status: '',
  type: ''
})

// 创建表单
const createDialogVisible = ref(false)
const createForm = ref<CreateGoalParams>({
  name: '',
  type: 'DAILY_HOURS',
  targetValue: 4,
  unit: 'HOUR',
  startDate: '',
  endDate: '',
  description: ''
})

// 加载目标列表
const loadGoals = async () => {
  loading.value = true
  try {
    const res = await getGoals(queryParams.value)
    goals.value = res.records
    total.value = res.total
  } catch (error) {
    console.error('加载目标失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载进行中的目标
const loadActiveGoals = async () => {
  try {
    activeGoals.value = await getActiveGoals()
  } catch (error) {
    console.error('加载进行中目标失败:', error)
  }
}

// 加载统计
const loadStats = async () => {
  try {
    stats.value = await getGoalStats()
  } catch (error) {
    console.error('加载统计失败:', error)
  }
}

// 打开创建弹窗
const openCreateDialog = () => {
  const today = new Date()
  const nextWeek = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)
  
  createForm.value = {
    name: '',
    type: 'DAILY_HOURS',
    targetValue: 4,
    unit: 'HOUR',
    startDate: today.toISOString().split('T')[0],
    endDate: nextWeek.toISOString().split('T')[0],
    description: ''
  }
  createDialogVisible.value = true
}

// 创建目标
const handleCreate = async () => {
  if (!createForm.value.name.trim()) {
    ElMessage.warning('请输入目标名称')
    return
  }
  if (!createForm.value.targetValue || createForm.value.targetValue <= 0) {
    ElMessage.warning('请输入有效的目标值')
    return
  }
  
  try {
    await createGoal(createForm.value)
    ElMessage.success('目标创建成功')
    createDialogVisible.value = false
    loadGoals()
    loadActiveGoals()
    loadStats()
  } catch (error) {
    // 错误已在拦截器中处理
  }
}

// 领取奖励
const handleClaimReward = async (goal: StudyGoal) => {
  try {
    const result = await claimGoalReward(goal.id)
    ElMessage.success(`领取成功！获得${result.points}积分，${result.exp}经验`)
    loadGoals()
    loadActiveGoals()
  } catch (error) {
    // 错误已在拦截器中处理
  }
}

// 取消目标
const handleCancel = async (goal: StudyGoal) => {
  try {
    await ElMessageBox.confirm('确定要取消该目标吗？', '提示', {
      type: 'warning'
    })
    
    await cancelGoal(goal.id)
    ElMessage.success('目标已取消')
    loadGoals()
    loadActiveGoals()
    loadStats()
  } catch {
    // 用户取消
  }
}

// 类型变化时更新单位
const handleTypeChange = (type: string) => {
  const found = GOAL_TYPES.find(t => t.value === type)
  if (found) {
    createForm.value.unit = found.unit
  }
}

// 获取进度条颜色
const getProgressColor = (percent: number) => {
  if (percent >= 100) return '#00C48C'
  if (percent >= 60) return '#3FB19E'
  if (percent >= 30) return '#FFB020'
  return '#FF4D4F'
}

// 状态选项
const statusOptions = [
  { value: '', label: '全部状态' },
  { value: 'ACTIVE', label: '进行中' },
  { value: 'COMPLETED', label: '已完成' },
  { value: 'FAILED', label: '未完成' },
  { value: 'CANCELLED', label: '已取消' }
]

onMounted(() => {
  loadGoals()
  loadActiveGoals()
  loadStats()
})
</script>

<template>
  <div class="goals-page">
    <!-- 统计卡片 -->
    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-icon total">
          <Target :size="24" />
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats?.totalGoals || 0 }}</span>
          <span class="stat-label">总目标数</span>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon active">
          <TrendingUp :size="24" />
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats?.activeGoals || 0 }}</span>
          <span class="stat-label">进行中</span>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon completed">
          <Trophy :size="24" />
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats?.completedGoals || 0 }}</span>
          <span class="stat-label">已完成</span>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon rate">
          <Check :size="24" />
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats?.completionRate || 0 }}%</span>
          <span class="stat-label">完成率</span>
        </div>
      </div>
    </div>
    
    <!-- 进行中的目标 -->
    <div class="active-goals" v-if="activeGoals.length > 0">
      <h3 class="section-title">
        <TrendingUp :size="20" />
        进行中的目标
      </h3>
      <div class="goal-cards">
        <div v-for="goal in activeGoals" :key="goal.id" class="goal-card active">
          <div class="goal-header">
            <span class="goal-name">{{ goal.name }}</span>
            <el-tag type="primary" size="small">{{ getGoalTypeLabel(goal.type) }}</el-tag>
          </div>
          <div class="goal-progress">
            <el-progress
              :percentage="goal.progressPercent"
              :color="getProgressColor(goal.progressPercent || 0)"
              :stroke-width="10"
            />
            <span class="progress-text">
              {{ goal.currentValue }} / {{ goal.targetValue }} {{ getUnitLabel(goal.type) }}
            </span>
          </div>
          <div class="goal-footer">
            <span class="remaining" v-if="goal.remainingDays !== undefined && goal.remainingDays >= 0">
              <Clock :size="14" />
              剩余{{ goal.remainingDays }}天
            </span>
            <span class="reward">
              <Gift :size="14" />
              {{ goal.rewardPoints }}积分
            </span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 目标列表 -->
    <div class="goals-list">
      <div class="list-header">
        <h3 class="section-title">
          <Target :size="20" />
          全部目标
        </h3>
        <div class="header-actions">
          <el-select v-model="queryParams.status" placeholder="状态" clearable @change="loadGoals">
            <el-option
              v-for="opt in statusOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
          <el-button type="primary" @click="openCreateDialog">
            <Plus :size="16" />
            创建目标
          </el-button>
        </div>
      </div>
      
      <el-table :data="goals" v-loading="loading" stripe>
        <el-table-column prop="name" label="目标名称" min-width="180" />
        <el-table-column label="类型" width="120">
          <template #default="{ row }">
            {{ getGoalTypeLabel(row.type) }}
          </template>
        </el-table-column>
        <el-table-column label="进度" width="200">
          <template #default="{ row }">
            <el-progress
              :percentage="row.progressPercent || 0"
              :color="getProgressColor(row.progressPercent || 0)"
              :stroke-width="8"
              :format="() => `${row.currentValue}/${row.targetValue}`"
            />
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusConfig(row.status).type" size="small">
              {{ getStatusConfig(row.status).label }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="奖励" width="120" align="center">
          <template #default="{ row }">
            <span class="reward-text">{{ row.rewardPoints }}积分</span>
          </template>
        </el-table-column>
        <el-table-column prop="endDate" label="截止日期" width="120" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 'COMPLETED' && row.rewardClaimed === 0"
              link
              type="success"
              size="small"
              @click="handleClaimReward(row)"
            >
              <Gift :size="14" />
              领取奖励
            </el-button>
            <el-button
              v-else-if="row.status === 'ACTIVE'"
              link
              type="danger"
              size="small"
              @click="handleCancel(row)"
            >
              <X :size="14" />
              取消
            </el-button>
            <span v-else-if="row.rewardClaimed === 1" class="text-muted">已领取</span>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination" v-if="total > 0">
        <el-pagination
          background
          layout="total, prev, pager, next"
          :total="total"
          :page-size="queryParams.pageSize"
          :current-page="queryParams.pageNum"
          @current-change="(page: number) => { queryParams.pageNum = page; loadGoals() }"
        />
      </div>
    </div>
    
    <!-- 创建目标弹窗 -->
    <el-dialog v-model="createDialogVisible" title="创建学习目标" width="500px">
      <el-form label-width="100px">
        <el-form-item label="目标名称" required>
          <el-input v-model="createForm.name" placeholder="例如：每天学习4小时" />
        </el-form-item>
        <el-form-item label="目标类型" required>
          <el-select v-model="createForm.type" @change="handleTypeChange" style="width: 100%">
            <el-option
              v-for="opt in GOAL_TYPES"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="目标值" required>
          <el-input-number
            v-model="createForm.targetValue"
            :min="1"
            :max="1000"
            style="width: 200px"
          />
          <span class="unit-label">{{ getUnitLabel(createForm.type) }}</span>
        </el-form-item>
        <el-form-item label="开始日期">
          <el-date-picker
            v-model="createForm.startDate"
            type="date"
            value-format="YYYY-MM-DD"
            placeholder="选择开始日期"
          />
        </el-form-item>
        <el-form-item label="结束日期">
          <el-date-picker
            v-model="createForm.endDate"
            type="date"
            value-format="YYYY-MM-DD"
            placeholder="选择结束日期"
          />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="createForm.description"
            type="textarea"
            :rows="2"
            placeholder="可选的目标描述..."
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleCreate">创建目标</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.goals-page {
  .stats-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: $spacing-4;
    margin-bottom: $spacing-6;
    
    @media (max-width: 768px) {
      grid-template-columns: repeat(2, 1fr);
    }
    
    .stat-card {
      background: white;
      border-radius: $radius-lg;
      padding: $spacing-4;
      display: flex;
      align-items: center;
      gap: $spacing-3;
      
      .stat-icon {
        width: 48px;
        height: 48px;
        border-radius: $radius-md;
        display: flex;
        align-items: center;
        justify-content: center;
        
        &.total { background: $primary-light; color: $primary; }
        &.active { background: $blue-light; color: $blue; }
        &.completed { background: $success-light; color: $success; }
        &.rate { background: $purple-light; color: $purple; }
      }
      
      .stat-info {
        display: flex;
        flex-direction: column;
        
        .stat-value {
          font-size: $font-size-xl;
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
  
  .section-title {
    display: flex;
    align-items: center;
    gap: $spacing-2;
    margin: 0 0 $spacing-4 0;
    font-size: $font-size-lg;
    font-weight: $font-weight-semibold;
    color: $text-primary;
  }
  
  .active-goals {
    background: white;
    border-radius: $radius-lg;
    padding: $spacing-6;
    margin-bottom: $spacing-6;
    
    .goal-cards {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: $spacing-4;
    }
    
    .goal-card {
      background: $gray-50;
      border-radius: $radius-md;
      padding: $spacing-4;
      
      &.active {
        border-left: 4px solid $primary;
      }
      
      .goal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: $spacing-3;
        
        .goal-name {
          font-weight: $font-weight-semibold;
          color: $text-primary;
        }
      }
      
      .goal-progress {
        margin-bottom: $spacing-3;
        
        .progress-text {
          display: block;
          margin-top: $spacing-1;
          font-size: $font-size-sm;
          color: $text-muted;
          text-align: right;
        }
      }
      
      .goal-footer {
        display: flex;
        justify-content: space-between;
        font-size: $font-size-sm;
        color: $text-secondary;
        
        .remaining, .reward {
          display: flex;
          align-items: center;
          gap: $spacing-1;
        }
      }
    }
  }
  
  .goals-list {
    background: white;
    border-radius: $radius-lg;
    padding: $spacing-6;
    
    .list-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: $spacing-4;
      
      .header-actions {
        display: flex;
        gap: $spacing-3;
      }
    }
    
    .reward-text {
      color: $accent-orange;
      font-weight: $font-weight-medium;
    }
    
    .text-muted {
      color: $text-muted;
      font-size: $font-size-sm;
    }
    
    .pagination {
      margin-top: $spacing-4;
      display: flex;
      justify-content: flex-end;
    }
  }
  
  .unit-label {
    margin-left: $spacing-2;
    color: $text-muted;
  }
}
</style>
