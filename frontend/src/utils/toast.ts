import { ElMessage, ElNotification } from 'element-plus'

/**
 * Toast 消息提示工具
 */
export const toast = {
  /**
   * 成功消息
   */
  success(message: string, duration = 2000) {
    ElMessage({
      message,
      type: 'success',
      duration,
      showClose: true
    })
  },

  /**
   * 错误消息
   */
  error(message: string, duration = 3000) {
    ElMessage({
      message,
      type: 'error',
      duration,
      showClose: true
    })
  },

  /**
   * 警告消息
   */
  warning(message: string, duration = 2500) {
    ElMessage({
      message,
      type: 'warning',
      duration,
      showClose: true
    })
  },

  /**
   * 信息消息
   */
  info(message: string, duration = 2000) {
    ElMessage({
      message,
      type: 'info',
      duration,
      showClose: true
    })
  },

  /**
   * 加载消息
   */
  loading(message = '加载中...') {
    return ElMessage({
      message,
      type: 'info',
      duration: 0,
      icon: 'Loading',
      customClass: 'loading-message'
    })
  }
}

/**
 * 通知提示
 */
export const notify = {
  /**
   * 成功通知
   */
  success(title: string, message?: string) {
    ElNotification({
      title,
      message,
      type: 'success',
      duration: 3000
    })
  },

  /**
   * 错误通知
   */
  error(title: string, message?: string) {
    ElNotification({
      title,
      message,
      type: 'error',
      duration: 4500
    })
  },

  /**
   * 警告通知
   */
  warning(title: string, message?: string) {
    ElNotification({
      title,
      message,
      type: 'warning',
      duration: 3500
    })
  },

  /**
   * 信息通知
   */
  info(title: string, message?: string) {
    ElNotification({
      title,
      message,
      type: 'info',
      duration: 3000
    })
  },

  /**
   * 预约成功通知
   */
  reservationSuccess(roomName: string, seatNo: string, time: string) {
    ElNotification({
      title: '预约成功',
      message: `您已成功预约 ${roomName} ${seatNo}号座位\n时间: ${time}`,
      type: 'success',
      duration: 5000
    })
  },

  /**
   * 签到提醒通知
   */
  checkInReminder(roomName: string, seatNo: string, minutes: number) {
    ElNotification({
      title: '签到提醒',
      message: `您在 ${roomName} ${seatNo}号座位的预约将在${minutes}分钟后开始，请及时签到！`,
      type: 'warning',
      duration: 0 // 不自动关闭
    })
  },

  /**
   * 成就解锁通知
   */
  achievementUnlocked(achievementName: string) {
    ElNotification({
      title: '🎉 成就解锁！',
      message: `恭喜您解锁成就：${achievementName}`,
      type: 'success',
      duration: 5000,
      customClass: 'achievement-notification'
    })
  }
}

export default { toast, notify }
