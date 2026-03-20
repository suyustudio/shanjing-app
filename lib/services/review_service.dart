/**
 * 评论服务
 * 
 * M6 评论系统 API 调用封装
 * 统一响应格式: { success: boolean, data: any, message?: string }
 */

import 'api_client.dart';
import 'api_config.dart';
import '../models/review_model.dart';

/// 评论服务
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final ApiClient _apiClient = ApiClient();

  // ==================== 评论 CRUD ====================

  /// 发表评论
  /// 
  /// POST /v1/trails/:trailId/reviews
  Future<Review> createReview(
    String trailId,
    CreateReviewRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.trailReviews(trailId),
      body: request.toJson(),
      parser: (data) => Review.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '发表评论失败',
      code: response.errorCode,
    );
  }

  /// 获取路线评论列表
  /// 
  /// GET /v1/trails/:trailId/reviews
  Future<ReviewListResponse> getReviews(
    String trailId, {
    String sort = 'newest',
    int? rating,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'sort': sort,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (rating != null) {
      queryParams['rating'] = rating.toString();
    }

    final response = await _apiClient.get(
      ApiEndpoints.trailReviews(trailId),
      queryParams: queryParams,
      parser: (data) => ReviewListResponse.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '获取评论列表失败',
      code: response.errorCode,
    );
  }

  /// 获取评论详情
  /// 
  /// GET /v1/reviews/:id
  Future<Review> getReviewDetail(String reviewId) async {
    final response = await _apiClient.get(
      ApiEndpoints.reviewDetail(reviewId),
      parser: (data) => Review.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '获取评论详情失败',
      code: response.errorCode,
    );
  }

  /// 编辑评论
  /// 
  /// PUT /v1/reviews/:id
  Future<Review> updateReview(
    String reviewId,
    UpdateReviewRequest request,
  ) async {
    // 使用 PUT 请求
    final response = await _apiClient.put(
      ApiEndpoints.reviewDetail(reviewId),
      body: request.toJson(),
      parser: (data) => Review.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '编辑评论失败',
      code: response.errorCode,
    );
  }

  /// 删除评论
  /// 
  /// DELETE /v1/reviews/:id
  Future<void> deleteReview(String reviewId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.reviewDetail(reviewId),
    );

    if (!response.success) {
      throw ApiException(
        message: response.errorMessage ?? '删除评论失败',
        code: response.errorCode,
      );
    }
  }

  // ==================== 评论点赞 (P0) ====================

  /// 点赞/取消点赞评论 (Toggle)
  /// 
  /// POST /v1/reviews/:id/like
  Future<LikeReviewResponse> likeReview(String reviewId) async {
    final response = await _apiClient.post(
      ApiEndpoints.reviewLike(reviewId),
      parser: (data) => LikeReviewResponse.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '点赞操作失败',
      code: response.errorCode,
    );
  }

  /// 检查是否已点赞
  /// 
  /// GET /v1/reviews/:id/like
  Future<bool> checkLikeStatus(String reviewId) async {
    final response = await _apiClient.get(
      ApiEndpoints.reviewLike(reviewId),
      parser: (data) => data['isLiked'] ?? false,
    );

    if (response.success) {
      return response.data ?? false;
    }

    return false;
  }

  // ==================== 评论回复 ====================

  /// 回复评论
  /// 
  /// POST /v1/reviews/:id/replies
  Future<ReviewReply> createReply(
    String reviewId,
    CreateReplyRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.reviewReplies(reviewId),
      body: request.toJson(),
      parser: (data) => ReviewReply.fromJson(data),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '回复评论失败',
      code: response.errorCode,
    );
  }

  /// 获取评论回复列表
  /// 
  /// GET /v1/reviews/:id/replies
  Future<List<ReviewReply>> getReplies(String reviewId) async {
    final response = await _apiClient.get(
      ApiEndpoints.reviewReplies(reviewId),
      parser: (data) => (data as List)
          .map((e) => ReviewReply.fromJson(e))
          .toList(),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.errorMessage ?? '获取回复列表失败',
      code: response.errorCode,
    );
  }

  // ==================== 评论举报 ====================

  /// 举报评论
  /// 
  /// POST /v1/reviews/:id/report
  Future<void> reportReview(String reviewId, String reason) async {
    final response = await _apiClient.post(
      ApiEndpoints.reviewReport(reviewId),
      body: {'reason': reason},
    );

    if (!response.success) {
      throw ApiException(
        message: response.errorMessage ?? '举报失败',
        code: response.errorCode,
      );
    }
  }
}

/// API 异常类 (与 api_client.dart 保持一致)
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;
  final dynamic data;

  ApiException({
    this.statusCode,
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message, code: $code)';
}
