# Flutter 轨迹跟随算法 - 基础实现

## 概述

本文档提供 Flutter 导航应用中 GPS 轨迹跟随的基础算法实现，包括：
1. GPS 点与路线轨迹的距离计算
2. 偏离路线判断（阈值 30 米）
3. 返回最近轨迹点索引

---

## 核心数据结构

```dart
/// GPS 坐标点
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}

/// 轨迹点（包含坐标和可选的元数据）
class TrackPoint {
  final LatLng position;
  final double? speed;      // m/s
  final DateTime? timestamp;

  const TrackPoint({
    required this.position,
    this.speed,
    this.timestamp,
  });
}

/// 路线轨迹
class RoutePath {
  final List<TrackPoint> points;

  const RoutePath(this.points);

  /// 从坐标列表快速创建
  factory RoutePath.fromCoordinates(List<LatLng> coords) {
    return RoutePath(
      coords.map((c) => TrackPoint(position: c)).toList(),
    );
  }
}
```

---

## 距离计算算法

### 1. Haversine 公式（地球表面两点距离）

```dart
import 'dart:math';

class DistanceCalculator {
  static const double _earthRadius = 6371000; // 地球半径（米）

  /// 使用 Haversine 公式计算两点间距离（米）
  static double haversine(LatLng p1, LatLng p2) {
    final lat1 = _toRadians(p1.latitude);
    final lat2 = _toRadians(p2.latitude);
    final dLat = _toRadians(p2.latitude - p1.latitude);
    final dLon = _toRadians(p2.longitude - p1.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(lat1) * cos(lat2) *
              sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadius * c;
  }

  /// 角度转弧度
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
```

### 2. 点到线段的最短距离

```dart
/// 点到线段的距离计算结果
class PointToSegmentResult {
  final double distance;      // 点到线段的距离（米）
  final LatLng closestPoint;  // 线段上最近的点
  final double ratio;         // 最近点在线段上的比例 (0.0 ~ 1.0)

  const PointToSegmentResult({
    required this.distance,
    required this.closestPoint,
    required this.ratio,
  });
}

class SegmentCalculator {
  /// 计算点到线段的最短距离
  /// 
  /// 使用向量投影法，将问题转换到平面坐标系近似计算
  static PointToSegmentResult pointToSegment(
    LatLng point,
    LatLng segmentStart,
    LatLng segmentEnd,
  ) {
    // 转换为局部平面坐标（以 segmentStart 为原点，单位：米）
    final p = _toLocal(point, segmentStart);
    final s = const Offset(0, 0); // segmentStart 在局部坐标系中是原点
    final e = _toLocal(segmentEnd, segmentStart);

    // 向量 se 和 sp
    final seX = e.dx - s.dx;
    final seY = e.dy - s.dy;
    final spX = p.dx - s.dx;
    final spY = p.dy - s.dy;

    // 计算投影比例 t
    final seLenSq = seX * seX + seY * seY;
    
    double t;
    if (seLenSq == 0) {
      // 线段退化为点
      t = 0;
    } else {
      t = (spX * seX + spY * seY) / seLenSq;
      // 限制在线段范围内
      t = t.clamp(0.0, 1.0);
    }

    // 计算最近点坐标
    final closestX = s.dx + t * seX;
    final closestY = s.dy + t * seY;

    // 计算距离
    final dx = p.dx - closestX;
    final dy = p.dy - closestY;
    final distance = sqrt(dx * dx + dy * dy);

    // 将最近点转换回经纬度
    final closestLatLng = _toLatLng(
      Offset(closestX, closestY),
      segmentStart,
    );

    return PointToSegmentResult(
      distance: distance,
      closestPoint: closestLatLng,
      ratio: t,
    );
  }

  /// 将经纬度转换为以 ref 为原点的局部平面坐标（米）
  static Offset _toLocal(LatLng point, LatLng ref) {
    // 经度方向每度的距离随纬度变化
    final latRad = point.latitude * pi / 180;
    final metersPerLonDeg = cos(latRad) * DistanceCalculator._earthRadius * pi / 180;
    final metersPerLatDeg = DistanceCalculator._earthRadius * pi / 180;

    return Offset(
      (point.longitude - ref.longitude) * metersPerLonDeg,
      (point.latitude - ref.latitude) * metersPerLatDeg,
    );
  }

  /// 将局部平面坐标转换回经纬度
  static LatLng _toLatLng(Offset local, LatLng ref) {
    final latRad = ref.latitude * pi / 180;
    final metersPerLonDeg = cos(latRad) * DistanceCalculator._earthRadius * pi / 180;
    final metersPerLatDeg = DistanceCalculator._earthRadius * pi / 180;

    return LatLng(
      ref.latitude + local.dy / metersPerLatDeg,
      ref.longitude + local.dx / metersPerLonDeg,
    );
  }
}
```

