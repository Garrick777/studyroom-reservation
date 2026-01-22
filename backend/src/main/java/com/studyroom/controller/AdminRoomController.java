package com.studyroom.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.common.PageResult;
import com.studyroom.common.Result;
import com.studyroom.dto.RoomCreateRequest;
import com.studyroom.dto.RoomUpdateRequest;
import com.studyroom.dto.SeatBatchCreateRequest;
import com.studyroom.dto.SeatUpdateRequest;
import com.studyroom.entity.Seat;
import com.studyroom.entity.StudyRoom;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.SeatMapper;
import com.studyroom.mapper.StudyRoomMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.*;

/**
 * 管理端 - 自习室管理控制器
 */
@Tag(name = "管理端-自习室管理")
@Slf4j
@RestController
@RequestMapping("/manage/rooms")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
public class AdminRoomController {

    private final StudyRoomMapper studyRoomMapper;
    private final SeatMapper seatMapper;

    // ==================== 自习室管理 ====================

    /**
     * 获取自习室列表（管理端）
     */
    @Operation(summary = "获取自习室列表")
    @GetMapping
    public Result<PageResult<StudyRoom>> getRoomList(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String building,
            @RequestParam(required = false) Integer status) {
        
        LambdaQueryWrapper<StudyRoom> wrapper = new LambdaQueryWrapper<>();
        
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                .like(StudyRoom::getName, keyword)
                .or().like(StudyRoom::getCode, keyword)
            );
        }
        if (StringUtils.hasText(building)) {
            wrapper.eq(StudyRoom::getBuilding, building);
        }
        if (status != null) {
            wrapper.eq(StudyRoom::getStatus, status);
        }
        
        wrapper.orderByDesc(StudyRoom::getCreateTime);
        
        IPage<StudyRoom> page = studyRoomMapper.selectPage(
            new Page<>(pageNum, pageSize), wrapper
        );
        
        // 为每个自习室添加座位统计
        page.getRecords().forEach(room -> {
            LambdaQueryWrapper<Seat> seatWrapper = new LambdaQueryWrapper<>();
            seatWrapper.eq(Seat::getRoomId, room.getId());
            long totalSeats = seatMapper.selectCount(seatWrapper);
            room.setCapacity((int) totalSeats);
        });
        
        return Result.success(PageResult.of(page));
    }

    /**
     * 获取自习室详情
     */
    @Operation(summary = "获取自习室详情")
    @GetMapping("/{id}")
    public Result<Map<String, Object>> getRoomDetail(@PathVariable Long id) {
        StudyRoom room = studyRoomMapper.selectById(id);
        if (room == null) {
            throw new BusinessException("自习室不存在");
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("room", room);
        
        // 座位统计
        LambdaQueryWrapper<Seat> seatWrapper = new LambdaQueryWrapper<>();
        seatWrapper.eq(Seat::getRoomId, id);
        long totalSeats = seatMapper.selectCount(seatWrapper);
        
        seatWrapper.clear();
        seatWrapper.eq(Seat::getRoomId, id).eq(Seat::getStatus, 1);
        long availableSeats = seatMapper.selectCount(seatWrapper);
        
        seatWrapper.clear();
        seatWrapper.eq(Seat::getRoomId, id).eq(Seat::getStatus, 0);
        long disabledSeats = seatMapper.selectCount(seatWrapper);
        
        result.put("totalSeats", totalSeats);
        result.put("availableSeats", availableSeats);
        result.put("disabledSeats", disabledSeats);
        
        return Result.success(result);
    }

    /**
     * 创建自习室
     */
    @Operation(summary = "创建自习室")
    @PostMapping
    @Transactional
    public Result<Long> createRoom(@Valid @RequestBody RoomCreateRequest request) {
        // 检查编号是否重复
        LambdaQueryWrapper<StudyRoom> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(StudyRoom::getCode, request.getCode());
        if (studyRoomMapper.selectCount(wrapper) > 0) {
            throw new BusinessException("自习室编号已存在");
        }
        
        // 解析设施JSON
        List<String> facilitiesList = new ArrayList<>();
        if (StringUtils.hasText(request.getFacilities())) {
            try {
                String[] arr = request.getFacilities().replace("[", "").replace("]", "")
                        .replace("\"", "").split(",");
                for (String s : arr) {
                    if (StringUtils.hasText(s.trim())) {
                        facilitiesList.add(s.trim());
                    }
                }
            } catch (Exception e) {
                // 忽略解析错误
            }
        }
        
        StudyRoom room = StudyRoom.builder()
                .name(request.getName())
                .code(request.getCode())
                .building(request.getBuilding())
                .floor(request.getFloor())
                .roomNumber(request.getRoomNumber())
                .capacity(request.getCapacity())
                .description(request.getDescription())
                .facilities(facilitiesList)
                .openTime(LocalTime.parse(request.getOpenTime()))
                .closeTime(LocalTime.parse(request.getCloseTime()))
                .rowCount(request.getRowCount())
                .colCount(request.getColCount())
                .coverImage(request.getCoverImage())
                .status(1) // 默认开放
                .rating(BigDecimal.ZERO)
                .ratingCount(0)
                .build();
        
        studyRoomMapper.insert(room);
        
        // 如果指定了行列数，自动生成座位
        if (request.getRowCount() != null && request.getColCount() != null 
            && request.getRowCount() > 0 && request.getColCount() > 0) {
            generateSeats(room.getId(), request.getRowCount(), request.getColCount());
        }
        
        log.info("创建自习室: {} ({})", room.getName(), room.getCode());
        
        return Result.success(room.getId());
    }

    /**
     * 更新自习室
     */
    @Operation(summary = "更新自习室")
    @PutMapping("/{id}")
    public Result<Void> updateRoom(@PathVariable Long id, @Valid @RequestBody RoomUpdateRequest request) {
        StudyRoom room = studyRoomMapper.selectById(id);
        if (room == null) {
            throw new BusinessException("自习室不存在");
        }
        
        // 检查编号是否重复（排除自己）
        if (StringUtils.hasText(request.getCode()) && !request.getCode().equals(room.getCode())) {
            LambdaQueryWrapper<StudyRoom> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(StudyRoom::getCode, request.getCode());
            if (studyRoomMapper.selectCount(wrapper) > 0) {
                throw new BusinessException("自习室编号已存在");
            }
            room.setCode(request.getCode());
        }
        
        if (StringUtils.hasText(request.getName())) room.setName(request.getName());
        if (StringUtils.hasText(request.getBuilding())) room.setBuilding(request.getBuilding());
        if (StringUtils.hasText(request.getFloor())) room.setFloor(request.getFloor());
        if (StringUtils.hasText(request.getRoomNumber())) room.setRoomNumber(request.getRoomNumber());
        if (request.getCapacity() != null) room.setCapacity(request.getCapacity());
        if (StringUtils.hasText(request.getDescription())) room.setDescription(request.getDescription());
        
        // 解析设施JSON
        if (StringUtils.hasText(request.getFacilities())) {
            List<String> facilitiesList = new ArrayList<>();
            try {
                String[] arr = request.getFacilities().replace("[", "").replace("]", "")
                        .replace("\"", "").split(",");
                for (String s : arr) {
                    if (StringUtils.hasText(s.trim())) {
                        facilitiesList.add(s.trim());
                    }
                }
            } catch (Exception e) {
                // 忽略解析错误
            }
            room.setFacilities(facilitiesList);
        }
        
        if (StringUtils.hasText(request.getOpenTime())) room.setOpenTime(LocalTime.parse(request.getOpenTime()));
        if (StringUtils.hasText(request.getCloseTime())) room.setCloseTime(LocalTime.parse(request.getCloseTime()));
        if (request.getRowCount() != null) room.setRowCount(request.getRowCount());
        if (request.getColCount() != null) room.setColCount(request.getColCount());
        if (StringUtils.hasText(request.getCoverImage())) room.setCoverImage(request.getCoverImage());
        if (request.getStatus() != null) room.setStatus(request.getStatus());
        
        studyRoomMapper.updateById(room);
        
        log.info("更新自习室: {} ({})", room.getName(), room.getCode());
        
        return Result.success();
    }

    /**
     * 删除自习室
     */
    @Operation(summary = "删除自习室")
    @DeleteMapping("/{id}")
    @Transactional
    public Result<Void> deleteRoom(@PathVariable Long id) {
        StudyRoom room = studyRoomMapper.selectById(id);
        if (room == null) {
            throw new BusinessException("自习室不存在");
        }
        
        // 删除关联座位
        LambdaQueryWrapper<Seat> seatWrapper = new LambdaQueryWrapper<>();
        seatWrapper.eq(Seat::getRoomId, id);
        seatMapper.delete(seatWrapper);
        
        // 删除自习室
        studyRoomMapper.deleteById(id);
        
        log.info("删除自习室: {} ({})", room.getName(), room.getCode());
        
        return Result.success();
    }

    /**
     * 切换自习室状态
     */
    @Operation(summary = "切换自习室状态")
    @PutMapping("/{id}/status")
    public Result<Void> toggleRoomStatus(@PathVariable Long id, @RequestParam int status) {
        StudyRoom room = studyRoomMapper.selectById(id);
        if (room == null) {
            throw new BusinessException("自习室不存在");
        }
        
        room.setStatus(status);
        studyRoomMapper.updateById(room);
        
        log.info("切换自习室状态: {} -> {}", room.getName(), status == 1 ? "开放" : "关闭");
        
        return Result.success();
    }

    // ==================== 座位管理 ====================

    /**
     * 获取自习室座位列表
     */
    @Operation(summary = "获取座位列表")
    @GetMapping("/{roomId}/seats")
    public Result<List<Seat>> getSeatList(@PathVariable Long roomId) {
        LambdaQueryWrapper<Seat> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Seat::getRoomId, roomId)
               .orderByAsc(Seat::getRowNum)
               .orderByAsc(Seat::getColNum);
        
        List<Seat> seats = seatMapper.selectList(wrapper);
        return Result.success(seats);
    }

    /**
     * 批量生成座位
     */
    @Operation(summary = "批量生成座位")
    @PostMapping("/{roomId}/seats/batch")
    @Transactional
    public Result<Integer> batchCreateSeats(
            @PathVariable Long roomId,
            @Valid @RequestBody SeatBatchCreateRequest request) {
        
        StudyRoom room = studyRoomMapper.selectById(roomId);
        if (room == null) {
            throw new BusinessException("自习室不存在");
        }
        
        // 是否清除原有座位
        if (request.isClearExisting()) {
            LambdaQueryWrapper<Seat> deleteWrapper = new LambdaQueryWrapper<>();
            deleteWrapper.eq(Seat::getRoomId, roomId);
            seatMapper.delete(deleteWrapper);
        }
        
        int count = generateSeats(roomId, request.getRowCount(), request.getColCount());
        
        // 更新自习室行列信息
        room.setRowCount(request.getRowCount());
        room.setColCount(request.getColCount());
        room.setCapacity(count);
        studyRoomMapper.updateById(room);
        
        log.info("为自习室 {} 生成 {} 个座位", room.getName(), count);
        
        return Result.success(count);
    }

    /**
     * 更新单个座位
     */
    @Operation(summary = "更新座位")
    @PutMapping("/seats/{seatId}")
    public Result<Void> updateSeat(
            @PathVariable Long seatId,
            @Valid @RequestBody SeatUpdateRequest request) {
        
        Seat seat = seatMapper.selectById(seatId);
        if (seat == null) {
            throw new BusinessException("座位不存在");
        }
        
        if (StringUtils.hasText(request.getSeatNo())) seat.setSeatNo(request.getSeatNo());
        if (request.getSeatType() != null) seat.setSeatType(request.getSeatType().toString());
        if (request.getStatus() != null) seat.setStatus(request.getStatus());
        if (StringUtils.hasText(request.getRemark())) seat.setRemark(request.getRemark());
        
        seatMapper.updateById(seat);
        
        return Result.success();
    }

    /**
     * 批量更新座位状态
     */
    @Operation(summary = "批量更新座位状态")
    @PutMapping("/{roomId}/seats/batch-status")
    public Result<Void> batchUpdateSeatStatus(
            @PathVariable Long roomId,
            @RequestBody Map<String, Object> request) {
        
        @SuppressWarnings("unchecked")
        List<Integer> seatIdInts = (List<Integer>) request.get("seatIds");
        Integer status = (Integer) request.get("status");
        
        if (seatIdInts == null || seatIdInts.isEmpty() || status == null) {
            throw new BusinessException("参数错误");
        }
        
        for (Integer seatIdInt : seatIdInts) {
            Long seatId = seatIdInt.longValue();
            Seat seat = seatMapper.selectById(seatId);
            if (seat != null && seat.getRoomId().equals(roomId)) {
                seat.setStatus(status);
                seatMapper.updateById(seat);
            }
        }
        
        return Result.success();
    }

    /**
     * 删除座位
     */
    @Operation(summary = "删除座位")
    @DeleteMapping("/seats/{seatId}")
    public Result<Void> deleteSeat(@PathVariable Long seatId) {
        Seat seat = seatMapper.selectById(seatId);
        if (seat == null) {
            throw new BusinessException("座位不存在");
        }
        
        seatMapper.deleteById(seatId);
        
        return Result.success();
    }

    /**
     * 获取建筑列表（用于筛选）
     */
    @Operation(summary = "获取建筑列表")
    @GetMapping("/buildings")
    public Result<List<String>> getBuildingList() {
        List<StudyRoom> rooms = studyRoomMapper.selectList(null);
        List<String> buildings = rooms.stream()
                .map(StudyRoom::getBuilding)
                .distinct()
                .sorted()
                .toList();
        return Result.success(buildings);
    }

    // ==================== 私有方法 ====================

    /**
     * 生成座位
     */
    private int generateSeats(Long roomId, int rowCount, int colCount) {
        List<Seat> seats = new ArrayList<>();
        
        for (int row = 1; row <= rowCount; row++) {
            for (int col = 1; col <= colCount; col++) {
                String seatNo = String.format("%c-%02d", (char)('A' + row - 1), col);
                
                Seat seat = Seat.builder()
                        .roomId(roomId)
                        .seatNo(seatNo)
                        .rowNum(row)
                        .colNum(col)
                        .seatType("NORMAL") // 普通座位
                        .status(1) // 可用
                        .build();
                
                seats.add(seat);
            }
        }
        
        // 批量插入
        for (Seat seat : seats) {
            seatMapper.insert(seat);
        }
        
        return seats.size();
    }
}
