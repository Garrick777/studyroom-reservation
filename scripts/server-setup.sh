#!/bin/bash
# =====================================================
# 智慧自习室系统 - 服务器环境自动安装脚本
# 适用于：Ubuntu 20.04/22.04, CentOS 7/8, Alibaba Cloud Linux
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
MYSQL_ROOT_PASSWORD="YourStrongPassword123!"
MYSQL_DB_NAME="studyroom"
MYSQL_USER="studyroom_user"
MYSQL_USER_PASSWORD="StudyRoom2024!"
APP_USER="studyroom"
APP_DIR="/opt/studyroom"

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}   智慧自习室系统 - 服务器环境安装${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        echo -e "${RED}无法检测操作系统${NC}"
        exit 1
    fi

    echo -e "${YELLOW}检测到操作系统: $OS $VERSION${NC}"
}

# 更新系统
update_system() {
    echo -e "${YELLOW}[1/8] 更新系统...${NC}"

    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        apt-get update -y
        apt-get upgrade -y
        apt-get install -y wget curl git vim unzip
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "alinux" ]]; then
        yum update -y
        yum install -y wget curl git vim unzip
    fi

    echo -e "${GREEN}[✓] 系统更新完成${NC}"
}

# 安装 Java 21
install_java() {
    echo -e "${YELLOW}[2/8] 安装 Java 21...${NC}"

    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$JAVA_VERSION" == "21" ]; then
            echo -e "${GREEN}Java 21 已安装${NC}"
            return
        fi
    fi

    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        # Ubuntu/Debian
        apt-get install -y openjdk-21-jdk
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
        # CentOS/RHEL
        yum install -y java-21-openjdk java-21-openjdk-devel
    elif [[ "$OS" == "alinux" ]]; then
        # Alibaba Cloud Linux
        yum install -y java-21-amazon-corretto-devel
    fi

    # 设置 JAVA_HOME
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
    source /etc/profile

    java -version
    echo -e "${GREEN}[✓] Java 21 安装完成${NC}"
}

# 安装 MySQL 8
install_mysql() {
    echo -e "${YELLOW}[3/8] 安装 MySQL 8...${NC}"

    if command -v mysql &> /dev/null; then
        echo -e "${GREEN}MySQL 已安装${NC}"
        return
    fi

    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        # Ubuntu/Debian
        apt-get install -y mysql-server
        systemctl start mysql
        systemctl enable mysql
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "alinux" ]]; then
        # CentOS/RHEL/Alibaba Cloud Linux
        yum install -y mysql-server
        systemctl start mysqld
        systemctl enable mysqld

        # 获取临时密码
        TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
        echo -e "${YELLOW}MySQL 临时密码: $TEMP_PASSWORD${NC}"
    fi

    # 配置 MySQL
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" || true
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DB_NAME.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

    echo -e "${GREEN}[✓] MySQL 8 安装完成${NC}"
    echo -e "${CYAN}数据库名: $MYSQL_DB_NAME${NC}"
    echo -e "${CYAN}用户名: $MYSQL_USER${NC}"
    echo -e "${CYAN}密码: $MYSQL_USER_PASSWORD${NC}"
}

# 安装 Redis
install_redis() {
    echo -e "${YELLOW}[4/8] 安装 Redis...${NC}"

    if command -v redis-server &> /dev/null; then
        echo -e "${GREEN}Redis 已安装${NC}"
        return
    fi

    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        apt-get install -y redis-server
        systemctl start redis-server
        systemctl enable redis-server
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "alinux" ]]; then
        yum install -y redis
        systemctl start redis
        systemctl enable redis
    fi

    # 配置 Redis
    sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf || true
    sed -i 's/# requirepass foobared/requirepass YourRedisPassword123!/' /etc/redis/redis.conf || true
    systemctl restart redis-server || systemctl restart redis

    echo -e "${GREEN}[✓] Redis 安装完成${NC}"
}

# 安装 Node.js
install_nodejs() {
    echo -e "${YELLOW}[5/8] 安装 Node.js...${NC}"

    if command -v node &> /dev/null; then
        echo -e "${GREEN}Node.js 已安装${NC}"
        return
    fi

    # 使用 NodeSource 安装 Node.js 20.x
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - || \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        apt-get install -y nodejs
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "alinux" ]]; then
        yum install -y nodejs
    fi

    # 安装 pnpm
    npm install -g pnpm

    node -v
    npm -v
    echo -e "${GREEN}[✓] Node.js 安装完成${NC}"
}

