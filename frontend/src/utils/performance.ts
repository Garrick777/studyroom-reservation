/**
 * 性能优化工具函数
 */

/**
 * 防抖函数
 */
export function debounce<T extends (...args: any[]) => any>(
  fn: T,
  delay: number = 300
): (...args: Parameters<T>) => void {
  let timer: ReturnType<typeof setTimeout> | null = null
  
  return function(this: any, ...args: Parameters<T>) {
    if (timer) clearTimeout(timer)
    timer = setTimeout(() => {
      fn.apply(this, args)
      timer = null
    }, delay)
  }
}

/**
 * 节流函数
 */
export function throttle<T extends (...args: any[]) => any>(
  fn: T,
  interval: number = 200
): (...args: Parameters<T>) => void {
  let lastTime = 0
  
  return function(this: any, ...args: Parameters<T>) {
    const now = Date.now()
    if (now - lastTime >= interval) {
      fn.apply(this, args)
      lastTime = now
    }
  }
}

/**
 * 图片懒加载
 */
export function lazyLoadImage(el: HTMLImageElement, src: string) {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        el.src = src
        el.classList.add('loaded')
        observer.unobserve(el)
      }
    })
  }, {
    rootMargin: '50px'
  })
  
  observer.observe(el)
  
  return () => observer.disconnect()
}

/**
 * 虚拟滚动辅助函数
 */
export function useVirtualScroll<T>(
  items: T[],
  itemHeight: number,
  containerHeight: number,
  buffer: number = 5
) {
  const visibleCount = Math.ceil(containerHeight / itemHeight) + buffer * 2
  
  return {
    getVisibleItems(scrollTop: number) {
      const startIndex = Math.max(0, Math.floor(scrollTop / itemHeight) - buffer)
      const endIndex = Math.min(items.length, startIndex + visibleCount)
      
      return {
        items: items.slice(startIndex, endIndex),
        startIndex,
        endIndex,
        offsetY: startIndex * itemHeight,
        totalHeight: items.length * itemHeight
      }
    }
  }
}

/**
 * 请求缓存
 */
const requestCache = new Map<string, { data: any; timestamp: number }>()

export function cachedRequest<T>(
  key: string,
  fetcher: () => Promise<T>,
  ttl: number = 5 * 60 * 1000 // 默认5分钟
): Promise<T> {
  const cached = requestCache.get(key)
  
  if (cached && Date.now() - cached.timestamp < ttl) {
    return Promise.resolve(cached.data as T)
  }
  
  return fetcher().then(data => {
    requestCache.set(key, { data, timestamp: Date.now() })
    return data
  })
}

/**
 * 清除请求缓存
 */
export function clearRequestCache(key?: string) {
  if (key) {
    requestCache.delete(key)
  } else {
    requestCache.clear()
  }
}

/**
 * 预加载图片
 */
export function preloadImages(urls: string[]): Promise<void[]> {
  return Promise.all(
    urls.map(url => new Promise<void>((resolve, reject) => {
      const img = new Image()
      img.onload = () => resolve()
      img.onerror = reject
      img.src = url
    }))
  )
}

/**
 * 检测是否为移动设备
 */
export function isMobile(): boolean {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent
  )
}

/**
 * 检测是否支持触摸
 */
export function isTouchDevice(): boolean {
  return 'ontouchstart' in window || navigator.maxTouchPoints > 0
}

/**
 * 页面可见性变化监听
 */
export function onVisibilityChange(callback: (visible: boolean) => void) {
  const handleChange = () => {
    callback(document.visibilityState === 'visible')
  }
  
  document.addEventListener('visibilitychange', handleChange)
  
  return () => {
    document.removeEventListener('visibilitychange', handleChange)
  }
}

/**
 * 空闲时执行任务
 */
export function runWhenIdle(callback: () => void, timeout: number = 2000) {
  if ('requestIdleCallback' in window) {
    return (window as any).requestIdleCallback(callback, { timeout })
  } else {
    return setTimeout(callback, 1)
  }
}

/**
 * 批量DOM更新
 */
export function batchUpdate(updates: (() => void)[]) {
  requestAnimationFrame(() => {
    updates.forEach(update => update())
  })
}
