# MEMORY_BENCHMARK - 内存占用测试标准

> **文档版本**: v1.0  > **制定日期**: 2026-03-19  > **优先级**: P1

---

## 测试目标

建立 App 内存占用的性能基准，防止 OOM 崩溃和性能下降。

## 测试指标

### 场景基准

| 场景 | 描述 | 目标值 | 警告阈值 | 失败阈值 |
|------|------|--------|----------|----------|
| **首页空闲** | 首页静置 1 分钟 | < 80MB | 80-120MB | > 120MB |
| **路线详情** | 打开路线详情页 | < 120MB | 120-180MB | > 180MB |
| **导航中** | 正常导航状态 | < 150MB | 150-220MB | > 220MB |
| **分享卡片生成** | 生成高清分享图 | < 200MB | 200-300MB | > 300MB |
| **后台运行** | 进入后台 5 分钟 | < 50MB | 50-80MB | > 80MB |

### 内存泄漏检查

| 检查项 | 方法 | 通过标准 |
|--------|------|----------|
| 页面返回 | 反复进出路线详情 10 次 | 内存增长 < 10MB |
| 图片加载 | 浏览 20 张图片后返回 | 内存恢复至基线 |
| 导航长时 | 导航 30 分钟 | 内存增长 < 20MB |

## 测试环境

| 项目 | 配置 |
|------|------|
| 测试设备 | Android 中端机 |
| 内存 | 8GB (监控 4GB 设备兼容性) |
| 监控工具 | Android Studio Profiler / dumpsys |

## 测试方法

### 1. 使用 adb dumpsys

```bash
# 获取内存信息
adb shell dumpsys meminfo com.shanjing.app

# 关键指标
# - PSS (Proportional Set Size): 实际占用内存
# - Heap: Dart/Native 堆内存

# 持续监控脚本
while true; do
    adb shell dumpsys meminfo com.shanjing.app | grep "TOTAL PSS"
    sleep 5
done
```

### 2. Flutter DevTools

```bash
# 启动 DevTools
flutter pub global activate devtools
flutter pub global run devtools

# 运行应用并连接
flutter run --profile
```

### 3. 代码内监控

```dart
// lib/utils/memory_monitor.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class MemoryMonitor {
  static DateTime? _startTime;
  static final List<MemorySnapshot> _snapshots = [];
  
  static void startMonitoring() {
    _startTime = DateTime.now();
    _takeSnapshot('start');
    
    // 每 30 秒记录一次
    Timer.periodic(Duration(seconds: 30), (_) {
      _takeSnapshot('periodic');
    });
  }
  
  static void _takeSnapshot(String tag) {
    final info = _getMemoryInfo();
    _snapshots.add(MemorySnapshot(
      timestamp: DateTime.now(),
      tag: tag,
      rss: info['rss'],
      pss: info['pss'],
      heap: info['heap'],
    ));
  }
  
  static Map<String, int> _getMemoryInfo() {
    // 读取 /proc/self/status
    final status = File('/proc/self/status').readAsStringSync();
    final vmRss = _parseValue(status, 'VmRSS:');
    
    return {
      'rss': vmRss,
      'pss': 0, // 需要 dumpsys
      'heap': 0, // 需要 native 代码
    };
  }
  
  static void mark(String scene) {
    _takeSnapshot(scene);
  }
  
  static MemoryReport generateReport() {
    return MemoryReport(
      duration: DateTime.now().difference(_startTime!),
      snapshots: _snapshots,
      peakMemory: _snapshots.map((s) => s.rss).reduce(max),
      avgMemory: _snapshots.map((s) => s.rss).reduce((a, b) => a + b) ~/ _snapshots.length,
    );
  }
}

class MemorySnapshot {
  final DateTime timestamp;
  final String tag;
  final int rss;
  final int pss;
  final int heap;
  
  MemorySnapshot({
    required this.timestamp,
    required this.tag,
    required this.rss,
    required this.pss,
    required this.heap,
  });
}
```

## 测试步骤

### 场景 1: 首页空闲内存

```bash
1. 冷启动 App
2. 等待首页加载完成
3. 静置 1 分钟
4. 记录 PSS 内存值
5. 重复 3 次取平均
```

### 场景 2: 导航内存测试

```bash
1. 开始导航
2. 每 5 分钟记录一次内存
3. 持续 30 分钟
4. 检查内存增长趋势
5. 结束导航，检查内存释放
```

### 场景 3: 内存泄漏检测

```bash
1. 记录基线内存
2. 进入路线详情 -> 返回 (重复 10 次)
3. GC 后记录内存
4. 计算内存增长
5. 增长 > 10MB 则判定泄漏
```

## 自动化脚本

