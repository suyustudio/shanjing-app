# 研究课题：Flutter 高德地图插件 JNI 崩溃问题

## 1. 问题概述

在 Flutter 项目中集成高德地图（`amap_flutter_map: ^3.0.0`）时，Android 平台出现 JNI 崩溃，导致应用闪退。该问题在 Firebase Test Lab 和本地构建中均可复现。

**项目信息：**
- 项目：山径APP（城市轻度徒步向导）
- 技术栈：Flutter 3.19.0 + Dart + Android (Gradle)
- 地图插件：`amap_flutter_map: ^3.0.0`
- 构建环境：GitHub Actions (Ubuntu) + Firebase Test Lab

---

## 2. 错误现象

### 2.1 崩溃日志

```
JNI DETECTED ERROR: java_class == null in call to GetStaticMethodID
    from java.lang.Class com.autonavi.base.amap.mapcore.ClassTools.getClass(java.lang.String, java.lang.String)
    from libAMapSDK_MAP_v9_2_0.so (offset 0x1230000)
    from libAMapSDK_MAP_v8_0_1.so (offset 0x1150000)
```

### 2.2 错误特征

- **触发时机**：地图初始化/加载时
- **崩溃类型**：Native crash (SIGABRT)
- **影响范围**：Android 全版本（API 21-33 均测试过）
- **发生频率**：100% 崩溃

---

## 3. 技术背景

### 3.1 组件架构

```
┌─────────────────────────────────────┐
│           Flutter Layer             │
│      (amap_flutter_map 3.0.0)       │
└──────────────┬──────────────────────┘
               │ Dart FFI / Platform Channel
               ▼
┌─────────────────────────────────────┐
│         Android Native Layer        │
│    (Flutter Plugin Java/Kotlin)     │
└──────────────┬──────────────────────┘
               │ JNI (Java Native Interface)
               ▼
┌─────────────────────────────────────┐
│          AMap SDK (C/C++)           │
│    (libAMapSDK_MAP_vX_X_X.so)       │
└─────────────────────────────────────┘
```

### 3.2 关键组件版本

| 组件 | 版本 | 说明 |
|------|------|------|
| Flutter | 3.19.0 | stable channel |
| amap_flutter_map | 3.0.0 | 官方 Flutter 插件 |
| Kotlin | 1.9.10 | Gradle 插件版本 |
| Gradle | 8.x | Flutter 3.19 默认 |

### 3.3 高德 SDK 版本矩阵

根据 `amap_flutter_map` 插件内部依赖（通过解包 aar 确认）：

| 插件版本 | 内置 3dmap | 内置 location | 内置 search |
|----------|-----------|---------------|-------------|
| 3.0.0 | 8.1.0 | 5.6.1 | 8.1.0 |

---

## 4. 已尝试的方案及结果

### 4.1 方案一：手动添加高德 SDK 依赖（失败）

**配置：**
```gradle
// android/app/build.gradle
dependencies {
    implementation "com.amap.api:3dmap:9.2.1"
    implementation "com.amap.api:location:6.1.0"
    implementation "com.amap.api:search:9.2.1"
}
```

**结果：** ❌ JNI 崩溃（`java_class == null`）

**原因分析：**
- 手动添加的 SDK 版本（9.2.1）与插件内置版本（8.1.0）冲突
- SO 库加载时找不到对应的 Java 类（类名/方法签名不匹配）

---

### 4.2 方案二：匹配插件内置版本（失败）

**配置：**
```gradle
implementation "com.amap.api:3dmap:8.1.0"
implementation "com.amap.api:location:5.6.1"
implementation "com.amap.api:search:8.1.0"
```

**结果：** ❌ 仍然 JNI 崩溃

**原因分析：**
- 即使版本号匹配，手动添加仍会导致重复依赖
- Gradle 依赖解析可能引入多个版本的 SO 库

---

### 4.3 方案三：使用 exclude 排除冲突（失败）

**配置：**
```gradle
implementation('com.amap.api:3dmap:9.2.1') {
    exclude group: 'com.amap.api', module: '3dmap'
}
```

**结果：** ❌ 逻辑矛盾，无法排除自身

---

### 4.4 方案四：不手动添加 SDK 依赖（当前尝试）

**配置：**
```gradle
// 不添加任何高德 SDK 依赖
// 完全依赖 amap_flutter_map 插件自动处理
```

**结果：** 🟡 Build #94-#95 验证中

**潜在问题：**
- `flutter create` 会重新生成 android 目录
- 可能丢失必要的 Maven 仓库配置

---

### 4.5 方案五：Flutter 端隐私合规（已添加）

**配置：**
```dart
AMapWidget(
  apiKey: AMapApiKey(androidKey: '...', iosKey: '...'),
  privacyStatement: const AMapPrivacyStatement(
    hasContains: true,
    hasShow: true,
    hasAgree: true,
  ),
  ...
)
```

**结果：** ✅ 隐私合规已满足，但不是崩溃的根本原因

---

## 5. 相关代码和配置

### 5.1 GitHub Actions 工作流

