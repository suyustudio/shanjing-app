// ================================================================
// Achievement Models
// 成就系统数据模型
// ================================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

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

  factory AchievementLevelModel.fromJson(Map<String, dynamic> json) =
      _$AchievementLevelModelFromJson;
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

  factory AchievementModel.fromJson(Map<String, dynamic> json) =
      _$AchievementModelFromJson;
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

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) =
      _$UserAchievementModelFromJson;
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

  factory UserAchievementSummary.fromJson(Map<String, dynamic> json) =
      _$UserAchievementSummaryFromJson;
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

  factory NewlyUnlockedAchievement.fromJson(Map<String, dynamic> json) =
      _$NewlyUnlockedAchievementFromJson;
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

  factory ProgressUpdate.fromJson(Map<String, dynamic> json) =
      _$ProgressUpdateFromJson;
}

/// 检查成就响应模型
@freezed
class CheckAchievementResult with _$CheckAchievementResult {
  const factory CheckAchievementResult({
    @Default([]) List<NewlyUnlockedAchievement> newlyUnlocked,
    @Default([]) List<ProgressUpdate> progressUpdated,
  }) = _CheckAchievementResult;

  factory CheckAchievementResult.fromJson(Map<String, dynamic> json) =
      _$CheckAchievementResultFromJson;
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

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =
      _$UserStatsModelFromJson;
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

  factory TrailStats.fromJson(Map<String, dynamic> json) =
      _$TrailStatsFromJson;
}
