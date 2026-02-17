#!/bin/bash
# =====================================================
# 智慧自习室系统 - 应用部署脚本
# =====================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置变量
APP_DIR="/opt/studyroom"
APP_USER="studyroom"
BACKEND_JAR="studyroom-backend.jar"
FRONTEND_DIST="dist"

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}   智慧自习室系统 - 应用部署${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

# 加载环境变量
if [ -f "$APP_DIR/env.sh" ]; then
    source "$APP_DIR/env.sh"
fi

# 停止现有服务
stop_services() {
    echo -e "${YELLOW}[1/6] 停止现有服务...${NC}"

    # 停止后端
    if [ -f "$APP_DIR/backend/app.pid" ]; then
        PID=$(cat "$APP_DIR/backend/app.pid")
        if ps -p $PID > /dev/null; then
            kill $PID
            echo -e "${GREEN}后端服务已停止${NC}"
        fi
    fi

    # 停止 Nginx（如果需要）
    # systemctl stop nginx

    echo -e "${GREEN}[✓] 服务停止完成${NC}"
}

# 备份现有版本
backup_current() {
    echo -e "${YELLOW}[2/6] 备份当前版本...${NC}"

    BACKUP_DIR="$APP_DIR/backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    if [ -f "$APP_DIR/backend/$BACKEND_JAR" ]; then
        cp "$APP_DIR/backend/$BACKEND_JAR" "$BACKUP_DIR/"
        echo -e "${GREEN}后端备份完成${NC}"
    fi

    if [ -d "$APP_DIR/frontend/dist" ]; then
        cp -r "$APP_DIR/frontend/dist" "$BACKUP_DIR/"
        echo -e "${GREEN}前端备份完成${NC}"
    fi

    echo -e "${GREEN}[✓] 备份完成: $BACKUP_DIR${NC}"
}

# 部署后端
deploy_backend() {
    echo -e "${YELLOW}[3/6] 部署后端...${NC}"

    cd "$APP_DIR/backend"

    # 构建后端
    if [ -f "pom.xml" ]; then
        echo -e "${YELLOW}构建后端项目...${NC}"
        mvn clean package -DskipTests
        cp target/*.jar "$BACKEND_JAR"
    fi

    # 导入数据库
    if [ -f "src/main/resources/db/schema.sql" ]; then
        echo -e "${YELLOW}导入数据库结构...${NC}"
        mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < src/main/resources/db/schema.sql
    fi

    if [ -f "src/main/resources/db/init_data.sql" ]; then
        echo -e "${YELLOW}导入初始数据...${NC}"
        mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < src/main/resources/db/init_data.sql
    fi

    echo -e "${GREEN}[✓] 后端部署完成${NC}"
}

# 部署前端
deploy_frontend() {
    echo -e "${YELLOW}[4/6] 部署前端...${NC}"

    cd "$APP_DIR/frontend"

    # 构建前端
    if [ -f "package.json" ]; then
        echo -e "${YELLOW}安装依赖...${NC}"
        npm install

        echo -e "${YELLOW}构建前端项目...${NC}"
        npm run build

        # 复制到 Nginx 目录
        rm -rf /usr/share/nginx/html/studyroom
        mkdir -p /usr/share/nginx/html/studyroom
        cp -r dist/* /usr/share/nginx/html/studyroom/
    fi

    echo -e "${GREEN}[✓] 前端部署完成${NC}"
}

# 配置 Nginx
configure_nginx() {
    echo -e "${YELLOW}[5/6] 配置 Nginx...${NC}"

    cat > /etc/nginx/conf.d/studyroom.conf <<'EOF'
server {
    listen 80;
    server_name _;

    # 前端静态文件（子路径访问）
    location /studyroom {
        alias /usr/share/nginx/html/studyroom;
        try_files $uri $uri/ /studyroom/index.html;
        index index.html;

        # 缓存配置
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # 后端 API 代理
    location /api {
        proxy_pass http://localhost:9090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket 支持
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript
               application/x-javascript application/xml+rss
               application/json application/javascript;
}
EOF

    # 测试配置
    nginx -t

    # 重启 Nginx
    systemctl restart nginx

    echo -e "${GREEN}[✓] Nginx 配置完成${NC}"
}

# 启动服务
start_services() {
    echo -e "${YELLOW}[6/6] 启动服务...${NC}"

    cd "$APP_DIR/backend"

    # 启动后端
    nohup java $JAVA_OPTS -jar "$BACKEND_JAR" \
        --spring.profiles.active=prod \
        --spring.datasource.url=jdbc:mysql://localhost:3306/$DB_NAME \
        --spring.datasource.username=$DB_USER \
        --spring.datasource.password=$DB_PASSWORD \
        --spring.data.redis.host=$REDIS_HOST \
        --spring.data.redis.port=$REDIS_PORT \
        --spring.data.redis.password=$REDIS_PASSWORD \
        > "$APP_DIR/logs/backend.log" 2>&1 &

    echo $! > "$APP_DIR/backend/app.pid"

    # 等待启动
    echo -e "${YELLOW}等待后端启动...${NC}"
    for i in {1..30}; do
        if curl -s http://localhost:9090/api/health > /dev/null 2>&1; then
            echo -e "${GREEN}后端启动成功${NC}"
            break
        fi
        sleep 1
        printf "."
    done
    echo ""

    echo -e "${GREEN}[✓] 服务启动完成${NC}"
}

# 显示状态
show_status() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}   部署完成！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${CYAN}服务状态：${NC}"

    # 检查后端
    if curl -s http://localhost:9090/api/health > /dev/null 2>&1; then
        echo -e "  后端: ${GREEN}运行中${NC}"
    else
        echo -e "  后端: ${RED}未运行${NC}"
    fi

    # 检查 Nginx
    if systemctl is-active --quiet nginx; then
        echo -e "  Nginx: ${GREEN}运行中${NC}"
    else
        echo -e "  Nginx: ${RED}未运行${NC}"
    fi

    echo ""
    echo -e "${CYAN}访问地址：${NC}"
    echo -e "  前端: ${YELLOW}http://$(hostname -I | awk '{print $1}')/studyroom${NC}"
    echo -e "  后端: ${YELLOW}http://$(hostname -I | awk '{print $1}'):9090${NC}"
    echo -e "  API文档: ${YELLOW}http://$(hostname -I | awk '{print $1}'):9090/doc.html${NC}"
    echo ""
    echo -e "${CYAN}日志文件：${NC}"
    echo -e "  ${YELLOW}$APP_DIR/logs/backend.log${NC}"
    echo ""
}

# 主函数
main() {
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}请使用 root 用户运行此脚本${NC}"
        exit 1
    fi

    stop_services
    backup_current
    deploy_backend
    deploy_frontend
    configure_nginx
    start_services
    show_status
}

main "$@"
