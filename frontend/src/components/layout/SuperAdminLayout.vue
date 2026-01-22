<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import {
  LayoutDashboard,
  Users,
  Building2,
  UserCog,
  Trophy,
  UserX,
  Settings,
  LogOut,
  ChevronLeft,
  ChevronRight
} from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const collapsed = ref(false)

const navItems = [
  { path: '/super/dashboard', icon: LayoutDashboard, label: '数据中心' },
  { path: '/super/users', icon: Users, label: '用户管理' },
  { path: '/super/rooms', icon: Building2, label: '自习室管理' },
  { path: '/super/admins', icon: UserCog, label: '管理员管理' },
  { path: '/super/achievements', icon: Trophy, label: '成就管理' },
  { path: '/super/blacklist', icon: UserX, label: '黑名单管理' },
  { path: '/super/settings', icon: Settings, label: '系统设置' }
]

const currentPath = computed(() => route.path)

const handleNavigate = (path: string) => {
  router.push(path)
}

const handleLogout = () => {
  userStore.logout()
}

const toggleCollapse = () => {
  collapsed.value = !collapsed.value
}
</script>

<template>
  <div class="super-admin-layout" :class="{ collapsed }">
    <!-- 侧边栏 -->
    <aside class="sidebar">
      <div class="sidebar-header">
        <div class="logo">
          <div class="logo-icon"><Settings :size="24" /></div>
          <span v-if="!collapsed" class="logo-text">超级管理</span>
        </div>
        <button class="collapse-btn" @click="toggleCollapse">
          <ChevronLeft v-if="!collapsed" :size="18" />
          <ChevronRight v-else :size="18" />
        </button>
      </div>
      
      <nav class="sidebar-nav">
        <button
          v-for="item in navItems"
          :key="item.path"
          class="nav-item"
          :class="{ active: currentPath === item.path }"
          @click="handleNavigate(item.path)"
          :title="collapsed ? item.label : ''"
        >
          <component :is="item.icon" :size="20" />
          <span v-if="!collapsed" class="nav-label">{{ item.label }}</span>
        </button>
      </nav>
      
      <div class="sidebar-footer">
        <div class="user-card" :class="{ mini: collapsed }">
          <el-avatar :size="collapsed ? 36 : 40" :src="userStore.userInfo?.avatar">
            {{ userStore.userName?.charAt(0) || 'S' }}
          </el-avatar>
          <div v-if="!collapsed" class="user-info">
            <span class="user-name">{{ userStore.userName }}</span>
            <span class="user-role">超级管理员</span>
          </div>
        </div>
        <button class="logout-btn" @click="handleLogout" :title="collapsed ? '退出登录' : ''">
          <LogOut :size="18" />
          <span v-if="!collapsed">退出登录</span>
        </button>
      </div>
    </aside>
    
    <!-- 主内容区 -->
    <main class="main-content">
      <router-view v-slot="{ Component }">
        <transition name="slide-fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.super-admin-layout {
  display: flex;
  min-height: 100vh;
  background: $bg-page;
}

.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  width: 240px;
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
  transition: width 0.3s ease;
  z-index: 100;
  
  .collapsed & {
    width: 72px;
  }
}

.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  overflow: hidden;
  
  .logo-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    color: $primary;
    flex-shrink: 0;
  }
  
  .logo-text {
    font-size: 16px;
    font-weight: 700;
    color: white;
    white-space: nowrap;
  }
}

.collapse-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  color: rgba(255, 255, 255, 0.6);
  border-radius: 6px;
  transition: all 0.2s;
  flex-shrink: 0;
  
  &:hover {
    color: white;
    background: rgba(255, 255, 255, 0.1);
  }
  
  .collapsed & {
    margin: 0 auto;
  }
}

.sidebar-nav {
  flex: 1;
  padding: 12px 8px;
  overflow-y: auto;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 12px 16px;
  margin-bottom: 4px;
  color: rgba(255, 255, 255, 0.7);
  border-radius: $radius-sm;
  transition: all 0.2s;
  
  .collapsed & {
    justify-content: center;
    padding: 12px;
  }
  
  &:hover {
    color: white;
    background: rgba(255, 255, 255, 0.1);
  }
  
  &.active {
    color: white;
    background: $gradient-purple;
    box-shadow: $shadow-purple;
  }
  
  .nav-label {
    font-size: 14px;
    font-weight: 500;
    white-space: nowrap;
  }
}

.sidebar-footer {
  padding: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.user-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  margin-bottom: 12px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: $radius-sm;
  
  &.mini {
    justify-content: center;
    padding: 8px;
  }
  
  .user-info {
    overflow: hidden;
  }
  
  .user-name {
    display: block;
    font-weight: 600;
    color: white;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  
  .user-role {
    display: block;
    font-size: 12px;
    color: rgba(255, 255, 255, 0.6);
  }
}

.logout-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  padding: 10px;
  color: rgba(255, 255, 255, 0.7);
  font-size: 14px;
  border-radius: $radius-sm;
  transition: all 0.2s;
  
  &:hover {
    color: white;
    background: rgba(255, 107, 107, 0.2);
  }
}

.main-content {
  flex: 1;
  margin-left: 240px;
  padding: 24px;
  transition: margin-left 0.3s ease;
  
  .collapsed & {
    margin-left: 72px;
  }
}

// 页面过渡
.slide-fade-enter-active {
  transition: all 0.3s ease-out;
}

.slide-fade-leave-active {
  transition: all 0.2s ease-in;
}

.slide-fade-enter-from,
.slide-fade-leave-to {
  transform: translateX(20px);
  opacity: 0;
}
</style>
