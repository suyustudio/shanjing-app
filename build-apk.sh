#!/bin/bash
# 构建脚本 - 在本地或 CI 环境运行

# 1. 安装 Flutter（如未安装）
if ! command -v flutter &> /dev/null; then
    echo "正在安装 Flutter..."
    cd /opt
    wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz
    tar xf flutter_linux_3.19.0-stable.tar.xz
    export PATH="/opt/flutter/bin:$PATH"
fi

# 2. 进入项目目录
cd /root/.openclaw/workspace

# 3. 获取依赖
flutter pub get

# 4. 构建 Release APK
flutter build apk --release

# 5. 输出 APK 路径
echo "构建完成！"
echo "APK 路径: build/app/outputs/flutter-apk/app-release.apk"
