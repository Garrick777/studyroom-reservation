<template>
  <div class="ranking-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-bg"></div>
      <div class="header-content">
        <h1><Trophy :size="28" class="title-icon" /> 排行榜</h1>
        <p>与学霸们一起竞争，成为学习之星</p>
      </div>
    </div>

    <!-- 我的排名概览 -->
    <div class="my-rank-section" v-if="myRanks">
      <h3>我的排名</h3>
      <div class="my-rank-grid">
        <div class="rank-card study-time">
          <div class="rank-icon"><BookOpen :size="24" /></div>
          <div class="rank-info">
            <span class="rank-type">学习时长</span>
            <span class="rank-value">第 {{ myRanks.studyTime?.rank || '-' }} 名</span>
            <span class="rank-detail">{{ myRanks.studyTime?.value || 0 }} {{ myRanks.studyTime?.unit }}</span>
          </div>
        </div>
        <div class="rank-card checkin">
          <div class="rank-icon"><Flame :size="24" /></div>
          <div class="rank-info">
            <span class="rank-type">连续打卡</span>
            <span class="rank-value">第 {{ myRanks.checkIn?.rank || '-' }} 名</span>
            <span class="rank-detail">{{ myRanks.checkIn?.value || 0 }} {{ myRanks.checkIn?.unit }}</span>
          </div>
        </div>
        <div class="rank-card points">
          <div class="rank-icon"><Gem :size="24" /></div>
          <div class="rank-info">
            <span class="rank-type">积分排名</span>
            <span class="rank-value">第 {{ myRanks.points?.rank || '-' }} 名</span>
            <span class="rank-detail">{{ myRanks.points?.value || 0 }} {{ myRanks.points?.unit }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 排行榜选项卡 -->
    <div class="ranking-tabs">
      <div 
        v-for="tab in tabs" 
        :key="tab.key"
        :class="['tab-item', { active: activeTab === tab.key }]"
        @click="activeTab = tab.key"
      >
        <span class="tab-icon"><component :is="tab.icon" :size="18" /></span>
        <span class="tab-name">{{ tab.name }}</span>
      </div>
    </div>

    <!-- 时间周期选择(仅学习时长) -->
    <div class="period-selector" v-if="activeTab === 'studyTime'">
      <el-radio-group v-model="period" @change="loadRanking">
        <el-radio-button label="daily">今日</el-radio-button>
        <el-radio-button label="weekly">本周</el-radio-button>
        <el-radio-button label="monthly">本月</el-radio-button>
        <el-radio-button label="all">总榜</el-radio-button>
      </el-radio-group>
    </div>

    <!-- 排行榜列表 -->
    <div class="ranking-list" v-loading="loading">
      <!-- 前三名特殊展示 -->
      <div class="top-three" v-if="rankingList.length >= 3">
        <div class="top-item second">
          <div class="avatar-wrapper">
            <img :src="getAvatar(rankingList[1])" class="avatar" />
            <div class="rank-badge">2</div>
          </div>
          <div class="user-name">{{ rankingList[1].realName || rankingList[1].username }}</div>
          <div class="user-value">{{ rankingList[1].value }} {{ rankingList[1].unit }}</div>
        </div>
        <div class="top-item first">
          <div class="crown">👑</div>
          <div class="avatar-wrapper">
            <img :src="getAvatar(rankingList[0])" class="avatar" />
            <div class="rank-badge">1</div>
          </div>
          <div class="user-name">{{ rankingList[0].realName || rankingList[0].username }}</div>
          <div class="user-value">{{ rankingList[0].value }} {{ rankingList[0].unit }}</div>
        </div>
        <div class="top-item third">
          <div class="avatar-wrapper">
            <img :src="getAvatar(rankingList[2])" class="avatar" />
            <div class="rank-badge">3</div>
          </div>
          <div class="user-name">{{ rankingList[2].realName || rankingList[2].username }}</div>
          <div class="user-value">{{ rankingList[2].value }} {{ rankingList[2].unit }}</div>
        </div>
      </div>

      <!-- 其他排名 -->
      <div class="rest-list">
        <div 
          v-for="(item, index) in restRankingList" 
          :key="item.userId"
          class="rank-item"
        >
          <div class="rank-num">{{ index + 4 }}</div>
          <img :src="getAvatar(item)" class="avatar" />
          <div class="user-info">
            <span class="name">{{ item.realName || item.username }}</span>
          </div>
          <div class="value">{{ item.value }} {{ item.unit }}</div>
        </div>
      </div>

      <el-empty v-if="!loading && rankingList.length === 0" description="暂无排行数据" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, markRaw } from 'vue'
