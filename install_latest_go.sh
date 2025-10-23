#!/bin/bash
# ===========================================
# 自动安装最新版本的 Go（Golang）
# 适用于 Linux x86_64
# ===========================================

set -e

echo "🔍 正在获取最新 Go 版本号..."
LATEST_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)

if [ -z "$LATEST_VERSION" ]; then
  echo "❌ 无法获取最新版本号，请检查网络或 Go 官网访问。"
  exit 1
fi

echo "✅ 最新版本为: $LATEST_VERSION"

# 下载文件名，例如 go1.23.3.linux-amd64.tar.gz
FILENAME="${LATEST_VERSION}.linux-amd64.tar.gz"
DOWNLOAD_URL="https://go.dev/dl/${FILENAME}"

echo "⬇️ 正在下载 Go: $DOWNLOAD_URL"
wget -q --show-progress "$DOWNLOAD_URL"

echo "📦 正在解压并安装到 /usr/local/go ..."
rm -rf /usr/local/go
tar -C /usr/local -xzf "$FILENAME"

echo "🧹 清理临时文件..."
rm -f "$FILENAME"

# 更新环境变量
PROFILE_FILE="/etc/profile"
if ! grep -q "/usr/local/go/bin" "$PROFILE_FILE"; then
  echo "🔧 添加 Go 路径到 $PROFILE_FILE"
  echo 'export PATH=$PATH:/usr/local/go/bin' >> "$PROFILE_FILE"
fi

# 立即生效
source "$PROFILE_FILE"

echo "✅ Go 已成功安装："
go version || echo "⚠️ Go 安装成功但可能需要重新登录终端以生效 PATH"

echo "🎉 完成！"
