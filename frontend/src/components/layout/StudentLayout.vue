<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import {
  Home,
  Building2,
  Calendar,
  Trophy,
  Medal,
  Shield,
  CalendarCheck,
  Target,
  User,
  Bell,
  LogOut,
  Menu,
  X,
  Users,
  UsersRound,
  MessageCircle,
  ShoppingBag,
  BookOpen
} from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const mobileMenuOpen = ref(false)

const navItems = [
  { path: '/dashboard', icon: Home, label: '工作台' },
  { path: '/rooms', icon: Building2, label: '自习室' },
  { path: '/reservations', icon: Calendar, label: '我的预约' },
  { path: '/checkin', icon: CalendarCheck, label: '打卡' },
  { path: '/goals', icon: Target, label: '目标' },
  { path: '/friends', icon: Users, label: '好友' },
  { path: '/groups', icon: UsersRound, label: '小组' },
  { path: '/credit', icon: Shield, label: '信用' },
  { path: '/achievements', icon: Trophy, label: '成就' },
  { path: '/ranking', icon: Medal, label: '排行' },
  { path: '/shop', icon: ShoppingBag, label: '商城' }
]

const currentPath = computed(() => route.path)

const handleNavigate = (path: string) => {
  router.push(path)
  mobileMenuOpen.value = false
}

const handleLogout = () => {
  userStore.logout()
}

const handleCommand = (command: string) => {
  if (command === 'logout') {
    handleLogout()
  } else if (command === 'profile') {
    handleNavigate('/profile')
  }
}

const toggleMobileMenu = () => {
  mobileMenuOpen.value = !mobileMenuOpen.value
}
</script>

<template>
  <div class="student-layout">
    <!-- 顶部导航栏 -->
    <header class="header">
      <div class="header-left">
        <button class="mobile-menu-btn" @click="toggleMobileMenu">
          <Menu v-if="!mobileMenuOpen" :size="24" />
          <X v-else :size="24" />
        </button>
        <div class="logo" @click="handleNavigate('/dashboard')">
          <div class="logo-icon"><BookOpen :size="24" /></div>
          <span class="logo-text">智慧自习室</span>
        </div>
      </div>
      
      <!-- 桌面端导航 -->
      <nav class="nav-desktop">
        <button
          v-for="item in navItems"
          :key="item.path"
          class="nav-item"
          :class="{ active: currentPath === item.path || currentPath.startsWith(item.path + '/') }"
          @click="handleNavigate(item.path)"
        >
          <component :is="item.icon" :size="18" />
          <span>{{ item.label }}</span>
        </button>
      </nav>
      
      <div class="header-right">
        <el-badge :value="3" :max="99" class="notification-badge">
          <button class="icon-btn" @click="handleNavigate('/messages')">
            <Bell :size="20" />
          </button>
        </el-badge>
        
        <el-dropdown trigger="click" @command="handleCommand">
          <div class="user-info">
            <el-avatar :size="36" :src="userStore.userInfo?.avatar">
              {{ userStore.userName?.charAt(0) || 'U' }}
            </el-avatar>
            <span class="user-name">{{ userStore.userName }}</span>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">
                <User :size="16" />
                <span>个人中心</span>
              </el-dropdown-item>
              <el-dropdown-item divided command="logout">
                <LogOut :size="16" />
                <span>退出登录</span>
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>
    
    <!-- 移动端导航菜单 -->
    <div class="mobile-nav" :class="{ open: mobileMenuOpen }">
      <button
        v-for="item in navItems"
        :key="item.path"
        class="mobile-nav-item"
        :class="{ active: currentPath === item.path }"
        @click="handleNavigate(item.path)"
      >
        <component :is="item.icon" :size="20" />
        <span>{{ item.label }}</span>
      </button>
    </div>
    
    <!-- 主内容区 -->
    <main class="main-content">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.student-layout {
  min-height: 100vh;
  background: $bg-page;
}

.header {
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
  padding: 0 24px;
  background: white;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.mobile-menu-btn {
  display: none;
  padding: 8px;
  color: $gray-600;
  
  @media (max-width: 768px) {
    display: flex;
  }
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  
  .logo-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    color: $primary;
  }
  
  .logo-text {
    font-size: 18px;
    font-weight: 700;
    color: $primary;
  }
}

.nav-desktop {
  display: flex;
  gap: 4px;
  
  @media (max-width: 768px) {
    display: none;
  }
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 16px;
  font-size: 14px;
  font-weight: 500;
  color: $gray-600;
  border-radius: $radius-sm;
  transition: all 0.2s;
  
  &:hover {
    color: $primary;
    background: $primary-light;
  }
  
  &.active {
    color: $primary;
    background: $primary-light;
  }
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.notification-badge {
  :deep(.el-badge__content) {
    background: $accent-orange;
  }
}

.icon-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  color: $gray-600;
  border-radius: $radius-sm;
  transition: all 0.2s;
  
  &:hover {
    color: $primary;
    background: $gray-100;
  }
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 4px;
  border-radius: $radius-sm;
  cursor: pointer;
  transition: all 0.2s;
  
  &:hover {
    background: $gray-100;
  }
  
  .user-name {
    font-weight: 500;
    color: $text-primary;
    
    @media (max-width: 768px) {
      display: none;
    }
  }
}

:deep(.el-dropdown-menu__item) {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
}

.mobile-nav {
  display: none;
  position: fixed;
  top: 64px;
  left: 0;
  right: 0;
  background: white;
  padding: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-100%);
  opacity: 0;
  transition: all 0.3s;
  z-index: 99;
  
  &.open {
    transform: translateY(0);
    opacity: 1;
  }
  
  @media (max-width: 768px) {
    display: block;
  }
}

.mobile-nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 14px 16px;
  font-size: 15px;
  color: $gray-600;
  border-radius: $radius-sm;
  
  &.active {
    color: $primary;
    background: $primary-light;
  }
}

.main-content {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
  
  @media (max-width: 768px) {
    padding: 16px;
  }
}

// 页面过渡动画
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
