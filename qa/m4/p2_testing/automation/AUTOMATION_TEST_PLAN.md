# 山径APP - M4 P2 自动化测试完善方案

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **测试框架**: Flutter Integration Test  
> **CI/CD**: GitHub Actions

---

## 1. 概述

### 1.1 目标

完善山径APP的自动化测试体系，建立完整的E2E测试覆盖和CI/CD集成流程。

| 目标维度 | 具体目标 | 成功标准 |
|---------|---------|---------|
| **E2E测试覆盖** | 核心流程100%覆盖 | 通过率>95% |
| **CI/CD集成** | 每次提交自动触发 | 构建+测试全自动 |
| **测试效率** | 测试执行时间优化 | <30分钟 |
| **问题发现** | 提前发现问题 | 拦截率>80% |

### 1.2 测试金字塔

```
        /\
       /  \
      / E2E \     15% - 集成测试（用户场景）
     /--------\
    /  Widget  \   30% - 组件测试（页面逻辑）
   /------------\
  /    Unit      \ 55% - 单元测试（函数/类）
 /----------------\
```

---

## 2. E2E测试脚本

### 2.1 测试架构

```
qa/m4/p2_testing/automation/
├── e2e/
│   ├── flows/              # 业务流程测试
│   │   ├── auth_flow_test.dart
│   │   ├── navigation_flow_test.dart
│   │   ├── offline_flow_test.dart
│   │   ├── sos_flow_test.dart
│   │   └── share_flow_test.dart
│   ├── scenarios/          # 场景测试
│   │   ├── cold_start_test.dart
│   │   ├── background_test.dart
│   │   ├── network_change_test.dart
│   │   └── battery_low_test.dart
│   ├── regressions/        # 回归测试
│   │   ├── critical_path_test.dart
│   │   └── smoke_test.dart
│   └── utils/              # 测试工具
│       ├── test_data.dart
│       ├── test_helpers.dart
│       └── mock_services.dart
├── scripts/                # 测试脚本
│   ├── run_e2e.sh
│   ├── run_smoke.sh
│   └── generate_report.sh
└── config/
    └── test_config.yaml
```

### 2.2 核心E2E测试脚本

#### 用户认证流程测试

```dart
// qa/m4/p2_testing/automation/e2e/flows/auth_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;
import '../utils/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('用户认证E2E测试', () {
    testWidgets('完整登录流程', (tester) async {
      // 启动APP
      app.main();
      await tester.pumpAndSettle();
      
      // 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      // 点击登录
      await tester.tap(find.text('登录/注册'));
      await tester.pumpAndSettle();
      
      // 输入手机号
      await tester.enterText(
        find.byKey(const Key('phone_input')), 
        '13800138000'
      );
      await tester.pumpAndSettle();
      
      // 获取验证码
      await tester.tap(find.byKey(const Key('get_code_button')));
      await tester.pumpAndSettle();
      
      // 输入验证码
      await tester.enterText(
        find.byKey(const Key('code_input')), 
        '123456'
      );
      await tester.pumpAndSettle();
      
      // 点击登录
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      
      // 验证登录成功
      await waitFor(find.text('我的'), timeout: const Duration(seconds: 5));
      expect(find.text('138****8000'), findsOneWidget);
      
      // 验证埋点上报
      await verifyAnalyticsEvent('login_success');
    });
    
    testWidgets('微信登录流程', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      // 点击微信登录
      await tester.tap(find.byKey(const Key('wechat_login_button')));
      await tester.pumpAndSettle();
      
      // 模拟微信授权（Mock）
      await mockWeChatAuth(success: true);
      await tester.pumpAndSettle();
      
      // 验证登录成功
      expect(find.byKey(const Key('user_avatar')), findsOneWidget);
    });
    
    testWidgets('退出登录流程', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 确保已登录
      await ensureLoggedIn(tester);
      
      // 进入设置
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();
      
      // 点击退出登录
      await tester.tap(find.text('退出登录'));
      await tester.pumpAndSettle();
      
      // 确认退出
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      
      // 验证退出成功
      expect(find.text('登录/注册'), findsOneWidget);
    });
  });
}
```

#### 导航流程测试

