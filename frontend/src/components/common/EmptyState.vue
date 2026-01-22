<template>
  <div class="empty-state" :class="[size]">
    <div class="empty-icon">
      <slot name="icon">
        <component :is="icon" :size="iconSize" />
      </slot>
    </div>
    <h3 v-if="title" class="empty-title">{{ title }}</h3>
    <p v-if="description" class="empty-description">{{ description }}</p>
    <div v-if="$slots.action" class="empty-action">
      <slot name="action" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Inbox, Search, FileX, WifiOff, AlertCircle } from 'lucide-vue-next'

type EmptyType = 'default' | 'search' | 'error' | 'network' | 'data'
type EmptySize = 'small' | 'default' | 'large'

const props = withDefaults(defineProps<{
  type?: EmptyType
  size?: EmptySize
  title?: string
  description?: string
}>(), {
  type: 'default',
  size: 'default'
})

const iconMap = {
  default: Inbox,
  search: Search,
  error: AlertCircle,
  network: WifiOff,
  data: FileX
}

const icon = computed(() => iconMap[props.type])

const iconSize = computed(() => {
  const sizes = { small: 40, default: 64, large: 80 }
  return sizes[props.size]
})
</script>

<style scoped lang="scss">
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  text-align: center;

  &.small {
    padding: 20px;

    .empty-title {
      font-size: 14px;
    }

    .empty-description {
      font-size: 12px;
    }
  }

  &.large {
    padding: 60px 20px;

    .empty-title {
      font-size: 20px;
    }

    .empty-description {
      font-size: 16px;
    }
  }
}

.empty-icon {
  color: #d1d5db;
  margin-bottom: 16px;
}

.empty-title {
  font-size: 16px;
  font-weight: 600;
  color: #374151;
  margin: 0 0 8px;
}

.empty-description {
  font-size: 14px;
  color: #9ca3af;
  margin: 0;
  max-width: 300px;
}

.empty-action {
  margin-top: 20px;
}
</style>
