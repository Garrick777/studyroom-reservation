<template>
  <div class="messages-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-left">
        <h1>消息中心</h1>
        <p>查看系统通知、预约提醒等消息</p>
      </div>
      <div class="header-right">
        <el-button v-if="stats.unreadCount > 0" @click="handleMarkAllRead">
          <el-icon><Check /></el-icon>
          全部已读
        </el-button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-row">
      <div 
        v-for="type in messageTypes" 
        :key="type.value"
        class="stat-card"
        :class="{ active: currentType === type.value }"
        @click="currentType = type.value"
      >
        <div class="stat-icon" :style="{ background: type.gradient }">
          <el-icon><component :is="type.icon" /></el-icon>
        </div>
        <div class="stat-info">
          <span class="stat-label">{{ type.label }}</span>
          <span v-if="stats.unreadByType[type.value]" class="stat-badge">
            {{ stats.unreadByType[type.value] }}
          </span>
        </div>
      </div>
    </div>

    <!-- 筛选条件 -->
    <div class="filter-bar">
      <div class="filter-tabs">
        <div 
          class="filter-tab" 
          :class="{ active: readFilter === null }"
          @click="readFilter = null"
        >
          全部
        </div>
        <div 
          class="filter-tab" 
          :class="{ active: readFilter === 0 }"
          @click="readFilter = 0"
        >
          <el-badge :value="stats.unreadCount" :hidden="stats.unreadCount === 0" :max="99">
            未读
          </el-badge>
        </div>
        <div 
          class="filter-tab" 
          :class="{ active: readFilter === 1 }"
          @click="readFilter = 1"
        >
          已读
        </div>
      </div>
    </div>

    <!-- 消息列表 -->
    <div class="message-list">
      <div v-if="loading" class="loading-state">
        <el-skeleton :rows="5" animated />
      </div>
      <div v-else-if="messages.length === 0" class="empty-state">
        <el-empty description="暂无消息" />
      </div>
      <template v-else>
        <div 
          v-for="msg in messages" 
          :key="msg.id" 
          class="message-card"
          :class="{ unread: msg.isRead === 0 }"
          @click="viewMessage(msg)"
        >
          <div class="message-icon" :style="{ background: getTypeColor(msg.type) }">
            <el-icon><component :is="getTypeIcon(msg.type)" /></el-icon>
          </div>
          <div class="message-content">
            <div class="message-header">
              <span class="message-title">{{ msg.title }}</span>
              <el-tag :type="getTagType(msg.type)" size="small">
                {{ getTypeName(msg.type) }}
              </el-tag>
            </div>
            <div class="message-body">{{ msg.content }}</div>
            <div class="message-footer">
              <span class="message-time">{{ formatTime(msg.createdAt) }}</span>
              <span v-if="msg.isRead === 0" class="unread-dot"></span>
            </div>
          </div>
          <div class="message-actions">
            <el-button 
              v-if="msg.isRead === 0" 
              type="text" 
              size="small"
              @click.stop="handleMarkRead(msg.id)"
            >
              标记已读
            </el-button>
            <el-button 
              type="text" 
              size="small"
              @click.stop="handleDelete(msg.id)"
            >
              删除
            </el-button>
          </div>
        </div>
      </template>
    </div>

    <!-- 分页 -->
    <div v-if="total > pageSize" class="pagination">
      <el-pagination 
        v-model:current-page="currentPage"
        :page-size="pageSize"
        :total="total"
        layout="prev, pager, next, total"
        @current-change="loadMessages"
      />
    </div>

    <!-- 消息详情对话框 -->
    <el-dialog 
      v-model="showDetailDialog" 
      :title="currentMessage?.title || '消息详情'"
      width="500px"
    >
      <div v-if="currentMessage" class="message-detail">
        <div class="detail-header">
          <el-tag :type="getTagType(currentMessage.type)">
            {{ getTypeName(currentMessage.type) }}
          </el-tag>
          <span class="detail-time">{{ formatFullTime(currentMessage.createdAt) }}</span>
        </div>
        <div class="detail-content">
          {{ currentMessage.content }}
        </div>
        <div v-if="currentMessage.relatedType" class="detail-related">
          <el-button type="primary" link @click="goToRelated">
            查看详情
            <el-icon><Right /></el-icon>
          </el-button>
        </div>
      </div>
      <template #footer>
        <el-button @click="showDetailDialog = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch, computed, markRaw } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Bell, Check, ChatLineRound, Calendar, Warning, 
  Trophy, User, UserFilled, Right, Notification
} from '@element-plus/icons-vue'
import { 
  getMessages, getMessageStats, markAsRead, markAllRead, deleteMessage 
} from '@/api/social'
import dayjs from 'dayjs'

