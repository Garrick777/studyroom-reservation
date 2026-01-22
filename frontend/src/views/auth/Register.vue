<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import { User, Lock, CreditCard, Mail, Phone, BookOpen, ArrowLeft } from 'lucide-vue-next'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  studentId: '',
  realName: '',
  email: '',
  phone: ''
})

const validateConfirmPassword = (rule: any, value: string, callback: Function) => {
  if (value !== registerForm.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 4, max: 20, message: '用户名长度为4-20位', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ],
  studentId: [
    { required: true, message: '请输入学号', trigger: 'blur' },
    { pattern: /^\d{8,12}$/, message: '学号格式不正确', trigger: 'blur' }
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' },
    { min: 2, max: 10, message: '姓名长度为2-10位', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '邮箱格式不正确', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ]
}

const formRef = ref()

const handleRegister = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid: boolean) => {
    if (!valid) return
    
    loading.value = true
    try {
      await userStore.register({
        username: registerForm.username,
        password: registerForm.password,
        studentId: registerForm.studentId,
        realName: registerForm.realName,
        email: registerForm.email || undefined,
        phone: registerForm.phone || undefined
      })
      ElMessage.success('注册成功，请登录')
      router.push('/login')
    } catch (error: any) {
      ElMessage.error(error.message || '注册失败')
    } finally {
      loading.value = false
    }
  })
}

const goLogin = () => {
  router.push('/login')
}
</script>

<template>
  <div class="register-page">
    <!-- 左侧装饰 -->
    <div class="register-left">
      <div class="brand">
        <BookOpen :size="48" />
        <h1>智慧自习室</h1>
        <p>开启高效学习之旅</p>
      </div>
    </div>
    
    <!-- 右侧注册表单 -->
    <div class="register-right">
      <div class="register-card">
        <el-button type="primary" link class="back-btn" @click="goLogin">
          <ArrowLeft :size="16" />
          返回登录
        </el-button>
        
        <h2>创建账号</h2>
        <p class="subtitle">填写信息注册新账号</p>
        
        <el-form
          ref="formRef"
          :model="registerForm"
          :rules="rules"
          class="register-form"
          label-position="top"
        >
          <div class="form-row">
            <el-form-item prop="username" label="用户名">
              <el-input
                v-model="registerForm.username"
                placeholder="请输入用户名"
              >
                <template #prefix>
                  <User :size="16" class="input-icon" />
                </template>
              </el-input>
            </el-form-item>
            
            <el-form-item prop="studentId" label="学号">
              <el-input
                v-model="registerForm.studentId"
                placeholder="请输入学号"
              >
                <template #prefix>
                  <CreditCard :size="16" class="input-icon" />
                </template>
              </el-input>
            </el-form-item>
          </div>
          
          <el-form-item prop="realName" label="真实姓名">
            <el-input
              v-model="registerForm.realName"
              placeholder="请输入真实姓名"
            >
              <template #prefix>
                <User :size="16" class="input-icon" />
              </template>
            </el-input>
          </el-form-item>
          
          <div class="form-row">
            <el-form-item prop="password" label="密码">
              <el-input
                v-model="registerForm.password"
                type="password"
                placeholder="请输入密码"
                show-password
              >
                <template #prefix>
                  <Lock :size="16" class="input-icon" />
                </template>
              </el-input>
            </el-form-item>
            
            <el-form-item prop="confirmPassword" label="确认密码">
              <el-input
                v-model="registerForm.confirmPassword"
                type="password"
                placeholder="请再次输入密码"
                show-password
              >
                <template #prefix>
                  <Lock :size="16" class="input-icon" />
                </template>
              </el-input>
            </el-form-item>
          </div>
          
          <div class="form-row">
            <el-form-item prop="email" label="邮箱（选填）">
              <el-input
                v-model="registerForm.email"
                placeholder="请输入邮箱"
              >
                <template #prefix>
                  <Mail :size="16" class="input-icon" />
                </template>
              </el-input>
            </el-form-item>
            
            <el-form-item prop="phone" label="手机号（选填）">
              <el-input
                v-model="registerForm.phone"
                placeholder="请输入手机号"
              >
                <template #prefix>
                  <Phone :size="16" class="input-icon" />
                </template>
              </el-input>
            </el-form-item>
          </div>
          
          <el-form-item>
            <el-button
              type="primary"
              size="large"
              :loading="loading"
              class="register-btn"
              @click="handleRegister"
            >
              注 册
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';
.register-page {
  display: flex;
  min-height: 100vh;
  background: $bg-page;
}

.register-left {
  flex: 0 0 40%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 60px;
  background: $gradient-hero;
  color: white;
  
  .brand {
    text-align: center;
    
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
}

.register-right {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40px;
  overflow-y: auto;
}

.register-card {
  width: 100%;
  max-width: 520px;
  padding: 40px 48px;
  background: white;
  border-radius: $radius-xl;
  box-shadow: $shadow-lg;
  
  .back-btn {
    margin-bottom: 16px;
    padding: 0;
    display: flex;
    align-items: center;
    gap: 4px;
  }
  
  h2 {
    font-size: 28px;
    font-weight: 700;
    color: $text-primary;
    margin-bottom: 8px;
  }
  
  .subtitle {
    color: $text-muted;
    margin-bottom: 24px;
  }
}

.register-form {
  .form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }
  
  :deep(.el-form-item__label) {
    font-weight: 500;
    color: $text-secondary;
    padding-bottom: 4px;
  }
  
  :deep(.el-input__wrapper) {
    border-radius: $radius-sm;
  }
  
  .input-icon {
    color: $gray-400;
  }
  
  .register-btn {
    width: 100%;
    height: 48px;
    font-size: 16px;
    border-radius: $radius-sm;
    margin-top: 8px;
  }
}

// 响应式
@media (max-width: 768px) {
  .register-page {
    flex-direction: column;
  }
  
  .register-left {
    flex: 0 0 auto;
    padding: 40px 20px;
    
    .brand h1 {
      font-size: 28px;
    }
  }
  
  .register-right {
    padding: 20px;
  }
  
  .register-card {
    padding: 24px;
  }
  
  .register-form .form-row {
    grid-template-columns: 1fr;
    gap: 0;
  }
}
</style>
