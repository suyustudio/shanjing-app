# 山径APP - M4 P2 性能基准深度测试

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **测试周期**: 60分钟深度测试  
> **测试类型**: 性能基准测试

---

## 1. 测试概述

### 1.1 测试目标

通过深度性能测试验证山径APP在长时间使用场景下的稳定性和资源管理能力，确保产品满足内测标准。

| 目标维度 | 具体目标 | 成功标准 |
|---------|---------|---------|
| **长时间稳定性** | 60分钟连续导航无异常 | 无崩溃、无ANR、定位不丢失 |
| **资源管理** | 内存、CPU、电量消耗可控 | 内存增长<100MB，电量消耗<15%/h |
| **多任务切换** | 多路线切换性能稳定 | 切换时间<3s，无内存泄漏 |
| **后台保活** | 后台导航可持续运行 | 15分钟内定位不丢失 |

### 1.2 测试范围

| 测试项 | 测试时长 | 测试场景 |
|--------|----------|----------|
| 长时间导航稳定性 | 60分钟 | 持续导航模式 |
| 多路线切换性能 | 20分钟 | 10次路线切换 |
| 后台保活测试 | 30分钟 | 前后台切换 |

---

## 2. 测试环境

### 2.1 设备要求

| 设备类型 | 最低配置 | 推荐配置 |
|----------|----------|----------|
| Android | 6GB RAM, Android 10+ | 8GB RAM, Android 13 |
| iOS | iPhone 11, iOS 15+ | iPhone 14, iOS 17 |

### 2.2 测试版本

| 属性 | 要求 |
|------|------|
| 版本号 | v1.0.0+build140 或更新 |
| 构建来源 | GitHub Actions Release Build |
| 配置要求 | Release模式，日志级别Error |

### 2.3 监控工具

| 工具 | 用途 | 配置 |
|------|------|------|
| Flutter DevTools | 性能监控 | 连接设备后启动 |
| Android Profiler | 内存/CPU监控 | Android Studio内置 |
| Xcode Instruments | iOS性能监控 | Energy Log, Memory Graph |
| Firebase Performance | 线上性能监控 | 已集成 |

---

## 3. 长时间导航稳定性测试（60分钟）

### 3.1 测试场景

**场景设计**: 模拟真实徒步场景，60分钟持续导航

```
测试路线: 西湖环湖线（延长版）
路线长度: 约15公里（多圈叠加）
模拟速度: 4-6 km/h（步行速度）
测试时长: 60分钟
```

### 3.2 测试步骤

| 阶段 | 时间 | 操作 | 检查项 |
|------|------|------|--------|
| 准备阶段 | 0-5min | 启动APP，进入导航页 | GPS定位成功，语音播报正常 |
| 稳定阶段 | 5-20min | 正常导航 | 轨迹跟随准确，内存稳定 |
| 压力阶段 | 20-40min | 加入模拟操作 | 切后台、接电话、看通知 |
| 疲劳阶段 | 40-60min | 持续导航 | 观察内存泄漏、定位漂移 |

### 3.3 数据采集点

| 采集时间 | 采集内容 | 目标值 |
|----------|----------|--------|
| 0min | 初始内存、CPU、电量 | 基线数据 |
| 10min | 内存占用、定位精度 | 内存<180MB |
| 20min | 内存占用、定位精度 | 内存<200MB |
| 30min | 内存占用、CPU使用率 | 内存<220MB |
| 40min | 内存占用、后台表现 | 内存<240MB |
| 50min | 内存占用、定位精度 | 内存<260MB |
| 60min | 最终内存、CPU、电量 | 内存<280MB |

### 3.4 通过标准

| 指标 | 目标值 | 通过标准 |
|------|--------|----------|
| 崩溃次数 | 0次 | 必须 |
| ANR次数 | 0次 | 必须 |
| 定位丢失次数 | 0次 | 必须 |
| 内存增长 | <100MB | 建议 |
| 电量消耗 | <15%/h | 建议 |
| 平均CPU | <30% | 建议 |

