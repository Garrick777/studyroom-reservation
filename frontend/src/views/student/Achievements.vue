<template>
  <div class="achievements-page">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1>🏆 成就中心</h1>
      <p>探索成就，解锁荣耀</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-section">
      <div class="stat-card total">
        <div class="stat-icon">🎯</div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.completedCount }}/{{ stats.totalCount }}</div>
          <div class="stat-label">已解锁</div>
        </div>
        <div class="stat-progress">
          <div class="progress-bar" :style="{ width: stats.completionRate + '%' }"></div>
        </div>
      </div>
      
      <div class="stat-card unclaimed" v-if="stats.unclaimedCount > 0" @click="showUnclaimedDialog">
        <div class="stat-icon pulse">🎁</div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.unclaimedCount }}</div>
          <div class="stat-label">待领取奖励</div>
        </div>
        <div class="claim-hint">点击领取</div>
      </div>

      <div class="rarity-stats">
        <div class="rarity-item common">
          <span class="rarity-dot"></span>
          <span>普通 {{ stats.rarityStats?.COMMON || 0 }}</span>
        </div>
        <div class="rarity-item rare">
          <span class="rarity-dot"></span>
          <span>稀有 {{ stats.rarityStats?.RARE || 0 }}</span>
        </div>
        <div class="rarity-item epic">
          <span class="rarity-dot"></span>
          <span>史诗 {{ stats.rarityStats?.EPIC || 0 }}</span>
        </div>
        <div class="rarity-item legendary">
          <span class="rarity-dot"></span>
          <span>传说 {{ stats.rarityStats?.LEGENDARY || 0 }}</span>
        </div>
      </div>
    </div>

    <!-- 分类Tab -->
    <div class="category-tabs">
      <button 
        v-for="cat in categories" 
        :key="cat.value"
        :class="['tab-btn', { active: activeCategory === cat.value }]"
        @click="activeCategory = cat.value"
      >
        <span class="tab-icon">{{ cat.icon }}</span>
        <span>{{ cat.label }}</span>
      </button>
    </div>

    <!-- 稀有度筛选 -->
    <div class="filter-bar">
      <el-radio-group v-model="activeRarity" size="small">
        <el-radio-button label="">全部</el-radio-button>
        <el-radio-button label="COMMON">普通</el-radio-button>
        <el-radio-button label="RARE">稀有</el-radio-button>
        <el-radio-button label="EPIC">史诗</el-radio-button>
        <el-radio-button label="LEGENDARY">传说</el-radio-button>
      </el-radio-group>
    </div>

    <!-- 成就网格 -->
    <div class="achievements-grid" v-loading="loading">
      <div 
        v-for="achievement in filteredAchievements" 
        :key="achievement.id"
        :class="['achievement-card', achievement.rarity.toLowerCase(), { 
          unlocked: achievement.userProgress?.isCompleted === 1,
          claimable: achievement.userProgress?.isCompleted === 1 && achievement.userProgress?.isClaimed === 0
        }]"
        @click="showAchievementDetail(achievement)"
      >
        <!-- 稀有度光效 -->
        <div class="rarity-glow"></div>
        
        <!-- 徽章 -->
        <div class="badge-wrapper">
          <div class="achievement-badge" :style="{ backgroundColor: achievement.badgeColor || getRarityColor(achievement.rarity) }">
            <img 
              :src="getAchievementIcon(achievement.icon, achievement.rarity)" 
              :alt="achievement.name"
              class="badge-icon"
            />
          </div>
          <div class="unlock-check" v-if="achievement.userProgress?.isCompleted === 1">✓</div>
          <div class="claimable-dot" v-if="achievement.userProgress?.isCompleted === 1 && achievement.userProgress?.isClaimed === 0"></div>
        </div>
        
        <!-- 信息 -->
        <div class="achievement-info">
          <div class="achievement-name">{{ achievement.name }}</div>
          <div class="achievement-desc">{{ achievement.description }}</div>
        </div>
        
        <!-- 进度 -->
        <div class="achievement-progress" v-if="achievement.userProgress && achievement.userProgress.isCompleted !== 1">
          <div class="progress-bar">
            <div 
              class="progress-fill" 
              :style="{ width: getProgressPercent(achievement) + '%' }"
            ></div>
          </div>
          <div class="progress-text">
            {{ achievement.userProgress.progress }} / {{ achievement.conditionValue }}
          </div>
        </div>
        
        <!-- 奖励 -->
        <div class="achievement-reward">
          <span class="reward-item">💰 {{ achievement.rewardPoints }}</span>
          <span class="reward-item">✨ {{ achievement.rewardExp }}</span>
        </div>
        
        <!-- 稀有度标签 -->
        <div class="rarity-tag">{{ getRarityName(achievement.rarity) }}</div>
      </div>
      
      <!-- 空状态 -->
      <div class="empty-state" v-if="!loading && filteredAchievements.length === 0">
        <div class="empty-icon">🔍</div>
        <div class="empty-text">暂无成就</div>
      </div>
    </div>

    <!-- 成就详情弹窗 -->
    <el-dialog 
      v-model="detailDialogVisible" 
      :title="null"
      width="480px"
      class="achievement-detail-dialog"
      :show-close="false"
    >
      <div class="detail-content" v-if="selectedAchievement">
        <div class="detail-header" :class="selectedAchievement.rarity.toLowerCase()">
          <div class="detail-badge" :style="{ backgroundColor: selectedAchievement.badgeColor || getRarityColor(selectedAchievement.rarity) }">
            <img 
              :src="getAchievementIcon(selectedAchievement.icon, selectedAchievement.rarity)" 
              :alt="selectedAchievement.name"
              class="badge-icon"
            />
          </div>
          <div class="detail-title">
            <h3>{{ selectedAchievement.name }}</h3>
            <span class="detail-rarity">{{ getRarityName(selectedAchievement.rarity) }}</span>
          </div>
          <button class="close-btn" @click="detailDialogVisible = false">×</button>
        </div>
        
        <div class="detail-body">
          <p class="detail-desc">{{ selectedAchievement.description }}</p>
          
          <div class="detail-condition">
            <div class="condition-label">达成条件</div>
            <div class="condition-value">
              {{ getConditionText(selectedAchievement) }}
            </div>
          </div>
          
          <div class="detail-progress" v-if="selectedAchievement.userProgress">
            <div class="progress-label">当前进度</div>
            <div class="progress-bar-large">
              <div 
                class="progress-fill" 
                :style="{ width: getProgressPercent(selectedAchievement) + '%' }"
              ></div>
            </div>
            <div class="progress-numbers">
              {{ selectedAchievement.userProgress.progress }} / {{ selectedAchievement.conditionValue }}
              ({{ getProgressPercent(selectedAchievement) }}%)
            </div>
          </div>
          
          <div class="detail-rewards">
            <div class="reward-label">完成奖励</div>
            <div class="reward-items">
              <div class="reward-box">
                <span class="reward-icon">💰</span>
                <span class="reward-value">{{ selectedAchievement.rewardPoints }}</span>
                <span class="reward-name">积分</span>
              </div>
              <div class="reward-box">
                <span class="reward-icon">✨</span>
                <span class="reward-value">{{ selectedAchievement.rewardExp }}</span>
                <span class="reward-name">经验</span>
              </div>
            </div>
          </div>
        </div>
        
        <div class="detail-footer">
          <el-button 
            v-if="selectedAchievement.userProgress?.isCompleted === 1 && selectedAchievement.userProgress?.isClaimed === 0"
            type="primary"
            size="large"
            :loading="claiming"
            @click="handleClaimReward(selectedAchievement.id)"
          >
            🎁 领取奖励
          </el-button>
          <el-button v-else-if="selectedAchievement.userProgress?.isClaimed === 1" type="info" size="large" disabled>
            ✓ 已领取
          </el-button>
          <el-button v-else type="default" size="large" @click="detailDialogVisible = false">
            继续努力
          </el-button>
        </div>
      </div>
    </el-dialog>

    <!-- 待领取奖励弹窗 -->
    <el-dialog 
      v-model="unclaimedDialogVisible" 
      title="🎁 待领取奖励"
      width="500px"
    >
      <div class="unclaimed-list">
        <div 
          v-for="ua in unclaimedList" 
          :key="ua.id"
          class="unclaimed-item"
        >
          <div class="unclaimed-badge" :style="{ backgroundColor: ua.achievement?.badgeColor }">
            <img 
              v-if="ua.achievement"
              :src="getAchievementIcon(ua.achievement.icon, ua.achievement.rarity)" 
              :alt="ua.achievement.name"
              class="badge-icon"
            />
          </div>
          <div class="unclaimed-info">
            <div class="unclaimed-name">{{ ua.achievement?.name }}</div>
            <div class="unclaimed-reward">
              💰 {{ ua.achievement?.rewardPoints }} 积分 | ✨ {{ ua.achievement?.rewardExp }} 经验
            </div>
          </div>
          <el-button 
            type="primary" 
            size="small"
            :loading="claimingId === ua.achievementId"
            @click="handleClaimReward(ua.achievementId)"
          >
            领取
          </el-button>
        </div>
        
        <div class="empty-unclaimed" v-if="unclaimedList.length === 0">
          暂无待领取的奖励
        </div>
      </div>
      
      <template #footer>
        <el-button @click="unclaimedDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="claimAllRewards" :disabled="unclaimedList.length === 0">
          一键领取全部
        </el-button>
      </template>
    </el-dialog>

    <!-- 领取成功动画 -->
    <transition name="reward-popup">
      <div class="reward-popup" v-if="showRewardPopup">
        <div class="popup-content">
          <div class="popup-icon">🎉</div>
          <div class="popup-title">恭喜获得奖励！</div>
          <div class="popup-rewards">
            <span>💰 +{{ claimResult.points }} 积分</span>
            <span>✨ +{{ claimResult.exp }} 经验</span>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  getAllAchievements, 
  getAchievementStats, 
  getUnclaimedAchievements,
  claimReward,
  initMyAchievements,
  getRarityName,
  getRarityColor,
  type Achievement,
  type UserAchievement,
  type AchievementStats
} from '@/api/achievement'
import { getAchievementIcon } from '@/utils/achievementIcons'

