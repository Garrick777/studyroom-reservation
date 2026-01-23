@echo off
chcp 65001 >nul
:: =====================================================
:: 智慧自习室系统 - 一键启动脚本 (Windows)
:: =====================================================

setlocal enabledelayedexpansion

:: 颜色设置
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "CYAN=[96m"
set "NC=[0m"

:: 获取脚本目录
set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "BACKEND_DIR=%PROJECT_DIR%\backend"
set "FRONTEND_DIR=%PROJECT_DIR%\frontend"

:: 配置
set "BACKEND_PORT=9090"
set "FRONTEND_PORT=3000"

echo %CYAN%================================================%NC%
echo %CYAN%   智慧自习室系统 - 一键启动 (Windows)%NC%
echo %CYAN%================================================%NC%
echo.

:: =====================================================
:: 0. 检查并设置 JAVA_HOME
:: =====================================================
if not defined JAVA_HOME (
    echo %YELLOW%JAVA_HOME 未设置，尝试自动检测...%NC%
    for /f "tokens=*" %%i in ('where java 2^>nul') do (
        set "JAVA_PATH=%%i"
        goto :found_java
    )
    echo %RED%[错误] 未找到 Java，请安装 JDK 并设置 JAVA_HOME%NC%
    pause
    exit /b 1
)
:found_java
echo %YELLOW%JAVA_HOME: %JAVA_HOME%%NC%
echo.

:: =====================================================
:: 1. 检查并释放端口
:: =====================================================
echo %YELLOW%[1/4] 检查端口...%NC%

:: 检查后端端口
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%BACKEND_PORT% " ^| findstr "LISTENING"') do (
    echo %YELLOW%端口 %BACKEND_PORT% 被进程 %%a 占用，正在关闭...%NC%
    taskkill /F /PID %%a >nul 2>&1
)

:: 检查前端端口
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%FRONTEND_PORT% " ^| findstr "LISTENING"') do (
    echo %YELLOW%端口 %FRONTEND_PORT% 被进程 %%a 占用，正在关闭...%NC%
    taskkill /F /PID %%a >nul 2>&1
)

echo %GREEN%[√] 端口检查完成%NC%

:: =====================================================
:: 2. 检查依赖
:: =====================================================
echo %YELLOW%[2/4] 检查依赖...%NC%

:: 检查 Java
where java >nul 2>&1
if errorlevel 1 (
    echo %RED%[错误] Java 未安装%NC%
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    echo   Java: %GREEN%已安装%NC% - %%i
    goto :java_done
)
:java_done

:: 检查 Maven
where mvn >nul 2>&1
if errorlevel 1 (
    echo %RED%[错误] Maven 未安装%NC%
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('mvn -v 2^>^&1 ^| findstr /i "Apache Maven"') do (
    echo   Maven: %GREEN%已安装%NC% - %%i
    goto :mvn_done
)
:mvn_done

:: 检查 Node.js
where node >nul 2>&1
if errorlevel 1 (
    echo %RED%[错误] Node.js 未安装%NC%
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node -v') do echo   Node.js: %GREEN%已安装%NC% - %%i

:: 检查 npm
where npm >nul 2>&1
if errorlevel 1 (
    echo %RED%[错误] npm 未安装%NC%
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm -v') do echo   npm: %GREEN%已安装%NC% - %%i

echo %GREEN%[√] 依赖检查完成%NC%

:: =====================================================
:: 3. 启动后端
:: =====================================================
echo %YELLOW%[3/4] 启动后端服务...%NC%
cd /d "%BACKEND_DIR%"

:: 检查是否需要编译
if not exist "target\classes" (
    echo %YELLOW%  编译后端项目...%NC%
    call mvn clean compile -q -DskipTests
)

:: 启动后端 (新窗口)
echo   启动 Spring Boot (端口: %BACKEND_PORT%)...
start "StudyRoom-Backend" cmd /c "mvn spring-boot:run -DskipTests > "%PROJECT_DIR%\backend.log" 2>&1"

:: 等待后端启动
echo   等待后端启动...
set /a count=0
:wait_backend
set /a count+=1
if %count% gtr 60 (
    echo %RED%[错误] 后端启动超时，请检查日志: %PROJECT_DIR%\backend.log%NC%
    pause
    exit /b 1
)
timeout /t 1 /nobreak >nul
curl -s http://localhost:%BACKEND_PORT%/api/health >nul 2>&1
if errorlevel 1 (
    echo|set /p=.
    goto :wait_backend
)
echo.
echo %GREEN%[√] 后端启动成功%NC%

:: =====================================================
:: 4. 启动前端
:: =====================================================
echo %YELLOW%[4/4] 启动前端服务...%NC%
cd /d "%FRONTEND_DIR%"

:: 检查是否需要安装依赖
if not exist "node_modules" (
    echo %YELLOW%  安装前端依赖...%NC%
    call npm install --silent
)

:: 启动前端 (新窗口)
echo   启动 Vite 开发服务器 (端口: %FRONTEND_PORT%)...
start "StudyRoom-Frontend" cmd /c "npm run dev > "%PROJECT_DIR%\frontend.log" 2>&1"

:: 等待前端启动
echo   等待前端启动...
set /a count=0
:wait_frontend
set /a count+=1
if %count% gtr 30 (
    echo %RED%[错误] 前端启动超时，请检查日志: %PROJECT_DIR%\frontend.log%NC%
    pause
    exit /b 1
)
timeout /t 1 /nobreak >nul
curl -s http://localhost:%FRONTEND_PORT% >nul 2>&1
if errorlevel 1 (
    echo|set /p=.
    goto :wait_frontend
)
echo.
echo %GREEN%[√] 前端启动成功%NC%

:: =====================================================
:: 完成
:: =====================================================
echo.
echo %GREEN%================================================%NC%
echo %GREEN%   系统启动完成!%NC%
echo %GREEN%================================================%NC%
echo.
echo 前端地址: %BLUE%http://localhost:%FRONTEND_PORT%%NC%
echo 后端地址: %BLUE%http://localhost:%BACKEND_PORT%%NC%
echo API文档:  %BLUE%http://localhost:%BACKEND_PORT%/doc.html%NC%
echo.
echo 日志文件:
echo   后端: %YELLOW%%PROJECT_DIR%\backend.log%NC%
echo   前端: %YELLOW%%PROJECT_DIR%\frontend.log%NC%
echo.
echo 默认账号 (密码: %YELLOW%123456%NC%):
echo   学生:       %BLUE%zhangsan%NC%
echo   管理员:     %BLUE%admin1%NC%
echo   超级管理员: %BLUE%superadmin%NC%
echo.
echo %YELLOW%使用 scripts\stop.bat 停止所有服务%NC%
echo.
pause