---

## 4. 多路线切换性能测试

### 4.1 测试场景

**场景设计**: 模拟用户在多条路线间切换的场景

```
测试路线列表:
1. 九溪烟树线 (R001)
2. 龙井村线 (R002)
3. 宝石山线 (R003)
4. 云栖竹径 (R004)
5. 满觉陇线 (R005)
6. 玉皇山线 (R006)
7. 灵隐寺线 (R007)
8. 法喜寺线 (R008)
9. 西湖环湖 (R009)
10. 断桥残雪 (R010)
```

### 4.2 测试步骤

| 轮次 | 操作 | 预期结果 | 性能要求 |
|------|------|----------|----------|
| 1 | 路线1→进入导航→退出→路线2 | 正常切换 | 切换<3s |
| 2 | 路线2→进入导航→退出→路线3 | 正常切换 | 切换<3s |
| 3 | 路线3→进入导航→退出→路线4 | 正常切换 | 切换<3s |
| ... | 依此类推 | ... | ... |
| 10 | 路线10→进入导航→退出 | 正常退出 | 切换<3s |

### 4.3 性能指标

| 指标 | 目标值 | 测量方法 |
|------|--------|----------|
| 路线列表加载时间 | <1.5s | 从点击到列表显示 |
| 路线详情页加载 | <2s | 从点击到详情显示 |
| 导航页启动时间 | <2s | 从点击到导航开始 |
| 退出导航时间 | <1s | 从点击到完全退出 |
| 内存释放率 | >80% | 退出后内存回收比例 |

### 4.4 内存泄漏检测

```dart
// 内存检测代码示例
class RouteSwitchMemoryTest {
  final List<int> memorySnapshots = [];
  
  Future<void> captureMemory() async {
    final info = await DevToolsService.getMemoryInfo();
    memorySnapshots.add(info.heapTotal);
  }
  
  bool detectMemoryLeak() {
    // 线性回归检测内存泄漏趋势
    final trend = calculateLinearTrend(memorySnapshots);
    return trend > 5; // 每次切换增长>5MB视为泄漏
  }
}
```

---

## 5. 后台保活测试

### 5.1 测试场景

**场景设计**: 验证APP在后台运行时的定位保活能力

### 5.2 Android后台保活测试

| 测试项 | 测试步骤 | 预期结果 | 通过标准 |
|--------|----------|----------|----------|
| 基础保活 | 进入导航→按Home键→5分钟后返回 | 定位连续性正常 | 轨迹无断点 |
| 长时保活 | 进入导航→按Home键→15分钟后返回 | 定位连续性正常 | 轨迹无断点 |
| 锁屏保活 | 进入导航→锁屏→10分钟后解锁 | 定位连续性正常 | 轨迹无断点 |
| 多任务切换 | 导航→打开相机→返回导航→打开微信→返回 | 定位连续性正常 | 轨迹无断点 |
| 内存压力 | 导航→打开大型游戏→返回导航 | APP未被杀死 | 正常恢复 |

### 5.3 iOS后台保活测试

| 测试项 | 测试步骤 | 预期结果 | 通过标准 |
|--------|----------|----------|----------|
| 基础保活 | 进入导航→切换APP→5分钟后返回 | 定位连续性正常 | 轨迹无断点 |
| 长时保活 | 进入导航→切换APP→15分钟后返回 | 定位连续性正常 | 轨迹无断点 |
| 系统限制 | 导航→打开相机→录像5分钟→返回 | 定位连续性正常 | 轨迹无断点 |
| 后台刷新 | 关闭后台刷新→导航→切换APP→5分钟 | 提示用户开启 | 友好提示 |

### 5.4 后台定位精度测试

