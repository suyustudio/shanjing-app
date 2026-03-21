// collection_enhanced_model.dart
// 山径APP - 增强版收藏夹数据模型（M7 P1）
// 扩展原有模型，添加分类标签和批量操作支持

import 'dart:convert';
import 'collection_model.dart';

/// 增强版收藏夹模型（扩展原有Collection模型）
class EnhancedCollection {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int trailCount;
  final bool isPublic;
  final bool isDefault;
  final int sortOrder;
  final List<String> tags; // 新增：分类标签
  final DateTime createdAt;
  final DateTime updatedAt;

  EnhancedCollection({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.trailCount,
    required this.isPublic,
    required this.isDefault,
    required this.sortOrder,
    this.tags = const [], // 默认空数组
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从原始Collection转换
  factory EnhancedCollection.fromCollection({
    required Collection collection,
    List<String> tags = const [],
  }) {
    return EnhancedCollection(
      id: collection.id,
      name: collection.name,
      description: collection.description,
      coverUrl: collection.coverUrl,
      trailCount: collection.trailCount,
      isPublic: collection.isPublic,
      isDefault: collection.isDefault,
      sortOrder: collection.sortOrder,
      tags: tags,
      createdAt: collection.createdAt,
      updatedAt: collection.updatedAt,
    );
  }

  /// 从JSON解析（API响应）
  factory EnhancedCollection.fromJson(Map<String, dynamic> json) {
    return EnhancedCollection(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      coverUrl: json['coverUrl'],
      trailCount: json['trailCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      isDefault: json['isDefault'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverUrl': coverUrl,
      'trailCount': trailCount,
      'isPublic': isPublic,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  EnhancedCollection copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    int? trailCount,
    bool? isPublic,
    bool? isDefault,
    int? sortOrder,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnhancedCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      trailCount: trailCount ?? this.trailCount,
      isPublic: isPublic ?? this.isPublic,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 检查是否包含指定标签
  bool hasTag(String tag) => tags.contains(tag);

  /// 添加标签（去重）
  EnhancedCollection withTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// 移除标签
  EnhancedCollection withoutTag(String tag) {
    if (!tags.contains(tag)) return this;
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// 批量设置标签
  EnhancedCollection withTags(List<String> newTags) {
    final uniqueTags = {...tags, ...newTags}.toList();
    return copyWith(tags: uniqueTags);
  }
}

/// 批量操作请求模型
class BatchOperationRequest {
  final List<String> ids;
  final Map<String, dynamic>? extraData;

  BatchOperationRequest({
    required this.ids,
    this.extraData,
  });

  factory BatchOperationRequest.fromJson(Map<String, dynamic> json) {
    return BatchOperationRequest(
      ids: (json['ids'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      extraData: json['extraData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ids': ids,
      if (extraData != null) 'extraData': extraData,
    };
  }
}

/// 批量添加路线请求
class BatchAddTrailsRequest {
  final List<String> trailIds;
  final String? note;

  BatchAddTrailsRequest({
    required this.trailIds,
    this.note,
  });

  factory BatchAddTrailsRequest.fromJson(Map<String, dynamic> json) {
    return BatchAddTrailsRequest(
      trailIds: (json['trailIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trailIds': trailIds,
      if (note != null) 'note': note,
    };
  }
}

/// 批量移动路线请求
class BatchMoveTrailsRequest {
  final String sourceCollectionId;
  final String targetCollectionId;
  final List<String> trailIds;

  BatchMoveTrailsRequest({
    required this.sourceCollectionId,
    required this.targetCollectionId,
    required this.trailIds,
  });

  factory BatchMoveTrailsRequest.fromJson(Map<String, dynamic> json) {
    return BatchMoveTrailsRequest(
      sourceCollectionId: json['sourceCollectionId'] ?? '',
      targetCollectionId: json['targetCollectionId'] ?? '',
      trailIds: (json['trailIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceCollectionId': sourceCollectionId,
      'targetCollectionId': targetCollectionId,
      'trailIds': trailIds,
    };
  }
}

/// 批量操作结果
class BatchOperationResult {
  final bool success;
  final String message;
  final int successCount;
  final int totalCount;
  final List<String>? failedIds;
  final Map<String, dynamic>? data;

  BatchOperationResult({
    required this.success,
    this.message = '',
    required this.successCount,
    required this.totalCount,
    this.failedIds,
    this.data,
  });

  factory BatchOperationResult.fromJson(Map<String, dynamic> json) {
    return BatchOperationResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      successCount: json['successCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      failedIds: (json['failedIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'successCount': successCount,
      'totalCount': totalCount,
      if (failedIds != null) 'failedIds': failedIds,
      if (data != null) 'data': data,
    };
  }

  /// 成功比例（0-1）
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;
}

/// 搜索筛选条件
class CollectionSearchFilter {
  final String? searchQuery;
  final List<String>? tags;
  final bool? isPublic;
  final String? sortBy;
  final bool sortAscending;
  final int page;
  final int limit;

  CollectionSearchFilter({
    this.searchQuery,
    this.tags,
    this.isPublic,
    this.sortBy,
    this.sortAscending = false,
    this.page = 1,
    this.limit = 20,
  });

  /// 转换为查询参数
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery!;
    }
    
    if (tags != null && tags!.isNotEmpty) {
      params['tags'] = tags!.join(',');
    }
    
    if (isPublic != null) {
      params['isPublic'] = isPublic.toString();
    }
    
    if (sortBy != null) {
      params['sort'] = '$sortBy:${sortAscending ? 'asc' : 'desc'}';
    }
    
    params['page'] = page.toString();
    params['limit'] = limit.toString();
    
    return params;
  }

  /// 从查询参数解析
  factory CollectionSearchFilter.fromQueryParams(Map<String, String> params) {
    final sortParts = (params['sort'] ?? '').split(':');
    final sortBy = sortParts.isNotEmpty ? sortParts[0] : null;
    final sortAscending = sortParts.length > 1 ? sortParts[1] == 'asc' : false;
    
    return CollectionSearchFilter(
      searchQuery: params['search'],
      tags: params['tags']?.split(','),
      isPublic: params['isPublic']?.toLowerCase() == 'true',
      sortBy: sortBy,
      sortAscending: sortAscending,
      page: int.tryParse(params['page'] ?? '1') ?? 1,
      limit: int.tryParse(params['limit'] ?? '20') ?? 20,
    );
  }

  /// 复制并更新参数
  CollectionSearchFilter copyWith({
    String? searchQuery,
    List<String>? tags,
    bool? isPublic,
    String? sortBy,
    bool? sortAscending,
    int? page,
    int? limit,
  }) {
    return CollectionSearchFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

/// 路线搜索筛选条件（在收藏夹内）
class CollectionTrailSearchFilter {
  final String? searchQuery;
  final List<String>? difficulties;
  final double? minDistance;
  final double? maxDistance;
  final int? minDuration;
  final int? maxDuration;
  final String? sortBy;
  final bool sortAscending;
  final int page;
  final int limit;

  CollectionTrailSearchFilter({
    this.searchQuery,
    this.difficulties,
    this.minDistance,
    this.maxDistance,
    this.minDuration,
    this.maxDuration,
    this.sortBy = 'added',
    this.sortAscending = false,
    this.page = 1,
    this.limit = 20,
  });

  /// 转换为查询参数
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery!;
    }
    
    if (difficulties != null && difficulties!.isNotEmpty) {
      params['difficulty'] = difficulties!.join(',');
    }
    
    if (minDistance != null) {
      params['minDistance'] = minDistance!.toString();
    }
    
    if (maxDistance != null) {
      params['maxDistance'] = maxDistance!.toString();
    }
    
    if (minDuration != null) {
      params['minDuration'] = minDuration!.toString();
    }
    
    if (maxDuration != null) {
      params['maxDuration'] = maxDuration!.toString();
    }
    
    if (sortBy != null) {
      params['sort'] = '$sortBy:${sortAscending ? 'asc' : 'desc'}';
    }
    
    params['page'] = page.toString();
    params['limit'] = limit.toString();
    
    return params;
  }

  /// 复制并更新参数
  CollectionTrailSearchFilter copyWith({
    String? searchQuery,
    List<String>? difficulties,
    double? minDistance,
    double? maxDistance,
    int? minDuration,
    int? maxDuration,
    String? sortBy,
    bool? sortAscending,
    int? page,
    int? limit,
  }) {
    return CollectionTrailSearchFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      difficulties: difficulties ?? this.difficulties,
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}