// 消息类型配置
const messageTypes = [
  { value: '', label: '全部消息', icon: markRaw(Bell), gradient: 'linear-gradient(135deg, #667eea, #764ba2)' },
  { value: 'SYSTEM', label: '系统消息', icon: markRaw(Notification), gradient: 'linear-gradient(135deg, #667eea, #764ba2)' },
  { value: 'RESERVATION', label: '预约消息', icon: markRaw(Calendar), gradient: 'linear-gradient(135deg, #4facfe, #00f2fe)' },
  { value: 'VIOLATION', label: '违约消息', icon: markRaw(Warning), gradient: 'linear-gradient(135deg, #f093fb, #f5576c)' },
  { value: 'ACHIEVEMENT', label: '成就消息', icon: markRaw(Trophy), gradient: 'linear-gradient(135deg, #fa709a, #fee140)' },
  { value: 'FRIEND', label: '好友消息', icon: markRaw(User), gradient: 'linear-gradient(135deg, #43e97b, #38f9d7)' },
  { value: 'GROUP', label: '小组消息', icon: markRaw(UserFilled), gradient: 'linear-gradient(135deg, #a8edea, #fed6e3)' }
]

// 状态
const loading = ref(false)
const messages = ref<any[]>([])
const currentType = ref('')
const readFilter = ref<number | null>(null)

// 分页
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

// 统计
const stats = reactive({
  unreadCount: 0,
  unreadByType: {} as Record<string, number>
})

// 详情
const showDetailDialog = ref(false)
const currentMessage = ref<any>(null)

// 类型相关
const getTypeName = (type: string) => {
  const found = messageTypes.find(t => t.value === type)
  return found?.label || '消息'
}

const getTypeIcon = (type: string) => {
  const found = messageTypes.find(t => t.value === type)
  return found?.icon || Bell
}

const getTypeColor = (type: string) => {
  const found = messageTypes.find(t => t.value === type)
  return found?.gradient || 'linear-gradient(135deg, #667eea, #764ba2)'
}

const getTagType = (type: string): 'success' | 'warning' | 'info' | 'danger' | 'primary' => {
  switch (type) {
    case 'SYSTEM': return 'info'
    case 'RESERVATION': return 'primary'
    case 'VIOLATION': return 'danger'
    case 'ACHIEVEMENT': return 'warning'
    case 'FRIEND': return 'success'
    case 'GROUP': return 'info'
    default: return 'info'
  }
}

// 格式化时间
const formatTime = (time: string) => {
  const d = dayjs(time)
  const now = dayjs()
  if (d.isSame(now, 'day')) {
    return d.format('HH:mm')
  } else if (d.isSame(now.subtract(1, 'day'), 'day')) {
    return '昨天 ' + d.format('HH:mm')
  } else if (d.isSame(now, 'year')) {
    return d.format('MM-DD HH:mm')
  }
  return d.format('YYYY-MM-DD HH:mm')
}

const formatFullTime = (time: string) => {
  return dayjs(time).format('YYYY年MM月DD日 HH:mm:ss')
}

// 加载消息列表
const loadMessages = async () => {
  loading.value = true
  try {
    const res = await getMessages({
      page: currentPage.value,
      size: pageSize.value,
      type: currentType.value || undefined,
      isRead: readFilter.value !== null ? readFilter.value : undefined
    })
    messages.value = res?.records || []
    total.value = res?.total || 0
  } catch (e) {
    console.error('加载消息失败', e)
  } finally {
    loading.value = false
  }
}

// 加载统计
const loadStats = async () => {
  try {
    const res = await getMessageStats()
    stats.unreadCount = res?.unreadCount || 0
    stats.unreadByType = res?.unreadByType || {}
  } catch (e) {
    console.error('加载统计失败', e)
  }
}

// 查看消息
const viewMessage = async (msg: any) => {
  currentMessage.value = msg
  showDetailDialog.value = true
  
  // 标记已读
  if (msg.isRead === 0) {
    try {
      await markAsRead(msg.id)
      msg.isRead = 1
      loadStats()
    } catch (e) {
      console.error('标记已读失败', e)
    }
  }
}

