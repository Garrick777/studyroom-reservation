import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import 'element-plus/dist/index.css'

import App from './App.vue'
import router from './router'
import { useUserStore } from './stores/user'
import { lazyDirective, lazyBgDirective } from './directives/lazyload'

import '@/styles/main.scss'

const app = createApp(App)

// 注册全局指令
app.directive('lazy', lazyDirective)
app.directive('lazy-bg', lazyBgDirective)

// Pinia 状态管理
const pinia = createPinia()
app.use(pinia)

// Vue Router
app.use(router)

// Element Plus
app.use(ElementPlus, {
  locale: zhCn,
  size: 'default'
})

// 初始化用户状态
const userStore = useUserStore()
userStore.init().then(() => {
  app.mount('#app')
})
