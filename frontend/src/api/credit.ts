import { request } from '@/utils/request'

// ==================== 类型定义 ====================

export interface CreditRecord {
  id: number
  userId: number
  changeScore: number
  beforeScore: number
  afterScore: number
  type: string
  sourceType: string
  sourceId: number
  description: string
  createdAt: string
}

export interface ViolationRecord {
  id: number
  userId: number
  reservationId: number
  type: string
  description: string
  deductScore: number
  beforeScore: number
  afterScore: number
  appealStatus: number
  appealReason: string
  appealTime: string
  appealResult: string
  processedBy: number
  processedTime: string
  createdAt: string
  // 关联信息
  user?: {
    username: string
    studentNo: string
  }
}

export interface Blacklist {
  id: number
  userId: number
  reason: string
  creditScoreWhenAdded: number
  startTime: string
  endTime: string
  released: number
  releaseTime: string
  releaseReason: string
  createdBy: number
  createdAt: string
  // 关联信息
  user?: {
    username: string
    studentNo: string
  }
}

export interface CreditStats {
  currentScore: number
  totalGain: number
  totalLoss: number
  violationCount: number
  isBlacklisted: boolean
  blacklistEndTime?: string
}

export interface PageResult<T> {
  records: T[]
  total: number
  current: number
  size: number
  pages: number
}

// ==================== 用户端接口 ====================

/**
 * 获取信用统计
 */
export function getCreditStats(): Promise<CreditStats> {
  return request.get('/credit/stats')
}

/**
 * 获取积分记录
 */
export function getCreditRecords(params: {
  pageNum?: number
  pageSize?: number
  type?: string
}): Promise<PageResult<CreditRecord>> {
  return request.get('/credit/records', { params })
}

/**
 * 获取违约记录
 */
export function getViolations(params: {
  pageNum?: number
  pageSize?: number
  type?: string
}): Promise<PageResult<ViolationRecord>> {
  return request.get('/credit/violations', { params })
}

/**
 * 提交申诉
 */
export function submitAppeal(id: number, reason: string): Promise<void> {
  return request.post(`/credit/violations/${id}/appeal`, { reason })
}

// ==================== 管理端接口 ====================

/**
 * 查询违约记录列表(管理端)
 */
export function getAdminViolations(params: {
  pageNum?: number
  pageSize?: number
  userId?: number
  type?: string
  appealStatus?: number
}): Promise<PageResult<ViolationRecord>> {
  return request.get('/manage/credit/violations', { params })
}

/**
 * 处理申诉
 */
export function processAppeal(id: number, approved: boolean, result: string): Promise<void> {
  return request.post(`/manage/credit/violations/${id}/process-appeal`, { approved, result })
}

/**
 * 查询黑名单列表
 */
export function getBlacklist(params: {
  pageNum?: number
  pageSize?: number
  released?: number
  keyword?: string
}): Promise<PageResult<Blacklist>> {
  return request.get('/manage/credit/blacklist', { params })
}

/**
 * 添加到黑名单
 */
export function addToBlacklist(data: {
  userId: number
  reason: string
  durationDays?: number
}): Promise<void> {
  return request.post('/manage/credit/blacklist', data)
}

/**
 * 解除黑名单
 */
export function releaseFromBlacklist(userId: number, reason?: string): Promise<void> {
  return request.delete(`/manage/credit/blacklist/${userId}`, { params: { reason } })
}

/**
 * 检查用户是否在黑名单
 */
export function checkBlacklist(userId: number): Promise<{
  isBlacklisted: boolean
  blacklist?: Blacklist
}> {
  return request.get(`/manage/credit/blacklist/check/${userId}`)
}

/**
 * 调整用户积分
 */
export function adjustCreditScore(data: {
  userId: number
  newScore: number
  reason?: string
}): Promise<void> {
  return request.post('/manage/credit/adjust', data)
}

/**
 * 获取用户信用统计(管理端)
 */
export function getAdminUserCreditStats(userId: number): Promise<CreditStats> {
  return request.get(`/manage/credit/stats/${userId}`)
}
