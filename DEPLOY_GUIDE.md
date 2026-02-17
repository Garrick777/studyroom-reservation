# 一键自动部署指南

## 概述

本项目提供了一键自动部署脚本，可以将应用快速部署到阿里云ECS服务器。所有敏感配置信息都保存在本地，不会提交到GitHub。

## 部署前准备

### 1. 服务器要求

- 操作系统: Ubuntu 20.04/22.04, CentOS 7/8, Alibaba Cloud Linux
- 最低配置: 2核CPU, 4GB内存, 40GB硬盘
- 已开放端口: 22 (SSH), 80 (HTTP), 443 (HTTPS)

### 2. 本地环境要求

- 已安装 SSH 客户端
- 可以通过 SSH 连接到服务器
- 建议配置 SSH 密钥登录（避免每次输入密码）

### 3. 域名准备（可选）

如果使用域名访问，需要提前配置DNS解析：
- 在域名服务商控制台添加 A 记录
- 主机记录: @
- 记录值: 服务器公网IP
- TTL: 600

## 快速部署步骤

### 步骤1: 创建配置文件

```bash
# 复制配置模板
cp deploy-config.template.sh deploy-config.sh

# 编辑配置文件
vim deploy-config.sh
```

### 步骤2: 填写配置信息

在 `deploy-config.sh` 中填写以下信息：

#### 必填项

```bash
# 服务器信息
export SERVER_IP="你的服务器公网IP"              # 例如: 47.98.123.456
export SERVER_USER="root"                        # SSH登录用户名

# 数据库配置
export DB_PASSWORD="你的数据库密码"               # 建议使用强密码
export DB_ROOT_PASSWORD="MySQL的root密码"        # MySQL root用户密码

# JWT配置
export JWT_SECRET="你的JWT密钥"                  # 至少64位随机字符串
```

#### 可选项

```bash
# 域名（如果有）
export DOMAIN_NAME="gavinsystem.top"

# Redis密码（如果需要）
export REDIS_PASSWORD="你的Redis密码"

# 其他配置保持默认即可
```

#### 生成安全的JWT密钥

```bash
# 方法1: 使用 openssl
openssl rand -base64 64

# 方法2: 使用 Python
python3 -c "import secrets; print(secrets.token_urlsafe(64))"

# 方法3: 在线生成
# 访问 https://www.random.org/strings/
```

### 步骤3: 运行部署脚本

```bash
# 给脚本添加执行权限
chmod +x auto-deploy.sh

# 运行一键部署
./auto-deploy.sh
```

脚本会自动完成以下操作：
1. ✅ 打包项目文件
2. ✅ 上传到服务器
3. ✅ 安装运行环境（Java, MySQL, Redis, Node.js, Nginx）
4. ✅ 创建数据库和用户
5. ✅ 构建前端和后端
6. ✅ 配置Nginx
7. ✅ 启动服务
8. ✅ 配置域名

### 步骤4: 配置SSL证书（推荐）

部署完成后，登录服务器配置HTTPS：

```bash
# 登录服务器
ssh root@你的服务器IP

# 安装certbot（如果未安装）
sudo apt install certbot python3-certbot-nginx -y

# 获取SSL证书
sudo certbot --nginx -d gavinsystem.top -d www.gavinsystem.top

# 测试自动续期
sudo certbot renew --dry-run
```

## 访问应用

部署成功后，可以通过以下地址访问：

- **前端**: http://gavinsystem.top/studyroom 或 https://gavinsystem.top/studyroom
- **后端API**: http://gavinsystem.top/api 或 https://gavinsystem.top/api

## 常见问题

### 1. SSH连接失败

```bash
# 检查服务器IP是否正确
ping 你的服务器IP

# 检查SSH端口是否开放
telnet 你的服务器IP 22

# 配置SSH密钥登录（推荐）
ssh-copy-id root@你的服务器IP
```

### 2. 数据库连接失败

```bash
# 登录服务器检查MySQL状态
ssh root@你的服务器IP
systemctl status mysql

# 检查数据库是否创建
mysql -u root -p
SHOW DATABASES;
```

### 3. 前端无法访问

```bash
# 检查Nginx状态
ssh root@你的服务器IP
systemctl status nginx

# 检查Nginx配置
nginx -t

# 查看Nginx日志
tail -f /var/log/nginx/error.log
```

### 4. 后端无法启动

```bash
# 查看后端日志
ssh root@你的服务器IP
tail -f /opt/studyroom/logs/backend.log

# 检查Java进程
ps aux | grep java
```

## 更新部署

当代码有更新时，只需重新运行部署脚本：

```bash
# 拉取最新代码
git pull

# 重新部署
./auto-deploy.sh
```

脚本会自动备份当前版本，然后部署新版本。

## 手动部署

如果自动部署失败，可以参考 `DEPLOYMENT.md` 进行手动部署。

## 安全建议

1. ✅ 使用强密码（至少16位，包含大小写字母、数字、特殊字符）
2. ✅ 配置SSH密钥登录，禁用密码登录
3. ✅ 定期更新系统和软件包
4. ✅ 配置防火墙，只开放必要端口
5. ✅ 启用HTTPS（SSL证书）
6. ✅ 定期备份数据库
7. ✅ 监控服务器资源使用情况

## 文件说明

- `auto-deploy.sh` - 一键自动部署脚本
- `deploy-config.template.sh` - 配置文件模板（可提交到Git）
- `deploy-config.sh` - 实际配置文件（不提交到Git，包含敏感信息）
- `backend/src/main/resources/application-prod.yml.template` - 生产环境配置模板
- `backend/src/main/resources/application-prod.yml` - 实际生产配置（不提交到Git）

## 技术支持

如有问题，请查看：
1. `DEPLOYMENT.md` - 详细部署文档
2. 项目 Issues: https://github.com/Garrick777/studyroom-reservation/issues
