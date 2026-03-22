// tag_service.dart
// 山径APP - 标签服务（M7 P1）
// 管理与后端API的标签相关操作，支持本地缓存

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../services/api_config.dart';
import '../models/collection_tag.dart';
import '../models/collection_enhanced_model.dart';

/// 标签服务
class TagService {
  final ApiClient _apiClient = ApiClient();
  final Map<String, CollectionTag> _tagCache = {};
  final Map<String, List<CollectionTag>> _collectionTagsCache = {};
  DateTime? _lastCacheUpdate;

  /// 获取所有标签（从缓存或API）
  Future<List<CollectionTag>> getAllTags({bool forceRefresh = false}) async {
    // 检查缓存是否有效（5分钟）
    final cacheValid = _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) <
            const Duration(minutes: 5);
    
    if (_tagCache.isNotEmpty && cacheValid && !forceRefresh) {
      return _tagCache.values.toList();
    }

    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.collections}/tags',
        parser: (data) {
          if (data is List) {
            return data.map((e) => CollectionTag.fromJson(e)).toList();
          }
          return <CollectionTag>[];
        },
      );

      if (response.success && response.data != null) {
        // 更新缓存
        _tagCache.clear();
        for (final tag in response.data!) {
          _tagCache[tag.id] = tag;
        }
        _lastCacheUpdate = DateTime.now();
        return response.data!;
      }
    } catch (e) {
      if (kDebugMode) {
        print('获取标签失败: $e');
      }
    }

    // API失败时返回缓存数据（如果有）
    return _tagCache.values.toList();
  }

  /// 获取收藏夹的标签
  Future<List<CollectionTag>> getCollectionTags(
    String collectionId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _collectionTagsCache.containsKey(collectionId)) {
      return _collectionTagsCache[collectionId]!;
    }

    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.collectionDetail(collectionId)}/tags',
        parser: (data) {
          if (data is List) {
            return data.map((e) => CollectionTag.fromJson(e)).toList();
          }
          return <CollectionTag>[];
        },
      );

      if (response.success && response.data != null) {
        _collectionTagsCache[collectionId] = response.data!;
        return response.data!;
      }
    } catch (e) {
      if (kDebugMode) {
        print('获取收藏夹标签失败: $e');
      }
    }

    return [];
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
      // 清除相关缓存
      _collectionTagsCache.remove(collectionId);
      _lastCacheUpdate = null;
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '更新标签失败',
      code: response.errorCode,
    );
  }

  /// 创建新标签
  Future<CollectionTag> createTag({
    required String name,
    Color? color,
  }) async {
    final tagColor = color ?? CollectionTag._generateColor(name);
    
    final response = await _apiClient.post(
      '${ApiEndpoints.collections}/tags',
      body: {
        'name': name,
        'color': tagColor.value.toRadixString(16).padLeft(8, '0'),
      },
      parser: (data) {
        if (data['data'] != null) {
          return CollectionTag.fromJson(data['data']);
        }
        return null;
      },
    );

    if (response.success && response.data != null) {
      // 更新缓存
      _tagCache[response.data!.id] = response.data!;
      _lastCacheUpdate = null;
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '创建标签失败',
      code: response.errorCode,
    );
  }

  /// 删除标签
  Future<bool> deleteTag(String tagId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.collections}/tags/$tagId',
    );

    if (response.success) {
      // 从缓存中移除
      _tagCache.remove(tagId);
      _lastCacheUpdate = null;
      // 清除所有收藏夹的标签缓存（因为可能包含已删除的标签）
      _collectionTagsCache.clear();
      return true;
    }

    throw ApiException(
      message: response.errorMessage ?? '删除标签失败',
      code: response.errorCode,
    );
  }

  /// 搜索标签
  Future<List<CollectionTag>> searchTags(String query) async {
    if (query.isEmpty) {
      return getAllTags();
    }

    final allTags = await getAllTags();
    final lowerQuery = query.toLowerCase();
    
    return allTags.where((tag) {
      return tag.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 获取热门标签（按使用次数排序）
  Future<List<CollectionTag>> getPopularTags({int limit = 10}) async {
    final allTags = await getAllTags();
    allTags.sort((a, b) => b.count.compareTo(a.count));
    return allTags.take(limit).toList();
  }

  /// 获取标签统计信息
  Future<TagStatistics> getTagStatistics() async {
    final allTags = await getAllTags();
    return TagStatistics.fromTags(allTags);
  }

  /// 批量处理标签（字符串数组转CollectionTag数组）
  List<CollectionTag> convertStringTags(List<String> tags) {
    return tags.map((tag) => CollectionTag.fromString(tag)).toList();
  }

  /// 从CollectionTag数组提取标签名
  List<String> extractTagNames(List<CollectionTag> tags) {
    return tags.map((tag) => tag.name).toList();
  }

  /// 清除所有缓存
  void clearCache() {
    _tagCache.clear();
    _collectionTagsCache.clear();
    _lastCacheUpdate = null;
  }
}

/// API端点扩展（标签相关）
class TagApiEndpoints {
  static String get collectionTags => '${ApiEndpoints.collections}/tags';
  static String collectionTagDetail(String tagId) =>
      '${ApiEndpoints.collections}/tags/$tagId';
  static String collectionTagSearch(String collectionId) =>
      '${ApiEndpoints.collectionDetail(collectionId)}/tags/search';
}