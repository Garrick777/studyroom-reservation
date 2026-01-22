import { request } from '@/utils/request'
import type { PageResult } from '@/types'

export interface StudyRoom {
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
  facilities: string[]
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
  status: number
  sortOrder: number
  availableSeats: number
  isFavorite: boolean
}

export interface Seat {
  id: number
  roomId: number
  seatNo: string
  rowNum: number
  colNum: number
  seatType: 'NORMAL' | 'WINDOW' | 'POWER' | 'VIP'
  status: number
  remark: string
  currentStatus?: 'AVAILABLE' | 'RESERVED' | 'IN_USE' | 'LEAVING' | 'UNAVAILABLE'
}

export interface TimeSlot {
  id: number
  name: string
  startTime: string
  endTime: string
  duration: number
  sortOrder: number
  status: number
  available?: boolean
  availableSeats?: number
}

// 获取自习室列表
export function getRoomList(params: {
  page?: number
  size?: number
  keyword?: string
  building?: string
  status?: number
}): Promise<PageResult<StudyRoom>> {
  return request.get('/rooms', { params })
}

// 获取自习室详情
export function getRoomDetail(roomId: number): Promise<StudyRoom> {
  return request.get(`/rooms/${roomId}`)
}

// 获取热门自习室
export function getHotRooms(limit = 6): Promise<StudyRoom[]> {
  return request.get('/rooms/hot', { params: { limit } })
}

// 获取评分最高的自习室
export function getTopRatedRooms(limit = 6): Promise<StudyRoom[]> {
  return request.get('/rooms/top-rated', { params: { limit } })
}

// 获取自习室座位列表
export function getRoomSeats(roomId: number): Promise<Seat[]> {
  return request.get(`/rooms/${roomId}/seats`)
}

// 获取座位实时状态
export function getSeatsWithStatus(roomId: number, date: string, timeSlotId: number): Promise<Seat[]> {
  return request.get(`/rooms/${roomId}/seats/status`, {
    params: { date, timeSlotId }
  })
}

// 获取所有时段
export function getTimeSlots(): Promise<TimeSlot[]> {
  return request.get('/rooms/time-slots')
}

// 获取自习室可用时段
export function getAvailableTimeSlots(roomId: number, date: string): Promise<TimeSlot[]> {
  return request.get(`/rooms/${roomId}/time-slots`, {
    params: { date }
  })
}

// 收藏自习室
export function addFavorite(roomId: number): Promise<void> {
  return request.post(`/rooms/${roomId}/favorite`)
}

// 取消收藏
export function removeFavorite(roomId: number): Promise<void> {
  return request.delete(`/rooms/${roomId}/favorite`)
}

// 获取我的收藏列表
export function getUserFavorites(): Promise<StudyRoom[]> {
  return request.get('/rooms/favorites')
}

// 检查是否已收藏
export function isFavorite(roomId: number): Promise<boolean> {
  return request.get(`/rooms/${roomId}/is-favorite`)
}