```dart
// qa/m4/p2_testing/automation/e2e/flows/navigation_flow_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('导航功能E2E测试', () {
    testWidgets('完整导航流程', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入发现页
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      // 点击第一条路线
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      
      // 验证路线详情页
      expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
      expect(find.text('开始导航'), findsOneWidget);
      
      // 开始导航
      await tester.tap(find.text('开始导航'));
      await tester.pumpAndSettle();
      
      // 验证导航页
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      expect(find.byKey(const Key('map_view')), findsOneWidget);
      
      // 等待GPS定位
      await tester.pump(const Duration(seconds: 3));
      
      // 验证定位状态
      expect(find.byKey(const Key('location_indicator')), findsOneWidget);
      
      // 模拟移动（Mock位置更新）
      await mockLocationUpdates([
        LatLng(30.2596, 120.1479),
        LatLng(30.2588, 120.1432),
        LatLng(30.2315, 120.1289),
      ]);
      await tester.pump(const Duration(seconds: 5));
      
      // 验证轨迹绘制
      expect(find.byKey(const Key('trail_polyline')), findsOneWidget);
      
      // 测试语音播报
      await tester.pump(const Duration(seconds: 10));
      expect(find.byKey(const Key('voice_indicator')), findsOneWidget);
      
      // 退出导航
      await tester.tap(find.byKey(const Key('exit_navigation_button')));
      await tester.pumpAndSettle();
      
      // 确认退出
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      
      // 验证返回详情页
      expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
    }, timeout: const Timeout(Duration(minutes: 2)));
    
    testWidgets('偏航重规划流程', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await startNavigation(tester, trailId: 'R001');
      
      // 模拟偏离路线
      await mockLocationUpdate(LatLng(30.2600, 120.1500)); // 偏离点
      await tester.pump(const Duration(seconds: 5));
      
      // 验证偏航提示
      expect(find.text('已偏离路线'), findsOneWidget);
      
      // 验证自动重规划
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('正在重新规划路线'), findsOneWidget);
    });
    
    testWidgets('导航中接打电话', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await startNavigation(tester, trailId: 'R001');
      
      // 模拟来电
      await simulateIncomingCall();
      await tester.pump(const Duration(seconds: 2));
      
      // 验证导航后台运行
      expect(find.byKey(const Key('navigation_background_indicator')), findsOneWidget);
      
      // 模拟挂断电话
      await simulateCallEnd();
      await tester.pumpAndSettle();
      
      // 验证导航恢复
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      expect(find.byKey(const Key('location_indicator')), findsOneWidget);
    });
  });
}
```

#### 离线地图流程测试

```dart
// qa/m4/p2_testing/automation/e2e/flows/offline_flow_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('离线地图E2E测试', () {
    testWidgets('下载离线地图流程', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      // 进入离线地图设置
      await tester.tap(find.text('离线地图'));
      await tester.pumpAndSettle();
      
      // 验证离线地图管理页
      expect(find.byKey(const Key('offline_map_page')), findsOneWidget);
      
      // 选择城市
      await tester.tap(find.text('杭州市'));
      await tester.pumpAndSettle();
      
      // 点击下载
      await tester.tap(find.byKey(const Key('download_button')));
      await tester.pumpAndSettle();
      
      // 等待下载完成
      await waitFor(
        find.text('下载完成'), 
        timeout: const Duration(minutes: 2)
      );
      
      // 验证下载状态
      expect(find.text('已下载'), findsOneWidget);
    }, timeout: const Timeout(Duration(minutes: 3)));
    
    testWidgets('离线导航流程', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 确保已下载离线地图
      await ensureOfflineMapDownloaded(tester, city: '杭州市');
      
      // 关闭网络
      await setNetworkState(enabled: false);
      
      // 进入发现页
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      // 点击路线（杭州市内）
      await tester.tap(find.text('西湖环湖线'));
      await tester.pumpAndSettle();
      
      // 开始导航
      await tester.tap(find.text('开始导航'));
      await tester.pumpAndSettle();
      
      // 验证离线地图显示
      expect(find.byKey(const Key('map_view')), findsOneWidget);
      expect(find.byKey(const Key('offline_indicator')), findsOneWidget);
      
      // 验证定位正常
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('location_indicator')), findsOneWidget);
      
      // 恢复网络
      await setNetworkState(enabled: true);
    });
    
    testWidgets('离线地图更新流程', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入离线地图管理
      await goToOfflineMapPage(tester);
      
      // 检查更新
      await tester.tap(find.byKey(const Key('check_update_button')));
      await tester.pumpAndSettle();
      
      // 如有更新，点击更新
      if (find.text('有更新').evaluate().isNotEmpty) {
        await tester.tap(find.byKey(const Key('update_button')));
        await tester.pumpAndSettle();
        
        // 等待更新完成
        await waitFor(find.text('已是最新'), timeout: const Duration(minutes: 3));
      }
    });
  });
}
```

