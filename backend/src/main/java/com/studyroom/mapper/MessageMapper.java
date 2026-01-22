package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.Message;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 消息Mapper
 */
@Mapper
public interface MessageMapper extends BaseMapper<Message> {

    /**
     * 获取用户消息列表（分页）
     */
    @Select("<script>" +
            "SELECT * FROM message WHERE user_id = #{userId} " +
            "<if test='type != null'>AND type = #{type}</if> " +
            "<if test='isRead != null'>AND is_read = #{isRead}</if> " +
            "ORDER BY created_at DESC" +
            "</script>")
    IPage<Message> selectUserMessages(Page<Message> page, 
                                       @Param("userId") Long userId,
                                       @Param("type") String type,
                                       @Param("isRead") Integer isRead);

    /**
     * 统计用户未读消息数量
     */
    @Select("SELECT COUNT(*) FROM message WHERE user_id = #{userId} AND is_read = 0")
    int countUnread(@Param("userId") Long userId);

    /**
     * 按类型统计未读消息数量
     */
    @Select("SELECT type, COUNT(*) as count FROM message WHERE user_id = #{userId} AND is_read = 0 GROUP BY type")
    @Results({
            @Result(property = "type", column = "type"),
            @Result(property = "count", column = "count")
    })
    List<Message.TypeCount> countUnreadByType(@Param("userId") Long userId);

    /**
     * 标记用户所有消息为已读
     */
    @Update("UPDATE message SET is_read = 1, read_time = NOW() WHERE user_id = #{userId} AND is_read = 0")
    int markAllRead(@Param("userId") Long userId);

    /**
     * 标记指定类型消息为已读
     */
    @Update("UPDATE message SET is_read = 1, read_time = NOW() WHERE user_id = #{userId} AND type = #{type} AND is_read = 0")
    int markTypeRead(@Param("userId") Long userId, @Param("type") String type);

    /**
     * 获取用户最近的消息
     */
    @Select("SELECT * FROM message WHERE user_id = #{userId} ORDER BY created_at DESC LIMIT #{limit}")
    List<Message> selectRecentMessages(@Param("userId") Long userId, @Param("limit") int limit);
}
