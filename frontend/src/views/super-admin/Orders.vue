<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Search,
  RefreshCw,
  Package,
  Truck,
  CheckCircle,
  XCircle,
  Clock,
  ShoppingCart
} from 'lucide-vue-next'
import request from '@/utils/request'

interface Exchange {
  id: number
  userId: number
  productId: number
  productName: string
  productImage: string
  quantity: number
  totalPoints: number
  status: string
  receiverName: string
  receiverPhone: string
  receiverAddress: string
  trackingNo: string
  createTime: string
  processTime: string
  completeTime: string
  cancelTime: string
  cancelReason: string
  user?: {
    username: string
    realName: string
  }
}

// 列表数据
const loading = ref(false)
const orders = ref<Exchange[]>([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  status: ''
})

// 状态选项
const statusOptions = [
  { label: '全部', value: '' },
  { label: '待处理', value: 'PENDING' },
  { label: '处理中', value: 'PROCESSING' },
  { label: '已完成', value: 'COMPLETED' },
  { label: '已取消', value: 'CANCELLED' }
]

// 加载订单列表
const loadOrders = async () => {
  loading.value = true
  try {
    const params: any = {
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize
    }
    if (queryParams.status) params.status = queryParams.status
    
    const res = await request.get('/shop/admin/exchanges', { params })
    orders.value = res.records || []
    total.value = res.total || 0
  } catch (error) {
    console.error('加载订单失败:', error)
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  queryParams.pageNum = 1
  loadOrders()
}

// 重置
const handleReset = () => {
  queryParams.status = ''
  queryParams.pageNum = 1
  loadOrders()
}

// 处理订单（发货）
const handleProcess = async (row: Exchange) => {
  try {
    const { value } = await ElMessageBox.prompt('请输入物流单号（可选）', '处理订单', {
      confirmButtonText: '确认发货',
      cancelButtonText: '取消',
      inputPlaceholder: '物流单号...'
    })
    await request.put(`/shop/admin/exchanges/${row.id}/process`, {
      trackingNo: value || ''
    })
    ElMessage.success('订单已发货')
    loadOrders()
  } catch {
    // 取消
  }
}

// 完成订单
const handleComplete = async (row: Exchange) => {
  try {
    await ElMessageBox.confirm('确定将此订单标记为已完成吗？', '确认完成', {
      type: 'warning'
    })
    await request.put(`/shop/admin/exchanges/${row.id}/complete`)
    ElMessage.success('订单已完成')
    loadOrders()
  } catch {
    // 取消
  }
}

// 取消订单
const handleCancel = async (row: Exchange) => {
  try {
    const { value } = await ElMessageBox.prompt('请输入取消原因', '取消订单', {
      confirmButtonText: '确认取消',
      cancelButtonText: '返回',
      inputPlaceholder: '取消原因...',
      inputValidator: (val) => !!val?.trim() || '请输入取消原因'
    })
    await request.put(`/shop/admin/exchanges/${row.id}/cancel`, {
      reason: value
    })
    ElMessage.success('订单已取消')
    loadOrders()
  } catch {
    // 取消
  }
}

// 获取状态标签
const getStatusTag = (status: string) => {
  const map: Record<string, { type: string; text: string; icon: any }> = {
    PENDING: { type: 'warning', text: '待处理', icon: Clock },
    PROCESSING: { type: 'primary', text: '处理中', icon: Truck },
    COMPLETED: { type: 'success', text: '已完成', icon: CheckCircle },
    CANCELLED: { type: 'info', text: '已取消', icon: XCircle }
  }
  return map[status] || { type: 'info', text: status, icon: Package }
}

onMounted(() => {
  loadOrders()
})
</script>

<template>
  <div class="orders-page">
    <div class="page-header">
      <h2><ShoppingCart :size="24" /> 订单管理</h2>
      <p>管理积分商城兑换订单</p>
    </div>
    
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 140px">
            <el-option
              v-for="opt in statusOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <Search :size="16" class="mr-1" />
            搜索
          </el-button>
          <el-button @click="handleReset">
            <RefreshCw :size="16" class="mr-1" />
            重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <!-- 表格 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>兑换订单列表</span>
        </div>
      </template>
      
      <el-table :data="orders" v-loading="loading" stripe table-layout="fixed">
        <el-table-column label="订单信息" width="200">
          <template #default="{ row }">
            <div class="order-info">
              <div class="order-id">#{{ row.id }}</div>
              <div class="order-time">{{ row.createTime }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="用户" width="140">
          <template #default="{ row }">
            <div v-if="row.user">
              <div>{{ row.user.realName || row.user.username }}</div>
            </div>
            <span v-else>用户ID: {{ row.userId }}</span>
          </template>
        </el-table-column>
        <el-table-column label="商品" min-width="180">
          <template #default="{ row }">
            <div class="product-info">
              <div class="product-name">{{ row.productName }}</div>
              <div class="product-qty">× {{ row.quantity }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="积分" width="90" align="center">
          <template #default="{ row }">
            <span class="points">{{ row.totalPoints }}</span>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" width="180" show-overflow-tooltip>
          <template #default="{ row }">
            <div v-if="row.receiverName" class="receiver-info">
              <div>{{ row.receiverName }} {{ row.receiverPhone }}</div>
              <div class="address">{{ row.receiverAddress || '-' }}</div>
            </div>
            <span v-else class="text-muted">虚拟商品</span>
          </template>
        </el-table-column>
        <el-table-column label="物流" width="120" show-overflow-tooltip>
          <template #default="{ row }">
            <span v-if="row.trackingNo">{{ row.trackingNo }}</span>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status).type" size="small">
              <component :is="getStatusTag(row.status).icon" :size="12" class="mr-1" />
              {{ getStatusTag(row.status).text }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <template v-if="row.status === 'PENDING'">
              <el-button link type="primary" size="small" @click="handleProcess(row)">
                <Truck :size="14" />
                发货
              </el-button>
              <el-button link type="danger" size="small" @click="handleCancel(row)">
                <XCircle :size="14" />
                取消
              </el-button>
            </template>
            <template v-else-if="row.status === 'PROCESSING'">
              <el-button link type="success" size="small" @click="handleComplete(row)">
                <CheckCircle :size="14" />
                完成
              </el-button>
            </template>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination">
        <el-pagination
          background
          layout="total, prev, pager, next"
          :total="total"
          :page-size="queryParams.pageSize"
          :current-page="queryParams.pageNum"
          @current-change="(page: number) => { queryParams.pageNum = page; loadOrders() }"
        />
      </div>
    </el-card>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.orders-page {
  .page-header {
    margin-bottom: $spacing-4;
    
    h2 {
      display: flex;
      align-items: center;
      gap: 8px;
      margin: 0 0 4px;
      font-size: 20px;
      color: $text-primary;
    }
    
    p {
      margin: 0;
      color: $text-muted;
      font-size: 14px;
    }
  }
  
  .search-card {
    margin-bottom: $spacing-4;
  }
  
  .table-card {
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
  }
  
  .order-info {
    .order-id {
      font-weight: 600;
      color: $primary;
    }
    
    .order-time {
      font-size: 12px;
      color: $text-muted;
    }
  }
  
  .product-info {
    .product-name {
      font-weight: 500;
    }
    
    .product-qty {
      font-size: 12px;
      color: $text-muted;
    }
  }
  
  .receiver-info {
    .address {
      font-size: 12px;
      color: $text-muted;
    }
  }
  
  .points {
    font-weight: 600;
    color: $warning;
  }
  
  .pagination {
    margin-top: $spacing-4;
    display: flex;
    justify-content: flex-end;
  }
  
  .mr-1 {
    margin-right: $spacing-1;
  }
  
  .text-muted {
    color: $text-muted;
  }
}
</style>
