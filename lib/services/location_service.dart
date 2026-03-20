// ============================================
// 定位服务存根
// ============================================

import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// 获取当前位置
  Future<Position?> getCurrentPosition() async {
    // 实际项目中应该使用 geolocator 包
    // 这里返回 null，表示使用默认推荐
    return null;
  }
}

class Position {
  final double latitude;
  final double longitude;

  Position({
    required this.latitude,
    required this.longitude,
  });
}