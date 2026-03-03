# 权限申请问题修复报告

## 修复概述

**问题**: APK 没有申请定位、导航等权限
**状态**: ✅ 已修复
**修复时间**: 2026-03-03

---

## 1. AndroidManifest.xml 权限配置修复

### 修复前的问题
- 缺少前台服务权限（Android 9+ 后台定位需要）
- 存储权限未适配 Android 10+ 分区存储
- 缺少网络状态、WiFi状态等辅助权限

### 修复内容

#### 新增权限
```xml
<!-- 网络状态权限 -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

<!-- 前台服务权限（Android 9+ 后台定位需要） -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />

<!-- Android 13+ 媒体权限 -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />

<!-- 唤醒锁权限（导航保活） -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

#### 适配的权限
```xml
<!-- 存储权限适配 Android 10+ 分区存储 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
```

---

## 2. iOS Info.plist 配置

**说明**: 项目当前为纯 Android 项目，没有 iOS 目录，无需配置 iOS 权限。

如需后续添加 iOS 支持，需要在 `ios/Runner/Info.plist` 中添加以下权限说明：

```xml
<!-- 定位权限 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要定位权限来显示您在地图上的位置</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要后台定位权限来在导航时持续追踪您的位置</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>需要后台定位权限来在导航时持续追踪您的位置</string>

<!-- 相机权限 -->
<key>NSCameraUsageDescription</key>
<string>需要相机权限来拍摄照片</string>

<!-- 通知权限 -->
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>audio</string>
</array>
```

---

## 3. 运行时权限申请流程修复

### 新增文件: `lib/utils/permission_manager.dart`

创建了统一的权限管理工具类，提供以下功能：

#### 核心方法
- `requestLocationPermission()` - 请求前台定位权限
- `requestBackgroundLocationPermission()` - 请求后台定位权限
- `requestStoragePermission()` - 请求存储权限
- `requestCameraPermission()` - 请求相机权限
- `requestNotificationPermission()` - 请求通知权限

#### 组合权限请求
- `requestMapPermissions()` - 请求地图所需权限（定位、存储）
- `requestNavigationPermissions()` - 请求导航所需权限（前台定位、后台定位、通知）

#### 权限检查
- `hasAllMapPermissions()` - 检查地图权限是否全部授予
- `hasAllNavigationPermissions()` - 检查导航权限是否全部授予

#### 权限管理
- `openAppSettings()` - 打开应用设置页面
- `showPermissionDeniedDialog()` - 显示权限拒绝对话框
- `showPermissionPermanentlyDeniedDialog()` - 显示权限永久拒绝对话框

### 修改文件: `lib/screens/map_screen.dart`

**修复内容**:
1. 替换 `permission_handler` 导入为 `permission_manager`
2. 完善 `_requestPermission()` 方法：
   - 使用 `PermissionManager.requestMapPermissions()` 统一申请权限
   - 处理权限被拒绝的情况，显示 SnackBar 提示
   - 处理权限被永久拒绝的情况，显示设置对话框
   - 添加存储权限检查

### 修改文件: `lib/screens/navigation_screen.dart`

**修复内容**:
1. 替换 `permission_handler` 导入为 `permission_manager`
2. 重构 `_requestLocationPermission()` 方法：
   - 使用 `PermissionManager.requestNavigationPermissions()` 申请导航所需权限
   - 检查后台定位权限，如未授予显示提示
   - 检查通知权限状态
   - 添加 `_useDefaultLocation()` 方法处理权限被拒绝情况

---

## 4. 权限申请流程说明

### 地图页面权限流程
```
用户打开地图页面
    ↓
调用 PermissionManager.requestMapPermissions()
    ↓
申请前台定位权限 + 存储权限
    ↓
权限授予 → 初始化定位
    ↓
权限拒绝 → 显示 SnackBar 提示
    ↓
权限永久拒绝 → 显示设置对话框
```

### 导航页面权限流程
```
用户进入导航页面
    ↓
