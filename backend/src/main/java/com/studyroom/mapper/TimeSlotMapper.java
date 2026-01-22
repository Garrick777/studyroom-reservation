package com.studyroom.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.studyroom.entity.TimeSlot;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 时段Mapper接口
 */
@Mapper
public interface TimeSlotMapper extends BaseMapper<TimeSlot> {

    /**
     * 查询所有启用的时段
     */
    @Select("SELECT * FROM time_slot WHERE status = 1 ORDER BY sort_order")
    List<TimeSlot> findAllActive();

    /**
     * 根据名称查找时段
     */
    @Select("SELECT * FROM time_slot WHERE name = #{name}")
    TimeSlot findByName(@Param("name") String name);
}
