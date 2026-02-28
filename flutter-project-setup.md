# Flutter 项目搭建指南 - 山径

> Week 5 Day 1 任务 - M1 Flutter 项目基础搭建

---

## 1. 创建 Flutter 项目

```bash
flutter create shanjing_app
```

项目信息：
- **项目名称**: shanjing_app（山径）
- **包名**: com.example.shanjing_app
- **平台**: Android / iOS / Web

---

## 2. 配置 pubspec.yaml

```yaml
name: shanjing_app
description: 山径 - 户外徒步路线规划与导航应用

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # 高德地图 SDK
  amap_flutter_map: ^3.0.0
  amap_flutter_location: ^3.0.0
  
  # HTTP 请求
  http: ^1.1.0
  
  # 本地存储
  shared_preferences: ^2.2.2
  
  # UI 增强
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
```

### 依赖说明

| 依赖 | 版本 | 用途 |
|------|------|------|
| amap_flutter_map | ^3.0.0 | 高德地图 Flutter 插件（地图显示） |
| amap_flutter_location | ^3.0.0 | 高德定位 SDK |
| http | ^1.1.0 | HTTP 网络请求 |
| shared_preferences | ^2.2.2 | 本地键值对存储 |

---

## 3. 目录结构

```
shanjing_app/
├── android/              # Android 原生代码
├── ios/                  # iOS 原生代码
├── lib/                  # Dart 主代码目录
│   ├── main.dart         # 应用入口
│   ├── app.dart          # 应用配置
│   ├── screens/          # 页面/屏幕组件
│   │   ├── home_screen.dart
│   │   ├── map_screen.dart
│   │   ├── route_screen.dart
│   │   └── profile_screen.dart
│   ├── services/         # 业务逻辑/服务层
│   │   ├── api_service.dart
│   │   ├── location_service.dart
│   │   └── storage_service.dart
│   ├── models/           # 数据模型
│   │   ├── trail.dart
│   │   ├── user.dart
│   │   └── location.dart
│   └── widgets/          # 可复用组件
│       └── common/
├── assets/               # 静态资源
│   ├── images/
│   └── icons/
├── test/                 # 测试代码
├── pubspec.yaml          # 项目配置
└── README.md
```

---

## 4. 初始化命令

```bash
# 进入项目目录
cd shanjing_app

# 安装依赖
flutter pub get

# 运行项目（调试模式）
flutter run

# 构建 APK
flutter build apk

# 构建 iOS
flutter build ios
```

---

## 5. 高德地图配置（后续步骤）

### Android 配置

1. 在 `android/app/src/main/AndroidManifest.xml` 添加：
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application
        android:name="${applicationName}"
        android:label="shanjing_app">
        
        <!-- 高德地图 API Key -->
        <meta-data
            android:name="com.amap.api.v2.apikey"
            android:value="YOUR_AMAP_KEY"/>
    </application>
</manifest>
```

### iOS 配置

1. 在 `ios/Runner/Info.plist` 添加：
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要使用您的位置来显示当前位置</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>需要使用您的位置来记录轨迹</string>
```

---

## 6. 基础代码模板

### main.dart
```dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const ShanjingApp());
}
```

### app.dart
```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class ShanjingApp extends StatelessWidget {
  const ShanjingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '山径',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

---

## 完成状态

- [x] Flutter 项目创建
- [x] pubspec.yaml 依赖配置
- [x] 目录结构设计
- [ ] 高德地图 API Key 申请
- [ ] Android/iOS 原生配置
- [ ] 首页 UI 开发

---

*文档生成时间: 2026-02-28*