import { 
  getStudyTimeRanking, 
  getCheckInStreakRanking, 
  getPointsRanking, 
  getAchievementRanking,
  getRankingOverview 
} from '@/api/ranking'
import { Trophy, BookOpen, Flame, Gem, Medal } from 'lucide-vue-next'

const tabs = [
  { key: 'studyTime', name: '学习时长', icon: markRaw(BookOpen) },
  { key: 'checkIn', name: '连续打卡', icon: markRaw(Flame) },
  { key: 'points', name: '积分排名', icon: markRaw(Gem) },
  { key: 'achievement', name: '成就达人', icon: markRaw(Medal) }
]

const activeTab = ref('studyTime')
const period = ref('weekly')
const loading = ref(false)
const rankingList = ref<any[]>([])
const myRanks = ref<any>(null)

const restRankingList = computed(() => rankingList.value.slice(3))

const loadRanking = async () => {
  loading.value = true
  try {
    let res
    switch (activeTab.value) {
      case 'studyTime':
        res = await getStudyTimeRanking({ period: period.value, limit: 50 })
        break
      case 'checkIn':
        res = await getCheckInStreakRanking(50)
        break
      case 'points':
        res = await getPointsRanking(50)
        break
      case 'achievement':
        res = await getAchievementRanking(50)
        break
    }
    rankingList.value = res || []
  } catch (e) {
    console.error('加载排行榜失败:', e)
  } finally {
    loading.value = false
  }
}

const loadOverview = async () => {
  try {
    const res = await getRankingOverview()
    myRanks.value = res.myRanks
  } catch (e) {
    console.error('加载排名概览失败:', e)
  }
}

const getAvatar = (user: any) => {
  if (user?.avatar) {
    if (user.avatar.startsWith('http')) return user.avatar
    return `/api${user.avatar}`
  }
  return `https://api.dicebear.com/7.x/avataaars/svg?seed=${user?.username || 'default'}`
}

watch(activeTab, () => {
  loadRanking()
})

onMounted(() => {
  loadRanking()
  loadOverview()
})
</script>

<style scoped lang="scss">
.ranking-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  padding-bottom: 40px;
}

.page-header {
  position: relative;
  padding: 40px 24px;
  text-align: center;
  overflow: hidden;

  .header-bg {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="20" cy="20" r="2" fill="rgba(255,215,0,0.3)"/><circle cx="80" cy="30" r="1.5" fill="rgba(255,215,0,0.2)"/><circle cx="50" cy="50" r="2.5" fill="rgba(255,215,0,0.25)"/><circle cx="30" cy="70" r="1" fill="rgba(255,215,0,0.3)"/><circle cx="70" cy="80" r="2" fill="rgba(255,215,0,0.2)"/></svg>');
    animation: twinkle 3s infinite;
  }

  @keyframes twinkle {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.6; }
  }

  .header-content {
    position: relative;
    z-index: 1;

    h1 {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      font-size: 32px;
      font-weight: 700;
      color: #f59e0b;
      margin-bottom: 8px;
    }

    p {
      color: #64748b;
      font-size: 14px;
    }
  }
}

