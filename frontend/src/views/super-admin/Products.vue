<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Search,
  RefreshCw,
  Plus,
  Edit,
  Trash2,
  ToggleLeft,
  ToggleRight,
  ShoppingBag,
  Package,
  Gift,
  Ticket
} from 'lucide-vue-next'
import request from '@/utils/request'

interface Product {
  id: number
  name: string
  description: string
  image: string
  category: string
  price: number
  stock: number
  exchangeLimit: number
  status: number
  sortOrder: number
  createTime: string
}

// 列表数据
const loading = ref(false)
const products = ref<Product[]>([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  category: '',
  keyword: ''
})

// 弹窗
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref()
const form = reactive({
  id: undefined as number | undefined,
  name: '',
  description: '',
  image: '',
  category: 'VIRTUAL',
  price: 100,
  stock: -1,
  exchangeLimit: 0,
  status: 1,
  sortOrder: 0
})

const formRules = {
  name: [{ required: true, message: '请输入商品名称', trigger: 'blur' }],
  price: [{ required: true, message: '请输入所需积分', trigger: 'blur' }],
  category: [{ required: true, message: '请选择分类', trigger: 'change' }]
}

// 分类选项
const categoryOptions = [
  { label: '全部', value: '' },
  { label: '虚拟商品', value: 'VIRTUAL' },
  { label: '实物商品', value: 'PHYSICAL' },
  { label: '优惠券', value: 'COUPON' }
]

