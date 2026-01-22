<template>
  <div class="groups-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-left">
        <h1>学习小组</h1>
        <p>加入学习小组，与志同道合的同学一起进步</p>
      </div>
      <div class="header-right">
        <el-button type="primary" @click="showCreateDialog = true">
          <el-icon><Plus /></el-icon>
          创建小组
        </el-button>
      </div>
    </div>

    <!-- 标签页切换 -->
    <div class="tabs-container">
      <div class="tabs">
        <div 
          class="tab" 
          :class="{ active: activeTab === 'my' }"
          @click="activeTab = 'my'"
        >
          <el-icon><Star /></el-icon>
          <span>我的小组</span>
        </div>
        <div 
          class="tab" 
          :class="{ active: activeTab === 'explore' }"
          @click="activeTab = 'explore'"
        >
          <el-icon><Search /></el-icon>
          <span>发现小组</span>
        </div>
      </div>
      
      <div v-if="activeTab === 'explore'" class="search-box">
        <el-input 
          v-model="searchKeyword" 
          placeholder="搜索小组名称或标签"
          clearable
          @keyup.enter="loadPublicGroups"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
      </div>
    </div>

    <!-- 我的小组 -->
    <div v-if="activeTab === 'my'" class="content-area">
      <div v-if="loading" class="loading-state">
        <el-skeleton :rows="4" animated />
      </div>
      <div v-else-if="myGroups.length === 0" class="empty-state">
        <el-empty description="还没有加入任何小组">
          <el-button type="primary" @click="activeTab = 'explore'">
            探索小组
          </el-button>
        </el-empty>
      </div>
      <div v-else class="group-grid">
        <div v-for="group in myGroups" :key="group.id" class="group-card my-group">
          <div class="group-cover" :style="{ background: getGradient(group.id) }">
            <div class="group-avatar">
              <el-avatar :size="60" :src="group.avatar || undefined">
                {{ group.name?.charAt(0) }}
              </el-avatar>
            </div>
            <el-tag 
              class="role-tag" 
              :type="getRoleType(group.role)"
              size="small"
            >
              {{ getRoleName(group.role) }}
            </el-tag>
          </div>
          <div class="group-body">
            <div class="group-name">{{ group.name }}</div>
            <div class="group-stats">
              <div class="stat-item">
                <el-icon><User /></el-icon>
                <span>{{ group.memberCount }} 成员</span>
              </div>
              <div class="stat-item">
                <el-icon><Clock /></el-icon>
                <span>{{ formatHours(group.totalHours) }} 总时长</span>
              </div>
            </div>
            <div class="my-contribution">
              <span class="label">我的贡献:</span>
              <span class="value">{{ formatHours(group.contributionHours) }}</span>
            </div>
          </div>
          <div class="group-footer">
            <el-button text type="primary" @click="viewGroupDetail(group.id)">
              查看详情
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 发现小组 -->
    <div v-if="activeTab === 'explore'" class="content-area">
      <div v-if="loading" class="loading-state">
        <el-skeleton :rows="4" animated />
      </div>
      <div v-else-if="publicGroups.length === 0" class="empty-state">
        <el-empty description="暂无公开小组" />
      </div>
      <div v-else class="group-grid">
        <div v-for="group in publicGroups" :key="group.id" class="group-card">
          <div class="group-cover" :style="{ background: getGradient(group.id) }">
            <div class="group-avatar">
              <el-avatar :size="60" :src="group.avatar || undefined">
                {{ group.name?.charAt(0) }}
              </el-avatar>
            </div>
          </div>
          <div class="group-body">
            <div class="group-name">{{ group.name }}</div>
            <div class="group-desc">{{ group.description || '暂无简介' }}</div>
            <div class="group-stats">
              <div class="stat-item">
                <el-icon><User /></el-icon>
                <span>{{ group.memberCount }}/{{ group.maxMembers }}</span>
              </div>
              <div class="stat-item">
                <el-icon><Clock /></el-icon>
                <span>{{ formatHours(group.totalHours) }}</span>
              </div>
            </div>
            <div v-if="group.tags" class="group-tags">
              <el-tag 
                v-for="tag in group.tags.split(',')" 
                :key="tag" 
                size="small" 
                type="info"
              >
                {{ tag }}
              </el-tag>
            </div>
          </div>
          <div class="group-footer">
            <el-button 
              type="primary" 
              @click="handleJoinGroup(group)"
              :disabled="group.memberCount >= group.maxMembers"
            >
              {{ group.needApprove ? '申请加入' : '加入小组' }}
            </el-button>
            <el-button text @click="viewGroupDetail(group.id)">
              详情
            </el-button>
          </div>
        </div>
      </div>
      
      <!-- 分页 -->
      <div v-if="total > pageSize" class="pagination">
        <el-pagination 
          v-model:current-page="currentPage"
          :page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          @current-change="loadPublicGroups"
        />
      </div>
    </div>

    <!-- 小组详情对话框 -->
    <el-dialog 
      v-model="showDetailDialog" 
      :title="groupDetail?.name || '小组详情'"
      width="700px"
      :close-on-click-modal="false"
    >
      <div v-if="detailLoading" class="loading-state">
        <el-skeleton :rows="6" animated />
      </div>
      <div v-else-if="groupDetail" class="group-detail">
        <div class="detail-header" :style="{ background: getGradient(groupDetail.id) }">
          <el-avatar :size="80" :src="groupDetail.avatar || undefined">
            {{ groupDetail.name?.charAt(0) }}
          </el-avatar>
          <div class="detail-title">
            <h2>{{ groupDetail.name }}</h2>
            <div class="detail-meta">
              <span><el-icon><User /></el-icon> {{ groupDetail.memberCount }}/{{ groupDetail.maxMembers }} 成员</span>
              <span><el-icon><Clock /></el-icon> 本周 {{ formatHours(groupDetail.weeklyHours) }}</span>
            </div>
          </div>
        </div>
        
        <div class="detail-body">
          <div class="detail-section">
            <h3>小组简介</h3>
            <p>{{ groupDetail.description || '暂无简介' }}</p>
          </div>
          
          <div class="detail-section">
            <h3>创建者</h3>
            <div class="creator-info">
              <el-avatar :size="32" :src="groupDetail.creator?.avatar || undefined">
                {{ groupDetail.creator?.nickname?.charAt(0) || groupDetail.creator?.username?.charAt(0) }}
              </el-avatar>
              <span>{{ groupDetail.creator?.nickname || groupDetail.creator?.username }}</span>
            </div>
          </div>
          
          <div v-if="groupDetail.tags" class="detail-section">
            <h3>标签</h3>
            <div class="tags">
              <el-tag v-for="tag in groupDetail.tags.split(',')" :key="tag" size="small">
                {{ tag }}
              </el-tag>
            </div>
          </div>
          
          <div class="detail-section">
            <h3>学习数据</h3>
            <div class="data-stats">
              <div class="data-item">
                <span class="data-value">{{ formatHours(groupDetail.totalHours) }}</span>
                <span class="data-label">累计学习</span>
              </div>
              <div class="data-item">
                <span class="data-value">{{ formatHours(groupDetail.weeklyHours) }}</span>
                <span class="data-label">本周学习</span>
              </div>
            </div>
          </div>
          
          <div class="detail-section">
            <div class="section-header">
              <h3>成员列表</h3>
              <span class="member-count">共 {{ members.length }} 人</span>
            </div>
            <div class="member-list">
              <div v-for="member in members" :key="member.id" class="member-item">
                <el-avatar :size="36" :src="member.user?.avatar || undefined">
                  {{ member.user?.nickname?.charAt(0) || member.user?.username?.charAt(0) }}
                </el-avatar>
                <div class="member-info">
                  <span class="member-name">
                    {{ member.nickname || member.user?.nickname || member.user?.username }}
                  </span>
                  <el-tag 
                    v-if="member.role !== 'MEMBER'" 
                    :type="getRoleType(member.role)"
                    size="small"
                  >
                    {{ getRoleName(member.role) }}
                  </el-tag>
                </div>
                <span class="member-hours">{{ formatHours(member.contributionHours) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <template #footer>
        <div class="detail-footer">
          <template v-if="groupDetail?.memberStatus === 1">
            <el-button 
              v-if="groupDetail.isAdmin" 
              type="primary"
              @click="goToManage"
            >
              管理小组
            </el-button>
            <el-button type="danger" plain @click="handleLeaveGroup">
              退出小组
            </el-button>
          </template>
          <template v-else-if="groupDetail?.memberStatus === 0">
            <el-tag type="warning">申请审核中</el-tag>
          </template>
          <template v-else>
            <el-button 
              type="primary" 
              @click="handleJoinGroup(groupDetail)"
              :disabled="groupDetail?.memberCount >= groupDetail?.maxMembers"
            >
              {{ groupDetail?.needApprove ? '申请加入' : '加入小组' }}
            </el-button>
          </template>
          <el-button @click="showDetailDialog = false">关闭</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 创建小组对话框 -->
    <el-dialog 
      v-model="showCreateDialog" 
      title="创建学习小组" 
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form :model="createForm" :rules="createRules" ref="createFormRef" label-width="100px">
        <el-form-item label="小组名称" prop="name">
          <el-input v-model="createForm.name" placeholder="请输入小组名称" maxlength="30" show-word-limit />
        </el-form-item>
        <el-form-item label="小组简介" prop="description">
          <el-input 
            v-model="createForm.description" 
            type="textarea" 
            :rows="3"
            placeholder="介绍一下你的小组" 
            maxlength="200" 
            show-word-limit 
          />
        </el-form-item>
        <el-form-item label="最大人数" prop="maxMembers">
          <el-input-number v-model="createForm.maxMembers" :min="2" :max="100" />
        </el-form-item>
        <el-form-item label="标签">
          <el-input v-model="createForm.tags" placeholder="多个标签用逗号分隔" />
        </el-form-item>
        <el-form-item label="公开小组">
          <el-switch v-model="createForm.isPublic" />
          <span class="form-tip">公开小组可被其他用户搜索和加入</span>
        </el-form-item>
        <el-form-item label="需要审批">
          <el-switch v-model="createForm.needApprove" />
          <span class="form-tip">开启后用户加入需要管理员审批</span>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" :loading="createLoading" @click="handleCreateGroup">
          创建
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { Plus, Star, Search, User, Clock } from '@element-plus/icons-vue'
import { 
  getMyGroups, getPublicGroups, getGroupDetail, getGroupMembers,
  createGroup, joinGroup, leaveGroup
} from '@/api/social'

// 状态
const loading = ref(false)
const activeTab = ref('my')
const myGroups = ref<any[]>([])
const publicGroups = ref<any[]>([])

// 分页
const currentPage = ref(1)
const pageSize = ref(12)
const total = ref(0)
const searchKeyword = ref('')

// 详情
const showDetailDialog = ref(false)
const detailLoading = ref(false)
const groupDetail = ref<any>(null)
const members = ref<any[]>([])

// 创建
const showCreateDialog = ref(false)
const createLoading = ref(false)
const createFormRef = ref<FormInstance>()
const createForm = reactive({
  name: '',
  description: '',
  maxMembers: 50,
  tags: '',
  isPublic: true,
  needApprove: false
})
const createRules: FormRules = {
  name: [
    { required: true, message: '请输入小组名称', trigger: 'blur' },
    { min: 2, max: 30, message: '名称长度为2-30个字符', trigger: 'blur' }
  ]
}

// 渐变色
const gradients = [
  'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
  'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
  'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
  'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
  'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
  'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)',
  'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)'
]

const getGradient = (id: number) => {
  return gradients[id % gradients.length]
}

// 角色
const getRoleName = (role: string) => {
  switch (role) {
    case 'CREATOR': return '创建者'
    case 'ADMIN': return '管理员'
    default: return '成员'
  }
}

const getRoleType = (role: string) => {
  switch (role) {
    case 'CREATOR': return 'danger'
    case 'ADMIN': return 'warning'
    default: return 'info'
  }
}

// 格式化时长
const formatHours = (hours: number | string) => {
  const h = Number(hours) || 0
  if (h < 1) return `${Math.round(h * 60)}分钟`
  return `${h.toFixed(1)}小时`
}

// 加载我的小组
const loadMyGroups = async () => {
  loading.value = true
  try {
    const res = await getMyGroups()
    myGroups.value = res || []
  } catch (e) {
    console.error('加载我的小组失败', e)
  } finally {
    loading.value = false
  }
}

// 加载公开小组
const loadPublicGroups = async () => {
  loading.value = true
  try {
    const res = await getPublicGroups({
      page: currentPage.value,
      size: pageSize.value,
      keyword: searchKeyword.value || undefined
    })
    publicGroups.value = res?.records || []
    total.value = res?.total || 0
  } catch (e) {
    console.error('加载公开小组失败', e)
  } finally {
    loading.value = false
  }
}

// 查看小组详情
const viewGroupDetail = async (groupId: number) => {
  showDetailDialog.value = true
  detailLoading.value = true
  try {
    const [detailRes, membersRes] = await Promise.all([
      getGroupDetail(groupId),
      getGroupMembers(groupId)
    ])
    groupDetail.value = detailRes
    members.value = membersRes || []
  } catch (e) {
    console.error('加载小组详情失败', e)
    ElMessage.error('加载小组详情失败')
  } finally {
    detailLoading.value = false
  }
}

// 加入小组
const handleJoinGroup = async (group: any) => {
  try {
    if (group.needApprove) {
      await ElMessageBox.confirm(
        `该小组需要审批，确定申请加入「${group.name}」吗？`,
        '提示'
      )
    }
    await joinGroup(group.id)
    ElMessage.success(group.needApprove ? '申请已提交，请等待审批' : '已成功加入小组')
    if (showDetailDialog.value) {
      viewGroupDetail(group.id)
    }
    loadMyGroups()
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e.message || '加入失败')
    }
  }
}