| 场景 | 前台精度 | 后台精度 | 可接受范围 |
|------|----------|----------|------------|
| 静止 | 5m | 10m | <20m |
| 步行 | 5m | 8m | <15m |
| 信号良好 | 5m | 6m | <10m |
| 信号弱 | 10m | 15m | <30m |

---

## 6. 自动化测试脚本

### 6.1 长时间导航测试脚本

```dart
// qa/m4/p2_testing/performance/long_navigation_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('长时间导航稳定性测试', () {
    testWidgets('60分钟连续导航测试', (tester) async {
      // 启动APP
      app.main();
      await tester.pumpAndSettle();
      
      // 进入导航
      await tester.tap(find.text('开始导航'));
      await tester.pumpAndSettle();
      
      // 60分钟持续测试
      final stopwatch = Stopwatch()..start();
      final memorySnapshots = <int>[];
      
      while (stopwatch.elapsed.inMinutes < 60) {
        // 每10分钟采集一次数据
        if (stopwatch.elapsed.inSeconds % 600 == 0) {
          final memory = await getMemoryUsage();
          memorySnapshots.add(memory);
          
          // 验证定位状态
          expect(isLocationActive(), true, 
            reason: '导航${stopwatch.elapsed.inMinutes}分钟后定位丢失');
        }
        
        await tester.pump(const Duration(seconds: 1));
      }
      
      // 验证内存增长
      final memoryGrowth = memorySnapshots.last - memorySnapshots.first;
      expect(memoryGrowth, lessThan(100 * 1024 * 1024), // 100MB
        reason: '内存增长超过100MB: ${memoryGrowth ~/ 1024 ~/ 1024}MB');
    }, timeout: const Timeout(Duration(minutes: 65)));
  });
}
```

### 6.2 多路线切换测试脚本

```dart
// qa/m4/p2_testing/performance/route_switch_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('多路线切换性能测试', () {
    testWidgets('10次路线切换测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final routeIds = ['R001', 'R002', 'R003', 'R004', 'R005', 
                       'R006', 'R007', 'R008', 'R009', 'R010'];
      final memorySnapshots = <int>[];
      final switchTimes = <int>[];
      
      for (final routeId in routeIds) {
        final stopwatch = Stopwatch()..start();
        
        // 进入路线详情
        await tester.tap(find.byKey(Key('route_$routeId')));
        await tester.pumpAndSettle();
        
        // 开始导航
        await tester.tap(find.text('开始导航'));
        await tester.pumpAndSettle();
        
        // 等待3秒后退出
        await Future.delayed(const Duration(seconds: 3));
        await tester.tap(find.byKey(const Key('exit_navigation')));
        await tester.pumpAndSettle();
        
        // 返回路线列表
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        switchTimes.add(stopwatch.elapsedMilliseconds);
        
        // 采集内存
        final memory = await getMemoryUsage();
        memorySnapshots.add(memory);
      }
      
      // 验证切换时间
      final avgSwitchTime = switchTimes.reduce((a, b) => a + b) / switchTimes.length;
      expect(avgSwitchTime, lessThan(3000), 
        reason: '平均切换时间超过3秒: ${avgSwitchTime}ms');
      
      // 验证内存泄漏
      final leakDetected = detectMemoryLeak(memorySnapshots);
      expect(leakDetected, false, reason: '检测到内存泄漏');
    });
  });
}
```

### 6.3 后台保活测试脚本

```dart
// qa/m4/p2_testing/performance/background_keepalive_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('后台保活测试', () {
    testWidgets('15分钟后台保活测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await tester.tap(find.text('开始导航'));
      await tester.pumpAndSettle();
      
      // 记录初始位置
      final initialPosition = await getCurrentPosition();
      
      // 切换到后台
      await sendAppToBackground();
      
      // 等待15分钟
      await Future.delayed(const Duration(minutes: 15));
      
      // 返回前台
      await bringAppToForeground();
      await tester.pumpAndSettle();
      
      // 获取轨迹数据
      final trackPoints = await getTrackPoints();
      
      // 验证轨迹连续性
      expect(trackPoints.isNotEmpty, true, 
        reason: '后台期间无轨迹数据');
      
      // 验证无大段断点（>30秒无数据）
      final gaps = findTrackGaps(trackPoints, thresholdSeconds: 30);
      expect(gaps.isEmpty, true, 
        reason: '检测到轨迹断点: $gaps');
    }, timeout: const Timeout(Duration(minutes: 20)));
  });
}
```

