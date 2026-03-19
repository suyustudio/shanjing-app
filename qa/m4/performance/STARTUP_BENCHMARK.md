# STARTUP_BENCHMARK - 启动时间测试标准

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **优先级**: P1

---

## 测试目标

建立 App 启动时间的性能基准，确保用户体验流畅。

## 测试指标

| 指标 | 定义 | 目标值 | 警告阈值 | 失败阈值 |
|------|------|--------|----------|----------|
| **冷启动时间** | 从点击图标到首页可交互 | < 3s | 3-5s | > 5s |
| **热启动时间** | 从后台恢复到首页可交互 | < 1s | 1-2s | > 2s |
| **首屏渲染时间** | 从启动到首屏内容显示 | < 2s | 2-3s | > 3s |
| **TTI (可交互时间)** | 从启动到用户可交互 | < 3.5s | 3.5-5s | > 5s |

## 测试环境

| 项目 | 配置 |
|------|------|
| 测试设备 | Android 中端机 (如小米 12 / OPPO Reno) |
| Android 版本 | 12/13 |
| 内存 | 8GB |
| 存储 | 剩余空间 > 5GB |
| 网络 | WiFi |
| 电量 | > 50% |

## 测试方法

### 1. 手动测试

```bash
# 使用 adb 测量启动时间

# 冷启动 - 强制停止后启动
adb shell am force-stop com.shanjing.app
adb shell am start -W -n com.shanjing.app/.MainActivity

# 输出中的 ThisTime / TotalTime 即为启动时间
```

### 2. 自动化测试

```dart
// Flutter 集成测试示例
test('冷启动时间测试', () async {
  final stopwatch = Stopwatch()..start();
  
  await tester.pumpWidget(ShanjingApp());
  await tester.pumpAndSettle();
  
  stopwatch.stop();
  final startupTime = stopwatch.elapsedMilliseconds;
  
  expect(startupTime, lessThan(3000), 
    reason: '冷启动时间应小于 3 秒');
});
```

### 3. 性能监控代码

```dart
// lib/utils/performance.dart
class PerformanceMonitor {
  static final Map<String, DateTime> _timers = {};
  
  static void mark(String name) {
    _timers[name] = DateTime.now();
  }
  
  static int measure(String startMark, String endMark) {
    final start = _timers[startMark];
    final end = _timers[endMark];
    if (start != null && end != null) {
      return end.difference(start).inMilliseconds;
    }
    return -1;
  }
  
  static void reportStartupMetrics() {
    final coldStart = measure('app_start', 'home_interactive');
    final firstPaint = measure('app_start', 'home_first_paint');
    
    Analytics.track('app_startup', {
      'cold_start_ms': coldStart,
      'first_paint_ms': firstPaint,
      'device_info': DeviceInfo.toMap(),
    });
  }
}

// main.dart
void main() {
  PerformanceMonitor.mark('app_start');
  
  runApp(ShanjingApp(
    onHomeRendered: () {
      PerformanceMonitor.mark('home_first_paint');
    },
    onHomeInteractive: () {
      PerformanceMonitor.mark('home_interactive');
      PerformanceMonitor.reportStartupMetrics();
    },
  ));
}
```

## 测试步骤

### 冷启动测试

1. **准备**: 确保 App 完全关闭（从最近任务中移除）
2. **测试**: 
   - 点击 App 图标
   - 使用 adb 或代码记录时间
   - 重复 10 次取平均值
3. **记录**: 
   ```
   测试 1: 2.8s
   测试 2: 2.9s
   ...
   平均: 2.85s
   ```

### 热启动测试

1. **准备**: App 在后台运行
2. **测试**: 从最近任务中点击 App
3. **记录**: 同冷启动

## 优化建议

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 启动慢 > 3s | 初始化过多 | 延迟初始化非必需组件 |
| 首屏白屏 | 资源加载慢 | 使用骨架屏、图片预加载 |
| TTI 延迟 | 主线程阻塞 | 使用 isolate 处理耗时任务 |

## 监控脚本

```python
# qa/m4/automation/startup_benchmark.py
#!/usr/bin/env python3
import subprocess
import statistics
import json

def measure_startup(package="com.shanjing.app", iterations=10):
    results = []
    
    for i in range(iterations):
        # 冷启动
        subprocess.run(["adb", "shell", "am", "force-stop", package])
        result = subprocess.run(
            ["adb", "shell", "am", "start", "-W", "-n", f"{package}/.MainActivity"],
            capture_output=True, text=True
        )
        
        # 解析时间
        for line in result.stdout.split('\n'):
            if 'TotalTime:' in line:
                time_ms = int(line.split(':')[1].strip())
                results.append(time_ms / 1000)
                break
    
    # 统计
    avg = statistics.mean(results)
    median = statistics.median(results)
    
    report = {
        "iterations": iterations,
        "average_seconds": round(avg, 2),
        "median_seconds": round(median, 2),
        "min_seconds": round(min(results), 2),
        "max_seconds": round(max(results), 2),
        "all_results": [round(r, 2) for r in results],
        "status": "PASS" if avg < 3 else "WARN" if avg < 5 else "FAIL"
    }
    
    return report

if __name__ == "__main__":
    report = measure_startup()
    print(json.dumps(report, indent=2))
```

## 报告模板

```markdown
## 启动时间测试报告 - Build #XXX

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| 冷启动平均 | < 3s | 2.8s | ✅ PASS |
| 热启动平均 | < 1s | 0.8s | ✅ PASS |
| 首屏渲染 | < 2s | 1.9s | ✅ PASS |

### 详细数据
- 测试次数: 10
- 冷启动: min=2.5s, max=3.2s, avg=2.8s
- 热启动: min=0.6s, max=1.1s, avg=0.8s

### 结论
启动性能达标，建议继续保持。
```

## 版本记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | 初版完成 |