---

## 轨迹匹配核心算法

```dart
/// 轨迹匹配结果
class TrackMatchingResult {
  final int nearestPointIndex;    // 最近轨迹点索引
  final double distanceToRoute;   // 到路线的最短距离（米）
  final bool isDeviated;          // 是否偏离路线
  final LatLng? projectedPoint;   // 投影点（在路线上）
  final double? progressRatio;    // 路线进度 (0.0 ~ 1.0)
  final bool isAccuracyValid;     // GPS 精度是否有效
  final String status;            // 匹配状态: "正常" | "精度不足" | "偏离路线"

  const TrackMatchingResult({
    required this.nearestPointIndex,
    required this.distanceToRoute,
    required this.isDeviated,
    this.projectedPoint,
    this.progressRatio,
    this.isAccuracyValid = true,
    this.status = "正常",
  });

  @override
  String toString() {
    return 'TrackMatchingResult{nearestIndex: $nearestPointIndex, '
           'distance: ${distanceToRoute.toStringAsFixed(2)}m, '
           'deviated: $isDeviated, status: $status}';
  }
}

class TrackMatcher {
  /// 偏离阈值（米）
  static const double deviationThreshold = 30.0;
  
  /// GPS 精度阈值（米）
  static const double accuracyThreshold = 10.0;

  /// 匹配 GPS 点到路线轨迹
  /// 
  /// 算法逻辑：
  /// 1. 检查 GPS 精度，若 accuracy > 10 米则返回精度不足状态
  /// 2. 遍历路线的所有线段
  /// 3. 计算当前 GPS 点到每条线段的距离
  /// 4. 找出最短距离对应的线段
  /// 5. 返回最近点索引、距离和偏离状态
  static TrackMatchingResult match(
    LatLng gpsPoint,
    RoutePath route, {
    double threshold = deviationThreshold,
    double? accuracy, // GPS 精度（米），null 表示未知
  }) {
    // GPS 精度检查：当 accuracy > 10 米时，返回精度不足状态
    if (accuracy != null && accuracy > accuracyThreshold) {
      return TrackMatchingResult(
        nearestPointIndex: -1,
        distanceToRoute: double.infinity,
        isDeviated: true,
        projectedPoint: null,
        progressRatio: null,
        isAccuracyValid: false,
        status: "精度不足",
      );
    }

    if (route.points.isEmpty) {
      throw ArgumentError('Route cannot be empty');
    }

    if (route.points.length == 1) {
      // 只有单个点
      final distance = DistanceCalculator.haversine(
        gpsPoint,
        route.points.first.position,
      );
      return TrackMatchingResult(
        nearestPointIndex: 0,
        distanceToRoute: distance,
        isDeviated: distance > threshold,
        projectedPoint: route.points.first.position,
        progressRatio: 0,
        isAccuracyValid: true,
        status: distance > threshold ? "偏离路线" : "正常",
      );
    }

    double minDistance = double.infinity;
    int nearestSegmentIndex = 0;
    PointToSegmentResult? bestResult;

    // 遍历所有线段，找到最短距离
    for (int i = 0; i < route.points.length - 1; i++) {
      final start = route.points[i].position;
      final end = route.points[i + 1].position;

      final result = SegmentCalculator.pointToSegment(gpsPoint, start, end);

      if (result.distance < minDistance) {
        minDistance = result.distance;
        nearestSegmentIndex = i;
        bestResult = result;
      }
    }

    // 计算最近点索引
    // 如果投影点更靠近线段终点，则返回 i+1
    final nearestPointIndex = bestResult!.ratio > 0.5 
        ? nearestSegmentIndex + 1 
        : nearestSegmentIndex;

    // 计算路线进度（0.0 ~ 1.0）
    final progressRatio = (nearestSegmentIndex + bestResult.ratio) / 
                          (route.points.length - 1);

    final isDeviated = minDistance > threshold;

    return TrackMatchingResult(
      nearestPointIndex: nearestPointIndex,
      distanceToRoute: minDistance,
      isDeviated: isDeviated,
      projectedPoint: bestResult.closestPoint,
      progressRatio: progressRatio,
      isAccuracyValid: true,
      status: isDeviated ? "偏离路线" : "正常",
    );
  }

  /// 快速检查是否偏离路线（不返回详细结果）
  static bool isDeviated(
    LatLng gpsPoint,
    RoutePath route, {
    double threshold = deviationThreshold,
    double? accuracy, // GPS 精度（米），null 表示未知
  }) {
    final result = match(gpsPoint, route, threshold: threshold, accuracy: accuracy);
    return result.isDeviated;
  }

  /// 批量匹配（用于历史轨迹回放）
  static List<TrackMatchingResult> matchBatch(
    List<LatLng> gpsPoints,
    RoutePath route, {
    double threshold = deviationThreshold,
    List<double>? accuracies, // 对应每个 GPS 点的精度值
  }) {
    return gpsPoints
        .asMap()
        .map((index, p) {
          final accuracy = accuracies != null && index < accuracies.length
              ? accuracies[index]
              : null;
          return MapEntry(index, match(p, route, threshold: threshold, accuracy: accuracy));
        })
        .values
        .toList();
  }
}
```

