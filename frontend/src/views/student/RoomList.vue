<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getRoomList, getHotRooms, addFavorite, removeFavorite, type StudyRoom } from '@/api/room'
import { ElMessage } from 'element-plus'
import {
  Search, Star, MapPin, Clock, Users, Wifi, Zap, Coffee, Armchair,
  ChevronRight, Heart, Loader2
} from 'lucide-vue-next'

const router = useRouter()

const loading = ref(false)
const rooms = ref<StudyRoom[]>([])
const hotRooms = ref<StudyRoom[]>([])
const total = ref(0)
const searchParams = ref({
  page: 1,
  size: 12,
  keyword: '',
  building: '',
  status: 1
})

// 建筑物筛选选项
const buildings = computed(() => {
  const set = new Set(rooms.value.map(r => r.building))
  return Array.from(set)
})

// 设施图标映射
const facilityIcons: Record<string, any> = {
  '空调': Coffee,
  'WiFi': Wifi,
  '电源': Zap,
  '饮水机': Coffee,
  '电脑': Armchair,
}

onMounted(async () => {
  await Promise.all([loadRooms(), loadHotRooms()])
})

async function loadRooms() {
  loading.value = true
  try {
    const res = await getRoomList(searchParams.value)
    rooms.value = res.records
    total.value = res.total
  } catch (error) {
    console.error('加载自习室列表失败', error)
  } finally {
    loading.value = false
  }
}

async function loadHotRooms() {
  try {
    hotRooms.value = await getHotRooms(4)
  } catch (error) {
    console.error('加载热门自习室失败', error)
  }
}

function handleSearch() {
  searchParams.value.page = 1
  loadRooms()
}

function handlePageChange(page: number) {
  searchParams.value.page = page
  loadRooms()
}

function goToRoom(roomId: number) {
  router.push(`/rooms/${roomId}`)
}

async function toggleFavorite(room: StudyRoom, event: Event) {
  event.stopPropagation()
  try {
    if (room.isFavorite) {
      await removeFavorite(room.id)
      room.isFavorite = false
      ElMessage.success('已取消收藏')
    } else {
      await addFavorite(room.id)
      room.isFavorite = true
      ElMessage.success('收藏成功')
    }
  } catch (error) {
    // 错误已在拦截器处理
  }
}

// 获取状态标签
function getStatusTag(status: number) {
  switch (status) {
    case 0: return { text: '已关闭', type: 'info' }
    case 1: return { text: '开放中', type: 'success' }
    case 2: return { text: '维护中', type: 'warning' }
    default: return { text: '未知', type: 'info' }
  }
}

// 获取座位类型颜色
function getSeatTypeColor(type: string) {
  switch (type) {
    case 'VIP': return '#FFD700'
    case 'POWER': return '#3FB19E'
    case 'WINDOW': return '#7195B9'
    default: return '#9E9E9E'
  }
}
</script>