#### SOS紧急流程测试

```dart
// qa/m4/p2_testing/automation/e2e/flows/sos_flow_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SOS功能E2E测试', () {
    testWidgets('SOS完整流程（Mock模式）', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await startNavigation(tester, trailId: 'R001');
      
      // 点击SOS按钮
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 验证SOS页面
      expect(find.byKey(const Key('sos_screen')), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // 倒计时
      
      // 等待倒计时
      await tester.pump(const Duration(seconds: 5));
      
      // 验证发送中状态（Mock模式）
      expect(find.text('发送中'), findsOneWidget);
      
      // 验证结果
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('已发送'), findsOneWidget);
      
      // 返回导航
      await tester.tap(find.text('返回导航'));
      await tester.pumpAndSettle();
      
      // 验证返回导航页
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
    });
    
    testWidgets('SOS倒计时取消', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await startNavigation(tester, trailId: 'R001');
      
      // 点击SOS
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 等待2秒
      await tester.pump(const Duration(seconds: 2));
      
      // 点击取消
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      
      // 验证返回导航
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      
      // 验证取消埋点
      await verifyAnalyticsEvent('sos_cancel');
    });
    
    testWidgets('SOS弱网环境测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 设置为弱网
      await setNetworkCondition(NetworkCondition.weak);
      
      await startNavigation(tester, trailId: 'R001');
      
      // 触发SOS
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      
      // 验证弱网提示
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('网络较弱，已本地保存'), findsOneWidget);
      
      // 恢复网络
      await setNetworkCondition(NetworkCondition.normal);
      
      // 验证自动补发
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('已自动补发'), findsOneWidget);
    });
  });
}
```

### 2.3 测试工具类

```dart
// qa/m4/p2_testing/automation/e2e/utils/test_helpers.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/// 等待元素出现
Future<void> waitFor(
  Finder finder, {
  required Duration timeout,
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final endTime = DateTime.now().add(timeout);
  
  while (DateTime.now().isBefore(endTime)) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await Future.delayed(interval);
  }
  
  throw Exception('等待元素超时: $finder');
}

/// 确保用户已登录
Future<void> ensureLoggedIn(WidgetTester tester) async {
  try {
    // 检查是否已登录
    if (find.text('登录/注册').evaluate().isNotEmpty) {
      // 执行登录
      await tester.tap(find.text('登录/注册'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('phone_input')), '13800138000');
      await tester.enterText(find.byKey(const Key('code_input')), '123456');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await waitFor(find.text('我的'), timeout: const Duration(seconds: 5));
    }
  } catch (e) {
    print('登录检查失败: $e');
  }
}

/// 开始导航
Future<void> startNavigation(
  WidgetTester tester, {
  required String trailId,
}) async {
  // 进入发现页
  await tester.tap(find.byKey(const Key('discover_tab')));
  await tester.pumpAndSettle();
  
  // 点击路线
  await tester.tap(find.byKey(Key('trail_$trailId')));
  await tester.pumpAndSettle();
  
  // 开始导航
  await tester.tap(find.text('开始导航'));
  await tester.pumpAndSettle();
  
  // 等待导航页加载
  await waitFor(
    find.byKey(const Key('navigation_screen')),
    timeout: const Duration(seconds: 5),
  );
}

/// 验证埋点事件
Future<void> verifyAnalyticsEvent(String eventName) async {
  // TODO: 实现埋点验证逻辑
  print('验证埋点: $eventName');
}

/// Mock位置更新
Future<void> mockLocationUpdate(LatLng position) async {
  // TODO: 实现位置Mock
  print('Mock位置: $position');
}

/// Mock多个位置更新
Future<void> mockLocationUpdates(List<LatLng> positions) async {
  for (final position in positions) {
    await mockLocationUpdate(position);
    await Future.delayed(const Duration(seconds: 2));
  }
}

/// Mock微信授权
Future<void> mockWeChatAuth({required bool success}) async {
  // TODO: 实现微信Mock
  print('Mock微信授权: $success');
}

/// 设置网络状态
Future<void> setNetworkState({required bool enabled}) async {
  // TODO: 实现网络控制
  print('设置网络: $enabled');
}

/// 网络条件枚举
enum NetworkCondition {
  normal,
  weak,
  offline,
}

/// 设置网络条件
Future<void> setNetworkCondition(NetworkCondition condition) async {
  // TODO: 实现网络条件控制
  print('设置网络条件: $condition');
}

/// 确保离线地图已下载
Future<void> ensureOfflineMapDownloaded(
  WidgetTester tester, {
  required String city,
}) async {
  // TODO: 实现离线地图检查
  print('确保离线地图已下载: $city');
}

/// 进入离线地图页面
Future<void> goToOfflineMapPage(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('profile_tab')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('离线地图'));
  await tester.pumpAndSettle();
}

/// 模拟来电
Future<void> simulateIncomingCall() async {
  // TODO: 实现来电模拟
  print('模拟来电');
}

/// 模拟挂断
Future<void> simulateCallEnd() async {
  // TODO: 实现挂断模拟
  print('模拟挂断');
}

/// 截屏保存
Future<void> takeScreenshot(
  WidgetTester tester,
  String name, {
  String? directory,
}) async {
  final bytes = await tester.binding.takeScreenshot(name);
  // TODO: 保存截图
  print('截图: $name');
}
```