// 退出小组
const handleLeaveGroup = async () => {
  if (!groupDetail.value) return
  try {
    await ElMessageBox.confirm(
      `确定要退出小组「${groupDetail.value.name}」吗？`,
      '退出小组',
      { type: 'warning' }
    )
    await leaveGroup(groupDetail.value.id)
    ElMessage.success('已退出小组')
    showDetailDialog.value = false
    loadMyGroups()
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e.message || '退出失败')
    }
  }
}

// 管理小组
const goToManage = () => {
  // TODO: 跳转到管理页面
  ElMessage.info('管理功能开发中')
}

// 创建小组
const handleCreateGroup = async () => {
  if (!createFormRef.value) return
  
  try {
    await createFormRef.value.validate()
  } catch {
    return
  }
  
  createLoading.value = true
  try {
    await createGroup(createForm)
    ElMessage.success('小组创建成功')
    showCreateDialog.value = false
    // 重置表单
    createForm.name = ''
    createForm.description = ''
    createForm.maxMembers = 50
    createForm.tags = ''
    createForm.isPublic = true
    createForm.needApprove = false
    // 刷新列表
    loadMyGroups()
    activeTab.value = 'my'
  } catch (e: any) {
    ElMessage.error(e.message || '创建失败')
  } finally {
    createLoading.value = false
  }
}

