// qa/m4/p2_testing/utils/performance_collector.dart
// 性能数据采集工具 - 用于E2E测试中的性能监控

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

/// 性能数据采集器
/// 用于在长时间测试中采集内存、FPS、电池等性能指标
class PerformanceCollector {
  static const MethodChannel _channel = MethodChannel('shanjing/performance');
  
  /// 采集间隔（默认10秒）
  final Duration interval;
  
  /// 是否正在采集
  bool _isCollecting = false;
  
  /// 采集定时器
  Timer? _timer;
  
  /// 采集的数据点
  final List<PerformanceDataPoint> _dataPoints = [];
  
  /// 数据文件路径
  String? _outputPath;
  
  /// 测试开始时间
  DateTime? _startTime;
  
  /// 电池初始电量
  int? _initialBatteryLevel;
  
  /// 内存初始值
  int? _initialMemory;
  
  /// 回调函数
  final void Function(PerformanceDataPoint)? onDataPoint;
  
  /// 性能阈值配置
  final PerformanceThresholds thresholds;

  PerformanceCollector({
    this.interval = const Duration(seconds: 10),
    this.onDataPoint,
    this.thresholds = const PerformanceThresholds(),
  });

  /// 获取所有采集的数据点
  List<PerformanceDataPoint> get dataPoints => List.unmodifiable(_dataPoints);

  /// 是否正在采集
  bool get isCollecting => _isCollecting;

  /// 开始采集
  Future<void> start({String? outputPath}) async {
    if (_isCollecting) return;
    
    _outputPath = outputPath;
    _startTime = DateTime.now();
    _dataPoints.clear();
    
    // 采集初始数据
    _initialBatteryLevel = await getBatteryLevel();
    _initialMemory = await getMemoryUsageMB();
    
    final initialData = PerformanceDataPoint(
      timestamp: DateTime.now(),
      elapsedSeconds: 0,
      memoryMB: _initialMemory ?? 0,
      batteryPercent: _initialBatteryLevel ?? 100,
      cpuPercent: await getCPUUsage(),
      fps: await getFPS(),
      locationAccuracy: await getLocationAccuracy(),
    );
    
    _dataPoints.add(initialData);
    onDataPoint?.call(initialData);
    
    // 启动定时采集
    _isCollecting = true;
    _timer = Timer.periodic(interval, _collectData);
    
    print('[PerformanceCollector] 开始采集 - 初始内存: ${_initialMemory}MB, 电量: ${_initialBatteryLevel}%');
  }

  /// 停止采集
  Future<void> stop() async {
    if (!_isCollecting) return;
    
    _timer?.cancel();
    _timer = null;
    _isCollecting = false;
    
    // 采集最终数据
    final finalData = await _collectCurrentData();
    _dataPoints.add(finalData);
    
    // 保存数据
    if (_outputPath != null) {
      await saveToFile(_outputPath!);
    }
    
    print('[PerformanceCollector] 停止采集 - 共采集 ${_dataPoints.length} 个数据点');
  }

  /// 采集单次数据
  void _collectData(Timer timer) async {
    if (!_isCollecting) return;
    
    final data = await _collectCurrentData();
    _dataPoints.add(data);
    onDataPoint?.call(data);
    
    // 检查阈值告警
    _checkThresholds(data);
  }

  /// 采集当前数据点
  Future<PerformanceDataPoint> _collectCurrentData() async {
    final now = DateTime.now();
    final elapsed = _startTime != null 
      ? now.difference(_startTime!).inSeconds 
      : 0;
    
    return PerformanceDataPoint(
      timestamp: now,
      elapsedSeconds: elapsed,
      memoryMB: await getMemoryUsageMB(),
      batteryPercent: await getBatteryLevel(),
      cpuPercent: await getCPUUsage(),
      fps: await getFPS(),
      locationAccuracy: await getLocationAccuracy(),
    );
  }

  /// 检查阈值告警
  void _checkThresholds(PerformanceDataPoint data) {
    if (thresholds.maxMemoryMB != null && data.memoryMB > thresholds.maxMemoryMB!) {
      print('[PerformanceCollector] ⚠️ 内存告警: ${data.memoryMB}MB > ${thresholds.maxMemoryMB}MB');
    }
    
    if (thresholds.minBatteryPercent != null && data.batteryPercent < thresholds.minBatteryPercent!) {
      print('[PerformanceCollector] ⚠️ 电量告警: ${data.batteryPercent}% < ${thresholds.minBatteryPercent}%');
    }
    
    if (thresholds.minFPS != null && data.fps != null && data.fps! < thresholds.minFPS!) {
      print('[PerformanceCollector] ⚠️ FPS告警: ${data.fps} < ${thresholds.minFPS}');
    }
    
    if (thresholds.maxLocationAccuracy != null && data.locationAccuracy != null 
        && data.locationAccuracy! > thresholds.maxLocationAccuracy!) {
      print('[PerformanceCollector] ⚠️ 定位精度告警: ${data.locationAccuracy}m > ${thresholds.maxLocationAccuracy}m');
    }
  }

