import request from '@/utils/request'

// ========== 类型定义 ==========

export interface Achievement {
  id: number
  name: string
  description: string
  icon: string
  badgeColor: string
  category: string
  conditionType: string
  conditionValue: number
  rewardPoints: number
  rewardExp: number
  rarity: string
  isHidden: number
  sortOrder: number
  status: number
  createdAt: string
  userProgress?: UserAchievement
}

export interface UserAchievement {
  id: number
  userId: number
  achievementId: number
  progress: number
  isCompleted: number
  completedAt: string | null
  isClaimed: number
  claimedAt: string | null
  createdAt: string
  updatedAt: string
  achievement?: Achievement
}

export interface AchievementStats {
  totalCount: number
  completedCount: number
  unclaimedCount: number
  completionRate: number
  rarityStats: {
    COMMON: number
    RARE: number
    EPIC: number
    LEGENDARY: number
  }
}

export interface ClaimRewardResult {
  achievementName: string
  points: number
  exp: number
  totalPoints: number
  totalExp: number
}

// ========== 学生端API ==========

/**
 * 获取所有成就列表
 */
export function getAllAchievements(params?: { category?: string; rarity?: string }) {
  return request.get<{
    list: Achievement[]
    total: number
    grouped: Record<string, Achievement[]>
  }>('/achievements', { params })
}

/**
 * 获取成就统计
 */
export function getAchievementStats() {
  return request.get<AchievementStats>('/achievements/stats')
}

/**
 * 获取我的成就列表
 */
export function getMyAchievements() {
  return request.get<{
    achievements: UserAchievement[]
    completed: UserAchievement[]
    inProgress: UserAchievement[]
    unclaimed: UserAchievement[]
    stats: AchievementStats
  }>('/achievements/my')
}

/**
 * 获取待领取奖励的成就
 */
export function getUnclaimedAchievements() {
  return request.get<UserAchievement[]>('/achievements/unclaimed')
}

/**
 * 领取成就奖励
 */
export function claimReward(achievementId: number) {
  return request.post<ClaimRewardResult>(`/achievements/${achievementId}/claim`)
}

/**
 * 初始化我的成就进度
 */
export function initMyAchievements() {
  return request.post('/achievements/init')
}

/**
 * 获取成就详情
 */
export function getAchievementDetail(id: number) {
  return request.get<Achievement>(`/achievements/${id}`)
}

// ========== 管理端API ==========

/**
 * 获取成就列表（管理端分页）
 */
export function getAdminAchievements(params: {
  page?: number
  size?: number
  category?: string
  rarity?: string
  keyword?: string
}) {
  return request.get<{
    list: Achievement[]
    total: number
    pages: number
    current: number
  }>('/manage/achievements', { params })
}

/**
 * 获取成就详情（管理端）
 */
export function getAdminAchievementDetail(id: number) {
  return request.get<Achievement>(`/manage/achievements/${id}`)
}

/**
 * 创建成就
 */
export function createAchievement(data: Partial<Achievement>) {
  return request.post<Achievement>('/manage/achievements', data)
}

/**
 * 更新成就
 */
export function updateAchievement(id: number, data: Partial<Achievement>) {
  return request.put<Achievement>(`/manage/achievements/${id}`, data)
}

/**
 * 删除成就
 */
export function deleteAchievement(id: number) {
  return request.delete(`/manage/achievements/${id}`)
}

/**
 * 切换成就状态
 */
export function toggleAchievementStatus(id: number) {
  return request.post(`/manage/achievements/${id}/toggle`)
}

/**
 * 获取成就分类列表
 */
export function getCategories() {
  return request.get<Record<string, string>>('/manage/achievements/categories')
}

/**
 * 获取成就稀有度列表
 */
export function getRarities() {
  return request.get<Record<string, string>>('/manage/achievements/rarities')
}

/**
 * 获取条件类型列表
 */
export function getConditionTypes() {
  return request.get<Record<string, string>>('/manage/achievements/condition-types')
}

// ========== 工具函数 ==========

/**
 * 获取分类中文名称
 */
export function getCategoryName(category: string): string {
  const names: Record<string, string> = {
    STUDY: '学习成就',
    CHECK_IN: '打卡成就',
    SOCIAL: '社交成就',
    SPECIAL: '特殊成就'
  }
  return names[category] || '未知分类'
}

/**
 * 获取稀有度中文名称
 */
export function getRarityName(rarity: string): string {
  const names: Record<string, string> = {
    COMMON: '普通',
    RARE: '稀有',
    EPIC: '史诗',
    LEGENDARY: '传说'
  }
  return names[rarity] || '未知'
}

/**
 * 获取稀有度颜色
 */
export function getRarityColor(rarity: string): string {
  const colors: Record<string, string> = {
    COMMON: '#9E9E9E',
    RARE: '#2196F3',
    EPIC: '#9C27B0',
    LEGENDARY: '#FFD700'
  }
  return colors[rarity] || '#9E9E9E'
}

/**
 * 获取稀有度渐变背景
 */
export function getRarityGradient(rarity: string): string {
  const gradients: Record<string, string> = {
    COMMON: 'linear-gradient(135deg, #9E9E9E 0%, #757575 100%)',
    RARE: 'linear-gradient(135deg, #2196F3 0%, #1565C0 100%)',
    EPIC: 'linear-gradient(135deg, #9C27B0 0%, #6A1B9A 100%)',
    LEGENDARY: 'linear-gradient(135deg, #FFD700 0%, #FF8C00 100%)'
  }
  return gradients[rarity] || gradients.COMMON
}

/**
 * 获取分类图标
 */
export function getCategoryIcon(category: string): string {
  const icons: Record<string, string> = {
    STUDY: '📚',
    CHECK_IN: '✅',
    SOCIAL: '👥',
    SPECIAL: '⭐'
  }
  return icons[category] || '🏆'
}
