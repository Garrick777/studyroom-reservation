/**
 * 成就图标映射配置
 * 将数据库中的图标名称映射到本地SVG图标路径
 */

// 导入所有成就图标
import studyClock from '@/assets/icons/achievement/study-clock.svg'
import studyMaster from '@/assets/icons/achievement/study-master.svg'
import checkinStreak from '@/assets/icons/achievement/checkin-streak.svg'
import calendarStar from '@/assets/icons/achievement/calendar-star.svg'
import crown from '@/assets/icons/achievement/crown.svg'
import socialFriends from '@/assets/icons/achievement/social-friends.svg'
import trophy from '@/assets/icons/achievement/trophy.svg'
import earlyBird from '@/assets/icons/achievement/early-bird.svg'
import nightOwl from '@/assets/icons/achievement/night-owl.svg'
import medal from '@/assets/icons/achievement/medal.svg'
import diamond from '@/assets/icons/achievement/diamond.svg'
import shield from '@/assets/icons/achievement/shield.svg'
import coin from '@/assets/icons/achievement/coin.svg'
import flag from '@/assets/icons/achievement/flag.svg'
import group from '@/assets/icons/achievement/group.svg'
import calendar from '@/assets/icons/achievement/calendar.svg'
import badgeCommon from '@/assets/icons/achievement/badge-common.svg'
import badgeRare from '@/assets/icons/achievement/badge-rare.svg'
import badgeEpic from '@/assets/icons/achievement/badge-epic.svg'
import badgeLegendary from '@/assets/icons/achievement/badge-legendary.svg'

// 图标映射表
const iconMap: Record<string, string> = {
  // 学习类图标
  'mdi-clock-outline': studyClock,
  'mdi-clock-check': studyClock,
  'mdi-clock-star': studyMaster,
  'mdi-star': studyMaster,
  
  // 打卡类图标
  'mdi-checkbox-marked-circle': checkinStreak,
  'mdi-calendar-week': calendar,
  'mdi-calendar-month': calendar,
  'mdi-calendar-check': calendarStar,
  'mdi-crown': crown,
  
  // 预约类图标
  'mdi-calendar-plus': calendar,
  'mdi-calendar-multiple': calendar,
  'mdi-calendar-star': calendarStar,
  
  // 特殊成就图标
  'mdi-weather-sunny': earlyBird,
  'mdi-weather-sunset-up': earlyBird,
  'mdi-white-balance-sunny': earlyBird,
  'mdi-weather-night': nightOwl,
  'mdi-moon-waning-crescent': nightOwl,
  
  // 社交类图标
  'mdi-account-plus': socialFriends,
  'mdi-account-group': group,
  'mdi-account-multiple-plus': group,
  'mdi-account-multiple-check': group,
  'mdi-account-star': socialFriends,
  
  // 荣誉类图标
  'mdi-trophy': trophy,
  'mdi-trophy-award': trophy,
  'mdi-medal': medal,
  'mdi-gold': coin,
  'mdi-diamond': diamond,
  'mdi-coin': coin,
  
  // 挑战类图标
  'mdi-flag-variant': flag,
  'mdi-flag-checkered': flag,
  'mdi-sword': medal,
  'mdi-run-fast': medal,
  
  // 信用/保护类图标
  'mdi-shield-check': shield,
  'mdi-shield-star': shield,
  'mdi-star-circle': studyMaster,
  
  // 默认图标（按稀有度）
  'default-common': badgeCommon,
  'default-rare': badgeRare,
  'default-epic': badgeEpic,
  'default-legendary': badgeLegendary,
}

/**
 * 获取成就图标URL
 * @param iconName 数据库中存储的图标名称
 * @param rarity 成就稀有度，用于获取默认图标
 * @returns 本地图标URL
 */
export function getAchievementIcon(iconName: string, rarity?: string): string {
  // 先尝试从映射表获取
  if (iconMap[iconName]) {
    return iconMap[iconName]
  }
  
  // 如果没有找到，根据稀有度返回默认图标
  if (rarity) {
    const defaultKey = `default-${rarity.toLowerCase()}`
    if (iconMap[defaultKey]) {
      return iconMap[defaultKey]
    }
  }
  
  // 最终默认返回普通徽章
  return badgeCommon
}

/**
 * 获取稀有度对应的默认图标
 * @param rarity 稀有度
 * @returns 图标URL
 */
export function getRarityIcon(rarity: string): string {
  const rarityMap: Record<string, string> = {
    'COMMON': badgeCommon,
    'RARE': badgeRare,
    'EPIC': badgeEpic,
    'LEGENDARY': badgeLegendary,
  }
  return rarityMap[rarity] || badgeCommon
}

export default {
  getAchievementIcon,
  getRarityIcon,
  iconMap
}
