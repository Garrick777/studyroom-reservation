// ============================================
// 通用类型定义
// ============================================

// 分页结果
export interface PageResult<T> {
  records: T[]
  current: number
  size: number
  total: number
  pages: number
  hasNext: boolean
  hasPrevious: boolean
}

// 分页请求参数
export interface PageParams {
  pageNum?: number
  pageSize?: number
  [key: string]: any
}

// API响应
export interface ApiResponse<T = any> {
  code: number
  message: string
  data: T
  timestamp: number
}

// ============================================
// 用户相关
// ============================================

export interface User {
  id: number
  username: string
  studentId: string
  realName: string
  email: string
  phone: string
  avatar: string
  role: 'STUDENT' | 'ADMIN' | 'SUPER_ADMIN'
  creditScore: number
  totalStudyTime: number
  totalPoints: number
  consecutiveDays: number
  totalCheckIns: number
  status: number
  createTime: string
}

// ============================================
// 自习室相关
// ============================================

export interface Room {
  id: number
  name: string
  code: string
  building: string
  floor: string
  roomNumber: string
  capacity: number
  rowCount: number
  colCount: number
  description: string
  facilities: string[] | string
  coverImage: string
  images: string[]
  openTime: string
  closeTime: string
  advanceDays: number
  maxDuration: number
  minCreditScore: number
  needApprove: boolean
  allowTemp: boolean
  rating: number
  ratingCount: number
  todayReservations: number
  totalReservations: number
  managerId: number
  managerName: string
  status: number
  availableSeats?: number
  isFavorite?: boolean
  createTime: string
}

// 自习室查询
export interface RoomQuery {
  pageNum?: number
  pageSize?: number
  keyword?: string
  building?: string
  status?: number
}

// ============================================
// 座位相关
// ============================================

export type SeatStatus = 'AVAILABLE' | 'RESERVED' | 'IN_USE' | 'LEAVING' | 'UNAVAILABLE'

export interface Seat {
  id: number
  roomId: number
  seatNo: string
  rowNum: number
  colNum: number
  seatType: string  // NORMAL, WINDOW, POWER, VIP
  status: number    // 0不可用 1可用 2维修中
  remark: string
  currentStatus?: SeatStatus  // 实时状态
  roomName?: string
  createTime: string
}

// ============================================
// 时段相关
// ============================================

export interface TimeSlot {
  id: number
  name: string
  startTime: string
  endTime: string
  sortOrder: number
  status: number
}

// ============================================
// 预约相关
// ============================================

export type ReservationStatus = 
  | 'PENDING'      // 待签到
  | 'CHECKED_IN'   // 使用中
  | 'LEAVING'      // 暂离
  | 'COMPLETED'    // 已完成
  | 'CANCELLED'    // 已取消
  | 'NO_SHOW'      // 未签到
  | 'VIOLATED'     // 违规

export interface Reservation {
  id: number
  userId: number
  userName: string
  roomId: number
  roomName: string
  seatId: number
  seatNo: string
  reservationDate: string
  timeSlotId: number
  startTime: string
  endTime: string
  status: ReservationStatus
  checkInTime: string | null
  checkOutTime: string | null
  actualStudyTime: number
  leaveCount: number
  createTime: string
}

// ============================================
// 成就相关
// ============================================

export type AchievementRarity = 'COMMON' | 'RARE' | 'EPIC' | 'LEGENDARY'

export interface Achievement {
  id: number
  name: string
  description: string
  icon: string
  rarity: AchievementRarity
  conditionType: string
  conditionValue: number
  points: number
  unlocked?: boolean
  unlockedAt?: string
}

// ============================================
// 违规相关
// ============================================

export type ViolationType = 
  | 'NO_SHOW'         // 未签到
  | 'LATE_CANCEL'     // 迟到取消
  | 'OVERTIME_LEAVE'  // 暂离超时
  | 'OTHER'           // 其他

export interface Violation {
  id: number
  userId: number
  userName: string
  reservationId: number
  type: ViolationType
  description: string
  penaltyScore: number
  createTime: string
}

// ============================================
// 统计相关
// ============================================

export interface DashboardStats {
  totalStudyTime: number
  totalStudyHours: number
  todayStudyTime: number
  todayStudyHours: number
  consecutiveDays: number
  creditScore: number
  totalPoints: number
  totalCheckIns: number
  currentStreak: number
  maxStreak: number
  dailyGoalHours: number
  dailyGoalProgress: number
}

export interface RoomStats {
  totalSeats: number
  availableSeats: number
  occupiedSeats: number
  leavingSeats: number
  occupancyRate: number
}
