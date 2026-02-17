# 智慧自习室系统 - 服务器部署指南

## 一、服务器要求

### 最低配置
- CPU: 2核
- 内存: 4GB
- 硬盘: 40GB
- 操作系统: Ubuntu 20.04/22.04, CentOS 7/8, Alibaba Cloud Linux

### 推荐配置
- CPU: 4核
- 内存: 8GB
- 硬盘: 100GB
- 带宽: 5Mbps

## 二、快速部署

### 1. 环境安装

```bash
# 上传安装脚本到服务器
scp scripts/server-setup.sh root@your-server-ip:/root/

# 登录服务器
ssh root@your-server-ip

# 赋予执行权限
chmod +x server-setup.sh

# 运行安装脚本
./server-setup.sh
```

安装脚本会自动安装：
- ✅ Java 21
- ✅ MySQL 8
- ✅ Redis
- ✅ Node.js 20
- ✅ Nginx
- ✅ 配置防火墙
- ✅ 创建应用目录

### 2. 上传代码

```bash
# 在本地打包项目
cd /path/to/studyroom-reservation
tar -czf studyroom.tar.gz backend frontend scripts

# 上传到服务器
scp studyroom.tar.gz root@your-server-ip:/opt/studyroom/

# 在服务器上解压
ssh root@your-server-ip
cd /opt/studyroom
tar -xzf studyroom.tar.gz
```

### 3. 配置环境变量

编辑配置文件：
```bash
vim /opt/studyroom/env.sh
```

修改以下配置：
```bash
# 数据库配置
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=studyroom
export DB_USER=studyroom_user
export DB_PASSWORD=YourPassword  # 修改为你的密码

# Redis 配置
export REDIS_HOST=localhost
export REDIS_PORT=6379
export REDIS_PASSWORD=YourRedisPassword  # 修改为你的密码

# 应用配置
export APP_PORT=9090
export APP_ENV=production
```

### 4. 部署应用

```bash
# 赋予执行权限
chmod +x /opt/studyroom/scripts/deploy.sh

# 运行部署脚本
/opt/studyroom/scripts/deploy.sh
```

部署脚本会自动：
- ✅ 停止现有服务
- ✅ 备份当前版本
- ✅ 构建后端项目
- ✅ 导入数据库
- ✅ 构建前端项目
- ✅ 配置 Nginx
- ✅ 启动服务

### 5. 验证部署

```bash
# 检查后端服务
curl http://localhost:9090/api/health

# 检查前端
curl http://localhost

# 查看日志
tail -f /opt/studyroom/logs/backend.log
```

## 三、手动部署步骤

如果自动脚本失败，可以按以下步骤手动部署：

### 1. 安装 Java 21

```bash
# Ubuntu/Debian
apt-get install -y openjdk-21-jdk

# CentOS/RHEL
yum install -y java-21-openjdk java-21-openjdk-devel
```

### 2. 安装 MySQL 8

```bash
# Ubuntu/Debian
apt-get install -y mysql-server

# CentOS/RHEL
yum install -y mysql-server

# 启动服务
systemctl start mysql
systemctl enable mysql

# 创建数据库
mysql -uroot -p <<EOF
CREATE DATABASE studyroom CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'studyroom_user'@'localhost' IDENTIFIED BY 'YourPassword';
GRANT ALL PRIVILEGES ON studyroom.* TO 'studyroom_user'@'localhost';
FLUSH PRIVILEGES;
EOF
```

### 3. 安装 Redis

```bash
# Ubuntu/Debian
apt-get install -y redis-server
systemctl start redis-server
systemctl enable redis-server

# CentOS/RHEL
yum install -y redis
systemctl start redis
systemctl enable redis
```

### 4. 安装 Node.js

```bash
# 使用 NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# 或
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs
```

### 5. 安装 Nginx

```bash
# Ubuntu/Debian
apt-get install -y nginx

# CentOS/RHEL
yum install -y nginx

# 启动服务
systemctl start nginx
systemctl enable nginx
```

### 6. 构建后端

```bash
cd /opt/studyroom/backend

# 构建项目
mvn clean package -DskipTests

# 导入数据库
mysql -ustudyroom_user -p studyroom < src/main/resources/db/schema.sql
mysql -ustudyroom_user -p studyroom < src/main/resources/db/init_data.sql
```

### 7. 构建前端

```bash
cd /opt/studyroom/frontend

# 安装依赖
npm install

# 构建
npm run build

# 复制到 Nginx
cp -r dist/* /usr/share/nginx/html/
```

### 8. 配置 Nginx

创建配置文件 `/etc/nginx/conf.d/studyroom.conf`：

```nginx
server {
    listen 80;
    server_name _;

    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:9090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

重启 Nginx：
```bash
nginx -t
systemctl restart nginx
```

### 9. 启动后端

```bash
cd /opt/studyroom/backend

