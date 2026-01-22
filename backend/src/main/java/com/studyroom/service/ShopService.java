package com.studyroom.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.exception.BusinessException;
import com.studyroom.entity.PointExchange;
import com.studyroom.entity.PointProduct;
import com.studyroom.entity.User;
import com.studyroom.mapper.PointExchangeMapper;
import com.studyroom.mapper.PointProductMapper;
import com.studyroom.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 积分商城服务
 */
@Service
@RequiredArgsConstructor
public class ShopService {

    private final PointProductMapper productMapper;
    private final PointExchangeMapper exchangeMapper;
    private final UserMapper userMapper;

    /**
     * 获取商品列表
     */
    public IPage<PointProduct> getProductList(int pageNum, int pageSize, String category, String keyword) {
        Page<PointProduct> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<PointProduct> wrapper = new LambdaQueryWrapper<>();
        
        wrapper.eq(PointProduct::getStatus, 1)
               .eq(PointProduct::getDeleted, 0);
        
        if (StringUtils.hasText(category)) {
            wrapper.eq(PointProduct::getCategory, category);
        }
        
        if (StringUtils.hasText(keyword)) {
            wrapper.like(PointProduct::getName, keyword);
        }
        
        // 检查时间有效性
        LocalDateTime now = LocalDateTime.now();
        wrapper.and(w -> w.isNull(PointProduct::getStartTime).or().le(PointProduct::getStartTime, now));
        wrapper.and(w -> w.isNull(PointProduct::getEndTime).or().ge(PointProduct::getEndTime, now));
        
        wrapper.orderByAsc(PointProduct::getSortOrder)
               .orderByDesc(PointProduct::getCreateTime);
        
        return productMapper.selectPage(page, wrapper);
    }

    /**
     * 获取商品详情
     */
    public PointProduct getProductDetail(Long productId) {
        PointProduct product = productMapper.selectById(productId);
        if (product == null || product.getDeleted() == 1) {
            throw new BusinessException("商品不存在");
        }
        return product;
    }

    /**
     * 兑换商品
     */
    @Transactional(rollbackFor = Exception.class)
    public PointExchange exchangeProduct(Long userId, Long productId, int quantity, 
                                         String receiverName, String receiverPhone, String receiverAddress) {
        // 验证商品
        PointProduct product = productMapper.selectById(productId);
        if (product == null || !product.isAvailable()) {
            throw new BusinessException("商品不可兑换");
        }

        // 验证库存
        if (product.getStock() != -1 && product.getStock() < quantity) {
            throw new BusinessException("库存不足");
        }

        // 验证用户限兑
        if (product.getLimitPerUser() != null && product.getLimitPerUser() > 0) {
            int exchanged = exchangeMapper.countUserExchanged(userId, productId);
            if (exchanged + quantity > product.getLimitPerUser()) {
                throw new BusinessException("超出个人限兑数量");
            }
        }

        // 验证用户积分
        User user = userMapper.selectById(userId);
        int totalCost = product.getPointsCost() * quantity;
        if (user.getTotalPoints() < totalCost) {
            throw new BusinessException("积分不足");
        }

        // 扣除积分
        user.setTotalPoints(user.getTotalPoints() - totalCost);
        userMapper.updateById(user);

        // 扣减库存
        if (product.getStock() != -1) {
            product.setStock(product.getStock() - quantity);
        }
        product.setExchangedCount(product.getExchangedCount() + quantity);
        productMapper.updateById(product);

        // 创建兑换记录
        PointExchange exchange = PointExchange.create(userId, product, quantity);
        exchange.setReceiverName(receiverName);
        exchange.setReceiverPhone(receiverPhone);
        exchange.setReceiverAddress(receiverAddress);
        
        // 虚拟商品自动完成
        if ("VIRTUAL".equals(product.getCategory()) || "COUPON".equals(product.getCategory())) {
            exchange.setStatus(PointExchange.Status.COMPLETED.name());
            exchange.setRedeemCode(generateRedeemCode());
            exchange.setCompleteTime(LocalDateTime.now());
        }
        
        exchangeMapper.insert(exchange);
        
        return exchange;
    }

