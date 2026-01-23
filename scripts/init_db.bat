@echo off
chcp 65001 >nul
:: =====================================================
:: 智慧自习室系统 - 数据库初始化脚本 (Windows)
:: =====================================================

setlocal enabledelayedexpansion

:: 颜色设置
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "BLUE=[94m"
set "NC=[0m"

:: 配置 (可通过环境变量覆盖)
if not defined DB_USER set "DB_USER=root"
if not defined DB_PASS set "DB_PASS=123456789"
set "DB_NAME=studyroom"

:: 获取脚本目录
set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "SQL_FILE=%PROJECT_DIR%\sql\studyroom_full.sql"

echo %BLUE%================================================%NC%
echo %BLUE%   智慧自习室系统 - 数据库初始化 (Windows)%NC%
echo %BLUE%================================================%NC%
echo.

:: 检查 SQL 文件是否存在
if not exist "%SQL_FILE%" (
    echo %RED%[错误] SQL 文件不存在: %SQL_FILE%%NC%
    pause
    exit /b 1
)

:: 检查 MySQL 是否安装
where mysql >nul 2>&1
if errorlevel 1 (
    echo %RED%[错误] MySQL 客户端未安装%NC%
    echo 请确保 MySQL 已安装并添加到 PATH 环境变量
    pause
    exit /b 1
)

:: 检查 MySQL 服务是否运行
echo %YELLOW%[1/4] 检查 MySQL 服务...%NC%
mysql -u%DB_USER% -p%DB_PASS% -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo %RED%[错误] MySQL 服务未运行或密码错误%NC%
    echo.
    echo %YELLOW%请检查:%NC%
    echo   1. MySQL 服务是否已启动
    echo   2. 数据库用户名和密码是否正确
    echo.
    echo 您可以使用以下环境变量设置数据库连接:
    echo   set DB_USER=root
    echo   set DB_PASS=yourpassword
    echo   init_db.bat
    pause
    exit /b 1
)
echo %GREEN%[√] MySQL 服务正常%NC%

:: 删除旧数据库
echo %YELLOW%[2/4] 删除旧数据库 (如果存在)...%NC%
mysql -u%DB_USER% -p%DB_PASS% -e "DROP DATABASE IF EXISTS %DB_NAME%;" 2>nul
echo %GREEN%[√] 旧数据库已删除%NC%

:: 导入 SQL
echo %YELLOW%[3/4] 导入数据库...%NC%
mysql -u%DB_USER% -p%DB_PASS% --default-character-set=utf8mb4 < "%SQL_FILE%" 2>nul
if errorlevel 1 (
    echo %RED%[错误] 数据库导入失败%NC%
    pause
    exit /b 1
)
echo %GREEN%[√] 数据库导入成功%NC%

:: 验证数据
echo %YELLOW%[4/4] 验证数据...%NC%
for /f %%i in ('mysql -u%DB_USER% -p%DB_PASS% -N -e "SELECT COUNT(*) FROM %DB_NAME%.user;" 2^>nul') do set "USER_COUNT=%%i"
for /f %%i in ('mysql -u%DB_USER% -p%DB_PASS% -N -e "SELECT COUNT(*) FROM %DB_NAME%.study_room;" 2^>nul') do set "ROOM_COUNT=%%i"
for /f %%i in ('mysql -u%DB_USER% -p%DB_PASS% -N -e "SELECT COUNT(*) FROM %DB_NAME%.seat;" 2^>nul') do set "SEAT_COUNT=%%i"

echo.
echo %GREEN%================================================%NC%
echo %GREEN%   数据库初始化完成!%NC%
echo %GREEN%================================================%NC%
echo.
echo 数据库名称: %BLUE%%DB_NAME%%NC%
echo 用户数量:   %BLUE%%USER_COUNT%%NC%
echo 自习室数量: %BLUE%%ROOM_COUNT%%NC%
echo 座位数量:   %BLUE%%SEAT_COUNT%%NC%
echo.
echo 默认账号 (密码均为: %YELLOW%123456%NC%):
echo   学生:       %BLUE%zhangsan%NC%
echo   管理员:     %BLUE%admin1%NC%
echo   超级管理员: %BLUE%superadmin%NC%
echo.
pause