<template>
  <div class="room-list-page">
    <!-- 热门推荐 -->
    <section class="hot-section" v-if="hotRooms.length">
      <div class="section-header">
        <h2>
          <Star :size="22" class="icon" />
          热门推荐
        </h2>
        <span class="subtitle">最受欢迎的自习室</span>
      </div>
      <div class="hot-grid">
        <div 
          v-for="room in hotRooms" 
          :key="room.id" 
          class="hot-card"
          @click="goToRoom(room.id)"
        >
          <div class="hot-card-cover">
            <img :src="room.coverImage || '/images/rooms/default.svg'" :alt="room.name" />
            <div class="hot-card-overlay">
              <span class="rating">
                <Star :size="14" fill="#FFD700" />
                {{ room.rating }}
              </span>
            </div>
          </div>
          <div class="hot-card-info">
            <h3>{{ room.name }}</h3>
            <p class="location">
              <MapPin :size="14" />
              {{ room.building }} {{ room.floor }}
            </p>
            <div class="stats">
              <span>
                <Users :size="14" />
                {{ room.availableSeats }}/{{ room.capacity }}
              </span>
              <span>
                <Clock :size="14" />
                {{ room.openTime }}-{{ room.closeTime }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 搜索栏 -->
    <section class="search-section">
      <div class="search-bar">
        <el-input
          v-model="searchParams.keyword"
          placeholder="搜索自习室名称、编号..."
          clearable
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <Search :size="18" />
          </template>
        </el-input>
        <el-select 
          v-model="searchParams.building" 
          placeholder="全部建筑" 
          clearable
          @change="handleSearch"
        >
          <el-option 
            v-for="b in buildings" 
            :key="b" 
            :label="b" 
            :value="b" 
          />
        </el-select>
        <el-button type="primary" @click="handleSearch">
          <Search :size="16" />
          搜索
        </el-button>
      </div>
    </section>

    <!-- 自习室列表 -->
    <section class="list-section">
      <div class="section-header">
        <h2>全部自习室</h2>
        <span class="total">共 {{ total }} 个</span>
      </div>

      <div v-if="loading" class="loading-state">
        <Loader2 :size="32" class="spinning" />
        <span>加载中...</span>
      </div>

      <div v-else-if="rooms.length === 0" class="empty-state">
        <img src="@/assets/images/empty/no-data.svg" alt="暂无数据" />
        <p>暂无符合条件的自习室</p>
      </div>

      <div v-else class="room-grid">
        <div 
          v-for="room in rooms" 
          :key="room.id" 
          class="room-card"
          @click="goToRoom(room.id)"
        >
          <div class="room-card-header">
            <el-tag :type="getStatusTag(room.status).type" size="small">
              {{ getStatusTag(room.status).text }}
            </el-tag>
            <button 
              class="favorite-btn" 
              :class="{ active: room.isFavorite }"
              @click="toggleFavorite(room, $event)"
            >
              <Heart :size="18" :fill="room.isFavorite ? '#FF4757' : 'none'" />
            </button>
          </div>

          <div class="room-card-body">
            <h3>{{ room.name }}</h3>
            <p class="code">{{ room.code }}</p>
            <p class="location">
              <MapPin :size="14" />
              {{ room.building }} {{ room.floor }} {{ room.roomNumber }}
            </p>
            
            <div class="facilities">
              <span 
                v-for="(facility, index) in room.facilities?.slice(0, 4)" 
                :key="index"
                class="facility-tag"
              >
                {{ facility }}
              </span>
              <span v-if="room.facilities?.length > 4" class="facility-more">
                +{{ room.facilities.length - 4 }}
              </span>
            </div>
          </div>

          <div class="room-card-footer">
            <div class="seat-info">
              <div class="available">
                <span class="number">{{ room.availableSeats }}</span>
                <span class="label">空位</span>
              </div>
              <span class="divider">/</span>
              <div class="total">
                <span class="number">{{ room.capacity }}</span>
                <span class="label">总数</span>
              </div>
            </div>
            <div class="rating">
              <Star :size="16" fill="#FFD700" stroke="#FFD700" />
              <span>{{ room.rating }}</span>
              <span class="count">({{ room.ratingCount }})</span>
            </div>
          </div>

          <div class="room-card-action">
            <span>立即预约</span>
            <ChevronRight :size="18" />
          </div>
        </div>
      </div>

      <!-- 分页 -->
      <div v-if="total > searchParams.size" class="pagination">
        <el-pagination
          background
          layout="prev, pager, next"
          :total="total"
          :page-size="searchParams.size"
          :current-page="searchParams.page"
          @current-change="handlePageChange"
        />
      </div>
    </section>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';
.room-list-page {
  animation: fadeIn 0.5s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.spinning {
  animation: spin 1s linear infinite;
}

// 热门推荐
.hot-section {
  margin-bottom: 32px;
  
  .section-header {
    display: flex;
    align-items: baseline;
    gap: 12px;
    margin-bottom: 20px;
    
    h2 {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 20px;
      font-weight: 600;
      color: $text-primary;
      
      .icon {
        color: $accent;
      }
    }
    
    .subtitle {
      font-size: 14px;
      color: $text-muted;
    }
  }
}

.hot-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  
  @media (max-width: 1200px) {
    grid-template-columns: repeat(2, 1fr);
  }
  
  @media (max-width: 640px) {
    grid-template-columns: 1fr;
  }
}

.hot-card {
  background: white;
  border-radius: $radius-lg;
  overflow: hidden;
  box-shadow: $shadow-card;
  cursor: pointer;
  transition: all 0.3s;
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: $shadow-card-hover;
  }
  
  .hot-card-cover {
    position: relative;
    height: 140px;
    
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    
    .hot-card-overlay {
      position: absolute;
      top: 12px;
      right: 12px;
      
      .rating {
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 4px 10px;
        background: rgba(0,0,0,0.6);
        color: white;
        border-radius: 20px;
        font-size: 13px;
        font-weight: 500;
      }
    }
  }
  
  .hot-card-info {
    padding: 16px;
    
    h3 {
      font-size: 16px;
      font-weight: 600;
      color: $text-primary;
      margin-bottom: 8px;
    }
    
    .location {
      display: flex;
      align-items: center;
      gap: 4px;
      font-size: 13px;
      color: $text-muted;
      margin-bottom: 12px;
    }
    
    .stats {
      display: flex;
      gap: 16px;
      font-size: 13px;
      color: $text-secondary;
      
      span {
        display: flex;
        align-items: center;
        gap: 4px;
      }
    }
  }
}

