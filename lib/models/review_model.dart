/**
 * 评论数据模型
 * 
 * M6 评论系统 - 与后端 API 对接
 */

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
      id: json['id'] ?? '',
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    };
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
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      user: ReviewUser.fromJson(json['user'] ?? {}),
      parentId: json['parentId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'user': user.toJson(),
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 评论模型
class Review {
  final String id;
  final int rating; // 1-5 整数评分
  final String? content;
  final List<String> tags;
  final List<String> photos;
  final int likeCount;
  final int replyCount;
  final bool isEdited;
  final bool isVerified;
  final bool isLiked;
  final ReviewUser user;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ReviewReply>? replies;

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
    this.isLiked = false,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    this.replies,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 0,
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      photos: List<String>.from(json['photos'] ?? []),
      likeCount: json['likeCount'] ?? 0,
      replyCount: json['replyCount'] ?? 0,
      isEdited: json['isEdited'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isLiked: json['isLiked'] ?? false,
      user: ReviewUser.fromJson(json['user'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      replies: json['replies'] != null
          ? (json['replies'] as List).map((e) => ReviewReply.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'content': content,
      'tags': tags,
      'photos': photos,
      'likeCount': likeCount,
      'replyCount': replyCount,
      'isEdited': isEdited,
      'isVerified': isVerified,
      'isLiked': isLiked,
      'user': user.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }

  /// 复制并修改
  Review copyWith({
    int? likeCount,
    bool? isLiked,
    int? replyCount,
    List<ReviewReply>? replies,
  }) {
    return Review(
      id: id,
      rating: rating,
      content: content,
      tags: tags,
      photos: photos,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isEdited: isEdited,
      isVerified: isVerified,
      isLiked: isLiked ?? this.isLiked,
      user: user,
      createdAt: createdAt,
      updatedAt: updatedAt,
      replies: replies ?? this.replies,
    );
  }
}

/// 评论统计模型
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
      trailId: json['trailId'] ?? '',
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      totalCount: json['totalCount'] ?? 0,
      rating5Count: json['rating5Count'] ?? 0,
      rating4Count: json['rating4Count'] ?? 0,
      rating3Count: json['rating3Count'] ?? 0,
      rating2Count: json['rating2Count'] ?? 0,
      rating1Count: json['rating1Count'] ?? 0,
    );
  }

  /// 获取评分分布百分比
  Map<int, double> getRatingDistribution() {
    if (totalCount == 0) {
      return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    }
    return {
      5: rating5Count / totalCount,
      4: rating4Count / totalCount,
      3: rating3Count / totalCount,
      2: rating2Count / totalCount,
      1: rating1Count / totalCount,
    };
  }
}

/// 评论列表响应模型
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
          .map((e) => Review.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      stats: ReviewStats.fromJson(json['stats'] ?? {}),
    );
  }
}

/// 预定义标签列表
const List<String> PREDEFINED_TAGS = [
  // 风景类
  '风景优美', '视野开阔', '拍照圣地', '秋色迷人', '春花烂漫',
  // 难度类
  '难度适中', '轻松休闲', '挑战性强', '适合新手', '需要体能',
  // 设施类
  '设施完善', '补给方便', '厕所干净', '指示牌清晰',
  // 人群类
  '适合亲子', '宠物友好', '人少清静', '团队建设',
  // 特色类
  '历史文化', '古迹众多', '森林氧吧', '溪流潺潺'
];

/// 创建评论请求
class CreateReviewRequest {
  final int rating;
  final String? content;
  final List<String>? tags;
  final List<String>? photos;

  CreateReviewRequest({
    required this.rating,
    this.content,
    this.tags,
    this.photos,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      if (content != null) 'content': content,
      if (tags != null) 'tags': tags,
      if (photos != null) 'photos': photos,
    };
  }
}

/// 更新评论请求
class UpdateReviewRequest {
  final int? rating;
  final String? content;
  final List<String>? tags;
  final List<String>? photos;

  UpdateReviewRequest({
    this.rating,
    this.content,
    this.tags,
    this.photos,
  });

  Map<String, dynamic> toJson() {
    return {
      if (rating != null) 'rating': rating,
      if (content != null) 'content': content,
      if (tags != null) 'tags': tags,
      if (photos != null) 'photos': photos,
    };
  }
}

/// 创建回复请求
class CreateReplyRequest {
  final String content;
  final String? parentId;

  CreateReplyRequest({
    required this.content,
    this.parentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (parentId != null) 'parentId': parentId,
    };
  }
}

/// 点赞响应模型
class LikeReviewResponse {
  final bool isLiked;
  final int likeCount;

  LikeReviewResponse({
    required this.isLiked,
    required this.likeCount,
  });

  factory LikeReviewResponse.fromJson(Map<String, dynamic> json) {
    return LikeReviewResponse(
      isLiked: json['isLiked'] ?? false,
      likeCount: json['likeCount'] ?? 0,
    );
  }
}
