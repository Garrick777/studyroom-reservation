import request from '@/utils/request'

// 获取学习时长排行榜
export const getStudyTimeRanking = (params: { period?: string; limit?: number }) => {
  return request.get('/ranking/study-time', { params })
}

// 获取连续打卡排行榜
export const getCheckInStreakRanking = (limit: number = 20) => {
  return request.get('/ranking/checkin-streak', { params: { limit } })
}

// 获取积分排行榜
export const getPointsRanking = (limit: number = 20) => {
  return request.get('/ranking/points', { params: { limit } })
}

// 获取成就排行榜
export const getAchievementRanking = (limit: number = 20) => {
  return request.get('/ranking/achievement', { params: { limit } })
}

// 获取我的排名信息
export const getMyRankInfo = (type: string = 'study_time') => {
  return request.get('/ranking/my-rank', { params: { type } })
}

// 获取综合排行榜
export const getRankingOverview = () => {
  return request.get('/ranking/overview')
}

// 刷新排行榜缓存（管理端）
export const refreshRankings = () => {
  return request.post('/ranking/admin/refresh')
}
