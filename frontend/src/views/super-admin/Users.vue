<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Users,
  Search,
  RefreshCw,
  Edit,
  Key,
  Ban,
  CheckCircle,
  Eye,
  GraduationCap,
  Clock,
  Award,
  Flame
} from 'lucide-vue-next'
import {
  getUserList,
  getUserDetail,
  updateUser,
  toggleUserStatus,
  resetUserPassword,
  getCollegeList,
  type UserVO
} from '@/api/super-admin'

// 列表数据
const loading = ref(false)
const users = ref<UserVO[]>([])
const total = ref(0)
const colleges = ref<string[]>([])

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  keyword: '',
  status: undefined as number | undefined,
  college: ''
})

// 详情弹窗
const detailVisible = ref(false)
const detailUser = ref<UserVO | null>(null)
const detailLoading = ref(false)

// 编辑弹窗
const editVisible = ref(false)
const editLoading = ref(false)
const editForm = reactive({
  id: 0,
  realName: '',
  phone: '',
  email: '',
  college: '',
  major: '',
  grade: '',
  classNo: '',
  creditScore: 100
})

// 状态选项
const statusOptions = [
  { label: '全部', value: undefined },
  { label: '正常', value: 1 },
  { label: '禁用', value: 0 },
  { label: '黑名单', value: 2 }
]

// 加载用户列表
const loadUsers = async () => {
  loading.value = true
  try {
    const res = await getUserList(queryParams)
    users.value = res.records
    total.value = res.total
  } catch (error) {
    console.error('加载用户列表失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载学院列表
const loadColleges = async () => {
  try {
    colleges.value = await getCollegeList()
  } catch (error) {
    console.error('加载学院列表失败:', error)
  }
}

// 搜索
const handleSearch = () => {
  queryParams.pageNum = 1
  loadUsers()
}

// 重置
const handleReset = () => {
  queryParams.keyword = ''
  queryParams.status = undefined
  queryParams.college = ''
  queryParams.pageNum = 1
  loadUsers()
}

// 查看详情
const handleViewDetail = async (row: UserVO) => {
  detailLoading.value = true
  detailVisible.value = true
  try {
    detailUser.value = await getUserDetail(row.id)
  } catch (error) {
    console.error('加载用户详情失败:', error)
    detailVisible.value = false
  } finally {
    detailLoading.value = false
  }
}

// 打开编辑弹窗
const handleEdit = (row: UserVO) => {
  editForm.id = row.id
  editForm.realName = row.realName
  editForm.phone = row.phone || ''
  editForm.email = row.email || ''
  editForm.college = row.college || ''
  editForm.major = row.major || ''
  editForm.grade = row.grade || ''
  editForm.classNo = row.classNo || ''
  editForm.creditScore = row.creditScore
  editVisible.value = true
}

// 保存编辑
const handleSaveEdit = async () => {
  editLoading.value = true
  try {
    await updateUser(editForm.id, {
      realName: editForm.realName,
      phone: editForm.phone,
      email: editForm.email,
      college: editForm.college,
      major: editForm.major,
      grade: editForm.grade,
      classNo: editForm.classNo,
      creditScore: editForm.creditScore
    })
    ElMessage.success('更新成功')
    editVisible.value = false
    loadUsers()
  } catch (error: any) {
    ElMessage.error(error.message || '更新失败')
  } finally {
    editLoading.value = false
  }
}

// 切换状态
const handleToggleStatus = async (row: UserVO) => {
  const newStatus = row.status === 1 ? 0 : 1
  const statusText = newStatus === 1 ? '启用' : '禁用'
  
  try {
    await ElMessageBox.confirm(`确定要${statusText}用户 ${row.realName} 吗？`, '提示', {
      type: 'warning'
    })
    await toggleUserStatus(row.id, newStatus)
    ElMessage.success(`${statusText}成功`)
    loadUsers()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失败')
    }
  }
}

// 重置密码
const handleResetPassword = async (row: UserVO) => {
  try {
    await ElMessageBox.confirm(`确定要重置用户 ${row.realName} 的密码吗？`, '重置密码', {
      type: 'warning'
    })
    const newPassword = await resetUserPassword(row.id)
    ElMessage.success(`密码已重置为: ${newPassword}`)
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '重置失败')
    }
  }
}

// 格式化状态
const getStatusTag = (status: number) => {
  switch (status) {
    case 1: return { type: 'success', text: '正常' }
    case 0: return { type: 'info', text: '禁用' }
    case 2: return { type: 'danger', text: '黑名单' }
    default: return { type: 'info', text: '未知' }
  }
}

