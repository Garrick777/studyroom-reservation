<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  Settings,
  Calendar,
  Award,
  Shield,
  Server,
  Save,
  RefreshCw,
  Clock,
  AlertTriangle,
  CheckCircle
} from 'lucide-vue-next'
import { getSystemSettings, updateSystemSettings, type SystemSettings } from '@/api/super-admin'

const loading = ref(false)
const saving = ref(false)

// 设置数据
const settings = reactive<SystemSettings>({
  reservation: {
    maxDailyReservations: 3,
    advanceBookingDays: 7,
    signInAdvanceMinutes: 15,
    signInTimeoutMinutes: 15,
    leaveTimeoutMinutes: 30,
    maxLeaveCount: 2,
    freeCancelMinutes: 30
  },
  points: {
    pointsPerHour: 10,
    checkInBonus: 5,
    achievementBonus: 20,
    referralBonus: 50
  },
  credit: {
    initialScore: 100,
    maxScore: 120,
    minScoreForBooking: 60,
    noShowPenalty: 10,
    leaveTimeoutPenalty: 5,
    earlyLeavePenalty: 3,
    monthlyRecovery: 5
  },
  system: {
    siteName: '智慧自习室',
    siteDescription: '智慧自习室座位预约系统',
    maintenanceMode: false,
    registrationEnabled: true
  }
})

// 当前激活的标签
const activeTab = ref('reservation')

// 加载设置
const loadSettings = async () => {
  loading.value = true
  try {
    const data = await getSystemSettings()
    Object.assign(settings, data)
  } catch (error) {
    console.error('加载设置失败:', error)
  } finally {
    loading.value = false
  }
}

// 保存设置
const handleSave = async () => {
  saving.value = true
  try {
    await updateSystemSettings(settings)
    ElMessage.success('保存成功')
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败')
  } finally {
    saving.value = false
  }
}

// 重置当前分类
const handleReset = () => {
  loadSettings()
  ElMessage.info('已重置为服务器配置')
}

onMounted(() => {
  loadSettings()
})
</script>

