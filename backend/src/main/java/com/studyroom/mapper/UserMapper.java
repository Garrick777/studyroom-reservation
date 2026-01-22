package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.studyroom.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 用户Mapper接口
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {

    /**
     * 根据用户名查找用户
     */
    @Select("SELECT * FROM user WHERE username = #{username} AND deleted = 0")
    User findByUsername(@Param("username") String username);

    /**
     * 根据学号查找用户
     */
    @Select("SELECT * FROM user WHERE student_id = #{studentId} AND deleted = 0")
    User findByStudentId(@Param("studentId") String studentId);

    /**
     * 根据邮箱查找用户
     */
    @Select("SELECT * FROM user WHERE email = #{email} AND deleted = 0")
    User findByEmail(@Param("email") String email);

    /**
     * 根据手机号查找用户
     */
    @Select("SELECT * FROM user WHERE phone = #{phone} AND deleted = 0")
    User findByPhone(@Param("phone") String phone);

    /**
     * 检查用户名是否存在
     */
    @Select("SELECT COUNT(*) FROM user WHERE username = #{username} AND deleted = 0")
    int countByUsername(@Param("username") String username);

    /**
     * 检查学号是否存在
     */
    @Select("SELECT COUNT(*) FROM user WHERE student_id = #{studentId} AND deleted = 0")
    int countByStudentId(@Param("studentId") String studentId);

    /**
     * 学习时长排行榜
     */
    @Select("SELECT * FROM user WHERE role = 'STUDENT' AND deleted = 0 ORDER BY total_study_time DESC LIMIT #{limit}")
    List<User> findTopByStudyTime(@Param("limit") int limit);

    /**
     * 积分排行榜
     */
    @Select("SELECT * FROM user WHERE role = 'STUDENT' AND deleted = 0 ORDER BY total_points DESC LIMIT #{limit}")
    List<User> findTopByPoints(@Param("limit") int limit);

    /**
     * 连续签到排行榜
     */
    @Select("SELECT * FROM user WHERE role = 'STUDENT' AND deleted = 0 ORDER BY consecutive_days DESC LIMIT #{limit}")
    List<User> findTopByConsecutiveDays(@Param("limit") int limit);
}
