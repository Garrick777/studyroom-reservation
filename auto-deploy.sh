#!/bin/bash
# =====================================================
# 一键自动部署脚本（Git克隆方式）
# 使用方法：
# 1. 先提交代码到GitHub
# 2. 填写 deploy-config.sh 中的配置
# 3. 运行: ./auto-deploy.sh
# =====================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}   智慧自习室系统 - 一键自动部署${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

# 检查配置文件
if [ ! -f "deploy-config.sh" ]; then
    echo -e "${RED}错误: 未找到 deploy-config.sh 配置文件${NC}"
    echo -e "${YELLOW}请确保 deploy-config.sh 文件存在并已配置${NC}"
    exit 1
fi

# 加载配置
source deploy-config.sh

echo -e "${GREEN}✓ 配置文件加载成功${NC}"
echo ""

# 验证必需配置
if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" = "你的服务器IP" ]; then
    echo -e "${RED}错误: 请在 deploy-config.sh 中配置 SERVER_IP${NC}"
    exit 1
fi

# Git仓库URL
GIT_REPO="https://github.com/Garrick777/studyroom-reservation.git"
GIT_BRANCH="main"

echo -e "${YELLOW}[1/7] 连接到服务器并克隆项目...${NC}"

ssh "$SERVER_USER@$SERVER_IP" << EOF
    set -e

    # 检查项目目录是否存在
    if [ -d "/opt/studyroom" ]; then
        echo "项目目录已存在，拉取最新代码..."
        cd /opt/studyroom
        git pull origin $GIT_BRANCH
    else
        echo "克隆项目..."
        cd /opt
        git clone -b $GIT_BRANCH $GIT_REPO studyroom
    fi

    cd /opt/studyroom
    chmod +x scripts/*.sh
    echo "✓ 项目代码准备完成"
EOF

echo -e "${GREEN}✓ 项目克隆/更新完成${NC}"
echo ""

echo -e "${YELLOW}[2/7] 创建生产环境配置文件...${NC}"

# 创建临时配置文件
TEMP_CONFIG=$(mktemp)

cat > "$TEMP_CONFIG" << EOF
server:
  port: $APP_PORT
  servlet:
    context-path: /api

spring:
  application:
    name: studyroom-system

  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://$DB_HOST:$DB_PORT/$DB_NAME?useUnicode=true&characterEncoding=UTF-8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true&connectionCollation=utf8mb4_unicode_ci
    username: $DB_USER
    password: $DB_PASSWORD
    hikari:
      minimum-idle: 5
      maximum-pool-size: 20
      idle-timeout: 30000
      pool-name: StudyRoomHikariCP
      max-lifetime: 1800000
      connection-timeout: 30000

  data:
    redis:
      host: $REDIS_HOST
      port: $REDIS_PORT
      password: $REDIS_PASSWORD
      database: 0
      timeout: 10000ms
      lettuce:
        pool:
          max-active: 8
          max-wait: -1ms
          max-idle: 8
          min-idle: 0

  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: Asia/Shanghai
    serialization:
      write-dates-as-timestamps: false
    default-property-inclusion: non_null

  servlet:
    multipart:
      max-file-size: 10MB
      max-request-size: 20MB

mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: com.studyroom.entity
  global-config:
    db-config:
      id-type: auto
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0
      insert-strategy: not_null
      update-strategy: not_null
  configuration:
    map-underscore-to-camel-case: true
    cache-enabled: true
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl

jwt:
  secret: $JWT_SECRET
  expiration: 86400000
  refresh-expiration: 604800000
  header: Authorization
  prefix: "Bearer "

springdoc:
  swagger-ui:
    enabled: false
  api-docs:
    enabled: false

knife4j:
  enable: false

logging:
  level:
    root: INFO
    com.studyroom: INFO
    com.studyroom.mapper: WARN
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: /opt/studyroom/logs/backend.log
    max-size: 100MB
    max-history: 30

upload:
  path: /opt/studyroom/uploads
  avatar-path: /avatars
  image-path: /images

studyroom:
  reservation:
    advance-days: 7
    max-per-day: 3
    cancel-limit-minutes: 30
  checkin:
    early-minutes: 15
    late-minutes: 15
    timeout-minutes: 30
  leave:
    max-minutes: 30
    max-count: 3
  credit:
    default-score: 100
    min-score: 0
    max-score: 100
    no-show-penalty: 10
    late-cancel-penalty: 5
    overtime-leave-penalty: 3
  blacklist:
    threshold: 60
    duration-days: 7
EOF

# 上传配置文件
scp "$TEMP_CONFIG" "$SERVER_USER@$SERVER_IP:/opt/studyroom/backend/src/main/resources/application-prod.yml"
rm "$TEMP_CONFIG"

echo -e "${GREEN}✓ 配置文件创建完成${NC}"
echo ""

echo -e "${YELLOW}[3/7] 安装运行环境...${NC}"

ssh "$SERVER_USER@$SERVER_IP" << EOF
    set -e
    cd /opt/studyroom

    # 检查是否已安装环境
    if command -v java &> /dev/null && command -v mysql &> /dev/null && command -v node &> /dev/null; then
        echo "环境已安装，跳过安装步骤"
    else
        echo "开始安装环境..."
        sudo ./scripts/server-setup.sh
    fi
EOF

echo -e "${GREEN}✓ 环境检查完成${NC}"
echo ""

echo -e "${YELLOW}[4/7] 配置数据库...${NC}"

ssh "$SERVER_USER@$SERVER_IP" << EOF
    set -e

    # 检查数据库是否存在
    if mysql -u root -p"$DB_ROOT_PASSWORD" -e "USE $DB_NAME" 2>/dev/null; then
        echo "数据库 $DB_NAME 已存在"
    else
        echo "创建数据库和用户..."
        mysql -u root -p"$DB_ROOT_PASSWORD" << SQL
CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
SQL
        echo "✓ 数据库创建完成"
    fi
EOF

echo -e "${GREEN}✓ 数据库配置完成${NC}"
echo ""

echo -e "${YELLOW}[5/7] 部署应用...${NC}"

ssh "$SERVER_USER@$SERVER_IP" << EOF
    set -e
    cd /opt/studyroom

    # 设置环境变量
    export DB_USER=$DB_USER
    export DB_PASSWORD=$DB_PASSWORD
    export DB_NAME=$DB_NAME
    export REDIS_HOST=$REDIS_HOST
    export REDIS_PORT=$REDIS_PORT
    export REDIS_PASSWORD=$REDIS_PASSWORD

    # 运行部署脚本
    sudo -E ./scripts/deploy.sh
EOF

echo -e "${GREEN}✓ 应用部署完成${NC}"
echo ""

echo -e "${YELLOW}[6/7] 配置域名...${NC}"

if [ ! -z "$DOMAIN_NAME" ]; then
    ssh "$SERVER_USER@$SERVER_IP" << EOF
        set -e

        # 更新Nginx配置中的域名
        sudo sed -i 's/server_name _;/server_name $DOMAIN_NAME www.$DOMAIN_NAME;/' /etc/nginx/conf.d/studyroom.conf

        # 测试配置
        sudo nginx -t

        # 重启Nginx
        sudo systemctl restart nginx

        echo "✓ 域名配置完成: $DOMAIN_NAME"
EOF
fi

echo -e "${GREEN}✓ 域名配置完成${NC}"
echo ""

echo -e "${YELLOW}[7/7] 验证部署...${NC}"

ssh "$SERVER_USER@$SERVER_IP" << 'EOF'
    set -e

    # 等待服务启动
    echo "等待服务启动..."
    sleep 5

    # 检查后端
    if curl -s http://localhost:9090/api/health > /dev/null 2>&1; then
        echo "✓ 后端服务运行正常"
    else
        echo "⚠ 后端服务可能未启动，请检查日志"
    fi

    # 检查Nginx
    if systemctl is-active --quiet nginx; then
        echo "✓ Nginx运行正常"
    else
        echo "⚠ Nginx未运行"
    fi
EOF

echo -e "${GREEN}✓ 部署验证完成${NC}"
echo ""

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   部署完成！${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${CYAN}访问地址：${NC}"
echo -e "  前端: ${YELLOW}http://$DOMAIN_NAME/studyroom${NC}"
echo -e "  后端: ${YELLOW}http://$DOMAIN_NAME/api${NC}"
echo ""
echo -e "${CYAN}后续步骤：${NC}"
echo "1. 确保DNS解析已生效（A记录指向 $SERVER_IP）"
echo "2. 配置SSL证书："
echo "   ssh $SERVER_USER@$SERVER_IP"
echo "   sudo certbot --nginx -d $DOMAIN_NAME -d www.$DOMAIN_NAME"
echo ""
echo -e "${CYAN}查看日志：${NC}"
echo "   ssh $SERVER_USER@$SERVER_IP 'tail -f /opt/studyroom/logs/backend.log'"
echo ""
