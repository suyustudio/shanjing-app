# GPS 精度过滤技术方案

## 问题背景
产品需求要求 GPS 精度 <10 米，但当前 Flutter 导航模块未实现精度过滤。

## 技术方案

### 方案 1: 使用 accuracy 属性（推荐）

Flutter `geolocator` 插件返回的 `Position` 对象包含 `accuracy` 属性，表示水平精度（米）。

```dart
import 'package:geolocator/geolocator.dart';

class GPSAccuracyFilter {
  static const double MIN_ACCURACY = 10.0; // 10米阈值
  
  static bool isAccuracyAcceptable(Position position) {
    return position.accuracy <= MIN_ACCURACY;
  }
  
  static String getAccuracyStatus(Position position) {
    if (position.accuracy <= 5.0) {
      return 'excellent'; // 优秀
    } else if (position.accuracy <= 10.0) {
      return 'good'; // 良好
    } else if (position.accuracy <= 20.0) {
      return 'fair'; // 一般
    } else {
      return 'poor'; // 差
    }
  }
}

// 使用示例
StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
  locationSettings: LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 5, // 5米更新一次
  ),
).listen((Position position) {
  if (GPSAccuracyFilter.isAccuracyAcceptable(position)) {
    // 精度满足要求，用于轨迹匹配
    trackMatcher.match(position);
  } else {
    // 精度不足，提示用户
    showToast('GPS信号较弱，请移动到开阔地带');
  }
});
```

### 方案 2: 使用 HDOP（水平精度因子）

HDOP (Horizontal Dilution of Precision) 是卫星几何分布的质量指标。

| HDOP 值 | 精度评级 | 水平误差范围 | 适用场景 |
|---------|----------|--------------|----------|
| < 1.0 | 理想 | < 1米 | 精密测绘 |
| 1.0 - 2.0 | 优秀 | 1-2米 | 航海导航 |
| 2.0 - 5.0 | 良好 | 2-5米 | 一般导航 |
| 5.0 - 10.0 | 一般 | 5-10米 | 基础定位 |
| > 10.0 | 差 | > 10米 | 不可靠 |

**注意**: Flutter `geolocator` 插件不直接提供 HDOP，需要通过原生代码获取 NMEA 数据。

### 方案 3: 综合过滤策略（最佳实践）

```dart
class GPSQualityFilter {
  static const double MIN_ACCURACY = 10.0;
  static const double MAX_SPEED = 50.0; // 最大速度 50m/s（180km/h）
  static const int MIN_SATELLITES = 4; // 最少卫星数
  
  static GPSQuality checkQuality(Position position) {
    List<String> issues = [];
    
    // 1. 精度检查
    if (position.accuracy > MIN_ACCURACY) {
      issues.add('精度不足: ${position.accuracy.toStringAsFixed(1)}m');
    }
    
    // 2. 速度合理性检查（防止漂移）
    if (position.speed > MAX_SPEED) {
      issues.add('速度异常: ${position.speed.toStringAsFixed(1)}m/s');
    }
    
    // 3. 时间戳检查
    final now = DateTime.now();
    final positionTime = position.timestamp;
    if (positionTime != null) {
      final age = now.difference(positionTime).inSeconds;
      if (age > 5) {
        issues.add('数据过时: ${age}s');
      }
    }
    
    return GPSQuality(
      isValid: issues.isEmpty,
      issues: issues,
      accuracy: position.accuracy,
    );
  }
}

class GPSQuality {
  final bool isValid;
  final List<String> issues;
  final double accuracy;
  
  GPSQuality({
    required this.isValid,
    required this.issues,
    required this.accuracy,
  });
}
```

## 实施建议

### 1. 立即实施（Week 5 Day 3）
- 使用方案 1（accuracy 属性），最简单直接
- 在 `TrackMatcher.match()` 中添加精度检查
- 精度不足时返回特定状态，不用于轨迹匹配

### 2. 优化改进（Week 5 Day 4-5）
- 实现方案 3（综合过滤策略）
- 添加速度合理性检查
- 添加数据时效性检查

### 3. 用户体验优化
- GPS 信号弱时显示提示
- 提供移动到开阔地带的建议
- 显示当前精度状态（优秀/良好/一般/差）

## 参考文档

- [Flutter Geolocator 文档](https://pub.dev/packages/geolocator)
- [GPS Accuracy: HDOP, PDOP, GDOP](https://www.giserdqy.com/remote-sensing/39262/)
- [HDOP: Horizontal Dilution of Precision](https://www.lerus.com/articles/hdop-horizontal-dilution-of-precision-in-gps-and-dgps-systems.html)

## 代码修改位置

修改文件：`workspace/flutter-navigation-matching.md`

在 `TrackMatcher` 类中添加：
1. `accuracy` 参数到 `match()` 方法
2. 精度检查逻辑
3. 返回 "精度不足" 状态