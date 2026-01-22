import { request } from '@/utils/request'

export interface LoginParams {
  username: string
  password: string
  rememberMe?: boolean
}

export interface RegisterParams {
  username: string
  password: string
  studentId: string
  realName: string
  email?: string
  phone?: string
  gender?: number
  college?: string
  major?: string
  grade?: string
  classNo?: string
}

export interface UserInfo {
  id: number
  username: string
  studentId: string
  realName: string
  email: string
  phone: string
  avatar: string
  role: 'STUDENT' | 'ADMIN' | 'SUPER_ADMIN'
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
  status: number
}

export interface LoginResponse {
  token: string
  refreshToken: string
  expiresIn: number
  user: UserInfo
}

// 登录
export function login(data: LoginParams): Promise<LoginResponse> {
  return request.post('/auth/login', data)
}

// 注册
export function register(data: RegisterParams): Promise<number> {
  return request.post('/auth/register', data)
}

// 刷新Token
export function refreshToken(refreshToken: string): Promise<LoginResponse> {
  return request.post('/auth/refresh', null, {
    params: { refreshToken }
  })
}

// 登出
export function logout(): Promise<void> {
  return request.post('/auth/logout')
}
