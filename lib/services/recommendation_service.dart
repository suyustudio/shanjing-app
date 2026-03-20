// ================================================================
// 推荐服务 (Enhanced with Timeout & Retry)
// ================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../constants/achievement_constants.dart';
import '../models/recommendation_model.dart';
import 'auth_service.dart';

/// 推荐服务
class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final RetryableHttpClient _client = RetryableHttpClient();
  final AuthService _authService = AuthService();

  /// 缓存
  RecommendationsResponse? _cachedResponse;
  DateTime? _cacheTime;
  static const Duration _cacheValidity = CacheTtl.medium;

  // ============ 工具方法 ============

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _authService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<ApiResponse<Map<String, dynamic>>?>> _get(
    String url, {
    Map<String, String>? queryParams,
    Duration? timeout,
  }) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client.get(
        uri,
        headers: _getHeaders(),
        timeout: timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(data, statusCode: response.statusCode);
      }
      return ApiResponse.error(
        'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on TimeoutException catch (e) {
      debugPrint('GET请求超时: $e');
      return ApiResponse.error('请求超时', statusCode: 408);
    } on NetworkException catch (e) {
      debugPrint('GET请求网络错误: $e');
      return ApiResponse.error('网络连接失败', statusCode: 0);
    } catch (e) {
      debugPrint('GET请求失败: $e');
      return ApiResponse.error('请求失败: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>?>> _post(
    String url, {
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
        timeout: timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(data, statusCode: response.statusCode);
      }
      return ApiResponse.error(
        'HTTP ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on TimeoutException catch (e) {
      debugPrint('POST请求超时: $e');
      return ApiResponse.error('请求超时', statusCode: 408);
    } on NetworkException catch (e) {
      debugPrint('POST请求网络错误: $e');
      return ApiResponse.error('网络连接失败', statusCode: 0);
    } catch (e) {
      debugPrint('POST请求失败: $e');
      return ApiResponse.error('请求失败: $e');
    }
  }

  // ============ 推荐获取 ============

  /// 获取首页推荐
  Future<List<RecommendedTrail>> getHomeRecommendations({
    int limit = ValidationConstraints.defaultLimit,
    double? lat,
    double? lng,
  }) async {
    return _getRecommendations(
      scene: RecommendationScene.home,
      limit: limit,
      lat: lat,
      lng: lng,
    );
  }

  /// 获取附近推荐
  Future<List<RecommendedTrail>> getNearbyRecommendations({
    required double lat,
    required double lng,
    int limit = ValidationConstraints.defaultLimit,
  }) async {
    return _getRecommendations(
      scene: RecommendationScene.nearby,
      limit: limit,
      lat: lat,
      lng: lng,
    );
  }

  /// 获取相似路线推荐
  Future<List<RecommendedTrail>> getSimilarTrails({
    required String trailId,
    int limit = 5,
  }) async {
    return _getRecommendations(
      scene: RecommendationScene.similar,
      limit: limit,
      referenceTrailId: trailId,
    );
  }

  /// 获取推荐（通用方法）
  Future<List<RecommendedTrail>> _getRecommendations({
    required RecommendationScene scene,
    int limit = ValidationConstraints.defaultLimit,
    double? lat,
    double? lng,
    String? referenceTrailId,
    bool useCache = true,
  }) async {
    // 检查缓存
    if (useCache &&
        _cachedResponse != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheValidity) {
      return _cachedResponse!.trails;
    }

    final queryParams = <String, String>{
      'scene': scene.name,
      'limit': limit.toString(),
    };

    if (lat != null) queryParams['lat'] = lat.toString();
    if (lng != null) queryParams['lng'] = lng.toString();
    if (referenceTrailId != null) {
      queryParams['referenceTrailId'] = referenceTrailId;
    }

    final response = await _get(
      '${ApiConfig.apiBaseUrl}/recommendations',
      queryParams: queryParams,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      if (data['success'] == true && data['data'] != null) {
        final recommendationData = RecommendationsResponse.fromJson(data['data']);

        // 缓存结果
        _cachedResponse = recommendationData;
        _cacheTime = DateTime.now();

        return recommendationData.trails;
      }
    }

    return [];
  }

  /// 刷新推荐
  Future<List<RecommendedTrail>> refreshRecommendations({
    RecommendationScene scene = RecommendationScene.home,
    int limit = ValidationConstraints.defaultLimit,
    double? lat,
    double? lng,
  }) async {
    _clearCache();
    return _getRecommendations(
      scene: scene,
      limit: limit,
      lat: lat,
      lng: lng,
      useCache: false,
    );
  }

  // ============ 反馈追踪 ============

  /// 记录用户点击
  Future<void> trackClick({
    required String trailId,
    String? logId,
    int? durationSec,
  }) async {
    return _sendFeedback(
      action: UserAction.click,
      trailId: trailId,
      logId: logId,
      durationSec: durationSec,
    );
  }

  /// 记录用户收藏
  Future<void> trackBookmark({
    required String trailId,
    String? logId,
  }) async {
    return _sendFeedback(
      action: UserAction.bookmark,
      trailId: trailId,
      logId: logId,
    );
  }

  /// 记录用户完成
  Future<void> trackComplete({
    required String trailId,
    String? logId,
    int? durationSec,
  }) async {
    return _sendFeedback(
      action: UserAction.complete,
      trailId: trailId,
      logId: logId,
      durationSec: durationSec,
    );
  }

  /// 记录推荐曝光事件
  Future<bool> trackImpression({
    required List<String> trailIds,
    required RecommendationScene scene,
    String? logId,
  }) async {
    if (trailIds.isEmpty) return false;

    final body = <String, dynamic>{
      'scene': scene.name,
      'trailIds': trailIds,
      'timestamp': DateTime.now().toIso8601String(),
      if (logId != null) 'logId': logId,
    };

    final response = await _post(
      '${ApiConfig.apiBaseUrl}/recommendations/impression',
      body: body,
    );

    return response.success && response.data?['success'] == true;
  }

  /// 发送反馈（通用方法）
  Future<void> _sendFeedback({
    required UserAction action,
    required String trailId,
    String? logId,
    int? durationSec,
  }) async {
    final body = <String, dynamic>{
      'action': action.name,
      'trailId': trailId,
      if (logId != null) 'logId': logId,
      if (durationSec != null) 'durationSec': durationSec,
    };

    await _post(
      '${ApiConfig.apiBaseUrl}/recommendations/feedback',
      body: body,
    );

    // 清除用户推荐缓存
    await clearCache();
  }

  // ============ 缓存管理 ============

  void _clearCache() {
    _cachedResponse = null;
    _cacheTime = null;
  }

  /// 清除推荐缓存
  void clearCache() => _clearCache();

  /// 获取缓存的日志ID（用于追踪）
  String? getCachedLogId() => _cachedResponse?.logId;
  
  /// 关闭客户端
  void dispose() {
    _client.close();
  }
}