---

## 7. 数据记录表格

### 7.1 长时间导航测试记录表

| 时间 | 内存(MB) | CPU(%) | 电量(%) | 定位精度(m) | 状态 | 备注 |
|------|----------|--------|---------|-------------|------|------|
| 0min | | | | | | |
| 10min | | | | | | |
| 20min | | | | | | |
| 30min | | | | | | |
| 40min | | | | | | |
| 50min | | | | | | |
| 60min | | | | | | |

### 7.2 多路线切换测试记录表

| 轮次 | 路线ID | 切换耗时(ms) | 内存(MB) | 内存增长(MB) | 状态 |
|------|--------|--------------|----------|--------------|------|
| 1 | R001 | | | | |
| 2 | R002 | | | | |
| ... | ... | | | | |
| 10 | R010 | | | | |

### 7.3 后台保活测试记录表

| 测试项 | 后台时长 | 轨迹点数 | 断点数 | 最大断点时长 | 状态 |
|--------|----------|----------|--------|--------------|------|
| 基础保活(Android) | 5min | | | | |
| 长时保活(Android) | 15min | | | | |
| 锁屏保活(Android) | 10min | | | | |
| 基础保活(iOS) | 5min | | | | |
| 长时保活(iOS) | 15min | | | | |

---

## 8. 问题反馈与修复

### 8.1 问题分级

| 级别 | 定义 | 处理时限 |
|------|------|----------|
| P0 | 崩溃、ANR、定位丢失 | 立即修复 |
| P1 | 内存泄漏>50MB、电量异常消耗 | 24小时内 |
| P2 | 性能下降<20% | 下个版本 |

### 8.2 问题报告模板

```markdown
## 性能问题报告

### 基本信息
- 测试项目: [长时间导航/多路线切换/后台保活]
- 发现时间: 
- 设备型号: 
- 系统版本: 
- APP版本: 

### 问题描述
[详细描述问题现象]

### 数据记录
- 内存变化: 
- CPU使用率: 
- 电量消耗: 
- 其他指标: 

### 复现步骤
1. 
2. 
3. 

### 预期结果

### 实际结果

### 建议修复方案
```

---

## 9. 测试交付物

| 交付物 | 格式 | 负责人 | 截止时间 |
|--------|------|--------|----------|
| 性能测试报告 | Markdown | QA | 测试后2天 |
| 性能测试数据 | CSV/Excel | QA | 测试后1天 |
| 问题清单 | Markdown | QA | 测试后1天 |
| 优化建议 | Markdown | QA | 测试后2天 |

---

## 10. 附录

### 10.1 相关文档

| 文档 | 路径 |
|------|------|
| M4 功能规划 | M4-FEATURE-PLAN.md |
| 性能基准 | qa/m4/performance/ |
| 验收检查清单 | M4-ACCEPTANCE-CHECKLIST.md |

### 10.2 测试命令

```bash
# 运行长时间导航测试
flutter test qa/m4/p2_testing/performance/long_navigation_test.dart

# 运行多路线切换测试
flutter test qa/m4/p2_testing/performance/route_switch_test.dart

# 运行后台保活测试
flutter test qa/m4/p2_testing/performance/background_keepalive_test.dart

# 运行全部性能测试
flutter test qa/m4/p2_testing/performance/
```

---

> **文档编写**: QA Agent  
> **评审待办**: Dev Agent（确认测试脚本可行性）
