#!/bin/bash
# =====================================================
# 智慧自习室系统 - 一键启动脚本
# =====================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"

# 配置
BACKEND_PORT=9090
FRONTEND_PORT=3000

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}   智慧自习室系统 - 一键启动${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

# 函数: 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -i:$port -t > /dev/null 2>&1; then
        return 0  # 端口被占用
    else
        return 1  # 端口空闲
    fi
}

# 函数: 杀死占用端口的进程
kill_port() {
    local port=$1
    local pid=$(lsof -i:$port -t 2>/dev/null)
    if [ -n "$pid" ]; then
        echo -e "${YELLOW}端口 $port 被进程 $pid 占用，正在关闭...${NC}"
        kill -9 $pid 2>/dev/null || true
        sleep 1
    fi
}

# =====================================================
# 0. 自动设置JAVA_HOME (macOS)
# =====================================================
if [ -z "$JAVA_HOME" ]; then
    if [ -x /usr/libexec/java_home ]; then
        export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
        echo -e "${YELLOW}自动设置 JAVA_HOME: $JAVA_HOME${NC}"
    fi
fi

# =====================================================
# 1. 检查并释放端口
# =====================================================
echo -e "${YELLOW}[1/4] 检查端口...${NC}"
if check_port $BACKEND_PORT; then
    kill_port $BACKEND_PORT
fi
if check_port $FRONTEND_PORT; then
    kill_port $FRONTEND_PORT
fi
echo -e "${GREEN}[✓] 端口检查完成${NC}"

# =====================================================
# 2. 检查依赖
# =====================================================
echo -e "${YELLOW}[2/4] 检查依赖...${NC}"

# 检查Java
if ! command -v java &> /dev/null; then
    echo -e "${RED}[错误] Java未安装${NC}"
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | head -n 1)
echo -e "  Java: ${GREEN}已安装${NC} - $JAVA_VERSION"

# 检查Maven
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}[错误] Maven未安装${NC}"
    exit 1
fi
MVN_VERSION=$(mvn -v 2>&1 | head -n 1)
echo -e "  Maven: ${GREEN}已安装${NC} - $MVN_VERSION"

# 检查Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}[错误] Node.js未安装${NC}"
    exit 1
fi
NODE_VERSION=$(node -v)
echo -e "  Node.js: ${GREEN}已安装${NC} - $NODE_VERSION"

# 检查npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}[错误] npm未安装${NC}"
    exit 1
fi
NPM_VERSION=$(npm -v)
echo -e "  npm: ${GREEN}已安装${NC} - $NPM_VERSION"

echo -e "${GREEN}[✓] 依赖检查完成${NC}"

# =====================================================
# 3. 启动后端
# =====================================================
echo -e "${YELLOW}[3/4] 启动后端服务...${NC}"
cd "$BACKEND_DIR"

# 检查是否需要编译
if [ ! -d "target/classes" ]; then
    echo -e "${YELLOW}  编译后端项目...${NC}"
    mvn clean compile -q -DskipTests 2>&1 | head -5
fi

# 启动后端
echo -e "  启动Spring Boot (端口: $BACKEND_PORT)..."
nohup mvn spring-boot:run -DskipTests > "$PROJECT_DIR/backend.log" 2>&1 &
BACKEND_PID=$!

# 等待后端启动
echo -e "  等待后端启动..."
for i in {1..60}; do
    if curl -s http://localhost:$BACKEND_PORT/api/health > /dev/null 2>&1; then
        echo -e "${GREEN}[✓] 后端启动成功 (PID: $BACKEND_PID)${NC}"
        break
    fi
    if [ $i -eq 60 ]; then
        echo -e "${RED}[错误] 后端启动超时，请检查日志: $PROJECT_DIR/backend.log${NC}"
        exit 1
    fi
    sleep 1
    printf "."
done
echo ""

# =====================================================
# 4. 启动前端
# =====================================================
echo -e "${YELLOW}[4/4] 启动前端服务...${NC}"
cd "$FRONTEND_DIR"

# 检查是否需要安装依赖
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}  安装前端依赖...${NC}"
    npm install --silent 2>&1 | tail -3
fi

# 启动前端
echo -e "  启动Vite开发服务器 (端口: $FRONTEND_PORT)..."
nohup npm run dev > "$PROJECT_DIR/frontend.log" 2>&1 &
FRONTEND_PID=$!

# 等待前端启动
echo -e "  等待前端启动..."
for i in {1..30}; do
    if curl -s http://localhost:$FRONTEND_PORT > /dev/null 2>&1; then
        echo -e "${GREEN}[✓] 前端启动成功 (PID: $FRONTEND_PID)${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}[错误] 前端启动超时，请检查日志: $PROJECT_DIR/frontend.log${NC}"
        exit 1
    fi
    sleep 1
    printf "."
done
echo ""

# =====================================================
# 完成
# =====================================================
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   系统启动完成!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "前端地址: ${BLUE}http://localhost:$FRONTEND_PORT${NC}"
echo -e "后端地址: ${BLUE}http://localhost:$BACKEND_PORT${NC}"
echo -e "API文档:  ${BLUE}http://localhost:$BACKEND_PORT/doc.html${NC}"
echo ""
echo -e "日志文件:"
echo -e "  后端: ${YELLOW}$PROJECT_DIR/backend.log${NC}"
echo -e "  前端: ${YELLOW}$PROJECT_DIR/frontend.log${NC}"
echo ""
echo -e "默认账号 (密码: ${YELLOW}123456${NC}):"
echo -e "  学生:       ${BLUE}zhangsan${NC}"
echo -e "  管理员:     ${BLUE}admin1${NC}"
echo -e "  超级管理员: ${BLUE}superadmin${NC}"
echo ""
echo -e "${YELLOW}使用 ./scripts/stop.sh 停止所有服务${NC}"
echo ""