```python
#!/usr/bin/env python3
# qa/m4/automation/memory_benchmark.py

import subprocess
import time
import re
import json
from dataclasses import dataclass
from typing import List

@dataclass
class MemoryReading:
    timestamp: float
    pss: int  # KB
    private_dirty: int  # KB
    heap: int  # KB

class MemoryBenchmark:
    def __init__(self, package="com.shanjing.app"):
        self.package = package
        self.readings: List[MemoryReading] = []
    
    def get_memory_info(self) -> MemoryReading:
        """获取内存信息"""
        result = subprocess.run(
            ["adb", "shell", "dumpsys", "meminfo", self.package],
            capture_output=True, text=True
        )
        
        output = result.stdout
        
        # 解析 TOTAL PSS
        pss_match = re.search(r'TOTAL PSS:\s+([\d,]+)K', output)
        pss = int(pss_match.group(1).replace(',', '')) if pss_match else 0
        
        # 解析 Private Dirty
        private_match = re.search(r'TOTAL PRIVATE DIRTY:\s+([\d,]+)K', output)
        private_dirty = int(private_match.group(1).replace(',', '')) if private_match else 0
        
        # 解析 Heap
        heap_match = re.search(r'Native Heap\s+\d+\s+\d+\s+([\d,]+)', output)
        heap = int(heap_match.group(1).replace(',', '')) if heap_match else 0
        
        return MemoryReading(
            timestamp=time.time(),
            pss=pss,
            private_dirty=private_dirty,
            heap=heap
        )
    
    def monitor_scenario(self, scenario_name: str, duration: int = 60):
        """监控特定场景"""
        print(f"\n🔍 监控场景: {scenario_name}")
        print(f"持续时间: {duration} 秒\n")
        
        self.readings = []
        start_time = time.time()
        
        while time.time() - start_time < duration:
            reading = self.get_memory_info()
            self.readings.append(reading)
            
            pss_mb = reading.pss / 1024
            print(f"  PSS: {pss_mb:.1f} MB")
            
            time.sleep(5)
        
        # 生成报告
        return self._generate_scenario_report(scenario_name)
    
    def _generate_scenario_report(self, scenario_name: str) -> dict:
        """生成场景报告"""
        pss_values = [r.pss for r in self.readings]
        
        avg_pss = sum(pss_values) / len(pss_values)
        max_pss = max(pss_values)
        min_pss = min(pss_values)
        
        # 判断状态
        thresholds = {
            "首页空闲": 80 * 1024,
            "路线详情": 120 * 1024,
            "导航中": 150 * 1024,
            "分享卡片生成": 200 * 1024,
        }
        
        threshold = thresholds.get(scenario_name, 150 * 1024)
        avg_mb = avg_pss / 1024
        
        if avg_mb < threshold / 1024:
            status = "✅ PASS"
        elif avg_mb < threshold / 1024 * 1.5:
            status = "⚠️  WARN"
        else:
            status = "❌ FAIL"
        
        return {
            "scenario": scenario_name,
            "avg_pss_mb": round(avg_mb, 1),
            "max_pss_mb": round(max_pss / 1024, 1),
            "min_pss_mb": round(min_pss / 1024, 1),
            "readings_count": len(self.readings),
            "status": status
        }
    
    def run_all_scenarios(self):
        """运行所有场景测试"""
        print("🧪 内存占用测试开始")
        print("=" * 50)
        
        scenarios = [
            ("首页空闲", 60),
            ("路线详情", 60),
            ("导航中", 300),  # 5 分钟
        ]
        
        results = []
        for scenario, duration in scenarios:
            input(f"\n请手动进入 '{scenario}' 场景，按回车开始测试...")
            report = self.monitor_scenario(scenario, duration)
            results.append(report)
        
        # 总报告
        print("\n" + "=" * 50)
        print("📊 内存测试报告")
        print("=" * 50)
        
        for r in results:
            print(f"\n{r['scenario']}:")
            print(f"  平均内存: {r['avg_pss_mb']} MB {r['status']}")
            print(f"  峰值内存: {r['max_pss_mb']} MB")
        
        return results

if __name__ == "__main__":
    benchmark = MemoryBenchmark()
    results = benchmark.run_all_scenarios()
    
    # 保存报告
    with open("memory_report.json", "w") as f:
        json.dump(results, f, indent=2)
    print("\n📄 报告已保存至 memory_report.json")
```

## 报告模板

```markdown
## 内存占用测试报告 - Build #XXX

| 场景 | 目标 | 平均 | 峰值 | 状态 |
|------|------|------|------|------|
| 首页空闲 | < 80MB | 75MB | 82MB | ✅ PASS |
| 路线详情 | < 120MB | 115MB | 128MB | ✅ PASS |
| 导航中 | < 150MB | 142MB | 155MB | ⚠️  WARN |

### 内存泄漏检测
- 页面返回测试: 内存增长 5MB ✅
- 图片加载测试: 内存恢复正常 ✅
- 导航长时测试: 内存增长 15MB ✅

### 优化建议
导航中内存接近阈值，建议检查地图渲染优化。

## 版本记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | 初版完成 |
