<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Trophy,
  TrendingUp,
  TrendingDown,
  AlertTriangle,
  Clock,
  CheckCircle,
  XCircle,
  Shield,
  FileText
} from 'lucide-vue-next'
import {
  getCreditStats,
  getCreditRecords,
  getViolations,
  submitAppeal,
  type CreditStats,
  type CreditRecord,
  type ViolationRecord
} from '@/api/credit'

// 信用统计
const stats = ref<CreditStats | null>(null)
const loading = ref(false)

// 积分记录
const creditRecords = ref<CreditRecord[]>([])
const creditLoading = ref(false)
const creditTotal = ref(0)
const creditPage = ref(1)

// 违约记录
const violations = ref<ViolationRecord[]>([])
const violationLoading = ref(false)
const violationTotal = ref(0)
const violationPage = ref(1)

// 申诉弹窗
const appealDialogVisible = ref(false)
const appealForm = ref({
  violationId: 0,
  reason: ''
})

// 当前选项卡
const activeTab = ref('records')

// 计算信用等级
const creditLevel = computed(() => {
  if (!stats.value) return { name: '未知', color: '#999' }
  const score = stats.value.currentScore
  if (score >= 90) return { name: '信用极好', color: '#00C48C' }
  if (score >= 80) return { name: '信用良好', color: '#52c41a' }
  if (score >= 70) return { name: '信用一般', color: '#faad14' }
  if (score >= 60) return { name: '信用较低', color: '#ff7a45' }
  return { name: '信用很差', color: '#ff4d4f' }
})

// 计算分数颜色
const scoreColor = computed(() => {
  if (!stats.value) return '#999'
  const score = stats.value.currentScore
  if (score >= 80) return '#00C48C'
  if (score >= 60) return '#faad14'
  return '#ff4d4f'
})