// 格式化性别
const getGenderText = (gender: number) => {
  switch (gender) {
    case 1: return '男'
    case 2: return '女'
    default: return '未知'
  }
}

// 格式化学习时长
const formatStudyTime = (minutes: number) => {
  if (!minutes) return '0小时'
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  return hours > 0 ? `${hours}小时${mins > 0 ? mins + '分' : ''}` : `${mins}分钟`
}

onMounted(() => {
  loadUsers()
  loadColleges()
})
</script>

<template>
  <div class="users-page">
    <div class="page-header">
      <h2><Users :size="24" /> 用户管理</h2>
      <p>共 {{ total }} 名学生用户</p>
    </div>
    
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="关键词">
          <el-input
            v-model="queryParams.keyword"
            placeholder="用户名/姓名/学号/手机"
            clearable
            style="width: 200px"
            @keyup.enter="handleSearch"
          >
            <template #prefix><Search :size="16" /></template>
          </el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 120px">
            <el-option
              v-for="opt in statusOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="学院">
          <el-select v-model="queryParams.college" placeholder="全部" clearable style="width: 160px">
            <el-option v-for="c in colleges" :key="c" :label="c" :value="c" />
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
    
    <!-- 用户表格 -->
    <el-card class="table-card">
      <el-table :data="users" v-loading="loading" stripe table-layout="fixed">
        <el-table-column label="用户信息" min-width="180">
          <template #default="{ row }">
            <div class="user-info">
              <el-avatar :size="36" :src="row.avatar">{{ row.realName?.charAt(0) }}</el-avatar>
              <div class="user-text">
                <div class="user-name">{{ row.realName }}</div>
                <div class="user-id">{{ row.studentId }}</div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="college" label="学院" min-width="100" show-overflow-tooltip />
        <el-table-column prop="phone" label="手机" min-width="120" show-overflow-tooltip>
          <template #default="{ row }">{{ row.phone || '-' }}</template>
        </el-table-column>
        <el-table-column label="学习数据" min-width="110">
          <template #default="{ row }">
            <div><Clock :size="14" class="icon-inline" /> {{ formatStudyTime(row.totalStudyTime) }}</div>
            <div><Flame :size="14" class="icon-inline" /> 连续{{ row.currentStreak }}天</div>
          </template>
        </el-table-column>
        <el-table-column label="积分/信用" width="90" align="center">
          <template #default="{ row }">
            <div class="stat-cell">
              <span class="points">{{ row.totalPoints }}</span>
              <span :class="['credit', row.creditScore < 60 ? 'low' : '']">{{ row.creditScore }}分</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status).type" size="small">
              {{ getStatusTag(row.status).text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleViewDetail(row)">
              <Eye :size="14" /> 详情
            </el-button>
            <el-button link type="primary" size="small" @click="handleEdit(row)">
              <Edit :size="14" /> 编辑
            </el-button>
            <el-dropdown trigger="click">
              <el-button link type="primary" size="small">更多</el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item @click="handleResetPassword(row)">
                    <Key :size="14" class="mr-1" /> 重置密码
                  </el-dropdown-item>
                  <el-dropdown-item 
                    :divided="true"
                    @click="handleToggleStatus(row)"
                  >
                    <template v-if="row.status === 1">
                      <Ban :size="14" class="mr-1" /> 禁用账号
                    </template>
                    <template v-else>
                      <CheckCircle :size="14" class="mr-1" /> 启用账号
                    </template>
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
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
          @current-change="(page: number) => { queryParams.pageNum = page; loadUsers() }"
          @size-change="(size: number) => { queryParams.pageSize = size; loadUsers() }"
        />
      </div>
    </el-card>
    
    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" title="用户详情" width="600px">
      <div v-loading="detailLoading" class="user-detail" v-if="detailUser">
        <div class="detail-header">
          <el-avatar :size="80" :src="detailUser.avatar">{{ detailUser.realName?.charAt(0) }}</el-avatar>
          <div class="detail-title">
            <h3>{{ detailUser.realName }}</h3>
            <p>{{ detailUser.username }} / {{ detailUser.studentId }}</p>
            <el-tag :type="getStatusTag(detailUser.status).type" size="small">
              {{ getStatusTag(detailUser.status).text }}
            </el-tag>
          </div>
        </div>
        
        <el-divider />
        
        <el-descriptions :column="2" border>
          <el-descriptions-item label="学院">{{ detailUser.college || '-' }}</el-descriptions-item>
          <el-descriptions-item label="专业">{{ detailUser.major || '-' }}</el-descriptions-item>
          <el-descriptions-item label="年级">{{ detailUser.grade || '-' }}</el-descriptions-item>
          <el-descriptions-item label="班级">{{ detailUser.classNo || '-' }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ getGenderText(detailUser.gender) }}</el-descriptions-item>
          <el-descriptions-item label="手机">{{ detailUser.phone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="邮箱" :span="2">{{ detailUser.email || '-' }}</el-descriptions-item>
        </el-descriptions>
        
        <div class="detail-stats">
          <div class="stat-item">
            <div class="stat-value">{{ formatStudyTime(detailUser.totalStudyTime) }}</div>
            <div class="stat-label">累计学习时长</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ detailUser.totalCheckIns }}</div>
            <div class="stat-label">累计打卡</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ detailUser.currentStreak }}</div>
            <div class="stat-label">连续打卡</div>
          </div>
          <div class="stat-item">
            <div class="stat-value">{{ detailUser.totalPoints }}</div>
            <div class="stat-label">积分</div>
          </div>
          <div class="stat-item">
            <div class="stat-value" :class="{ low: detailUser.creditScore < 60 }">{{ detailUser.creditScore }}</div>
            <div class="stat-label">信用分</div>
          </div>
        </div>
        
        <el-descriptions :column="2" border class="mt-4">
          <el-descriptions-item label="注册时间">{{ detailUser.createTime }}</el-descriptions-item>
          <el-descriptions-item label="更新时间">{{ detailUser.updateTime }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
    
    <!-- 编辑弹窗 -->
    <el-dialog v-model="editVisible" title="编辑用户" width="500px">
      <el-form :model="editForm" label-width="80px">
        <el-form-item label="姓名">
          <el-input v-model="editForm.realName" />
        </el-form-item>
        <el-form-item label="手机">
          <el-input v-model="editForm.phone" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="editForm.email" />
        </el-form-item>
        <el-form-item label="学院">
          <el-input v-model="editForm.college" />
        </el-form-item>
        <el-form-item label="专业">
          <el-input v-model="editForm.major" />
        </el-form-item>
        <el-form-item label="年级">
          <el-input v-model="editForm.grade" />
        </el-form-item>
        <el-form-item label="班级">
          <el-input v-model="editForm.classNo" />
        </el-form-item>
        <el-form-item label="信用分">
          <el-input-number v-model="editForm.creditScore" :min="0" :max="120" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editVisible = false">取消</el-button>
        <el-button type="primary" :loading="editLoading" @click="handleSaveEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.users-page {
  padding: 24px;
}

