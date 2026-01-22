<template>
  <div class="shop-manage">
    <el-tabs v-model="activeTab" type="border-card">
      <!-- 商品管理 -->
      <el-tab-pane label="商品管理" name="products">
        <div class="toolbar">
          <el-button type="primary" @click="showProductDialog()">
            <el-icon><Plus /></el-icon> 添加商品
          </el-button>
          <el-select v-model="productFilter.category" placeholder="商品分类" clearable style="width: 140px">
            <el-option label="虚拟商品" value="VIRTUAL" />
            <el-option label="优惠券" value="COUPON" />
            <el-option label="实物商品" value="PHYSICAL" />
          </el-select>
        </div>

        <el-table :data="products" v-loading="loading" stripe>
          <el-table-column prop="id" label="ID" width="60" />
          <el-table-column label="商品图片" width="80">
            <template #default="{ row }">
              <el-image 
                :src="getProductImage(row)" 
                style="width: 50px; height: 50px"
                fit="contain"
              />
            </template>
          </el-table-column>
          <el-table-column prop="name" label="商品名称" min-width="150" />
          <el-table-column prop="category" label="分类" width="100">
            <template #default="{ row }">
              <el-tag :type="getCategoryType(row.category)" size="small">
                {{ getCategoryName(row.category) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="pointsCost" label="积分" width="80" />
          <el-table-column label="库存" width="80">
            <template #default="{ row }">
              {{ row.stock === -1 ? '无限' : row.stock }}
            </template>
          </el-table-column>
          <el-table-column prop="exchangedCount" label="已兑" width="70" />
          <el-table-column prop="status" label="状态" width="80">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
                {{ row.status === 1 ? '上架' : '下架' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button text size="small" @click="showProductDialog(row)">编辑</el-button>
              <el-button text size="small" :type="row.status === 1 ? 'warning' : 'success'" @click="toggleStatus(row)">
                {{ row.status === 1 ? '下架' : '上架' }}
              </el-button>
              <el-popconfirm title="确定删除该商品？" @confirm="deleteProduct(row.id)">
                <template #reference>
                  <el-button text size="small" type="danger">删除</el-button>
                </template>
              </el-popconfirm>
            </template>
          </el-table-column>
        </el-table>

        <el-pagination
          v-model:current-page="productPagination.pageNum"
          v-model:page-size="productPagination.pageSize"
          :total="productPagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @current-change="loadProducts"
          @size-change="loadProducts"
          style="margin-top: 16px"
        />
      </el-tab-pane>

      <!-- 兑换订单 -->
      <el-tab-pane label="兑换订单" name="exchanges">
        <div class="toolbar">
          <el-select v-model="exchangeFilter.status" placeholder="订单状态" clearable style="width: 140px" @change="loadExchanges">
            <el-option label="待处理" value="PENDING" />
            <el-option label="处理中" value="PROCESSING" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
        </div>

        <el-table :data="exchanges" v-loading="exchangeLoading" stripe>
          <el-table-column prop="exchangeNo" label="订单号" width="160" />
          <el-table-column prop="productName" label="商品名称" min-width="150" />
          <el-table-column prop="pointsCost" label="消耗积分" width="90" />
          <el-table-column prop="quantity" label="数量" width="70" />
          <el-table-column prop="status" label="状态" width="90">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.status)" size="small">
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="收货信息" min-width="200">
            <template #default="{ row }">
              <div v-if="row.receiverName">
                {{ row.receiverName }} / {{ row.receiverPhone }}<br/>
                <span class="text-muted">{{ row.receiverAddress }}</span>
              </div>
              <span v-else class="text-muted">虚拟商品</span>
            </template>
          </el-table-column>
          <el-table-column prop="redeemCode" label="兑换码" width="140">
            <template #default="{ row }">
              {{ row.redeemCode || '-' }}
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="创建时间" width="160">
            <template #default="{ row }">
              {{ formatDate(row.createTime) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="150" fixed="right">
            <template #default="{ row }">
              <template v-if="row.status === 'PENDING'">
                <el-button text size="small" type="primary" @click="processOrder(row)">发货</el-button>
                <el-button text size="small" type="danger" @click="cancelOrder(row)">取消</el-button>
              </template>
              <template v-else-if="row.status === 'PROCESSING'">
                <el-button text size="small" type="success" @click="completeOrder(row)">完成</el-button>
              </template>
              <span v-else class="text-muted">-</span>
            </template>
          </el-table-column>
        </el-table>

        <el-pagination
          v-model:current-page="exchangePagination.pageNum"
          v-model:page-size="exchangePagination.pageSize"
          :total="exchangePagination.total"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @current-change="loadExchanges"
          @size-change="loadExchanges"
          style="margin-top: 16px"
        />
      </el-tab-pane>
    </el-tabs>

    <!-- 商品编辑弹窗 -->
    <el-dialog v-model="productDialogVisible" :title="editingProduct ? '编辑商品' : '添加商品'" width="600px">
      <el-form ref="productFormRef" :model="productForm" :rules="productRules" label-width="100px">
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="productForm.name" placeholder="请输入商品名称" />
        </el-form-item>
        <el-form-item label="商品分类" prop="category">
          <el-select v-model="productForm.category" style="width: 100%">
            <el-option label="虚拟商品" value="VIRTUAL" />
            <el-option label="优惠券" value="COUPON" />
            <el-option label="实物商品" value="PHYSICAL" />
          </el-select>
        </el-form-item>
        <el-form-item label="所需积分" prop="pointsCost">
          <el-input-number v-model="productForm.pointsCost" :min="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="库存数量" prop="stock">
          <el-input-number v-model="productForm.stock" :min="-1" style="width: 100%" />
          <div class="form-tip">-1 表示无限库存</div>
        </el-form-item>
        <el-form-item label="限兑数量" prop="limitPerUser">
          <el-input-number v-model="productForm.limitPerUser" :min="0" style="width: 100%" />
          <div class="form-tip">0 表示不限制</div>
        </el-form-item>
        <el-form-item label="商品描述" prop="description">
          <el-input v-model="productForm.description" type="textarea" :rows="3" placeholder="请输入商品描述" />
        </el-form-item>
        <el-form-item label="商品图片" prop="image">
          <el-input v-model="productForm.image" placeholder="请输入图片URL" />
        </el-form-item>
        <el-form-item label="排序权重" prop="sortOrder">
          <el-input-number v-model="productForm.sortOrder" :min="0" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="productDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveProduct" :loading="saving">保存</el-button>
      </template>
    </el-dialog>

    <!-- 发货弹窗 -->
    <el-dialog v-model="shipDialogVisible" title="发货" width="400px">
      <el-form :model="shipForm" label-width="80px">
        <el-form-item label="物流单号">
          <el-input v-model="shipForm.trackingNo" placeholder="请输入物流单号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="shipDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmShip" :loading="shipping">确认发货</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { 
  getProductList, 
  adminGetExchanges, 
  adminCreateProduct, 
  adminUpdateProduct, 
  adminDeleteProduct, 
  adminToggleProduct,
  adminProcessExchange,
  adminCompleteExchange,
  adminCancelExchange
} from '@/api/shop'

const activeTab = ref('products')
const loading = ref(false)
const exchangeLoading = ref(false)
const saving = ref(false)
const shipping = ref(false)

// 商品相关
const products = ref<any[]>([])
const productFilter = reactive({ category: '' })
const productPagination = reactive({ pageNum: 1, pageSize: 20, total: 0 })
const productDialogVisible = ref(false)
const editingProduct = ref<any>(null)
const productFormRef = ref<FormInstance>()
const productForm = reactive({
  name: '',
  category: 'VIRTUAL',
  pointsCost: 100,
  stock: -1,
  limitPerUser: 0,
  description: '',
  image: '',
  sortOrder: 0
})
const productRules: FormRules = {
  name: [{ required: true, message: '请输入商品名称', trigger: 'blur' }],
  category: [{ required: true, message: '请选择商品分类', trigger: 'change' }],
  pointsCost: [{ required: true, message: '请输入所需积分', trigger: 'blur' }]
}

// 兑换相关
const exchanges = ref<any[]>([])
const exchangeFilter = reactive({ status: '' })
const exchangePagination = reactive({ pageNum: 1, pageSize: 20, total: 0 })
const shipDialogVisible = ref(false)
const shipForm = reactive({ trackingNo: '' })
const currentExchange = ref<any>(null)

const loadProducts = async () => {
  loading.value = true
  try {
    const res = await getProductList({
      pageNum: productPagination.pageNum,
      pageSize: productPagination.pageSize,
      category: productFilter.category || undefined
    })
    products.value = res.records || []
    productPagination.total = res.total || 0
  } catch (e) {
    console.error('加载商品失败:', e)
  } finally {
    loading.value = false
  }
}

const loadExchanges = async () => {
  exchangeLoading.value = true
  try {
    const res = await adminGetExchanges({
      pageNum: exchangePagination.pageNum,
      pageSize: exchangePagination.pageSize,
      status: exchangeFilter.status || undefined
    })
    exchanges.value = res.records || []
    exchangePagination.total = res.total || 0
  } catch (e) {
    console.error('加载兑换记录失败:', e)
  } finally {
    exchangeLoading.value = false
  }
}

const showProductDialog = (product?: any) => {
  editingProduct.value = product
  if (product) {
    Object.assign(productForm, product)
  } else {
    Object.assign(productForm, {
      name: '',
      category: 'VIRTUAL',
      pointsCost: 100,
      stock: -1,
      limitPerUser: 0,
      description: '',
      image: '',
      sortOrder: 0
    })
  }
  productDialogVisible.value = true
}

const saveProduct = async () => {
  const valid = await productFormRef.value?.validate().catch(() => false)
  if (!valid) return

  saving.value = true
  try {
    if (editingProduct.value) {
      await adminUpdateProduct(editingProduct.value.id, productForm)
      ElMessage.success('更新成功')
    } else {
      await adminCreateProduct(productForm)
      ElMessage.success('添加成功')
    }
    productDialogVisible.value = false
    loadProducts()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  } finally {
    saving.value = false
  }
}

const toggleStatus = async (product: any) => {
  try {
    await adminToggleProduct(product.id)
    ElMessage.success(product.status === 1 ? '已下架' : '已上架')
    loadProducts()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

const deleteProduct = async (id: number) => {
  try {
    await adminDeleteProduct(id)
    ElMessage.success('删除成功')
    loadProducts()
  } catch (e: any) {
    ElMessage.error(e.message || '删除失败')
  }
}

const processOrder = (exchange: any) => {
  currentExchange.value = exchange
  shipForm.trackingNo = ''
  shipDialogVisible.value = true
}

const confirmShip = async () => {
  if (!currentExchange.value) return
  shipping.value = true
  try {
    await adminProcessExchange(currentExchange.value.id, shipForm.trackingNo)
    ElMessage.success('发货成功')
    shipDialogVisible.value = false
    loadExchanges()
  } catch (e: any) {
    ElMessage.error(e.message || '发货失败')
  } finally {
    shipping.value = false
  }
}

const completeOrder = async (exchange: any) => {
  try {
    await adminCompleteExchange(exchange.id)
    ElMessage.success('订单已完成')
    loadExchanges()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

const cancelOrder = async (exchange: any) => {
  try {
    await adminCancelExchange(exchange.id, '管理员取消')
    ElMessage.success('订单已取消')
    loadExchanges()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

const getProductImage = (product: any) => {
  if (product.image) {
    if (product.image.startsWith('http')) return product.image
    // 静态资源直接从public目录获取，不加/api前缀
    return product.image
  }
  return 'https://api.iconify.design/material-symbols:package-2.svg?color=%236b7280'
}

const getCategoryType = (category: string) => {
  const types: Record<string, string> = {
    VIRTUAL: 'primary',
    COUPON: 'warning',
    PHYSICAL: 'success'
  }
  return types[category] || 'default'
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

watch(() => productFilter.category, () => {
  productPagination.pageNum = 1
  loadProducts()
})

watch(activeTab, (val) => {
  if (val === 'products') loadProducts()
  else if (val === 'exchanges') loadExchanges()
})

onMounted(() => {
  loadProducts()
})
</script>

<style scoped lang="scss">
.shop-manage {
  padding: 20px;

  .toolbar {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;
  }

  .text-muted {
    color: #9ca3af;
    font-size: 12px;
  }

  .form-tip {
    font-size: 12px;
    color: #9ca3af;
    margin-top: 4px;
  }
}
</style>
