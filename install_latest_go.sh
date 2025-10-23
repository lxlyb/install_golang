#!/bin/bash
# =====================================================
# 🚀 自动安装最新版本的 Go (Golang)
# 适用于 Linux x86_64 / aarch64 架构
# 作者: lxlyb
# GitHub: https://github.com/lxlyb/install_golang/
# =====================================================

set -e

echo "=========================================="
echo " 🧰 Go 自动安装脚本"
echo "=========================================="

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 root 用户运行此脚本（或使用 sudo）"
  exit 1
fi

# 检查依赖
for cmd in curl wget tar; do
  if ! command -v $cmd &>/dev/null; then
    echo "❌ 缺少依赖: $cmd，请先安装它"
    exit 1
  fi
done

# 自动检测系统架构
ARCH=$(uname -m)
case $ARCH 在
  x86_64)  GOARCH="amd64" ;;
  aarch64) GOARCH="arm64" ;;
  *) echo "❌ 不支持的架构: $ARCH"; exit 1 ;;
esac

# 获取最新 Go 版本号
echo "🔍 正在从 go.dev 获取最新版本..."
LATEST_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)

if [ -z "$LATEST_VERSION" ]; then
  echo "❌ 无法获取最新版本号，请检查网络。"
  exit 1
fi

echo "✅ 最新版本为: $LATEST_VERSION"

# 拼接下载链接
FILENAME="${LATEST_VERSION}.linux-${GOARCH}.tar.gz"
DOWNLOAD_URL="https://go.dev/dl/${FILENAME}"

# 下载
echo "⬇️ 开始下载: $DOWNLOAD_URL"
wget -q --show-progress "$DOWNLOAD_URL"

# 安装
echo "📦 正在安装到 /usr/local/go ..."
rm -rf /usr/local/go
tar -C /usr/local -xzf "$FILENAME"

# 清理
rm -f "$FILENAME"

# 设置环境变量（系统级）
echo "🔧 配置环境变量到 /etc/profile.d/go.sh ..."
cat <<EOF > /etc/profile.d/go.sh
export PATH=\$PATH:/usr/local/go/bin
EOF
chmod +x /etc/profile.d/go.sh

# 当前会话立即生效
export PATH=$PATH:/usr/local/go/bin

# 验证安装结果
echo "✅ 验证安装..."
if command -v go &>/dev/null; then
  echo "🎉 Go 安装成功：$(go version)"
else
  echo "⚠️ Go 已安装，但当前会话可能需重新加载环境变量。"
fi

echo "=========================================="
echo "✅ 完成！下次登录系统会自动加载 Go 环境。"
echo "=========================================="
