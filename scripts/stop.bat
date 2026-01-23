@echo off
chcp 65001 >nul
:: =====================================================
:: 智慧自习室系统 - 停止服务脚本 (Windows)
:: =====================================================

setlocal enabledelayedexpansion

:: 颜色设置
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

:: 配置
set "BACKEND_PORT=9090"
set "FRONTEND_PORT=3000"

echo %YELLOW%================================================%NC%
echo %YELLOW%   智慧自习室系统 - 停止服务 (Windows)%NC%
echo %YELLOW%================================================%NC%
echo.

:: 停止后端 (端口 9090)
echo 正在停止后端服务 (端口: %BACKEND_PORT%)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%BACKEND_PORT% " ^| findstr "LISTENING"') do (
    echo   停止进程 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
)
echo %GREEN%[√] 后端服务已停止%NC%

:: 停止前端 (端口 3000)
echo 正在停止前端服务 (端口: %FRONTEND_PORT%)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%FRONTEND_PORT% " ^| findstr "LISTENING"') do (
    echo   停止进程 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
)
echo %GREEN%[√] 前端服务已停止%NC%

:: 停止所有 Java 进程 (Spring Boot)
echo.
echo %YELLOW%清理相关进程...%NC%
for /f "tokens=2" %%a in ('tasklist /fi "imagename eq java.exe" /fo list ^| findstr "PID"') do (
    echo   停止 Java 进程 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
)

:: 停止 Node 进程
for /f "tokens=2" %%a in ('tasklist /fi "imagename eq node.exe" /fo list ^| findstr "PID"') do (
    echo   停止 Node 进程 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
)

:: 关闭相关命令窗口
taskkill /F /FI "WINDOWTITLE eq StudyRoom-Backend*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq StudyRoom-Frontend*" >nul 2>&1

echo.
echo %GREEN%================================================%NC%
echo %GREEN%   所有服务已停止%NC%
echo %GREEN%================================================%NC%
echo.
pause