// 分类定义
const categories = [
  { value: '', label: '全部', icon: '🏆' },
  { value: 'STUDY', label: '学习', icon: '📚' },
  { value: 'CHECK_IN', label: '打卡', icon: '✅' },
  { value: 'SOCIAL', label: '社交', icon: '👥' },
  { value: 'SPECIAL', label: '特殊', icon: '⭐' }
]

// 状态
const loading = ref(false)
const achievements = ref<Achievement[]>([])
const stats = ref<AchievementStats>({
  totalCount: 0,
  completedCount: 0,
  unclaimedCount: 0,
  completionRate: 0,
  rarityStats: { COMMON: 0, RARE: 0, EPIC: 0, LEGENDARY: 0 }
})
const activeCategory = ref('')
const activeRarity = ref('')

// 弹窗状态
const detailDialogVisible = ref(false)
const selectedAchievement = ref<Achievement | null>(null)
const unclaimedDialogVisible = ref(false)
const unclaimedList = ref<UserAchievement[]>([])

// 领取状态
const claiming = ref(false)
const claimingId = ref<number | null>(null)
const showRewardPopup = ref(false)
const claimResult = ref({ points: 0, exp: 0 })

// 筛选后的成就列表
const filteredAchievements = computed(() => {
  return achievements.value.filter(a => {
    if (activeCategory.value && a.category !== activeCategory.value) return false
    if (activeRarity.value && a.rarity !== activeRarity.value) return false
    return true
  })
})