  /// 生成测试报告
  Map<String, dynamic> generateReport() {
    if (_dataPoints.isEmpty) {
      return {'error': '无采集数据'};
    }
    
    final memories = _dataPoints.map((d) => d.memoryMB).toList();
    final batteries = _dataPoints.map((d) => d.batteryPercent).toList();
    final cpus = _dataPoints.where((d) => d.cpuPercent != null).map((d) => d.cpuPercent!).toList();
    final fpss = _dataPoints.where((d) => d.fps != null).map((d) => d.fps!).toList();
    final accuracies = _dataPoints.where((d) => d.locationAccuracy != null).map((d) => d.locationAccuracy!).toList();
    
    final initialMemory = memories.first;
    final finalMemory = memories.last;
    final memoryGrowth = finalMemory - initialMemory;
    
    final initialBattery = batteries.first;
    final finalBattery = batteries.last;
    final batteryConsumption = initialBattery - finalBattery;
    
    final duration = _dataPoints.last.elapsedSeconds;
    final hourlyBatteryConsumption = duration > 0 
      ? batteryConsumption / (duration / 3600) 
      : 0;
    
    return {
      'duration_seconds': duration,
      'data_point_count': _dataPoints.length,
      'memory': {
        'initial_mb': initialMemory,
        'final_mb': finalMemory,
        'growth_mb': memoryGrowth,
        'max_mb': memories.reduce((a, b) => a > b ? a : b),
        'min_mb': memories.reduce((a, b) => a < b ? a : b),
        'avg_mb': memories.reduce((a, b) => a + b) / memories.length,
      },
      'battery': {
        'initial_percent': initialBattery,
        'final_percent': finalBattery,
        'consumption_percent': batteryConsumption,
        'hourly_consumption_percent': hourlyBatteryConsumption.toStringAsFixed(2),
      },
      'cpu': cpus.isNotEmpty ? {
        'avg_percent': cpus.reduce((a, b) => a + b) / cpus.length,
        'max_percent': cpus.reduce((a, b) => a > b ? a : b),
      } : null,
      'fps': fpss.isNotEmpty ? {
        'avg': fpss.reduce((a, b) => a + b) / fpss.length,
        'min': fpss.reduce((a, b) => a < b ? a : b),
        'max': fpss.reduce((a, b) => a > b ? a : b),
      } : null,
      'location_accuracy': accuracies.isNotEmpty ? {
        'avg_m': accuracies.reduce((a, b) => a + b) / accuracies.length,
        'max_m': accuracies.reduce((a, b) => a > b ? a : b),
      } : null,
      'threshold_violations': _countThresholdViolations(),
    };
  }

  /// 统计阈值违规次数
  Map<String, int> _countThresholdViolations() {
    int memoryViolations = 0;
    int batteryViolations = 0;
    int fpsViolations = 0;
    int locationViolations = 0;
    
    for (final data in _dataPoints) {
      if (thresholds.maxMemoryMB != null && data.memoryMB > thresholds.maxMemoryMB!) {
        memoryViolations++;
      }
      if (thresholds.minBatteryPercent != null && data.batteryPercent < thresholds.minBatteryPercent!) {
        batteryViolations++;
      }
      if (thresholds.minFPS != null && data.fps != null && data.fps! < thresholds.minFPS!) {
        fpsViolations++;
      }
      if (thresholds.maxLocationAccuracy != null && data.locationAccuracy != null 
          && data.locationAccuracy! > thresholds.maxLocationAccuracy!) {
        locationViolations++;
      }
    }
    
    return {
      'memory': memoryViolations,
      'battery': batteryViolations,
      'fps': fpsViolations,
      'location_accuracy': locationViolations,
    };
  }

  /// 保存数据到文件
  Future<void> saveToFile(String path) async {
    final report = generateReport();
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(JsonEncoder.withIndent('  ').convert({
      'report': report,
      'data_points': _dataPoints.map((d) => d.toJson()).toList(),
    }));
    print('[PerformanceCollector] 数据已保存: $path');
  }