// 搜索栏
.search-section {
  margin-bottom: 24px;
  
  .search-bar {
    display: flex;
    gap: 12px;
    padding: 20px;
    background: white;
    border-radius: $radius-lg;
    box-shadow: $shadow-card;
    
    :deep(.el-input) {
      flex: 1;
      max-width: 400px;
    }
    
    :deep(.el-select) {
      width: 160px;
    }
    
    @media (max-width: 768px) {
      flex-wrap: wrap;
      
      :deep(.el-input),
      :deep(.el-select) {
        width: 100%;
        max-width: none;
      }
    }
  }
}

// 自习室列表
.list-section {
  .section-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
    
    h2 {
      font-size: 20px;
      font-weight: 600;
      color: $text-primary;
    }
    
    .total {
      font-size: 14px;
      color: $text-muted;
    }
  }
}

.loading-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 20px;
  color: $text-muted;
  
  img {
    width: 200px;
    margin-bottom: 20px;
  }
}

.room-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  
  @media (max-width: 1200px) {
    grid-template-columns: repeat(2, 1fr);
  }
  
  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.room-card {
  background: white;
  border-radius: $radius-lg;
  overflow: hidden;
  box-shadow: $shadow-card;
  cursor: pointer;
  transition: all 0.3s;
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: $shadow-card-hover;
    
    .room-card-action {
      background: $primary;
      color: white;
    }
  }
  
  .room-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 16px 0;
    
    .favorite-btn {
      background: none;
      border: none;
      padding: 8px;
      cursor: pointer;
      color: $gray-400;
      transition: all 0.2s;
      
      &:hover {
        color: #FF4757;
      }
      
      &.active {
        color: #FF4757;
      }
    }
  }
  
  .room-card-body {
    padding: 16px;
    
    h3 {
      font-size: 18px;
      font-weight: 600;
      color: $text-primary;
      margin-bottom: 4px;
    }
    
    .code {
      font-size: 12px;
      color: $primary;
      font-weight: 500;
      margin-bottom: 8px;
    }
    
    .location {
      display: flex;
      align-items: center;
      gap: 4px;
      font-size: 14px;
      color: $text-muted;
      margin-bottom: 12px;
    }
    
    .facilities {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      
      .facility-tag {
        padding: 4px 10px;
        background: $gray-50;
        color: $text-secondary;
        font-size: 12px;
        border-radius: 4px;
      }
      
      .facility-more {
        padding: 4px 10px;
        background: $primary-50;
        color: $primary;
        font-size: 12px;
        border-radius: 4px;
      }
    }
  }
  
  .room-card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 16px 16px;
    
    .seat-info {
      display: flex;
      align-items: baseline;
      gap: 4px;
      
      .available {
        .number {
          font-size: 24px;
          font-weight: 700;
          color: $primary;
        }
        .label {
          font-size: 12px;
          color: $text-muted;
          margin-left: 2px;
        }
      }
      
      .divider {
        color: $gray-300;
        margin: 0 4px;
      }
      
      .total {
        .number {
          font-size: 16px;
          font-weight: 500;
          color: $text-secondary;
        }
        .label {
          font-size: 12px;
          color: $text-muted;
          margin-left: 2px;
        }
      }
    }
    
    .rating {
      display: flex;
      align-items: center;
      gap: 4px;
      
      span {
        font-size: 14px;
        font-weight: 600;
        color: $text-primary;
      }
      
      .count {
        font-weight: 400;
        color: $text-muted;
      }
    }
  }
  
  .room-card-action {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 4px;
    padding: 14px;
    background: $gray-50;
    color: $text-secondary;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.3s;
  }
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 32px;
}
</style>