// 获取进度百分比
const getProgressPercent = (achievement: Achievement) => {
  if (!achievement.userProgress) return 0
  const progress = achievement.userProgress.progress
  const target = achievement.conditionValue
  if (target <= 0) return 0
  return Math.min(Math.round((progress / target) * 100), 100)
}

// 获取条件描述文本
const getConditionText = (achievement: Achievement) => {
  const typeNames: Record<string, string> = {
    TOTAL_RESERVATIONS: '累计完成预约',
    TOTAL_HOURS: '累计学习时长',
    TOTAL_CHECK_INS: '累计打卡',
    CONTINUOUS_CHECK_INS: '连续打卡',
    TOTAL_FRIENDS: '拥有好友',
    CREATE_GROUP: '创建学习小组',
    EARLY_SIGN_IN: '早起签到(8点前)',
    LATE_SIGN_OUT: '晚间签退(22点后)',
    NO_VIOLATION_STREAK: '连续无违约',
    WEEKEND_STUDY: '周末学习',
    GOALS_COMPLETED: '完成学习目标',
    TOTAL_REVIEWS: '发表座位评价'
  }
  const typeName = typeNames[achievement.conditionType] || achievement.conditionType
  const unit = achievement.conditionType === 'TOTAL_HOURS' ? '小时' : '次'
  return `${typeName} ${achievement.conditionValue} ${unit}`
}

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const [achievementsRes, statsRes] = await Promise.all([
      getAllAchievements(),
      getAchievementStats()
    ])
    achievements.value = achievementsRes.list
    stats.value = statsRes
  } catch (error) {
    console.error('加载成就数据失败', error)
  } finally {
    loading.value = false
  }
}

