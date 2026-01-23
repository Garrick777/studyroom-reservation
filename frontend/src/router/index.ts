import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/stores/user'
import NProgress from 'nprogress'

// 公开路由
const publicRoutes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/Login.vue'),
    meta: { title: '登录', public: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/auth/Register.vue'),
    meta: { title: '注册', public: true }
  }
]

// 学生路由
const studentRoutes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('@/components/layout/StudentLayout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'StudentDashboard',
        component: () => import('@/views/student/Dashboard.vue'),
        meta: { title: '工作台', roles: ['STUDENT'] }
      },
      {
        path: 'rooms',
        name: 'RoomList',
        component: () => import('@/views/student/RoomList.vue'),
        meta: { title: '自习室', roles: ['STUDENT'] }
      },
      {
        path: 'rooms/:id',
        name: 'RoomDetail',
        component: () => import('@/views/student/RoomDetail.vue'),
        meta: { title: '选座', roles: ['STUDENT'] }
      },
      {
        path: 'reservations',
        name: 'MyReservations',
        component: () => import('@/views/student/Reservations.vue'),
        meta: { title: '我的预约', roles: ['STUDENT'] }
      },
      {
        path: 'achievements',
        name: 'Achievements',
        component: () => import('@/views/student/Achievements.vue'),
        meta: { title: '成就', roles: ['STUDENT'] }
      },
      {
        path: 'ranking',
        name: 'Ranking',
        component: () => import('@/views/student/Ranking.vue'),
        meta: { title: '排行榜', roles: ['STUDENT'] }
      },
      {
        path: 'credit',
        name: 'Credit',
        component: () => import('@/views/student/Credit.vue'),
        meta: { title: '信用积分', roles: ['STUDENT'] }
      },
      {
        path: 'checkin',
        name: 'CheckIn',
        component: () => import('@/views/student/CheckIn.vue'),
        meta: { title: '每日打卡', roles: ['STUDENT'] }
      },
      {
        path: 'goals',
        name: 'Goals',
        component: () => import('@/views/student/Goals.vue'),
        meta: { title: '学习目标', roles: ['STUDENT'] }
      },
      {
        path: 'friends',
        name: 'Friends',
        component: () => import('@/views/student/Friends.vue'),
        meta: { title: '好友', roles: ['STUDENT'] }
      },
      {
        path: 'groups',
        name: 'Groups',
        component: () => import('@/views/student/Groups.vue'),
        meta: { title: '学习小组', roles: ['STUDENT'] }
      },
      {
        path: 'messages',
        name: 'Messages',
        component: () => import('@/views/student/Messages.vue'),
        meta: { title: '消息中心', roles: ['STUDENT'] }
      },
      {
        path: 'shop',
        name: 'Shop',
        component: () => import('@/views/student/Shop.vue'),
        meta: { title: '积分商城', roles: ['STUDENT'] }
      },
      {
        path: 'profile',
        name: 'StudentProfile',
        component: () => import('@/views/student/Profile.vue'),
        meta: { title: '个人中心', roles: ['STUDENT'] }
      }
    ]
  }
]

// 管理员路由
const adminRoutes: RouteRecordRaw[] = [
  {
    path: '/admin',
    component: () => import('@/components/layout/AdminLayout.vue'),
    redirect: '/admin/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'AdminDashboard',
        component: () => import('@/views/admin/Dashboard.vue'),
        meta: { title: '控制台', roles: ['ADMIN'] }
      },
      {
        path: 'rooms',
        name: 'AdminRooms',
        component: () => import('@/views/admin/Rooms.vue'),
        meta: { title: '自习室管理', roles: ['ADMIN'] }
      },
      {
        path: 'seats',
        name: 'AdminSeats',
        component: () => import('@/views/admin/Seats.vue'),
        meta: { title: '座位监控', roles: ['ADMIN'] }
      },
      {
        path: 'reservations',
        name: 'AdminReservations',
        component: () => import('@/views/admin/Reservations.vue'),
        meta: { title: '预约管理', roles: ['ADMIN'] }
      },
      {
        path: 'violations',
        name: 'AdminViolations',
        component: () => import('@/views/admin/Violations.vue'),
        meta: { title: '违规管理', roles: ['ADMIN'] }
      },
      {
        path: 'shop',
        name: 'AdminShop',
        component: () => import('@/views/admin/ShopManage.vue'),
        meta: { title: '商城管理', roles: ['ADMIN'] }
      }
    ]
  }
]

