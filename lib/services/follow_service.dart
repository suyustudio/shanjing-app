// ================================================================
// M6: 关注系统服务
// ================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// 关注用户数据模型
class FollowUser {
  final String id;
  final String? nickname;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final bool isFollowing;
  final int? mutualFollows;

  FollowUser({
    required this.id,
    this.nickname,
    this.avatarUrl,
    this.bio,
    required this.followersCount,
    this.isFollowing = false,
    this.mutualFollows,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      followersCount: json['followersCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
      mutualFollows: json['mutualFollows'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'followersCount': followersCount,
      'isFollowing': isFollowing,
      'mutualFollows': mutualFollows,
    };
  }

  FollowUser copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
    String? bio,
    int? followersCount,
    bool? isFollowing,
    int? mutualFollows,
  }) {
    return FollowUser(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      isFollowing: isFollowing ?? this.isFollowing,
      mutualFollows: mutualFollows ?? this.mutualFollows,
    );
  }
}

/// 关注统计数据模型
class FollowStats {
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  FollowStats({
    required this.followersCount,
    required this.followingCount,
    this.isFollowing = false,
  });

  factory FollowStats.fromJson(Map<String, dynamic> json) {
    return FollowStats(
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
    );
  }
}

/// 关注操作响应
class FollowActionResult {
  final bool isFollowing;
  final int followersCount;
  final int followingCount;

  FollowActionResult({
    required this.isFollowing,
    required this.followersCount,
    required this.followingCount,
  });

  factory FollowActionResult.fromJson(Map<String, dynamic> json) {
    return FollowActionResult(
      isFollowing: json['isFollowing'] ?? false,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
    );
  }
}

/// 关注列表响应
class FollowListResult {
  final List<FollowUser> list;
  final String? nextCursor;
  final bool hasMore;
  final int total;

  FollowListResult({
    required this.list,
    this.nextCursor,
    required this.hasMore,
    required this.total,
  });

  factory FollowListResult.fromJson(Map<String, dynamic> json) {
    // 处理统一响应格式 {success, data, meta}
    final data = json['data'] ?? json;
    final list = (data is List) 
        ? data 
        : (data['list'] as List<dynamic>? ?? []);
    
    return FollowListResult(
      list: list.map((e) => FollowUser.fromJson(e)).toList(),
      nextCursor: json['meta']?['cursor'] ?? data['nextCursor'],
      hasMore: json['meta']?['hasMore'] ?? data['hasMore'] ?? false,
      total: json['meta']?['total'] ?? data['total'] ?? 0,
    );
  }
}

/// 关注状态
class FollowStatus {
  final bool isFollowing;
  final bool isMutual;

  FollowStatus({
    required this.isFollowing,
    required this.isMutual,
  });

  factory FollowStatus.fromJson(Map<String, dynamic> json) {
    // 处理统一响应格式 {success, data}
    final data = json['data'] ?? json;
    return FollowStatus(
      isFollowing: data['isFollowing'] ?? false,
      isMutual: data['isMutual'] ?? false,
    );
  }
}

/// 关注系统服务类
class FollowService {
  static final FollowService _instance = FollowService._internal();
  static FollowService get instance => _instance;

  FollowService._internal();

  final ApiClient _apiClient = ApiClient();

  // ==================== 关注操作 ====================

  /// 关注用户
  Future<FollowActionResult> followUser(String userId) async {
    final response = await _apiClient.post(
      '/v1/users/$userId/follow',
      parser: (data) => FollowActionResult.fromJson(data['data'] ?? data),
    );

    if (!response.success) {
      throw ApiException(
        message: response.errorMessage ?? '关注失败',
        code: response.errorCode ?? 'FOLLOW_ERROR',
      );
    }

    return response.data!;
  }

  /// 取消关注用户
  Future<FollowActionResult> unfollowUser(String userId) async {
    final response = await _apiClient.delete(
      '/v1/users/$userId/follow',
      parser: (data) => FollowActionResult.fromJson(data['data'] ?? data),
    );

    if (!response.success) {
      throw ApiException(
        message: response.errorMessage ?? '取消关注失败',
        code: response.errorCode ?? 'UNFOLLOW_ERROR',
      );
    }

    return response.data!;
  }

  /// 切换关注状态（关注/取消关注）
  Future<FollowActionResult> toggleFollow(String userId, bool isFollowing) async {
    if (isFollowing) {
      return unfollowUser(userId);
    } else {
      return followUser(userId);
    }
  }

  // ==================== 列表查询 ====================

  /// 获取关注列表
  Future<FollowListResult> getFollowing(
    String userId, {
    String? cursor,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await _apiClient.get(
      '/v1/users/$userId/following',
      queryParams: queryParams,
      parser: (data) => FollowListResult.fromJson(data),
    );

    if (!response.success) {
      throw ApiException(
        message: response.errorMessage ?? '获取关注列表失败',
        code: response.errorCode ?? 'GET_FOLLOWING_ERROR',
      );
    }

    return response.data!;
  }

  /// 获取粉丝列表
  Future<FollowListResult> getFollowers(
    String userId, {
    String? cursor,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await _apiClient.get(
      '/v1/users/$userId/followers',
      queryParams: queryParams,
      parser: (data) => FollowListResult.fromJson(data),
    );

    if (!response.success) {
      throw ApiException(
        message: response.errorMessage ?? '获取粉丝列表失败',
        code: response.errorCode ?? 'GET_FOLLOWERS_ERROR',
      );
    }

    return response.data!;
  }

  /// 获取互相关注列表
  Future<List<FollowUser>> getMutualFollows(String userId) async {
    // 获取关注列表
    final followingResult = await getFollowing(userId, limit: 1000);
    final followingIds = followingResult.list.map((u) => u.id).toSet();

    // 获取粉丝列表
    final followersResult = await getFollowers(userId, limit: 1000);

    // 筛选互相关注
    final mutualFollows = followersResult.list
        .where((user) => followingIds.contains(user.id))
        .toList();

    return mutualFollows;
  }

  /// 获取推荐关注用户
  Future<FollowListResult> getSuggestions({int limit = 10}) async {
    final response = await _apiClient.get(
      '/v1/users/suggestions',
      queryParams: {'limit': limit},
      parser: (data) => FollowListResult.fromJson(data),
    );

    if (!response.success) {
      throw ApiException(
        message: response.errorMessage ?? '获取推荐关注失败',
        code: response.errorCode ?? 'GET_SUGGESTIONS_ERROR',
      );
    }

    return response.data!;
  }

  // ==================== 状态查询 ====================

  /// 获取关注状态
  Future<FollowStatus> getFollowStatus(String userId) async {
    final response = await _apiClient.get(
      '/v1/users/$userId/follow-status',
      parser: (data) => FollowStatus.fromJson(data),
    );

    if (!response.success) {
      throw ApiException(
        message: response.errorMessage ?? '获取关注状态失败',
        code: response.errorCode ?? 'GET_STATUS_ERROR',
      );
    }

    return response.data!;
  }

  /// 获取关注统计
  Future<FollowStats> getFollowStats(String userId) async {
    final response = await _apiClient.get(
      '/v1/users/$userId/follow-stats',
      parser: (data) => FollowStats.fromJson(data['data'] ?? data),
    );

    if (!response.success) {
      throw ApiException(
        message: response.errorMessage ?? '获取关注统计失败',
        code: response.errorCode ?? 'GET_STATS_ERROR',
      );
    }

    return response.data!;
  }
}