---

## 3. CI/CD集成

### 3.1 GitHub Actions 工作流

```yaml
# .github/workflows/e2e_test.yml

name: E2E Tests

on:
  push:
    branches: [main, develop]
    paths:
      - 'lib/**'
      - 'qa/**'
      - 'pubspec.yaml'
  pull_request:
    branches: [main, develop]
  schedule:
    # 每天凌晨2点运行
    - cron: '0 18 * * *'
  workflow_dispatch:
    inputs:
      test_type:
        description: '测试类型'
        required: true
        default: 'all'
        type: choice
        options:
          - all
          - smoke
          - e2e
          - compatibility

jobs:
  # 代码检查
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze
        run: flutter analyze
      
      - name: Format check
        run: dart format --set-exit-if-changed lib/

  # 单元测试
  unit_test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test --coverage test/
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info

  # E2E测试 - Android
  e2e_android:
    runs-on: macos-latest
    needs: unit_test
    timeout-minutes: 45
    strategy:
      matrix:
        api-level: [29, 33, 34]
        target: [default, google_apis]
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --debug
      
      - name: Build test APK
        run: flutter build apk --debug \
          -t qa/m4/p2_testing/automation/e2e/flows/all_flows_test.dart
      
      - name: Run E2E tests on emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: ${{ matrix.api-level }}
          target: ${{ matrix.target }}
          arch: x86_64
          script: |
            flutter test qa/m4/p2_testing/automation/e2e/ \
              --device-id emulator-5554 \
              --reporter expanded
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: e2e-android-results-${{ matrix.api-level }}
          path: test-results/

  # E2E测试 - iOS
  e2e_ios:
    runs-on: macos-latest
    needs: unit_test
    timeout-minutes: 45
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable
      
      - name: Install dependencies
        run: flutter pub get
        
      - name: Install pods
        run: |
          cd ios
          pod install
      
      - name: Build iOS app
        run: flutter build ios --simulator
      
      - name: Run E2E tests
        run: |
          flutter test qa/m4/p2_testing/automation/e2e/ \
            --reporter expanded
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: e2e-ios-results
          path: test-results/

  # 烟雾测试 - 快速验证
  smoke_test:
    runs-on: macos-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run smoke tests
        run: |
          flutter test qa/m4/p2_testing/automation/e2e/regressions/smoke_test.dart \
            --reporter expanded

  # 性能测试
  performance_test:
    runs-on: macos-latest
    needs: smoke_test
    if: github.event_name == 'schedule' || github.event.inputs.test_type == 'e2e'
    timeout-minutes: 90
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run performance tests
        run: |
          flutter test qa/m4/p2_testing/performance/ \
            --reporter json > performance_results.json
      
      - name: Upload performance results
        uses: actions/upload-artifact@v4
        with:
          name: performance-results
          path: performance_results.json

  # 兼容性测试
  compatibility_test:
    runs-on: ubuntu-latest
    needs: smoke_test
    if: github.event_name == 'schedule' || github.event.inputs.test_type == 'compatibility'
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload to Firebase Test Lab
        uses: asadmansr/Firebase-Test-Lab-Action@v1.0
        with:
          arg-spec: 'firebase_test_lab.yaml:android'
        env:
          SERVICE_ACCOUNT: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}

  # 生成测试报告
  test_report:
    runs-on: ubuntu-latest
    needs: [e2e_android, e2e_ios, smoke_test]
    if: always()
    steps:
      - uses: actions/checkout@v4
      
      - name: Download all artifacts
        uses: actions/download-artifact@v4
        with:
          path: test-results
      
      - name: Generate test report
        run: |
          python3 scripts/generate_test_report.py \
            --input test-results \
            --output test-report.md
      
      - name: Upload test report
        uses: actions/upload-artifact@v4
        with:
          name: test-report
          path: test-report.md
      
      - name: Comment on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('test-report.md', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });
```

