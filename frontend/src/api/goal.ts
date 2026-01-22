import { request } from '@/utils/request'

// ==================== 类型定义 ====================

export interface StudyGoal {
  id: number
  userId: number
  name: string
  type: string
  targetValue: number
  currentValue: number
  unit: string
  startDate: string
  endDate: string
  status: string
  completedTime: string
  rewardPoints: number
  rewardExp: number
  rewardClaimed: number
  description: string
  createdAt: string
  updatedAt: string
  // 计算字段
  progressPercent?: number
  remainingDays?: number
}

export interface CreateGoalParams {
  name: string
  type: string
  targetValue: number
  unit?: string
  startDate?: string
  endDate?: string
  description?: string
  rewardPoints?: number
  rewardExp?: number
}

export interface GoalStats {
  totalGoals: number
  completedGoals: number
  activeGoals: number
  completionRate: number
}

export interface PageResult<T> {
  records: T[]
  total: number
  current: number
  size: number
  pages: number
}

// 目标类型选项
export const GOAL_TYPES = [
  { value: 'DAILY_HOURS', label: '每日学习时长', unit: 'HOUR', unitLabel: '小时' },
  { value: 'WEEKLY_HOURS', label: '每周学习时长', unit: 'HOUR', unitLabel: '小时' },
  { value: 'MONTHLY_HOURS', label: '每月学习时长', unit: 'HOUR', unitLabel: '小时' },
  { value: 'TOTAL_HOURS', label: '累计学习时长', unit: 'HOUR', unitLabel: '小时' },
  { value: 'DAILY_CHECKIN', label: '连续打卡天数', unit: 'DAY', unitLabel: '天' },
  { value: 'RESERVATION_COUNT', label: '预约次数', unit: 'COUNT', unitLabel: '次' }
]

// 状态选项
export const GOAL_STATUSES = [
  { value: 'ACTIVE', label: '进行中', type: 'primary' },
  { value: 'COMPLETED', label: '已完成', type: 'success' },
  { value: 'FAILED', label: '未完成', type: 'danger' },
  { value: 'CANCELLED', label: '已取消', type: 'info' }
]

// ==================== API接口 ====================

/**
 * 创建学习目标
 */
export function createGoal(data: CreateGoalParams): Promise<StudyGoal> {
  return request.post('/goals', data)
}

/**
 * 获取目标列表
 */
export function getGoals(params: {
  pageNum?: number
  pageSize?: number
  status?: string
  type?: string
}): Promise<PageResult<StudyGoal>> {
  return request.get('/goals', { params })
}

/**
 * 获取进行中的目标
 */
export function getActiveGoals(): Promise<StudyGoal[]> {
  return request.get('/goals/active')
}

/**
 * 获取目标详情
 */
export function getGoalDetail(id: number): Promise<StudyGoal> {
  return request.get(`/goals/${id}`)
}

/**
 * 领取目标奖励
 */
export function claimGoalReward(id: number): Promise<{ points: number; exp: number }> {
  return request.post(`/goals/${id}/claim`)
}

/**
 * 取消目标
 */
export function cancelGoal(id: number): Promise<void> {
  return request.post(`/goals/${id}/cancel`)
}

/**
 * 获取目标统计
 */
export function getGoalStats(): Promise<GoalStats> {
  return request.get('/goals/stats')
}

// ==================== 工具函数 ====================

/**
 * 获取目标类型标签
 */
export function getGoalTypeLabel(type: string): string {
  const found = GOAL_TYPES.find(t => t.value === type)
  return found?.label || type
}

/**
 * 获取单位标签
 */
export function getUnitLabel(type: string): string {
  const found = GOAL_TYPES.find(t => t.value === type)
  return found?.unitLabel || ''
}

/**
 * 获取状态配置
 */
export function getStatusConfig(status: string) {
  return GOAL_STATUSES.find(s => s.value === status) || { value: status, label: status, type: 'info' }
}