nohup java -jar studyroom-backend.jar \
    --spring.profiles.active=prod \
    --spring.datasource.url=jdbc:mysql://localhost:3306/studyroom \
    --spring.datasource.username=studyroom_user \
    --spring.datasource.password=YourPassword \
    > /opt/studyroom/logs/backend.log 2>&1 &
```

## 四、常用命令

### 查看服务状态

```bash
# 查看后端进程
ps aux | grep studyroom-backend

# 查看后端日志
tail -f /opt/studyroom/logs/backend.log

# 查看 Nginx 状态
systemctl status nginx

# 查看 MySQL 状态
systemctl status mysql

# 查看 Redis 状态
systemctl status redis
```

### 重启服务

```bash
# 重启后端
kill $(cat /opt/studyroom/backend/app.pid)
/opt/studyroom/scripts/deploy.sh

# 重启 Nginx
systemctl restart nginx

# 重启 MySQL
systemctl restart mysql

# 重启 Redis
systemctl restart redis
```

### 查看日志

```bash
# 后端日志
tail -f /opt/studyroom/logs/backend.log

# Nginx 访问日志
tail -f /var/log/nginx/access.log

# Nginx 错误日志
tail -f /var/log/nginx/error.log

# MySQL 日志
tail -f /var/log/mysql/error.log
```

## 五、安全配置

### 1. 配置防火墙

```bash
# Ubuntu (UFW)
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# CentOS (firewalld)
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
```

### 2. 配置 SSL 证书（可选）

```bash
# 安装 Certbot
apt-get install -y certbot python3-certbot-nginx

# 获取证书
certbot --nginx -d your-domain.com

# 自动续期
certbot renew --dry-run
```

### 3. 修改默认密码

```bash
# MySQL root 密码
mysql -uroot -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NewStrongPassword';

# Redis 密码
vim /etc/redis/redis.conf
# 修改: requirepass YourStrongPassword
systemctl restart redis
```

## 六、性能优化

### 1. MySQL 优化

编辑 `/etc/mysql/my.cnf`：

```ini
[mysqld]
max_connections = 500
innodb_buffer_pool_size = 2G
innodb_log_file_size = 256M
query_cache_size = 64M
```

### 2. Redis 优化

编辑 `/etc/redis/redis.conf`：

```ini
maxmemory 1gb
maxmemory-policy allkeys-lru
```

### 3. Nginx 优化

编辑 `/etc/nginx/nginx.conf`：

```nginx
worker_processes auto;
worker_connections 2048;

gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript;
```

### 4. Java 优化

```bash
export JAVA_OPTS="-Xms2g -Xmx4g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
```

## 七、监控和维护

### 1. 设置定时备份

```bash
# 创建备份脚本
cat > /opt/studyroom/scripts/backup.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/opt/studyroom/backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# 备份数据库
mysqldump -ustudyroom_user -p studyroom > $BACKUP_DIR/database.sql

# 备份应用
cp /opt/studyroom/backend/*.jar $BACKUP_DIR/

# 删除 7 天前的备份
find /opt/studyroom/backups -type d -mtime +7 -exec rm -rf {} \;
EOF

chmod +x /opt/studyroom/scripts/backup.sh

# 添加到 crontab
crontab -e
# 添加: 0 2 * * * /opt/studyroom/scripts/backup.sh
```

### 2. 监控脚本

```bash
# 创建监控脚本
cat > /opt/studyroom/scripts/monitor.sh <<'EOF'
#!/bin/bash
# 检查后端服务
if ! curl -s http://localhost:9090/api/health > /dev/null; then
    echo "后端服务异常，正在重启..."
    /opt/studyroom/scripts/deploy.sh
fi
EOF

chmod +x /opt/studyroom/scripts/monitor.sh

# 添加到 crontab
crontab -e
# 添加: */5 * * * * /opt/studyroom/scripts/monitor.sh
```

## 八、故障排查

### 常见问题

1. **后端无法启动**
   - 检查 Java 版本：`java -version`
   - 检查端口占用：`lsof -i:9090`
   - 查看日志：`tail -f /opt/studyroom/logs/backend.log`

2. **数据库连接失败**
   - 检查 MySQL 状态：`systemctl status mysql`
   - 测试连接：`mysql -ustudyroom_user -p studyroom`
   - 检查配置：`vim /opt/studyroom/env.sh`

3. **前端无法访问**
   - 检查 Nginx 状态：`systemctl status nginx`
   - 测试配置：`nginx -t`
   - 查看日志：`tail -f /var/log/nginx/error.log`

4. **Redis 连接失败**
   - 检查 Redis 状态：`systemctl status redis`
   - 测试连接：`redis-cli ping`
   - 检查密码：`vim /etc/redis/redis.conf`

## 九、联系支持

如有问题，请查看：
- 项目文档：README.md
- 日志文件：/opt/studyroom/logs/
- GitHub Issues

---

**祝部署顺利！** 🚀
