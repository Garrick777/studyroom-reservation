<script setup lang="ts">
import { useRouter } from 'vue-router'
import { ShieldX, ArrowLeft, Home } from 'lucide-vue-next'

const router = useRouter()

const goBack = () => {
  router.back()
}

const goHome = () => {
  router.push('/')
}
</script>

<template>
  <div class="error-page">
    <div class="error-content">
      <ShieldX :size="120" class="error-icon" />
      <h1>403</h1>
      <p class="title">访问受限</p>
      <p class="description">抱歉，您没有权限访问此页面</p>
      <div class="actions">
        <el-button @click="goBack">
          <ArrowLeft :size="16" />
          返回上一页
        </el-button>
        <el-button type="primary" @click="goHome">
          <Home :size="16" />
          返回首页
        </el-button>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';
.error-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: $bg-page;
}

.error-content {
  text-align: center;
  padding: 40px;
  
  .error-icon {
    color: $warning;
    margin-bottom: 24px;
  }
  
  h1 {
    font-size: 72px;
    font-weight: 700;
    color: $text-primary;
    margin-bottom: 16px;
  }
  
  .title {
    font-size: 24px;
    font-weight: 600;
    color: $text-primary;
    margin-bottom: 8px;
  }
  
  .description {
    color: $text-muted;
    margin-bottom: 32px;
  }
  
  .actions {
    display: flex;
    gap: 16px;
    justify-content: center;
    
    :deep(.el-button) {
      display: flex;
      align-items: center;
      gap: 8px;
    }
  }
}
</style>
