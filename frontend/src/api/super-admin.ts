import { request } from '@/utils/request'

/**
 * 获取超管统计数据
 */
export function getSuperAdminStats() {
  return request.get('/super-admin/stats')
}

/**
 * 获取系统配置
 */
export function getSystemSettings() {
  return request.get('/super-admin/settings')
}

/**
 * 更新系统配置
 */
export function updateSystemSettings(data: any) {
  return request.put('/super-admin/settings', data)
}

/**
 * 获取管理员列表
 */
export function getAdminList(params: {
  pageNum?: number
  pageSize?: number
  keyword?: string
}) {
  return request.get('/super-admin/admins', { params })
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
  return request.post('/super-admin/admins', data)
}

/**
 * 更新管理员
 */
export function updateAdmin(id: number, data: any) {
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
  return request.post(`/super-admin/admins/${id}/reset-password`)
}
