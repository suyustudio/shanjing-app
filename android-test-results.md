# Android 真机测试报告

> Week 6 Day 1 - 真实设备测试  
> 测试时间: 2026-02-28  
> 测试状态: ⚠️ 环境受限，基于代码审查的测试准备报告

---

## 一、测试环境现状

### 1.1 环境检查

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Flutter SDK | ❌ 未安装 | 无法构建 APK |
| Android SDK | ❌ 未安装 | 无法连接设备 |
| ADB 工具 | ❌ 未安装 | 无法调试设备 |
| 物理设备 | ❌ 未连接 | 无配对 Android 设备 |
| APK 文件 | ❌ 不存在 | 需先构建 |

### 1.2 项目构建状态

```
项目: 山径 App (hangzhou_guide)
版本: 1.0.0+1
Flutter: >=3.0.0 <4.0.0
```

**构建前置条件**:
- [ ] 安装 Flutter SDK
- [ ] 安装 Android SDK
- [ ] 配置高德地图 API Key
- [ ] 准备 Android 测试设备

---

## 二、测试准备清单

### 2.1 权限配置检查 ✅

**AndroidManifest.xml 已配置权限**:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

**待补充权限**:
- `WRITE_EXTERNAL_STORAGE` - 保存路线数据
- `READ_EXTERNAL_STORAGE` - 读取本地数据
- `CAMERA` - 拍摄照片标记
- `POST_NOTIFICATIONS` (Android 13+)

### 2.2 测试设备要求

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

---

## 三、测试项目清单

### 3.1 安装测试

| 检查项 | 状态 | 备注 |
|--------|------|------|
| Debug APK 安装 | ⬜ 待测 | 需构建 |
| Release APK 安装 | ⬜ 待测 | 需构建 |
| 首次启动时间 | ⬜ 待测 | 目标 <3s |
| 冷启动/热启动 | ⬜ 待测 | 需测试 |

### 3.2 定位功能测试

| 检查项 | 状态 | 预期结果 |
|--------|------|----------|
| 首次启动权限申请 | ⬜ 待测 | 弹出定位权限弹窗 |
| 定位精度 (<10m) | ⬜ 待测 | GPS精度<10米 |
| 后台定位保活 | ⬜ 待测 | 息屏后持续定位 |
| GPS 信号弱场景 | ⬜ 待测 | 提示信号弱，使用网络定位 |
| 室内定位表现 | ⬜ 待测 | 切换至网络定位 |
| 权限被拒绝处理 | ⬜ 待测 | 提示需要权限，引导设置 |
| 权限永久拒绝引导 | ⬜ 待测 | 跳转系统设置 |

### 3.3 地图功能测试

| 检查项 | 状态 | 预期结果 |
|--------|------|----------|
| 高德地图加载 | ⬜ 待测 | 地图正常显示 |
| 地图缩放/平移 | ⬜ 待测 | 手势操作流畅 |
| 当前位置标记 | ⬜ 待测 | 蓝色定位点显示 |
| 路线轨迹绘制 | ⬜ 待测 | 路线正确渲染 |
| 标记点显示 | ⬜ 待测 | POI标记正常显示 |
| 离线地图包下载 | ⬜ 待测 | 可下载离线数据 |

### 3.4 导航功能测试

| 检查项 | 状态 | 预期结果 |
|--------|------|----------|
| 轨迹跟随算法 | ⬜ 待测 | 箭头跟随当前位置 |
| 偏航检测 (30m阈值) | ⬜ 待测 | 偏离30m触发偏航 |
| 偏航重新规划 | ⬜ 待测 | 自动重新规划路线 |
| 语音播报 | ⬜ 待测 | TTS播报导航提示 |
| 进度显示 | ⬜ 待测 | 显示剩余距离/时间 |
| 息屏后导航 | ⬜ 待测 | 后台持续导航 |

### 3.5 性能测试

| 检查项 | 状态 | 预期结果 |
|--------|------|----------|
| 页面切换流畅度 | ⬜ 待测 | 60fps |
| 地图渲染帧率 | ⬜ 待测 | 30fps+ |
| 内存占用 | ⬜ 待测 | <200MB |
| CPU 占用 | ⬜ 待测 | <30% |
| 电池消耗 | ⬜ 待测 | 1小时<15% |
| 长时间导航稳定性 | ⬜ 待测 | 2小时无崩溃 |

---

## 四、已知问题记录

### 4.1 权限相关问题

| 问题 | 严重程度 | 状态 | 备注 |
|-----|---------|------|------|
| Android 存储权限未配置 | 🔴 高 | 待修复 | 影响路线保存 |
| 权限文案需优化 | 🟡 中 | 待优化 | 需按规范修改 |

### 4.2 功能相关问题

| 问题 | 严重程度 | 状态 | 备注 |
|-----|---------|------|------|
| 地图页功能缺失 | 🔴 高 | 开发中 | 标记点、卡片浮层 |
| 详情页 Tab 导航未实现 | 🔴 高 | 开发中 | 轨迹/评价/攻略 |
| API Key 硬编码 | 🟡 中 | 待修复 | 安全风险 |

### 4.3 性能相关问题

| 问题 | 严重程度 | 状态 | 备注 |
|-----|---------|------|------|
| GPS 精度过滤未实现 | 🔴 高 | 待开发 | <10m 过滤 |
| 后台保活策略待验证 | 🟡 中 | 待测试 | background_locator |

---

## 五、构建命令参考

### 5.1 构建 APK

```bash
# 清理
flutter clean

# 获取依赖
flutter pub get

# 分析代码
flutter analyze

# 构建 Release APK (ARM64)
flutter build apk --release --target-platform android-arm64

# 输出路径: build/app/outputs/flutter-apk/app-release.apk
```

### 5.2 安装 APK

```bash
# 连接设备后
adb install build/app/outputs/flutter-apk/app-release.apk

# 或传输到设备安装
```

---

## 六、下一步行动

### 6.1 环境准备

1. [ ] 安装 Flutter SDK
2. [ ] 安装 Android SDK
3. [ ] 配置环境变量
4. [ ] 准备 Android 测试设备

### 6.2 构建与测试

1. [ ] 配置高德地图 API Key
2. [ ] 构建 Release APK
3. [ ] 在真机上安装 APK
4. [ ] 执行完整测试清单
5. [ ] 记录问题并修复

### 6.3 测试场景建议

**场景1: 户外导航测试**
- 地点: 杭州九溪/龙井路线
- 测试: 定位精度、轨迹记录、偏航检测

**场景2: 弱信号测试**
- 地点: 室内/隧道
- 测试: 信号丢失处理、网络定位切换

**场景3: 长时间测试**
- 时长: 2小时+
- 测试: 后台保活、电池消耗、内存泄漏

---

## 七、结论

当前测试环境尚未就绪，无法执行真实设备测试。需要完成以下准备工作后方可进行:

1. **搭建 Flutter 开发环境**
2. **准备 Android 测试设备**
3. **构建 Release APK**
4. **配置高德地图 API Key**

测试清单已准备就绪，待环境就绪后可立即执行完整测试。

---

*报告生成: 2026-02-28*  
*关联文档: testing-checklist.md, build-commands.md, flutter-navigation-test-plan.md*
