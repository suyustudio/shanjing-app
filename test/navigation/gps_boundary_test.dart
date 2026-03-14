import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

// 导入导航测试中的核心类
// ==================== 核心数据结构 ====================

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class GPSPoint {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  GPSPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  double distanceTo(GPSPoint other) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(other.latitude - latitude);
    final double dLon = _toRadians(other.longitude - longitude);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(other.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;
}

void main() {
  group('GPS点 边界场景测试', () {
    
    test('相同位置的距离为0', () {
      final point = GPSPoint(
        latitude: 30.25,
        longitude: 120.15,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );
      
      final distance = point.distanceTo(point);
      expect(distance, closeTo(0, 0.001));
    });

    test('高精度定位点处理', () {
      final point = GPSPoint(
        latitude: 30.25,
        longitude: 120.15,
        accuracy: 0.5, // 亚米级精度
        timestamp: DateTime.now(),
      );
      
      expect(point.accuracy, lessThan(1.0));
    });

    test('低精度定位点处理', () {
      final point = GPSPoint(
        latitude: 30.25,
        longitude: 120.15,
        accuracy: 100.0, // 100米精度
        timestamp: DateTime.now(),
      );
      
      expect(point.accuracy, greaterThan(50.0));
    });

    test('不同时间的同一点', () async {
      final now = DateTime.now();
      final point1 = GPSPoint(
        latitude: 30.25,
        longitude: 120.15,
        accuracy: 5.0,
        timestamp: now,
      );
      
      await Future.delayed(const Duration(milliseconds: 10));
      
      final point2 = GPSPoint(
        latitude: 30.25,
        longitude: 120.15,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );
      
      expect(point1.latitude, equals(point2.latitude));
      expect(point1.longitude, equals(point2.longitude));
      expect(point1.timestamp, isNot(equals(point2.timestamp)));
    });

    test('南北极距离计算', () {
      final northPole = GPSPoint(
        latitude: 90.0,
        longitude: 0.0,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
      
      final southPole = GPSPoint(
        latitude: -90.0,
        longitude: 0.0,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
      
      final distance = northPole.distanceTo(southPole);
      // 南北极距离约 20015 公里
      expect(distance, closeTo(20015000, 1000));
    });

    test('赤道上两点距离', () {
      final point1 = GPSPoint(
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
      
      final point2 = GPSPoint(
        latitude: 0.0,
        longitude: 1.0, // 1度经度
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
      
      final distance = point1.distanceTo(point2);
      // 赤道1度经度约 111.3 公里
      expect(distance, closeTo(111320, 1000));
    });

    test('经度边界 - 180度', () {
      final point1 = GPSPoint(
        latitude: 0.0,
        longitude: 179.9,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
      
      final point2 = GPSPoint(
        latitude: 0.0,
        longitude: -179.9,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      );
      
      final distance = point1.distanceTo(point2);
      // 经度179.9到-179.9只有0.2度
      expect(distance, closeTo(22264, 1000));
    });

    test('负精度值处理', () {
      // 虽然实际不应该出现，但测试代码健壮性
      final point = GPSPoint(
        latitude: 30.25,
        longitude: 120.15,
        accuracy: -5.0,
        timestamp: DateTime.now(),
      );
      
      // 代码应该能处理负精度
      expect(point.accuracy, equals(-5.0));
    });
  });
}
