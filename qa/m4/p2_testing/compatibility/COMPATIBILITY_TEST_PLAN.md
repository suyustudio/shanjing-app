# 山径APP - M4 P2 兼容性测试方案

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **测试范围**: Android 8-14, iOS 14-17  
> **厂商覆盖**: 小米、华为、OPPO、vivo

---

## 1. 测试概述

### 1.1 测试目标

验证山径APP在不同Android版本和厂商定制系统上的兼容性，确保核心功能在各主流设备上正常运行。

| 目标维度 | 具体目标 | 成功标准 |
|---------|---------|---------|
| **系统兼容性** | Android 8-14 全覆盖 | 核心功能100%可用 |
| **厂商适配** | 主流厂商系统适配 | 无严重兼容性问题 |
| **功能一致性** | 各平台体验一致 | UI/功能无差异 |
| **性能稳定** | 各平台性能达标 | 启动<3s，内存<300MB |

### 1.2 测试矩阵

| 系统版本 | 小米 | 华为 | OPPO | vivo | Google | 优先级 |
|----------|------|------|------|------|--------|--------|
| Android 14 | P0 | P0 | P0 | P0 | P1 | 最高 |
| Android 13 | P0 | P0 | P0 | P0 | P1 | 最高 |
| Android 12 | P1 | P1 | P1 | P1 | P2 | 高 |
| Android 11 | P1 | P1 | P1 | P1 | P2 | 高 |
| Android 10 | P1 | P1 | P1 | P1 | P3 | 中 |
| Android 9 | P2 | P2 | P2 | P2 | - | 中 |
| Android 8 | P2 | P2 | P2 | P2 | - | 低 |

---

## 2. 测试环境

### 2.1 设备清单

#### Android 测试设备

| 厂商 | 型号 | 系统版本 | MIUI/EMUI/ColorOS | 优先级 | 来源 |
|------|------|----------|-------------------|--------|------|
| 小米 | Xiaomi 14 | Android 14 | HyperOS 1.0 | P0 | 真机 |
| 小米 | Redmi K70 | Android 13 | MIUI 15 | P0 | 真机 |
| 小米 | Mi 11 | Android 12 | MIUI 13 | P1 | 真机/云测 |
| 华为 | Mate 60 Pro | Android 12 | HarmonyOS 4.0 | P0 | 真机 |
| 华为 | P60 | Android 12 | HarmonyOS 3.1 | P0 | 真机 |
| 华为 | Nova 11 | Android 12 | EMUI 13 | P1 | 云测 |
| OPPO | Find X7 | Android 14 | ColorOS 14 | P0 | 真机 |
| OPPO | Reno 11 | Android 13 | ColorOS 13 | P0 | 真机 |
| OPPO | A2 Pro | Android 13 | ColorOS 13 | P1 | 云测 |
| vivo | X100 | Android 14 | OriginOS 4 | P0 | 真机 |
| vivo | S18 | Android 13 | OriginOS 3 | P0 | 真机 |
| vivo | Y100 | Android 13 | OriginOS 3 | P1 | 云测 |

#### iOS 测试设备

| 型号 | 系统版本 | 优先级 | 来源 |
|------|----------|--------|------|
| iPhone 15 Pro | iOS 17 | P0 | 真机 |
| iPhone 14 | iOS 16 | P0 | 真机 |
| iPhone 13 | iOS 15 | P1 | 真机 |
| iPhone 12 | iOS 14 | P2 | 云测 |

### 2.2 云测平台

| 平台 | 覆盖范围 | 用途 |
|------|----------|------|
| Firebase Test Lab | Android全版本 | 自动化兼容性测试 |
| AWS Device Farm | Android/iOS | 扩展设备覆盖 |
| 腾讯WeTest | 国产厂商 | 华为/小米/OPPO/vivo |
| 百度MTC | 国产厂商 | 补充覆盖 |

---

## 3. 兼容性测试项目

### 3.1 安装与启动测试

| 测试项 | 测试内容 | 通过标准 |
|--------|----------|----------|
| 安装测试 | APK安装、首次启动 | 安装成功，启动正常 |
| 权限申请 | 位置、存储权限 | 申请时机合理，可正常授权 |
| 冷启动 | 首次启动时间 | <3s |
| 热启动 | 后台恢复时间 | <1s |
| 升级测试 | 覆盖安装旧版本 | 数据不丢失，功能正常 |

