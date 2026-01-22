<template>
  <div class="shop-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1>积分商城</h1>
        <p>用学习积分兑换精彩好礼</p>
      </div>
      <div class="points-display">
        <div class="points-card">
          <span class="label">我的积分</span>
          <span class="value">{{ userPoints }}</span>
        </div>
      </div>
    </div>

    <!-- 分类筛选 -->
    <div class="category-bar">
      <div 
        v-for="cat in categories" 
        :key="cat.value"
        :class="['category-item', { active: currentCategory === cat.value }]"
        @click="currentCategory = cat.value"
      >
        <span class="icon">{{ cat.icon }}</span>
        <span class="name">{{ cat.name }}</span>
      </div>
    </div>

    <!-- 商品列表 -->
    <div class="products-section">
      <div class="products-grid" v-if="products.length">
        <div 
          v-for="product in products" 
          :key="product.id" 
          class="product-card"
          @click="showProductDetail(product)"
        >
          <div class="product-image">
            <img :src="getProductImage(product)" :alt="product.name" />
            <div class="category-tag" :class="product.category.toLowerCase()">
              {{ getCategoryName(product.category) }}
            </div>
            <div v-if="product.stock !== -1 && product.stock < 10" class="stock-tag">
              仅剩 {{ product.stock }}
            </div>
          </div>
          <div class="product-info">
            <h3 class="product-name">{{ product.name }}</h3>
            <p class="product-desc">{{ product.description }}</p>
            <div class="product-footer">
              <div class="price">
                <span class="points">{{ product.pointsCost }}</span>
                <span class="unit">积分</span>
              </div>
              <div class="exchanged">
                已兑 {{ product.exchangedCount }}
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <el-empty v-else description="暂无商品" />

      <!-- 分页 -->
      <div class="pagination" v-if="total > pageSize">
        <el-pagination
          v-model:current-page="pageNum"
          :page-size="pageSize"
          :total="total"
          layout="prev, pager, next"
          @current-change="loadProducts"
        />
      </div>
    </div>

    <!-- 我的兑换记录 -->
    <div class="exchanges-section">
      <div class="section-header">
        <h2>我的兑换记录</h2>
        <el-button text @click="showAllExchanges = !showAllExchanges">
          {{ showAllExchanges ? '收起' : '查看全部' }}
        </el-button>
      </div>
      
      <div class="exchanges-list" v-if="exchanges.length">
        <div 
          v-for="exchange in displayedExchanges" 
          :key="exchange.id" 
          class="exchange-item"
        >
          <div class="exchange-image">
            <img :src="getProductImage(exchange)" :alt="exchange.productName" />
          </div>
          <div class="exchange-info">
            <h4>{{ exchange.productName }}</h4>
            <p>兑换单号：{{ exchange.exchangeNo }}</p>
            <p>兑换时间：{{ formatDate(exchange.createTime) }}</p>
          </div>
          <div class="exchange-status">
            <el-tag :type="getStatusType(exchange.status)">
              {{ getStatusText(exchange.status) }}
            </el-tag>
            <div class="points-cost">-{{ exchange.pointsCost }} 积分</div>
          </div>
          <div class="exchange-action" v-if="exchange.redeemCode">
            <el-button size="small" @click="copyCode(exchange.redeemCode)">
              复制兑换码
            </el-button>
          </div>
        </div>
      </div>
      <el-empty v-else description="暂无兑换记录" :image-size="80" />
    </div>

    <!-- 商品详情弹窗 -->
    <el-dialog v-model="detailVisible" :title="selectedProduct?.name" width="500px">
      <div class="product-detail" v-if="selectedProduct">
        <div class="detail-image">
          <img :src="getProductImage(selectedProduct)" :alt="selectedProduct.name" />
        </div>
        <div class="detail-info">
          <p class="description">{{ selectedProduct.description }}</p>
          <div class="detail-meta">
            <div class="meta-item">
              <span class="label">所需积分</span>
              <span class="value highlight">{{ selectedProduct.pointsCost }}</span>
            </div>
            <div class="meta-item">
              <span class="label">库存</span>
              <span class="value">{{ selectedProduct.stock === -1 ? '充足' : selectedProduct.stock }}</span>
            </div>
            <div class="meta-item" v-if="selectedProduct.limitPerUser > 0">
              <span class="label">限兑</span>
              <span class="value">{{ selectedProduct.limitPerUser }} 件/人</span>
            </div>
          </div>
        </div>
        
        <!-- 实物商品需要填写收货信息 -->
        <el-form 
          v-if="selectedProduct.category === 'PHYSICAL'" 
          ref="addressFormRef"
          :model="addressForm" 
          :rules="addressRules"
          label-width="80px"
          class="address-form"
        >
          <el-form-item label="收货人" prop="receiverName">
            <el-input v-model="addressForm.receiverName" placeholder="请输入收货人姓名" />
          </el-form-item>
          <el-form-item label="联系电话" prop="receiverPhone">
            <el-input v-model="addressForm.receiverPhone" placeholder="请输入联系电话" />
          </el-form-item>
          <el-form-item label="收货地址" prop="receiverAddress">
            <el-input v-model="addressForm.receiverAddress" type="textarea" placeholder="请输入详细收货地址" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">取消</el-button>
        <el-button 
          type="primary" 
          @click="handleExchange"
          :disabled="!canExchange"
          :loading="exchanging"
        >
          立即兑换
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { getProductList, getMyExchanges, exchangeProduct } from '@/api/shop'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

