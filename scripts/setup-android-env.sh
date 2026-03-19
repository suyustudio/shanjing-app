#!/bin/bash
# Android 测试环境配置脚本

set -e

ANDROID_SDK_ROOT="/usr/lib/android-sdk"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Android 测试环境配置 ===${NC}"

# 1. 检查并安装 cmdline-tools
echo -e "${YELLOW}[1/5] 检查 cmdline-tools...${NC}"
if [ ! -d "$ANDROID_SDK_ROOT/cmdline-tools/latest" ]; then
    echo "下载 cmdline-tools..."
    cd /tmp
    wget -q --show-progress "$CMDLINE_TOOLS_URL" -O cmdline-tools.zip
    mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
    unzip -q cmdline-tools.zip -d "$ANDROID_SDK_ROOT/cmdline-tools/"
    mv "$ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools" "$ANDROID_SDK_ROOT/cmdline-tools/latest"
    rm cmdline-tools.zip
    echo -e "${GREEN}✓ cmdline-tools 安装完成${NC}"
else
    echo -e "${GREEN}✓ cmdline-tools 已存在${NC}"
fi

# 2. 设置环境变量
echo -e "${YELLOW}[2/5] 设置环境变量...${NC}"
export ANDROID_SDK_ROOT
export PATH="$PATH:$ANDROID_SDK_ROOT/emulator"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"

# 添加到 .bashrc
if ! grep -q "ANDROID_SDK_ROOT" ~/.bashrc; then
    echo "export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" >> ~/.bashrc
    echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/emulator' >> ~/.bashrc
    echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools' >> ~/.bashrc
    echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin' >> ~/.bashrc
fi

echo -e "${GREEN}✓ 环境变量设置完成${NC}"

# 3. 安装系统镜像
echo -e "${YELLOW}[3/5] 安装 Android 33 系统镜像...${NC}"
echo "这可能需要 5-10 分钟..."
yes | sdkmanager --licenses > /dev/null 2>&1 || true
sdkmanager "system-images;android-33;google_apis;x86_64" > /dev/null 2>&1
echo -e "${GREEN}✓ 系统镜像安装完成${NC}"

# 4. 创建 AVD
echo -e "${YELLOW}[4/5] 创建 AVD (Android Virtual Device)...${NC}"
if ! avdmanager list avd -c 2>/dev/null | grep -q "pixel_33"; then
    echo "no" | avdmanager create avd -n pixel_33 -k "system-images;android-33;google_apis;x86_64" --device "pixel_5" > /dev/null 2>&1
    echo -e "${GREEN}✓ AVD 'pixel_33' 创建完成${NC}"
else
    echo -e "${GREEN}✓ AVD 'pixel_33' 已存在${NC}"
fi

# 5. 验证安装
echo -e "${YELLOW}[5/5] 验证安装...${NC}"
echo "ADB 版本: $(adb version | head -1)"
echo "模拟器版本: $(emulator -version | head -1)"
echo "可用 AVD:"
avdmanager list avd -c 2>/dev/null || echo "  (暂无)"

echo -e "${GREEN}=== 环境配置完成 ===${NC}"
echo ""
echo "使用方法:"
echo "  1. 启动模拟器: emulator -avd pixel_33 -no-window -no-audio &"
echo "  2. 等待启动完成: adb wait-for-device"
echo "  3. 安装 APK: adb install app.apk"
echo "  4. 查看日志: adb logcat | grep flutter"