// 显示成就详情
const showAchievementDetail = (achievement: Achievement) => {
  selectedAchievement.value = achievement
  detailDialogVisible.value = true
}

// 显示待领取弹窗
const showUnclaimedDialog = async () => {
  try {
    unclaimedList.value = await getUnclaimedAchievements()
    unclaimedDialogVisible.value = true
  } catch (error) {
    console.error('加载待领取奖励失败', error)
  }
}

// 领取奖励
const handleClaimReward = async (achievementId: number) => {
  claiming.value = true
  claimingId.value = achievementId
  try {
    const result = await claimReward(achievementId)
    claimResult.value = { points: result.points, exp: result.exp }
    
    // 显示奖励动画
    showRewardPopup.value = true
    setTimeout(() => {
      showRewardPopup.value = false
    }, 2000)
    
    // 刷新数据
    await loadData()
    
    // 更新待领取列表
    unclaimedList.value = unclaimedList.value.filter(ua => ua.achievementId !== achievementId)
    
    // 关闭详情弹窗
    detailDialogVisible.value = false
    
    ElMessage.success(`成功领取奖励: ${result.points}积分, ${result.exp}经验`)
  } catch (error: any) {
    ElMessage.error(error.message || '领取失败')
  } finally {
    claiming.value = false
    claimingId.value = null
  }
}

// 一键领取全部
const claimAllRewards = async () => {
  for (const ua of unclaimedList.value) {
    await handleClaimReward(ua.achievementId)
  }
}

// 初始化成就进度
const initProgress = async () => {
  try {
    await initMyAchievements()
    await loadData()
  } catch (error) {
    console.error('初始化成就进度失败', error)
  }
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.achievements-page {
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
}

.page-header {
  text-align: center;
  margin-bottom: 32px;
  
  h1 {
    font-size: 32px;
    font-weight: 700;
    color: #fff;
    margin-bottom: 8px;
  }
  
  p {
    color: rgba(255, 255, 255, 0.6);
    font-size: 14px;
  }
}

.stats-section {
  display: flex;
  gap: 20px;
  margin-bottom: 32px;
  flex-wrap: wrap;
}

.stat-card {
  background: rgba(255, 255, 255, 0.08);
  border-radius: 16px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  position: relative;
  overflow: hidden;
  
  &.total {
    flex: 1;
    min-width: 280px;
  }
  
  &.unclaimed {
    cursor: pointer;
    background: linear-gradient(135deg, rgba(255, 193, 7, 0.2) 0%, rgba(255, 152, 0, 0.2) 100%);
    border-color: rgba(255, 193, 7, 0.3);
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(255, 193, 7, 0.2);
    }
  }
}