.my-rank-section {
  padding: 0 24px;
  margin-bottom: 24px;

  h3 {
    color: #1e293b;
    font-size: 16px;
    margin-bottom: 12px;
    padding-left: 4px;
  }

  .my-rank-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;

    .rank-card {
      background: white;
      border-radius: 16px;
      padding: 16px;
      display: flex;
      align-items: center;
      gap: 12px;
      border: 1px solid #e2e8f0;
      box-shadow: 0 2px 8px rgba(0,0,0,0.05);

      .rank-icon {
        font-size: 28px;
        color: #f59e0b;
      }

      .rank-info {
        display: flex;
        flex-direction: column;

        .rank-type {
          font-size: 12px;
          color: #64748b;
        }

        .rank-value {
          font-size: 18px;
          font-weight: 700;
          color: #f59e0b;
        }

        .rank-detail {
          font-size: 11px;
          color: #94a3b8;
        }
      }

      &.study-time { border-left: 3px solid #6366f1; }
      &.checkin { border-left: 3px solid #ef4444; }
      &.points { border-left: 3px solid #3b82f6; }
    }
  }
}

.ranking-tabs {
  display: flex;
  justify-content: center;
  gap: 8px;
  padding: 0 24px;
  margin-bottom: 20px;

  .tab-item {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 10px 18px;
    background: white;
    border: 1px solid #e2e8f0;
    border-radius: 24px;
    cursor: pointer;
    transition: all 0.3s;
    color: #64748b;

    &:hover {
      background: #f8fafc;
      border-color: #f59e0b;
    }

    &.active {
      background: linear-gradient(135deg, #f59e0b, #d97706);
      color: white;
      border-color: transparent;
      font-weight: 600;
    }

    .tab-icon {
      font-size: 16px;
    }

    .tab-name {
      font-size: 14px;
    }
  }
}

.period-selector {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;

  :deep(.el-radio-group) {
    background: white;
    border-radius: 12px;
    padding: 4px;
    border: 1px solid #e2e8f0;

    .el-radio-button__inner {
      background: transparent;
      border: none;
      color: #64748b;
      padding: 8px 16px;
    }

    .el-radio-button__original-radio:checked + .el-radio-button__inner {
      background: #fef3c7;
      color: #d97706;
      box-shadow: none;
    }
  }
}

.ranking-list {
  padding: 0 24px;
}

.top-three {
  display: flex;
  justify-content: center;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 32px;
  padding: 24px 0;

  .top-item {
    text-align: center;
    position: relative;

    .crown {
      font-size: 32px;
      margin-bottom: 8px;
      animation: float 2s ease-in-out infinite;
    }

    @keyframes float {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(-8px); }
    }

    .avatar-wrapper {
      position: relative;
      margin-bottom: 12px;

      .avatar {
        border-radius: 50%;
        object-fit: cover;
        border: 3px solid;
      }

      .rank-badge {
        position: absolute;
        bottom: -8px;
        left: 50%;
        transform: translateX(-50%);
        width: 24px;
        height: 24px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 12px;
      }
    }

    .user-name {
      color: #1e293b;
      font-weight: 600;
      font-size: 14px;
      margin-bottom: 4px;
    }

    .user-value {
      color: #64748b;
      font-size: 12px;
    }

    &.first {
      .avatar-wrapper .avatar {
        width: 90px;
        height: 90px;
        border-color: #ffd700;
        box-shadow: 0 0 30px rgba(255, 215, 0, 0.5);
      }
      .rank-badge {
        background: linear-gradient(135deg, #ffd700, #ff8c00);
        color: #1a1a2e;
      }
    }

    &.second {
      .avatar-wrapper .avatar {
        width: 70px;
        height: 70px;
        border-color: #c0c0c0;
        box-shadow: 0 0 20px rgba(192, 192, 192, 0.4);
      }
      .rank-badge {
        background: linear-gradient(135deg, #c0c0c0, #a0a0a0);
        color: #1a1a2e;
      }
    }

    &.third {
      .avatar-wrapper .avatar {
        width: 70px;
        height: 70px;
        border-color: #cd7f32;
        box-shadow: 0 0 20px rgba(205, 127, 50, 0.4);
      }
      .rank-badge {
        background: linear-gradient(135deg, #cd7f32, #b8860b);
        color: white;
      }
    }
  }
}

.rest-list {
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);

  .rank-item {
    display: flex;
    align-items: center;
    padding: 16px 20px;
    border-bottom: 1px solid #f1f5f9;

    &:last-child {
      border-bottom: none;
    }

    .rank-num {
      width: 32px;
      font-size: 16px;
      font-weight: 600;
      color: #94a3b8;
    }

    .avatar {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      object-fit: cover;
      margin-right: 12px;
    }

    .user-info {
      flex: 1;

      .name {
        color: #1e293b;
        font-weight: 500;
      }
    }

    .value {
      color: #f59e0b;
      font-weight: 600;
      font-size: 15px;
    }
  }
}
</style>