### 3.2 测试脚本

```bash
#!/bin/bash
# qa/m4/p2_testing/automation/scripts/run_e2e.sh

set -e

# 配置
TEST_DIR="qa/m4/p2_testing/automation/e2e"
DEVICE_ID=""
REPORTER="expanded"

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --device-id)
      DEVICE_ID="$2"
      shift 2
      ;;
    --reporter)
      REPORTER="$2"
      shift 2
      ;;
    --flow)
      FLOW="$2"
      shift 2
      ;;
    *)
      echo "未知参数: $1"
      exit 1
      ;;
  esac
done

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
  echo "错误: 未找到Flutter"
  exit 1
fi

# 获取依赖
echo "正在获取依赖..."
flutter pub get

# 构建测试
echo "正在构建测试..."
if [ -n "$DEVICE_ID" ]; then
  BUILD_ARGS="--device-id $DEVICE_ID"
else
  BUILD_ARGS=""
fi

# 运行测试
echo "正在运行E2E测试..."
if [ -n "$FLOW" ]; then
  # 运行指定流程
  flutter test "$TEST_DIR/flows/${FLOW}_flow_test.dart" \
    --reporter "$REPORTER" \
    $BUILD_ARGS
else
  # 运行全部E2E测试
  flutter test "$TEST_DIR/" \
    --reporter "$REPORTER" \
    $BUILD_ARGS
fi

echo "E2E测试完成"
```

```bash
#!/bin/bash
# qa/m4/p2_testing/automation/scripts/run_smoke.sh

set -e

echo "运行烟雾测试..."

flutter test qa/m4/p2_testing/automation/e2e/regressions/smoke_test.dart \
  --reporter expanded

echo "烟雾测试完成"
```

---

## 4. 测试报告

### 4.1 报告格式

```markdown
# E2E测试报告

## 执行摘要

| 指标 | 数值 |
|------|------|
| 测试用例总数 | XX |
| 通过 | XX |
| 失败 | XX |
| 跳过 | XX |
| 通过率 | XX% |
| 执行时间 | XX分钟 |

## 详细结果

### 用户认证流程
| 用例 | 状态 | 耗时 |
|------|------|------|
| 完整登录流程 | ✅ | 15s |
| 微信登录流程 | ✅ | 12s |
| 退出登录流程 | ✅ | 8s |

### 导航流程
| 用例 | 状态 | 耗时 |
|------|------|------|
| 完整导航流程 | ✅ | 45s |
| 偏航重规划 | ✅ | 32s |
| 导航中接打电话 | ✅ | 28s |

...（更多模块）

## 失败用例分析

### 失败用例1: XXX
- 错误信息: 
- 复现步骤: 
- 建议修复: 

## 性能指标

| 指标 | 目标 | 实际 |
|------|------|------|
| 平均用例执行时间 | <30s | XXs |
| 内存占用峰值 | <300MB | XXMB |
| CPU使用率 | <50% | XX% |
```

### 4.2 报告生成脚本