// 标记单条已读
const handleMarkRead = async (messageId: number) => {
  try {
    await markAsRead(messageId)
    const msg = messages.value.find(m => m.id === messageId)
    if (msg) msg.isRead = 1
    loadStats()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

// 标记全部已读
const handleMarkAllRead = async () => {
  try {
    await markAllRead()
    messages.value.forEach(m => m.isRead = 1)
    loadStats()
    ElMessage.success('已全部标记为已读')
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

// 删除消息
const handleDelete = async (messageId: number) => {
  try {
    await ElMessageBox.confirm('确定要删除这条消息吗？', '提示', { type: 'warning' })
    await deleteMessage(messageId)
    loadMessages()
    loadStats()
    ElMessage.success('已删除')
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e.message || '删除失败')
    }
  }
}

// 跳转相关内容
const goToRelated = () => {
  // TODO: 根据 relatedType 跳转
  ElMessage.info('功能开发中')
  showDetailDialog.value = false
}

// 监听筛选条件变化
watch([currentType, readFilter], () => {
  currentPage.value = 1
  loadMessages()
})

onMounted(() => {
  loadMessages()
  loadStats()
})
</script>

<style lang="scss" scoped>
.messages-container {
  padding: 24px;
  max-width: 1000px;
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

.stats-row {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
  overflow-x: auto;
  padding-bottom: 8px;
  
  &::-webkit-scrollbar {
    height: 6px;
  }
  
  &::-webkit-scrollbar-track {
    background: #f0f0f0;
    border-radius: 3px;
  }
  
  &::-webkit-scrollbar-thumb {
    background: #ccc;
    border-radius: 3px;
  }
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  cursor: pointer;
  transition: all 0.3s;
  flex-shrink: 0;
  border: 2px solid transparent;
  
  &:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }
  
  &.active {
    border-color: #667eea;
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
  }
  
  .stat-icon {
    width: 36px;
    height: 36px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 18px;
  }
  
  .stat-info {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  
  .stat-label {
    font-size: 14px;
    color: #333;
    white-space: nowrap;
  }
  
  .stat-badge {
    min-width: 18px;
    height: 18px;
    padding: 0 6px;
    background: #f56c6c;
    color: white;
    border-radius: 9px;
    font-size: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}

.filter-bar {
  margin-bottom: 20px;
  
  .filter-tabs {
    display: flex;
    gap: 8px;
    background: #f5f7fa;
    padding: 4px;
    border-radius: 8px;
    width: fit-content;
  }
  
  .filter-tab {
    padding: 8px 16px;
    border-radius: 6px;
    cursor: pointer;
    color: #666;
    font-size: 14px;
    transition: all 0.3s;
    
    &:hover {
      color: #333;
    }
    
    &.active {
      background: white;
      color: #667eea;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
    }
    
    :deep(.el-badge__content) {
      top: -4px;
      right: -4px;
    }
  }
}

.message-list {
  min-height: 300px;
}

.loading-state,
.empty-state {
  padding: 80px 20px;
  text-align: center;
}

.message-card {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  padding: 16px 20px;
  background: white;
  border-radius: 12px;
  margin-bottom: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  cursor: pointer;
  transition: all 0.3s;
  
  &:hover {
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
    
    .message-actions {
      opacity: 1;
    }
  }
  
  &.unread {
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
    border-left: 3px solid #667eea;
  }
  
  .message-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 20px;
    flex-shrink: 0;
  }
  
  .message-content {
    flex: 1;
    min-width: 0;
  }
  
  .message-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
  }
  
  .message-title {
    font-size: 15px;
    font-weight: 600;
    color: #1a1a2e;
  }
  
  .message-body {
    font-size: 14px;
    color: #666;
    line-height: 1.5;
    margin-bottom: 8px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
  
  .message-footer {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  
  .message-time {
    font-size: 12px;
    color: #999;
  }
  
  .unread-dot {
    width: 6px;
    height: 6px;
    background: #f56c6c;
    border-radius: 50%;
  }
  
  .message-actions {
    display: flex;
    flex-direction: column;
    gap: 4px;
    opacity: 0;
    transition: opacity 0.3s;
    flex-shrink: 0;
  }
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 24px;
}

// 消息详情
.message-detail {
  .detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 16px;
    border-bottom: 1px solid #f0f0f0;
  }
  
  .detail-time {
    font-size: 13px;
    color: #999;
  }
  
  .detail-content {
    font-size: 15px;
    color: #333;
    line-height: 1.8;
    padding: 16px;
    background: #f8f9fa;
    border-radius: 8px;
    margin-bottom: 16px;
  }
  
  .detail-related {
    text-align: right;
  }
}

// 响应式
@media (max-width: 768px) {
  .messages-container {
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
  
  .stats-row {
    flex-wrap: nowrap;
  }
  
  .message-card {
    .message-actions {
      opacity: 1;
    }
  }
}
</style>
