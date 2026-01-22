<template>
  <div class="friends-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1>好友中心</h1>
      <p>与同学一起学习，互相监督进步</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-row">
      <div class="stat-card friends">
        <div class="stat-icon">
          <el-icon><User /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.friendCount }}</span>
          <span class="stat-label">我的好友</span>
        </div>
      </div>
      <div class="stat-card requests" @click="activeTab = 'requests'">
        <div class="stat-icon">
          <el-icon><Bell /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.pendingCount }}</span>
          <span class="stat-label">待处理请求</span>
        </div>
        <el-badge v-if="stats.pendingCount > 0" :value="stats.pendingCount" class="badge" />
      </div>
      <div class="stat-card add" @click="showSearchDialog = true">
        <div class="stat-icon">
          <el-icon><Plus /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-label">添加好友</span>
        </div>
      </div>
    </div>

    <!-- 标签页切换 -->
    <div class="tabs-container">
      <div class="tabs">
        <div 
          class="tab" 
          :class="{ active: activeTab === 'friends' }"
          @click="activeTab = 'friends'"
        >
          <el-icon><User /></el-icon>
          <span>好友列表</span>
        </div>
        <div 
          class="tab" 
          :class="{ active: activeTab === 'requests' }"
          @click="activeTab = 'requests'"
        >
          <el-icon><Bell /></el-icon>
          <span>好友请求</span>
          <el-badge v-if="stats.pendingCount > 0" :value="stats.pendingCount" />
        </div>
        <div 
          class="tab" 
          :class="{ active: activeTab === 'sent' }"
          @click="activeTab = 'sent'"
        >
          <el-icon><Promotion /></el-icon>
          <span>已发送</span>
        </div>
      </div>
    </div>

    <!-- 好友列表 -->
    <div v-if="activeTab === 'friends'" class="content-area">
      <div v-if="loading" class="loading-state">
        <el-skeleton :rows="4" animated />
      </div>
      <div v-else-if="friendList.length === 0" class="empty-state">
        <el-empty description="还没有好友，快去添加吧">
          <el-button type="primary" @click="showSearchDialog = true">
            <el-icon><Plus /></el-icon>
            添加好友
          </el-button>
        </el-empty>
      </div>
      <div v-else class="friend-grid">
        <div v-for="friend in friendList" :key="friend.userId" class="friend-card">
          <div class="friend-avatar">
            <el-avatar :size="64" :src="friend.avatar || undefined">
              {{ friend.nickname?.charAt(0) || friend.username?.charAt(0) }}
            </el-avatar>
          </div>
          <div class="friend-info">
            <div class="friend-name">
              {{ friend.remark || friend.nickname || friend.username }}
            </div>
            <div v-if="friend.remark && friend.nickname" class="friend-original-name">
              {{ friend.nickname }}
            </div>
            <div class="friend-student-no">{{ friend.studentNo }}</div>
          </div>
          <div class="friend-actions">
            <el-dropdown trigger="click">
              <el-button type="text" size="small">
                <el-icon><More /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item @click="editRemark(friend)">
                    <el-icon><Edit /></el-icon>
                    修改备注
                  </el-dropdown-item>
                  <el-dropdown-item divided @click="handleDeleteFriend(friend)">
                    <el-icon><Delete /></el-icon>
                    <span style="color: var(--el-color-danger)">删除好友</span>
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </div>
    </div>

    <!-- 好友请求列表 -->
    <div v-if="activeTab === 'requests'" class="content-area">
      <div v-if="loading" class="loading-state">
        <el-skeleton :rows="4" animated />
      </div>
      <div v-else-if="receivedRequests.length === 0" class="empty-state">
        <el-empty description="暂无好友请求" />
      </div>
      <div v-else class="request-list">
        <div v-for="req in receivedRequests" :key="req.requestId" class="request-card">
          <div class="request-avatar">
            <el-avatar :size="48" :src="req.avatar || undefined">
              {{ req.nickname?.charAt(0) || req.username?.charAt(0) }}
            </el-avatar>
          </div>
          <div class="request-info">
            <div class="request-name">{{ req.nickname || req.username }}</div>
            <div class="request-student-no">{{ req.studentNo }}</div>
            <div class="request-time">{{ formatTime(req.requestTime) }}</div>
          </div>
          <div class="request-actions">
            <el-button type="primary" size="small" @click="handleAccept(req.requestId)">
              接受
            </el-button>
            <el-button size="small" @click="handleReject(req.requestId)">
              拒绝
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 已发送请求列表 -->
    <div v-if="activeTab === 'sent'" class="content-area">
      <div v-if="loading" class="loading-state">
        <el-skeleton :rows="4" animated />
      </div>
      <div v-else-if="sentRequests.length === 0" class="empty-state">
        <el-empty description="暂无已发送的请求" />
      </div>
      <div v-else class="request-list">
        <div v-for="req in sentRequests" :key="req.requestId" class="request-card sent">
          <div class="request-avatar">
            <el-avatar :size="48" :src="req.avatar || undefined">
              {{ req.nickname?.charAt(0) || req.username?.charAt(0) }}
            </el-avatar>
          </div>
          <div class="request-info">
            <div class="request-name">{{ req.nickname || req.username }}</div>
            <div class="request-time">{{ formatTime(req.requestTime) }}</div>
          </div>
          <div class="request-status">
            <el-tag type="warning" size="small">等待确认</el-tag>
          </div>
        </div>
      </div>
    </div>

    <!-- 搜索添加好友对话框 -->
    <el-dialog 
      v-model="showSearchDialog" 
      title="添加好友" 
      width="500px"
      :close-on-click-modal="false"
    >
      <div class="search-container">
        <el-input 
          v-model="searchKeyword" 
          placeholder="搜索用户名、姓名或学号"
          size="large"
          @keyup.enter="handleSearch"
        >
          <template #append>
            <el-button @click="handleSearch" :loading="searchLoading">
              <el-icon><Search /></el-icon>
            </el-button>
          </template>
        </el-input>
      </div>
      
      <div class="search-results">
        <div v-if="searchLoading" class="loading-state">
          <el-skeleton :rows="3" animated />
        </div>
        <div v-else-if="searchResults.length === 0 && searchKeyword" class="empty-state">
          <el-empty description="未找到相关用户" />
        </div>
        <div v-else class="user-list">
          <div v-for="user in searchResults" :key="user.userId" class="user-card">
            <div class="user-avatar">
              <el-avatar :size="40" :src="user.avatar || undefined">
                {{ user.nickname?.charAt(0) || user.username?.charAt(0) }}
              </el-avatar>
            </div>
            <div class="user-info">
              <div class="user-name">{{ user.nickname || user.username }}</div>
              <div class="user-student-no">{{ user.studentNo }}</div>
            </div>
            <div class="user-action">
              <el-button 
                v-if="user.friendStatus === 'none'"
                type="primary" 
                size="small"
                @click="handleSendRequest(user)"
              >
                添加
              </el-button>
              <el-tag v-else-if="user.friendStatus === 'friend'" type="success" size="small">
                已是好友
              </el-tag>
              <el-tag v-else-if="user.friendStatus === 'sent'" type="info" size="small">
                已发送
              </el-tag>
              <el-button 
                v-else-if="user.friendStatus === 'received'"
                type="success" 
                size="small"
                @click="quickAccept(user.userId)"
              >
                同意
              </el-button>
            </div>
          </div>
        </div>
      </div>
    </el-dialog>

    <!-- 修改备注对话框 -->
    <el-dialog v-model="showRemarkDialog" title="修改备注" width="400px">
      <el-form>
        <el-form-item label="备注名称">
          <el-input v-model="remarkForm.remark" placeholder="请输入备注名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showRemarkDialog = false">取消</el-button>
        <el-button type="primary" @click="handleUpdateRemark">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  User, Bell, Plus, More, Edit, Delete, Search, Promotion 
} from '@element-plus/icons-vue'
import { 
  getFriendList, getReceivedRequests, getSentRequests, 
  searchUsers, sendFriendRequest, acceptFriendRequest, 
  rejectFriendRequest, deleteFriend, updateFriendRemark,
  getPendingRequestCount, getFriendCount
} from '@/api/social'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/zh-cn'