### 3.2 核心功能兼容性

| 功能模块 | 测试项 | 各平台一致性要求 |
|----------|--------|------------------|
| **用户系统** | 登录/注册/注销 | 100%一致 |
| **路线发现** | 列表加载/搜索/筛选 | 100%一致 |
| **路线详情** | 信息展示/海拔图/POI | 100%一致 |
| **导航功能** | GPS定位/轨迹/语音 | 100%一致 |
| **离线地图** | 下载/使用/更新 | 100%一致 |
| **收藏功能** | 添加/移除/列表 | 100%一致 |
| **分享功能** | 海报生成/分享 | 100%一致 |
| **SOS功能** | 触发/取消/流程 | 100%一致 |

### 3.3 UI兼容性测试

| 测试项 | 测试内容 | 通过标准 |
|--------|----------|----------|
| 屏幕适配 | 不同分辨率/比例 | 无变形、无截断 |
| 字体显示 | 系统字体大小设置 | 正常显示，不重叠 |
| 暗黑模式 | 系统主题切换 | 正确响应，显示正常 |
| 刘海屏适配 | 状态栏/手势区 | 内容不被遮挡 |
| 折叠屏适配 | 展开/折叠状态 | 布局自适应 |

### 3.4 厂商特性适配

#### 小米/HyperOS

| 特性 | 适配点 | 测试项 |
|------|--------|--------|
| 应用权限管理 | 后台定位权限 | 验证后台持续定位 |
| 省电策略 | 后台限制 | 验证不被误杀 |
| 通知管理 | 通知权限 | 验证SOS通知显示 |
| 悬浮窗 | 导航悬浮窗 | 验证权限和显示 |

#### 华为/HarmonyOS

| 特性 | 适配点 | 测试项 |
|------|--------|--------|
| 位置服务 | 融合定位 | 验证定位精度 |
| 后台管理 | 应用启动管理 | 验证自启动权限 |
| 电池优化 | 忽略电池优化 | 验证后台保活 |
| 通知渠道 | 通知分类管理 | 验证重要通知显示 |

#### OPPO/ColorOS

| 特性 | 适配点 | 测试项 |
|------|--------|--------|
| 后台冻结 | 后台应用管理 | 验证后台保活 |
| 省电模式 | 高性能模式 | 验证定位频率 |
| 应用分身 | 双开支持 | 验证数据隔离 |
| 通知栏 | 通知显示样式 | 验证内容完整 |

#### vivo/OriginOS

| 特性 | 适配点 | 测试项 |
|------|--------|--------|
| 后台高耗电 | 高耗电管理 | 验证白名单设置 |
| 自启动管理 | 允许自启动 | 验证服务启动 |
| 悬浮球 | 系统悬浮球冲突 | 验证无冲突 |
| 深色模式 | 强制深色 | 验证APP适配 |

---

## 4. 专项兼容性测试

### 4.1 定位服务兼容性

| 测试项 | 小米 | 华为 | OPPO | vivo | 通过标准 |
|--------|------|------|------|------|----------|
| GPS定位精度 | <10m | <10m | <10m | <10m | 偏差<20m |
| 网络定位精度 | <50m | <50m | <50m | <50m | 偏差<100m |
| 后台定位频率 | 1-5s | 1-5s | 1-5s | 1-5s | <10s |
| 定位服务保活 | 正常 | 正常 | 正常 | 正常 | 无断点 |

### 4.2 权限兼容性

| 权限 | Android 8 | Android 10 | Android 12 | Android 14 | 行为一致性 |
|------|-----------|------------|------------|------------|------------|
| 位置权限 | 一次授权 | 仅使用时 | 精确定位 | 新权限模型 | 适配各版本 |
| 存储权限 | 运行时申请 | Scoped Storage | 分区存储 | 加强限制 | 适配各版本 |
| 通知权限 | 默认允许 | 默认允许 | 默认允许 | 需主动申请 | Android 14+ |
| 后台运行 | 无限制 | 限制加强 | 严格限制 | 严格限制 | 引导用户设置 |

