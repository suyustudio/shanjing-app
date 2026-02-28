# Flutter 偏航检测与提醒 (M8.2)

## 功能概述

实现导航过程中的偏航检测与提醒功能，当用户偏离规划路线超过 30 米时触发提醒。

## 核心功能

### 1. 偏航检测

```dart
// lib/services/deviation_detector.dart

import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeviationDetector {
  /// 偏航阈值（米）
  static const double deviationThreshold = 30.0;

  /// 检测是否偏航
  /// 
  /// [currentPosition] 当前位置
  /// [routePoints] 规划路线点列表
  /// 返回：是否偏航
  static bool isDeviating(LatLng currentPosition, List<LatLng> routePoints) {
    if (routePoints.isEmpty) return false;

    // 计算当前位置到路线最近点的距离
    double minDistance = double.infinity;
    
    for (int i = 0; i < routePoints.length - 1; i++) {
      final distance = _distanceToSegment(
        currentPosition,
        routePoints[i],
        routePoints[i + 1],
      );
      minDistance = math.min(minDistance, distance);
    }

    return minDistance > deviationThreshold;
  }

  /// 计算点到线段的最短距离（米）
  static double _distanceToSegment(LatLng point, LatLng start, LatLng end) {
    final lat1 = _toRadians(start.latitude);
    final lon1 = _toRadians(start.longitude);
    final lat2 = _toRadians(end.latitude);
    final lon2 = _toRadians(end.longitude);
    final lat3 = _toRadians(point.latitude);
    final lon3 = _toRadians(point.longitude);

    // 使用球面投影简化计算
    final d = _haversineDistance(start, end);
    if (d == 0) return _haversineDistance(point, start);

    final t = ((lat3 - lat1) * (lat2 - lat1) + (lon3 - lon1) * (lon2 - lon1)) / 
              (pow(lat2 - lat1, 2) + pow(lon2 - lon1, 2));

    final clampedT = t.clamp(0.0, 1.0);
    
    final closestLat = lat1 + clampedT * (lat2 - lat1);
    final closestLon = lon1 + clampedT * (lon2 - lon1);

    return _haversineDistance(
      point,
      LatLng(_toDegrees(closestLat), _toDegrees(closestLon)),
    );
  }

  /// Haversine 公式计算两点间距离（米）
  static double _haversineDistance(LatLng p1, LatLng p2) {
    const R = 6371000; // 地球半径（米）
    
    final lat1 = _toRadians(p1.latitude);
    final lat2 = _toRadians(p2.latitude);
    final deltaLat = _toRadians(p2.latitude - p1.latitude);
    final deltaLon = _toRadians(p2.longitude - p1.longitude);

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
              cos(lat1) * cos(lat2) *
              sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;
}
```

### 2. 偏航提醒（Toast 提示）

```dart
// lib/widgets/deviation_toast.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DeviationToast {
  static OverlayEntry? _currentToast;
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isSpeaking = false;

  /// 初始化 TTS
  static Future<void> initTts() async {
    await _flutterTts.setLanguage('zh-CN');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  /// 播报语音
  static Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
    }
    _isSpeaking = true;
    await _flutterTts.speak(text);
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });
  }

  /// 显示偏航提醒
  static void show(BuildContext context) {
    // 移除已存在的 Toast
    hide();

    // 播报偏航语音提醒
    _speak('您已偏离路线');

    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935), // 偏航红色
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '已偏离路线',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '距离规划路线超过 30 米',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentToast!);
  }

  /// 隐藏偏航提醒
  static void hide() {
    _currentToast?.remove();
    _currentToast = null;
  }

  /// 播报回到正轨语音提醒
  static void showBackOnTrack() {
    _speak('已回到正确路线');
  }

  /// 释放 TTS 资源
  static Future<void> dispose() async {
    await _flutterTts.stop();
    await _flutterTts.shutdown();
  }
}
```

### 3. 重新规划路线建议

```dart
// lib/services/route_replanner.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteReplanner {
  /// 显示重新规划建议对话框
  static Future<bool> showReplannerDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.route, color: Color(0xFFE53935)), // 偏航红色
            SizedBox(width: 8),
            Text('重新规划路线'),
          ],
        ),
        content: const Text(
          '您已偏离原规划路线，是否需要重新规划路线？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('暂不'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935), // 偏航红色
              foregroundColor: Colors.white,
            ),
            child: const Text('重新规划'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// 简化版：直接触发重新规划（无需用户确认）
  static void triggerReplanner({
    required VoidCallback onReplanner,
  }) {
    onReplanner();
  }
}
```

## 集成使用

```dart
// lib/screens/navigation_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/deviation_detector.dart';
import '../services/route_replanner.dart';
import '../widgets/deviation_toast.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  List<LatLng> _routePoints = [];
  bool _isDeviating = false;
  bool _hasShownDialog = false;

  /// 位置更新回调
  void _onLocationUpdate(LatLng currentPosition) {
    if (_routePoints.isEmpty) return;

    final isDeviating = DeviationDetector.isDeviating(
      currentPosition,
      _routePoints,
    );

    // 状态变化时处理
    if (isDeviating != _isDeviating) {
      setState(() {
        _isDeviating = isDeviating;
      });

      if (isDeviating) {
        // 显示偏航提醒
        DeviationToast.show(context);
        
        // 首次偏航时询问是否重新规划
        if (!_hasShownDialog) {
          _hasShownDialog = true;
          _showReplannerDialog();
        }
      } else {
        // 回到路线上，隐藏提醒并播报
        DeviationToast.hide();
        DeviationToast.showBackOnTrack();
      }
    }
  }

  Future<void> _showReplannerDialog() async {
    final shouldReplanner = await RouteReplanner.showReplannerDialog(context);
    
    if (shouldReplanner && mounted) {
      _performReplanner();
    }
  }

  void _performReplanner() {
    // TODO: 调用路线规划 API 重新规划
    debugPrint('重新规划路线...');
    
    // 重置状态
    setState(() {
      _hasShownDialog = false;
    });
    
    DeviationToast.hide();
  }

  @override
  void dispose() {
    DeviationToast.hide();
    DeviationToast.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 构建导航界面...
    return Scaffold(
      body: Stack(
        children: [
          // Google Map 或其他地图组件
          // GoogleMap(...),
          
          // 偏航状态指示器
          if (_isDeviating)
            Positioned(
              bottom: 100,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.9), // 偏航红色
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '偏航中',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            // 回到正轨状态指示器
            Positioned(
              bottom: 100,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withOpacity(0.9), // 绿色 - 回到正轨
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '已回到正轨',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

## 依赖配置

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0  # 位置服务
  flutter_tts: ^4.0.2   # 语音播报
```

