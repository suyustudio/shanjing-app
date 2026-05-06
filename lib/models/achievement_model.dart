// ================================================================
// Achievement Models
// 成就系统数据模型
// ================================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_model.freezed.dart';

/// 成就类别枚举
enum AchievementCategory {
  explorer,
  distance,
  frequency,
  challenge,
  social;
}

/// 成就等级枚举
enum AchievementLevel {
  bronze,
  silver,
  gold,
  diamond;
}

/// 成就等级定义模型
@freezed
class AchievementLevelModel with _$AchievementLevelModel {
  const factory AchievementLevelModel({
    required String id,
    required AchievementLevel level,
    required int requirement,
    required String name,
    String? description,
    String? reward,
    String? iconUrl,
  }) = _AchievementLevelModel;

  factory AchievementLevelModel.fromJson(Map<String, dynamic> json) {
    return AchievementLevelModel(
      id: json['id'] as String,
      level: AchievementLevel.values.byName(json['level'] as String),
      requirement: (json['requirement'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      reward: json['reward'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );
  }
}

/// 成就定义模型
@freezed
class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String key,
    required String name,
    String? description,
    required AchievementCategory category,
    String? iconUrl,
    @Default(false) bool isHidden,
    @Default(0) int sortOrder,
    required List<AchievementLevelModel> levels,
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: AchievementCategory.values.byName(json['category'] as String),
      iconUrl: json['iconUrl'] as String?,
      isHidden: json['isHidden'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      levels: (json['levels'] as List<dynamic>)
          .map((e) => AchievementLevelModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 用户成就模型
@freezed
class UserAchievementModel with _$UserAchievementModel {
  const factory UserAchievementModel({
    required String achievementId,
    required String key,
    required String name,
    required String category,
    String? currentLevel,
    @Default(0) int currentProgress,
    @Default(0) int nextRequirement,
    @Default(0) int percentage,
    DateTime? unlockedAt,
    @Default(false) bool isNew,
    @Default(false) bool isUnlocked,
  }) = _UserAchievementModel;

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      achievementId: json['achievementId'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      currentLevel: json['currentLevel'] as String?,
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      nextRequirement: (json['nextRequirement'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      isNew: json['isNew'] as bool? ?? false,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }
}

/// 用户成就汇总模型
@freezed
class UserAchievementSummary with _$UserAchievementSummary {
  const factory UserAchievementSummary({
    @Default(0) int totalCount,
    @Default(0) int unlockedCount,
    @Default(0) int newUnlockedCount,
    @Default([]) List<UserAchievementModel> achievements,
  }) = _UserAchievementSummary;

  factory UserAchievementSummary.fromJson(Map<String, dynamic> json) {
    return UserAchievementSummary(
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      unlockedCount: (json['unlockedCount'] as num?)?.toInt() ?? 0,
      newUnlockedCount: (json['newUnlockedCount'] as num?)?.toInt() ?? 0,
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map(
                  (e) => UserAchievementModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 新解锁成就模型
@freezed
class NewlyUnlockedAchievement with _$NewlyUnlockedAchievement {
  const factory NewlyUnlockedAchievement({
    required String achievementId,
    required String level,
    required String name,
    required String message,
    required String badgeUrl,
  }) = _NewlyUnlockedAchievement;

  factory NewlyUnlockedAchievement.fromJson(Map<String, dynamic> json) {
    return NewlyUnlockedAchievement(
      achievementId: json['achievementId'] as String,
      level: json['level'] as String,
      name: json['name'] as String,
      message: json['message'] as String,
      badgeUrl: json['badgeUrl'] as String,
    );
  }
}

/// 进度更新模型
@freezed
class ProgressUpdate with _$ProgressUpdate {
  const factory ProgressUpdate({
    required String achievementId,
    required int progress,
    required int requirement,
    required int percentage,
  }) = _ProgressUpdate;

  factory ProgressUpdate.fromJson(Map<String, dynamic> json) {
    return ProgressUpdate(
      achievementId: json['achievementId'] as String,
      progress: (json['progress'] as num).toInt(),
      requirement: (json['requirement'] as num).toInt(),
      percentage: (json['percentage'] as num).toInt(),
    );
  }
}

/// 检查成就响应模型
@freezed
class CheckAchievementResult with _$CheckAchievementResult {
  const factory CheckAchievementResult({
    @Default([]) List<NewlyUnlockedAchievement> newlyUnlocked,
    @Default([]) List<ProgressUpdate> progressUpdated,
  }) = _CheckAchievementResult;

  factory CheckAchievementResult.fromJson(Map<String, dynamic> json) {
    return CheckAchievementResult(
      newlyUnlocked: (json['newlyUnlocked'] as List<dynamic>?)
              ?.map((e) =>
                  NewlyUnlockedAchievement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      progressUpdated: (json['progressUpdated'] as List<dynamic>?)
              ?.map(
                  (e) => ProgressUpdate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 用户统计模型
@freezed
class UserStatsModel with _$UserStatsModel {
  const factory UserStatsModel({
    @Default(0) int totalDistanceM,
    @Default(0) int totalDurationSec,
    @Default(0.0) double totalElevationGainM,
    @Default(0) int uniqueTrailsCount,
    @Default(0) int currentWeeklyStreak,
    @Default(0) int longestWeeklyStreak,
    @Default(0) int nightTrailCount,
    @Default(0) int rainTrailCount,
    @Default(0) int shareCount,
  }) = _UserStatsModel;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalDistanceM: (json['totalDistanceM'] as num?)?.toInt() ?? 0,
      totalDurationSec: (json['totalDurationSec'] as num?)?.toInt() ?? 0,
      totalElevationGainM:
          (json['totalElevationGainM'] as num?)?.toDouble() ?? 0.0,
      uniqueTrailsCount: (json['uniqueTrailsCount'] as num?)?.toInt() ?? 0,
      currentWeeklyStreak: (json['currentWeeklyStreak'] as num?)?.toInt() ?? 0,
      longestWeeklyStreak: (json['longestWeeklyStreak'] as num?)?.toInt() ?? 0,
      nightTrailCount: (json['nightTrailCount'] as num?)?.toInt() ?? 0,
      rainTrailCount: (json['rainTrailCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 轨迹统计数据
@freezed
class TrailStats with _$TrailStats {
  const factory TrailStats({
    required int distance,
    required int duration,
    @Default(false) bool isNight,
    @Default(false) bool isRain,
    @Default(false) bool isSolo,
  }) = _TrailStats;

  factory TrailStats.fromJson(Map<String, dynamic> json) {
    return TrailStats(
      distance: (json['distance'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      isNight: json['isNight'] as bool? ?? false,
      isRain: json['isRain'] as bool? ?? false,
      isSolo: json['isSolo'] as bool? ?? false,
    );
  }
}
