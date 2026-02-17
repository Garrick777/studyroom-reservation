# 🚀 一键部署到阿里云ECS

## 配置信息已就绪

所有配置已经填写完成，可以直接部署！

### 当前配置
- **服务器IP**: 121.41.171.239
- **域名**: gavinsystem.top
- **数据库**: studyroom
- **数据库密码**: 123456789
- **JWT密钥**: 已自动生成安全密钥

## 部署步骤

### 第一步: 提交代码到GitHub

```bash
# 提交所有更改
git add .
git commit -m "feat: 添加自动部署配置"
git push
```

### 第二步: 运行一键部署

```bash
# 直接运行部署脚本
./auto-deploy.sh
```

脚本会自动完成：
1. ✅ 从GitHub克隆项目到服务器
2. ✅ 创建生产环境配置
3. ✅ 安装环境（Java, MySQL, Redis, Node.js, Nginx）
4. ✅ 创建数据库
5. ✅ 构建并部署应用
6. ✅ 配置Nginx和域名
7. ✅ 验证部署

**预计耗时**: 10-15分钟（首次部署）

## 部署后配置

### 1. 配置DNS解析

在域名服务商控制台添加A记录：
```
记录类型: A
主机记录: @
记录值: 121.41.171.239
TTL: 600
```

### 2. 配置SSL证书（推荐）

```bash
# 登录服务器
ssh root@121.41.171.239

# 安装certbot
sudo apt install certbot python3-certbot-nginx -y

# 获取SSL证书
sudo certbot --nginx -d gavinsystem.top -d www.gavinsystem.top
```

## 访问地址

部署完成后，通过以下地址访问：

- **前端**: http://gavinsystem.top/studyroom
- **后端API**: http://gavinsystem.top/api
- **API文档**: http://gavinsystem.top/api/doc.html

配置SSL后：
- **前端**: https://gavinsystem.top/studyroom
- **后端API**: https://gavinsystem.top/api

## 测试账号

部署完成后，可以使用以下测试账号登录：

**学生账号**:
- 学号: 2021001
- 密码: 123456

**管理员账号**:
- 用户名: admin
- 密码: admin123

## 常用命令

```bash
# 查看后端日志
ssh root@121.41.171.239 'tail -f /opt/studyroom/logs/backend.log'

# 重启后端服务
ssh root@121.41.171.239 'systemctl restart studyroom-backend'

# 重启Nginx
ssh root@121.41.171.239 'systemctl restart nginx'

# 查看服务状态
ssh root@121.41.171.239 'systemctl status studyroom-backend nginx mysql redis'
```

## 更新部署

代码更新后重新部署：

```bash
# 本地提交代码
git add .
git commit -m "更新说明"
git push

# 重新部署
./auto-deploy.sh
```

脚本会自动拉取最新代码并重新部署。

## 故障排查

### 1. 无法访问网站
```bash
# 检查防火墙
ssh root@121.41.171.239
firewall-cmd --list-all

# 开放端口
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
```

### 2. 后端启动失败
```bash
# 查看日志
ssh root@121.41.171.239 'tail -100 /opt/studyroom/logs/backend.log'

# 检查数据库连接
ssh root@121.41.171.239 'mysql -u studyroom -p123456789 -e "USE studyroom; SHOW TABLES;"'
```

### 3. 前端显示404
```bash
# 检查Nginx配置
ssh root@121.41.171.239 'nginx -t'

# 检查前端文件
ssh root@121.41.171.239 'ls -la /usr/share/nginx/html/studyroom/'
```

## 手动部署（备选方案）

如果自动部署失败，可以手动执行：

```bash
# 1. 登录服务器
ssh root@121.41.171.239

# 2. 克隆项目
cd /opt
git clone https://github.com/Garrick777/studyroom-reservation.git studyroom
cd studyroom

# 3. 安装环境
chmod +x scripts/*.sh
sudo ./scripts/server-setup.sh

# 4. 配置数据库
mysql -u root -p
CREATE DATABASE studyroom CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'studyroom'@'localhost' IDENTIFIED BY '123456789';
GRANT ALL PRIVILEGES ON studyroom.* TO 'studyroom'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 5. 部署应用
./scripts/deploy.sh
```

## 安全建议

1. ✅ 部署完成后，建议修改数据库密码为更强的密码
2. ✅ 配置SSH密钥登录，禁用密码登录
3. ✅ 启用HTTPS（SSL证书）
4. ✅ 定期备份数据库
5. ✅ 监控服务器资源使用

## 需要帮助？

- 详细文档: 查看 `DEPLOYMENT.md`
- 部署指南: 查看 `DEPLOY_GUIDE.md`
- 问题反馈: GitHub Issues
