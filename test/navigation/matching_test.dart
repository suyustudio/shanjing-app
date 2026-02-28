import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

// ==================== 核心数据结构 ====================

/// GPS 坐标点
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      other.latitude == latitude &&
      other.longitude == longitude;
  
  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// 轨迹点
class TrackPoint {
  final LatLng position;
  const TrackPoint({required this.position});
}

/// 路线轨迹
class RoutePath {
  final List<TrackPoint> points;
  const RoutePath(this.points);

  factory RoutePath.fromCoordinates(List<LatLng> coords) {
    return RoutePath(coords.map((c) => TrackPoint(position: c)).toList());
  }
}

/// 轨迹匹配结果
class TrackMatchingResult {
  final int nearestPointIndex;
  final double distanceToRoute;
  final bool isDeviated;

  const TrackMatchingResult({
    required this.nearestPointIndex,
    required this.distanceToRoute,
    required this.isDeviated,
  });
}

// ==================== 距离计算工具 ====================

class DistanceCalculator {
  static const double _earthRadius = 6371000;

  static double haversine(LatLng p1, LatLng p2) {
    final lat1 = _toRadians(p1.latitude);
    final lat2 = _toRadians(p2.latitude);
    final dLat = _toRadians(p2.latitude - p1.latitude);
    final dLon = _toRadians(p2.longitude - p1.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}

// ==================== 轨迹匹配器 ====================

class TrackMatcher {
  static const double deviationThreshold = 30.0;

  /// 匹配 GPS 点到路线轨迹
  static TrackMatchingResult match(LatLng gpsPoint, RoutePath route) {
    if (route.points.isEmpty) {
      throw ArgumentError('Route cannot be empty');
    }

    double minDistance = double.infinity;
    int nearestIndex = 0;

    // 找到最近的轨迹点
    for (int i = 0; i < route.points.length; i++) {
      final distance = DistanceCalculator.haversine(
        gpsPoint,
        route.points[i].position,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    return TrackMatchingResult(
      nearestPointIndex: nearestIndex,
      distanceToRoute: minDistance,
      isDeviated: minDistance > deviationThreshold,
    );
  }
}

// ==================== 测试用例 ====================

void main() {
  group('轨迹匹配算法 - 精确匹配用例', () {
    // 测试路线
    late RoutePath testRoute;

    setUp(() {
      testRoute = RoutePath.fromCoordinates([
        const LatLng(30.2000, 120.1000), // 索引 0
        const LatLng(30.2010, 120.1000), // 索引 1
        const LatLng(30.2020, 120.1000), // 索引 2
        const LatLng(30.2030, 120.1000), // 索引 3
        const LatLng(30.2040, 120.1000), // 索引 4
      ]);
    });

    // 精确匹配 - GPS 点精确匹配到轨迹上
    test('精确匹配 - 坐标精确匹配到轨迹点，返回正确索引', () {
      // GPS 点精确匹配到索引 2 的轨迹点
      final gpsPoint = const LatLng(30.2020, 120.1000);
      final result = TrackMatcher.match(gpsPoint, testRoute);

      // 验证返回正确索引
      expect(result.nearestPointIndex, equals(2));
      // 验证距离接近 0（精确匹配）
      expect(result.distanceToRoute, lessThan(1.0));
      // 验证未偏离
      expect(result.isDeviated, isFalse);
    });

    test('精确匹配 - 起点坐标返回索引 0', () {
      final gpsPoint = const LatLng(30.2000, 120.1000);
      final result = TrackMatcher.match(gpsPoint, testRoute);

      expect(result.nearestPointIndex, equals(0));
      expect(result.distanceToRoute, lessThan(1.0));
      expect(result.isDeviated, isFalse);
    });

    test('精确匹配 - 终点坐标返回最后一个索引', () {
      final gpsPoint = const LatLng(30.2040, 120.1000);
      final result = TrackMatcher.match(gpsPoint, testRoute);

      expect(result.nearestPointIndex, equals(4));
      expect(result.distanceToRoute, lessThan(1.0));
      expect(result.isDeviated, isFalse);
    });
  });
}