```yaml
# .github/workflows/build-v33.yml
name: Build APK

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      # 关键步骤：flutter create 会重新生成 android 目录
      - name: Create Android Project
        run: |
          rm -rf android
          flutter create --platforms=android --project-name=shanjing_app .
      
      - name: Fix Kotlin version
        run: |
          sed -i 's/id "org.jetbrains.kotlin.android" version "[^"]*"/id "org.jetbrains.kotlin.android" version "1.9.10"/' android/settings.gradle
      
      - name: Add AMap Maven repo
        run: |
          sed -i '/mavenCentral()/a\        maven { url "https://maven.aliyun.com/repository/public" }' android/settings.gradle
```

### 5.2 当前修复尝试（Build #95）

```yaml
- name: Fix app/build.gradle
  run: |
    # 修复 minSdkVersion
    sed -i 's/minSdkVersion flutter.minSdkVersion/minSdkVersion 21/' android/app/build.gradle
    
    # 添加 ndk 块
    sed -i '/minSdkVersion 21/a\        ndk {\n            abiFilters "arm64-v8a", "armeabi-v7a", "x86_64"\n        }' android/app/build.gradle
    
    # 不手动添加 SDK 依赖，让插件自动处理
```

### 5.3 Flutter 地图页面代码

```dart
// lib/screens/map_screen.dart
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AMapWidget(
        apiKey: const AMapApiKey(
          androidKey: 'e17f8ae117d84e2d2d394a2124866603',
          iosKey: '...',
        ),
        privacyStatement: const AMapPrivacyStatement(
          hasContains: true,
          hasShow: true,
          hasAgree: true,
        ),
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationStyle: MyLocationStyle(),
      ),
    );
  }
}
```

---

## 6. 核心研究问题

### Q1: JNI 崩溃的根本原因是什么？

- 是 SO 库版本不匹配？
- 是 Java 类加载顺序问题？
- 是 Gradle 依赖解析导致的重复库？
- 是 Flutter 插件封装的问题？

### Q2: 如何正确配置高德 SDK 依赖？

- 是否需要手动添加？
- 如何与插件内置版本共存？
- 如何验证依赖解析结果？

### Q3: flutter create 重新生成 android 目录的影响？

- 会丢失哪些配置？
- 如何保持必要的修改？
- 是否有更好的构建方式？

### Q4: 是否有替代方案？

- 使用其他高德 Flutter 插件（如 `amap_map_flutter`）？
- 使用原生地图（Google Maps / Mapbox）？
- 降级 Flutter 或插件版本？

---

## 7. 可能的解决方向

### 方向一：依赖管理

1. 使用 `./gradlew app:dependencies` 分析依赖树
2. 确认是否存在重复的 AMap SDK
3. 使用 `exclude` 或 `force` 统一版本

### 方向二：本地构建验证

1. 在本地 Android Studio 中构建
2. 使用 logcat 查看完整崩溃日志
3. 使用 `ndk-stack` 分析 native 堆栈

### 方向三：插件源码分析

1. 阅读 `amap_flutter_map` 插件源码
2. 确认其内部依赖的高德 SDK 版本
3. 检查是否有已知的兼容性问题

### 方向四：替代插件

1. 评估 `amap_map_flutter` 插件
2. 评估 `flutter_amap_location` + 自定义地图视图
3. 考虑使用 WebView 嵌入高德地图 JS API

---

## 8. 参考资源

### 官方文档
- [高德地图 Flutter 插件文档](https://pub.dev/packages/amap_flutter_map)
- [高德地图 Android SDK 文档](https://developer.amap.com/api/android-sdk/guide/create-project/manual-configuration)
- [Flutter Platform Channel](https://docs.flutter.dev/platform-integration/platform-channels)

### 相关问题
- [GitHub: amap_flutter_map issues](https://github.com/amap-flutter/amap-flutter-map/issues)
- [StackOverflow: JNI DETECTED ERROR](https://stackoverflow.com/search?q=JNI+DETECTED+ERROR+java_class+null)

### 工具
- `ndk-stack`: Native 堆栈解析
- `apkanalyzer`: APK 分析工具
- `./gradlew dependencies`: 依赖树分析

---

## 9. 当前状态

| Build | 状态 | 方案 | 时间 |
|-------|------|------|------|
| #95 | 🔄 运行中 | 移除手动 SDK 依赖 | 2026-03-07 09:35 |
| #94 | ❌ 失败 | 手动添加 9.2.1 | 2026-03-07 09:30 |
| #93 | ✅ success | 无地图功能 | - |

**测试环境：**
- Firebase Test Lab: 已启用（$2,346 赠金）
- 测试设备: Pixel 5 (API 30), Pixel 6 (API 33)

---

## 10. 期望产出

1. **根因分析报告**：JNI 崩溃的根本原因
2. **解决方案**：可行的配置方案或替代方案
3. **最佳实践**：Flutter + 高德地图的集成指南
4. **预防措施**：如何避免类似问题

---

**课题提交时间：** 2026-03-07  
**项目仓库：** https://github.com/suyustudio/shanjing-app  
**联系：** 如需更多信息（完整日志、APK 文件等），请随时联系。
