import { request } from '@/utils/request'

// 类型定义
export interface CreateReservationParams {
  roomId: number
  seatId: number
  date: string
  timeSlotId: number
  remark?: string
  source?: string
}

export interface ReservationVO {
  id: number
  reservationNo: string
  userId: number
  userName: string
  studentId: string
  roomId: number
  roomName: string
  roomLocation: string
  seatId: number
  seatNo: string
  seatType: string
  date: string
  timeSlotId: number
  timeSlotName: string
  startTime: string
  endTime: string
  status: string
  statusText: string
  signInTime: string | null
  signOutTime: string | null
  actualDuration: number | null
  leaveTime: string | null
  leaveCount: number
  violationType: string | null
  earnedPoints: number
  earnedExp: number
  remark: string | null
  source: string
  createdAt: string
  canSignIn: boolean
  canSignOut: boolean
  canLeave: boolean
  canReturn: boolean
  canCancel: boolean
  remainingMinutes: number | null
}

export interface ReservationQueryParams {
  status?: string
  startDate?: string
  endDate?: string
  pageNum?: number
  pageSize?: number
}

export interface PageResult<T> {
  records: T[]
  total: number
  pageNum: number
  pageSize: number
}

// 创建预约
export function createReservation(data: CreateReservationParams) {
  return request.post<ReservationVO>('/reservations', data)
}

// 获取预约详情
export function getReservationDetail(id: number) {
  return request.get<ReservationVO>(`/reservations/${id}`)
}

// 获取当前预约
export function getCurrentReservation() {
  return request.get<ReservationVO | null>('/reservations/current')
}

// 查询我的预约列表
export function getMyReservations(params: ReservationQueryParams) {
  return request.get<PageResult<ReservationVO>>('/reservations/my', { params })
}

// 签到
export function signIn(id: number) {
  return request.post<ReservationVO>(`/reservations/${id}/sign-in`)
}

// 签退
export function signOut(id: number) {
  return request.post<ReservationVO>(`/reservations/${id}/sign-out`)
}

// 暂离
export function leave(id: number) {
  return request.post<ReservationVO>(`/reservations/${id}/leave`)
}

// 暂离返回
export function returnFromLeave(id: number) {
  return request.post<ReservationVO>(`/reservations/${id}/return`)
}

// 取消预约
export function cancelReservation(id: number, reason?: string) {
  return request.post<ReservationVO>(`/reservations/${id}/cancel`, null, {
    params: { reason }
  })
}

// 提交评价
export interface CreateReviewParams {
  rating: number
  content?: string
  tags?: string
}

export function createReview(reservationId: number, data: CreateReviewParams) {
  return request.post(`/reservations/${reservationId}/review`, data)
}

// 获取座位评价
export function getSeatReviews(seatId: number, limit = 10) {
  return request.get(`/seats/${seatId}/reviews`, { params: { limit } })
}

// 管理员接口
export function getAdminReservations(params: ReservationQueryParams & { userId?: number, roomId?: number, seatId?: number }) {
  return request.get<PageResult<ReservationVO>>('/manage/reservations', { params })
}

export function getAdminReservationStats() {
  return request.get<{
    total: number
    pending: number
    signedIn: number
    leaving: number
    inUse: number
    completed: number
    cancelled: number
    noShow: number
  }>('/manage/reservations/stats/today')
}
