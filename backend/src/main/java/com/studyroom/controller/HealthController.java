package com.studyroom.controller;

import com.studyroom.common.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 健康检查控制器
 */
@Tag(name = "系统", description = "系统相关接口")
@RestController
@RequestMapping("/public")
public class HealthController {

    @Operation(summary = "健康检查")
    @GetMapping("/health")
    public Result<Map<String, Object>> health() {
        Map<String, Object> data = new HashMap<>();
        data.put("status", "UP");
        data.put("timestamp", LocalDateTime.now());
        data.put("service", "智慧自习室座位预约系统");
        data.put("version", "1.0.0");
        return Result.success(data);
    }

    @Operation(summary = "获取服务器时间")
    @GetMapping("/time")
    public Result<LocalDateTime> serverTime() {
        return Result.success(LocalDateTime.now());
    }
}
