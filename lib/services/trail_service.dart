/**
 * 路线服务
 * 
 * 提供路线相关的 API 调用
 */

import 'api_client.dart';
import 'api_config.dart';

/// 路线数据模型
class Trail {
  final String id;
  final String name;
  final double distanceKm;
  final int durationMin;
  final String difficulty;
  final String city;
  final String district;
  final List<string> coverImages;
  final int favoriteCount;
  final bool isFavorited;

  Trail({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.durationMin,
    required this.difficulty,
    required this.city,
    required this.district,
    required this.coverImages,
    required this.favoriteCount,
    required this.isFavorited,
  });

  factory Trail.fromJson(Map<string, dynamic> json) {
    return Trail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      durationMin: json['durationMin'] ?? 0,
      difficulty: json['difficulty'] ?? 'EASY',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      coverImages: List<string>.from(json['coverImages'] ?? []),
      favoriteCount: json['favoriteCount'] ?? 0,
      isFavorited: json['isFavorited'] ?? false,
    );
  }
}

/// 路线详情数据模型
class TrailDetail extends Trail {
  final String? description;
  final int elevationGainM;
  final List<string> tags;
  final String? gpxUrl;
  final double startPointLat;
  final double startPointLng;
  final String? startPointAddress;
  final Map<string, dynamic>? safetyInfo;
  final List<TrailPoi> pois;

  TrailDetail({
    required super.id,
    required super.name,
    required super.distanceKm,
    required super.durationMin,
    required super.difficulty,
    required super.city,
    required super.district,
    required super.coverImages,
    required super.favoriteCount,
    required super.isFavorited,
    this.description,
    required this.elevationGainM,
    required this.tags,
    this.gpxUrl,
    required this.startPointLat,
    required this.startPointLng,
    this.startPointAddress,
    this.safetyInfo,
    required this.pois,
  });

  factory TrailDetail.fromJson(Map<string, dynamic> json) {
    return TrailDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      durationMin: json['durationMin'] ?? 0,
      difficulty: json['difficulty'] ?? 'EASY',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      coverImages: List<string>.from(json['coverImages'] ?? []),
      favoriteCount: json['favoriteCount'] ?? 0,
      isFavorited: json['isFavorited'] ?? false,
      description: json['description'],
      elevationGainM: json['elevationGainM'] ?? 0,
      tags: List<string>.from(json['tags'] ?? []),
      gpxUrl: json['gpxUrl'],
      startPointLat: (json['startPointLat'] ?? 0).toDouble(),
      startPointLng: (json['startPointLng'] ?? 0).toDouble(),
      startPointAddress: json['startPointAddress'],
      safetyInfo: json['safetyInfo'],
      pois: (json['pois'] as List? ?? [])
          .map((e) => TrailPoi.fromJson(e))
          .toList(),
    );
  }
}

/// 路线 POI 数据模型
class TrailPoi {
  final String id;
  final String name;
  final String? description;
  final double lat;
  final double lng;
  final String type;
  final int order;

  TrailPoi({
    required this.id,
    required this.name,
    this.description,
    required this.lat,
    required this.lng,
    required this.type,
    required this.order,
  });

  factory TrailPoi.fromJson(Map<string, dynamic> json) {
    return TrailPoi(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}

/// 路线服务
class TrailService {
  static final TrailService _instance = TrailService._internal();
  factory TrailService() => _instance;
  TrailService._internal();

  final ApiClient _apiClient = ApiClient();

  /// 获取路线列表
  Future<List<Trail>> getTrails({
    String? keyword,
    String? city,
    String? district,
    String? difficulty,
    String? tag,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.trails,
      queryParams: {
        if (keyword != null) 'keyword': keyword,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (difficulty != null) 'difficulty': difficulty,
        if (tag != null) 'tag': tag,
        'page': page.toString(),
        'limit': limit.toString(),
      },
      parser: (data) => (data as List).map((e) => Trail.fromJson(e)).toList(),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '获取路线列表失败',
      code: response.errorCode,
    );
  }

  /// 获取路线详情
  Future<TrailDetail> getTrailDetail(String trailId) async {
    final response = await _apiClient.get(
      ApiEndpoints.trailDetail(trailId),
      parser: (data) => TrailDetail.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '获取路线详情失败',
      code: response.errorCode,
    );
  }

  /// 获取推荐路线
  Future<List<Trail>> getRecommendedTrails({int limit = 10}) async {
    final response = await _apiClient.get(
      ApiEndpoints.recommendedTrails,
      queryParams: {'limit': limit.toString()},
      parser: (data) => (data as List).map((e) => Trail.fromJson(e)).toList(),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '获取推荐路线失败',
      code: response.errorCode,
    );
  }

  /// 获取附近路线
  Future<List<Trail>> getNearbyTrails({
    required double lat,
    required double lng,
    double radius = 10,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.nearbyTrails,
      queryParams: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
      },
      parser: (data) => (data as List).map((e) => Trail.fromJson(e)).toList(),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '获取附近路线失败',
      code: response.errorCode,
    );
  }
}
