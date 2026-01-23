<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  UserCog,
  Search,
  RefreshCw,
  Plus,
  Edit,
  Trash2,
  Key,
  Ban,
  CheckCircle
} from 'lucide-vue-next'
import {
  getAdminList,
  createAdmin,
  updateAdmin,
  deleteAdmin,
  resetAdminPassword,
  toggleAdminStatus,
  type UserVO
} from '@/api/super-admin'

// 列表数据
const loading = ref(false)
const admins = ref<UserVO[]>([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  keyword: ''
})

// 新增/编辑弹窗
const dialogVisible = ref(false)
const dialogTitle = ref('新增管理员')
const isEdit = ref(false)
const submitLoading = ref(false)

const formData = reactive({
  id: 0,
  username: '',
  password: '',
  realName: '',
  phone: '',
  email: ''
})

// 加载管理员列表
const loadAdmins = async () => {
  loading.value = true
  try {
    const res = await getAdminList(queryParams)
    admins.value = res.records
    total.value = res.total
  } catch (error) {
    console.error('加载管理员列表失败:', error)
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  queryParams.pageNum = 1
  loadAdmins()
}

// 重置
const handleReset = () => {
  queryParams.keyword = ''
  queryParams.pageNum = 1
  loadAdmins()
}

// 打开新增弹窗
const openCreateDialog = () => {
  isEdit.value = false
  dialogTitle.value = '新增管理员'
  formData.id = 0
  formData.username = ''
  formData.password = ''
  formData.realName = ''
  formData.phone = ''
  formData.email = ''
  dialogVisible.value = true
}

// 打开编辑弹窗
const openEditDialog = (row: UserVO) => {
  isEdit.value = true
  dialogTitle.value = '编辑管理员'
  formData.id = row.id
  formData.username = row.username
  formData.password = ''
  formData.realName = row.realName
  formData.phone = row.phone || ''
  formData.email = row.email || ''
  dialogVisible.value = true
}

// 提交表单
const handleSubmit = async () => {
  if (!formData.realName.trim()) {
    ElMessage.warning('请输入姓名')
    return
  }
  
  if (!isEdit.value) {
    if (!formData.username.trim()) {
      ElMessage.warning('请输入用户名')
      return
    }
    if (!formData.password.trim()) {
      ElMessage.warning('请输入密码')
      return
    }
  }
  
  submitLoading.value = true
  try {
    if (isEdit.value) {
      await updateAdmin(formData.id, {
        realName: formData.realName,
        phone: formData.phone,
        email: formData.email
      })
      ElMessage.success('更新成功')
    } else {
      await createAdmin({
        username: formData.username,
        password: formData.password,
        realName: formData.realName,
        phone: formData.phone,
        email: formData.email
      })
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadAdmins()
  } catch (error: any) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    submitLoading.value = false
  }
}

// 删除管理员
const handleDelete = async (row: UserVO) => {
  try {
    await ElMessageBox.confirm(`确定要删除管理员 ${row.realName} 吗？此操作不可恢复。`, '删除确认', {
      type: 'warning',
      confirmButtonText: '确定删除',
      confirmButtonClass: 'el-button--danger'
    })
    await deleteAdmin(row.id)
    ElMessage.success('删除成功')
    loadAdmins()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

// 重置密码
const handleResetPassword = async (row: UserVO) => {
  try {
    await ElMessageBox.confirm(`确定要重置管理员 ${row.realName} 的密码吗？密码将重置为 123456`, '重置密码', {
      type: 'warning'
    })
    const newPassword = await resetAdminPassword(row.id)
    ElMessage.success(`密码已重置为: ${newPassword}`)
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '重置失败')
    }
  }
}

// 切换状态
const handleToggleStatus = async (row: UserVO) => {
  const newStatus = row.status === 1 ? 0 : 1
  const statusText = newStatus === 1 ? '启用' : '禁用'
  
  try {
    await ElMessageBox.confirm(`确定要${statusText}管理员 ${row.realName} 吗？`, '提示', {
      type: 'warning'
    })
    await toggleAdminStatus(row.id, newStatus)
    ElMessage.success(`${statusText}成功`)
    loadAdmins()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失败')
    }
  }
}