### 4.3 地图SDK兼容性

| 测试项 | 高德SDK | 通过标准 |
|--------|---------|----------|
| SDK初始化 | 各平台正常初始化 | 无崩溃 |
| 地图显示 | 地图瓦片正常加载 | 无灰屏 |
| 离线地图 | 下载/解压/使用正常 | 功能完整 |
| 导航功能 | 路线计算/轨迹绘制 | 准确无误 |

---

## 5. 自动化兼容性测试

### 5.1 Firebase Test Lab 配置

```yaml
# firebase_test_lab.yaml
defaults:
  test_timeout: 30m
  
android:
  app: build/app/outputs/apk/release/app-release.apk
  test: build/app/outputs/apk/androidTest/release/app-release-androidTest.apk
  
  device_selection:
    - model: redfin    # Pixel 5
      version: 30      # Android 11
    - model: panther   # Pixel 7
      version: 33      # Android 13
    - model: tangorpro # Pixel Tablet
      version: 34      # Android 14
    
  # 国产厂商云测设备
  additional_apks: []
  
  # 测试配置
  test_setup:
    - orientation: portrait
    - locale: zh_CN
    - billing_method: flame
    
  # 测试类型
  test_types:
    - robo:          # Robo测试
        max_depth: 50
        max_steps: 1000
    - instrumentation: # 仪器测试
        test_runner: androidx.test.runner.AndroidJUnitRunner
```

### 5.2 兼容性测试脚本

```dart
// qa/m4/p2_testing/compatibility/device_compatibility_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shanjing/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('设备兼容性测试', () {
    late DeviceInfoPlugin deviceInfo;
    
    setUp(() {
      deviceInfo = DeviceInfoPlugin();
    });
    
    testWidgets('获取设备信息', (tester) async {
      final androidInfo = await deviceInfo.androidInfo;
      
      // 记录设备信息
      print('设备品牌: ${androidInfo.brand}');
      print('设备型号: ${androidInfo.model}');
      print('系统版本: ${androidInfo.version.release}');
      print('SDK版本: ${androidInfo.version.sdkInt}');
      
      expect(androidInfo.brand.isNotEmpty, true);
    });
    
    testWidgets('核心功能兼容性测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 测试用户系统
      await testAuthFlow(tester);
      
      // 测试路线发现
      await testTrailDiscovery(tester);
      
      // 测试导航功能
      await testNavigation(tester);
      
      // 测试离线地图
      await testOfflineMap(tester);
      
      // 测试SOS功能
      await testSOS(tester);
    }, timeout: const Timeout(Duration(minutes: 10)));
  });
}

// 各功能测试辅助方法
Future<void> testAuthFlow(WidgetTester tester) async {
  // 登录流程测试
  await tester.tap(find.byKey(const Key('profile_tab')));
  await tester.pumpAndSettle();
  
  // 验证页面正常显示
  expect(find.text('我的'), findsOneWidget);
}

Future<void> testTrailDiscovery(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('discover_tab')));
  await tester.pumpAndSettle();
  
  // 等待列表加载
  await tester.pump(const Duration(seconds: 2));
  
  // 验证路线列表显示
  expect(find.byType(TrailCard), findsWidgets);
}

Future<void> testNavigation(WidgetTester tester) async {
  // 点击第一条路线
  await tester.tap(find.byType(TrailCard).first);
  await tester.pumpAndSettle();
  
  // 开始导航
  await tester.tap(find.text('开始导航'));
  await tester.pumpAndSettle();
  
  // 验证导航页显示
  expect(find.byType(NavigationScreen), findsOneWidget);
  
  // 退出导航
  await tester.tap(find.byKey(const Key('exit_navigation')));
  await tester.pumpAndSettle();
}

Future<void> testOfflineMap(WidgetTester tester) async {
  // 进入离线地图页面
  await tester.tap(find.byKey(const Key('offline_map_settings')));
  await tester.pumpAndSettle();
  
  // 验证页面加载
  expect(find.text('离线地图'), findsOneWidget);
}

Future<void> testSOS(WidgetTester tester) async {
  // 进入导航后测试SOS
  await tester.tap(find.text('开始导航'));
  await tester.pumpAndSettle();
  
  // 点击SOS按钮
  await tester.tap(find.byKey(const Key('sos_button')));
  await tester.pumpAndSettle();
  
  // 验证SOS页面显示
  expect(find.text('紧急求救'), findsOneWidget);
  
  // 取消SOS
  await tester.tap(find.text('取消'));
  await tester.pumpAndSettle();
}
```

