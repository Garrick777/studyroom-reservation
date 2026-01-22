<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'
import { updatePassword, uploadAvatar, checkIn } from '@/api/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  User,
  Mail,
  Phone,
  GraduationCap,
  Building,
  BookOpen,
  Users,
  Award,
  Clock,
  Coins,
  Flame,
  Calendar,
  Camera,
  Shield,
  Lock,
  Save
} from 'lucide-vue-next'

const userStore = useUserStore()

const loading = ref(false)
const activeTab = ref('profile')

// 个人信息表单
const profileForm = reactive({
  realName: '',
  email: '',
  phone: '',
  gender: 0,
  college: '',
  major: '',
  grade: '',
  classNo: ''
})

// 修改密码表单
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 用户统计
const stats = computed(() => [
  {
    icon: Clock,
    label: '累计学习',
    value: formatStudyTime(userStore.totalStudyTime),
    color: '#3FB19E'
  },
  {
    icon: Coins,
    label: '总积分',
    value: userStore.totalPoints.toString(),
    color: '#FFCB2F'
  },
  {
    icon: Shield,
    label: '信用分',
    value: userStore.creditScore.toString(),
    color: '#4A9FFF'
  },
  {
    icon: Flame,
    label: '连续签到',
    value: (userStore.userInfo?.consecutiveDays || 0) + '天',
    color: '#FF7A45'
  }
])