    /**
     * 获取用户兑换记录
     */
    public List<PointExchange> getUserExchanges(Long userId) {
        return exchangeMapper.selectByUserId(userId);
    }

    /**
     * 获取所有兑换记录(管理端)
     */
    public IPage<PointExchange> getAllExchanges(int pageNum, int pageSize, String status) {
        Page<PointExchange> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<PointExchange> wrapper = new LambdaQueryWrapper<>();
        
        if (StringUtils.hasText(status)) {
            wrapper.eq(PointExchange::getStatus, status);
        }
        
        wrapper.orderByDesc(PointExchange::getCreateTime);
        
        return exchangeMapper.selectPage(page, wrapper);
    }

    /**
     * 处理兑换订单
     */
    @Transactional(rollbackFor = Exception.class)
    public void processExchange(Long exchangeId, String trackingNo) {
        PointExchange exchange = exchangeMapper.selectById(exchangeId);
        if (exchange == null) {
            throw new BusinessException("兑换记录不存在");
        }
        
        if (!"PENDING".equals(exchange.getStatus())) {
            throw new BusinessException("该订单状态不可处理");
        }
        
        exchange.setStatus(PointExchange.Status.PROCESSING.name());
        exchange.setTrackingNo(trackingNo);
        exchange.setProcessTime(LocalDateTime.now());
        exchangeMapper.updateById(exchange);
    }

    /**
     * 完成兑换订单
     */
    @Transactional(rollbackFor = Exception.class)
    public void completeExchange(Long exchangeId) {
        PointExchange exchange = exchangeMapper.selectById(exchangeId);
        if (exchange == null) {
            throw new BusinessException("兑换记录不存在");
        }
        
        exchange.setStatus(PointExchange.Status.COMPLETED.name());
        exchange.setCompleteTime(LocalDateTime.now());
        exchangeMapper.updateById(exchange);
    }

    /**
     * 取消兑换订单(退还积分)
     */
    @Transactional(rollbackFor = Exception.class)
    public void cancelExchange(Long exchangeId, String reason) {
        PointExchange exchange = exchangeMapper.selectById(exchangeId);
        if (exchange == null) {
            throw new BusinessException("兑换记录不存在");
        }
        
        if ("COMPLETED".equals(exchange.getStatus())) {
            throw new BusinessException("已完成的订单不可取消");
        }
        
        // 退还积分
        User user = userMapper.selectById(exchange.getUserId());
        user.setTotalPoints(user.getTotalPoints() + exchange.getPointsCost());
        userMapper.updateById(user);
        
        // 恢复库存
        PointProduct product = productMapper.selectById(exchange.getProductId());
        if (product != null && product.getStock() != -1) {
            product.setStock(product.getStock() + exchange.getQuantity());
            product.setExchangedCount(product.getExchangedCount() - exchange.getQuantity());
            productMapper.updateById(product);
        }
        
        exchange.setStatus(PointExchange.Status.CANCELLED.name());
        exchange.setRemark(reason);
        exchangeMapper.updateById(exchange);
    }

    /**
     * 生成兑换码
     */
    private String generateRedeemCode() {
        StringBuilder sb = new StringBuilder();
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        for (int i = 0; i < 12; i++) {
            if (i > 0 && i % 4 == 0) sb.append("-");
            sb.append(chars.charAt((int)(Math.random() * chars.length())));
        }
        return sb.toString();
    }

    // ========== 管理端商品CRUD ==========
    
    /**
     * 创建商品
     */
    public PointProduct createProduct(PointProduct product) {
        product.setExchangedCount(0);
        product.setDeleted(0);
        productMapper.insert(product);
        return product;
    }

    /**
     * 更新商品
     */
    public void updateProduct(PointProduct product) {
        productMapper.updateById(product);
    }

    /**
     * 删除商品
     */
    public void deleteProduct(Long productId) {
        PointProduct product = productMapper.selectById(productId);
        if (product != null) {
            product.setDeleted(1);
            productMapper.updateById(product);
        }
    }

    /**
     * 上下架商品
     */
    public void toggleProductStatus(Long productId) {
        PointProduct product = productMapper.selectById(productId);
        if (product != null) {
            product.setStatus(product.getStatus() == 1 ? 0 : 1);
            productMapper.updateById(product);
        }
    }
}
