package com.studyroom.controller;

import com.studyroom.common.PageResult;
import com.studyroom.common.Result;
import com.studyroom.dto.LoginResponse;
import com.studyroom.dto.UpdatePasswordRequest;
import com.studyroom.dto.UpdateProfileRequest;
import com.studyroom.entity.User;
import com.studyroom.security.SecurityUtil;
import com.studyroom.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

/**
 * 用户控制器
 */
@Tag(name = "用户管理", description = "用户信息相关接口")
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @Operation(summary = "获取当前用户信息")
    @GetMapping("/profile")
    public Result<LoginResponse.UserVO> getProfile() {
        User user = userService.getCurrentUser();
        return Result.success(LoginResponse.UserVO.fromUser(user));
    }

    @Operation(summary = "更新个人信息")
    @PutMapping("/profile")
    public Result<LoginResponse.UserVO> updateProfile(@Valid @RequestBody UpdateProfileRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        User user = userService.updateProfile(userId, request);
        return Result.success("更新成功", LoginResponse.UserVO.fromUser(user));
    }

    @Operation(summary = "修改密码")
    @PutMapping("/password")
    public Result<Void> updatePassword(@Valid @RequestBody UpdatePasswordRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        userService.updatePassword(userId, request);
        return Result.success("密码修改成功", null);
    }

    @Operation(summary = "上传头像")
    @PostMapping("/avatar")
    public Result<String> uploadAvatar(@RequestParam("file") MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            return Result.error("请选择文件");
        }
        
        // 检查文件类型
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return Result.error("只能上传图片文件");
        }
        
        // 生成文件名
        String originalFilename = file.getOriginalFilename();
        String ext = originalFilename != null && originalFilename.contains(".") 
                ? originalFilename.substring(originalFilename.lastIndexOf(".")) 
                : ".jpg";
        String filename = UUID.randomUUID().toString() + ext;
        
        // 保存文件
        String uploadDir = "./uploads/avatars";
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        
        File dest = new File(dir, filename);
        file.transferTo(dest);
        
        // 更新用户头像
        String avatarUrl = "/uploads/avatars/" + filename;
        Long userId = SecurityUtil.getCurrentUserId();
        userService.updateAvatar(userId, avatarUrl);
        
        return Result.success("上传成功", avatarUrl);
    }

    @Operation(summary = "用户签到")
    @PostMapping("/checkin")
    public Result<Void> checkIn() {
        Long userId = SecurityUtil.getCurrentUserId();
        userService.checkIn(userId);
        return Result.success("签到成功", null);
    }

    // ==================== 管理员接口 ====================

    @Operation(summary = "获取用户列表（管理员）")
    @GetMapping("/admin/list")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public Result<PageResult<User>> getUserList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) Integer status) {
        var pageResult = userService.getUserList(page, size, keyword, role, status);
        return Result.success(PageResult.of(pageResult));
    }

    @Operation(summary = "获取用户详情（管理员）")
    @GetMapping("/admin/{userId}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public Result<User> getUserDetail(@PathVariable Long userId) {
        User user = userService.getUserById(userId);
        return Result.success(user);
    }

    @Operation(summary = "更新用户状态（管理员）")
    @PutMapping("/admin/{userId}/status")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public Result<Void> updateUserStatus(
            @PathVariable Long userId,
            @RequestParam Integer status) {
        userService.updateUserStatus(userId, status);
        return Result.success("状态更新成功", null);
    }

    @Operation(summary = "加入黑名单（管理员）")
    @PostMapping("/admin/{userId}/blacklist")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Void> addToBlacklist(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "7") int days,
            @RequestParam(required = false) String reason) {
        userService.addToBlacklist(userId, days, reason != null ? reason : "管理员操作");
        return Result.success("已加入黑名单", null);
    }

    @Operation(summary = "移出黑名单（管理员）")
    @DeleteMapping("/admin/{userId}/blacklist")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public Result<Void> removeFromBlacklist(@PathVariable Long userId) {
        userService.removeFromBlacklist(userId);
        return Result.success("已移出黑名单", null);
    }
}
