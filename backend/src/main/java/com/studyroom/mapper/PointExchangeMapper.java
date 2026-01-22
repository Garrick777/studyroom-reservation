package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.PointExchange;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 积分兑换Mapper
 */
@Mapper
public interface PointExchangeMapper extends BaseMapper<PointExchange> {

    /**
     * 查询用户兑换记录(带商品信息)
     */
    @Select("SELECT pe.*, pp.name as product_name, pp.image as product_image " +
            "FROM point_exchange pe " +
            "LEFT JOIN point_product pp ON pe.product_id = pp.id " +
            "WHERE pe.user_id = #{userId} " +
            "ORDER BY pe.create_time DESC")
    @Results({
            @Result(property = "id", column = "id"),
            @Result(property = "exchangeNo", column = "exchange_no"),
            @Result(property = "userId", column = "user_id"),
            @Result(property = "productId", column = "product_id"),
            @Result(property = "productName", column = "product_name"),
            @Result(property = "productImage", column = "product_image"),
            @Result(property = "pointsCost", column = "points_cost"),
            @Result(property = "quantity", column = "quantity"),
            @Result(property = "status", column = "status"),
            @Result(property = "createTime", column = "create_time")
    })
    List<PointExchange> selectByUserId(@Param("userId") Long userId);

    /**
     * 统计用户已兑换某商品的数量
     */
    @Select("SELECT COALESCE(SUM(quantity), 0) FROM point_exchange " +
            "WHERE user_id = #{userId} AND product_id = #{productId} AND status != 'CANCELLED'")
    int countUserExchanged(@Param("userId") Long userId, @Param("productId") Long productId);
}
