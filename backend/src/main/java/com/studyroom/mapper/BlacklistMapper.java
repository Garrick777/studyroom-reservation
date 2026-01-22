package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.Blacklist;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 黑名单 Mapper
 */
@Mapper
public interface BlacklistMapper extends BaseMapper<Blacklist> {

    /**
     * 检查用户是否在黑名单中
     */
    @Select("SELECT * FROM blacklist WHERE user_id = #{userId} AND released = 0 " +
            "AND (end_time IS NULL OR end_time > NOW()) LIMIT 1")
    Blacklist selectActiveByUserId(@Param("userId") Long userId);

    /**
     * 分页查询黑名单
     */
    @Select("<script>" +
            "SELECT * FROM blacklist " +
            "WHERE 1=1 " +
            "<if test='released != null'> AND released = #{released} </if>" +
            "ORDER BY created_at DESC" +
            "</script>")
    IPage<Blacklist> selectBlacklist(Page<Blacklist> page,
                                      @Param("released") Integer released,
                                      @Param("keyword") String keyword);

    /**
     * 查询已过期但未解除的黑名单
     */
    @Select("SELECT * FROM blacklist WHERE released = 0 AND end_time IS NOT NULL AND end_time <= NOW()")
    List<Blacklist> selectExpiredBlacklist();

    /**
     * 自动解除过期黑名单
     */
    @Update("UPDATE blacklist SET released = 1, release_time = NOW(), release_reason = '到期自动解除' " +
            "WHERE released = 0 AND end_time IS NOT NULL AND end_time <= NOW()")
    int autoReleaseExpired();

    /**
     * 统计黑名单中的用户数
     */
    @Select("SELECT COUNT(DISTINCT user_id) FROM blacklist WHERE released = 0 " +
            "AND (end_time IS NULL OR end_time > NOW())")
    int countActiveBlacklist();

    /**
     * 查询用户黑名单历史
     */
    @Select("SELECT * FROM blacklist WHERE user_id = #{userId} ORDER BY created_at DESC")
    List<Blacklist> selectUserHistory(@Param("userId") Long userId);
}
