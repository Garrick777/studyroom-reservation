package com.studyroom.service;

import com.studyroom.entity.CheckInRecord;
import com.studyroom.entity.User;
import com.studyroom.exception.BusinessException;
import com.studyroom.mapper.CheckInRecordMapper;
import com.studyroom.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 打卡签到服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CheckInService {

    private final CheckInRecordMapper checkInRecordMapper;
    private final UserMapper userMapper;

    /**
     * 每日打卡
     */
    @Transactional
    public CheckInRecord dailyCheckIn(Long userId, String source) {
        LocalDate today = LocalDate.now();
        
        // 检查今天是否已打卡
        CheckInRecord existing = checkInRecordMapper.selectByUserIdAndDate(userId, today);
        if (existing != null) {
            throw new BusinessException("今天已经打卡过了");
        }
        
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        
        // 计算连续打卡天数
        int continuousDays = calculateContinuousDays(userId, today);
        
        // 计算奖励
        int points = CheckInRecord.BASE_POINTS + CheckInRecord.getBonusPoints(continuousDays);
        int exp = CheckInRecord.BASE_EXP + CheckInRecord.getBonusExp(continuousDays);
        
        // 创建打卡记录
        CheckInRecord record = new CheckInRecord();
        record.setUserId(userId);
        record.setCheckInDate(today);
        record.setCheckInTime(LocalDateTime.now());
        record.setType(CheckInRecord.TYPE_DAILY);
        record.setEarnedPoints(points);
        record.setEarnedExp(exp);
        record.setContinuousDays(continuousDays);
        record.setSource(source != null ? source : CheckInRecord.SOURCE_WEB);
        checkInRecordMapper.insert(record);
        
        // 更新用户统计
        user.setTotalCheckIns((user.getTotalCheckIns() != null ? user.getTotalCheckIns() : 0) + 1);
        user.setConsecutiveDays(continuousDays);
        user.setTotalPoints((user.getTotalPoints() != null ? user.getTotalPoints() : 0) + points);
        user.setExp((user.getExp() != null ? user.getExp() : 0) + exp);
        userMapper.updateById(user);
        
        log.info("用户{}打卡成功，连续{}天，获得积分{}，经验{}", userId, continuousDays, points, exp);
        
        return record;
    }

    /**
     * 计算连续打卡天数
     */
    private int calculateContinuousDays(Long userId, LocalDate today) {
        // 获取昨天的打卡记录
        LocalDate yesterday = today.minusDays(1);
        CheckInRecord lastRecord = checkInRecordMapper.selectByUserIdAndDate(userId, yesterday);
        
        if (lastRecord != null) {
            // 昨天打卡了，连续天数+1
            return lastRecord.getContinuousDays() + 1;
        } else {
            // 昨天没打卡，重新计算（从1开始）
            return 1;
        }
    }

    /**
     * 获取今日打卡状态
     */
    public Map<String, Object> getTodayStatus(Long userId) {
        LocalDate today = LocalDate.now();
        CheckInRecord record = checkInRecordMapper.selectByUserIdAndDate(userId, today);
        
        User user = userMapper.selectById(userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("checkedIn", record != null);
        result.put("checkInTime", record != null ? record.getCheckInTime() : null);
        result.put("continuousDays", user != null ? user.getConsecutiveDays() : 0);
        result.put("totalCheckIns", user != null ? user.getTotalCheckIns() : 0);
        
        // 如果今天还没打卡，计算预期奖励
        if (record == null && user != null) {
            int expectedContinuous = calculateContinuousDays(userId, today);
            int expectedPoints = CheckInRecord.BASE_POINTS + CheckInRecord.getBonusPoints(expectedContinuous);
            int expectedExp = CheckInRecord.BASE_EXP + CheckInRecord.getBonusExp(expectedContinuous);
            result.put("expectedPoints", expectedPoints);
            result.put("expectedExp", expectedExp);
            result.put("expectedContinuousDays", expectedContinuous);
        } else if (record != null) {
            result.put("earnedPoints", record.getEarnedPoints());
            result.put("earnedExp", record.getEarnedExp());
        }
        
        return result;
    }

    /**
     * 获取月度打卡日历
     */
    public Map<String, Object> getMonthCalendar(Long userId, int year, int month) {
        YearMonth yearMonth = YearMonth.of(year, month);
        LocalDate startDate = yearMonth.atDay(1);
        LocalDate endDate = yearMonth.atEndOfMonth();
        
        List<CheckInRecord> records = checkInRecordMapper.selectByUserIdAndDateRange(userId, startDate, endDate);
        
        // 打卡日期列表
        Set<Integer> checkedDays = records.stream()
                .map(r -> r.getCheckInDate().getDayOfMonth())
                .collect(Collectors.toSet());
        
        // 统计本月数据
        int monthTotal = records.size();
        int monthPoints = records.stream().mapToInt(CheckInRecord::getEarnedPoints).sum();
        int monthExp = records.stream().mapToInt(CheckInRecord::getEarnedExp).sum();
        
        Map<String, Object> result = new HashMap<>();
        result.put("year", year);
        result.put("month", month);
        result.put("checkedDays", checkedDays);
        result.put("totalDays", monthTotal);
        result.put("totalPoints", monthPoints);
        result.put("totalExp", monthExp);
        result.put("daysInMonth", yearMonth.lengthOfMonth());
        
        return result;
    }

    /**
     * 获取打卡统计
     */
    public Map<String, Object> getCheckInStats(Long userId) {
        User user = userMapper.selectById(userId);
        
        int totalDays = checkInRecordMapper.countTotalDays(userId);
        int totalPoints = checkInRecordMapper.sumEarnedPoints(userId);
        int totalExp = checkInRecordMapper.sumEarnedExp(userId);
        int maxContinuous = checkInRecordMapper.selectMaxContinuousDays(userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("totalDays", totalDays);
        result.put("totalPoints", totalPoints);
        result.put("totalExp", totalExp);
        result.put("maxContinuousDays", maxContinuous);
        result.put("currentContinuousDays", user != null ? user.getConsecutiveDays() : 0);
        
        // 最近7天打卡情况
        LocalDate today = LocalDate.now();
        List<CheckInRecord> recent = checkInRecordMapper.selectByUserIdAndDateRange(
                userId, today.minusDays(6), today);
        List<LocalDate> recentDates = recent.stream()
                .map(CheckInRecord::getCheckInDate)
                .collect(Collectors.toList());
        result.put("recentCheckIns", recentDates);
        
        return result;
    }

    /**
     * 获取打卡记录列表
     */
    public List<CheckInRecord> getCheckInRecords(Long userId, LocalDate startDate, LocalDate endDate) {
        return checkInRecordMapper.selectByUserIdAndDateRange(userId, startDate, endDate);
    }
}
