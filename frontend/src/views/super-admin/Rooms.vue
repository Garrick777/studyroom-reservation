<script setup lang="ts">
import { Building2 } from 'lucide-vue-next'
// TODO: 自习室管理
</script>

<template>
  <div class="page-placeholder">
    <h2><Building2 :size="24" /> 自习室管理</h2>
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
