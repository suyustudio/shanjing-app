// ================================================================
// 成就与推荐系统共享常量
// Achievement & Recommendation System Constants
// ================================================================

/// 时间相关常量 (单位: 毫秒)
class TimeConstants {
  const TimeConstants._();
  
  static const int oneMinute = 60 * 1000;
  static const int fiveMinutes = 5 * 60 * 1000;
  static const int tenMinutes = 10 * 60 * 1000;
  static const int thirtyMinutes = 30 * 60 * 1000;
  static const int oneHour = 60 * 60 * 1000;
  static const int oneDay = 24 * 60 * 60 * 1000;
  static const int thirtyDays = 30 * 24 * 60 * 60 * 1000;
  static const int ninetyDays = 90 * 24 * 60 * 60 * 1000;
}

/// 距离相关常量 (单位: 米)
class DistanceConstants {
  const DistanceConstants._();
  
  static const int oneKm = 1000;
  static const int tenKm = 10 * 1000;
  static const int fiftyKm = 50 * 1000;
  static const int oneHundredKm = 100 * 1000;
  static const int maxReferenceDistanceKm = 100;
  static const double earthRadiusMeters = 6371000;
}

/// 缓存TTL常量 (单位: 毫秒)
class CacheTtl {
  const CacheTtl._();
  
  static const Duration veryShort = Duration(minutes: 2);
  static const Duration short = Duration(minutes: 3);
  static const Duration medium = Duration(minutes: 5);
  static const Duration long = Duration(minutes: 10);
  static const Duration persistent = Duration(minutes: 30);
}

/// 成就系统特定常量
class AchievementConstants {
  const AchievementConstants._();
  
  static const String achievementListCacheKey = 'achievements:all';
  static const String userAchievementCachePrefix = 'achievements:user';
  static const Duration achievementCacheTtl = Duration(minutes: 5);
  static const Duration userAchievementCacheTtl = Duration(minutes: 3);
  
  static const List<String> validTriggerTypes = [
    'trail_completed',
    'share',
    'manual',
  ];
}

/// 推荐系统特定常量
class RecommendationConstants {
  const RecommendationConstants._();
  
  static const String cachePrefix = 'recommendation:';
  static const Duration popularityCacheTtl = Duration(minutes: 5);
  static const Duration recommendationCacheTtl = Duration(minutes: 10);
  static const int freshnessDecayDays = 90;
  static const int maxDifficultyDiff = 3;
  static const int coldStartMultiplier = 3;
  static const int homeTopTrailsCount = 3;
  
  static const double freshnessHighThreshold = 0.7;
  static const double difficultyMatchHighThreshold = 0.8;
  static const double distanceHighThreshold = 0.7;
  static const double popularityHighThreshold = 0.8;
  static const double ratingHighThreshold = 0.85;
  
  static const int nearbyMaxDistanceMeters = 50000; // 50km
  static const int distanceBonusThresholdKm = 10;
  static const int distancePenaltyThresholdKm = 100;
  static const int newTrailProtectionDays = 30;
  static const int minReviewCount = 10;
  static const double defaultRating = 3.5;
  
  static const int popularityCompletionDenominator = 100;
  static const int popularityBookmarkDenominator = 50;
  static const double popularityCompletionWeight = 0.6;
  static const double popularityBookmarkWeight = 0.4;
  static const double newTrailBasePopularityScore = 0.5;
  static const double coldStartDefaultMatchScore = 0.8;
  static const double defaultDistanceScore = 0.5;
  static const double defaultFreshnessScore = 0.5;
  static const double lowReviewCountScore = 0.7;
}

/// 难度映射常量
/// 前后端共享，确保一致性
class DifficultyMap {
  const DifficultyMap._();
  
  static const int easy = 1;
  static const int moderate = 2;
  static const int hard = 3;
  static const int expert = 4;
  
  /// 将难度字符串映射为数值
  static int fromString(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'EASY':
        return easy;
      case 'MODERATE':
        return moderate;
      case 'HARD':
        return hard;
      case 'EXPERT':
        return expert;
      default:
        return moderate;
    }
  }
  
  /// 将数值映射为难度字符串
  static String toString(int value) {
    switch (value) {
      case easy:
        return 'EASY';
      case moderate:
        return 'MODERATE';
      case hard:
        return 'HARD';
      case expert:
        return 'EXPERT';
      default:
        return 'MODERATE';
    }
  }
}

/// 推荐场景枚举
enum RecommendationScene {
  home,
  list,
  similar,
  nearby,
}

/// 用户行为枚举
enum UserAction {
  click,
  bookmark,
  complete,
  ignore,
}

/// 成就类别枚举
enum AchievementCategory {
  explorer,
  distance,
  frequency,
  challenge,
  social,
}

/// 成就等级枚举
enum AchievementLevel {
  bronze,
  silver,
  gold,
  diamond,
}

/// 验证约束常量
class ValidationConstraints {
  const ValidationConstraints._();
  
  static const int maxDistanceMeters = 1000000; // 1000km
  static const int maxDurationSeconds = 86400; // 24小时
  static const int maxLimit = 50;
  static const int minLimit = 1;
  static const int defaultLimit = 10;
}

/// API 超时配置
class ApiTimeoutConfig {
  const ApiTimeoutConfig._();
  
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration longTimeout = Duration(seconds: 60);
  static const Duration shortTimeout = Duration(seconds: 10);
  
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const double retryDelayMultiplier = 2.0;
}
