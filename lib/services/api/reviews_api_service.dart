// ================================================================
// M6: 评论 API 服务 - 修复版
// 统一响应格式，支持点赞功能
// ================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// 评论用户模型
class ReviewUser {
  final String id;
  final String? nickname;
  final String? avatarUrl;

  ReviewUser({
    required this.id,
    this.nickname,
    this.avatarUrl,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
    );
  }
}

/// 评论模型
class Review {
  final String id;
  final int rating;
  final String? content;
  final List<String> tags;
  final List<String> photos;
  final int likeCount;
  final int replyCount;
  final bool isEdited;
  final bool isVerified;
  final bool? isLiked;
  final ReviewUser user;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.rating,
    this.content,
    required this.tags,
    required this.photos,
    required this.likeCount,
    required this.replyCount,
    required this.isEdited,
    required this.isVerified,
    this.isLiked,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      photos: List<String>.from(json['photos'] ?? []),
      likeCount: json['likeCount'] ?? 0,
      replyCount: json['replyCount'] ?? 0,
      isEdited: json['isEdited'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isLiked: json['isLiked'],
      user: ReviewUser.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// 评论回复模型
class ReviewReply {
  final String id;
  final String content;
  final ReviewUser user;
  final String? parentId;
  final DateTime createdAt;

  ReviewReply({
    required this.id,
    required this.content,
    required this.user,
    this.parentId,
    required this.createdAt,
  });

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      id: json['id'],
      content: json['content'],
      user: ReviewUser.fromJson(json['user']),
      parentId: json['parentId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// 评论详情模型
class ReviewDetail extends Review {
  final List<ReviewReply> replies;

  ReviewDetail({
    required super.id,
    required super.rating,
    super.content,
    required super.tags,
    required super.photos,
    required super.likeCount,
    required super.replyCount,
    required super.isEdited,
    required super.isVerified,
    super.isLiked,
    required super.user,
    required super.createdAt,
    required super.updatedAt,
    required this.replies,
  });

  factory ReviewDetail.fromJson(Map<String, dynamic> json) {
    return ReviewDetail(
      id: json['id'],
      rating: json['rating'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      photos: List<String>.from(json['photos'] ?? []),
      likeCount: json['likeCount'] ?? 0,
      replyCount: json['replyCount'] ?? 0,
      isEdited: json['isEdited'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isLiked: json['isLiked'],
      user: ReviewUser.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      replies: (json['replies'] as List? ?? [])
          .map((r) => ReviewReply.fromJson(r))
          .toList(),
    );
  }
}

/// 评分统计模型
class ReviewStats {
  final String trailId;
  final double avgRating;
  final int totalCount;
  final int rating5Count;
  final int rating4Count;
  final int rating3Count;
  final int rating2Count;
  final int rating1Count;

  ReviewStats({
    required this.trailId,
    required this.avgRating,
    required this.totalCount,
    required this.rating5Count,
    required this.rating4Count,
    required this.rating3Count,
    required this.rating2Count,
    required this.rating1Count,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      trailId: json['trailId'],
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      totalCount: json['totalCount'] ?? 0,
      rating5Count: json['rating5Count'] ?? 0,
      rating4Count: json['rating4Count'] ?? 0,
      rating3Count: json['rating3Count'] ?? 0,
      rating2Count: json['rating2Count'] ?? 0,
      rating1Count: json['rating1Count'] ?? 0,
    );
  }

  /// 获取各星级百分比
  Map<int, double> get ratingPercentages {
    if (totalCount == 0) return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    return {
      5: (rating5Count / totalCount * 100),
      4: (rating4Count / totalCount * 100),
      3: (rating3Count / totalCount * 100),
      2: (rating2Count / totalCount * 100),
      1: (rating1Count / totalCount * 100),
    };
  }
}

/// 评论列表响应
class ReviewListResponse {
  final List<Review> list;
  final int total;
  final int page;
  final int limit;
  final ReviewStats stats;

  ReviewListResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.limit,
    required this.stats,
  });

  factory ReviewListResponse.fromJson(Map<String, dynamic> json) {
    return ReviewListResponse(
      list: (json['list'] as List? ?? [])
          .map((r) => Review.fromJson(r))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      stats: ReviewStats.fromJson(json['stats']),
    );
  }
}

/// 点赞响应
class LikeReviewResponse {
  final bool isLiked;
  final int likeCount;

  LikeReviewResponse({
    required this.isLiked,
    required this.likeCount,
  });

  factory LikeReviewResponse.fromJson(Map<String, dynamic> json) {
    return LikeReviewResponse(
      isLiked: json['isLiked'],
      likeCount: json['likeCount'],
    );
  }
}

/// 评论 API 服务
class ReviewsApiService {
  static final http.Client _client = http.Client();
  static const String _baseUrl = '${ApiConfig.baseUrl}/${ApiConfig.apiVersion}';

  // ==================== 辅助方法 ====================

  static Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static T _parseResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body['success'] == true) {
        return parser(body['data']);
      }
      throw Exception(body['message'] ?? '请求失败');
    }
    throw Exception(body['message'] ?? 'HTTP ${response.statusCode}');
  }

  // ==================== 评论 CRUD ====================

  /// 发表评论
  static Future<Review> createReview({
    required String token,
    required String trailId,
    required int rating,
    String? content,
    List<String>? tags,
    List<String>? photos,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/trails/$trailId/reviews'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'rating': rating,
        if (content != null) 'content': content,
        if (tags != null) 'tags': tags,
        if (photos != null) 'photos': photos,
      }),
    );
    return _parseResponse(response, (data) => Review.fromJson(data));
  }

  /// 获取评论列表
  static Future<ReviewListResponse> getReviews({
    String? token,
    required String trailId,
    String sort = 'newest',
    int? rating,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'sort': sort,
      'page': page.toString(),
      'limit': limit.toString(),
      if (rating != null) 'rating': rating.toString(),
    };

    final uri = Uri.parse('$_baseUrl/trails/$trailId/reviews')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: _getHeaders(token),
    );
    return _parseResponse(response, (data) => ReviewListResponse.fromJson(data));
  }

  /// 获取评论详情
  static Future<ReviewDetail> getReviewDetail({
    String? token,
    required String reviewId,
  }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/reviews/$reviewId'),
      headers: _getHeaders(token),
    );
    return _parseResponse(response, (data) => ReviewDetail.fromJson(data));
  }

  /// 编辑评论
  static Future<Review> updateReview({
    required String token,
    required String reviewId,
    int? rating,
    String? content,
    List<String>? tags,
    List<String>? photos,
  }) async {
    final body = <String, dynamic>{};
    if (rating != null) body['rating'] = rating;
    if (content != null) body['content'] = content;
    if (tags != null) body['tags'] = tags;
    if (photos != null) body['photos'] = photos;

    final response = await _client.put(
      Uri.parse('$_baseUrl/reviews/$reviewId'),
      headers: _getHeaders(token),
      body: jsonEncode(body),
    );
    return _parseResponse(response, (data) => Review.fromJson(data));
  }

  /// 删除评论
  static Future<void> deleteReview({
    required String token,
    required String reviewId,
  }) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/reviews/$reviewId'),
      headers: _getHeaders(token),
    );
    _parseResponse(response, (data) => data);
  }

  // ==================== 点赞功能 (P0) ====================

  /// 点赞/取消点赞评论
  static Future<LikeReviewResponse> likeReview({
    required String token,
    required String reviewId,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/reviews/$reviewId/like'),
      headers: _getHeaders(token),
    );
    return _parseResponse(response, (data) => LikeReviewResponse.fromJson(data));
  }

  /// 检查是否已点赞
  static Future<bool> checkLikeStatus({
    required String token,
    required String reviewId,
  }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/reviews/$reviewId/like'),
      headers: _getHeaders(token),
    );
    return _parseResponse(response, (data) => data['isLiked'] as bool);
  }

  // ==================== 评论回复 ====================

  /// 回复评论
  static Future<ReviewReply> createReply({
    required String token,
    required String reviewId,
    required String content,
    String? parentId,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/reviews/$reviewId/replies'),
      headers: _getHeaders(token),
      body: jsonEncode({
        'content': content,
        if (parentId != null) 'parentId': parentId,
      }),
    );
    return _parseResponse(response, (data) => ReviewReply.fromJson(data));
  }

  /// 获取评论回复列表
  static Future<List<ReviewReply>> getReplies({
    required String reviewId,
  }) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/reviews/$reviewId/replies'),
    );
    return _parseResponse(
      response,
      (data) => (data as List).map((r) => ReviewReply.fromJson(r)).toList(),
    );
  }

  // ==================== 举报 ====================

  /// 举报评论
  static Future<void> reportReview({
    required String token,
    required String reviewId,
    required String reason,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/reviews/$reviewId/report'),
      headers: _getHeaders(token),
      body: jsonEncode({'reason': reason}),
    );
    _parseResponse(response, (data) => data);
  }
}