.stat-icon {
  font-size: 36px;
  
  &.pulse {
    animation: pulse 1.5s ease-in-out infinite;
  }
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.stat-info {
  .stat-value {
    font-size: 28px;
    font-weight: 700;
    color: #fff;
  }
  
  .stat-label {
    color: rgba(255, 255, 255, 0.6);
    font-size: 13px;
  }
}

.stat-progress {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: rgba(255, 255, 255, 0.1);
  
  .progress-bar {
    height: 100%;
    background: linear-gradient(90deg, #00d2ff, #3a7bd5);
    transition: width 0.5s ease;
  }
}

.claim-hint {
  position: absolute;
  right: 16px;
  font-size: 12px;
  color: #ffc107;
}

.rarity-stats {
  display: flex;
  gap: 20px;
  align-items: center;
  background: rgba(255, 255, 255, 0.05);
  padding: 16px 24px;
  border-radius: 12px;
}

.rarity-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.8);
  
  .rarity-dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
  }
  
  &.common .rarity-dot { background: #9E9E9E; }
  &.rare .rarity-dot { background: #2196F3; }
  &.epic .rarity-dot { background: #9C27B0; }
  &.legendary .rarity-dot { background: linear-gradient(135deg, #FFD700, #FF8C00); }
}

.category-tabs {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.tab-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border: none;
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.08);
  color: rgba(255, 255, 255, 0.7);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  
  &:hover {
    background: rgba(255, 255, 255, 0.12);
  }
  
  &.active {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
  }
  
  .tab-icon {
    font-size: 16px;
  }
}

.filter-bar {
  margin-bottom: 24px;
  
  :deep(.el-radio-group) {
    .el-radio-button__inner {
      background: rgba(255, 255, 255, 0.08);
      border-color: rgba(255, 255, 255, 0.1);
      color: rgba(255, 255, 255, 0.7);
    }
    
    .el-radio-button__original-radio:checked + .el-radio-button__inner {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border-color: #667eea;
    }
  }
}

.achievements-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

.achievement-card {
  background: rgba(255, 255, 255, 0.06);
  border-radius: 16px;
  padding: 20px;
  position: relative;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid rgba(255, 255, 255, 0.08);
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.3);
  }
  
  &.unlocked {
    border-color: rgba(76, 175, 80, 0.3);
  }
  
  &.claimable {
    border-color: rgba(255, 193, 7, 0.5);
    animation: glow 2s ease-in-out infinite;
  }
  
  // 稀有度效果
  &.legendary {
    .rarity-glow {
      background: radial-gradient(ellipse at center, rgba(255, 215, 0, 0.15) 0%, transparent 70%);
    }
  }
  
  &.epic {
    .rarity-glow {
      background: radial-gradient(ellipse at center, rgba(156, 39, 176, 0.15) 0%, transparent 70%);
    }
  }
  
  &.rare {
    .rarity-glow {
      background: radial-gradient(ellipse at center, rgba(33, 150, 243, 0.1) 0%, transparent 70%);
    }
  }
}

@keyframes glow {
  0%, 100% { box-shadow: 0 0 8px rgba(255, 193, 7, 0.3); }
  50% { box-shadow: 0 0 16px rgba(255, 193, 7, 0.5); }
}

.rarity-glow {
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  pointer-events: none;
}

.badge-wrapper {
  position: relative;
  display: inline-block;
  margin-bottom: 12px;
}

.achievement-badge {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  overflow: hidden;
  
  .badge-icon {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  
  .unlocked & {
    box-shadow: 0 4px 16px rgba(76, 175, 80, 0.4);
  }
}

.unlock-check {
  position: absolute;
  bottom: -4px;
  right: -4px;
  width: 24px;
  height: 24px;
  background: #4CAF50;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 14px;
  font-weight: bold;
  border: 2px solid #1a1a2e;
}

.claimable-dot {
  position: absolute;
  top: 0;
  right: 0;
  width: 12px;
  height: 12px;
  background: #ffc107;
  border-radius: 50%;
  animation: blink 1s ease-in-out infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.achievement-info {
  margin-bottom: 12px;
}

.achievement-name {
  font-size: 16px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 4px;
}

.achievement-desc {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.5);
  line-height: 1.4;
}

.achievement-progress {
  margin-bottom: 12px;
  
  .progress-bar {
    height: 6px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 3px;
    overflow: hidden;
    margin-bottom: 4px;
    
    .progress-fill {
      height: 100%;
      background: linear-gradient(90deg, #00d2ff, #3a7bd5);
      transition: width 0.3s ease;
    }
  }
  
  .progress-text {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
  }
}

.achievement-reward {
  display: flex;
  gap: 16px;
  
  .reward-item {
    font-size: 13px;
    color: rgba(255, 255, 255, 0.7);
  }
}

.rarity-tag {
  position: absolute;
  top: 12px;
  right: 12px;
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.6);
  
  .legendary & {
    background: linear-gradient(135deg, rgba(255, 215, 0, 0.3), rgba(255, 140, 0, 0.3));
    color: #FFD700;
  }
  
  .epic & {
    background: rgba(156, 39, 176, 0.2);
    color: #CE93D8;
  }
  
  .rare & {
    background: rgba(33, 150, 243, 0.2);
    color: #90CAF9;
  }
}

.empty-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 60px;
  
  .empty-icon {
    font-size: 48px;
    margin-bottom: 16px;
  }
  
  .empty-text {
    color: rgba(255, 255, 255, 0.5);
  }
}

// 详情弹窗样式
:deep(.achievement-detail-dialog) {
  .el-dialog {
    background: #1e1e2d;
    border-radius: 20px;
    overflow: hidden;
  }
  
  .el-dialog__header {
    display: none;
  }
  
  .el-dialog__body {
    padding: 0;
  }
}

.detail-content {
  color: #fff;
}

.detail-header {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 24px;
  position: relative;
  
  &.legendary { background: linear-gradient(135deg, rgba(255, 215, 0, 0.2), rgba(255, 140, 0, 0.1)); }
  &.epic { background: linear-gradient(135deg, rgba(156, 39, 176, 0.2), rgba(103, 58, 183, 0.1)); }
  &.rare { background: linear-gradient(135deg, rgba(33, 150, 243, 0.2), rgba(21, 101, 192, 0.1)); }
  &.common { background: rgba(255, 255, 255, 0.05); }
}

.detail-badge {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 36px;
  overflow: hidden;
  
  .badge-icon {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.detail-title {
  flex: 1;
  
  h3 {
    font-size: 22px;
    font-weight: 600;
    margin-bottom: 4px;
  }
  
  .detail-rarity {
    font-size: 13px;
    color: rgba(255, 255, 255, 0.6);
  }
}

.close-btn {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.7);
  font-size: 20px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  
  &:hover {
    background: rgba(255, 255, 255, 0.2);
  }
}

.detail-body {
  padding: 24px;
}

.detail-desc {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.7);
  line-height: 1.6;
  margin-bottom: 24px;
}

.detail-condition,
.detail-progress,
.detail-rewards {
  margin-bottom: 20px;
}

.condition-label,
.progress-label,
.reward-label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.condition-value {
  font-size: 15px;
  color: #fff;
}

.progress-bar-large {
  height: 8px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 8px;
  
  .progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #00d2ff, #3a7bd5);
    transition: width 0.3s ease;
  }
}

