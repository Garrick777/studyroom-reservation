import { request } from '@/utils/request'

// ==================== 统计数据 ====================

/**
 * 获取超管统计数据
 */
export function getSuperAdminStats() {
  return request.get('/super-admin/stats')
}

/**
 * 获取图表数据
 */
export interface ChartData {
  userGrowth: { date: string; count: number }[]
  reservationTrend: { date: string; count: number }[]
  roomUsage: { name: string; usage: number }[]
  categoryDistribution: { name: string; value: number }[]
}

export function getChartData() {
  return request.get<ChartData>('/super-admin/chart-data')
}

// ==================== 用户管理 ====================

export interface UserVO {
  id: number
  username: string
  studentId: string
  realName: string
  email: string
  phone: string
  avatar: string
  role: string
  gender: number
  college: string
  major: string
  grade: string
  classNo: string
  creditScore: number
  totalStudyTime: number
  totalPoints: number
  consecutiveDays: number
  totalCheckIns: number
  exp: number
  currentStreak: number
  maxStreak: number
  status: number
  createTime: string
  updateTime: string
}

export interface UserQueryParams {
  pageNum?: number
  pageSize?: number
  keyword?: string
  status?: number
  college?: string
}

/**
 * 获取学生用户列表
 */
export function getUserList(params: UserQueryParams) {
  return request.get<{ records: UserVO[], total: number }>('/super-admin/users', { params })
}

/**
 * 获取用户详情
 */
export function getUserDetail(id: number) {
  return request.get<UserVO>(`/super-admin/users/${id}`)
}

/**
 * 更新用户信息
 */
export function updateUser(id: number, data: Partial<UserVO>) {
  return request.put(`/super-admin/users/${id}`, data)
}

/**
 * 切换用户状态
 */
export function toggleUserStatus(id: number, status: number) {
  return request.put(`/super-admin/users/${id}/status`, null, { params: { status } })
}

/**
 * 重置用户密码
 */
export function resetUserPassword(id: number) {
  return request.post<string>(`/super-admin/users/${id}/reset-password`)
}

/**
 * 获取学院列表
 */
export function getCollegeList() {
  return request.get<string[]>('/super-admin/users/colleges')
}

// ==================== 管理员管理 ====================

export interface AdminQueryParams {
  pageNum?: number
  pageSize?: number
  keyword?: string
}

/**
 * 获取管理员列表
 */
export function getAdminList(params: AdminQueryParams) {
  return request.get<{ records: UserVO[], total: number }>('/super-admin/admins', { params })
}

/**
 * 创建管理员
 */
export function createAdmin(data: {
  username: string
  password: string
  realName: string
  phone?: string
  email?: string
}) {
  return request.post<number>('/super-admin/admins', data)
}

/**
 * 更新管理员
 */
export function updateAdmin(id: number, data: {
  realName?: string
  phone?: string
  email?: string
}) {
  return request.put(`/super-admin/admins/${id}`, data)
}

/**
 * 删除管理员
 */
export function deleteAdmin(id: number) {
  return request.delete(`/super-admin/admins/${id}`)
}

/**
 * 重置管理员密码
 */
export function resetAdminPassword(id: number) {
  return request.post<string>(`/super-admin/admins/${id}/reset-password`)
}

/**
 * 切换管理员状态
 */
export function toggleAdminStatus(id: number, status: number) {
  return request.put(`/super-admin/admins/${id}/status`, null, { params: { status } })
}

// ==================== 系统设置 ====================

export interface SystemSettings {
  reservation: {
    maxDailyReservations: number
    advanceBookingDays: number
    signInAdvanceMinutes: number
    signInTimeoutMinutes: number
    leaveTimeoutMinutes: number
    maxLeaveCount: number
    freeCancelMinutes: number
  }
  points: {
    pointsPerHour: number
    checkInBonus: number
    achievementBonus: number
    referralBonus: number
  }
  credit: {
    initialScore: number
    maxScore: number
    minScoreForBooking: number
    noShowPenalty: number
    leaveTimeoutPenalty: number
    earlyLeavePenalty: number
    monthlyRecovery: number
  }
  system: {
    siteName: string
    siteDescription: string
    maintenanceMode: boolean
    registrationEnabled: boolean
  }
}

/**
 * 获取系统配置
 */
export function getSystemSettings() {
  return request.get<SystemSettings>('/super-admin/settings')
}

/**
 * 更新系统配置
 */
export function updateSystemSettings(data: Partial<SystemSettings>) {
  return request.put('/super-admin/settings', data)
}
