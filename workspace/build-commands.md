# 真实设备测试准备 - 构建命令

> Week 5 Day 6 - 2026-02-28

## 项目信息
- **App名称**: hangzhou_guide
- **版本**: 1.0.0+1
- **Flutter SDK**: >=3.0.0 <4.0.0

---

## 1. Android APK 构建

### 1.1 构建发布版 APK
```bash
flutter build apk --release
```

### 1.2 构建分架构 APK（推荐）
```bash
# ARM64 (现代安卓设备)
flutter build apk --release --target-platform android-arm64

# ARM32 (老旧设备)
flutter build apk --release --target-platform android-arm

# x86_64 (模拟器/部分平板)
flutter build apk --release --target-platform android-x64
```

### 1.3 构建 App Bundle (Google Play)
```bash
flutter build appbundle --release
```

### 1.4 输出路径
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## 2. iOS 构建

### 2.1 构建发布版
```bash
flutter build ios --release
```

### 2.2 构建 IPA（用于分发）
```bash
flutter build ipa --release
```

### 2.3 输出路径
- Runner.app: `build/ios/iphoneos/Runner.app`
- IPA: `build/ios/ipa/山径.ipa`

---

## 3. 构建前检查清单

### 3.1 环境检查
```bash
flutter doctor -v
```

### 3.2 代码检查
```bash
flutter analyze
flutter test
```

### 3.3 依赖检查
```bash
flutter pub get
flutter pub outdated
```

---

## 4. 关键依赖版本

| 依赖 | 版本 | 用途 |
|------|------|------|
| amap_flutter_map | ^3.0.0 | 高德地图 |
| amap_flutter_location | ^3.0.0 | 定位服务 |
| permission_handler | ^11.0.0 | 权限管理 |
| cached_network_image | ^3.3.0 | 图片缓存 |
| flutter_dotenv | ^5.1.0 | 环境变量 |

---

## 5. 测试设备要求

### 5.1 Android 设备
| 要求 | 规格 |
|------|------|
| 最低系统 | Android 5.0 (API 21) |
| 推荐系统 | Android 10+ (API 29+) |
| 架构 | ARM64 (arm64-v8a) |
| 内存 | 4GB+ |
| 存储 | 500MB+ 可用空间 |
| GPS | 必需（支持GPS/北斗/GLONASS） |
| 网络 | WiFi/4G/5G |

**推荐测试机型**:
- 小米 13/14 系列
- 华为 Mate/P 系列
- OPPO Find 系列
- vivo X 系列

### 5.2 iOS 设备
| 要求 | 规格 |
|------|------|
| 最低系统 | iOS 12.0 |
| 推荐系统 | iOS 16+ |
| 设备 | iPhone 8 及以上 |
| GPS | 必需 |
| 网络 | WiFi/4G/5G |

**推荐测试机型**:
- iPhone 14/15 系列
- iPhone 13 系列
- iPhone 12 系列

---

## 6. 权限配置检查

### Android (android/app/src/main/AndroidManifest.xml)
需包含以下权限：
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

### iOS (ios/Runner/Info.plist)
需包含以下权限描述：
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要定位权限以提供导航服务</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>需要后台定位权限以持续记录轨迹</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要定位权限以提供完整导航体验</string>
```

---

## 7. 快速构建脚本

```bash
#!/bin/bash
# build.sh - 快速构建脚本

echo "=== 山径 App 构建脚本 ==="

# 清理
flutter clean

# 获取依赖
flutter pub get

# 分析
flutter analyze

# 构建 Android APK
echo "构建 Android APK..."
flutter build apk --release --target-platform android-arm64

# 构建 iOS (仅Mac)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "构建 iOS..."
    flutter build ios --release
fi

echo "=== 构建完成 ==="
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
```

---

## 8. 注意事项

1. **高德地图Key**: 确保 Android/iOS 都配置了正确的高德地图 API Key
2. **签名配置**: 发布前确认已配置正确的签名证书
3. **环境变量**: 检查 `.env` 文件是否包含必要的配置
4. **资源文件**: 确认 `data/json/trails-all.json` 已正确打包

---

## 9. 分发方式

| 平台 | 方式 |
|------|------|
| Android | APK 直接安装 / 蒲公英 / Firebase |
| iOS | TestFlight / 蒲公英 / Ad Hoc |

---

*生成时间: 2026-02-28*