// 格式化状态
const getStatusTag = (status: number) => {
  return status === 1 
    ? { type: 'success', text: '正常' }
    : { type: 'info', text: '禁用' }
}

onMounted(() => {
  loadAdmins()
})
</script>

<template>
  <div class="admins-page">
    <div class="page-header">
      <div class="header-left">
        <h2><UserCog :size="24" /> 管理员管理</h2>
        <p>共 {{ total }} 名管理员</p>
      </div>
      <el-button type="primary" @click="openCreateDialog">
        <Plus :size="16" class="mr-1" /> 新增管理员
      </el-button>
    </div>
    
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="关键词">
          <el-input
            v-model="queryParams.keyword"
            placeholder="用户名/姓名/手机"
            clearable
            style="width: 200px"
            @keyup.enter="handleSearch"
          >
            <template #prefix><Search :size="16" /></template>
          </el-input>
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
    
    <!-- 管理员表格 -->
    <el-card class="table-card">
      <el-table :data="admins" v-loading="loading" stripe table-layout="fixed">
        <el-table-column label="管理员信息" min-width="180">
          <template #default="{ row }">
            <div class="admin-info">
              <el-avatar :size="36" :src="row.avatar">{{ row.realName?.charAt(0) }}</el-avatar>
              <div class="admin-text">
                <div class="admin-name">{{ row.realName }}</div>
                <div class="admin-username">{{ row.username }}</div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="手机号" min-width="120">
          <template #default="{ row }">{{ row.phone || '-' }}</template>
        </el-table-column>
        <el-table-column prop="email" label="邮箱" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ row.email || '-' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status).type" size="small">
              {{ getStatusTag(row.status).text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" min-width="140" show-overflow-tooltip />
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openEditDialog(row)">
              <Edit :size="14" /> 编辑
            </el-button>
            <el-button link type="warning" size="small" @click="handleResetPassword(row)">
              <Key :size="14" /> 重置密码
            </el-button>
            <el-dropdown trigger="click">
              <el-button link type="primary" size="small">更多</el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item @click="handleToggleStatus(row)">
                    <template v-if="row.status === 1">
                      <Ban :size="14" class="mr-1" /> 禁用
                    </template>
                    <template v-else>
                      <CheckCircle :size="14" class="mr-1" /> 启用
                    </template>
                  </el-dropdown-item>
                  <el-dropdown-item divided @click="handleDelete(row)">
                    <Trash2 :size="14" class="mr-1 text-danger" /> 删除
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
          @current-change="(page: number) => { queryParams.pageNum = page; loadAdmins() }"
          @size-change="(size: number) => { queryParams.pageSize = size; loadAdmins() }"
        />
      </div>
    </el-card>
    
    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="480px">
      <el-form :model="formData" label-width="80px">
        <el-form-item label="用户名" :required="!isEdit">
          <el-input 
            v-model="formData.username" 
            :disabled="isEdit"
            placeholder="请输入用户名"
          />
        </el-form-item>
        <el-form-item label="密码" :required="!isEdit" v-if="!isEdit">
          <el-input 
            v-model="formData.password" 
            type="password"
            placeholder="请输入密码"
            show-password
          />
        </el-form-item>
        <el-form-item label="姓名" required>
          <el-input v-model="formData.realName" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="formData.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="formData.email" placeholder="请输入邮箱" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">
          {{ isEdit ? '保存' : '创建' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.admins-page {
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
  .admin-info {
    display: flex;
    align-items: center;
    gap: 12px;
    
    .admin-text {
      .admin-name {
        font-weight: 500;
        color: $text-primary;
      }
      .admin-username {
        font-size: 12px;
        color: $text-muted;
      }
    }
  }
}

.pagination {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.mr-1 {
  margin-right: 4px;
}

.text-danger {
  color: $error;
}
</style>