  /// 获取内存使用量（MB）
  static Future<int> getMemoryUsageMB() async {
    try {
      final result = await _channel.invokeMethod<int>('getMemoryUsage');
      return result ?? await _getMemoryUsageFallback();
    } catch (e) {
      return await _getMemoryUsageFallback();
    }
  }

  /// 内存获取备用方案
  static Future<int> _getMemoryUsageFallback() async {
    try {
      // 使用 Dart 的内存信息API
      final info = await Process.run('cat', ['/proc/self/status']);
      if (info.exitCode == 0) {
        final vmRSS = RegExp(r'VmRSS:\s+(\d+)\s+kB')
          .firstMatch(info.stdout as String);
        if (vmRSS != null) {
          final kb = int.parse(vmRSS.group(1)!);
          return (kb / 1024).round(); // 转换为MB
        }
      }
    } catch (e) {
      // 忽略错误
    }
    return 0;
  }

  /// 获取CPU使用率（%）
  static Future<double> getCPUUsage() async {
    try {
      final result = await _channel.invokeMethod<double>('getCPUUsage');
      return result ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// 获取FPS
  static Future<double?> getFPS() async {
    try {
      final result = await _channel.invokeMethod<double>('getFPS');
      return result;
    } catch (e) {
      return null;
    }
  }

  /// 获取电池电量（%）
  static Future<int> getBatteryLevel() async {
    try {
      final result = await _channel.invokeMethod<int>('getBatteryLevel');
      return result ?? 100;
    } catch (e) {
      return 100;
    }
  }

  /// 获取电池状态
  static Future<BatteryState> getBatteryState() async {
    try {
      final result = await _channel.invokeMethod<String>('getBatteryState');
      return BatteryState.fromString(result ?? 'unknown');
    } catch (e) {
      return BatteryState.unknown;
    }
  }

  /// 获取定位精度（米）
  static Future<double?> getLocationAccuracy() async {
    try {
      final result = await _channel.invokeMethod<double>('getLocationAccuracy');
      return result;
    } catch (e) {
      return null;
    }
  }

  /// 模拟切换到后台
  static Future<void> simulateBackgroundSwitch() async {
    try {
      await _channel.invokeMethod('simulateBackgroundSwitch');
    } catch (e) {
      print('[PerformanceCollector] 后台切换模拟失败: $e');
    }
  }

  /// 模拟返回前台
  static Future<void> simulateForegroundReturn() async {
    try {
      await _channel.invokeMethod('simulateForegroundReturn');
    } catch (e) {
      print('[PerformanceCollector] 前台恢复模拟失败: $e');
    }
  }

  /// 保存测试数据
  static Future<void> saveTestData(String testName, Map<String, dynamic> data, {String? directory}) async {
    try {
      final dir = directory ?? 'test-results';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$dir/${testName}_$timestamp.json';
      
      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsString(JsonEncoder.withIndent('  ').convert({
        'test_name': testName,
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      }));
      
      print('[PerformanceCollector] 测试数据已保存: $path');
    } catch (e) {
      print('[PerformanceCollector] 保存测试数据失败: $e');
    }
  }
}

/// 性能数据点
class PerformanceDataPoint {
  final DateTime timestamp;
  final int elapsedSeconds;
  final int memoryMB;
  final int batteryPercent;
  final double? cpuPercent;
  final double? fps;
  final double? locationAccuracy;

  PerformanceDataPoint({
    required this.timestamp,
    required this.elapsedSeconds,
    required this.memoryMB,
    required this.batteryPercent,
    this.cpuPercent,
    this.fps,
    this.locationAccuracy,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'elapsed_seconds': elapsedSeconds,
    'memory_mb': memoryMB,
    'battery_percent': batteryPercent,
    'cpu_percent': cpuPercent,
    'fps': fps,
    'location_accuracy': locationAccuracy,
  };

  @override
  String toString() {
    return 'PerformanceDataPoint(${elapsedSeconds}s: ${memoryMB}MB, ${batteryPercent}%)';
  }
}

/// 性能阈值配置
class PerformanceThresholds {
  /// 最大内存使用（MB）
  final int? maxMemoryMB;
  
  /// 最小电池电量（%）
  final int? minBatteryPercent;
  
  /// 最小FPS
  final double? minFPS;
  
  /// 最大定位精度（米）
  final double? maxLocationAccuracy;

  const PerformanceThresholds({
    this.maxMemoryMB = 500,
    this.minBatteryPercent = 20,
    this.minFPS = 30,
    this.maxLocationAccuracy = 50,
  });
}

/// 电池状态
enum BatteryState {
  charging,
  discharging,
  full,
  unknown;

  static BatteryState fromString(String value) {
    switch (value.toLowerCase()) {
      case 'charging':
        return BatteryState.charging;
      case 'discharging':
        return BatteryState.discharging;
      case 'full':
        return BatteryState.full;
      default:
        return BatteryState.unknown;
    }
  }
}

/// FPS监控器
class FPSMonitor {
  final _frameTimes = <Duration>[];
  DateTime? _lastFrameTime;
  bool _isMonitoring = false;
  
  /// 开始监控FPS
  void start() {
    _isMonitoring = true;
    _frameTimes.clear();
    _lastFrameTime = null;
  }
  
  /// 停止监控
  void stop() {
    _isMonitoring = false;
  }
  
  /// 记录帧时间
  void recordFrame() {
    if (!_isMonitoring) return;
    
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      _frameTimes.add(now.difference(_lastFrameTime!));
    }
    _lastFrameTime = now;
    
    // 只保留最近60帧
    if (_frameTimes.length > 60) {
      _frameTimes.removeAt(0);
    }
  }
  
  /// 获取平均FPS
  double? getAverageFPS() {
    if (_frameTimes.isEmpty) return null;
    
    final avgFrameTime = _frameTimes.map((d) => d.inMicroseconds).reduce((a, b) => a + b) / _frameTimes.length;
    return avgFrameTime > 0 ? 1000000 / avgFrameTime : 0;
  }
  
  /// 获取当前FPS
  double? getCurrentFPS() {
    if (_frameTimes.isEmpty) return null;
    final lastFrameTime = _frameTimes.last.inMicroseconds;
    return lastFrameTime > 0 ? 1000000 / lastFrameTime : 0;
  }
}

/// 内存监控器
class MemoryMonitor {
  final List<MemorySnapshot> _snapshots = [];
  
  /// 采集内存快照
  Future<MemorySnapshot> takeSnapshot() async {
    final memory = await PerformanceCollector.getMemoryUsageMB();
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      memoryMB: memory,
    );
    _snapshots.add(snapshot);
    return snapshot;
  }
  
  /// 获取所有快照
  List<MemorySnapshot> get snapshots => List.unmodifiable(_snapshots);
  
  /// 获取内存增长趋势
  MemoryTrend getTrend() {
    if (_snapshots.length < 2) return MemoryTrend.stable;
    
    final first = _snapshots.first.memoryMB;
    final last = _snapshots.last.memoryMB;
    final growth = last - first;
    
    if (growth > 50) return MemoryTrend.increasing;
    if (growth < -20) return MemoryTrend.decreasing;
    return MemoryTrend.stable;
  }
}

/// 内存快照
class MemorySnapshot {
  final DateTime timestamp;
  final int memoryMB;

