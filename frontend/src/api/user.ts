import { request } from '@/utils/request'
import type { UserInfo } from './auth'

export interface UpdateProfileParams {
  realName?: string
  email?: string
  phone?: string
  avatar?: string
  gender?: number
  college?: string
  major?: string
  grade?: string
  classNo?: string
}

export interface UpdatePasswordParams {
  oldPassword: string
  newPassword: string
}

// 获取当前用户信息
export function getProfile(): Promise<UserInfo> {
  return request.get('/user/profile')
}

// 更新个人信息
export function updateProfile(data: UpdateProfileParams): Promise<UserInfo> {
  return request.put('/user/profile', data)
}

// 修改密码
export function updatePassword(data: UpdatePasswordParams): Promise<void> {
  return request.put('/user/password', data)
}

// 上传头像
export function uploadAvatar(file: File): Promise<string> {
  return request.upload('/user/avatar', file)
}

// 用户签到
export function checkIn(): Promise<void> {
  return request.post('/user/checkin')
}