dayjs.extend(relativeTime)
dayjs.locale('zh-cn')

// 状态
const loading = ref(false)
const activeTab = ref('friends')
const friendList = ref<any[]>([])
const receivedRequests = ref<any[]>([])
const sentRequests = ref<any[]>([])
const stats = reactive({
  friendCount: 0,
  pendingCount: 0
})

// 搜索
const showSearchDialog = ref(false)
const searchKeyword = ref('')
const searchLoading = ref(false)
const searchResults = ref<any[]>([])

// 备注
const showRemarkDialog = ref(false)
const remarkForm = reactive({
  friendId: 0,
  remark: ''
})

// 格式化时间
const formatTime = (time: string) => {
  return dayjs(time).fromNow()
}

// 加载好友列表
const loadFriendList = async () => {
  loading.value = true
  try {
    const res = await getFriendList()
    friendList.value = res || []
  } catch (e) {
    console.error('加载好友列表失败', e)
  } finally {
    loading.value = false
  }
}

// 加载收到的请求
const loadReceivedRequests = async () => {
  loading.value = true
  try {
    const res = await getReceivedRequests()
    receivedRequests.value = res || []
  } catch (e) {
    console.error('加载好友请求失败', e)
  } finally {
    loading.value = false
  }
}

// 加载发出的请求
const loadSentRequests = async () => {
  loading.value = true
  try {
    const res = await getSentRequests()
    sentRequests.value = res || []
  } catch (e) {
    console.error('加载已发送请求失败', e)
  } finally {
    loading.value = false
  }
}