## 极简使用示例

```dart
// 快速集成示例

class SimpleNavigation extends StatelessWidget {
  final List<LatLng> routePoints;
  
  const SimpleNavigation({super.key, required this.routePoints});

  void checkDeviation(LatLng currentPosition, BuildContext context) {
    // 1. 检测偏航
    if (DeviationDetector.isDeviating(currentPosition, routePoints)) {
      // 2. 显示提醒
      DeviationToast.show(context);
      
      // 3. 建议重新规划
      RouteReplanner.showReplannerDialog(context).then((shouldReplanner) {
        if (shouldReplanner) {
          // 执行重新规划
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // 你的导航界面
  }
}
```

## 文件结构

```
lib/
├── services/
│   ├── deviation_detector.dart    # 偏航检测算法
│   └── route_replanner.dart       # 重新规划逻辑
├── widgets/
│   └── deviation_toast.dart       # 偏航提醒 UI
└── screens/
    └── navigation_screen.dart     # 导航界面（集成示例）
```

## 4. Toast 自动关闭逻辑

```dart
// lib/widgets/deviation_toast.dart

import 'dart:async';
import 'package:flutter/material.dart';

class DeviationToast {
  static OverlayEntry? _currentToast;
  static Timer? _autoHideTimer;

  /// 显示偏航提醒（3秒后自动关闭）
  static void show(BuildContext context) {
    hide();

    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '已偏离路线',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '距离规划路线超过 30 米',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // 手动关闭按钮
                GestureDetector(
                  onTap: hide,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentToast!);
    
    // 3秒后自动关闭
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), hide);
  }

  /// 显示回到正轨提醒（2秒后自动关闭）
  static void showBackOnTrack(BuildContext context) {
    hide();

    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '已回到正轨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: hide,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentToast!);
    
    // 2秒后自动关闭
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 2), hide);
  }

  /// 隐藏 Toast
  static void hide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    _currentToast?.remove();
    _currentToast = null;
  }
}
```

### 集成更新

```dart
// lib/screens/navigation_screen.dart

void _onLocationUpdate(LatLng currentPosition) {
  if (_routePoints.isEmpty) return;

  final isDeviating = DeviationDetector.isDeviating(
    currentPosition,
    _routePoints,
  );

  if (isDeviating != _isDeviating) {
    setState(() => _isDeviating = isDeviating);

    if (isDeviating) {
      DeviationToast.show(context);  // 3秒自动关闭
      if (!_hasShownDialog) {
        _hasShownDialog = true;
        _showReplannerDialog();
      }
    } else {
      DeviationToast.showBackOnTrack(context);  // 2秒自动关闭
    }
  }
}
```

| Toast 类型 | 显示时长 | 关闭方式 |
|-----------|---------|---------|
| 偏航提醒 | 3秒 | 自动 + 手动 X |
| 回到正轨 | 2秒 | 自动 + 手动 X |

## 总结

| 功能 | 实现 | 说明 |
|------|------|------|
| 偏航检测 | `DeviationDetector.isDeviating()` | 距离阈值 30 米 |
| 偏航提醒 | `DeviationToast.show()` | 顶部红色 Toast，3秒自动关闭 |
| 回到正轨 | `DeviationToast.showBackOnTrack()` | 绿色 Toast，2秒自动关闭 |
| 手动关闭 | X 按钮 | 随时关闭 Toast |
| 重新规划 | `RouteReplanner.showReplannerDialog()` | 弹窗确认 |

> **注意**：此为极简实现，生产环境建议添加防抖处理、距离分级提醒、语音播报等功能。

---

## 语音提醒说明

### 功能说明

偏航检测现已集成语音播报功能，使用 `flutter_tts` 插件实现：

| 触发条件 | 播报内容 |
|---------|---------|
| 偏离路线 | "您已偏离路线" |
| 回到正轨 | "已回到正确路线" |

### 使用方法

1. **初始化 TTS**（在应用启动时调用）：
```dart
await DeviationToast.initTts();
```

2. **偏航时自动播报**：
```dart
// 偏离路线时自动播报 "您已偏离路线"
DeviationToast.show(context);
```

3. **回到正轨时播报**：
```dart
// 回到正确路线时播报 "已回到正确路线"
DeviationToast.showBackOnTrack();
```

4. **释放资源**（在页面销毁时调用）：
```dart
@override
void dispose() {
  DeviationToast.dispose();
  super.dispose();
}
```

### 依赖安装

```bash
flutter pub add flutter_tts
```

### 平台配置

- **Android**: 无需额外配置
- **iOS**: 在 `ios/Runner/Info.plist` 中添加：
```xml
<key>NSMicrophoneUsageDescription</key>
<string>需要麦克风权限用于语音播报</string>
```
