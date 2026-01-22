import type { Directive } from 'vue'

/**
 * 图片懒加载指令
 * 使用方式: <img v-lazy="imageUrl" />
 */
export const lazyDirective: Directive<HTMLImageElement, string> = {
  mounted(el, binding) {
    const loadImage = () => {
      el.src = binding.value
      el.classList.add('lazy-loaded')
    }

    // 设置占位图
    el.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZjBmMGYwIi8+PC9zdmc+'
    el.classList.add('lazy-image')

    // 使用 IntersectionObserver 实现懒加载
    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              loadImage()
              observer.unobserve(el)
            }
          })
        },
        {
          rootMargin: '100px',
          threshold: 0.1
        }
      )
      observer.observe(el)
      
      // 存储observer引用以便卸载时清理
      ;(el as any)._lazyObserver = observer
    } else {
      // 不支持 IntersectionObserver 时直接加载
      loadImage()
    }
  },

  updated(el, binding) {
    if (binding.value !== binding.oldValue) {
      el.src = binding.value
    }
  },

  unmounted(el) {
    const observer = (el as any)._lazyObserver
    if (observer) {
      observer.disconnect()
    }
  }
}

/**
 * 背景图懒加载指令
 * 使用方式: <div v-lazy-bg="imageUrl"></div>
 */
export const lazyBgDirective: Directive<HTMLElement, string> = {
  mounted(el, binding) {
    const loadBackground = () => {
      el.style.backgroundImage = `url(${binding.value})`
      el.classList.add('lazy-bg-loaded')
    }

    el.classList.add('lazy-bg')

    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              loadBackground()
              observer.unobserve(el)
            }
          })
        },
        {
          rootMargin: '100px',
          threshold: 0.1
        }
      )
      observer.observe(el)
      ;(el as any)._lazyBgObserver = observer
    } else {
      loadBackground()
    }
  },

  updated(el, binding) {
    if (binding.value !== binding.oldValue) {
      el.style.backgroundImage = `url(${binding.value})`
    }
  },

  unmounted(el) {
    const observer = (el as any)._lazyBgObserver
    if (observer) {
      observer.disconnect()
    }
  }
}

// 全局样式（可以添加到全局CSS中）
export const lazyLoadStyles = `
.lazy-image {
  opacity: 0;
  transition: opacity 0.3s ease;
}

.lazy-image.lazy-loaded {
  opacity: 1;
}

.lazy-bg {
  background-color: #f0f0f0;
  transition: background-image 0.3s ease;
}

.lazy-bg.lazy-bg-loaded {
  background-color: transparent;
}
`
