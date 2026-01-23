<template>
  <div class="achievements-management">
    <div class="page-header">
      <h2>成就管理</h2>
      <el-button type="primary" @click="showCreateDialog">
        <el-icon><Plus /></el-icon>
        新增成就
      </el-button>
    </div>

    <!-- 筛选栏 -->
    <div class="filter-bar">
      <el-select v-model="filters.category" placeholder="分类" clearable style="width: 140px">
        <el-option label="学习成就" value="STUDY" />
        <el-option label="打卡成就" value="CHECKIN" />
        <el-option label="预约成就" value="RESERVATION" />
        <el-option label="社交成就" value="SOCIAL" />
        <el-option label="特殊成就" value="SPECIAL" />
        <el-option label="信用成就" value="CREDIT" />
        <el-option label="目标成就" value="GOAL" />
        <el-option label="积分成就" value="POINTS" />
      </el-select>
      <el-select v-model="filters.rarity" placeholder="稀有度" clearable style="width: 120px">
        <el-option label="普通" value="COMMON" />
        <el-option label="稀有" value="RARE" />
        <el-option label="史诗" value="EPIC" />
        <el-option label="传说" value="LEGENDARY" />
      </el-select>
      <el-input 
        v-model="filters.keyword" 
        placeholder="搜索成就名称" 
        clearable 
        style="width: 200px"
        @keyup.enter="loadData"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
      </el-input>
      <el-button type="primary" @click="loadData">搜索</el-button>
      <el-button @click="resetFilters">重置</el-button>
    </div>

    <!-- 成就表格 -->
    <el-table :data="achievements" v-loading="loading" table-layout="fixed">
      <el-table-column label="成就" min-width="280">
        <template #default="{ row }">
          <div class="achievement-cell">
            <div class="achievement-icon" :style="{ backgroundColor: row.badgeColor }">
              <span v-if="isEmoji(row.icon)">{{ row.icon }}</span>
              <Icon v-else :icon="formatIconName(row.icon)" :width="24" :height="24" color="#fff" />
            </div>
            <div class="achievement-info">
              <div class="achievement-name">{{ row.name }}</div>
              <div class="achievement-desc">{{ row.description }}</div>
            </div>
          </div>
        </template>
      </el-table-column>
      
      <el-table-column label="分类" width="100">
        <template #default="{ row }">
          <el-tag :type="getCategoryType(row.category)" size="small">
            {{ getCategoryNameLocal(row.category) }}
          </el-tag>
        </template>
      </el-table-column>
      
      <el-table-column label="稀有度" width="80">
        <template #default="{ row }">
          <span :class="['rarity-badge', row.rarity?.toLowerCase()]">
            {{ getRarityName(row.rarity) }}
          </span>
        </template>
      </el-table-column>
      
      <el-table-column label="达成条件" min-width="140">
        <template #default="{ row }">
          <div class="condition-text">
            {{ getConditionTypeName(row.conditionType) }} ≥ {{ row.conditionValue }}
          </div>
        </template>
      </el-table-column>
      
      <el-table-column label="奖励" width="100">
        <template #default="{ row }">
          <div class="reward-cell">
            <span>💰{{ row.rewardPoints }}</span>
            <span>✨{{ row.rewardExp }}</span>
          </div>
        </template>
      </el-table-column>
      
      <el-table-column label="隐藏" width="60">
        <template #default="{ row }">
          <el-tag :type="row.isHidden ? 'warning' : 'info'" size="small">
            {{ row.isHidden ? '是' : '否' }}
          </el-tag>
        </template>
      </el-table-column>
      
      <el-table-column label="状态" width="70">
        <template #default="{ row }">
          <el-switch 
            v-model="row.status" 
            :active-value="1" 
            :inactive-value="0"
            @change="handleToggleStatus(row)"
          />
        </template>
      </el-table-column>
      
      <el-table-column label="操作" width="120" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link size="small" @click="showEditDialog(row)">
            编辑
          </el-button>
          <el-popconfirm 
            title="确定要删除此成就吗？" 
            @confirm="handleDelete(row.id)"
          >
            <template #reference>
              <el-button type="danger" link size="small">删除</el-button>
            </template>
          </el-popconfirm>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination-wrapper">
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next"
        @size-change="loadData"
        @current-change="loadData"
      />
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog 
      v-model="dialogVisible" 
      :title="isEdit ? '编辑成就' : '新增成就'"
      width="600px"
    >
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="成就名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入成就名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="图标" prop="icon">
              <el-input v-model="form.icon" placeholder="请输入emoji图标">
                <template #append>
                  <span style="font-size: 20px">{{ form.icon }}</span>
                </template>
              </el-input>
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="成就描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入成就描述" />
        </el-form-item>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="分类" prop="category">
              <el-select v-model="form.category" placeholder="请选择分类" style="width: 100%">
                <el-option label="学习成就" value="STUDY" />
                <el-option label="打卡成就" value="CHECK_IN" />
                <el-option label="社交成就" value="SOCIAL" />
                <el-option label="特殊成就" value="SPECIAL" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="稀有度" prop="rarity">
              <el-select v-model="form.rarity" placeholder="请选择稀有度" style="width: 100%">
                <el-option label="普通" value="COMMON" />
                <el-option label="稀有" value="RARE" />
                <el-option label="史诗" value="EPIC" />
                <el-option label="传说" value="LEGENDARY" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="条件类型" prop="conditionType">
              <el-select v-model="form.conditionType" placeholder="请选择条件类型" style="width: 100%">
                <el-option label="累计预约次数" value="TOTAL_RESERVATIONS" />
                <el-option label="累计学习时长" value="TOTAL_HOURS" />
                <el-option label="累计打卡次数" value="TOTAL_CHECK_INS" />
                <el-option label="连续打卡天数" value="CONTINUOUS_CHECK_INS" />
                <el-option label="好友数量" value="TOTAL_FRIENDS" />
                <el-option label="创建小组" value="CREATE_GROUP" />
                <el-option label="早起签到次数" value="EARLY_SIGN_IN" />
                <el-option label="晚间签退次数" value="LATE_SIGN_OUT" />
                <el-option label="连续无违约次数" value="NO_VIOLATION_STREAK" />
                <el-option label="周末学习次数" value="WEEKEND_STUDY" />
                <el-option label="完成目标数" value="GOALS_COMPLETED" />
                <el-option label="评价数量" value="TOTAL_REVIEWS" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="条件值" prop="conditionValue">
              <el-input-number v-model="form.conditionValue" :min="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="奖励积分" prop="rewardPoints">
              <el-input-number v-model="form.rewardPoints" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="奖励经验" prop="rewardExp">
              <el-input-number v-model="form.rewardExp" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="徽章颜色">
              <el-color-picker v-model="form.badgeColor" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序">
              <el-input-number v-model="form.sortOrder" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        
        <el-form-item label="隐藏成就">
          <el-switch v-model="form.isHidden" :active-value="1" :inactive-value="0" />
          <span class="form-hint">隐藏成就在解锁前不会显示给用户</span>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          {{ isEdit ? '保存' : '创建' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { Plus, Search } from '@element-plus/icons-vue'
import { Icon } from '@iconify/vue'
import {
  getAdminAchievements,
  createAchievement,
  updateAchievement,
  deleteAchievement,
  toggleAchievementStatus,
  getCategoryName,
  getRarityName,
  type Achievement
} from '@/api/achievement'

// 将 mdi-xxx-xxx 转换为 mdi:xxx-xxx 格式
const formatIconName = (icon: string): string => {
  if (!icon) return 'mdi:trophy'
  // 如果已经是 mdi: 格式，直接返回
  if (icon.startsWith('mdi:')) return icon
  // 将 mdi-xxx 转换为 mdi:xxx
  if (icon.startsWith('mdi-')) return 'mdi:' + icon.slice(4)
  // 如果是 emoji 或其他，返回默认图标
  if (icon.length <= 2) return icon // emoji
  return 'mdi:' + icon
}

// 检查是否是 emoji
const isEmoji = (str: string): boolean => {
  if (!str) return false
  return str.length <= 2 || /\p{Extended_Pictographic}/u.test(str)
}

// 状态
const loading = ref(false)
const achievements = ref<Achievement[]>([])
const filters = reactive({
  category: '',
  rarity: '',
  keyword: ''
})
const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

// 弹窗状态
const dialogVisible = ref(false)
const isEdit = ref(false)
const submitting = ref(false)
const formRef = ref<FormInstance>()

const defaultForm = {
  name: '',
  description: '',
  icon: '🏆',
  badgeColor: '#4CAF50',
  category: 'STUDY',
  conditionType: 'TOTAL_RESERVATIONS',
  conditionValue: 1,
  rewardPoints: 10,
  rewardExp: 20,
  rarity: 'COMMON',
  isHidden: 0,
  sortOrder: 0
}

const form = reactive({ ...defaultForm })

const formRules: FormRules = {
  name: [{ required: true, message: '请输入成就名称', trigger: 'blur' }],
  icon: [{ required: true, message: '请输入图标', trigger: 'blur' }],
  description: [{ required: true, message: '请输入成就描述', trigger: 'blur' }],
  category: [{ required: true, message: '请选择分类', trigger: 'change' }],
  rarity: [{ required: true, message: '请选择稀有度', trigger: 'change' }],
  conditionType: [{ required: true, message: '请选择条件类型', trigger: 'change' }],
  conditionValue: [{ required: true, message: '请输入条件值', trigger: 'blur' }]
}

// 获取分类Tag类型
const getCategoryType = (category: string) => {
  const types: Record<string, string> = {
    STUDY: 'primary',
    CHECK_IN: 'success',
    CHECKIN: 'success',
    RESERVATION: '',
    SOCIAL: 'warning',
    SPECIAL: 'danger',
    CREDIT: 'info',
    GOAL: '',
    POINTS: 'warning'
  }
  return types[category] || 'info'
}

// 获取分类名称（本地备用）
const getCategoryNameLocal = (category: string) => {
  const names: Record<string, string> = {
    STUDY: '学习成就',
    CHECK_IN: '打卡成就',
    CHECKIN: '打卡成就',
    RESERVATION: '预约成就',
    SOCIAL: '社交成就',
    SPECIAL: '特殊成就',
    CREDIT: '信用成就',
    GOAL: '目标成就',
    POINTS: '积分成就'
  }
  return names[category] || category
}

// 获取条件类型名称
const getConditionTypeName = (type: string) => {
  const names: Record<string, string> = {
    TOTAL_RESERVATIONS: '预约次数',
    TOTAL_HOURS: '学习时长',
    TOTAL_CHECK_INS: '打卡次数',
    CONTINUOUS_CHECK_INS: '连续打卡',
    TOTAL_FRIENDS: '好友数量',
    CREATE_GROUP: '创建小组',
    EARLY_SIGN_IN: '早起签到',
    LATE_SIGN_OUT: '晚间签退',
    NO_VIOLATION_STREAK: '无违约',
    WEEKEND_STUDY: '周末学习',
    GOALS_COMPLETED: '完成目标',
    TOTAL_REVIEWS: '评价数量'
  }
  return names[type] || type
}

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const res = await getAdminAchievements({
      page: pagination.page,
      size: pagination.size,
      ...filters
    })
    achievements.value = res.list
    pagination.total = res.total
  } catch (error) {
    console.error('加载成就列表失败', error)
  } finally {
    loading.value = false
  }
}

