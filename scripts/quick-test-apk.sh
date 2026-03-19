#!/bin/bash
# APK 快速测试脚本 - 测试后立即清理

set -e

APK_DIR="/tmp/apk-test-$$"
BUILD_ID="${1:-latest}"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[TEST]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERR]${NC} $1"; }

# 清理函数
cleanup() {
    log "清理临时文件..."
    rm -rf "$APK_DIR"
    df -h / | tail -1
}
trap cleanup EXIT

mkdir -p "$APK_DIR"
cd "$APK_DIR"

log "下载 APK (Build: $BUILD_ID)..."
if [ "$BUILD_ID" = "latest" ]; then
    RUN_ID=$(gh run list --repo suyustudio/shanjing-app --workflow "Build APK with Debug" --json databaseId --jq '.[0].databaseId')
else
    RUN_ID=$(gh run list --repo suyustudio/shanjing-app --json number,databaseId --jq "map(select(.number == $BUILD_ID))[0].databaseId")
fi

gh run download "$RUN_ID" --repo suyustudio/shanjing-app --name shanjing-debug-apk 2>&1

log "查找 APK..."
APK_PATH=$(find . -name "*.apk" -type f | head -1)

if [ -z "$APK_PATH" ]; then
    error "APK 文件未找到"
    ls -la
    exit 1
fi

log "APK 路径: $APK_PATH"
ls -lh "$APK_PATH"

log "APK 信息:"
aapt dump badging "$APK_PATH" 2>/dev/null | head -5 || echo "aapt 不可用"

log "解压检查..."
unzip -q "$APK_PATH" -d ./extracted

log "检查 assets:"
ls -la ./extracted/assets/ 2>/dev/null | head -10

if [ -f ./extracted/assets/.env ]; then
    log "✅ .env 文件存在"
    cat ./extracted/assets/.env
else
    warn "⚠️ .env 文件不存在"
fi

log "检查 lib 架构:"
ls ./extracted/lib/ 2>/dev/null

log "检查 classes.dex:"
ls -lh ./extracted/*.dex 2>/dev/null | head -3

log "✅ 测试完成"

# 清理会在 EXIT 时自动执行
