import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as loginApi, register as registerApi, logout as logoutApi, type LoginParams, type RegisterParams, type UserInfo } from '@/api/auth'
import { getProfile, updateProfile as updateProfileApi, type UpdateProfileParams } from '@/api/user'
import router from '@/router'

export const useUserStore = defineStore('user', () => {
  // 状态
  const token = ref<string>(localStorage.getItem('token') || '')
  const refreshToken = ref<string>(localStorage.getItem('refreshToken') || '')
  const userInfo = ref<UserInfo | null>(null)
  
  // 计算属性
  const isLoggedIn = computed(() => !!token.value)
  const userRole = computed(() => userInfo.value?.role || '')
  const userId = computed(() => userInfo.value?.id || 0)
  const userName = computed(() => userInfo.value?.realName || userInfo.value?.username || '')
  const userAvatar = computed(() => userInfo.value?.avatar || '')
  const creditScore = computed(() => userInfo.value?.creditScore || 0)
  const totalStudyTime = computed(() => userInfo.value?.totalStudyTime || 0)
  const totalPoints = computed(() => userInfo.value?.totalPoints || 0)
  
  // 登录
  async function login(data: LoginParams) {
    const res = await loginApi(data)
    
    // 保存Token
    token.value = res.token
    refreshToken.value = res.refreshToken
    userInfo.value = res.user
    
    localStorage.setItem('token', res.token)
    localStorage.setItem('refreshToken', res.refreshToken)
    
    // 根据角色跳转
    switch (res.user.role) {
      case 'SUPER_ADMIN':
        router.push('/super/dashboard')
        break
      case 'ADMIN':
        router.push('/admin/dashboard')
        break
      default:
        router.push('/dashboard')
    }
    
    return res
  }
  
  // 注册
  async function register(data: RegisterParams) {
    const userId = await registerApi(data)
    return userId
  }
  
  // 获取用户信息
  async function fetchUserInfo() {
    if (!token.value) return null
    try {
      const res = await getProfile()
      userInfo.value = res
      return res
    } catch (error) {
      // Token无效，清除登录状态
      logout()
      throw error
    }
  }
  
  // 更新用户信息
  async function updateProfile(data: UpdateProfileParams) {
    const res = await updateProfileApi(data)
    userInfo.value = res
    return res
  }
  
  // 设置Token（用于刷新Token）
  function setToken(newToken: string, newRefreshToken: string) {
    token.value = newToken
    refreshToken.value = newRefreshToken
    localStorage.setItem('token', newToken)
    localStorage.setItem('refreshToken', newRefreshToken)
  }
  
  // 登出
  async function logout() {
    try {
      if (token.value) {
        await logoutApi()
      }
    } catch (error) {
      // 忽略登出错误
    } finally {
      // 清除状态
      token.value = ''
      refreshToken.value = ''
      userInfo.value = null
      localStorage.removeItem('token')
      localStorage.removeItem('refreshToken')
      router.push('/login')
    }
  }
  
  // 初始化：从本地存储恢复状态
  async function init() {
    if (token.value) {
      try {
        await fetchUserInfo()
      } catch (error) {
        // Token无效，清除
        token.value = ''
        refreshToken.value = ''
        localStorage.removeItem('token')
        localStorage.removeItem('refreshToken')
      }
    }
  }
  
  return {
    // 状态
    token,
    refreshToken,
    userInfo,
    // 计算属性
    isLoggedIn,
    userRole,
    userId,
    userName,
    userAvatar,
    creditScore,
    totalStudyTime,
    totalPoints,
    // 方法
    login,
    register,
    fetchUserInfo,
    updateProfile,
    setToken,
    logout,
    init
  }
})
