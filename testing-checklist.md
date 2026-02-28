# 真实设备测试准备清单

> Week 5 Day 5 - 真实设备测试准备  
> 生成时间: 2026-02-28

---

## 一、AndroidManifest.xml 权限配置检查

### 当前配置状态

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### 配置评估

| 权限 | 状态 | 说明 |
|-----|------|------|
| INTERNET | ✅ | 网络访问必需 |
| ACCESS_FINE_LOCATION | ✅ | 精确定位必需 |
| ACCESS_COARSE_LOCATION | ✅ | 粗略定位备用 |
| ACCESS_BACKGROUND_LOCATION | ✅ | 后台定位必需 |

### 缺失权限（待添加）

| 权限 | 用途 | 优先级 |
|-----|------|-------|
| `WRITE_EXTERNAL_STORAGE` | 保存路线数据、离线地图 | P0 |
| `READ_EXTERNAL_STORAGE` | 读取本地数据 | P0 |
| `CAMERA` | 拍摄照片标记 | P1 |
| `RECORD_AUDIO` | 语音标记录制 | P1 |
| `POST_NOTIFICATIONS` | 推送通知 (Android 13+) | P2 |

---

## 二、Info.plist 权限配置检查

### 当前配置状态

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要定位权限以显示当前位置</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>需要后台定位权限</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要定位权限以显示当前位置</string>
```

### 配置评估

| 权限 | 状态 | 说明 |
|-----|------|------|
| NSLocationWhenInUseUsageDescription | ⚠️ | 文案需优化 |
| NSLocationAlwaysUsageDescription | ⚠️ | 文案需优化 |
| NSLocationAlwaysAndWhenInUseUsageDescription | ⚠️ | 文案需优化 |

### 缺失权限（待添加）

| 权限 | 用途 | 优先级 |
|-----|------|-------|
| `NSCameraUsageDescription` | 相机使用说明 | P1 |
| `NSMicrophoneUsageDescription` | 麦克风使用说明 | P1 |
| `NSPhotoLibraryAddUsageDescription` | 保存照片到相册 | P1 |
| `NSPhotoLibraryUsageDescription` | 读取相册 | P2 |

### 建议文案优化

```xml
<!-- 定位权限 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>山径需要获取您的位置，用于在地图上显示您的当前位置和记录路线轨迹</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>山径需要在后台获取位置，用于持续记录您的路线轨迹（仅在开始记录后）</string>
```

---

## 三、真实设备测试检查清单

### 3.1 安装测试

| 检查项 | Android | iOS | 状态 |
|-------|---------|-----|------|
| Debug APK 安装 | ⬜ | - | 待测 |
| Release APK 安装 | ⬜ | - | 待测 |
| TestFlight 安装 | - | ⬜ | 待测 |
| 首次启动时间 | ⬜ | ⬜ | 待测 |
| 冷启动/热启动 | ⬜ | ⬜ | 待测 |

### 3.2 定位功能测试

| 检查项 | Android | iOS | 状态 |
|-------|---------|-----|------|
| 首次启动权限申请 | ⬜ | ⬜ | 待测 |
| 定位精度 (<10m) | ⬜ | ⬜ | 待测 |
| 后台定位保活 | ⬜ | ⬜ | 待测 |
| GPS 信号弱场景 | ⬜ | ⬜ | 待测 |
| 室内定位表现 | ⬜ | ⬜ | 待测 |
| 权限被拒绝处理 | ⬜ | ⬜ | 待测 |
| 权限永久拒绝引导 | ⬜ | ⬜ | 待测 |

### 3.3 地图功能测试

| 检查项 | Android | iOS | 状态 |
|-------|---------|-----|------|
| 高德地图加载 | ⬜ | ⬜ | 待测 |
| 地图缩放/平移 | ⬜ | ⬜ | 待测 |
| 当前位置标记 | ⬜ | ⬜ | 待测 |
| 路线轨迹绘制 | ⬜ | ⬜ | 待测 |
| 标记点显示 | ⬜ | ⬜ | 待测 |
| 离线地图包下载 | ⬜ | ⬜ | 待测 |

### 3.4 导航功能测试

| 检查项 | Android | iOS | 状态 |
|-------|---------|-----|------|
| 轨迹跟随算法 | ⬜ | ⬜ | 待测 |
| 偏航检测 (30m阈值) | ⬜ | ⬜ | 待测 |
| 偏航重新规划 | ⬜ | ⬜ | 待测 |
| 语音播报 | ⬜ | ⬜ | 待测 |
| 进度显示 | ⬜ | ⬜ | 待测 |
| 息屏后导航 | ⬜ | ⬜ | 待测 |

### 3.5 性能测试

| 检查项 | Android | iOS | 状态 |
|-------|---------|-----|------|
| 页面切换流畅度 | ⬜ | ⬜ | 待测 |
| 地图渲染帧率 | ⬜ | ⬜ | 待测 |
| 内存占用 | ⬜ | ⬜ | 待测 |
| CPU 占用 | ⬜ | ⬜ | 待测 |
| 电池消耗 | ⬜ | ⬜ | 待测 |
| 长时间导航稳定性 | ⬜ | ⬜ | 待测 |

### 3.6 兼容性测试

| 检查项 | Android | iOS | 状态 |
|-------|---------|-----|------|
| Android 10 | ⬜ | - | 待测 |
| Android 12 | ⬜ | - | 待测 |
| Android 14 | ⬜ | - | 待测 |
| iOS 15 | - | ⬜ | 待测 |
| iOS 16 | - | ⬜ | 待测 |
| iOS 17 | - | ⬜ | 待测 |

---

## 四、已知问题记录

### 4.1 权限相关问题

| 问题 | 严重程度 | 状态 | 备注 |
|-----|---------|------|------|
| Android 存储权限未配置 | 🔴 高 | 待修复 | 影响路线保存 |
| iOS 权限文案不够友好 | 🟡 中 | 待优化 | 需按规范修改 |
| iOS 相机/麦克风权限缺失 | 🟡 中 | 待添加 | 可选功能 |

### 4.2 功能相关问题

| 问题 | 严重程度 | 状态 | 备注 |
|-----|---------|------|------|
| 地图页功能缺失严重 | 🔴 高 | 开发中 | 标记点、卡片浮层 |
| 详情页 Tab 导航未实现 | 🔴 高 | 开发中 | 轨迹/评价/攻略 |
| API Key 硬编码 | 🟡 中 | 待修复 | 安全风险 |
| 点击卡片无跳转 | 🟡 中 | 待修复 | 导航逻辑缺失 |

### 4.3 性能相关问题

| 问题 | 严重程度 | 状态 | 备注 |
|-----|---------|------|------|
| GPS 精度过滤未实现 | 🔴 高 | 待开发 | <10m 过滤 |
| 后台保活策略待验证 | 🟡 中 | 待测试 | background_locator |
| 离线地图性能待测 | 🟡 中 | 待测试 | 大文件下载 |

---

## 五、测试设备准备

### 5.1 Android 设备

| 设备 | 系统版本 | 状态 | 负责人 |
|-----|---------|------|-------|
| (待补充) | Android 12+ | ⬜ | - |

### 5.2 iOS 设备

| 设备 | 系统版本 | 状态 | 负责人 |
|-----|---------|------|-------|
| (待补充) | iOS 16+ | ⬜ | - |

---

## 六、下一步行动

1. **权限配置修复** (Day 5)
   - [ ] 补充 Android 存储权限
   - [ ] 优化 iOS 权限文案
   - [ ] 添加相机/麦克风权限配置

2. **功能补全** (Day 5-6)
   - [ ] 地图页标记点和卡片浮层
   - [ ] 详情页 Tab 导航
   - [ ] API Key 安全处理

3. **设备测试** (Day 6-7)
   - [ ] 准备测试设备
   - [ ] 执行测试清单
   - [ ] 记录问题并修复

---

*文档生成: 2026-02-28*  
*关联文档: shanjing-permissions.md, review-dev-flutter-by-product.md*
