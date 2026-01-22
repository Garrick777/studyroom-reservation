<script setup lang="ts">
import { Settings } from 'lucide-vue-next'
// TODO: 系统设置
</script>

<template>
  <div class="page-placeholder">
    <h2><Settings :size="24" /> 系统设置</h2>
    <p>待开发</p>
  </div>
</template>

<style lang="scss" scoped>
.page-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  background: white;
  border-radius: 16px;
  
  h2 { margin-bottom: 8px; }
  p { color: #999; }
}
</style>
