/**
 * 地图服务
 *
 * 路径规划/地理编码：优先后端 API，后端不可用时直连高德 Web API
 */

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
  /// 优先调用后端 API，不可用时直接调用高德 Web API
  Future<RoutePlanResult> planWalkingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // 1) 尝试后端 API
    try {
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
      }
    } catch (_) {
      debugPrint('⚠️ 后端路线规划不可用，切换到高德 Web API');
    }

    // 2) 后端不可用，直接调用高德 Web API
    return _planWalkingRouteDirect(origin: origin, destination: destination);
  }

  /// 直接调用高德 Web API 进行步行路线规划
  Future<RoutePlanResult> _planWalkingRouteDirect({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final apiKey = dotenv.env['AMAP_KEY'] ?? '';
      if (apiKey.isEmpty) {
        debugPrint('❌ 高德 Web API 调用失败：AMAP_KEY 未配置');
        return RoutePlanResult(
          success: false,
          errorMessage: 'API Key 未配置',
          paths: [],
        );
      }

      // 高德步行路径规划 API：origin/destination 为 "lng,lat" 格式
      final originStr = '${origin.longitude},${origin.latitude}';
      final destStr = '${destination.longitude},${destination.latitude}';
      final url = Uri.parse(
        'https://restapi.amap.com/v3/direction/walking'
        '?key=$apiKey'
        '&origin=$originStr'
        '&destination=$destStr',
      );

      debugPrint('🗺️ 调用高德 Web API 步行路径规划...');
      debugPrint('   origin: $originStr');
      debugPrint('   destination: $destStr');

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('❌ 高德 Web API HTTP ${response.statusCode}');
        return RoutePlanResult(success: false, errorMessage: 'HTTP ${response.statusCode}', paths: []);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['status'] != '1') {
        final info = body['info'] ?? '未知错误';
        debugPrint('❌ 高德 Web API 返回错误: $info');
        return RoutePlanResult(success: false, errorMessage: info, paths: []);
      }

      final route = body['route'] as Map<String, dynamic>?;
      if (route == null) {
        return RoutePlanResult(success: false, errorMessage: '无路线数据', paths: []);
      }

      final pathsJson = route['paths'] as List<dynamic>? ?? [];
      final paths = <RoutePath>[];

      for (final p in pathsJson) {
        final pMap = p as Map<String, dynamic>;
        final stepsJson = (pMap['steps'] as List<dynamic>? ?? []);
        final steps = <RouteStep>[];

        for (final s in stepsJson) {
          final sMap = s as Map<String, dynamic>;
          final polylineStr = sMap['polyline'] as String? ?? '';
          // polyline 格式: "lng1,lat1;lng2,lat2;..."
          final polyline = polylineStr
              .split(';')
              .where((part) => part.contains(','))
              .map((part) {
                final coords = part.split(',');
                if (coords.length >= 2) {
                  return LatLng(
                    double.tryParse(coords[1]) ?? 0,
                    double.tryParse(coords[0]) ?? 0,
                  );
                }
                return null;
              })
              .whereType<LatLng>()
              .toList();

          steps.add(RouteStep(
            instruction: sMap['instruction'] ?? '',
            road: sMap['road'] ?? '',
            distance: int.tryParse(sMap['distance']?.toString() ?? '0') ?? 0,
            duration: int.tryParse(sMap['duration']?.toString() ?? '0') ?? 0,
            polyline: polyline,
            action: sMap['action'],
            assistantAction: sMap['assistant_action'],
          ));
        }

        paths.add(RoutePath(
          distance: int.tryParse(pMap['distance']?.toString() ?? '0') ?? 0,
          duration: int.tryParse(pMap['duration']?.toString() ?? '0') ?? 0,
          steps: steps,
          tolls: pMap['tolls']?.toDouble(),
          tollDistance: int.tryParse(pMap['toll_distance']?.toString() ?? ''),
          restriction: pMap['restriction'] == '1',
          trafficLights: int.tryParse(pMap['traffic_lights']?.toString() ?? ''),
        ));
      }

      debugPrint('✅ 高德 Web API 步行路径规划成功: ${paths.length} 条路径');
      return RoutePlanResult(
        success: true,
        paths: paths,
        origin: originStr,
        destination: destStr,
      );
    } catch (e) {
      debugPrint('❌ 高德 Web API 调用异常: $e');
      return RoutePlanResult(
        success: false,
        errorMessage: '路径规划失败: $e',
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
