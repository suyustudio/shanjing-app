import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

/// 成就类别枚举
enum AchievementCategory {
  explorer,   // 探索类
  distance,   // 里程类
  frequency,  // 频率类
  challenge,  // 挑战类
  social,     // 社交类
}

/// 成就等级枚举
enum AchievementLevelType {
  bronze,     // 铜
  silver,     // 银
  gold,       // 金
  diamond,    // 钻石
}

/// 成就等级定义
@freezed
class AchievementLevel with _$AchievementLevel {
  const factory AchievementLevel({
    required AchievementLevelType level,
    required int requirement,
    required String name,
    String? description,
    String? iconUrl,
  }) = _AchievementLevel;

  factory AchievementLevel.fromJson(Map<String, dynamic> json) =
      _$AchievementLevelFromJson;
}

/// 成就定义
@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String key,
    required String name,
    String? description,
    required AchievementCategory category,
    String? iconUrl,
    @Default(false) bool isHidden,
    @Default(0) int sortOrder,
    required List<AchievementLevel> levels,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementFromJson;
}

/// 用户成就
@freezed
class UserAchievement with _$UserAchievement {
  const factory UserAchievement({
    required String achievementId,
    required String key,
    required String name,
    required AchievementCategory category,
    AchievementLevelType? currentLevel,
    @Default(0) int currentProgress,
    @Default(0) int nextRequirement,
    @Default(0.0) double percentage,
    DateTime? unlockedAt,
    @Default(false) bool isNew,
  }) = _UserAchievement;

  factory UserAchievement.fromJson(Map<String, dynamic> json) =
      _$UserAchievementFromJson;
}

/// 用户成就汇总
@freezed
class UserAchievementSummary with _$UserAchievementSummary {
  const factory UserAchievementSummary({
    @Default(0) int totalCount,
    @Default(0) int unlockedCount,
    @Default(0) int newUnlockedCount,
    @Default([]) List<UserAchievement> achievements,
  }) = _UserAchievementSummary;

  factory UserAchievementSummary.fromJson(Map<String, dynamic> json) =
      _$UserAchievementSummaryFromJson;
}

/// 轨迹统计
@freezed
class TrailStats with _$TrailStats {
  const factory TrailStats({
    required int distance,     // 米
    required int duration,     // 秒
    @Default(false) bool isNight,
    @Default(false) bool isRain,
    @Default(false) bool isSolo,
  }) = _TrailStats;

  factory TrailStats.fromJson(Map<String, dynamic> json) =
      _$TrailStatsFromJson;
}

/// 新解锁成就
@freezed
class NewlyUnlockedAchievement with _$NewlyUnlockedAchievement {
  const factory NewlyUnlockedAchievement({
    required String achievementId,
    required AchievementLevelType level,
    required String name,
    required String message,
    required String badgeUrl,
  }) = _NewlyUnlockedAchievement;

  factory NewlyUnlockedAchievement.fromJson(Map<String, dynamic> json) =
      _$NewlyUnlockedAchievementFromJson;
}

/// 进度更新
@freezed
class ProgressUpdatedAchievement with _$ProgressUpdatedAchievement {
  const factory ProgressUpdatedAchievement({
    required String achievementId,
    required int progress,
    required int requirement,
    required double percentage,
  }) = _ProgressUpdatedAchievement;

  factory ProgressUpdatedAchievement.fromJson(Map<String, dynamic> json) =
      _$ProgressUpdatedAchievementFromJson;
}

/// 成就检查结果
@freezed
class AchievementCheckResult with _$AchievementCheckResult {
  const factory AchievementCheckResult({
    @Default([]) List<NewlyUnlockedAchievement> newlyUnlocked,
    @Default([]) List<ProgressUpdatedAchievement> progressUpdated,
  }) = _AchievementCheckResult;

  factory AchievementCheckResult.fromJson(Map<String, dynamic> json) =
      _$AchievementCheckResultFromJson;
}

/// 成就等级扩展方法
extension AchievementLevelTypeExtension on AchievementLevelType {
  String get displayName {
    switch (this) {
      case AchievementLevelType.bronze:
        return '铜';
      case AchievementLevelType.silver:
        return '银';
      case AchievementLevelType.gold:
        return '金';
      case AchievementLevelType.diamond:
        return '钻石';
    }
  }

  String get colorHex {
    switch (this) {
      case AchievementLevelType.bronze:
        return '#CD7F32';
      case AchievementLevelType.silver:
        return '#C0C0C0';
      case AchievementLevelType.gold:
        return '#FFD700';
      case AchievementLevelType.diamond:
        return '#00CED1';
    }
  }

  int get order {
    switch (this) {
      case AchievementLevelType.bronze:
        return 1;
      case AchievementLevelType.silver:
        return 2;
      case AchievementLevelType.gold:
        return 3;
      case AchievementLevelType.diamond:
        return 4;
    }
  }
}

/// 成就类别扩展方法
extension AchievementCategoryExtension on AchievementCategory {
  String get displayName {
    switch (this) {
      case AchievementCategory.explorer:
        return '探索';
      case AchievementCategory.distance:
        return '里程';
      case AchievementCategory.frequency:
        return '频率';
      case AchievementCategory.challenge:
        return '挑战';
      case AchievementCategory.social:
        return '社交';
    }
  }
}