// 超级管理员路由
const superAdminRoutes: RouteRecordRaw[] = [
  {
    path: '/super',
    component: () => import('@/components/layout/SuperAdminLayout.vue'),
    redirect: '/super/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'SuperDashboard',
        component: () => import('@/views/super-admin/Dashboard.vue'),
        meta: { title: '数据中心', roles: ['SUPER_ADMIN'] }
      },
      {
        path: 'users',
        name: 'UserManagement',
        component: () => import('@/views/super-admin/Users.vue'),
        meta: { title: '用户管理', roles: ['SUPER_ADMIN'] }
      },
      {
        path: 'rooms',
        name: 'RoomManagement',
        component: () => import('@/views/super-admin/Rooms.vue'),
        meta: { title: '自习室管理', roles: ['SUPER_ADMIN'] }
      },
      {
        path: 'admins',
        name: 'AdminManagement',
        component: () => import('@/views/super-admin/Admins.vue'),
        meta: { title: '管理员管理', roles: ['SUPER_ADMIN'] }
      },
      {
        path: 'achievements',
        name: 'AchievementManagement',
        component: () => import('@/views/super-admin/Achievements.vue'),
        meta: { title: '成就管理', roles: ['SUPER_ADMIN'] }
      },
      {
        path: 'products',
        name: 'ProductManagement',
        component: () => import('@/views/super-admin/Products.vue'),
        meta: { title: '商品管理', roles: ['SUPER_ADMIN'] }
      },
      {
        path: 'orders',
        name: 'OrderManagement',
        component: () => import('@/views/super-admin/Orders.vue'),
        meta: { title: '订单管理', roles: ['SUPER_ADMIN'] }
      },
      {
        path: 'appeals',
        name: 'AppealManagement',
        component: () => import('@/views/super-admin/Appeals.vue'),
        meta: { title: '申诉管理', roles: ['SUPER_ADMIN'] }
      },
      {
        path: 'blacklist',
        name: 'BlacklistManagement',
        component: () => import('@/views/super-admin/Blacklist.vue'),
        meta: { title: '黑名单管理', roles: ['SUPER_ADMIN'] }
      },
      {
        path: 'settings',
        name: 'SystemSettings',
        component: () => import('@/views/super-admin/Settings.vue'),
        meta: { title: '系统设置', roles: ['SUPER_ADMIN'] }
      }
    ]
  }
]

// 错误页面
const errorRoutes: RouteRecordRaw[] = [
  {
    path: '/403',
    name: 'Forbidden',
    component: () => import('@/views/error/403.vue'),
    meta: { title: '无权限', public: true }
  },
  {
    path: '/404',
    name: 'NotFound',
    component: () => import('@/views/error/404.vue'),
    meta: { title: '页面不存在', public: true }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/404'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes: [...publicRoutes, ...studentRoutes, ...adminRoutes, ...superAdminRoutes, ...errorRoutes]
})

// 标记是否已初始化
let isInitialized = false

// 根据角色获取首页路径
function getHomePathByRole(role: string): string {
  switch (role) {
    case 'SUPER_ADMIN':
      return '/super/dashboard'
    case 'ADMIN':
      return '/admin/dashboard'
    default:
      return '/dashboard'
  }
}

// 路由守卫
router.beforeEach(async (to, from, next) => {
  NProgress.start()
  
  // 设置页面标题
  document.title = `${to.meta.title || '智慧自习室'} - 智慧自习室座位预约系统`
  
  const userStore = useUserStore()
  const isPublic = to.meta.public
  const requiredRoles = to.meta.roles as string[] | undefined
  
  // 公开页面，直接放行
  if (isPublic) {
    next()
    return
  }
  
  // 未登录，跳转登录页
  if (!userStore.token) {
    next({ path: '/login', query: { redirect: to.fullPath } })
    return
  }
  
  // 首次访问需要登录的页面，先获取用户信息
  if (!isInitialized && userStore.token && !userStore.userInfo) {
    try {
      await userStore.fetchUserInfo()
      isInitialized = true
    } catch (error) {
      // Token无效，跳转登录
      next({ path: '/login', query: { redirect: to.fullPath } })
      return
    }
  }
  
  // 访问根路径时，根据角色重定向到对应首页
  if (to.path === '/' || to.path === '/dashboard') {
    const homePath = getHomePathByRole(userStore.userRole)
    if (to.path !== homePath && userStore.userRole !== 'STUDENT') {
      next(homePath)
      return
    }
  }
  
  // 需要角色验证
  if (requiredRoles && requiredRoles.length > 0) {
    if (!requiredRoles.includes(userStore.userRole)) {
      // 如果没有权限，重定向到对应角色的首页而不是403
      const homePath = getHomePathByRole(userStore.userRole)
      next(homePath)
      return
    }
  }
  
  next()
})

router.afterEach(() => {
  NProgress.done()
})

export default router