// 格式化学习时长
function formatStudyTime(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}分钟`
  }
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  return mins > 0 ? `${hours}h${mins}m` : `${hours}小时`
}

// 初始化表单
onMounted(async () => {
  await userStore.fetchUserInfo()
  if (userStore.userInfo) {
    Object.assign(profileForm, {
      realName: userStore.userInfo.realName || '',
      email: userStore.userInfo.email || '',
      phone: userStore.userInfo.phone || '',
      gender: userStore.userInfo.gender || 0,
      college: userStore.userInfo.college || '',
      major: userStore.userInfo.major || '',
      grade: userStore.userInfo.grade || '',
      classNo: userStore.userInfo.classNo || ''
    })
  }
})

// 更新个人信息
async function handleUpdateProfile() {
  loading.value = true
  try {
    await userStore.updateProfile(profileForm)
    ElMessage.success('信息更新成功')
  } catch (error: any) {
    // 错误已在拦截器处理
  } finally {
    loading.value = false
  }
}

// 修改密码
async function handleUpdatePassword() {
  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    ElMessage.error('两次输入的密码不一致')
    return
  }
  
  loading.value = true
  try {
    await updatePassword({
      oldPassword: passwordForm.oldPassword,
      newPassword: passwordForm.newPassword
    })
    ElMessage.success('密码修改成功')
    // 清空表单
    passwordForm.oldPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
  } catch (error: any) {
    // 错误已在拦截器处理
  } finally {
    loading.value = false
  }
}

// 上传头像
async function handleAvatarChange(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  
  // 验证文件类型
  if (!file.type.startsWith('image/')) {
    ElMessage.error('请上传图片文件')
    return
  }
  
  // 验证文件大小 (2MB)
  if (file.size > 2 * 1024 * 1024) {
    ElMessage.error('图片大小不能超过2MB')
    return
  }
  
  loading.value = true
  try {
    const avatarUrl = await uploadAvatar(file)
    await userStore.fetchUserInfo()
    ElMessage.success('头像更新成功')
  } catch (error: any) {
    // 错误已在拦截器处理
  } finally {
    loading.value = false
  }
}

// 每日签到
async function handleCheckIn() {
  loading.value = true
  try {
    await checkIn()
    await userStore.fetchUserInfo()
    ElMessage.success('签到成功！')
  } catch (error: any) {
    // 错误已在拦截器处理
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="profile-page">
    <!-- 顶部用户卡片 -->
    <div class="user-card">
      <div class="user-card-bg"></div>
      <div class="user-card-content">
        <div class="avatar-wrapper">
          <el-avatar :size="100" :src="userStore.userAvatar">
            {{ userStore.userName?.charAt(0) || 'U' }}
          </el-avatar>
          <label class="avatar-upload">
            <Camera :size="18" />
            <input type="file" accept="image/*" @change="handleAvatarChange" />
          </label>
        </div>
        <div class="user-info">
          <h2>{{ userStore.userName }}</h2>
          <p class="student-id">学号: {{ userStore.userInfo?.studentId }}</p>
          <div class="user-tags">
            <el-tag type="success">
              {{ userStore.userInfo?.college || '未设置学院' }}
            </el-tag>
            <el-tag>
              {{ userStore.userInfo?.major || '未设置专业' }}
            </el-tag>
          </div>
        </div>
        <el-button 
          type="primary" 
          class="checkin-btn"
          :loading="loading"
          @click="handleCheckIn"
        >
          <Calendar :size="18" />
          每日签到
        </el-button>
      </div>
    </div>
    
    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div 
        v-for="stat in stats" 
        :key="stat.label" 
        class="stat-card"
        :style="{ '--stat-color': stat.color }"
      >
        <div class="stat-icon">
          <component :is="stat.icon" :size="24" />
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stat.value }}</span>
          <span class="stat-label">{{ stat.label }}</span>
        </div>
      </div>
    </div>
    
    <!-- 设置面板 -->
    <div class="settings-panel">
      <el-tabs v-model="activeTab" class="settings-tabs">
        <el-tab-pane label="个人信息" name="profile">
          <div class="tab-content">
            <el-form :model="profileForm" label-position="top" class="profile-form">
              <div class="form-grid">
                <el-form-item label="真实姓名">
                  <el-input v-model="profileForm.realName" placeholder="请输入真实姓名">
                    <template #prefix>
                      <User :size="16" />
                    </template>
                  </el-input>
                </el-form-item>
                
                <el-form-item label="性别">
                  <el-select v-model="profileForm.gender" placeholder="请选择性别" style="width: 100%">
                    <el-option label="未设置" :value="0" />
                    <el-option label="男" :value="1" />
                    <el-option label="女" :value="2" />
                  </el-select>
                </el-form-item>
                
                <el-form-item label="邮箱">
                  <el-input v-model="profileForm.email" placeholder="请输入邮箱">
                    <template #prefix>
                      <Mail :size="16" />
                    </template>
                  </el-input>
                </el-form-item>
                
                <el-form-item label="手机号">
                  <el-input v-model="profileForm.phone" placeholder="请输入手机号">
                    <template #prefix>
                      <Phone :size="16" />
                    </template>
                  </el-input>
                </el-form-item>
                
                <el-form-item label="学院">
                  <el-input v-model="profileForm.college" placeholder="请输入学院">
                    <template #prefix>
                      <Building :size="16" />
                    </template>
                  </el-input>
                </el-form-item>
                
                <el-form-item label="专业">
                  <el-input v-model="profileForm.major" placeholder="请输入专业">
                    <template #prefix>
                      <BookOpen :size="16" />
                    </template>
                  </el-input>
                </el-form-item>
                
                <el-form-item label="年级">
                  <el-input v-model="profileForm.grade" placeholder="请输入年级">
                    <template #prefix>
                      <GraduationCap :size="16" />
                    </template>
                  </el-input>
                </el-form-item>
                
                <el-form-item label="班级">
                  <el-input v-model="profileForm.classNo" placeholder="请输入班级">
                    <template #prefix>
                      <Users :size="16" />
                    </template>
                  </el-input>
                </el-form-item>
              </div>
              
              <el-button 
                type="primary" 
                :loading="loading"
                @click="handleUpdateProfile"
              >
                <Save :size="16" />
                保存修改
              </el-button>
            </el-form>
          </div>
        </el-tab-pane>
        
        <el-tab-pane label="修改密码" name="password">
          <div class="tab-content">
            <el-form :model="passwordForm" label-position="top" class="password-form">
              <el-form-item label="当前密码">
                <el-input 
                  v-model="passwordForm.oldPassword" 
                  type="password" 
                  placeholder="请输入当前密码"
                  show-password
                >
                  <template #prefix>
                    <Lock :size="16" />
                  </template>
                </el-input>
              </el-form-item>
              
              <el-form-item label="新密码">
                <el-input 
                  v-model="passwordForm.newPassword" 
                  type="password" 
                  placeholder="请输入新密码（6-20位）"
                  show-password
                >
                  <template #prefix>
                    <Lock :size="16" />
                  </template>
                </el-input>
              </el-form-item>
              
              <el-form-item label="确认新密码">
                <el-input 
                  v-model="passwordForm.confirmPassword" 
                  type="password" 
                  placeholder="请再次输入新密码"
                  show-password
                >
                  <template #prefix>
                    <Lock :size="16" />
                  </template>
                </el-input>
              </el-form-item>
              
              <el-button 
                type="primary" 
                :loading="loading"
                @click="handleUpdatePassword"
              >
                <Lock :size="16" />
                修改密码
              </el-button>
            </el-form>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';
.profile-page {
  animation: fadeIn 0.5s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.user-card {
  position: relative;
  background: white;
  border-radius: $radius-xl;
  overflow: hidden;
  margin-bottom: 24px;
  
  .user-card-bg {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 120px;
    background: $gradient-hero;
  }
  
  .user-card-content {
    position: relative;
    display: flex;
    align-items: flex-end;
    gap: 24px;
    padding: 80px 32px 32px;
    
    @media (max-width: 768px) {
      flex-direction: column;
      align-items: center;
      text-align: center;
    }
  }
  
  .avatar-wrapper {
    position: relative;
    
    :deep(.el-avatar) {
      border: 4px solid white;
      box-shadow: $shadow-lg;
    }
    
    .avatar-upload {
      position: absolute;
      bottom: 0;
      right: 0;
      width: 32px;
      height: 32px;
      background: $primary;
      color: white;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.2s;
      
      &:hover {
        background: $primary-dark;
        transform: scale(1.1);
      }
      
      input {
        display: none;
      }
    }
  }
  
  .user-info {
    flex: 1;
    
    h2 {
      font-size: 24px;
      font-weight: 700;
      color: $text-primary;
      margin-bottom: 4px;
    }
    
    .student-id {
      color: $text-muted;
      margin-bottom: 12px;
    }
    
    .user-tags {
      display: flex;
      gap: 8px;
      
      @media (max-width: 768px) {
        justify-content: center;
      }
    }
  }
  
  .checkin-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    height: 44px;
    padding: 0 24px;
    border-radius: $radius-sm;
  }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 24px;
  
  @media (max-width: 1024px) {
    grid-template-columns: repeat(2, 1fr);
  }
  
  @media (max-width: 480px) {
    grid-template-columns: 1fr;
  }
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: white;
  border-radius: $radius-lg;
  box-shadow: $shadow-card;
  transition: all 0.3s;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: $shadow-card-hover;
  }
  
  .stat-icon {
    width: 52px;
    height: 52px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: color-mix(in srgb, var(--stat-color) 15%, white);
    color: var(--stat-color);
    border-radius: $radius-md;
  }
  
  .stat-info {
    .stat-value {
      display: block;
      font-size: 22px;
      font-weight: 700;
      color: $text-primary;
    }
    
    .stat-label {
      font-size: 13px;
      color: $text-muted;
    }
  }
}

.settings-panel {
  background: white;
  border-radius: $radius-xl;
  padding: 24px;
  box-shadow: $shadow-card;
  
  :deep(.el-tabs__header) {
    margin-bottom: 24px;
  }
  
  :deep(.el-tabs__item) {
    font-size: 15px;
    font-weight: 500;
  }
}

.tab-content {
  max-width: 600px;
}

.profile-form, .password-form {
  .form-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    margin-bottom: 24px;
    
    @media (max-width: 768px) {
      grid-template-columns: 1fr;
    }
  }
  
  :deep(.el-form-item__label) {
    font-weight: 500;
    color: $text-secondary;
  }
  
  :deep(.el-input__wrapper) {
    border-radius: $radius-sm;
  }
  
  :deep(.el-button) {
    display: flex;
    align-items: center;
    gap: 8px;
    height: 44px;
    padding: 0 24px;
  }
}

.password-form {
  max-width: 400px;
  
  :deep(.el-form-item) {
    margin-bottom: 20px;
  }
}
</style>