// 监听标签页切换
watch(activeTab, (tab) => {
  if (tab === 'my') {
    loadMyGroups()
  } else {
    loadPublicGroups()
  }
})

onMounted(() => {
  loadMyGroups()
})
</script>

<style lang="scss" scoped>
.groups-container {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  
  .header-left {
    h1 {
      font-size: 28px;
      font-weight: 700;
      color: #1a1a2e;
      margin: 0 0 8px 0;
    }
    
    p {
      color: #666;
      margin: 0;
    }
  }
}

.tabs-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 16px;
  
  .tabs {
    display: flex;
    gap: 8px;
    background: #f5f7fa;
    padding: 4px;
    border-radius: 12px;
  }
  
  .tab {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 24px;
    border-radius: 8px;
    cursor: pointer;
    color: #666;
    transition: all 0.3s;
    
    &:hover {
      color: #1a1a2e;
    }
    
    &.active {
      background: white;
      color: #667eea;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }
  }
  
  .search-box {
    width: 300px;
  }
}

.content-area {
  min-height: 400px;
}

.loading-state,
.empty-state {
  padding: 80px 20px;
  text-align: center;
}

.group-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.group-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s;
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  }
  
  .group-cover {
    height: 100px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    
    .group-avatar {
      border: 3px solid white;
      border-radius: 50%;
    }
    
    .role-tag {
      position: absolute;
      top: 8px;
      right: 8px;
    }
  }
  
  .group-body {
    padding: 16px;
  }
  
  .group-name {
    font-size: 18px;
    font-weight: 600;
    color: #1a1a2e;
    margin-bottom: 8px;
    text-align: center;
  }
  
  .group-desc {
    font-size: 13px;
    color: #666;
    margin-bottom: 12px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-align: center;
    min-height: 36px;
  }
  
  .group-stats {
    display: flex;
    justify-content: center;
    gap: 24px;
    margin-bottom: 12px;
    
    .stat-item {
      display: flex;
      align-items: center;
      gap: 4px;
      font-size: 13px;
      color: #666;
    }
  }
  
  .group-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    justify-content: center;
    margin-top: 8px;
  }
  
  .my-contribution {
    text-align: center;
    padding: 8px 0;
    margin-top: 8px;
    background: #f8f9fa;
    border-radius: 8px;
    
    .label {
      font-size: 12px;
      color: #999;
      margin-right: 8px;
    }
    
    .value {
      font-size: 14px;
      font-weight: 600;
      color: #667eea;
    }
  }
  
  .group-footer {
    padding: 12px 16px;
    border-top: 1px solid #f0f0f0;
    display: flex;
    justify-content: center;
    gap: 8px;
  }
}

