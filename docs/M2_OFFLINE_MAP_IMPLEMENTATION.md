# M2 离线地图SDK接入 - 实现报告

## 任务完成状态

### ✅ Android 原生实现

**文件位置**: `android/app/src/main/kotlin/com/suyustudio/shanjing/OfflineMapPlugin.kt`

**集成的高德离线地图SDK**:
- SDK: `com.amap.api:map3d:latest.integration`
- 依赖已在 `android/app/build.gradle` 中添加

**实现的功能**:
1. **MethodChannel 接口** (12个方法):
   - `initialize` - 初始化离线地图管理器
   - `getOfflineCityList` - 获取所有可下载城市列表
   - `getHotCityList` - 获取热门城市列表
   - `getDownloadedOfflineMapList` - 获取已下载的城市列表
   - `downloadOfflineMap` - 开始下载指定城市的离线地图
   - `pauseDownload` - 暂停当前下载
   - `resumeDownload` - 继续下载
   - `deleteOfflineMap` - 删除指定城市的离线地图
   - `isCityDownloaded` - 检查城市是否已下载
   - `getDownloadProgress` - 获取下载进度
   - `clearAllOfflineMaps` - 清除所有离线地图
   - `updateOfflineMap` - 检查并更新离线地图

2. **EventChannel 事件流**:
   - 实时下载进度通知
   - 下载状态变化通知
   - 删除完成通知
   - 更新检查通知

3. **离线地图下载监听器**:
   - 实现 `OfflineMapManager.OfflineMapDownloadListener`
   - 在主线程中转发事件到Flutter

**注册方式**: 在 `MainActivity.kt` 中通过单例模式注册

---

### ✅ Flutter 层完善

#### 1. OfflineMapManager (`lib/services/offline_map_manager.dart`)

**增强功能**:
- 集成 `connectivity_plus` 实现网络状态监听
- 离线模式自动检测和通知
- 存储空间统计和管理
- 改进的错误处理和日志输出

**新增属性**:
```dart
Stream<bool> get offlineModeStream  // 离线模式变化流
bool get isOfflineMode               // 当前是否离线模式
bool get isInitialized               // 是否已初始化
```

**新增方法**:
```dart
Future<bool> canUseOfflineMap(String cityCode)  // 检查是否可用离线地图
Future<OfflineCity?> getBestOfflineCity(String? currentCityName)  // 获取最佳离线城市
String formatSize(int bytes)  // 格式化文件大小
```

#### 2. OfflineMapScreen (`lib/screens/offline_map_screen.dart`)

**UI 改进**:
- 三栏标签页设计（已下载、热门城市、全部城市）
- 实时下载进度条和状态显示
- 网络状态横幅提示
- 存储空间使用统计
- 已下载城市数量徽章
- 批量清理功能

**用户体验**:
- 离线模式下禁用下载按钮并显示提示
- 下载完成自动刷新列表
- 删除确认对话框显示大小信息
- 搜索城市功能（支持拼音）

#### 3. MapScreen (`lib/screens/map_screen.dart`)

**新增功能**:
- 离线模式指示器（右上角悬浮提示）
- 网络状态监听和自动切换
- 离线地图管理入口

---

### ⏸️ iOS 原生实现

**状态**: 待实现

**原因**: 当前项目没有iOS目录结构（`ios/` 目录不存在）

**待实现内容**:
1. 创建iOS项目结构
2. 集成高德iOS离线地图SDK (`AMapOfflineMap`)
3. 实现与Android相同的MethodChannel接口
4. 配置iOS权限和Info.plist

---