---

## 使用示例

```dart
void main() {
  // 1. 定义路线轨迹
  final route = RoutePath.fromCoordinates([
    const LatLng(39.9042, 116.4074),  // 北京天安门
    const LatLng(39.9050, 116.4080),
    const LatLng(39.9060, 116.4090),
    const LatLng(39.9070, 116.4100),
    const LatLng(39.9080, 116.4110),
  ]);

  // 2. 当前 GPS 位置（模拟）
  final currentGps = const LatLng(39.9055, 116.4085);

  // 3. 执行轨迹匹配（带 GPS 精度）
  final result = TrackMatcher.match(
    currentGps, 
    route,
    accuracy: 5.0, // GPS 精度 5 米
  );

  // 4. 输出结果
  print('匹配结果: $result');
  print('最近轨迹点索引: ${result.nearestPointIndex}');
  print('距离路线: ${result.distanceToRoute.toStringAsFixed(2)} 米');
  print('是否偏离: ${result.isDeviated ? "是" : "否"}');
  print('路线进度: ${(result.progressRatio! * 100).toStringAsFixed(1)}%');
  print('状态: ${result.status}');

  // 5. 快速偏离检查（带精度）
  final deviated = TrackMatcher.isDeviated(
    currentGps, 
    route,
    accuracy: 15.0, // 精度 15 米，超过阈值
  );
  print('偏离检查: ${deviated ? "已偏离/精度不足" : "在路线上"}');
  
  // 6. 低精度 GPS 示例
  final lowAccuracyResult = TrackMatcher.match(
    currentGps,
    route,
    accuracy: 20.0, // 精度 20 米，超过 10 米阈值
  );
  print('低精度匹配结果: ${lowAccuracyResult.status}'); // 输出: 精度不足
}
```

---

## 性能优化建议

### 1. 空间索引（R-Tree 或网格）

```dart
/// 简单的网格索引（用于大规模轨迹数据）
class GridIndex {
  final double cellSize; // 网格大小（米）
  final Map<String, List<int>> _grid = {};

  GridIndex({this.cellSize = 1000}); // 默认 1km 网格

  void build(RoutePath route) {
    _grid.clear();
    for (int i = 0; i < route.points.length; i++) {
      final key = _getCellKey(route.points[i].position);
      _grid.putIfAbsent(key, () => []).add(i);
    }
  }

  List<int> queryNearby(LatLng point, double radius) {
    // 只查询周围 9 个网格
    final results = <int>[];
    final centerKey = _getCellKey(point);
    final centerCell = _parseKey(centerKey);

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        final key = '${centerCell.$1 + dx},${centerCell.$2 + dy}';
        if (_grid.containsKey(key)) {
          results.addAll(_grid[key]!);
        }
      }
    }
    return results;
  }

  String _getCellKey(LatLng point) {
    final x = (point.longitude * 111320 / cellSize).floor();
    final y = (point.latitude * 110540 / cellSize).floor();
    return '$x,$y';
  }

  (int, int) _parseKey(String key) {
    final parts = key.split(',');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }
}
```

### 2. 增量匹配（利用历史位置）

