package com.studyroom.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.studyroom.common.PageResult;
import com.studyroom.common.Result;
import com.studyroom.entity.*;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.*;
import com.studyroom.common.ResultCode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

/**
 * 超级管理员Controller
 */
@Tag(name = "超级管理员", description = "超级管理员相关接口")
@Slf4j
@RestController
@RequestMapping("/super-admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SUPER_ADMIN')")
public class SuperAdminController {

    private final UserMapper userMapper;
    private final StudyRoomMapper studyRoomMapper;
    private final SeatMapper seatMapper;
    private final ViolationRecordMapper violationRecordMapper;
    private final BlacklistMapper blacklistMapper;
    private final CheckInRecordMapper checkInRecordMapper;
    private final AchievementMapper achievementMapper;
    private final PasswordEncoder passwordEncoder;

    // ==================== 统计数据 ====================

private final ReservationMapper reservationMapper;

    @Operation(summary = "获取超管统计数据")
    @GetMapping("/stats")
    public Result<Map<String, Object>> getStats() {
        Map<String, Object> result = new HashMap<>();
        
        // 用户统计
        Long totalUsers = userMapper.selectCount(
            new LambdaQueryWrapper<User>().eq(User::getRole, "STUDENT")
        );
        
        // 活跃用户（最近7天有打卡）
        LocalDateTime weekAgo = LocalDateTime.now().minusDays(7);
        Long activeUsers = checkInRecordMapper.selectCount(
            new LambdaQueryWrapper<CheckInRecord>()
                .ge(CheckInRecord::getCheckInTime, weekAgo)
        );
        
        // 管理员数量
        Long totalAdmins = userMapper.selectCount(
            new LambdaQueryWrapper<User>().eq(User::getRole, "ADMIN")
        );
        
        // 自习室统计
        Long totalRooms = studyRoomMapper.selectCount(null);
        Long totalSeats = seatMapper.selectCount(null);
        
        // 黑名单数量
        Long blacklistCount = blacklistMapper.selectCount(
            new LambdaQueryWrapper<Blacklist>().eq(Blacklist::getReleased, 0)
        );
        
        // 今日打卡
        LocalDateTime todayStart = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
        Long todayCheckIns = checkInRecordMapper.selectCount(
            new LambdaQueryWrapper<CheckInRecord>()
                .ge(CheckInRecord::getCheckInTime, todayStart)
        );
        
        // 成就总数
        Long totalAchievements = achievementMapper.selectCount(null);
        
        // 待处理申诉
        Long pendingAppeals = violationRecordMapper.selectCount(
            new LambdaQueryWrapper<ViolationRecord>()
                .eq(ViolationRecord::getAppealStatus, 1)
        );
        
        // 即将到期的黑名单（7天内）
        LocalDateTime weekLater = LocalDateTime.now().plusDays(7);
        Long blacklistExpiring = blacklistMapper.selectCount(
            new LambdaQueryWrapper<Blacklist>()
                .eq(Blacklist::getReleased, 0)
                .le(Blacklist::getEndTime, weekLater)
        );
        
        // 最近7天新用户
        Long newUsers = userMapper.selectCount(
            new LambdaQueryWrapper<User>()
                .eq(User::getRole, "STUDENT")
                .ge(User::getCreateTime, weekAgo)
        );
        
        // 组装结果
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", totalUsers);
        stats.put("activeUsers", activeUsers);
        stats.put("totalAdmins", totalAdmins);
        stats.put("totalRooms", totalRooms);
        stats.put("totalSeats", totalSeats);
        stats.put("blacklistCount", blacklistCount);
        stats.put("todayCheckIns", todayCheckIns);
        stats.put("totalAchievements", totalAchievements);
        
        Map<String, Object> pendingTasks = new HashMap<>();
        pendingTasks.put("appeals", pendingAppeals);
        pendingTasks.put("blacklistExpiring", blacklistExpiring);
        pendingTasks.put("newUsers", newUsers);
        
        Map<String, String> systemStatus = new HashMap<>();
        systemStatus.put("database", "healthy");
        systemStatus.put("redis", "healthy");
        systemStatus.put("storage", "healthy");
        
        result.put("stats", stats);
        result.put("pendingTasks", pendingTasks);
        result.put("systemStatus", systemStatus);
        
        return Result.success(result);
    }