// 加载商品列表
const loadProducts = async () => {
  loading.value = true
  try {
    const params: any = {
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize
    }
    if (queryParams.category) params.category = queryParams.category
    if (queryParams.keyword) params.keyword = queryParams.keyword
    
    const res = await request.get('/shop/products', { params })
    products.value = res.records || []
    total.value = res.total || 0
  } catch (error) {
    console.error('加载商品失败:', error)
  } finally {
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  queryParams.pageNum = 1
  loadProducts()
}

// 重置
const handleReset = () => {
  queryParams.category = ''
  queryParams.keyword = ''
  queryParams.pageNum = 1
  loadProducts()
}

// 打开新增弹窗
const openAddDialog = () => {
  isEdit.value = false
  resetForm()
  dialogVisible.value = true
}

// 打开编辑弹窗
const openEditDialog = (row: Product) => {
  isEdit.value = true
  Object.assign(form, {
    id: row.id,
    name: row.name,
    description: row.description,
    image: row.image,
    category: row.category,
    price: row.price,
    stock: row.stock,
    exchangeLimit: row.exchangeLimit,
    status: row.status,
    sortOrder: row.sortOrder
  })
  dialogVisible.value = true
}

// 重置表单
const resetForm = () => {
  form.id = undefined
  form.name = ''
  form.description = ''
  form.image = ''
  form.category = 'VIRTUAL'
  form.price = 100
  form.stock = -1
  form.exchangeLimit = 0
  form.status = 1
  form.sortOrder = 0
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate()
  
  try {
    if (isEdit.value) {
      await request.put(`/shop/admin/products/${form.id}`, form)
      ElMessage.success('更新成功')
    } else {
      await request.post('/shop/admin/products', form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadProducts()
  } catch (error) {
    console.error('保存失败:', error)
  }
}

// 删除商品
const handleDelete = async (row: Product) => {
  try {
    await ElMessageBox.confirm(`确定删除商品"${row.name}"吗？`, '确认删除', {
      type: 'warning'
    })
    await request.delete(`/shop/admin/products/${row.id}`)
    ElMessage.success('删除成功')
    loadProducts()
  } catch {
    // 取消
  }
}

// 切换上下架
const handleToggle = async (row: Product) => {
  const action = row.status === 1 ? '下架' : '上架'
  try {
    await ElMessageBox.confirm(`确定${action}商品"${row.name}"吗？`, `确认${action}`, {
      type: 'warning'
    })
    await request.put(`/shop/admin/products/${row.id}/toggle`)
    ElMessage.success(`${action}成功`)
    loadProducts()
  } catch {
    // 取消
  }
}

// 获取分类名称
const getCategoryName = (category: string) => {
  const map: Record<string, string> = {
    VIRTUAL: '虚拟商品',
    PHYSICAL: '实物商品',
    COUPON: '优惠券'
  }
  return map[category] || category
}

// 获取分类图标
const getCategoryIcon = (category: string) => {
  const map: Record<string, any> = {
    VIRTUAL: Gift,
    PHYSICAL: Package,
    COUPON: Ticket
  }
  return map[category] || ShoppingBag
}

onMounted(() => {
  loadProducts()
})
</script>

<template>
  <div class="products-page">
    <div class="page-header">
      <h2><ShoppingBag :size="24" /> 商品管理</h2>
      <p>管理积分商城的商品</p>
    </div>
    
    <!-- 搜索栏 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="分类">
          <el-select v-model="queryParams.category" placeholder="全部" clearable style="width: 140px">
            <el-option
              v-for="opt in categoryOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input
            v-model="queryParams.keyword"
            placeholder="商品名称"
            clearable
            @keyup.enter="handleSearch"
            style="width: 180px"
          />
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
          <span>商品列表</span>
          <el-button type="primary" @click="openAddDialog">
            <Plus :size="16" class="mr-1" />
            新增商品
          </el-button>
        </div>
      </template>
      
      <el-table :data="products" v-loading="loading" stripe table-layout="fixed">
        <el-table-column label="商品" width="280">
          <template #default="{ row }">
            <div class="product-cell">
              <el-image
                v-if="row.image"
                :src="row.image"
                fit="cover"
                class="product-image"
              >
                <template #error>
                  <div class="image-placeholder">
                    <component :is="getCategoryIcon(row.category)" :size="24" />
                  </div>
                </template>
              </el-image>
              <div v-else class="image-placeholder">
                <component :is="getCategoryIcon(row.category)" :size="24" />
              </div>
              <div class="product-info">
                <div class="product-name">{{ row.name }}</div>
                <div class="product-desc">{{ row.description || '-' }}</div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="分类" width="110" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="row.category === 'PHYSICAL' ? 'warning' : row.category === 'COUPON' ? 'success' : ''">
              {{ getCategoryName(row.category) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="积分" width="100" align="center">
          <template #default="{ row }">
            <span class="price">{{ row.price }}</span>
          </template>
        </el-table-column>
        <el-table-column label="库存" width="100" align="center">
          <template #default="{ row }">
            <span v-if="row.stock < 0" class="text-muted">不限</span>
            <span v-else :class="{ 'text-danger': row.stock === 0 }">{{ row.stock }}</span>
          </template>
        </el-table-column>
        <el-table-column label="限购" width="80" align="center">
          <template #default="{ row }">
            <span v-if="!row.exchangeLimit" class="text-muted">不限</span>
            <span v-else>{{ row.exchangeLimit }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '上架中' : '已下架' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" show-overflow-tooltip />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="openEditDialog(row)">
              <Edit :size="14" />
              编辑
            </el-button>
            <el-button link :type="row.status === 1 ? 'warning' : 'success'" size="small" @click="handleToggle(row)">
              <ToggleLeft v-if="row.status === 1" :size="14" />
              <ToggleRight v-else :size="14" />
              {{ row.status === 1 ? '下架' : '上架' }}
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">
              <Trash2 :size="14" />
              删除
            </el-button>
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
          @current-change="(page: number) => { queryParams.pageNum = page; loadProducts() }"
        />
      </div>
    </el-card>
    
    <!-- 编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑商品' : '新增商品'"
      width="600px"
    >
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="24">
            <el-form-item label="商品名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入商品名称" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="商品描述">
              <el-input
                v-model="form.description"
                type="textarea"
                :rows="2"
                placeholder="请输入商品描述"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分类" prop="category">
              <el-select v-model="form.category" style="width: 100%">
                <el-option label="虚拟商品" value="VIRTUAL" />
                <el-option label="实物商品" value="PHYSICAL" />
                <el-option label="优惠券" value="COUPON" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所需积分" prop="price">
              <el-input-number v-model="form.price" :min="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="库存">
              <el-input-number v-model="form.stock" :min="-1" style="width: 100%" />
              <div class="form-tip">-1表示不限库存</div>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="限购数量">
              <el-input-number v-model="form.exchangeLimit" :min="0" style="width: 100%" />
              <div class="form-tip">0表示不限购</div>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="商品图片">
              <el-input v-model="form.image" placeholder="请输入图片URL" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序">
              <el-input-number v-model="form.sortOrder" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态">
              <el-switch
                v-model="form.status"
                :active-value="1"
                :inactive-value="0"
                active-text="上架"
                inactive-text="下架"
              />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
@import '@/styles/variables.scss';

.products-page {
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
  
  .product-cell {
    display: flex;
    align-items: center;
    gap: 12px;
    
    .product-image, .image-placeholder {
      width: 50px;
      height: 50px;
      border-radius: $radius-sm;
      flex-shrink: 0;
    }
    
    .image-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      background: $bg-secondary;
      color: $text-muted;
    }
    
    .product-info {
      overflow: hidden;
    }
    
    .product-name {
      font-weight: 500;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    
    .product-desc {
      font-size: 12px;
      color: $text-muted;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
  }
  
  .price {
    font-weight: 600;
    color: $primary;
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
  
  .text-danger {
    color: $danger;
  }
  
  .form-tip {
    font-size: 12px;
    color: $text-muted;
    margin-top: 4px;
  }
}
</style>