// 重置筛选
const resetFilters = () => {
  filters.category = ''
  filters.rarity = ''
  filters.keyword = ''
  loadData()
}

// 显示新增弹窗
const showCreateDialog = () => {
  isEdit.value = false
  Object.assign(form, defaultForm)
  dialogVisible.value = true
}

// 显示编辑弹窗
const showEditDialog = (row: Achievement) => {
  isEdit.value = true
  Object.assign(form, {
    id: row.id,
    name: row.name,
    description: row.description,
    icon: row.icon,
    badgeColor: row.badgeColor,
    category: row.category,
    conditionType: row.conditionType,
    conditionValue: row.conditionValue,
    rewardPoints: row.rewardPoints,
    rewardExp: row.rewardExp,
    rarity: row.rarity,
    isHidden: row.isHidden,
    sortOrder: row.sortOrder
  })
  dialogVisible.value = true
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    
    submitting.value = true
    try {
      if (isEdit.value) {
        await updateAchievement((form as any).id, form)
        ElMessage.success('更新成功')
      } else {
        await createAchievement(form)
        ElMessage.success('创建成功')
      }
      dialogVisible.value = false
      loadData()
    } catch (error: any) {
      ElMessage.error(error.message || '操作失败')
    } finally {
      submitting.value = false
    }
  })
}