const userPoints = computed(() => userStore.userInfo?.totalPoints || 0)

const categories = [
  { value: '', name: '全部', icon: '🎁' },
  { value: 'VIRTUAL', name: '虚拟商品', icon: '💎' },
  { value: 'COUPON', name: '优惠券', icon: '🎫' },
  { value: 'PHYSICAL', name: '实物商品', icon: '📦' }
]

const currentCategory = ref('')
const products = ref<any[]>([])
const exchanges = ref<any[]>([])
const pageNum = ref(1)
const pageSize = ref(12)
const total = ref(0)
const showAllExchanges = ref(false)

const detailVisible = ref(false)
const selectedProduct = ref<any>(null)
const exchanging = ref(false)
const addressFormRef = ref<FormInstance>()

const addressForm = ref({
  receiverName: '',
  receiverPhone: '',
  receiverAddress: ''
})

const addressRules: FormRules = {
  receiverName: [{ required: true, message: '请输入收货人姓名', trigger: 'blur' }],
  receiverPhone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  receiverAddress: [{ required: true, message: '请输入收货地址', trigger: 'blur' }]
}

const displayedExchanges = computed(() => {
  return showAllExchanges.value ? exchanges.value : exchanges.value.slice(0, 3)
})

const canExchange = computed(() => {
  if (!selectedProduct.value) return false
  if (userPoints.value < selectedProduct.value.pointsCost) return false
  if (selectedProduct.value.stock === 0) return false
  return true
})

const loadProducts = async () => {
  try {
    const res = await getProductList({
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      category: currentCategory.value || undefined
    })
    products.value = res.records || []
    total.value = res.total || 0
  } catch (e) {
    console.error('加载商品失败:', e)
  }
}

const loadExchanges = async () => {
  try {
    const res = await getMyExchanges()
    exchanges.value = res || []
  } catch (e) {
    console.error('加载兑换记录失败:', e)
  }
}

const showProductDetail = (product: any) => {
  selectedProduct.value = product
  addressForm.value = { receiverName: '', receiverPhone: '', receiverAddress: '' }
  detailVisible.value = true
}

const handleExchange = async () => {
  if (!selectedProduct.value) return

  // 实物商品需要验证地址
  if (selectedProduct.value.category === 'PHYSICAL') {
    const valid = await addressFormRef.value?.validate().catch(() => false)
    if (!valid) return
  }

  try {
    exchanging.value = true
    const data: any = {
      productId: selectedProduct.value.id,
      quantity: 1
    }
    
    if (selectedProduct.value.category === 'PHYSICAL') {
      data.receiverName = addressForm.value.receiverName
      data.receiverPhone = addressForm.value.receiverPhone
      data.receiverAddress = addressForm.value.receiverAddress
    }

    const result = await exchangeProduct(data)
    
    ElMessage.success('兑换成功！')
    detailVisible.value = false
    
    // 刷新数据
    await userStore.fetchUserInfo()
    await loadProducts()
    await loadExchanges()
    
    // 如果是虚拟商品，显示兑换码
    if (result.redeemCode) {
      ElMessage.success(`兑换码：${result.redeemCode}`)
    }
  } catch (e: any) {
    ElMessage.error(e.message || '兑换失败')
  } finally {
    exchanging.value = false
  }
}

const getProductImage = (item: any) => {
  if (item.image || item.productImage) {
    const img = item.image || item.productImage
    if (img.startsWith('http')) return img
    // 静态资源直接从public目录获取，不加/api前缀
    return img
  }
  // 默认图片
  const category = item.category || 'VIRTUAL'
  const defaultImages: Record<string, string> = {
    VIRTUAL: 'https://api.iconify.design/material-symbols:diamond.svg?color=%236366f1',
    COUPON: 'https://api.iconify.design/material-symbols:confirmation-number.svg?color=%23f59e0b',
    PHYSICAL: 'https://api.iconify.design/material-symbols:package-2.svg?color=%2310b981'
  }
  return defaultImages[category] || defaultImages.VIRTUAL
}

const getCategoryName = (category: string) => {
  const names: Record<string, string> = {
    VIRTUAL: '虚拟商品',
    COUPON: '优惠券',
    PHYSICAL: '实物'
  }
  return names[category] || category
}

const getStatusType = (status: string) => {
  const types: Record<string, string> = {
    PENDING: 'warning',
    PROCESSING: 'primary',
    COMPLETED: 'success',
    CANCELLED: 'info'
  }
  return types[status] || 'default'
}

const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    PENDING: '待处理',
    PROCESSING: '处理中',
    COMPLETED: '已完成',
    CANCELLED: '已取消'
  }
  return texts[status] || status
}