### 5.3 厂商适配测试脚本

```dart
// qa/m4/p2_testing/compatibility/vendor_specific_test.dart

import 'package:flutter/services.dart';

class VendorCompatibilityTest {
  static const platform = MethodChannel('com.shanjing/vendor_compat');
  
  // 测试小米后台权限
  static Future<bool> testXiaomiBackgroundPermission() async {
    try {
      final result = await platform.invokeMethod('checkXiaomiBackgroundPermission');
      return result as bool;
    } catch (e) {
      print('小米后台权限测试失败: $e');
      return false;
    }
  }
  
  // 测试华为位置服务
  static Future<bool> testHuaweiLocationService() async {
    try {
      final result = await platform.invokeMethod('checkHuaweiLocationService');
      return result as bool;
    } catch (e) {
      print('华为位置服务测试失败: $e');
      return false;
    }
  }
  
  // 测试OPPO后台管理
  static Future<bool> testOPPOBackgroundManagement() async {
    try {
      final result = await platform.invokeMethod('checkOPPOBackgroundManagement');
      return result as bool;
    } catch (e) {
      print('OPPO后台管理测试失败: $e');
      return false;
    }
  }
  
  // 测试vivo高耗电管理
  static Future<bool> testVivoHighPowerManagement() async {
    try {
      final result = await platform.invokeMethod('checkVivoHighPowerManagement');
      return result as bool;
    } catch (e) {
      print('vivo高耗电管理测试失败: $e');
      return false;
    }
  }
}
```

---

## 6. 手动兼容性测试清单

### 6.1 小米设备测试清单

| 测试项 | 测试步骤 | 预期结果 | 实测结果 | 通过 |
|--------|----------|----------|----------|------|
| 后台定位权限 | 设置→应用管理→权限管理→后台定位 | 允许后台定位 | | ⬜ |
| 省电策略 | 设置→电池与性能→省电优化 | 无限制 | | ⬜ |
| 自启动管理 | 设置→应用设置→授权管理→自启动 | 允许自启动 | | ⬜ |
| 通知管理 | 设置→通知与控制中心→通知管理 | 允许通知 | | ⬜ |
| 悬浮窗权限 | 设置→应用设置→授权管理→悬浮窗 | 允许悬浮窗 | | ⬜ |

### 6.2 华为设备测试清单

| 测试项 | 测试步骤 | 预期结果 | 实测结果 | 通过 |
|--------|----------|----------|----------|------|
| 位置服务 | 设置→隐私→定位服务 | 高精度模式 | | ⬜ |
| 应用启动管理 | 手机管家→启动管理 | 手动管理，允许自启动 | | ⬜ |
| 电池优化 | 设置→电池→更多电池设置→休眠时始终保持网络 | 开启 | | ⬜ |
| 后台运行 | 设置→应用和服务→应用启动管理 | 手动管理 | | ⬜ |

### 6.3 OPPO设备测试清单

| 测试项 | 测试步骤 | 预期结果 | 实测结果 | 通过 |
|--------|----------|----------|----------|------|
| 后台冻结 | 设置→电池→应用耗电管理 | 允许完全后台行为 | | ⬜ |
| 自启动管理 | 手机管家→权限隐私→自启动管理 | 允许自启动 | | ⬜ |
| 省电模式 | 设置→电池→省电模式 | 关闭或允许后台运行 | | ⬜ |
| 应用分身 | 设置→应用管理→应用分身 | 如有需要支持双开 | | ⬜ |

### 6.4 vivo设备测试清单

| 测试项 | 测试步骤 | 预期结果 | 实测结果 | 通过 |
|--------|----------|----------|----------|------|
| 后台高耗电 | 设置→电池→后台高耗电 | 允许后台高耗电 | | ⬜ |
| 自启动管理 | 设置→应用与权限→权限管理→自启动 | 允许自启动 | | ⬜ |
| 悬浮球冲突 | 设置→快捷与辅助→悬浮球 | 与导航悬浮窗无冲突 | | ⬜ |
| 深色模式 | 设置→显示与亮度→深色模式 | APP正确适配 | | ⬜ |

