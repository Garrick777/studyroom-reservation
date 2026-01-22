import { request } from '@/utils/request'
import type { Room, Seat, PageResult } from '@/types'

// 自习室查询参数
export interface RoomQuery {
  pageNum?: number
  pageSize?: number
  keyword?: string
  building?: string
  status?: number
}

// 创建自习室参数
export interface RoomCreateParams {
  name: string
  code: string
  building: string
  floor: string
  roomNumber?: string
  capacity: number
  description?: string
  facilities?: string
  openTime: string
  closeTime: string
  rowCount?: number
  colCount?: number
  coverImage?: string
}

// 更新自习室参数
export interface RoomUpdateParams {
  name?: string
  code?: string
  building?: string
  floor?: string
  roomNumber?: string
  capacity?: number
  description?: string
  facilities?: string
  openTime?: string
  closeTime?: string
  rowCount?: number
  colCount?: number
  coverImage?: string
  status?: number
}

// 批量创建座位参数
export interface SeatBatchCreateParams {
  rowCount: number
  colCount: number
  clearExisting?: boolean
}

// 更新座位参数
export interface SeatUpdateParams {
  seatNo?: string
  seatType?: number
  status?: number
  hasPower?: boolean
  hasUsb?: boolean
  hasLamp?: boolean
  nearWindow?: boolean
  nearAisle?: boolean
}

// 自习室详情响应
export interface RoomDetailResponse {
  room: Room
  totalSeats: number
  availableSeats: number
  disabledSeats: number
}

// ==================== 自习室管理 ====================

// 获取自习室列表
export function getAdminRoomList(params: RoomQuery): Promise<PageResult<Room>> {
  return request.get('/manage/rooms', { params })
}

// 获取自习室详情
export function getAdminRoomDetail(id: number): Promise<RoomDetailResponse> {
  return request.get(`/manage/rooms/${id}`)
}

// 创建自习室
export function createRoom(data: RoomCreateParams): Promise<number> {
  return request.post('/manage/rooms', data)
}

// 更新自习室
export function updateRoom(id: number, data: RoomUpdateParams): Promise<void> {
  return request.put(`/manage/rooms/${id}`, data)
}

// 删除自习室
export function deleteRoom(id: number): Promise<void> {
  return request.delete(`/manage/rooms/${id}`)
}

// 切换自习室状态
export function toggleRoomStatus(id: number, status: number): Promise<void> {
  return request.put(`/manage/rooms/${id}/status`, null, { params: { status } })
}

// 获取建筑列表
export function getBuildingList(): Promise<string[]> {
  return request.get('/manage/rooms/buildings')
}

// ==================== 座位管理 ====================

// 获取座位列表
export function getSeatList(roomId: number): Promise<Seat[]> {
  return request.get(`/manage/rooms/${roomId}/seats`)
}

// 批量生成座位
export function batchCreateSeats(roomId: number, data: SeatBatchCreateParams): Promise<number> {
  return request.post(`/manage/rooms/${roomId}/seats/batch`, data)
}

// 更新座位
export function updateSeat(seatId: number, data: SeatUpdateParams): Promise<void> {
  return request.put(`/manage/rooms/seats/${seatId}`, data)
}

// 批量更新座位状态
export function batchUpdateSeatStatus(roomId: number, seatIds: number[], status: number): Promise<void> {
  return request.put(`/manage/rooms/${roomId}/seats/batch-status`, { seatIds, status })
}

// 删除座位
export function deleteSeat(seatId: number): Promise<void> {
  return request.delete(`/manage/rooms/seats/${seatId}`)
}