调用 PermissionManager.requestNavigationPermissions()
    ↓
申请前台定位权限
    ↓
申请后台定位权限（需要前台权限先授予）
    ↓
申请通知权限
    ↓
所有权限授予 → 初始化定位
    ↓
后台定位未授予 → 显示提示（建议开启）
    ↓
定位权限拒绝 → 使用默认位置 + 显示提示
```

---

## 5. 测试验证计划

### 5.1 权限弹窗测试

#### 测试场景 1: 首次安装 - 地图页面
**步骤**:
1. 卸载应用后重新安装
2. 打开应用进入地图页面

**预期结果**:
- [ ] 显示定位权限弹窗
- [ ] 用户点击"允许"后，地图显示当前位置
- [ ] 用户点击"拒绝"后，显示 SnackBar 提示"需要定位权限才能显示当前位置"

#### 测试场景 2: 首次安装 - 导航页面
**步骤**:
1. 卸载应用后重新安装
2. 进入路线详情，点击"开始导航"

**预期结果**:
- [ ] 显示定位权限弹窗
- [ ] 用户点击"允许"后，显示后台定位权限弹窗
- [ ] 用户允许后台定位后，显示通知权限弹窗
- [ ] 导航正常启动

#### 测试场景 3: 权限永久拒绝
**步骤**:
1. 首次打开应用，拒绝定位权限
2. 再次进入地图页面

**预期结果**:
- [ ] 显示"去设置"对话框
- [ ] 点击"去设置"跳转到系统设置页面

### 5.2 权限功能测试

#### 测试场景 4: 定位功能
**步骤**:
1. 授予所有定位权限
2. 在地图页面点击定位按钮

**预期结果**:
- [ ] 地图移动到当前位置
- [ ] 显示蓝色定位点

#### 测试场景 5: 后台定位
**步骤**:
1. 开始导航
2. 按 Home 键返回桌面
3. 等待 1 分钟后重新打开应用

**预期结果**:
- [ ] 导航继续运行
- [ ] 位置信息已更新

#### 测试场景 6: 离线地图存储
**步骤**:
1. 授予存储权限
2. 进入离线地图页面
3. 下载城市地图

**预期结果**:
- [ ] 下载成功
- [ ] 文件保存到本地存储

### 5.3 不同 Android 版本测试

| Android 版本 | 前台定位 | 后台定位 | 存储权限 | 测试结果 |
|-------------|---------|---------|---------|---------|
| Android 6.0 (API 23) | ✅ | N/A | ✅ | 待测试 |
| Android 10 (API 29) | ✅ | ✅ | 分区存储 | 待测试 |
| Android 12 (API 31) | ✅ | ✅ | 分区存储 | 待测试 |
| Android 13+ (API 33+) | ✅ | ✅ | 媒体权限 | 待测试 |

---

## 6. 修复文件清单

| 文件路径 | 操作 | 说明 |
|---------|------|------|
| `android/app/src/main/AndroidManifest.xml` | 修改 | 添加完整权限配置 |
| `lib/utils/permission_manager.dart` | 新增 | 统一权限管理工具类 |
| `lib/screens/map_screen.dart` | 修改 | 完善地图权限申请流程 |
| `lib/screens/navigation_screen.dart` | 修改 | 完善导航权限申请流程 |

---

## 7. 注意事项

1. **后台定位权限**: Android 10+ 要求必须先获得前台定位权限，才能申请后台定位权限
2. **存储权限**: Android 10+ 使用分区存储，应用只能访问自己的目录
3. **前台服务**: Android 9+ 后台定位需要配合前台服务使用
4. **权限说明**: 建议在实际发布时，在应用商店的应用描述中说明需要的权限及用途

---

## 8. 后续建议

1. 添加权限引导页面，在用户首次使用时解释权限用途
2. 在设置页面添加权限管理入口，方便用户随时调整
3. 考虑添加"仅使用期间允许"选项的处理
4. 对于 iOS 版本，需要单独配置 Info.plist 权限说明
