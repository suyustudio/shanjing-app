/**
 * 收藏服务
 * 
 * 提供用户收藏相关的 API 调用
 */

import 'api_client.dart';
import 'api_config.dart';

/// 收藏数据模型
class Favorite {
  final String id;
  final String trailId;
  final String trailName;
  final String coverImage;
  final double distanceKm;
  final int durationMin;
  final String difficulty;
  final String city;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.trailId,
    required this.trailName,
    required this.coverImage,
    required this.distanceKm,
    required this.durationMin,
    required this.difficulty,
    required this.city,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<string, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      trailId: json['trailId'] ?? '',
      trailName: json['trailName'] ?? '',
      coverImage: json['coverImage'] ?? '',
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      durationMin: json['durationMin'] ?? 0,
      difficulty: json['difficulty'] ?? 'EASY',
      city: json['city'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

/// 收藏操作结果
class FavoriteResult {
  final bool success;
  final bool isFavorited;
  final int favoriteCount;
  final String message;

  FavoriteResult({
    required this.success,
    required this.isFavorited,
    required this.favoriteCount,
    required this.message,
  });

  factory FavoriteResult.fromJson(Map<string, dynamic> json) {
    return FavoriteResult(
      success: json['success'] ?? false,
      isFavorited: json['isFavorited'] ?? false,
      favoriteCount: json['favoriteCount'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

/// 收藏状态
class FavoriteStatus {
  final bool isFavorited;
  final int favoriteCount;

  FavoriteStatus({
    required this.isFavorited,
    required this.favoriteCount,
  });

  factory FavoriteStatus.fromJson(Map<string, dynamic> json) {
    return FavoriteStatus(
      isFavorited: json['isFavorited'] ?? false,
      favoriteCount: json['favoriteCount'] ?? 0,
    );
  }
}

/// 收藏服务
class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final ApiClient _apiClient = ApiClient();

  /// 获取用户收藏列表
  Future<List<Favorite>> getFavorites({int page = 1, int limit = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.favorites,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      parser: (data) => (data as List).map((e) => Favorite.fromJson(e)).toList(),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '获取收藏列表失败',
      code: response.errorCode,
    );
  }

  /// 添加收藏
  Future<FavoriteResult> addFavorite(String trailId) async {
    final response = await _apiClient.post(
      ApiEndpoints.favorites,
      body: {'trailId': trailId},
      parser: (data) => FavoriteResult.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '收藏失败',
      code: response.errorCode,
    );
  }

  /// 取消收藏
  Future<FavoriteResult> removeFavorite(String trailId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.removeFavorite(trailId),
      parser: (data) => FavoriteResult.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '取消收藏失败',
      code: response.errorCode,
    );
  }

  /// 切换收藏状态
  /// 如果已收藏则取消，未收藏则添加
  Future<FavoriteResult> toggleFavorite(String trailId) async {
    final response = await _apiClient.post(
      ApiEndpoints.toggleFavorite,
      body: {'trailId': trailId},
      parser: (data) => FavoriteResult.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '操作失败',
      code: response.errorCode,
    );
  }

  /// 检查收藏状态
  Future<FavoriteStatus> checkFavoriteStatus(String trailId) async {
    final response = await _apiClient.get(
      ApiEndpoints.favoriteStatus(trailId),
      parser: (data) => FavoriteStatus.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '获取收藏状态失败',
      code: response.errorCode,
    );
  }
}
