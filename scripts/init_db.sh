#!/bin/bash
# =====================================================
# 智慧自习室系统 - 数据库初始化脚本
# =====================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-123456789}"
DB_NAME="studyroom"
SQL_FILE="../sql/studyroom_full.sql"

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   智慧自习室系统 - 数据库初始化${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# 检查SQL文件是否存在
if [ ! -f "$PROJECT_DIR/sql/studyroom_full.sql" ]; then
    echo -e "${RED}[错误] SQL文件不存在: $PROJECT_DIR/sql/studyroom_full.sql${NC}"
    exit 1
fi

# 检查MySQL是否安装
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}[错误] MySQL客户端未安装${NC}"
    exit 1
fi

# 检查MySQL服务是否运行
echo -e "${YELLOW}[1/4] 检查MySQL服务...${NC}"
if ! mysqladmin ping -u"$DB_USER" -p"$DB_PASS" --silent 2>/dev/null; then
    echo -e "${RED}[错误] MySQL服务未运行或密码错误${NC}"
    echo -e "${YELLOW}请检查:${NC}"
    echo "  1. MySQL服务是否已启动"
    echo "  2. 数据库用户名和密码是否正确"
    echo ""
    echo "您可以使用以下环境变量设置数据库连接:"
    echo "  DB_USER=root DB_PASS=yourpassword ./init_db.sh"
    exit 1
fi
echo -e "${GREEN}[✓] MySQL服务正常${NC}"

# 删除旧数据库
echo -e "${YELLOW}[2/4] 删除旧数据库(如果存在)...${NC}"
mysql -u"$DB_USER" -p"$DB_PASS" -e "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null
echo -e "${GREEN}[✓] 旧数据库已删除${NC}"

# 导入SQL
echo -e "${YELLOW}[3/4] 导入数据库...${NC}"
mysql -u"$DB_USER" -p"$DB_PASS" --default-character-set=utf8mb4 < "$PROJECT_DIR/sql/studyroom_full.sql" 2>/dev/null
echo -e "${GREEN}[✓] 数据库导入成功${NC}"

# 验证数据
echo -e "${YELLOW}[4/4] 验证数据...${NC}"
USER_COUNT=$(mysql -u"$DB_USER" -p"$DB_PASS" -N -e "SELECT COUNT(*) FROM $DB_NAME.user;" 2>/dev/null)
ROOM_COUNT=$(mysql -u"$DB_USER" -p"$DB_PASS" -N -e "SELECT COUNT(*) FROM $DB_NAME.study_room;" 2>/dev/null)
SEAT_COUNT=$(mysql -u"$DB_USER" -p"$DB_PASS" -N -e "SELECT COUNT(*) FROM $DB_NAME.seat;" 2>/dev/null)

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   数据库初始化完成!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "数据库名称: ${BLUE}$DB_NAME${NC}"
echo -e "用户数量:   ${BLUE}$USER_COUNT${NC}"
echo -e "自习室数量: ${BLUE}$ROOM_COUNT${NC}"
echo -e "座位数量:   ${BLUE}$SEAT_COUNT${NC}"
echo ""
echo -e "默认账号 (密码均为: ${YELLOW}123456${NC}):"
echo -e "  学生:       ${BLUE}zhangsan${NC}"
echo -e "  管理员:     ${BLUE}admin1${NC}"
echo -e "  超级管理员: ${BLUE}superadmin${NC}"
echo ""
