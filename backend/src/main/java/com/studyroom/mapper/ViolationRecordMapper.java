package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.entity.ViolationRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 违约记录 Mapper
 */
@Mapper
public interface ViolationRecordMapper extends BaseMapper<ViolationRecord> {

    /**
     * 分页查询用户违约记录
     */
    @Select("<script>" +
            "SELECT vr.*, u.username, u.student_id " +
            "FROM violation_record vr " +
            "LEFT JOIN user u ON vr.user_id = u.id " +
            "WHERE vr.user_id = #{userId} " +
            "<if test=\"type != null and type != ''\"> AND vr.type = #{type} </if>" +
            "ORDER BY vr.created_at DESC" +
            "</script>")
    IPage<ViolationRecord> selectUserViolations(Page<ViolationRecord> page, 
                                                 @Param("userId") Long userId,
                                                 @Param("type") String type);

    /**
     * 管理员分页查询所有违约记录
     */
    @Select("<script>" +
            "SELECT vr.*, u.username, u.student_id " +
            "FROM violation_record vr " +
            "LEFT JOIN user u ON vr.user_id = u.id " +
            "WHERE 1=1 " +
            "<if test='userId != null'> AND vr.user_id = #{userId} </if>" +
            "<if test=\"type != null and type != ''\"> AND vr.type = #{type} </if>" +
            "<if test='appealStatus != null'> AND vr.appeal_status = #{appealStatus} </if>" +
            "ORDER BY vr.created_at DESC" +
            "</script>")
    IPage<ViolationRecord> selectAllViolations(Page<ViolationRecord> page,
                                                @Param("userId") Long userId,
                                                @Param("type") String type,
                                                @Param("appealStatus") Integer appealStatus);

    /**
     * 统计用户违约次数
     */
    @Select("SELECT COUNT(*) FROM violation_record WHERE user_id = #{userId}")
    int countByUserId(@Param("userId") Long userId);

    /**
     * 统计用户特定类型违约次数
     */
    @Select("SELECT COUNT(*) FROM violation_record WHERE user_id = #{userId} AND type = #{type}")
    int countByUserIdAndType(@Param("userId") Long userId, @Param("type") String type);

    /**
     * 查询用户待处理的申诉
     */
    @Select("SELECT * FROM violation_record WHERE user_id = #{userId} AND appeal_status = 1 ORDER BY appeal_time DESC")
    List<ViolationRecord> selectPendingAppeals(@Param("userId") Long userId);

    /**
     * 统计待处理申诉数量
     */
    @Select("SELECT COUNT(*) FROM violation_record WHERE appeal_status = 1")
    int countPendingAppeals();
}