  MemorySnapshot({required this.timestamp, required this.memoryMB});
}

/// 内存趋势
enum MemoryTrend {
  increasing,
  stable,
  decreasing,
}

/// 电池监控器
class BatteryMonitor {
  int? _initialLevel;
  int? _lastLevel;
  final List<BatterySnapshot> _snapshots = [];
  
  /// 开始监控
  Future<void> start() async {
    _initialLevel = await PerformanceCollector.getBatteryLevel();
    _lastLevel = _initialLevel;
    _snapshots.clear();
    _snapshots.add(BatterySnapshot(
      timestamp: DateTime.now(),
      level: _initialLevel!,
      state: await PerformanceCollector.getBatteryState(),
    ));
  }
  
  /// 采集快照
  Future<BatterySnapshot> takeSnapshot() async {
    final level = await PerformanceCollector.getBatteryLevel();
    final state = await PerformanceCollector.getBatteryState();
    final snapshot = BatterySnapshot(
      timestamp: DateTime.now(),
      level: level,
      state: state,
    );
    _snapshots.add(snapshot);
    _lastLevel = level;
    return snapshot;
  }
  
  /// 获取总消耗电量
  int getTotalConsumption() {
    if (_initialLevel == null || _lastLevel == null) return 0;
    return _initialLevel! - _lastLevel!;
  }
  
  /// 获取每小时消耗电量
  double getHourlyConsumption() {
    if (_snapshots.length < 2) return 0;
    
    final duration = _snapshots.last.timestamp.difference(_snapshots.first.timestamp);
    if (duration.inSeconds == 0) return 0;
    
    final consumption = _snapshots.first.level - _snapshots.last.level;
    return consumption / (duration.inSeconds / 3600);
  }
}

/// 电池快照
class BatterySnapshot {
  final DateTime timestamp;
  final int level;
  final BatteryState state;

  BatterySnapshot({
    required this.timestamp,
    required this.level,
    required this.state,
  });
}
