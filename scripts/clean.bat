@echo off
chcp 65001 >nul
:: =====================================================
:: 智慧自习室系统 - 清理脚本 (Windows)
:: 清理数据库、前后端依赖，恢复到初始状态
:: =====================================================

setlocal enabledelayedexpansion

:: 颜色设置
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

:: 配置
if not defined DB_USER set "DB_USER=root"
if not defined DB_PASS set "DB_PASS=123456789"
set "DB_NAME=studyroom"

:: 获取脚本目录
set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "BACKEND_DIR=%PROJECT_DIR%\backend"
set "FRONTEND_DIR=%PROJECT_DIR%\frontend"

echo %RED%================================================%NC%
echo %RED%   智慧自习室系统 - 清理 (Windows)%NC%
echo %RED%================================================%NC%
echo.
echo %YELLOW%警告: 此操作将删除:%NC%
echo   1. 数据库 %DB_NAME%
echo   2. 后端编译文件 (backend\target)
echo   3. 前端依赖 (frontend\node_modules)
echo   4. 日志文件
echo.

set /p confirm=确认要继续吗? [y/N] 
if /i not "%confirm%"=="y" (
    echo %YELLOW%已取消%NC%
    pause
    exit /b 0
)

echo.

:: =====================================================
:: 1. 停止服务
:: =====================================================
echo %YELLOW%[1/4] 停止运行中的服务...%NC%
call "%SCRIPT_DIR%stop.bat" >nul 2>&1
echo %GREEN%[√] 服务已停止%NC%

:: =====================================================
:: 2. 删除数据库
:: =====================================================
echo %YELLOW%[2/4] 删除数据库...%NC%
mysql -u%DB_USER% -p%DB_PASS% -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%[!] MySQL 未运行，跳过数据库删除%NC%
) else (
    mysql -u%DB_USER% -p%DB_PASS% -e "DROP DATABASE IF EXISTS %DB_NAME%;" 2>nul
    echo %GREEN%[√] 数据库 %DB_NAME% 已删除%NC%
)

:: =====================================================
:: 3. 删除后端编译文件
:: =====================================================
echo %YELLOW%[3/4] 清理后端...%NC%
if exist "%BACKEND_DIR%\target" (
    rmdir /s /q "%BACKEND_DIR%\target"
    echo %GREEN%[√] 后端 target 目录已删除%NC%
) else (
    echo %YELLOW%[!] 后端 target 目录不存在%NC%
)

:: 删除后端日志
del /f /q "%PROJECT_DIR%\backend.log" 2>nul
del /f /q "%BACKEND_DIR%\backend.log" 2>nul

:: =====================================================
:: 4. 删除前端依赖
:: =====================================================
echo %YELLOW%[4/4] 清理前端...%NC%
if exist "%FRONTEND_DIR%\node_modules" (
    rmdir /s /q "%FRONTEND_DIR%\node_modules"
    echo %GREEN%[√] 前端 node_modules 目录已删除%NC%
) else (
    echo %YELLOW%[!] 前端 node_modules 目录不存在%NC%
)

:: 删除前端日志和缓存
del /f /q "%PROJECT_DIR%\frontend.log" 2>nul
if exist "%FRONTEND_DIR%\.vite" rmdir /s /q "%FRONTEND_DIR%\.vite" 2>nul

echo.
echo %GREEN%================================================%NC%
echo %GREEN%   清理完成!%NC%
echo %GREEN%================================================%NC%
echo.
echo 要重新初始化项目，请执行:
echo   %BLUE%scripts\init_db.bat%NC%  # 初始化数据库
echo   %BLUE%scripts\start.bat%NC%    # 启动服务
echo.
pause
