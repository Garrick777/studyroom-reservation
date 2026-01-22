import { request } from '@/utils/request'

// 仪表盘统计数据
export interface DashboardStats {
  creditScore: number
  totalPoints: number
  totalStudyTime: number
  totalStudyHours: number
  consecutiveDays: number
  totalCheckIns: number
  currentStreak: number
  maxStreak: number
  todayStudyTime: number
  todayStudyHours: number
  dailyGoalHours: number
  dailyGoalProgress: number
}

// 热门自习室
export interface HotRoom {
  id: number
  name: string
  code: string
  building: string
  floor: string
  capacity: number
  rating: number
  ratingCount: number
  openTime: string
  closeTime: string
  coverImage: string
  availableSeats: number
  totalSeats: number
}

// 排行榜项
export interface RankingItem {
  rank: number
  userId: number
  username: string
  realName: string
  avatar: string
  totalStudyTime: number
  totalStudyHours: number
  totalPoints: number
}

// 排行榜响应
export interface RankingResponse {
  list: RankingItem[]
  type: string
  myRank: number | string
}

// 成就项
export interface Achievement {
  id: number
  name: string
  description: string
  icon: string
  rarity: 'COMMON' | 'RARE' | 'EPIC' | 'LEGENDARY'
  unlocked: boolean
  unlockedAt?: string
}

// 成就响应
export interface AchievementResponse {
  list: Achievement[]
  total: number
  unlocked: number
}

// 获取仪表盘统计
export function getDashboardStats(): Promise<DashboardStats> {
  return request.get('/stats/dashboard')
}

// 获取热门自习室
export function getHotRooms(): Promise<HotRoom[]> {
  return request.get('/stats/hot-rooms')
}

// 获取排行榜
export function getRanking(type: string = 'today', limit: number = 10): Promise<RankingResponse> {
  return request.get('/stats/ranking', { params: { type, limit } })
}

// 获取用户成就
export function getAchievements(): Promise<AchievementResponse> {
  return request.get('/stats/achievements')
}

// 获取平台统计（超管用）
export function getPlatformStats(): Promise<any> {
  return request.get('/stats/platform')
}