```dart
class IncrementalTrackMatcher {
  int _lastMatchedIndex = 0;

  /// 基于上次匹配结果进行增量匹配
  TrackMatchingResult matchIncremental(
    LatLng gpsPoint,
    RoutePath route, {
    int searchWindow = 5, // 前后搜索窗口大小
  }) {
    final startIdx = (_lastMatchedIndex - searchWindow).clamp(0, route.points.length - 1);
    final endIdx = (_lastMatchedIndex + searchWindow).clamp(0, route.points.length - 1);

    // 只在窗口范围内搜索
    double minDistance = double.infinity;
    int nearestIdx = _lastMatchedIndex;

    for (int i = startIdx; i <= endIdx && i < route.points.length; i++) {
      final distance = DistanceCalculator.haversine(
        gpsPoint,
        route.points[i].position,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestIdx = i;
      }
    }

    _lastMatchedIndex = nearestIdx;

    return TrackMatchingResult(
      nearestPointIndex: nearestIdx,
      distanceToRoute: minDistance,
      isDeviated: minDistance > TrackMatcher.deviationThreshold,
    );
  }

  void reset() {
    _lastMatchedIndex = 0;
  }
}
```

---

## 完整代码文件

建议将代码组织为以下文件结构：

```
lib/
├── navigation/
│   ├── models/
│   │   ├── latlng.dart           # 坐标模型
│   │   ├── track_point.dart      # 轨迹点模型
│   │   └── route_path.dart       # 路线模型
│   ├── utils/
│   │   ├── distance_calculator.dart  # 距离计算
│   │   └── segment_calculator.dart   # 线段计算
│   ├── track_matcher.dart        # 核心匹配算法
│   └── navigation_service.dart   # 导航服务封装
```

---

## 算法复杂度

| 操作 | 时间复杂度 | 空间复杂度 |
|------|-----------|-----------|
| 单次匹配 | O(n) | O(1) |
| 批量匹配 | O(m × n) | O(m) |
| 带网格索引 | O(1) ~ O(n) | O(n) |
| 增量匹配 | O(w) | O(1) |

- n = 路线轨迹点数
- m = GPS 点数
- w = 搜索窗口大小

---

## 注意事项

1. **坐标系**：本实现使用 WGS84 坐标系（GPS 标准）
2. **精度**：Haversine 公式在短距离（<1km）精度足够，长距离需考虑地球椭球
3. **性能**：对于实时导航（1秒间隔），简单遍历通常足够；大规模数据建议使用空间索引
4. **阈值调整**：30米阈值适用于步行/骑行，车辆导航建议 50-100米

---

*文档版本: 1.1 | 更新日期: 2026-02-28*

---

## GPS 精度过滤说明

### 功能概述

为了提升轨迹跟随算法的可靠性，系统增加了 GPS 精度过滤机制。当 GPS 定位精度不足时（>10 米），算法将拒绝使用该点进行轨迹匹配，避免低精度数据导致错误的导航判断。

### 实现细节

1. **精度阈值**：`accuracyThreshold = 10.0` 米
   - 精度 ≤ 10 米：视为有效，正常进行轨迹匹配
   - 精度 > 10 米：视为无效，返回 "精度不足" 状态

2. **TrackMatcher 修改**：
   - `match()` 方法新增 `accuracy` 可选参数（单位：米）
   - `isDeviated()` 方法新增 `accuracy` 可选参数
   - `matchBatch()` 方法新增 `accuracies` 可选参数列表

3. **TrackMatchingResult 扩展**：
   - `isAccuracyValid`: 布尔值，表示 GPS 精度是否有效
   - `status`: 字符串，表示匹配状态（"正常" | "精度不足" | "偏离路线"）

4. **低精度点处理**：
   - 当 accuracy > 10 米时，直接返回结果，不执行轨迹匹配计算
   - `nearestPointIndex` 设为 -1
   - `distanceToRoute` 设为 `double.infinity`
   - `projectedPoint` 和 `progressRatio` 设为 null

### 使用建议

```dart
// 获取 GPS 位置时同时获取精度
final position = await Geolocator.getCurrentPosition();
final accuracy = position.accuracy; // 水平精度（米）

// 传入精度参数进行匹配
final result = TrackMatcher.match(
  LatLng(position.latitude, position.longitude),
  route,
  accuracy: accuracy,
);

// 根据状态处理不同情况
switch (result.status) {
  case "正常":
    // 更新导航 UI
    break;
  case "精度不足":
    // 提示用户等待更好的 GPS 信号
    showMessage("GPS 信号较弱，请稍候...");
    break;
  case "偏离路线":
    // 触发重新规划路线
    recalculateRoute();
    break;
}
```

### 注意事项

- 当 `accuracy` 为 null 时，系统跳过精度检查，保持向后兼容
- 批量匹配时，`accuracies` 列表长度可以与 `gpsPoints` 不一致，缺失的精度值视为 null
- 建议在 UI 层对 "精度不足" 状态进行友好提示，避免用户困惑
