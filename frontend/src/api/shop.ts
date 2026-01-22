import request from '@/utils/request'

// 商品相关
export const getProductList = (params: {
  pageNum?: number
  pageSize?: number
  category?: string
  keyword?: string
}) => {
  return request.get('/shop/products', { params })
}

export const getProductDetail = (id: number) => {
  return request.get(`/shop/products/${id}`)
}

// 兑换相关
export const exchangeProduct = (data: {
  productId: number
  quantity?: number
  receiverName?: string
  receiverPhone?: string
  receiverAddress?: string
}) => {
  return request.post('/shop/exchange', data)
}

export const getMyExchanges = () => {
  return request.get('/shop/exchanges')
}

// 管理端接口
export const adminGetExchanges = (params: {
  pageNum?: number
  pageSize?: number
  status?: string
}) => {
  return request.get('/shop/admin/exchanges', { params })
}

export const adminCreateProduct = (data: any) => {
  return request.post('/shop/admin/products', data)
}

export const adminUpdateProduct = (id: number, data: any) => {
  return request.put(`/shop/admin/products/${id}`, data)
}

export const adminDeleteProduct = (id: number) => {
  return request.delete(`/shop/admin/products/${id}`)
}

export const adminToggleProduct = (id: number) => {
  return request.put(`/shop/admin/products/${id}/toggle`)
}

export const adminProcessExchange = (id: number, trackingNo: string) => {
  return request.put(`/shop/admin/exchanges/${id}/process`, { trackingNo })
}

export const adminCompleteExchange = (id: number) => {
  return request.put(`/shop/admin/exchanges/${id}/complete`)
}

export const adminCancelExchange = (id: number, reason: string) => {
  return request.put(`/shop/admin/exchanges/${id}/cancel`, { reason })
}