const formatDate = (dateStr: string) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleString('zh-CN')
}

const copyCode = (code: string) => {
  navigator.clipboard.writeText(code)
  ElMessage.success('兑换码已复制')
}

// 监听分类变化
import { watch } from 'vue'
watch(currentCategory, () => {
  pageNum.value = 1
  loadProducts()
})

onMounted(() => {
  loadProducts()
  loadExchanges()
})
</script>

<style scoped lang="scss">
.shop-page {
  padding: 24px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8eb 100%);
  min-height: 100vh;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 32px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 20px;
  color: white;

  .header-content {
    h1 {
      font-size: 28px;
      font-weight: 700;
      margin-bottom: 8px;
    }
    p {
      opacity: 0.9;
      font-size: 14px;
    }
  }

  .points-card {
    background: rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(10px);
    padding: 16px 32px;
    border-radius: 16px;
    text-align: center;

    .label {
      display: block;
      font-size: 12px;
      opacity: 0.9;
      margin-bottom: 4px;
    }
    .value {
      font-size: 32px;
      font-weight: 700;
    }
  }
}

.category-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
  padding: 8px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);

  .category-item {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 12px 16px;
    border-radius: 12px;
    cursor: pointer;
    transition: all 0.3s;
    font-weight: 500;

    &:hover {
      background: #f5f7fa;
    }

    &.active {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }

    .icon {
      font-size: 20px;
    }
  }
}

.products-section {
  margin-bottom: 32px;
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 20px;
}

.product-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
  cursor: pointer;
  transition: all 0.3s;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  }

  .product-image {
    position: relative;
    height: 160px;
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    display: flex;
    align-items: center;
    justify-content: center;

    img {
      max-width: 80%;
      max-height: 80%;
      object-fit: contain;
    }

    .category-tag {
      position: absolute;
      top: 12px;
      left: 12px;
      padding: 4px 10px;
      border-radius: 6px;
      font-size: 11px;
      font-weight: 600;

      &.virtual { background: #e0e7ff; color: #4f46e5; }
      &.coupon { background: #fef3c7; color: #d97706; }
      &.physical { background: #d1fae5; color: #059669; }
    }

    .stock-tag {
      position: absolute;
      top: 12px;
      right: 12px;
      padding: 4px 8px;
      background: #fee2e2;
      color: #dc2626;
      border-radius: 6px;
      font-size: 11px;
      font-weight: 600;
    }
  }

  .product-info {
    padding: 16px;

    .product-name {
      font-size: 16px;
      font-weight: 600;
      color: #1f2937;
      margin-bottom: 8px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .product-desc {
      font-size: 13px;
      color: #6b7280;
      line-height: 1.5;
      height: 40px;
      overflow: hidden;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
    }

    .product-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 12px;
      padding-top: 12px;
      border-top: 1px solid #f3f4f6;

      .price {
        .points {
          font-size: 22px;
          font-weight: 700;
          color: #667eea;
        }
        .unit {
          font-size: 12px;
          color: #9ca3af;
          margin-left: 4px;
        }
      }

      .exchanged {
        font-size: 12px;
        color: #9ca3af;
      }
    }
  }
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 24px;
}

.exchanges-section {
  background: white;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;

    h2 {
      font-size: 18px;
      font-weight: 600;
    }
  }
}

.exchanges-list {
  .exchange-item {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px;
    border-radius: 12px;
    background: #f9fafb;
    margin-bottom: 12px;

    &:last-child {
      margin-bottom: 0;
    }

    .exchange-image {
      width: 60px;
      height: 60px;
      border-radius: 10px;
      background: white;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;

      img {
        max-width: 80%;
        max-height: 80%;
        object-fit: contain;
      }
    }

    .exchange-info {
      flex: 1;

      h4 {
        font-size: 15px;
        font-weight: 600;
        margin-bottom: 4px;
      }

      p {
        font-size: 12px;
        color: #6b7280;
        margin: 2px 0;
      }
    }

    .exchange-status {
      text-align: right;

      .points-cost {
        font-size: 14px;
        font-weight: 600;
        color: #667eea;
        margin-top: 8px;
      }
    }

    .exchange-action {
      margin-left: 16px;
    }
  }
}

.product-detail {
  .detail-image {
    height: 200px;
    background: #f9fafb;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 20px;

    img {
      max-width: 80%;
      max-height: 80%;
      object-fit: contain;
    }
  }

  .detail-info {
    .description {
      color: #6b7280;
      line-height: 1.6;
      margin-bottom: 20px;
    }

    .detail-meta {
      display: flex;
      gap: 24px;
      padding: 16px;
      background: #f9fafb;
      border-radius: 12px;

      .meta-item {
        text-align: center;

        .label {
          display: block;
          font-size: 12px;
          color: #9ca3af;
          margin-bottom: 4px;
        }
        .value {
          font-size: 18px;
          font-weight: 600;
          color: #1f2937;

          &.highlight {
            color: #667eea;
          }
        }
      }
    }
  }

  .address-form {
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #f3f4f6;
  }
}
</style>
