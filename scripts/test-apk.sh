#!/bin/bash
# APK 测试脚本 - 自动下载、安装、测试

set -e

# 配置
GITHUB_REPO="suyustudio/shanjing-app"
BUILD_NUMBER="${1:-latest}"
APK_DIR="/tmp/apk-test"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 确保环境变量
export ANDROID_SDK_ROOT="/usr/lib/android-sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. 下载 APK
download_apk() {
    log_info "下载 APK (Build #$BUILD_NUMBER)..."
    
    mkdir -p "$APK_DIR"
    cd "$APK_DIR"
    
    if [ "$BUILD_NUMBER" = "latest" ]; then
        # 获取最新构建
        RUN_ID=$(gh run list --repo "$GITHUB_REPO" --workflow "Build APK with Debug" --json databaseId --jq '.[0].databaseId')
    else
        # 获取指定构建
        RUN_ID=$(gh run list --repo "$GITHUB_REPO" --json number,databaseId --jq "map(select(.number == $BUILD_NUMBER))[0].databaseId")
    fi
    
    if [ -z "$RUN_ID" ]; then
        log_error "找不到构建 #$BUILD_NUMBER"
        exit 1
    fi
    
    log_info "下载构建 Run ID: $RUN_ID"
    gh run download "$RUN_ID" --repo "$GITHUB_REPO" --dir "$APK_DIR" || {
        log_error "下载失败"
        exit 1
    }
    
    # 查找 APK
    APK_PATH=$(find "$APK_DIR" -name "*.apk" -type f | head -1)
    if [ -z "$APK_PATH" ]; then
        log_error "找不到 APK 文件"
        exit 1
    fi
    
    log_ok "APK 下载完成: $APK_PATH"
    echo "$APK_PATH"
}

# 2. 启动模拟器
start_emulator() {
    log_info "检查模拟器状态..."
    
    # 检查是否已有运行的模拟器
    if adb devices | grep -q "emulator"; then
        log_ok "模拟器已在运行"
        return 0
    fi
    
    # 检查 AVD 是否存在
    if ! avdmanager list avd -c 2>/dev/null | grep -q "pixel_33"; then
        log_warn "AVD 'pixel_33' 不存在，需要先运行 setup-android-env.sh"
        return 1
    fi
    
    log_info "启动模拟器 (后台模式)..."
    emulator -avd pixel_33 -no-window -no-audio -gpu swiftshader_indirect &
    EMULATOR_PID=$!
    
    log_info "等待模拟器启动 (最多 120 秒)..."
    timeout=120
    while [ $timeout -gt 0 ]; do
        if adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; then
            log_ok "模拟器启动完成"
            return 0
        fi
        sleep 2
        timeout=$((timeout - 2))
        echo -n "."
    done
    
    log_error "模拟器启动超时"
    kill $EMULATOR_PID 2>/dev/null || true
    return 1
}

# 3. 安装 APK
install_apk() {
    local apk_path="$1"
    log_info "安装 APK..."
    
    # 先卸载旧版本
    adb uninstall com.suyustudio.shanjing 2>/dev/null || true
    
    # 安装新版本
    if adb install "$apk_path"; then
        log_ok "APK 安装成功"
    else
        log_error "APK 安装失败"
        return 1
    fi
}

# 4. 运行测试
run_test() {
    log_info "启动应用并收集日志..."
    
    # 启动应用
    adb shell am start -n com.suyustudio.shanjing/.MainActivity
    
    log_info "等待 5 秒让应用启动..."
    sleep 5
    
    # 截图
    log_info "截取屏幕..."
    adb shell screencap -p /data/local/tmp/screen.png
    adb pull /data/local/tmp/screen.png "$APK_DIR/screen_$(date +%s).png"
    
    # 收集日志
    log_info "收集 30 秒日志..."
    timeout 30 adb logcat -d | grep -E "flutter|AndroidRuntime|FATAL|ERROR" > "$APK_DIR/logcat_$(date +%s).txt" || true
    
    log_ok "测试完成"
    log_info "日志保存到: $APK_DIR/"
    
    # 分析日志
    if grep -q "FATAL EXCEPTION" "$APK_DIR"/logcat_*.txt 2>/dev/null; then
        log_error "发现崩溃！"
        grep -A 10 "FATAL EXCEPTION" "$APK_DIR"/logcat_*.txt | head -20
    fi
}

# 主流程
main() {
    echo -e "${GREEN}=== APK 自动测试 ===${NC}"
    echo "Build: ${BUILD_NUMBER}"
    echo ""
    
    # 步骤 1: 下载
    APK_PATH=$(download_apk)
    
    # 步骤 2: 启动模拟器
    if ! start_emulator; then
        log_error "无法启动模拟器，退出"
        exit 1
    fi
    
    # 步骤 3: 安装
    if ! install_apk "$APK_PATH"; then
        exit 1
    fi
    
    # 步骤 4: 测试
    run_test
    
    echo ""
    log_ok "全部完成！"
    log_info "查看结果: ls -la $APK_DIR/"
}

# 执行
main
