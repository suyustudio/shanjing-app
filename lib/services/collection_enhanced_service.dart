// collection_enhanced_service.dart
// 山径APP - 增强版收藏夹服务（M7 P1）
// 扩展原有服务，添加批量操作和搜索筛选功能

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_client.dart';
import 'api_config.dart';
import '../models/collection_enhanced_model.dart';
import 'collection_service.dart';

/// 增强版收藏夹服务
class CollectionEnhancedService {
  final ApiClient _apiClient = ApiClient();
  final CollectionService _collectionService = CollectionService();
  final Connectivity _connectivity = Connectivity();

  /// 检查网络连接
  Future<bool> _checkNetworkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // 如果检查失败，假设有网络，让API调用自然失败
      return true;
    }
  }

  /// 执行带有重试的API调用
  Future<ApiResponse<T>> _executeWithRetry<T>(
    Future<ApiResponse<T>> Function() apiCall,
    {int maxRetries = 2, Duration retryDelay = const Duration(seconds: 1)}
  ) async {
    ApiResponse<T>? lastResponse;
    Exception? lastException;
    
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await apiCall();
        lastResponse = response;
        
        // 如果成功，直接返回
        if (response.success) {
          return response;
        }
        
        // 如果是服务器错误且可重试（5xx），则重试
        if (response.errorCode?.startsWith('5') == true && attempt < maxRetries) {
          await Future.delayed(retryDelay * (attempt + 1));
          continue;
        }
        
        // 其他错误不重试
        return response;
      } on ApiException catch (e) {
        lastException = e;
        
        // 如果是网络错误且可重试，则重试
        if (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT') {
          if (attempt < maxRetries) {
            await Future.delayed(retryDelay * (attempt + 1));
            continue;
          }
        }
        
        // 其他异常或达到重试次数上限，抛出异常
        rethrow;
      } catch (e) {
        lastException = e as Exception;
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay * (attempt + 1));
          continue;
        }
        rethrow;
      }
    }
    
    // 理论上不会执行到这里
    throw lastException ?? Exception('API调用失败，达到最大重试次数');
  }

  /// 检查是否是权限错误
  bool _isPermissionError(ApiException e) {
    return e.statusCode == 403 || 
           e.code?.contains('FORBIDDEN') == true ||
           e.code?.contains('PERMISSION') == true ||
           e.message.toLowerCase().contains('permission') ||
           e.message.toLowerCase().contains('forbidden') ||
           e.message.toLowerCase().contains('无权') ||
           e.message.toLowerCase().contains('权限');
  }

  // ==================== 批量操作 ====================

  /// 批量添加路线到收藏夹
  Future<BatchOperationResult> batchAddTrailsToCollection({
    required String collectionId,
    required List<String> trailIds,
    String? note,
  }) async {
    // 1. 基本验证
    if (trailIds.isEmpty) {
      return BatchOperationResult(
        success: true,
        message: '没有需要添加的路线',
        successCount: 0,
        totalCount: 0,
      );
    }

    // 2. 批量大小限制
    const maxBatchSize = 100;
    if (trailIds.length > maxBatchSize) {
      return BatchOperationResult(
        success: false,
        message: '单次批量操作不能超过 $maxBatchSize 条路线',
        successCount: 0,
        totalCount: trailIds.length,
      );
    }

    // 3. 网络连接检查
    final hasNetwork = await _checkNetworkConnectivity();
    if (!hasNetwork) {
      return BatchOperationResult(
        success: false,
        message: '网络连接不可用，请检查网络设置',
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    }

    try {
      // 4. 执行API调用（带重试）
      final response = await _executeWithRetry<BatchOperationResult>(
        () => _apiClient.post(
          '${ApiEndpoints.collectionDetail(collectionId)}/trails/batch',
          body: BatchAddTrailsRequest(trailIds: trailIds, note: note).toJson(),
          parser: (data) => BatchOperationResult.fromJson(data),
        ),
        maxRetries: 2,
        retryDelay: Duration(seconds: 1),
      );

      if (response.success && response.data != null) {
        // 清除缓存
        _collectionService.clearCache();
        return response.data!;
      }

      // API返回业务错误（如部分失败）
      return BatchOperationResult(
        success: false,
        message: response.errorMessage ?? '批量添加失败',
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    } on ApiException catch (e) {
      // 检查权限错误
      if (_isPermissionError(e)) {
        return BatchOperationResult(
          success: false,
          message: '您没有权限修改此收藏夹',
          successCount: 0,
          totalCount: trailIds.length,
          failedIds: trailIds,
        );
      }
      // 其他网络或API异常
      return BatchOperationResult(
        success: false,
        message: e.message,
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    } catch (e) {
      // 其他未知异常
      return BatchOperationResult(
        success: false,
        message: '操作失败: $e',
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    }
  }

  /// 批量从收藏夹移除路线
  Future<BatchOperationResult> batchRemoveTrailsFromCollection({
    required String collectionId,
    required List<String> trailIds,
  }) async {
    // 1. 基本验证
    if (trailIds.isEmpty) {
      return BatchOperationResult(
        success: true,
        message: '没有需要移除的路线',
        successCount: 0,
        totalCount: 0,
      );
    }

    // 2. 批量大小限制
    const maxBatchSize = 100;
    if (trailIds.length > maxBatchSize) {
      return BatchOperationResult(
        success: false,
        message: '单次批量操作不能超过 $maxBatchSize 条路线',
        successCount: 0,
        totalCount: trailIds.length,
      );
    }

    // 3. 网络连接检查
    final hasNetwork = await _checkNetworkConnectivity();
    if (!hasNetwork) {
      return BatchOperationResult(
        success: false,
        message: '网络连接不可用，请检查网络设置',
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    }

    try {
      // 4. 执行API调用（带重试）
      final response = await _executeWithRetry<BatchOperationResult>(
        () => _apiClient.delete(
          '${ApiEndpoints.collectionDetail(collectionId)}/trails/batch',
          body: {'trailIds': trailIds},
          parser: (data) => BatchOperationResult.fromJson(data),
        ),
        maxRetries: 2,
        retryDelay: Duration(seconds: 1),
      );

      if (response.success && response.data != null) {
        // 清除缓存
        _collectionService.clearCache();
        return response.data!;
      }

      // API返回业务错误
      return BatchOperationResult(
        success: false,
        message: response.errorMessage ?? '批量移除失败',
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    } on ApiException catch (e) {
      // 检查权限错误
      if (_isPermissionError(e)) {
        return BatchOperationResult(
          success: false,
          message: '您没有权限修改此收藏夹',
          successCount: 0,
          totalCount: trailIds.length,
          failedIds: trailIds,
        );
      }
      // 其他网络或API异常
      return BatchOperationResult(
        success: false,
        message: e.message,
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    } catch (e) {
      // 其他未知异常
      return BatchOperationResult(
        success: false,
        message: '操作失败: $e',
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    }
  }

  /// 批量移动路线到其他收藏夹
  Future<BatchOperationResult> batchMoveTrails({
    required String sourceCollectionId,
    required String targetCollectionId,
    required List<String> trailIds,
  }) async {
    // 1. 基本验证
    if (trailIds.isEmpty) {
      return BatchOperationResult(
        success: true,
        message: '没有需要移动的路线',
        successCount: 0,
        totalCount: 0,
      );
    }

    // 2. 批量大小限制
    const maxBatchSize = 100;
    if (trailIds.length > maxBatchSize) {
      return BatchOperationResult(
        success: false,
        message: '单次批量操作不能超过 $maxBatchSize 条路线',
        successCount: 0,
        totalCount: trailIds.length,
      );
    }

    // 3. 网络连接检查
    final hasNetwork = await _checkNetworkConnectivity();
    if (!hasNetwork) {
      return BatchOperationResult(
        success: false,
        message: '网络连接不可用，请检查网络设置',
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    }

    try {
      // 4. 执行API调用（带重试）
      final response = await _executeWithRetry<BatchOperationResult>(
        () => _apiClient.post(
          '${ApiEndpoints.collectionDetail(sourceCollectionId)}/trails/move',
          body: {
            'trailIds': trailIds,
            'targetCollectionId': targetCollectionId,
          },
          parser: (data) => BatchOperationResult.fromJson(data),
        ),
        maxRetries: 2,
        retryDelay: Duration(seconds: 1),
      );

      if (response.success && response.data != null) {
        // 清除缓存（影响两个收藏夹）
        _collectionService.clearCache();
        return response.data!;
      }

      // API返回业务错误
      return BatchOperationResult(
        success: false,
        message: response.errorMessage ?? '批量移动失败',
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    } on ApiException catch (e) {
      // 检查权限错误
      if (_isPermissionError(e)) {
        return BatchOperationResult(
          success: false,
          message: '您没有权限修改此收藏夹',
          successCount: 0,
          totalCount: trailIds.length,
          failedIds: trailIds,
        );
      }
      // 其他网络或API异常
      return BatchOperationResult(
        success: false,
        message: e.message,
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    } catch (e) {
      // 其他未知异常
      return BatchOperationResult(
        success: false,
        message: '操作失败: $e',
        successCount: 0,
        totalCount: trailIds.length,
        failedIds: trailIds,
      );
    }
  }

  /// 批量删除收藏夹
  Future<BatchOperationResult> batchDeleteCollections({
    required List<String> collectionIds,
  }) async {
    // 1. 基本验证
    if (collectionIds.isEmpty) {
      return BatchOperationResult(
        success: true,
        message: '没有需要删除的收藏夹',
        successCount: 0,
        totalCount: 0,
      );
    }

    // 2. 批量大小限制
    const maxBatchSize = 50;
    if (collectionIds.length > maxBatchSize) {
      return BatchOperationResult(
        success: false,
        message: '单次批量操作不能超过 $maxBatchSize 个收藏夹',
        successCount: 0,
        totalCount: collectionIds.length,
      );
    }

    // 3. 网络连接检查
    final hasNetwork = await _checkNetworkConnectivity();
    if (!hasNetwork) {
      return BatchOperationResult(
        success: false,
        message: '网络连接不可用，请检查网络设置',
        successCount: 0,
        totalCount: collectionIds.length,
        failedIds: collectionIds,
      );
    }

    try {
      // 4. 执行API调用（带重试）
      final response = await _executeWithRetry<BatchOperationResult>(
        () => _apiClient.delete(
          '${ApiEndpoints.collections}/batch',
          body: {'collectionIds': collectionIds},
          parser: (data) => BatchOperationResult.fromJson(data),
        ),
        maxRetries: 2,
        retryDelay: Duration(seconds: 1),
      );

      if (response.success && response.data != null) {
        // 清除缓存
        _collectionService.clearCache();
        return response.data!;
      }

      // API返回业务错误
      return BatchOperationResult(
        success: false,
        message: response.errorMessage ?? '批量删除失败',
        successCount: 0,
        totalCount: collectionIds.length,
        failedIds: collectionIds,
      );
    } on ApiException catch (e) {
      // 检查权限错误
      if (_isPermissionError(e)) {
        return BatchOperationResult(
          success: false,
          message: '您没有权限修改此收藏夹',
          successCount: 0,
          totalCount: collectionIds.length,
          failedIds: collectionIds,
        );
      }
      // 其他网络或API异常
      return BatchOperationResult(
        success: false,
        message: e.message,
        successCount: 0,
        totalCount: collectionIds.length,
        failedIds: collectionIds,
      );
    } catch (e) {
      // 其他未知异常
      return BatchOperationResult(
        success: false,
        message: '操作失败: $e',
        successCount: 0,
        totalCount: collectionIds.length,
        failedIds: collectionIds,
      );
    }
  }

  // ==================== 搜索筛选 ====================

  /// 搜索收藏夹（带筛选条件）
  Future<List<EnhancedCollection>> searchCollections({
    required CollectionSearchFilter filter,
    String? userId,
    bool forceRefresh = false,
  }) async {
    // 构建查询参数
    final queryParams = filter.toQueryParams();
    if (userId != null) {
      queryParams['userId'] = userId;
    }

    final response = await _apiClient.get(
      ApiEndpoints.collections,
      queryParams: queryParams,
      parser: (data) {
        if (data is List) {
          return data.map((e) => EnhancedCollection.fromJson(e)).toList();
        }
        if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => EnhancedCollection.fromJson(e))
              .toList();
        }
        return <EnhancedCollection>[];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '搜索收藏夹失败',
      code: response.errorCode,
    );
  }

  /// 在收藏夹内搜索路线
  Future<List<CollectionTrail>> searchTrailsInCollection({
    required String collectionId,
    required CollectionTrailSearchFilter filter,
  }) async {
    // 构建查询参数，映射到后端期望的字段名
    final queryParams = <String, String>{};
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      queryParams['q'] = filter.searchQuery!;
    }
    if (filter.difficulties != null && filter.difficulties!.isNotEmpty) {
      queryParams['difficulty'] = filter.difficulties!.join(',');
    }
    if (filter.minDistance != null) {
      queryParams['minDistance'] = filter.minDistance!.toString();
    }
    if (filter.maxDistance != null) {
      queryParams['maxDistance'] = filter.maxDistance!.toString();
    }
    if (filter.minDuration != null) {
      queryParams['minDuration'] = filter.minDuration!.toString();
    }
    if (filter.maxDuration != null) {
      queryParams['maxDuration'] = filter.maxDuration!.toString();
    }
    if (filter.sortBy != null) {
      queryParams['sort'] = filter.sortBy!;
    }
    queryParams['page'] = filter.page.toString();
    queryParams['limit'] = filter.limit.toString();

    final response = await _apiClient.get(
      '${ApiEndpoints.collectionDetail(collectionId)}/search',
      queryParams: queryParams,
      parser: (data) {
        // 后端返回的是CollectionDetailDto，我们需要提取trails
        if (data is Map && data['data'] is Map && data['data']['trails'] is List) {
          return (data['data']['trails'] as List)
              .map((e) => CollectionTrail.fromJson(e))
              .toList();
        }
        return <CollectionTrail>[];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '搜索路线失败',
      code: response.errorCode,
    );
  }

  // ==================== 标签管理 ====================

  /// 获取所有收藏夹标签（去重）
  Future<List<String>> getAllCollectionTags({String? userId}) async {
    final collections = await _collectionService.getCollections(
      userId: userId,
      forceRefresh: true,
    );

    final allTags = <String>{};
    for (final collection in collections) {
      // 注意：这里需要API返回tags字段，暂时使用空列表
      // 实际实现需要后端支持
      if (collection is EnhancedCollection) {
        allTags.addAll(collection.tags);
      }
    }

    return allTags.toList()..sort();
  }

  /// 更新收藏夹标签
  Future<EnhancedCollection> updateCollectionTags({
    required String collectionId,
    required List<String> tags,
  }) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.collectionDetail(collectionId)}/tags',
      body: {'tags': tags},
      parser: (data) {
        if (data['data'] != null) {
          return EnhancedCollection.fromJson(data['data']);
        }
        return null;
      },
    );

    if (response.success && response.data != null) {
      // 清除缓存
      _collectionService.clearCache();
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '更新标签失败',
      code: response.errorCode,
    );
  }

  /// 批量添加标签到路线
  Future<BatchOperationResult> batchAddTagsToTrails({
    required String collectionId,
    required List<String> trailIds,
    required List<String> tagIds,
  }) async {
    if (trailIds.isEmpty || tagIds.isEmpty) {
      return BatchOperationResult(
        success: true,
        message: trailIds.isEmpty ? '没有需要添加标签的路线' : '没有需要添加的标签',
        successCount: 0,
        totalCount: trailIds.length,
      );
    }

    const maxBatchSize = 100;
    if (trailIds.length > maxBatchSize) {
      return BatchOperationResult(
        success: false,
        message: '单次批量操作不能超过 $maxBatchSize 条路线',
        successCount: 0,
        totalCount: trailIds.length,
      );
    }

    final response = await _apiClient.post(
      ApiEndpointsEnhanced.collectionTrailsBatchTags(collectionId),
      body: BatchAddTagsRequest(trailIds: trailIds, tagIds: tagIds).toJson(),
      parser: (data) => BatchOperationResult.fromJson(data),
    );

    if (response.success && response.data != null) {
      // 清除缓存
      _collectionService.clearCache();
      return response.data!;
    }

    return BatchOperationResult(
      success: false,
      message: response.errorMessage ?? '批量添加标签失败',
      successCount: 0,
      totalCount: trailIds.length,
    );
  }

  /// 批量从路线移除标签
  Future<BatchOperationResult> batchRemoveTagsFromTrails({
    required String collectionId,
    required List<String> trailIds,
    required List<String> tagIds,
  }) async {
    if (trailIds.isEmpty || tagIds.isEmpty) {
      return BatchOperationResult(
        success: true,
        message: trailIds.isEmpty ? '没有需要移除标签的路线' : '没有需要移除的标签',
        successCount: 0,
        totalCount: trailIds.length,
      );
    }

    const maxBatchSize = 100;
    if (trailIds.length > maxBatchSize) {
      return BatchOperationResult(
        success: false,
        message: '单次批量操作不能超过 $maxBatchSize 条路线',
        successCount: 0,
        totalCount: trailIds.length,
      );
    }

    final response = await _apiClient.delete(
      ApiEndpointsEnhanced.collectionTrailsBatchTags(collectionId),
      body: BatchRemoveTagsRequest(trailIds: trailIds, tagIds: tagIds).toJson(),
      parser: (data) => BatchOperationResult.fromJson(data),
    );

    if (response.success && response.data != null) {
      // 清除缓存
      _collectionService.clearCache();
      return response.data!;
    }

    return BatchOperationResult(
      success: false,
      message: response.errorMessage ?? '批量移除标签失败',
      successCount: 0,
      totalCount: trailIds.length,
    );
  }

  // ==================== 工具方法 ====================

  /// 检查批量操作是否可用
  bool isBatchOperationAvailable() {
    // 检查API是否支持批量操作
    // 可以添加版本检查或特性标志
    return true;
  }

  /// 获取推荐标签（基于用户现有收藏夹）
  Future<List<String>> getSuggestedTags({String? userId}) async {
    final allTags = await getAllCollectionTags(userId: userId);
    
    // 简单的推荐逻辑：返回最常用的标签
    final tagFrequency = <String, int>{};
    // TODO: 实现标签频率统计
    
    // 临时返回一些示例标签
    return [
      '工作',
      '旅行',
      '周末',
      '家庭',
      '运动',
      '探索',
      '摄影',
      '放松',
    ].where((tag) => !allTags.contains(tag)).take(5).toList();
  }
}

/// API端点扩展
class ApiEndpointsEnhanced {
  // 批量操作端点（需要在后端实现）
  static String collectionTrailsBatch(String collectionId) =>
      '${ApiEndpoints.collectionDetail(collectionId)}/trails/batch';
  
  static String collectionBatchMove = '${ApiEndpoints.collections}/batch-move';
  
  static String collectionsBatch = '${ApiEndpoints.collections}/batch';
  
  static String collectionTags(String collectionId) =>
      '${ApiEndpoints.collectionDetail(collectionId)}/tags';
  
  // 批量标签操作端点
  static String collectionTrailsBatchTags(String collectionId) =>
      '${ApiEndpoints.collectionDetail(collectionId)}/trails/batch-tags';
}