# 安装 Nginx
install_nginx() {
    echo -e "${YELLOW}[6/8] 安装 Nginx...${NC}"

    if command -v nginx &> /dev/null; then
        echo -e "${GREEN}Nginx 已安装${NC}"
        return
    fi

    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        apt-get install -y nginx
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "alinux" ]]; then
        yum install -y nginx
    fi

    systemctl start nginx
    systemctl enable nginx

    echo -e "${GREEN}[✓] Nginx 安装完成${NC}"
}

# 创建应用用户和目录
setup_app_environment() {
    echo -e "${YELLOW}[7/8] 配置应用环境...${NC}"

    # 创建应用用户
    if ! id "$APP_USER" &>/dev/null; then
        useradd -m -s /bin/bash $APP_USER
        echo -e "${GREEN}创建用户: $APP_USER${NC}"
    fi

    # 创建应用目录
    mkdir -p $APP_DIR/{backend,frontend,logs,backups}
    chown -R $APP_USER:$APP_USER $APP_DIR

    echo -e "${GREEN}[✓] 应用环境配置完成${NC}"
}

# 配置防火墙
configure_firewall() {
    echo -e "${YELLOW}[8/8] 配置防火墙...${NC}"

    if command -v ufw &> /dev/null; then
        # Ubuntu/Debian
        ufw allow 22/tcp
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 3306/tcp
        ufw allow 6379/tcp
        ufw allow 9090/tcp
        echo "y" | ufw enable || true
    elif command -v firewall-cmd &> /dev/null; then
        # CentOS/RHEL
        firewall-cmd --permanent --add-port=22/tcp
        firewall-cmd --permanent --add-port=80/tcp
        firewall-cmd --permanent --add-port=443/tcp
        firewall-cmd --permanent --add-port=3306/tcp
        firewall-cmd --permanent --add-port=6379/tcp
        firewall-cmd --permanent --add-port=9090/tcp
        firewall-cmd --reload
    fi

    echo -e "${GREEN}[✓] 防火墙配置完成${NC}"
}

# 生成配置文件
generate_config() {
    echo -e "${YELLOW}生成配置文件...${NC}"

    cat > $APP_DIR/env.sh <<EOF
#!/bin/bash
# 应用环境变量配置

# 数据库配置
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=$MYSQL_DB_NAME
export DB_USER=$MYSQL_USER
export DB_PASSWORD=$MYSQL_USER_PASSWORD

# Redis 配置
export REDIS_HOST=localhost
export REDIS_PORT=6379
export REDIS_PASSWORD=YourRedisPassword123!

# 应用配置
export APP_PORT=9090
export APP_ENV=production

# Java 配置
export JAVA_OPTS="-Xms512m -Xmx2g -XX:+UseG1GC"
EOF

    chmod +x $APP_DIR/env.sh
    chown $APP_USER:$APP_USER $APP_DIR/env.sh

    echo -e "${GREEN}配置文件已生成: $APP_DIR/env.sh${NC}"
}

# 主函数
main() {
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}请使用 root 用户运行此脚本${NC}"
        exit 1
    fi

    detect_os
    update_system
    install_java
    install_mysql
    install_redis
    install_nodejs
    install_nginx
    setup_app_environment
    configure_firewall
    generate_config

    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}   环境安装完成！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${CYAN}已安装的组件：${NC}"
    echo -e "  ✓ Java 21"
    echo -e "  ✓ MySQL 8"
    echo -e "  ✓ Redis"
    echo -e "  ✓ Node.js 20"
    echo -e "  ✓ Nginx"
    echo ""
    echo -e "${CYAN}数据库信息：${NC}"
    echo -e "  数据库名: ${YELLOW}$MYSQL_DB_NAME${NC}"
    echo -e "  用户名: ${YELLOW}$MYSQL_USER${NC}"
    echo -e "  密码: ${YELLOW}$MYSQL_USER_PASSWORD${NC}"
    echo ""
    echo -e "${CYAN}应用目录：${NC}"
    echo -e "  ${YELLOW}$APP_DIR${NC}"
    echo ""
    echo -e "${CYAN}配置文件：${NC}"
    echo -e "  ${YELLOW}$APP_DIR/env.sh${NC}"
    echo ""
    echo -e "${YELLOW}下一步：${NC}"
    echo -e "  1. 上传应用代码到 $APP_DIR"
    echo -e "  2. 导入数据库脚本"
    echo -e "  3. 配置 Nginx 反向代理"
    echo -e "  4. 启动应用"
    echo ""
}

main "$@"