// 切换状态
const handleToggleStatus = async (row: Achievement) => {
  try {
    await toggleAchievementStatus(row.id)
    ElMessage.success(row.status ? '已启用' : '已禁用')
  } catch (error: any) {
    row.status = row.status ? 0 : 1 // 恢复原状态
    ElMessage.error(error.message || '操作失败')
  }
}

// 删除成就
const handleDelete = async (id: number) => {
  try {
    await deleteAchievement(id)
    ElMessage.success('删除成功')
    loadData()
  } catch (error: any) {
    ElMessage.error(error.message || '删除失败')
  }
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.achievements-management {
  padding: 24px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  
  h2 {
    font-size: 20px;
    font-weight: 600;
    color: #1f2937;
  }
}

.filter-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.achievement-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.achievement-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  flex-shrink: 0;
}

.achievement-info {
  min-width: 0;
  
  .achievement-name {
    font-weight: 500;
    color: #1f2937;
    margin-bottom: 2px;
  }
  
  .achievement-desc {
    font-size: 12px;
    color: #6b7280;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
}

.rarity-badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
  
  &.common {
    background: #f3f4f6;
    color: #6b7280;
  }
  
  &.rare {
    background: #dbeafe;
    color: #2563eb;
  }
  
  &.epic {
    background: #ede9fe;
    color: #7c3aed;
  }
  
  &.legendary {
    background: linear-gradient(135deg, #fef3c7, #fde68a);
    color: #d97706;
  }
}

.condition-text {
  font-size: 13px;
  color: #4b5563;
}

.reward-cell {
  display: flex;
  gap: 12px;
  font-size: 13px;
  color: #4b5563;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.form-hint {
  margin-left: 12px;
  font-size: 12px;
  color: #9ca3af;
}
</style>
