<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import { User, Lock, BookOpen } from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const loading = ref(false)
const loginForm = reactive({
  username: '',
  password: '',
  rememberMe: false
})

const rules = {
  username: [
    { required: true, message: '请输入用户名/学号', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

const formRef = ref()

// 从本地存储恢复记住的用户名
onMounted(() => {
  const rememberedUsername = localStorage.getItem('rememberedUsername')
  if (rememberedUsername) {
    loginForm.username = rememberedUsername
    loginForm.rememberMe = true
  }
})

const handleLogin = async () => {
  if (!formRef.value) return
  
  try {
    // 使用 Promise 方式验证表单
    const valid = await formRef.value.validate().catch(() => false)
    if (!valid) return
    
    loading.value = true
    await userStore.login({
      username: loginForm.username,
      password: loginForm.password,
      rememberMe: loginForm.rememberMe
    })
    
    // 记住用户名
    if (loginForm.rememberMe) {
      localStorage.setItem('rememberedUsername', loginForm.username)
    } else {
      localStorage.removeItem('rememberedUsername')
    }
    
    ElMessage.success('登录成功')
    
    // 跳转到来源页面
    const redirect = route.query.redirect as string
    if (redirect && !redirect.includes('/login')) {
      router.push(redirect)
    }
  } catch (error: any) {
    // 错误消息已在拦截器中处理
    console.error('登录失败:', error)
  } finally {
    loading.value = false
  }
}

const goRegister = () => {
  router.push('/register')
}
</script>

<template>
  <div class="login-page">
    <!-- 左侧装饰 -->
    <div class="login-left">
      <div class="brand">
        <BookOpen :size="48" />
        <h1>智慧自习室</h1>
        <p>专注学习，高效预约</p>
      </div>
      <div class="features">
        <div class="feature-item">
          <span class="dot"></span>
          <span>快速预约心仪座位</span>
        </div>
        <div class="feature-item">
          <span class="dot"></span>
          <span>实时查看空位信息</span>
        </div>
        <div class="feature-item">
          <span class="dot"></span>
          <span>累积学习时长成就</span>
        </div>
      </div>
    </div>
    
    <!-- 右侧登录表单 -->
    <div class="login-right">
      <div class="login-card">
        <h2>欢迎回来</h2>
        <p class="subtitle">请登录您的账号</p>
        
        <el-form
          ref="formRef"
          :model="loginForm"
          :rules="rules"
          class="login-form"
          @keyup.enter="handleLogin"
        >
          <el-form-item prop="username">
            <el-input
              v-model="loginForm.username"
              placeholder="用户名 / 学号"
              size="large"
            >
              <template #prefix>
                <User :size="18" class="input-icon" />
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item prop="password">
            <el-input
              v-model="loginForm.password"
              type="password"
              placeholder="密码"
              size="large"
              show-password
            >
              <template #prefix>
                <Lock :size="18" class="input-icon" />
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item>
            <div class="form-options">
              <el-checkbox v-model="loginForm.rememberMe">记住我</el-checkbox>
            </div>
          </el-form-item>
          
          <el-form-item>
            <el-button
              type="primary"
              size="large"
              :loading="loading"
              class="login-btn"
              @click="handleLogin"
            >
              {{ loading ? '登录中...' : '登 录' }}
            </el-button>
          </el-form-item>
        </el-form>
        
        <div class="login-footer">
          <span>还没有账号？</span>
          <el-button type="primary" link @click="goRegister">
            立即注册
          </el-button>
        </div>
        
        <!-- 测试账号提示 -->
        <div class="test-accounts">
          <p class="test-title">测试账号（密码均为 123456）</p>
          <div class="test-item">
            <span class="role">学生：</span>
            <span>zhangsan / lisi / wangwu</span>
          </div>
          <div class="test-item">
            <span class="role">管理员：</span>
            <span>admin1 / admin2</span>
          </div>
          <div class="test-item">
            <span class="role">超管：</span>
            <span>superadmin</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.login-page {
  display: flex;
  min-height: 100vh;
  background: $bg-page;
}

.login-left {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 60px;
  background: $gradient-hero;
  color: white;
  
  .brand {
    text-align: center;
    margin-bottom: 60px;
    
    h1 {
      font-size: 36px;
      font-weight: 700;
      margin: 16px 0 8px;
    }
    
    p {
      font-size: 16px;
      opacity: 0.9;
    }
  }
  
  .features {
    .feature-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 0;
      font-size: 16px;
      
      .dot {
        width: 8px;
        height: 8px;
        background: white;
        border-radius: 50%;
      }
    }
  }
}

.login-right {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 60px;
}

.login-card {
  width: 100%;
  max-width: 400px;
  padding: 48px;
  background: white;
  border-radius: $radius-xl;
  box-shadow: $shadow-lg;
  
  h2 {
    font-size: 28px;
    font-weight: 700;
    color: $text-primary;
    margin-bottom: 8px;
  }
  
  .subtitle {
    color: $text-muted;
    margin-bottom: 32px;
  }
}

.login-form {
  :deep(.el-input__wrapper) {
    padding: 4px 16px;
    border-radius: $radius-sm;
  }
  
  .input-icon {
    color: $gray-400;
  }
  
  .form-options {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .login-btn {
    width: 100%;
    height: 48px;
    font-size: 16px;
    border-radius: $radius-sm;
  }
}

.login-footer {
  text-align: center;
  margin-top: 24px;
  color: $text-muted;
}

.test-accounts {
  margin-top: 32px;
  padding: 16px;
  background: $gray-50;
  border-radius: $radius-sm;
  font-size: 12px;
  
  .test-title {
    font-weight: 600;
    color: $text-secondary;
    margin-bottom: 8px;
  }
  
  .test-item {
    display: flex;
    gap: 8px;
    padding: 4px 0;
    color: $text-muted;
    
    .role {
      color: $text-secondary;
      min-width: 50px;
    }
  }
}

// 响应式
@media (max-width: 768px) {
  .login-page {
    flex-direction: column;
  }
  
  .login-left {
    padding: 40px 20px;
    
    .brand h1 {
      font-size: 28px;
    }
    
    .features {
      display: none;
    }
  }
  
  .login-right {
    padding: 20px;
  }
  
  .login-card {
    padding: 32px 24px;
  }
}
</style>
