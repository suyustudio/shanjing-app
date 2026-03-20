// collection_service.dart
// 山径APP - 收藏夹服务

import 'dart:convert';
import 'api_client.dart';
import 'api_config.dart';
import '../models/collection_model.dart';

/// 收藏夹操作结果
class CollectionResult {
  final bool success;
  final String message;
  final Collection? collection;
  final Map<String, dynamic>? data;

  CollectionResult({
    required this.success,
    this.message = '',
    this.collection,
    this.data,
  });
}

/// 用户收藏夹缓存
class _UserCollectionCache {
  final List<Collection> collections;
  final DateTime cacheTime;

  _UserCollectionCache({
    required this.collections,
    required this.cacheTime,
  });
}

/// 收藏夹服务
class CollectionService {
  static final CollectionService _instance = CollectionService._internal();
  factory CollectionService() => _instance;
  CollectionService._internal();

  final ApiClient _apiClient = ApiClient();

  // ==================== 缓存 (支持多用户) ====================
  // 使用 Map 存储不同用户的缓存
  final Map<String, _UserCollectionCache> _userCaches = {};
  static const _cacheDuration = Duration(minutes: 5);

  /// 获取指定用户的缓存
  _UserCollectionCache? _getUserCache(String? userId) {
    final cacheKey = userId ?? '_current_user_';
    final cache = _userCaches[cacheKey];
    if (cache == null) return null;
    
    // 检查缓存是否过期
    if (DateTime.now().difference(cache.cacheTime) > _cacheDuration) {
      _userCaches.remove(cacheKey);
      return null;
    }
    return cache;
  }

  /// 设置用户缓存
  void _setUserCache(String? userId, List<Collection> collections) {
    final cacheKey = userId ?? '_current_user_';
    _userCaches[cacheKey] = _UserCollectionCache(
      collections: collections,
      cacheTime: DateTime.now(),
    );
  }

  /// 清除指定用户的缓存
  void clearUserCache({String? userId}) {
    if (userId != null) {
      _userCaches.remove(userId);
    } else {
      _userCaches.clear();
    }
  }

  // ==================== 收藏夹管理 ====================