    @Operation(summary = "获取图表数据")
    @GetMapping("/chart-data")
    public Result<Map<String, Object>> getChartData() {
        Map<String, Object> result = new HashMap<>();
        
        // 用户增长趋势（近7天）
        List<Map<String, Object>> userGrowth = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();
            
            Long count = userMapper.selectCount(
                new LambdaQueryWrapper<User>()
                    .eq(User::getRole, "STUDENT")
                    .ge(User::getCreateTime, startOfDay)
                    .lt(User::getCreateTime, endOfDay)
            );
            
            Map<String, Object> item = new HashMap<>();
            item.put("date", (date.getMonthValue()) + "/" + date.getDayOfMonth());
            item.put("count", count);
            userGrowth.add(item);
        }
        result.put("userGrowth", userGrowth);
        
        // 预约趋势（近7天）
        List<Map<String, Object>> reservationTrend = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            
            Long count = reservationMapper.selectCount(
                new LambdaQueryWrapper<Reservation>()
                    .eq(Reservation::getDate, date)
            );
            
            Map<String, Object> item = new HashMap<>();
            item.put("date", (date.getMonthValue()) + "/" + date.getDayOfMonth());
            item.put("count", count);
            reservationTrend.add(item);
        }
        result.put("reservationTrend", reservationTrend);
        
        // 自习室使用率（今日）
        List<Map<String, Object>> roomUsage = new ArrayList<>();
        List<StudyRoom> rooms = studyRoomMapper.selectList(
            new LambdaQueryWrapper<StudyRoom>()
                .eq(StudyRoom::getStatus, 1)
                .orderByDesc(StudyRoom::getCapacity)
                .last("LIMIT 5")
        );
        
        LocalDate today = LocalDate.now();
        for (StudyRoom room : rooms) {
            // 计算当前使用中的座位数
            Long inUseCount = reservationMapper.selectCount(
                new LambdaQueryWrapper<Reservation>()
                    .eq(Reservation::getRoomId, room.getId())
                    .eq(Reservation::getDate, today)
                    .in(Reservation::getStatus, Arrays.asList("CHECKED_IN", "LEAVING"))
            );
            
            int usage = room.getCapacity() > 0 ? 
                (int) Math.round((double) inUseCount / room.getCapacity() * 100) : 0;
            
            Map<String, Object> item = new HashMap<>();
            item.put("name", room.getName());
            item.put("usage", Math.min(usage, 100));
            roomUsage.add(item);
        }
        result.put("roomUsage", roomUsage);
        
        // 座位类型分布
        List<Map<String, Object>> categoryDistribution = new ArrayList<>();
        
        Long normalCount = seatMapper.selectCount(
            new LambdaQueryWrapper<Seat>()
                .eq(Seat::getSeatType, "NORMAL")
                .eq(Seat::getStatus, 1)
        );
        Long windowCount = seatMapper.selectCount(
            new LambdaQueryWrapper<Seat>()
                .eq(Seat::getSeatType, "WINDOW")
                .eq(Seat::getStatus, 1)
        );
        Long powerCount = seatMapper.selectCount(
            new LambdaQueryWrapper<Seat>()
                .eq(Seat::getSeatType, "POWER")
                .eq(Seat::getStatus, 1)
        );
        Long vipCount = seatMapper.selectCount(
            new LambdaQueryWrapper<Seat>()
                .eq(Seat::getSeatType, "VIP")
                .eq(Seat::getStatus, 1)
        );
        
        categoryDistribution.add(Map.of("name", "普通座位", "value", normalCount));
        categoryDistribution.add(Map.of("name", "靠窗座位", "value", windowCount));
        categoryDistribution.add(Map.of("name", "电源座位", "value", powerCount));
        categoryDistribution.add(Map.of("name", "VIP座位", "value", vipCount));
        
        result.put("categoryDistribution", categoryDistribution);
        
        return Result.success(result);
    }

    // ==================== 用户管理 ====================

    @Operation(summary = "获取学生用户列表")
    @GetMapping("/users")
    public Result<PageResult<User>> getUserList(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String college) {
        
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getRole, "STUDENT");
        
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                .like(User::getUsername, keyword)
                .or().like(User::getRealName, keyword)
                .or().like(User::getStudentId, keyword)
                .or().like(User::getPhone, keyword)
            );
        }
        if (status != null) {
            wrapper.eq(User::getStatus, status);
        }
        if (StringUtils.hasText(college)) {
            wrapper.eq(User::getCollege, college);
        }
        
        wrapper.orderByDesc(User::getCreateTime);
        
        IPage<User> page = userMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        
        return Result.success(PageResult.of(page));
    }

    @Operation(summary = "获取用户详情")
    @GetMapping("/users/{id}")
    public Result<User> getUserDetail(@PathVariable Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "用户不存在");
        }
        return Result.success(user);
    }

    @Operation(summary = "更新用户信息")
    @PutMapping("/users/{id}")
    public Result<Void> updateUser(@PathVariable Long id, @RequestBody Map<String, Object> params) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "用户不存在");
        }
        
        if (params.containsKey("realName")) {
            user.setRealName((String) params.get("realName"));
        }
        if (params.containsKey("phone")) {
            user.setPhone((String) params.get("phone"));
        }
        if (params.containsKey("email")) {
            user.setEmail((String) params.get("email"));
        }
        if (params.containsKey("college")) {
            user.setCollege((String) params.get("college"));
        }
        if (params.containsKey("major")) {
            user.setMajor((String) params.get("major"));
        }
        if (params.containsKey("grade")) {
            user.setGrade((String) params.get("grade"));
        }
        if (params.containsKey("classNo")) {
            user.setClassNo((String) params.get("classNo"));
        }
        if (params.containsKey("creditScore")) {
            user.setCreditScore((Integer) params.get("creditScore"));
        }
        
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
        
        log.info("超管更新用户信息: userId={}", id);
        return Result.success();
    }

    @Operation(summary = "切换用户状态")
    @PutMapping("/users/{id}/status")
    public Result<Void> toggleUserStatus(@PathVariable Long id, @RequestParam int status) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "用户不存在");
        }
        
        user.setStatus(status);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
        
        log.info("超管切换用户状态: userId={}, status={}", id, status);
        return Result.success();
    }

    @Operation(summary = "重置用户密码")
    @PostMapping("/users/{id}/reset-password")
    public Result<String> resetUserPassword(@PathVariable Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new BusinessException(ResultCode.NOT_FOUND, "用户不存在");
        }
        
        // 生成随机6位密码
        String newPassword = String.format("%06d", new Random().nextInt(1000000));
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
        
        log.info("超管重置用户密码: userId={}", id);
        return Result.success(newPassword);
    }

    @Operation(summary = "获取学院列表")
    @GetMapping("/users/colleges")
    public Result<List<String>> getCollegeList() {
        List<User> users = userMapper.selectList(
            new LambdaQueryWrapper<User>()
                .eq(User::getRole, "STUDENT")
                .isNotNull(User::getCollege)
                .select(User::getCollege)
        );
        List<String> colleges = users.stream()
            .map(User::getCollege)
            .filter(StringUtils::hasText)
            .distinct()
            .sorted()
            .toList();
        return Result.success(colleges);
    }

    // ==================== 管理员管理 ====================

    @Operation(summary = "获取管理员列表")
    @GetMapping("/admins")
    public Result<PageResult<User>> getAdminList(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String keyword) {
        
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getRole, "ADMIN");
        
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                .like(User::getUsername, keyword)
                .or().like(User::getRealName, keyword)
                .or().like(User::getPhone, keyword)
            );
        }
        
        wrapper.orderByDesc(User::getCreateTime);
        
        IPage<User> page = userMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        
        return Result.success(PageResult.of(page));
    }

    @Operation(summary = "创建管理员")
    @PostMapping("/admins")
    public Result<Long> createAdmin(@RequestBody Map<String, String> params) {
        String username = params.get("username");
        String password = params.get("password");
        String realName = params.get("realName");
        String phone = params.get("phone");
        String email = params.get("email");
        
        if (!StringUtils.hasText(username) || !StringUtils.hasText(password) || !StringUtils.hasText(realName)) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "用户名、密码、姓名不能为空");
        }
        
        // 检查用户名是否存在
        Long count = userMapper.selectCount(
            new LambdaQueryWrapper<User>().eq(User::getUsername, username)
        );
        if (count > 0) {
            throw new BusinessException(ResultCode.BAD_REQUEST, "用户名已存在");
        }
        
        User admin = User.builder()
            .username(username)
            .password(passwordEncoder.encode(password))
            .realName(realName)
            .phone(phone)
            .email(email)
            .studentId("ADMIN" + System.currentTimeMillis())
            .role("ADMIN")
            .status(1)
            .creditScore(100)
            .totalStudyTime(0)
            .totalPoints(0)
            .consecutiveDays(0)
            .totalCheckIns(0)
            .exp(0)
            .currentStreak(0)
            .maxStreak(0)
            .createTime(LocalDateTime.now())
            .updateTime(LocalDateTime.now())
            .build();
        
        userMapper.insert(admin);
        
        log.info("超管创建管理员: username={}", username);
        return Result.success(admin.getId());
    }

    @Operation(summary = "更新管理员")
    @PutMapping("/admins/{id}")
    public Result<Void> updateAdmin(@PathVariable Long id, @RequestBody Map<String, String> params) {
        User admin = userMapper.selectById(id);
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            throw new BusinessException(ResultCode.NOT_FOUND, "管理员不存在");
        }
        
        if (params.containsKey("realName") && StringUtils.hasText(params.get("realName"))) {
            admin.setRealName(params.get("realName"));
        }
        if (params.containsKey("phone")) {
            admin.setPhone(params.get("phone"));
        }
        if (params.containsKey("email")) {
            admin.setEmail(params.get("email"));
        }
        
        admin.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(admin);
        
        log.info("超管更新管理员: adminId={}", id);
        return Result.success();
    }

    @Operation(summary = "删除管理员")
    @DeleteMapping("/admins/{id}")
    public Result<Void> deleteAdmin(@PathVariable Long id) {
        User admin = userMapper.selectById(id);
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            throw new BusinessException(ResultCode.NOT_FOUND, "管理员不存在");
        }
        
        userMapper.deleteById(id);
        
        log.info("超管删除管理员: adminId={}", id);
        return Result.success();
    }

    @Operation(summary = "重置管理员密码")
    @PostMapping("/admins/{id}/reset-password")
    public Result<String> resetAdminPassword(@PathVariable Long id) {
        User admin = userMapper.selectById(id);
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            throw new BusinessException(ResultCode.NOT_FOUND, "管理员不存在");
        }
        
        // 重置为默认密码 123456
        String newPassword = "123456";
        admin.setPassword(passwordEncoder.encode(newPassword));
        admin.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(admin);
        
        log.info("超管重置管理员密码: adminId={}", id);
        return Result.success(newPassword);
    }

    @Operation(summary = "切换管理员状态")
    @PutMapping("/admins/{id}/status")
    public Result<Void> toggleAdminStatus(@PathVariable Long id, @RequestParam int status) {
        User admin = userMapper.selectById(id);
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            throw new BusinessException(ResultCode.NOT_FOUND, "管理员不存在");
        }
        
        admin.setStatus(status);
        admin.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(admin);
        
        log.info("超管切换管理员状态: adminId={}, status={}", id, status);
        return Result.success();
    }

    // ==================== 系统设置 ====================

    @Operation(summary = "获取系统设置")
    @GetMapping("/settings")
    public Result<Map<String, Object>> getSettings() {
        Map<String, Object> settings = new HashMap<>();
        
        // 预约设置
        Map<String, Object> reservation = new HashMap<>();
        reservation.put("maxDailyReservations", 3);
        reservation.put("advanceBookingDays", 7);
        reservation.put("signInAdvanceMinutes", 15);
        reservation.put("signInTimeoutMinutes", 15);
        reservation.put("leaveTimeoutMinutes", 30);
        reservation.put("maxLeaveCount", 2);
        reservation.put("freeCancelMinutes", 30);
        settings.put("reservation", reservation);
        
        // 积分设置
        Map<String, Object> points = new HashMap<>();
        points.put("pointsPerHour", 10);
        points.put("checkInBonus", 5);
        points.put("achievementBonus", 20);
        points.put("referralBonus", 50);
        settings.put("points", points);
        
        // 信用分设置
        Map<String, Object> credit = new HashMap<>();
        credit.put("initialScore", 100);
        credit.put("maxScore", 120);
        credit.put("minScoreForBooking", 60);
        credit.put("noShowPenalty", 10);
        credit.put("leaveTimeoutPenalty", 5);
        credit.put("earlyLeavePenalty", 3);
        credit.put("monthlyRecovery", 5);
        settings.put("credit", credit);
        
        // 系统设置
        Map<String, Object> system = new HashMap<>();
        system.put("siteName", "智慧自习室");
        system.put("siteDescription", "智慧自习室座位预约系统");
        system.put("maintenanceMode", false);
        system.put("registrationEnabled", true);
        settings.put("system", system);
        
        return Result.success(settings);
    }

    @Operation(summary = "更新系统设置")
    @PutMapping("/settings")
    public Result<Void> updateSettings(@RequestBody Map<String, Object> settings) {
        // TODO: 将设置存储到数据库或配置文件
        log.info("超管更新系统设置: {}", settings);
        return Result.success();
    }
}