// 加载统计
const loadStats = async () => {
  try {
    const [countRes, pendingRes] = await Promise.all([
      getFriendCount(),
      getPendingRequestCount()
    ])
    stats.friendCount = countRes || 0
    stats.pendingCount = pendingRes || 0
  } catch (e) {
    console.error('加载统计失败', e)
  }
}

// 搜索用户
const handleSearch = async () => {
  if (!searchKeyword.value.trim()) {
    ElMessage.warning('请输入搜索关键词')
    return
  }
  searchLoading.value = true
  try {
    const res = await searchUsers(searchKeyword.value.trim())
    searchResults.value = res || []
  } catch (e) {
    console.error('搜索失败', e)
  } finally {
    searchLoading.value = false
  }
}

// 发送好友请求
const handleSendRequest = async (user: any) => {
  try {
    await sendFriendRequest({ friendId: user.userId })
    ElMessage.success('好友请求已发送')
    user.friendStatus = 'sent'
  } catch (e: any) {
    ElMessage.error(e.message || '发送失败')
  }
}

// 接受好友请求
const handleAccept = async (requestId: number) => {
  try {
    await acceptFriendRequest(requestId)
    ElMessage.success('已接受好友请求')
    loadReceivedRequests()
    loadStats()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

// 拒绝好友请求
const handleReject = async (requestId: number) => {
  try {
    await ElMessageBox.confirm('确定要拒绝此好友请求吗？', '提示', {
      type: 'warning'
    })
    await rejectFriendRequest(requestId)
    ElMessage.success('已拒绝好友请求')
    loadReceivedRequests()
    loadStats()
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e.message || '操作失败')
    }
  }
}

// 快速接受
const quickAccept = async (userId: number) => {
  // 找到对应的请求ID
  const req = receivedRequests.value.find(r => r.userId === userId)
  if (req) {
    await handleAccept(req.requestId)
    showSearchDialog.value = false
  }
}