<template>
  <div class="settings-page" v-loading="loading">
    <div class="page-header">
      <div class="header-left">
        <h2><Settings :size="24" /> 系统设置</h2>
        <p>配置系统运行参数</p>
      </div>
      <div class="header-actions">
        <el-button @click="handleReset">
          <RefreshCw :size="16" class="mr-1" /> 重置
        </el-button>
        <el-button type="primary" :loading="saving" @click="handleSave">
          <Save :size="16" class="mr-1" /> 保存设置
        </el-button>
      </div>
    </div>
    
    <el-tabs v-model="activeTab" class="settings-tabs">
      <!-- 预约设置 -->
      <el-tab-pane label="预约设置" name="reservation">
        <template #label>
          <span class="tab-label">
            <Calendar :size="16" /> 预约设置
          </span>
        </template>
        
        <el-card class="settings-card">
          <template #header>
            <div class="card-header">
              <Calendar :size="20" />
              <span>预约规则配置</span>
            </div>
          </template>
          
          <el-form label-width="180px" label-position="left">
            <el-form-item label="每日最大预约次数">
              <el-input-number 
                v-model="settings.reservation.maxDailyReservations" 
                :min="1" 
                :max="10"
              />
              <span class="form-hint">每位用户每天最多可预约的次数</span>
            </el-form-item>
            
            <el-form-item label="提前预约天数">
              <el-input-number 
                v-model="settings.reservation.advanceBookingDays" 
                :min="1" 
                :max="30"
              />
              <span class="form-hint">最多可提前多少天预约</span>
            </el-form-item>
            
            <el-divider />
            
            <el-form-item label="提前签到时间">
              <el-input-number 
                v-model="settings.reservation.signInAdvanceMinutes" 
                :min="5" 
                :max="30"
              />
              <span class="form-hint">分钟，可在预约开始前多久签到</span>
            </el-form-item>
            
            <el-form-item label="签到超时时间">
              <el-input-number 
                v-model="settings.reservation.signInTimeoutMinutes" 
                :min="5" 
                :max="60"
              />
              <span class="form-hint">分钟，超时未签到视为爽约</span>
            </el-form-item>
            
            <el-divider />
            
            <el-form-item label="暂离超时时间">
              <el-input-number 
                v-model="settings.reservation.leaveTimeoutMinutes" 
                :min="10" 
                :max="60"
              />
              <span class="form-hint">分钟，暂离超时自动签退</span>
            </el-form-item>
            
            <el-form-item label="最大暂离次数">
              <el-input-number 
                v-model="settings.reservation.maxLeaveCount" 
                :min="1" 
                :max="5"
              />
              <span class="form-hint">每次预约最多可暂离次数</span>
            </el-form-item>
            
            <el-form-item label="免责取消时间">
              <el-input-number 
                v-model="settings.reservation.freeCancelMinutes" 
                :min="10" 
                :max="120"
              />
              <span class="form-hint">分钟，预约开始前多久取消不扣分</span>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>
      
      <!-- 积分设置 -->
      <el-tab-pane label="积分设置" name="points">
        <template #label>
          <span class="tab-label">
            <Award :size="16" /> 积分设置
          </span>
        </template>
        
        <el-card class="settings-card">
          <template #header>
            <div class="card-header">
              <Award :size="20" />
              <span>积分奖励配置</span>
            </div>
          </template>
          
          <el-form label-width="180px" label-position="left">
            <el-form-item label="学习积分">
              <el-input-number 
                v-model="settings.points.pointsPerHour" 
                :min="1" 
                :max="50"
              />
              <span class="form-hint">每学习1小时获得的积分</span>
            </el-form-item>
            
            <el-form-item label="打卡奖励">
              <el-input-number 
                v-model="settings.points.checkInBonus" 
                :min="1" 
                :max="20"
              />
              <span class="form-hint">每日首次打卡获得的额外积分</span>
            </el-form-item>
            
            <el-form-item label="成就奖励">
              <el-input-number 
                v-model="settings.points.achievementBonus" 
                :min="5" 
                :max="100"
              />
              <span class="form-hint">解锁成就的基础奖励积分</span>
            </el-form-item>
            
            <el-form-item label="邀请奖励">
              <el-input-number 
                v-model="settings.points.referralBonus" 
                :min="10" 
                :max="200"
              />
              <span class="form-hint">成功邀请新用户获得的积分</span>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>
      
      <!-- 信用分设置 -->
      <el-tab-pane label="信用分设置" name="credit">
        <template #label>
          <span class="tab-label">
            <Shield :size="16" /> 信用分设置
          </span>
        </template>
        
        <el-card class="settings-card">
          <template #header>
            <div class="card-header">
              <Shield :size="20" />
              <span>信用分规则配置</span>
            </div>
          </template>
          
          <el-form label-width="180px" label-position="left">
            <el-form-item label="初始信用分">
              <el-input-number 
                v-model="settings.credit.initialScore" 
                :min="50" 
                :max="100"
              />
              <span class="form-hint">新用户的初始信用分</span>
            </el-form-item>
            
            <el-form-item label="信用分上限">
              <el-input-number 
                v-model="settings.credit.maxScore" 
                :min="100" 
                :max="150"
              />
              <span class="form-hint">信用分的最大值</span>
            </el-form-item>
            
            <el-form-item label="预约最低分">
              <el-input-number 
                v-model="settings.credit.minScoreForBooking" 
                :min="30" 
                :max="80"
              />
              <span class="form-hint">低于此分数无法预约</span>
            </el-form-item>
            
            <el-divider />
            
            <el-form-item label="爽约扣分">
              <el-input-number 
                v-model="settings.credit.noShowPenalty" 
                :min="5" 
                :max="30"
              />
              <span class="form-hint">未签到扣除的信用分</span>
            </el-form-item>
            
            <el-form-item label="暂离超时扣分">
              <el-input-number 
                v-model="settings.credit.leaveTimeoutPenalty" 
                :min="2" 
                :max="20"
              />
              <span class="form-hint">暂离超时扣除的信用分</span>
            </el-form-item>
            
            <el-form-item label="提前离开扣分">
              <el-input-number 
                v-model="settings.credit.earlyLeavePenalty" 
                :min="1" 
                :max="15"
              />
              <span class="form-hint">提前签退扣除的信用分</span>
            </el-form-item>
            
            <el-divider />
            
            <el-form-item label="每月恢复分数">
              <el-input-number 
                v-model="settings.credit.monthlyRecovery" 
                :min="1" 
                :max="20"
              />
              <span class="form-hint">每月自动恢复的信用分</span>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>
      
      <!-- 系统设置 -->
      <el-tab-pane label="系统设置" name="system">
        <template #label>
          <span class="tab-label">
            <Server :size="16" /> 系统设置
          </span>
        </template>
        
        <el-card class="settings-card">
          <template #header>
            <div class="card-header">
              <Server :size="20" />
              <span>系统基础配置</span>
            </div>
          </template>
          
          <el-form label-width="180px" label-position="left">
            <el-form-item label="网站名称">
              <el-input v-model="settings.system.siteName" style="width: 300px" />
            </el-form-item>
            
            <el-form-item label="网站描述">
              <el-input 
                v-model="settings.system.siteDescription" 
                type="textarea" 
                :rows="2"
                style="width: 400px"
              />
            </el-form-item>
            
            <el-divider />
            
            <el-form-item label="维护模式">
              <el-switch 
                v-model="settings.system.maintenanceMode"
                active-text="开启"
                inactive-text="关闭"
              />
              <div class="form-warning" v-if="settings.system.maintenanceMode">
                <AlertTriangle :size="14" /> 维护模式下，普通用户将无法访问系统
              </div>
            </el-form-item>
            
            <el-form-item label="开放注册">
              <el-switch 
                v-model="settings.system.registrationEnabled"
                active-text="允许"
                inactive-text="禁止"
              />
              <span class="form-hint">是否允许新用户注册</span>
            </el-form-item>
          </el-form>
        </el-card>
        
        <!-- 系统状态 -->
        <el-card class="settings-card mt-4">
          <template #header>
            <div class="card-header">
              <CheckCircle :size="20" />
              <span>系统状态</span>
            </div>
          </template>
          
          <div class="system-status">
            <div class="status-item healthy">
              <Server :size="20" />
              <div class="status-info">
                <div class="status-name">数据库</div>
                <div class="status-value">运行正常</div>
              </div>
            </div>
            <div class="status-item healthy">
              <Server :size="20" />
              <div class="status-info">
                <div class="status-name">Redis 缓存</div>
                <div class="status-value">运行正常</div>
              </div>
            </div>
            <div class="status-item healthy">
              <Server :size="20" />
              <div class="status-info">
                <div class="status-name">文件存储</div>
                <div class="status-value">运行正常</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.settings-page {
  padding: 24px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
  
  .header-left {
    h2 {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 22px;
      font-weight: 600;
      color: $text-primary;
      margin-bottom: 4px;
    }
    
    p {
      color: $text-secondary;
      font-size: 14px;
    }
  }
  
  .header-actions {
    display: flex;
    gap: 12px;
  }
}