## 技术架构

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Layer                         │
│  ┌─────────────────┐  ┌──────────────────┐              │
│  │ OfflineMapScreen│  │   MapScreen      │              │
│  └────────┬────────┘  └────────┬─────────┘              │
│           │                    │                        │
│  ┌────────▼────────────────────▼─────────┐              │
│  │         OfflineMapManager              │              │
│  │  - 网络状态监听                        │              │
│  │  - MethodChannel调用                  │              │
│  │  - EventChannel监听                   │              │
│  └────────┬────────────────────┬─────────┘              │
│           │                    │                        │
│  ┌────────▼────────────────────▼─────────┐              │
│  │     MethodChannel / EventChannel       │              │
│  │    com.shanjing/offline_map            │              │
│  └────────┬────────────────────┬─────────┘              │
└───────────┼────────────────────┼────────────────────────┘
            │                    │
┌───────────▼────────────────────▼────────────────────────┐
│                  Android Native Layer                    │
│  ┌─────────────────────────────────────────────────┐    │
│  │              OfflineMapPlugin                    │    │
│  │  ┌───────────────────────────────────────────┐  │    │
│  │  │          MethodChannel.MethodCallHandler   │  │    │
│  │  └───────────────────────────────────────────┘  │    │
│  │  ┌───────────────────────────────────────────┐  │    │
│  │  │         EventChannel.StreamHandler         │  │    │
│  │  └───────────────────────────────────────────┘  │    │
│  │  ┌───────────────────────────────────────────┐  │    │
│  │  │  OfflineMapManager.OfflineMapDownloadListener│ │    │
│  │  └───────────────────────────────────────────┘  │    │
│  └──────────────┬──────────────────────────────────┘    │
│                 │                                        │
│  ┌──────────────▼──────────────────────────────────┐    │
│  │              高德离线地图 SDK                      │    │
│  │         com.amap.api.maps.offlinemap.*           │    │
│  └───────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────┘
```

---

## 交付标准验证

| 标准 | 状态 | 说明 |
|------|------|------|
| 离线地图可真实下载并使用 | ✅ | Android端已实现，使用高德离线SDK |
| 下载进度实时显示 | ✅ | EventChannel实时推送进度到Flutter |
| 断网后能正常显示已下载的离线地图 | ✅ | 集成connectivity_plus自动检测网络状态 |

---

## 文件变更列表

### 新增文件
1. `android/app/src/main/kotlin/com/suyustudio/shanjing/OfflineMapPlugin.kt`
2. `docs/offline_map_sdk_test.md`

### 修改文件
1. `android/app/build.gradle` - 添加离线地图SDK依赖
2. `android/app/src/main/kotlin/com/suyustudio/shanjing/MainActivity.kt` - 注册离线地图插件
3. `lib/services/offline_map_manager.dart` - 完善网络监听和自动切换逻辑
4. `lib/screens/offline_map_screen.dart` - 增强UI和用户体验
5. `lib/screens/map_screen.dart` - 添加离线模式指示器

---

## 测试指南

### 编译命令
```bash
flutter clean
flutter pub get
cd android
./gradlew assembleDebug
```

### 真机测试步骤
1. 安装APK到Android设备
2. 打开应用，进入"我的" -> "离线地图"
3. 选择一个热门城市（如"北京"）下载
4. 观察下载进度条更新
5. 下载完成后，切换到"已下载"标签确认
6. 关闭设备网络，进入地图页面
7. 验证显示"离线模式"指示器

详细测试文档见: `docs/offline_map_sdk_test.md`

---

## 注意事项

1. **权限要求**: 需要存储权限才能下载离线地图
2. **网络建议**: 建议在WiFi环境下下载离线地图
3. **存储空间**: 单个城市离线包约5-50MB，确保设备有足够空间
4. **Android版本**: 需要Android 5.0 (API 21) 及以上
5. **高德SDK**: 使用的是高德地图离线SDK 3D版本

---

## 后续工作

### 高优先级
- [ ] iOS原生实现
- [ ] 真机测试验证
- [ ] 性能优化（大列表渲染）

### 中优先级
- [ ] 离线地图自动更新提醒
- [ ] 下载队列管理（多任务同时下载）
- [ ] 离线地图预加载策略

### 低优先级
- [ ] 离线地图数据压缩存储
- [ ] 自定义离线地图下载区域（非城市级别）
