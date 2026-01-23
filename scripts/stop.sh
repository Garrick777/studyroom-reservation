#!/bin/bash
# =====================================================
# 智慧自习室系统 - 停止服务脚本
# =====================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
BACKEND_PORT=9090
FRONTEND_PORT=3000

echo -e "${YELLOW}================================================${NC}"
echo -e "${YELLOW}   智慧自习室系统 - 停止服务${NC}"
echo -e "${YELLOW}================================================${NC}"
echo ""

# 函数: 杀死占用端口的进程
kill_port() {
    local port=$1
    local name=$2
    local pid=$(lsof -i:$port -t 2>/dev/null)
    if [ -n "$pid" ]; then
        echo -e "停止 $name (端口: $port, PID: $pid)..."
        kill -9 $pid 2>/dev/null || true
        echo -e "${GREEN}[✓] $name 已停止${NC}"
    else
        echo -e "${YELLOW}$name 未运行 (端口: $port)${NC}"
    fi
}

# 停止后端
kill_port $BACKEND_PORT "后端服务"

# 停止前端
kill_port $FRONTEND_PORT "前端服务"

# 杀死相关的Java和Node进程
echo ""
echo -e "${YELLOW}清理相关进程...${NC}"

# 杀死Spring Boot进程
SPRING_PIDS=$(pgrep -f "spring-boot:run" 2>/dev/null || true)
if [ -n "$SPRING_PIDS" ]; then
    echo "停止Spring Boot进程: $SPRING_PIDS"
    kill -9 $SPRING_PIDS 2>/dev/null || true
fi

# 杀死Vite进程
VITE_PIDS=$(pgrep -f "vite" 2>/dev/null || true)
if [ -n "$VITE_PIDS" ]; then
    echo "停止Vite进程: $VITE_PIDS"
    kill -9 $VITE_PIDS 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   所有服务已停止${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
