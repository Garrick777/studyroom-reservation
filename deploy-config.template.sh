#!/bin/bash
# =====================================================
# 部署配置文件模板
# 复制此文件为 deploy-config.sh 并填入实际值
# deploy-config.sh 不会被提交到 Git
# =====================================================

# ========== 服务器信息 ==========
export SERVER_IP="你的服务器IP"
export SERVER_USER="root"
export DOMAIN_NAME="gavinsystem.top"

# ========== 数据库配置 ==========
export DB_HOST="localhost"
export DB_PORT="3306"
export DB_NAME="studyroom"
export DB_USER="studyroom"
export DB_PASSWORD="你的数据库密码"
export DB_ROOT_PASSWORD="MySQL的root密码"

# ========== Redis 配置 ==========
export REDIS_HOST="localhost"
export REDIS_PORT="6379"
export REDIS_PASSWORD="你的Redis密码(可选，留空表示无密码)"

# ========== JWT 配置 ==========
# 建议使用随机生成的长字符串
export JWT_SECRET="你的JWT密钥(至少64位随机字符串)"

# ========== 应用配置 ==========
export APP_PORT="9090"
export APP_ENV="production"

# ========== 邮件配置（可选） ==========
export MAIL_HOST="smtp.example.com"
export MAIL_PORT="587"
export MAIL_USERNAME="your-email@example.com"
export MAIL_PASSWORD="邮箱密码或授权码"

# ========== 阿里云OSS配置（可选） ==========
export OSS_ENDPOINT="oss-cn-hangzhou.aliyuncs.com"
export OSS_ACCESS_KEY_ID="你的AccessKeyId"
export OSS_ACCESS_KEY_SECRET="你的AccessKeySecret"
export OSS_BUCKET_NAME="你的Bucket名称"

echo "配置已加载"
