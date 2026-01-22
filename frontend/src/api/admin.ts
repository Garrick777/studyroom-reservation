import { request } from '@/utils/request'

/**
 * 获取管理员统计数据
 */
export function getAdminStats() {
  return request.get('/manage/stats/overview')
}

/**
 * 获取实时状态
 */
export function getRealTimeStatus() {
  return request.get('/manage/stats/realtime')
}

/**
 * 获取最近活动
 */
export function getRecentActivities() {
  return request.get('/manage/stats/activities')
}

/**
 * 获取座位状态分布
 */
export function getSeatStatusDistribution() {
  return request.get('/manage/stats/seat-distribution')
}

/**
 * 获取预约趋势
 */
export function getReservationTrend(days: number = 7) {
  return request.get('/manage/stats/reservation-trend', { params: { days } })
}
