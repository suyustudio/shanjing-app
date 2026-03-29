/**
 * 地图服务
 * 
 * 提供路径规划、地理编码等功能
 * 调用后端 API 使用高德地图服务
 */

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'api_client.dart';
import 'api_config.dart';

/// 路线步骤
class RouteStep {
  final String instruction;  // 导航指令，如"步行100米左转"
  final String road;         // 道路名称
  final int distance;        // 距离（米）
  final int duration;        // 时间（秒）
  final List<LatLng> polyline; // 轨迹点
  final String? action;      // 动作（左转、右转等）
  final String? assistantAction; // 辅助动作

  RouteStep({
    required this.instruction,
    required this.road,
    required this.distance,
    required this.duration,
    required this.polyline,
    this.action,
    this.assistantAction,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    // 解析polyline - 支持两种格式:
    // 1. [{'lat': x, 'lng': y}, ...] - 对象数组
    // 2. [LatLng(x, y), ...] - 已解析的LatLng对象
    List<LatLng> polyline = [];
    final polylineData = json['polyline'] as List<dynamic>?;
    if (polylineData != null) {
      for (final point in polylineData) {
        if (point is Map<String, dynamic>) {
          // 格式1: {'lat': x, 'lng': y}
          polyline.add(LatLng(
            (point['lat'] as num).toDouble(),
            (point['lng'] as num).toDouble(),
          ));
        } else if (point is LatLng) {
          // 格式2: 已经是LatLng对象
          polyline.add(point);
        }
      }
    }

    return RouteStep(
      instruction: json['instruction'] ?? '',
      road: json['road'] ?? '',
      distance: json['distance'] ?? 0,
      duration: json['duration'] ?? 0,
      polyline: polyline,
      action: json['action'],
      assistantAction: json['assistantAction'],
    );
  }
}

/// 路线路径
class RoutePath {
  final int distance;        // 总距离（米）
  final int duration;        // 总时间（秒）
  final List<RouteStep> steps; // 路线步骤
  final double? tolls;       // 过路费（驾车）
  final int? tollDistance;   // 收费路段距离
  final bool? restriction;   // 是否限行
  final int? trafficLights;  // 红绿灯数量

  RoutePath({
    required this.distance,
    required this.duration,
    required this.steps,
    this.tolls,
    this.tollDistance,
    this.restriction,
    this.trafficLights,
  });

  factory RoutePath.fromJson(Map<String, dynamic> json) {
    return RoutePath(
      distance: json['distance'] ?? 0,
      duration: json['duration'] ?? 0,
      steps: (json['steps'] as List<dynamic>?)
          ?.map((s) => RouteStep.fromJson(s))
          .toList() ?? [],
      tolls: json['tolls']?.toDouble(),
      tollDistance: json['tollDistance'],
      restriction: json['restriction'],
      trafficLights: json['trafficLights'],
    );
  }

  /// 获取所有轨迹点（用于绘制路线）
  List<LatLng> get allPoints {
    final points = <LatLng>[];
    for (final step in steps) {
      points.addAll(step.polyline);
    }
    return points;
  }
}

/// 路线规划结果
class RoutePlanResult {
  final bool success;
  final String? errorMessage;
  final List<RoutePath> paths;
  final String? origin;
  final String? destination;

  RoutePlanResult({
    required this.success,
    this.errorMessage,
    required this.paths,
    this.origin,
    this.destination,
  });

  factory RoutePlanResult.fromJson(Map<String, dynamic> json) {
    return RoutePlanResult(
      success: json['success'] ?? false,
      errorMessage: json['errorMessage'],
      paths: (json['paths'] as List<dynamic>?)
          ?.map((p) => RoutePath.fromJson(p))
          .toList() ?? [],
      origin: json['origin'],
      destination: json['destination'],
    );
  }
}

/// 地图服务
class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  final ApiClient _apiClient = ApiClient();

  /// 步行路线规划
  /// 
  /// [origin] 起点坐标
  /// [destination] 终点坐标
  /// 
  /// 返回路线规划结果，包含多条可选路径
  Future<RoutePlanResult> planWalkingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.walkingRoute,
      body: {
        'originLat': origin.latitude,
        'originLng': origin.longitude,
        'destLat': destination.latitude,
        'destLng': destination.longitude,
      },
    );

    if (response.success && response.data != null) {
      return RoutePlanResult.fromJson(response.data as Map<String, dynamic>);
    } else {
      return RoutePlanResult(
        success: false,
        errorMessage: response.errorMessage ?? '路线规划失败',
        paths: [],
      );
    }
  }

  /// 驾车路线规划
  Future<RoutePlanResult> planDrivingRoute({
    required LatLng origin,
    required LatLng destination,
    int strategy = 10, // 最快路线
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.drivingRoute,
      body: {
        'originLat': origin.latitude,
        'originLng': origin.longitude,
        'destLat': destination.latitude,
        'destLng': destination.longitude,
        'strategy': strategy,
      },
    );

    if (response.success && response.data != null) {
      return RoutePlanResult.fromJson(response.data as Map<String, dynamic>);
    } else {
      return RoutePlanResult(
        success: false,
        errorMessage: response.errorMessage ?? '路线规划失败',
        paths: [],
      );
    }
  }

  /// 骑行路线规划
  Future<RoutePlanResult> planBicyclingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.bicyclingRoute,
      body: {
        'originLat': origin.latitude,
        'originLng': origin.longitude,
        'destLat': destination.latitude,
        'destLng': destination.longitude,
      },
    );

    if (response.success && response.data != null) {
      return RoutePlanResult.fromJson(response.data as Map<String, dynamic>);
    } else {
      return RoutePlanResult(
        success: false,
        errorMessage: response.errorMessage ?? '路线规划失败',
        paths: [],
      );
    }
  }

  /// 地理编码（地址转坐标）
  Future<LatLng?> geocode(String address) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.geocode}?address=$address',
    );

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final location = data['location'] as Map<String, dynamic>?;
      if (location != null) {
        return LatLng(
          location['lat'] as double,
          location['lng'] as double,
        );
      }
    }
    return null;
  }

  /// 逆地理编码（坐标转地址）
  Future<String?> reverseGeocode(LatLng location) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.regeocode}?lat=${location.latitude}&lng=${location.longitude}',
    );

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return data['formattedAddress'] as String?;
    }
    return null;
  }
}
