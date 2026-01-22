package com.studyroom.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.studyroom.common.Result;
import com.studyroom.entity.PointExchange;
import com.studyroom.entity.PointProduct;
import com.studyroom.service.ShopService;
import com.studyroom.security.SecurityUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 积分商城控制器
 */
@Tag(name = "积分商城", description = "积分商城相关接口")
@RestController
@RequestMapping("/shop")
@RequiredArgsConstructor
public class ShopController {

    private final ShopService shopService;

    @Operation(summary = "获取商品列表")
    @GetMapping("/products")
    public Result<IPage<PointProduct>> getProductList(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "12") int pageSize,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword) {
        return Result.success(shopService.getProductList(pageNum, pageSize, category, keyword));
    }

    @Operation(summary = "获取商品详情")
    @GetMapping("/products/{id}")
    public Result<PointProduct> getProductDetail(@PathVariable Long id) {
        return Result.success(shopService.getProductDetail(id));
    }

    @Operation(summary = "兑换商品")
    @PostMapping("/exchange")
    public Result<PointExchange> exchangeProduct(@RequestBody Map<String, Object> params) {
        Long userId = SecurityUtil.getCurrentUserId();
        Long productId = Long.valueOf(params.get("productId").toString());
        int quantity = params.get("quantity") != null ? Integer.parseInt(params.get("quantity").toString()) : 1;
        String receiverName = (String) params.get("receiverName");
        String receiverPhone = (String) params.get("receiverPhone");
        String receiverAddress = (String) params.get("receiverAddress");
        
        PointExchange exchange = shopService.exchangeProduct(userId, productId, quantity, 
                receiverName, receiverPhone, receiverAddress);
        return Result.success(exchange);
    }

    @Operation(summary = "获取我的兑换记录")
    @GetMapping("/exchanges")
    public Result<List<PointExchange>> getMyExchanges() {
        Long userId = SecurityUtil.getCurrentUserId();
        return Result.success(shopService.getUserExchanges(userId));
    }

    // ========== 管理端接口 ==========

    @Operation(summary = "获取所有兑换记录(管理端)")
    @GetMapping("/admin/exchanges")
    public Result<IPage<PointExchange>> getAllExchanges(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String status) {
        return Result.success(shopService.getAllExchanges(pageNum, pageSize, status));
    }

    @Operation(summary = "创建商品(管理端)")
    @PostMapping("/admin/products")
    public Result<PointProduct> createProduct(@RequestBody PointProduct product) {
        return Result.success(shopService.createProduct(product));
    }

    @Operation(summary = "更新商品(管理端)")
    @PutMapping("/admin/products/{id}")
    public Result<Void> updateProduct(@PathVariable Long id, @RequestBody PointProduct product) {
        product.setId(id);
        shopService.updateProduct(product);
        return Result.success();
    }

    @Operation(summary = "删除商品(管理端)")
    @DeleteMapping("/admin/products/{id}")
    public Result<Void> deleteProduct(@PathVariable Long id) {
        shopService.deleteProduct(id);
        return Result.success();
    }

    @Operation(summary = "上下架商品(管理端)")
    @PutMapping("/admin/products/{id}/toggle")
    public Result<Void> toggleProductStatus(@PathVariable Long id) {
        shopService.toggleProductStatus(id);
        return Result.success();
    }

    @Operation(summary = "处理兑换订单(管理端)")
    @PutMapping("/admin/exchanges/{id}/process")
    public Result<Void> processExchange(@PathVariable Long id, @RequestBody Map<String, String> params) {
        shopService.processExchange(id, params.get("trackingNo"));
        return Result.success();
    }

    @Operation(summary = "完成兑换订单(管理端)")
    @PutMapping("/admin/exchanges/{id}/complete")
    public Result<Void> completeExchange(@PathVariable Long id) {
        shopService.completeExchange(id);
        return Result.success();
    }

    @Operation(summary = "取消兑换订单(管理端)")
    @PutMapping("/admin/exchanges/{id}/cancel")
    public Result<Void> cancelExchange(@PathVariable Long id, @RequestBody Map<String, String> params) {
        shopService.cancelExchange(id, params.get("reason"));
        return Result.success();
    }
}
