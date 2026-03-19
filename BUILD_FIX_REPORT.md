# Build 修复报告

## 修复时间
2026-03-14 16:47 GMT+8

## 问题根因（基于 QA 分析报告）

### 1. `settings.gradle` 依赖 `local.properties`
- **问题**: `android/settings.gradle` 尝试从 `local.properties` 读取 `flutter.sdk` 路径
- **后果**: CI 环境中 `local.properties` 文件不存在，导致构建失败
- **错误信息**: `android/settings.gradle not found`

### 2. 高德地图 SDK 版本不稳定
- **问题**: 使用 `latest.integration` 动态版本
- **后果**: 版本不确定，可能导致依赖冲突

## 修复内容

### 修复 1: `android/settings.gradle`
```diff
- def flutterSdkPath = {
-     def properties = new Properties()
-     file("local.properties").withInputStream { properties.load(it) }
-     def flutterSdkPath = properties.getProperty("flutter.sdk")
-     assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
+ def flutterSdkPath = {
+     def properties = new Properties()
+     def localPropertiesFile = file("local.properties")
+     if (localPropertiesFile.exists()) {
+         localPropertiesFile.withInputStream { properties.load(it) }
+     }
+     // 优先从 local.properties 读取，否则使用环境变量
+     def flutterPath = properties.getProperty("flutter.sdk")
+     if (flutterPath == null) {
+         flutterPath = System.getenv("FLUTTER_ROOT")
+     }
+     assert flutterPath != null, "flutter.sdk not set in local.properties or FLUTTER_ROOT environment variable"
```

### 修复 2: `android/app/build.gradle`
```diff
- implementation 'com.amap.api:3dmap-location-search:latest.integration'
- implementation 'com.amap.api:map3d:latest.integration'
+ implementation 'com.amap.api:3dmap-location-search:9.4.0'
+ implementation 'com.amap.api:map3d:9.4.0'
```

### 修复 3: `.github/workflows/build-v55.yml`
```diff
+ - name: Create local.properties
+   run: |
+     echo "flutter.sdk=$FLUTTER_ROOT" > android/local.properties
+     echo "flutter.versionCode=2" >> android/local.properties
+     echo "flutter.versionName=1.0.0" >> android/local.properties
```

## 代码统计
- 修改文件数: 3
- 新增行数: 23
- 删除行数: 7
- **总修改: 30 行** (符合 < 50 行限制)

## 修复后 Build 状态

| 构建编号 | 状态 | 时间 |
|---------|------|------|
| Build #36 | 🔄 in_progress | 2026-03-14 16:47 |
| Build #35 | ❌ failure | 之前 |
| Build #34 | ❌ failure | 之前 |
| Build #33 | ❌ failure | 之前 |

## 验证步骤

1. ✅ `settings.gradle` 现在支持从 `FLUTTER_ROOT` 环境变量读取 Flutter SDK 路径
2. ✅ CI 工作流显式创建 `local.properties` 文件
3. ✅ 高德地图 SDK 版本锁定为 9.4.0
4. 🔄 等待 Build #36 完成验证

## 提交信息
```
commit 2fab5cb4
fix(build): 修复 Flutter CI 构建失败问题

- 修复 settings.gradle 不再强制依赖 local.properties
- 添加 FLUTTER_ROOT 环境变量支持作为备选方案
- 锁定高德地图 SDK 版本到 9.4.0，避免 latest.integration 不稳定
- 在 CI 中显式创建 local.properties 文件
```

## 后续建议

1. **监控 Build #36**: 构建预计需要 5-10 分钟完成
2. **如仍失败**: 检查 Gradle/AGP 版本兼容性（当前使用 AGP 7.3.0）
3. **长期改进**: 考虑使用 `flutter build apk --no-pub` 避免重复依赖解析

---
报告生成: 2026-03-14 16:50 GMT+8
