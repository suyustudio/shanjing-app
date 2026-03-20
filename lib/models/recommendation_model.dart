// ============================================
// 推荐模型
// ============================================

/// 推荐场景枚举
enum RecommendationScene {
  home,      // 首页推荐
  list,      // 路线列表
  similar,   // 相似路线
  nearby,    // 附近推荐
}

/// 用户行为枚举
enum UserAction {
  click,     // 点击
  bookmark,  // 收藏
  complete,  // 完成
  ignore,    // 忽略
}

/// 匹配因子
class MatchFactors {
  final int difficultyMatch;
  final int distance;
  final int rating;
  final int popularity;
  final int freshness;

  MatchFactors({
    required this.difficultyMatch,
    required this.distance,
    required this.rating,
    required this.popularity,
    required this.freshness,
  });

  factory MatchFactors.fromJson(Map<String, dynamic> json) {
    return MatchFactors(
      difficultyMatch: json['difficultyMatch'] ?? 0,
      distance: json['distance'] ?? 0,
      rating: json['rating'] ?? 0,
      popularity: json['popularity'] ?? 0,
      freshness: json['freshness'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    return {
      'difficultyMatch': difficultyMatch,
      'distance': distance,
      'rating': rating,
      'popularity': popularity,
      'freshness': freshness,
    };
  }
}

/// 推荐路线
class RecommendedTrail {
  final String id;
  final String name;
  final String coverImage;
  final double distanceKm;
  final int durationMin;
  final String difficulty;
  final double rating;
  final int matchScore;
  final MatchFactors matchFactors;
  final String? recommendReason;
  final double? userDistanceM;

  RecommendedTrail({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.distanceKm,
    required this.durationMin,
    required this.difficulty,
    required this.rating,
    required this.matchScore,
    required this.matchFactors,
    this.recommendReason,
    this.userDistanceM,
  });

  factory RecommendedTrail.fromJson(Map<String, dynamic> json) {
    return RecommendedTrail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      coverImage: json['coverImage'] ?? '',
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      durationMin: json['durationMin'] ?? 0,
      difficulty: json['difficulty'] ?? 'MODERATE',
      rating: (json['rating'] ?? 0).toDouble(),
      matchScore: json['matchScore'] ?? 0,
      matchFactors: MatchFactors.fromJson(json['matchFactors'] ?? {}),
      recommendReason: json['recommendReason'],
      userDistanceM: json['userDistanceM']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    return {
      'id': id,
      'name': name,
      'coverImage': coverImage,
      'distanceKm': distanceKm,
      'durationMin': durationMin,
      'difficulty': difficulty,
      'rating': rating,
      'matchScore': matchScore,
      'matchFactors': matchFactors.toJson(),
      'recommendReason': recommendReason,
      'userDistanceM': userDistanceM,
    };
  }

  /// 获取格式化距离
  String get formattedDistance {
    if (userDistanceM != null) {
      if (userDistanceM! < 1000) {
        return '${userDistanceM!.toInt()}m';
      } else {
        return '${(userDistanceM! / 1000).toStringAsFixed(1)}km';
      }
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }

  /// 获取格式化时长
  String get formattedDuration {
    final hours = durationMin ~/ 60;
    final mins = durationMin % 60;
    if (hours > 0) {
      return '${hours}h${mins > 0 ? '${mins}m' : ''}';
    }
    return '${mins}m';
  }

  /// 获取难度中文
  String get difficultyText {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return '简单';
      case 'MODERATE':
        return '适中';
      case 'HARD':
        return '困难';
      default:
        return '适中';
    }
  }

  /// 获取匹配度文本
  String get matchScoreText => '$matchScore% 匹配';
}

/// 推荐响应
class RecommendationsResponse {
  final String algorithm;
  final String scene;
  final String logId;
  final List<RecommendedTrail> trails;

  RecommendationsResponse({
    required this.algorithm,
    required this.scene,
    required this.logId,
    required this.trails,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationsResponse(
      algorithm: json['algorithm'] ?? '',
      scene: json['scene'] ?? '',
      logId: json['logId'] ?? '',
      trails: (json['trails'] as List?)
          ?.map((e) => RecommendedTrail.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    return {
      'algorithm': algorithm,
      'scene': scene,
      'logId': logId,
      'trails': trails.map((e) => e.toJson()).toList(),
    };
  }
}