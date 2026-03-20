// ================================================================
// Achievement Integration
// 成就系统集成工具类
// 
// 使用说明:
// 1. 导航完成后调用 AchievementIntegration.onTrailCompleted()
// 2. 分享功能调用 AchievementIntegration.onShare()
// 3. 收藏路线调用 AchievementIntegration.onFavoriteTrail()
// ================================================================

import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';
import '../screens/achievements/achievement_unlock_dialog.dart';

/// 成就系统集成工具类
class AchievementIntegration {
  AchievementIntegration._();

  static final AchievementIntegration _instance = AchievementIntegration._();
  static AchievementIntegration get instance => _instance;

  final AchievementService _achievementService = AchievementService.instance;

  /// 轨迹完成时检查成就
  /// 
  /// 在导航页面轨迹完成回调中调用:
  /// ```dart
  /// void onTrailCompleted(TrailRecord record) {
  ///   AchievementIntegration.instance.onTrailCompleted(
  ///     context: context,
  ///     trailId: record.trailId,
  ///     distance: record.totalDistanceM,
  ///     duration: record.totalDurationSec,
  ///     isNight: record.isNightHike,
  ///     isRain: record.isRainyWeather,
  ///     isSolo: record.isSoloHike,
  ///   );
  /// }
  /// ```
  Future<void> onTrailCompleted({
    required BuildContext context,
    String? trailId,
    required int distance,
    required int duration,
    bool isNight = false,
    bool isRain = false,
    bool isSolo = false,
  }) async {
    try {
      final result = await _achievementService.checkAchievements(
        triggerType: 'trail_completed',
        trailId: trailId,
        stats: TrailStats(
          distance: distance,
          duration: duration,
          isNight: isNight,
          isRain: isRain,
          isSolo: isSolo,
        ),
      );

      // 显示解锁弹窗
      if (result.newlyUnlocked.isNotEmpty && context.mounted) {
        for (final achievement in result.newlyUnlocked) {
          await AchievementUnlockDialog.show(context, achievement);
        }
      }
    } catch (e) {
      debugPrint('轨迹完成后检查成就失败: $e');
    }
  }

  /// 分享功能触发成就
  /// 
  /// 在分享功能中调用:
  /// ```dart
  /// void onShare() {
  ///   AchievementIntegration.instance.onShare(context: context);
  ///   // ... 原有分享代码
  /// }
  /// ```
  Future<void> onShare({
    required BuildContext context,
    bool showDialog = false,
  }) async {
    try {
      final result = await _achievementService.checkAchievements(
        triggerType: 'share',
      );

      if (result.newlyUnlocked.isNotEmpty && context.mounted && showDialog) {
        for (final achievement in result.newlyUnlocked) {
          await AchievementUnlockDialog.show(context, achievement);
        }
      }
    } catch (e) {
      debugPrint('分享后检查成就失败: $e');
    }
  }

  /// 收藏路线时检查成就
  /// 
  /// 在收藏功能中调用:
  /// ```dart
  /// void onFavoriteTrail(String trailId) {
  ///   AchievementIntegration.instance.onFavoriteTrail(
  ///     context: context,
  ///     trailId: trailId,
  ///   );
  ///   // ... 原有收藏代码
  /// }
  /// ```
  Future<void> onFavoriteTrail({
    required BuildContext context,
    required String trailId,
  }) async {
    try {
      // 收藏行为不直接触发成就解锁，但可以触发统计更新
      await _achievementService.checkAchievements(
        triggerType: 'manual',
      );
    } catch (e) {
      debugPrint('收藏后检查成就失败: $e');
    }
  }

  /// 手动触发成就检查
  /// 
  /// 用于需要手动检查成就的场景
  Future<void> checkAchievementsManually({
    required BuildContext context,
    bool showDialog = true,
  }) async {
    try {
      final result = await _achievementService.checkAchievements(
        triggerType: 'manual',
      );

      if (result.newlyUnlocked.isNotEmpty && context.mounted && showDialog) {
        for (final achievement in result.newlyUnlocked) {
          await AchievementUnlockDialog.show(context, achievement);
        }
      }
    } catch (e) {
      debugPrint('手动检查成就失败: $e');
    }
  }

  /// 显示成就解锁提示 (SnackBar)
  /// 
  /// 如果不想显示全屏弹窗，可以使用轻量级提示
  void showUnlockSnackBar(
    BuildContext context,
    NewlyUnlockedAchievement achievement,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AchievementUnlockSnackBar(achievement: achievement),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

/// 轨迹记录数据类
class TrailRecord {
  final String trailId;
  final int totalDistanceM;
  final int totalDurationSec;
  final bool isNightHike;
  final bool isRainyWeather;
  final bool isSoloHike;
  final DateTime completedAt;

  TrailRecord({
    required this.trailId,
    required this.totalDistanceM,
    required this.totalDurationSec,
    this.isNightHike = false,
    this.isRainyWeather = false,
    this.isSoloHike = false,
    required this.completedAt,
  });
}
