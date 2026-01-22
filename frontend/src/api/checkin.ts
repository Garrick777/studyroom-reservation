import { request } from '@/utils/request'

// ==================== 类型定义 ====================

export interface CheckInRecord {
  id: number
  userId: number
  checkInDate: string
  checkInTime: string
  type: string
  earnedPoints: number
  earnedExp: number
  continuousDays: number
  source: string
  remark: string
  createdAt: string
}

export interface TodayStatus {
  checkedIn: boolean
  checkInTime?: string
  continuousDays: number
  totalCheckIns: number
  earnedPoints?: number
  earnedExp?: number
  expectedPoints?: number
  expectedExp?: number
  expectedContinuousDays?: number
}

export interface MonthCalendar {
  year: number
  month: number
  checkedDays: number[]
  totalDays: number
  totalPoints: number
  totalExp: number
  daysInMonth: number
}

export interface CheckInStats {
  totalDays: number
  totalPoints: number
  totalExp: number
  maxContinuousDays: number
  currentContinuousDays: number
  recentCheckIns: string[]
}

// ==================== API接口 ====================

/**
 * 每日打卡
 */
export function dailyCheckIn(source: string = 'WEB'): Promise<CheckInRecord> {
  return request.post('/checkin', null, { params: { source } })
}

/**
 * 获取今日打卡状态
 */
export function getTodayStatus(): Promise<TodayStatus> {
  return request.get('/checkin/today')
}

/**
 * 获取月度打卡日历
 */
export function getMonthCalendar(year?: number, month?: number): Promise<MonthCalendar> {
  return request.get('/checkin/calendar', { params: { year, month } })
}

/**
 * 获取打卡统计
 */
export function getCheckInStats(): Promise<CheckInStats> {
  return request.get('/checkin/stats')
}

/**
 * 获取打卡记录列表
 */
export function getCheckInRecords(startDate: string, endDate: string): Promise<CheckInRecord[]> {
  return request.get('/checkin/records', { params: { startDate, endDate } })
}