// 加载信用统计
const loadStats = async () => {
  loading.value = true
  try {
    stats.value = await getCreditStats()
  } catch (error) {
    console.error('加载信用统计失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载积分记录
const loadCreditRecords = async () => {
  creditLoading.value = true
  try {
    const res = await getCreditRecords({
      pageNum: creditPage.value,
      pageSize: 10
    })
    creditRecords.value = res.records
    creditTotal.value = res.total
  } catch (error) {
    console.error('加载积分记录失败:', error)
  } finally {
    creditLoading.value = false
  }
}

// 加载违约记录
const loadViolations = async () => {
  violationLoading.value = true
  try {
    const res = await getViolations({
      pageNum: violationPage.value,
      pageSize: 10
    })
    violations.value = res.records
    violationTotal.value = res.total
  } catch (error) {
    console.error('加载违约记录失败:', error)
  } finally {
    violationLoading.value = false
  }
}

// 打开申诉弹窗
const openAppealDialog = (violation: ViolationRecord) => {
  if (violation.appealStatus !== 0) {
    ElMessage.warning('该违约记录已申诉或申诉已处理')
    return
  }
  appealForm.value = {
    violationId: violation.id,
    reason: ''
  }
  appealDialogVisible.value = true
}

// 提交申诉
const handleSubmitAppeal = async () => {
  if (!appealForm.value.reason.trim()) {
    ElMessage.warning('请输入申诉理由')
    return
  }
  
  try {
    await submitAppeal(appealForm.value.violationId, appealForm.value.reason)
    ElMessage.success('申诉提交成功')
    appealDialogVisible.value = false
    loadViolations()
  } catch (error) {
    console.error('申诉提交失败:', error)
  }
}

// 获取变动类型标签
const getChangeTypeTag = (record: CreditRecord) => {
  if (record.changeScore > 0) {
    return { type: 'success', text: '+' + record.changeScore }
  }
  return { type: 'danger', text: record.changeScore.toString() }
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

// 切换选项卡
const handleTabChange = (tab: string) => {
  if (tab === 'records' && creditRecords.value.length === 0) {
    loadCreditRecords()
  } else if (tab === 'violations' && violations.value.length === 0) {
    loadViolations()
  }
}

onMounted(() => {
  loadStats()
})
</script>

<template>
  <div class="credit-page">
    <!-- 信用积分概览 -->
    <div class="credit-overview" v-loading="loading">
      <div class="score-card">
        <div class="score-ring">
          <el-progress
            type="circle"
            :percentage="stats?.currentScore || 0"
            :width="180"
            :stroke-width="12"
            :color="scoreColor"
          >
            <template #default>
              <div class="score-content">
                <span class="score-number">{{ stats?.currentScore || 0 }}</span>
                <span class="score-label">信用分</span>
              </div>
            </template>
          </el-progress>
        </div>
        <div class="credit-level" :style="{ color: creditLevel.color }">
          <Shield :size="20" />
          <span>{{ creditLevel.name }}</span>
        </div>
      </div>
      
      <div class="stats-grid">
        <div class="stat-item">
          <div class="stat-icon gain">
            <TrendingUp :size="24" />
          </div>
          <div class="stat-info">
            <span class="stat-value">+{{ stats?.totalGain || 0 }}</span>
            <span class="stat-label">累计获得</span>
          </div>
        </div>
        
        <div class="stat-item">
          <div class="stat-icon loss">
            <TrendingDown :size="24" />
          </div>
          <div class="stat-info">
            <span class="stat-value">-{{ stats?.totalLoss || 0 }}</span>
            <span class="stat-label">累计扣除</span>
          </div>
        </div>
        
        <div class="stat-item">
          <div class="stat-icon violation">
            <AlertTriangle :size="24" />
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ stats?.violationCount || 0 }}</span>
            <span class="stat-label">违约次数</span>
          </div>
        </div>
      </div>
      
      <!-- 黑名单警告 -->
      <div v-if="stats?.isBlacklisted" class="blacklist-warning">
        <AlertTriangle :size="20" />
        <span>您当前在黑名单中，暂时无法预约座位</span>
        <span v-if="stats.blacklistEndTime" class="end-time">
          解除时间：{{ stats.blacklistEndTime }}
        </span>
      </div>
    </div>
    
    <!-- 选项卡 -->
    <el-tabs v-model="activeTab" @tab-change="handleTabChange" class="credit-tabs">
      <el-tab-pane label="积分记录" name="records">
        <div class="records-list" v-loading="creditLoading">
          <div v-if="creditRecords.length === 0" class="empty-state">
            <FileText :size="48" />
            <p>暂无积分记录</p>
          </div>
          
          <div v-else class="timeline">
            <div
              v-for="record in creditRecords"
              :key="record.id"
              class="timeline-item"
            >
              <div class="timeline-icon" :class="record.changeScore > 0 ? 'gain' : 'loss'">
                <TrendingUp v-if="record.changeScore > 0" :size="16" />
                <TrendingDown v-else :size="16" />
              </div>
              <div class="timeline-content">
                <div class="timeline-header">
                  <span class="description">{{ record.description }}</span>
                  <el-tag
                    :type="record.changeScore > 0 ? 'success' : 'danger'"
                    size="small"
                  >
                    {{ record.changeScore > 0 ? '+' : '' }}{{ record.changeScore }}
                  </el-tag>
                </div>
                <div class="timeline-meta">
                  <span class="score-change">
                    {{ record.beforeScore }} → {{ record.afterScore }}
                  </span>
                  <span class="time">{{ record.createdAt }}</span>
                </div>
              </div>
            </div>
          </div>
          
          <div v-if="creditRecords.length > 0" class="pagination">
            <el-pagination
              v-model:current-page="creditPage"
              :total="creditTotal"
              :page-size="10"
              layout="prev, pager, next"
              @current-change="loadCreditRecords"
            />
          </div>
        </div>
      </el-tab-pane>
      
      <el-tab-pane label="违约记录" name="violations">
        <div class="violations-list" v-loading="violationLoading">
          <div v-if="violations.length === 0" class="empty-state">
            <CheckCircle :size="48" />
            <p>无违约记录，继续保持！</p>
          </div>
          
          <el-table v-else :data="violations" stripe>
            <el-table-column label="违约类型" width="140">
              <template #default="{ row }">
                {{ getViolationTypeText(row.type) }}
              </template>
            </el-table-column>
            <el-table-column prop="description" label="描述" min-width="200" />
            <el-table-column label="扣分" width="80" align="center">
              <template #default="{ row }">
                <el-tag type="danger" size="small">-{{ row.deductScore }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="申诉状态" width="100" align="center">
              <template #default="{ row }">
                <el-tag :type="getAppealStatusTag(row.appealStatus).type" size="small">
                  {{ getAppealStatusTag(row.appealStatus).text }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="时间" width="180" />
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button
                  v-if="row.appealStatus === 0"
                  link
                  type="primary"
                  size="small"
                  @click="openAppealDialog(row)"
                >
                  申诉
                </el-button>
                <span v-else-if="row.appealStatus === 1" class="text-warning">
                  等待处理
                </span>
                <span v-else-if="row.appealStatus === 2" class="text-success">
                  {{ row.appealResult }}
                </span>
                <span v-else class="text-danger">
                  {{ row.appealResult }}
                </span>
              </template>
            </el-table-column>
          </el-table>
          
          <div v-if="violations.length > 0" class="pagination">
            <el-pagination
              v-model:current-page="violationPage"
              :total="violationTotal"
              :page-size="10"
              layout="prev, pager, next"
              @current-change="loadViolations"
            />
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
    
    <!-- 申诉弹窗 -->
    <el-dialog v-model="appealDialogVisible" title="提交申诉" width="500px">
      <el-form label-width="80px">
        <el-form-item label="申诉理由">
          <el-input
            v-model="appealForm.reason"
            type="textarea"
            :rows="4"
            placeholder="请详细说明申诉理由..."
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="appealDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitAppeal">提交申诉</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.credit-page {
  .credit-overview {
    background: white;
    border-radius: $radius-lg;
    padding: $spacing-6;
    margin-bottom: $spacing-6;
    
    display: flex;
    align-items: center;
    gap: $spacing-8;
    
    @media (max-width: 768px) {
      flex-direction: column;
    }
  }
  
  .score-card {
    text-align: center;
    
    .score-ring {
      margin-bottom: $spacing-4;
    }
    
    .score-content {
      display: flex;
      flex-direction: column;
      
      .score-number {
        font-size: 42px;
        font-weight: $font-weight-bold;
        color: $text-primary;
        line-height: 1;
      }
      
      .score-label {
        font-size: $font-size-sm;
        color: $text-muted;
        margin-top: $spacing-1;
      }
    }
    
    .credit-level {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: $spacing-2;
      font-size: $font-size-md;
      font-weight: $font-weight-semibold;
    }
  }
  
  .stats-grid {
    flex: 1;
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: $spacing-4;
    
    @media (max-width: 768px) {
      width: 100%;
    }
    
    .stat-item {
      display: flex;
      align-items: center;
      gap: $spacing-3;
      padding: $spacing-4;
      background: $gray-50;
      border-radius: $radius-md;
      
      .stat-icon {
        width: 48px;
        height: 48px;
        border-radius: $radius-sm;
        display: flex;
        align-items: center;
        justify-content: center;
        
        &.gain {
          background: $success-light;
          color: $success;
        }
        
        &.loss {
          background: $error-light;
          color: $error;
        }
        
        &.violation {
          background: $warning-light;
          color: $warning;
        }
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
  
  .blacklist-warning {
    margin-top: $spacing-4;
    padding: $spacing-4;
    background: $error-light;
    border: 1px solid $error;
    border-radius: $radius-sm;
    color: $error;
    display: flex;
    align-items: center;
    gap: $spacing-2;
    
    .end-time {
      margin-left: auto;
      font-size: $font-size-sm;
    }
  }
  
  .credit-tabs {
    background: white;
    border-radius: $radius-lg;
    padding: $spacing-4;
    
    :deep(.el-tabs__header) {
      margin-bottom: $spacing-4;
    }
  }
  
  .empty-state {
    text-align: center;
    padding: $spacing-10;
    color: $text-muted;
    
    svg {
      margin-bottom: $spacing-3;
    }
    
    p {
      margin: 0;
    }
  }
  
  .timeline {
    .timeline-item {
      display: flex;
      gap: $spacing-4;
      padding: $spacing-4 0;
      border-bottom: 1px solid $border-light;
      
      &:last-child {
        border-bottom: none;
      }
      
      .timeline-icon {
        width: 32px;
        height: 32px;
        border-radius: $radius-full;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        
        &.gain {
          background: $success-light;
          color: $success;
        }
        
        &.loss {
          background: $error-light;
          color: $error;
        }
      }
      
      .timeline-content {
        flex: 1;
        
        .timeline-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          
          .description {
            font-weight: $font-weight-medium;
            color: $text-primary;
          }
        }
        
        .timeline-meta {
          margin-top: $spacing-1;
          font-size: $font-size-sm;
          color: $text-muted;
          display: flex;
          gap: $spacing-4;
        }
      }
    }
  }
  
  .pagination {
    margin-top: $spacing-4;
    display: flex;
    justify-content: center;
  }
  
  .text-warning {
    color: $warning;
    font-size: $font-size-sm;
  }
  
  .text-success {
    color: $success;
    font-size: $font-size-sm;
  }
  
  .text-danger {
    color: $error;
    font-size: $font-size-sm;
  }
}
</style>