.progress-numbers {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
}

.reward-items {
  display: flex;
  gap: 16px;
}

.reward-box {
  flex: 1;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 16px;
  text-align: center;
  
  .reward-icon {
    font-size: 24px;
    display: block;
    margin-bottom: 8px;
  }
  
  .reward-value {
    font-size: 24px;
    font-weight: 700;
    color: #fff;
    display: block;
  }
  
  .reward-name {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
  }
}

.detail-footer {
  padding: 16px 24px 24px;
  display: flex;
  justify-content: center;
  
  .el-button {
    width: 200px;
    height: 44px;
    font-size: 15px;
  }
}

// 待领取弹窗
:deep(.el-dialog) {
  background: #1e1e2d;
  
  .el-dialog__header {
    color: #fff;
  }
  
  .el-dialog__body {
    color: #fff;
  }
}

.unclaimed-list {
  max-height: 400px;
  overflow-y: auto;
}

.unclaimed-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  margin-bottom: 12px;
  
  &:last-child {
    margin-bottom: 0;
  }
}

.unclaimed-badge {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  overflow: hidden;
  
  .badge-icon {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.unclaimed-info {
  flex: 1;
  
  .unclaimed-name {
    font-weight: 600;
    margin-bottom: 4px;
  }
  
  .unclaimed-reward {
    font-size: 13px;
    color: rgba(255, 255, 255, 0.6);
  }
}

.empty-unclaimed {
  text-align: center;
  padding: 40px;
  color: rgba(255, 255, 255, 0.5);
}

// 奖励弹出动画
.reward-popup {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.popup-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 60px;
  border-radius: 20px;
  text-align: center;
  animation: popIn 0.3s ease;
}

@keyframes popIn {
  0% { transform: scale(0.5); opacity: 0; }
  100% { transform: scale(1); opacity: 1; }
}

.popup-icon {
  font-size: 64px;
  margin-bottom: 16px;
}

.popup-title {
  font-size: 24px;
  font-weight: 700;
  color: #fff;
  margin-bottom: 16px;
}

.popup-rewards {
  display: flex;
  gap: 24px;
  justify-content: center;
  
  span {
    font-size: 18px;
    color: rgba(255, 255, 255, 0.9);
  }
}

.reward-popup-enter-active,
.reward-popup-leave-active {
  transition: opacity 0.3s ease;
}

.reward-popup-enter-from,
.reward-popup-leave-to {
  opacity: 0;
}
</style>