  /// 获取收藏夹列表
  Future<List<Collection>> getCollections({String? userId, bool forceRefresh = false}) async {
    // 检查缓存（仅在非强制刷新时）
    if (!forceRefresh) {
      final cached = _getUserCache(userId);
      if (cached != null) {
        return cached.collections;
      }
    }

    final queryParams = userId != null ? {'userId': userId} : null;
    
    final response = await _apiClient.get(
      ApiEndpoints.collections,
      queryParams: queryParams,
      parser: (data) {
        if (data is List) {
          return data.map((e) => Collection.fromJson(e)).toList();
        }
        // 处理统一响应格式 {success, data}
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).map((e) => Collection.fromJson(e)).toList();
        }
        return <Collection>[];
      },
    );

    if (response.success && response.data != null) {
      _setUserCache(userId, response.data!);
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '获取收藏夹列表失败',
      code: response.errorCode,
    );
  }

  /// 清除缓存 (向后兼容)
  void clearCache() {
    clearUserCache();
  }

  /// 创建收藏夹
  Future<CollectionResult> createCollection({
    required String name,
    String? description,
    bool isPublic = true,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.collections,
      body: {
        'name': name,
        'description': description,
        'isPublic': isPublic,
      },
      parser: (data) {
        if (data['data'] != null) {
          return Collection.fromJson(data['data']);
        }
        return null;
      },
    );

    if (response.success && response.data != null) {
      clearCache(); // 清除缓存
      return CollectionResult(
        success: true,
        collection: response.data,
      );
    }
    
    return CollectionResult(
      success: false,
      message: response.errorMessage ?? '创建收藏夹失败',
    );
  }

  /// 更新收藏夹
  Future<CollectionResult> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (isPublic != null) body['isPublic'] = isPublic;

    final response = await _apiClient.put(
      ApiEndpoints.collectionDetail(collectionId),
      body: body,
      parser: (data) {
        if (data['data'] != null) {
          return Collection.fromJson(data['data']);
        }
        return null;
      },
    );

    if (response.success && response.data != null) {
      clearCache(); // 清除缓存
      return CollectionResult(
        success: true,
        collection: response.data,
      );
    }
    
    return CollectionResult(
      success: false,
      message: response.errorMessage ?? '更新收藏夹失败',
    );
  }

  /// 删除收藏夹
  Future<CollectionResult> deleteCollection(String collectionId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.collectionDetail(collectionId),
    );

    if (response.success) {
      clearCache(); // 清除缓存
      return CollectionResult(success: true);
    }
    
    return CollectionResult(
      success: false,
      message: response.errorMessage ?? '删除收藏夹失败',
    );
  }

  /// 获取收藏夹详情
  Future<CollectionDetail> getCollectionDetail(
    String collectionId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.collectionDetail(collectionId),
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      parser: (data) {
        if (data['data'] != null) {
          return CollectionDetail.fromJson(data['data']);
        }
        return null;
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    
    throw ApiException(
      message: response.errorMessage ?? '获取收藏夹详情失败',
      code: response.errorCode,
    );
  }

  // ==================== 路线管理 ====================

  /// 添加路线到收藏夹
  Future<CollectionResult> addTrailToCollection({
    required String collectionId,
    required String trailId,
    String? note,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.collectionTrails(collectionId),
      body: {
        'trailId': trailId,
        'note': note,
      },
    );

    if (response.success) {
      clearCache(); // 清除缓存
      return CollectionResult(
        success: true,
        data: response.data,
      );
    }
    
    return CollectionResult(
      success: false,
      message: response.errorMessage ?? '添加路线失败',
    );
  }

  /// 从收藏夹移除路线
  Future<CollectionResult> removeTrailFromCollection({
    required String collectionId,
    required String trailId,
  }) async {
    final response = await _apiClient.delete(
      ApiEndpoints.collectionTrailDetail(collectionId, trailId),
    );

    if (response.success) {
      clearCache(); // 清除缓存
      return CollectionResult(
        success: true,
        data: response.data,
      );
    }
    
    return CollectionResult(
      success: false,
      message: response.errorMessage ?? '移除路线失败',
    );
  }

  /// 排序收藏夹内路线
  Future<CollectionResult> sortTrailsInCollection({
    required String collectionId,
    required List<String> trailIds,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.collectionSort(collectionId),
      body: {'trailIds': trailIds},
    );

    if (response.success) {
      return CollectionResult(success: true);
    }
    
    return CollectionResult(
      success: false,
      message: response.errorMessage ?? '排序失败',
    );
  }

  // ==================== 快速收藏 ====================

  /// 快速收藏（添加到默认收藏夹）
  Future<QuickCollectResult> quickCollect(String trailId) async {
    final response = await _apiClient.post(
      ApiEndpoints.quickCollect(trailId),
    );

    if (response.success) {
      clearCache(); // 清除缓存
      return QuickCollectResult.fromJson(response.data ?? {});
    }
    
    throw ApiException(
      message: response.errorMessage ?? '快速收藏失败',
      code: response.errorCode,
    );
  }

  /// 检查路线是否在默认收藏夹中
  Future<bool> isQuickCollected(String trailId) async {
    try {
      final collections = await getCollections();
      final defaultCollection = collections.firstWhere(
        (c) => c.isDefault,
        orElse: () => throw Exception('No default collection'),
      );
      
      final detail = await getCollectionDetail(defaultCollection.id);
      return detail.trails.any((t) => t.trailId == trailId);
    } catch (e) {
      return false;
    }
  }

  /// 批量添加路线到收藏夹
  Future<CollectionResult> batchAddTrailsToCollection({
    required String collectionId,
    required List<String> trailIds,
  }) async {
    final results = <bool>[];
    
    for (final trailId in trailIds) {
      final result = await addTrailToCollection(
        collectionId: collectionId,
        trailId: trailId,
      );
      results.add(result.success);
    }
    
    final successCount = results.where((r) => r).length;
    
    return CollectionResult(
      success: successCount == trailIds.length,
      message: '成功添加 $successCount/${trailIds.length} 条路线',
    );
  }
}

/// 快速收藏结果
class QuickCollectResult {
  final bool isCollected;
  final String collectionId;

  QuickCollectResult({
    required this.isCollected,
    required this.collectionId,
  });

  factory QuickCollectResult.fromJson(Map<String, dynamic> json) {
    return QuickCollectResult(
      isCollected: json['isCollected'] ?? json['is_collected'] ?? false,
      collectionId: json['collectionId'] ?? json['collection_id'] ?? '',
    );
  }
}
