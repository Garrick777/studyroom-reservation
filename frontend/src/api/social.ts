import request from '@/utils/request'

// ==================== 好友相关 ====================

/** 获取好友列表 */
export function getFriendList() {
  return request.get('/friends/list')
}

/** 发送好友请求 */
export function sendFriendRequest(data: { friendId: number; remark?: string }) {
  return request.post('/friends/request', data)
}

/** 接受好友请求 */
export function acceptFriendRequest(requestId: number) {
  return request.post(`/friends/accept/${requestId}`)
}

/** 拒绝好友请求 */
export function rejectFriendRequest(requestId: number) {
  return request.post(`/friends/reject/${requestId}`)
}

/** 删除好友 */
export function deleteFriend(friendId: number) {
  return request.delete(`/friends/${friendId}`)
}

/** 获取收到的好友请求 */
export function getReceivedRequests() {
  return request.get('/friends/requests/received')
}

/** 获取发出的好友请求 */
export function getSentRequests() {
  return request.get('/friends/requests/sent')
}

/** 搜索用户 */
export function searchUsers(keyword: string) {
  return request.get('/friends/search', { params: { keyword } })
}

/** 更新好友备注 */
export function updateFriendRemark(friendId: number, remark: string) {
  return request.put(`/friends/${friendId}/remark`, { remark })
}

/** 获取待处理请求数量 */
export function getPendingRequestCount() {
  return request.get('/friends/requests/pending/count')
}

/** 获取好友数量 */
export function getFriendCount() {
  return request.get('/friends/count')
}

/** 检查是否为好友 */
export function checkIsFriend(targetId: number) {
  return request.get(`/friends/check/${targetId}`)
}

// ==================== 学习小组相关 ====================

/** 创建小组 */
export function createGroup(data: {
  name: string
  description?: string
  avatar?: string
  coverImage?: string
  maxMembers?: number
  isPublic?: boolean
  needApprove?: boolean
  tags?: string
}) {
  return request.post('/groups', data)
}

/** 获取小组详情 */
export function getGroupDetail(groupId: number) {
  return request.get(`/groups/${groupId}`)
}

/** 获取小组成员列表 */
export function getGroupMembers(groupId: number) {
  return request.get(`/groups/${groupId}/members`)
}

/** 获取待审批成员列表 */
export function getPendingMembers(groupId: number) {
  return request.get(`/groups/${groupId}/members/pending`)
}

/** 加入小组 */
export function joinGroup(groupId: number) {
  return request.post(`/groups/${groupId}/join`)
}

/** 审批加入申请 */
export function approveJoin(groupId: number, memberId: number, approve: boolean) {
  return request.post(`/groups/${groupId}/members/${memberId}/approve`, null, {
    params: { approve }
  })
}

/** 退出小组 */
export function leaveGroup(groupId: number) {
  return request.post(`/groups/${groupId}/leave`)
}

/** 移除成员 */
export function removeMember(groupId: number, memberId: number) {
  return request.delete(`/groups/${groupId}/members/${memberId}`)
}

/** 设置/取消管理员 */
export function setAdmin(groupId: number, targetUserId: number, isAdmin: boolean) {
  return request.post(`/groups/${groupId}/members/${targetUserId}/admin`, null, {
    params: { isAdmin }
  })
}

/** 解散小组 */
export function dissolveGroup(groupId: number) {
  return request.delete(`/groups/${groupId}`)
}

/** 转让小组 */
export function transferGroup(groupId: number, newCreatorId: number) {
  return request.post(`/groups/${groupId}/transfer`, null, {
    params: { newCreatorId }
  })
}

/** 更新小组信息 */
export function updateGroup(groupId: number, data: Record<string, any>) {
  return request.put(`/groups/${groupId}`, data)
}

/** 获取公开小组列表 */
export function getPublicGroups(params: { page?: number; size?: number; keyword?: string }) {
  return request.get('/groups/public', { params })
}

/** 获取我加入的小组 */
export function getMyGroups() {
  return request.get('/groups/my')
}

/** 获取我创建的小组 */
export function getCreatedGroups() {
  return request.get('/groups/created')
}

/** 获取待审批数量 */
export function getPendingMemberCount(groupId: number) {
  return request.get(`/groups/${groupId}/pending/count`)
}

// ==================== 消息相关 ====================

/** 获取消息列表 */
export function getMessages(params: { page?: number; size?: number; type?: string; isRead?: number }) {
  return request.get('/messages', { params })
}

/** 获取最近消息 */
export function getRecentMessages(limit: number = 5) {
  return request.get('/messages/recent', { params: { limit } })
}

/** 获取消息详情 */
export function getMessageDetail(messageId: number) {
  return request.get(`/messages/${messageId}`)
}

/** 标记消息已读 */
export function markAsRead(messageId: number) {
  return request.post(`/messages/${messageId}/read`)
}

/** 标记所有消息已读 */
export function markAllRead() {
  return request.post('/messages/read-all')
}

/** 标记指定类型消息已读 */
export function markTypeRead(type: string) {
  return request.post('/messages/read-type', null, { params: { type } })
}

/** 获取未读消息数量 */
export function getUnreadCount() {
  return request.get('/messages/unread/count')
}

/** 按类型统计未读消息 */
export function getUnreadCountByType() {
  return request.get('/messages/unread/by-type')
}

/** 删除消息 */
export function deleteMessage(messageId: number) {
  return request.delete(`/messages/${messageId}`)
}

/** 获取消息统计 */
export function getMessageStats() {
  return request.get('/messages/stats')
}