.page-header {
  margin-bottom: 24px;
  
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

.search-card {
  margin-bottom: 16px;
}

.table-card {
  .user-info {
    display: flex;
    align-items: center;
    gap: 12px;
    
    .user-text {
      .user-name {
        font-weight: 500;
        color: $text-primary;
      }
      .user-id {
        font-size: 12px;
        color: $text-muted;
      }
    }
  }
  
  .stat-cell {
    display: flex;
    flex-direction: column;
    gap: 2px;
    
    .points {
      color: $warning;
      font-weight: 500;
    }
    
    .credit {
      font-size: 12px;
      color: $success;
      
      &.low {
        color: $error;
      }
    }
  }
  
  .icon-inline {
    vertical-align: middle;
    margin-right: 4px;
  }
}

.pagination {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.user-detail {
  .detail-header {
    display: flex;
    align-items: center;
    gap: 20px;
    
    .detail-title {
      h3 {
        font-size: 20px;
        font-weight: 600;
        margin-bottom: 4px;
      }
      p {
        color: $text-secondary;
        margin-bottom: 8px;
      }
    }
  }
  
  .detail-stats {
    display: flex;
    justify-content: space-around;
    padding: 20px 0;
    background: $gray-50;
    border-radius: 8px;
    margin-top: 16px;
    
    .stat-item {
      text-align: center;
      
      .stat-value {
        font-size: 24px;
        font-weight: 600;
        color: $primary;
        
        &.low {
          color: $error;
        }
      }
      
      .stat-label {
        font-size: 12px;
        color: $text-secondary;
        margin-top: 4px;
      }
    }
  }
}

.mr-1 {
  margin-right: 4px;
}

.mt-4 {
  margin-top: 16px;
}

.text-muted {
  color: $text-muted;
  font-size: 12px;
}
</style>
