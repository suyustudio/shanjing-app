# Android测试环境搭建记录

## 当前状态
正在配置本地Android测试环境，以便能够：
1. 安装APK文件
2. 启动Android模拟器
3. 查看应用运行状态（是否白屏）
4. 获取logcat日志进行调试

## 已完成
- ✅ Android SDK已安装在 `/usr/lib/android-sdk`
- ✅ emulator 和 adb 工具可用
- ✅ 下载 cmdline-tools (进行中)

## 进行中
- 🔄 下载 commandlinetools (约200MB)
- ⏳ 安装系统镜像 (约1GB)
- ⏳ 创建AVD (Android Virtual Device)
- ⏳ 启动模拟器

## 环境配置脚本

```bash
# 环境变量
export ANDROID_SDK_ROOT=/usr/lib/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin

# 检查工具
which adb      # /usr/bin/adb
which emulator # /usr/bin/emulator
which sdkmanager # 安装后可用
```

## 下一步
1. 等待cmdline-tools下载完成
2. 使用sdkmanager下载系统镜像: `sdkmanager "system-images;android-33;google_apis;x86_64"`
3. 创建AVD: `avdmanager create avd -n test -k "system-images;android-33;google_apis;x86_64"`
4. 启动模拟器: `emulator -avd test -no-window`
5. 安装APK: `adb install app-release.apk`
6. 查看日志: `adb logcat`

## 预计时间
- 下载系统镜像: 5-10分钟
- 创建和启动AVD: 2-3分钟
- 总计: 约15-20分钟完成环境配置

---
更新时间: 2026-03-17 12:45
