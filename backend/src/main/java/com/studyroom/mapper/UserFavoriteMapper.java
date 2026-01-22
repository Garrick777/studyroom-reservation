package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.studyroom.entity.UserFavorite;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 用户收藏Mapper接口
 */
@Mapper
public interface UserFavoriteMapper extends BaseMapper<UserFavorite> {

    /**
     * 查找用户收藏
     */
    @Select("SELECT * FROM user_favorite WHERE user_id = #{userId} AND room_id = #{roomId}")
    UserFavorite findByUserIdAndRoomId(@Param("userId") Long userId, @Param("roomId") Long roomId);

    /**
     * 查找用户所有收藏的自习室ID
     */
    @Select("SELECT room_id FROM user_favorite WHERE user_id = #{userId}")
    List<Long> findRoomIdsByUserId(@Param("userId") Long userId);

    /**
     * 删除收藏
     */
    @Delete("DELETE FROM user_favorite WHERE user_id = #{userId} AND room_id = #{roomId}")
    int deleteByUserIdAndRoomId(@Param("userId") Long userId, @Param("roomId") Long roomId);

    /**
     * 统计自习室收藏数
     */
    @Select("SELECT COUNT(*) FROM user_favorite WHERE room_id = #{roomId}")
    int countByRoomId(@Param("roomId") Long roomId);
}