---

## 7. 测试执行计划

### 7.1 测试阶段

| 阶段 | 时间 | 内容 | 负责人 |
|------|------|------|--------|
| 第一阶段 | Day 1-2 | P0设备真机测试 | QA |
| 第二阶段 | Day 3-4 | P1设备云测+真机 | QA |
| 第三阶段 | Day 5 | P2设备云测覆盖 | QA |
| 第四阶段 | Day 6 | 问题复现与验证 | QA+Dev |
| 第五阶段 | Day 7 | 报告产出 | QA |

### 7.2 测试资源

| 资源类型 | 数量 | 用途 |
|----------|------|------|
| Android真机 | 8台 | P0设备测试 |
| iPhone真机 | 2台 | iOS兼容性测试 |
| 云测机时 | 100小时 | 扩展设备覆盖 |
| 测试人员 | 2人 | 并行测试 |

---

## 8. 问题分级与处理

### 8.1 问题分级标准

| 级别 | 定义 | 示例 | 处理时限 |
|------|------|------|----------|
| P0 | 崩溃/ANR/功能完全不可用 | APP启动崩溃，导航无法开始 | 立即 |
| P1 | 主要功能受影响 | 定位漂移严重，离线地图无法下载 | 24小时 |
| P2 | 次要功能异常 | UI显示异常，特定机型适配问题 | 72小时 |
| P3 | 体验优化项 | 动画不流畅，字体显示略大 | 下个版本 |

### 8.2 问题报告模板

```markdown
## 兼容性问题报告

### 基本信息
- 设备品牌: [小米/华为/OPPO/vivo]
- 设备型号: 
- 系统版本: 
- 定制系统版本: [MIUI/EMUI/ColorOS/OriginOS X.X]
- APP版本: 

### 问题描述
[详细描述问题现象]

### 复现步骤
1. 
2. 
3. 

### 预期结果

### 实际结果

### 截图/录屏
[附件]

### 日志
[关键日志]

### 问题分级
- [ ] P0 阻塞性
- [ ] P1 严重
- [ ] P2 一般
- [ ] P3 轻微
```

---

## 9. 测试交付物

| 交付物 | 格式 | 内容 | 截止时间 |
|--------|------|------|----------|
| 兼容性测试报告 | Markdown | 测试结果汇总 | Day 7 |
| 问题清单 | Excel | 按分级分类的问题 | Day 6 |
| 厂商适配指南 | Markdown | 各厂商适配要点 | Day 7 |
| 测试数据 | CSV | 各设备测试结果 | Day 7 |
| 测试截图 | JPG/PNG | 关键界面截图 | Day 7 |

---

## 10. 附录

### 10.1 厂商适配文档

| 厂商 | 文档链接 |
|------|----------|
| 小米 | https://dev.mi.com/console/doc/detail?pId=1004 |
| 华为 | https://developer.huawei.com/consumer/cn/doc/app/FAQ-faq-01 |
| OPPO | https://open.oppomobile.com/wiki/doc#id=10160 |
| vivo | https://dev.vivo.com.cn/documentCenter/doc/185 |

### 10.2 测试命令

```bash
# 运行兼容性测试
flutter test qa/m4/p2_testing/compatibility/

# 运行特定厂商测试
flutter test qa/m4/p2_testing/compatibility/vendor_specific_test.dart

# 运行设备信息测试
flutter test qa/m4/p2_testing/compatibility/device_compatibility_test.dart
```

### 10.3 相关文档

| 文档 | 路径 |
|------|------|
| M4 功能规划 | M4-FEATURE-PLAN.md |
| 验收检查清单 | M4-ACCEPTANCE-CHECKLIST.md |
| iOS适配方案 | ios-adaptation-v1.0.md |
| iOS兼容性矩阵 | qa/m4/ios/IOS_COMPATIBILITY_MATRIX.md |

---

> **文档编写**: QA Agent  
> **评审待办**: Dev Agent（确认厂商适配实现）、Product Agent（确认测试范围）