.settings-tabs {
  :deep(.el-tabs__header) {
    margin-bottom: 24px;
  }
  
  .tab-label {
    display: flex;
    align-items: center;
    gap: 6px;
  }
}

.settings-card {
  .card-header {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 500;
    color: $text-primary;
  }
  
  .form-hint {
    margin-left: 16px;
    color: $text-muted;
    font-size: 13px;
  }
  
  .form-warning {
    display: flex;
    align-items: center;
    gap: 6px;
    margin-top: 8px;
    padding: 8px 12px;
    background: $warning-light;
    color: $warning;
    border-radius: 4px;
    font-size: 13px;
  }
}

.system-status {
  display: flex;
  gap: 24px;
  
  .status-item {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px;
    background: $gray-50;
    border-radius: 8px;
    
    &.healthy {
      background: $success-light;
      color: $success;
    }
    
    &.warning {
      background: $warning-light;
      color: $warning;
    }
    
    &.error {
      background: $error-light;
      color: $error;
    }
    
    .status-info {
      .status-name {
        font-size: 13px;
        color: $text-secondary;
      }
      
      .status-value {
        font-weight: 500;
      }
    }
  }
}

.mr-1 {
  margin-right: 4px;
}

.mt-4 {
  margin-top: 16px;
}
</style>
