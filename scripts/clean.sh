#!/bin/bash
# =====================================================
# 智慧自习室系统 - 清理脚本
# 清理数据库、前后端依赖，恢复到初始状态
# =====================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-123456789}"
DB_NAME="studyroom"

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"

echo -e "${RED}================================================${NC}"
echo -e "${RED}   智慧自习室系统 - 清理${NC}"
echo -e "${RED}================================================${NC}"
echo ""
echo -e "${YELLOW}警告: 此操作将删除:${NC}"
echo "  1. 数据库 $DB_NAME"
echo "  2. 后端编译文件 (backend/target)"
echo "  3. 前端依赖 (frontend/node_modules)"
echo "  4. 日志文件"
echo ""
read -p "确认要继续吗? [y/N] " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}已取消${NC}"
    exit 0
fi

echo ""

# =====================================================
# 1. 停止服务
# =====================================================
echo -e "${YELLOW}[1/4] 停止运行中的服务...${NC}"
"$SCRIPT_DIR/stop.sh" 2>/dev/null || true
echo -e "${GREEN}[✓] 服务已停止${NC}"

# =====================================================
# 2. 删除数据库
# =====================================================
echo -e "${YELLOW}[2/4] 删除数据库...${NC}"
if mysqladmin ping -u"$DB_USER" -p"$DB_PASS" --silent 2>/dev/null; then
    mysql -u"$DB_USER" -p"$DB_PASS" -e "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null
    echo -e "${GREEN}[✓] 数据库 $DB_NAME 已删除${NC}"
else
    echo -e "${YELLOW}[!] MySQL未运行，跳过数据库删除${NC}"
fi

# =====================================================
# 3. 删除后端编译文件
# =====================================================
echo -e "${YELLOW}[3/4] 清理后端...${NC}"
if [ -d "$BACKEND_DIR/target" ]; then
    rm -rf "$BACKEND_DIR/target"
    echo -e "${GREEN}[✓] 后端target目录已删除${NC}"
else
    echo -e "${YELLOW}[!] 后端target目录不存在${NC}"
fi

# 删除后端日志
rm -f "$PROJECT_DIR/backend.log" "$BACKEND_DIR/backend.log" 2>/dev/null || true

# =====================================================
# 4. 删除前端依赖
# =====================================================
echo -e "${YELLOW}[4/4] 清理前端...${NC}"
if [ -d "$FRONTEND_DIR/node_modules" ]; then
    rm -rf "$FRONTEND_DIR/node_modules"
    echo -e "${GREEN}[✓] 前端node_modules目录已删除${NC}"
else
    echo -e "${YELLOW}[!] 前端node_modules目录不存在${NC}"
fi

# 删除前端日志和缓存
rm -f "$PROJECT_DIR/frontend.log" 2>/dev/null || true
rm -rf "$FRONTEND_DIR/.vite" 2>/dev/null || true

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   清理完成!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "要重新初始化项目，请执行:"
echo -e "  ${BLUE}./scripts/init_db.sh${NC}  # 初始化数据库"
echo -e "  ${BLUE}./scripts/start.sh${NC}    # 启动服务"
echo ""