// 删除好友
const handleDeleteFriend = async (friend: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除好友 ${friend.remark || friend.nickname || friend.username} 吗？`,
      '删除好友',
      { type: 'warning' }
    )
    await deleteFriend(friend.userId)
    ElMessage.success('已删除好友')
    loadFriendList()
    loadStats()
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e.message || '删除失败')
    }
  }
}

// 修改备注
const editRemark = (friend: any) => {
  remarkForm.friendId = friend.userId
  remarkForm.remark = friend.remark || ''
  showRemarkDialog.value = true
}

const handleUpdateRemark = async () => {
  try {
    await updateFriendRemark(remarkForm.friendId, remarkForm.remark)
    ElMessage.success('备注已更新')
    showRemarkDialog.value = false
    loadFriendList()
  } catch (e: any) {
    ElMessage.error(e.message || '更新失败')
  }
}

// 监听标签页切换
watch(activeTab, (tab) => {
  if (tab === 'friends') {
    loadFriendList()
  } else if (tab === 'requests') {
    loadReceivedRequests()
  } else if (tab === 'sent') {
    loadSentRequests()
  }
})

// 监听搜索对话框关闭
watch(showSearchDialog, (visible) => {
  if (!visible) {
    searchKeyword.value = ''
    searchResults.value = []
  }
})

onMounted(() => {
  loadFriendList()
  loadStats()
})
</script>

<style lang="scss" scoped>
.friends-container {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 24px;
  
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

.stats-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s;
  position: relative;
  cursor: pointer;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
  }
  
  .stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
  }
  
  &.friends .stat-icon {
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
  }
  
  &.requests .stat-icon {
    background: linear-gradient(135deg, #f093fb, #f5576c);
    color: white;
  }
  
  &.add .stat-icon {
    background: linear-gradient(135deg, #4facfe, #00f2fe);
    color: white;
  }
  
  .stat-info {
    display: flex;
    flex-direction: column;
  }
  
  .stat-value {
    font-size: 28px;
    font-weight: 700;
    color: #1a1a2e;
  }
  
  .stat-label {
    font-size: 14px;
    color: #666;
  }
  
  .badge {
    position: absolute;
    top: 12px;
    right: 12px;
  }
}

.tabs-container {
  margin-bottom: 24px;
  
  .tabs {
    display: flex;
    gap: 8px;
    background: #f5f7fa;
    padding: 4px;
    border-radius: 12px;
    width: fit-content;
  }
  
  .tab {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 20px;
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
    
    .el-badge {
      margin-left: 4px;
    }
  }
}

.content-area {
  min-height: 300px;
}

.loading-state,
.empty-state {
  padding: 60px 20px;
  text-align: center;
}

.friend-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

.friend-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  transition: all 0.3s;
  
  &:hover {
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  }
  
  .friend-avatar {
    flex-shrink: 0;
  }
  
  .friend-info {
    flex: 1;
    min-width: 0;
  }
  
  .friend-name {
    font-size: 16px;
    font-weight: 600;
    color: #1a1a2e;
    margin-bottom: 2px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  
  .friend-original-name {
    font-size: 12px;
    color: #999;
  }
  
  .friend-student-no {
    font-size: 13px;
    color: #666;
  }
  
  .friend-actions {
    flex-shrink: 0;
  }
}

.request-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.request-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  
  &.sent {
    opacity: 0.8;
  }
  
  .request-avatar {
    flex-shrink: 0;
  }
  
  .request-info {
    flex: 1;
    min-width: 0;
  }
  
  .request-name {
    font-size: 15px;
    font-weight: 600;
    color: #1a1a2e;
    margin-bottom: 2px;
  }
  
  .request-student-no {
    font-size: 13px;
    color: #666;
  }
  
  .request-time {
    font-size: 12px;
    color: #999;
    margin-top: 2px;
  }
  
  .request-actions {
    display: flex;
    gap: 8px;
    flex-shrink: 0;
  }
  
  .request-status {
    flex-shrink: 0;
  }
}

// 搜索对话框
.search-container {
  margin-bottom: 20px;
}

.search-results {
  min-height: 200px;
  max-height: 400px;
  overflow-y: auto;
}

.user-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.user-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
  
  .user-avatar {
    flex-shrink: 0;
  }
  
  .user-info {
    flex: 1;
    min-width: 0;
  }
  
  .user-name {
    font-size: 14px;
    font-weight: 600;
    color: #1a1a2e;
  }
  
  .user-student-no {
    font-size: 12px;
    color: #666;
  }
  
  .user-action {
    flex-shrink: 0;
  }
}

// 响应式
@media (max-width: 768px) {
  .friends-container {
    padding: 16px;
  }
  
  .stats-row {
    grid-template-columns: 1fr;
  }
  
  .tabs-container .tabs {
    width: 100%;
    
    .tab {
      flex: 1;
      justify-content: center;
    }
  }
  
  .friend-grid {
    grid-template-columns: 1fr;
  }
}
</style>