// 详情对话框
.group-detail {
  .detail-header {
    display: flex;
    align-items: center;
    gap: 20px;
    padding: 24px;
    border-radius: 12px;
    margin-bottom: 20px;
    color: white;
    
    .detail-title {
      h2 {
        margin: 0 0 8px 0;
        font-size: 22px;
      }
      
      .detail-meta {
        display: flex;
        gap: 16px;
        font-size: 14px;
        opacity: 0.9;
        
        span {
          display: flex;
          align-items: center;
          gap: 4px;
        }
      }
    }
  }
  
  .detail-section {
    margin-bottom: 24px;
    
    h3 {
      font-size: 15px;
      color: #1a1a2e;
      margin: 0 0 12px 0;
      padding-bottom: 8px;
      border-bottom: 1px solid #f0f0f0;
    }
    
    p {
      color: #666;
      margin: 0;
      line-height: 1.6;
    }
    
    .section-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      h3 {
        margin: 0;
        padding: 0;
        border: none;
      }
      
      .member-count {
        font-size: 13px;
        color: #999;
      }
    }
  }
  
  .creator-info {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }
  
  .data-stats {
    display: flex;
    gap: 32px;
    
    .data-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      
      .data-value {
        font-size: 24px;
        font-weight: 700;
        color: #667eea;
      }
      
      .data-label {
        font-size: 13px;
        color: #999;
      }
    }
  }
  
  .member-list {
    max-height: 200px;
    overflow-y: auto;
    
    .member-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 8px 0;
      border-bottom: 1px solid #f5f5f5;
      
      &:last-child {
        border-bottom: none;
      }
      
      .member-info {
        flex: 1;
        display: flex;
        align-items: center;
        gap: 8px;
        
        .member-name {
          font-size: 14px;
          color: #1a1a2e;
        }
      }
      
      .member-hours {
        font-size: 13px;
        color: #666;
      }
    }
  }
}

.detail-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

// 创建表单
.form-tip {
  margin-left: 12px;
  font-size: 12px;
  color: #999;
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 32px;
}

// 响应式
@media (max-width: 768px) {
  .groups-container {
    padding: 16px;
  }
  
  .page-header {
    flex-direction: column;
    gap: 16px;
    
    .header-right {
      width: 100%;
      
      button {
        width: 100%;
      }
    }
  }
  
  .tabs-container {
    flex-direction: column;
    
    .tabs {
      width: 100%;
      
      .tab {
        flex: 1;
        justify-content: center;
      }
    }
    
    .search-box {
      width: 100%;
    }
  }
  
  .group-grid {
    grid-template-columns: 1fr;
  }
}
</style>