```python
# scripts/generate_test_report.py

import json
import sys
import os
from datetime import datetime

def parse_test_results(results_dir):
    """解析测试结果"""
    results = {
        'total': 0,
        'passed': 0,
        'failed': 0,
        'skipped': 0,
        'duration': 0,
        'suites': []
    }
    
    # 遍历结果文件
    for root, dirs, files in os.walk(results_dir):
        for file in files:
            if file.endswith('.json'):
                with open(os.path.join(root, file)) as f:
                    data = json.load(f)
                    # 解析测试结果...
                    
    return results

def generate_markdown_report(results):
    """生成Markdown报告"""
    report = f"""# E2E测试报告

## 执行摘要

| 指标 | 数值 |
|------|------|
| 测试用例总数 | {results['total']} |
| 通过 | {results['passed']} |
| 失败 | {results['failed']} |
| 跳过 | {results['skipped']} |
| 通过率 | {results['passed'] / results['total'] * 100:.1f}% |
| 执行时间 | {results['duration'] // 60}分钟 |

生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""
    return report

def main():
    if len(sys.argv) < 4:
        print("用法: python generate_test_report.py --input <dir> --output <file>")
        sys.exit(1)
    
    input_dir = sys.argv[2]
    output_file = sys.argv[4]
    
    results = parse_test_results(input_dir)
    report = generate_markdown_report(results)
    
    with open(output_file, 'w') as f:
        f.write(report)
    
    print(f"报告已生成: {output_file}")

if __name__ == '__main__':
    main()
```

---

## 5. 测试配置

### 5.1 测试数据配置

```yaml
# qa/m4/p2_testing/automation/config/test_config.yaml

test_data:
  users:
    - phone: "13800138000"
      code: "123456"
      nickname: "测试用户1"
    - phone: "13800138001"
      code: "123456"
      nickname: "测试用户2"
  
  trails:
    - id: "R001"
      name: "九溪烟树线"
      city: "杭州"
    - id: "R002"
      name: "龙井村线"
      city: "杭州"
    - id: "R009"
      name: "西湖环湖线"
      city: "杭州"
  
  locations:
    - name: "断桥残雪"
      lat: 30.2596
      lng: 120.1479
    - name: "白堤"
      lat: 30.2588
      lng: 120.1432
    - name: "苏堤春晓"
      lat: 30.2315
      lng: 120.1289

timeouts:
  default: 30
  navigation: 120
  offline_download: 180
  sos: 10

mock_services:
  wechat:
    enabled: true
    auto_auth: true
  
  location:
    enabled: true
    mock_provider: true
  
  network:
    enabled: true
    can_simulate_weak: true

screenshots:
  enabled: true
  on_failure: true
  on_success: false
  directory: "test-results/screenshots"
```

---

## 6. 测试执行计划

| 阶段 | 频率 | 触发条件 | 覆盖范围 | 预计耗时 |
|------|------|----------|----------|----------|
| 烟雾测试 | 每次提交 | push/PR | 核心流程 | 5分钟 |
| 单元测试 | 每次提交 | push/PR | 全量单元测试 | 3分钟 |
| E2E测试(Android) | 每次PR | PR to main | 主要流程 | 30分钟 |
| E2E测试(iOS) | 每次PR | PR to main | 主要流程 | 30分钟 |
| 全量E2E | 每天 | 定时触发 | 全量场景 | 60分钟 |
| 性能测试 | 每天 | 定时触发 | 性能基准 | 90分钟 |
| 兼容性测试 | 每周 | 定时触发 | 多设备 | 120分钟 |

---

## 7. 交付物清单

| 交付物 | 路径 | 说明 |
|--------|------|------|
| E2E测试脚本 | qa/m4/p2_testing/automation/e2e/ | 完整E2E测试 |
| CI/CD配置 | .github/workflows/e2e_test.yml | GitHub Actions |
| 测试工具类 | qa/m4/p2_testing/automation/e2e/utils/ | 测试辅助 |
| 测试脚本 | qa/m4/p2_testing/automation/scripts/ | 运行脚本 |
| 配置文件 | qa/m4/p2_testing/automation/config/ | 测试配置 |

---

> **文档编写**: QA Agent  
> **评审待办**: Dev Agent（确认CI/CD配置）
