import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';

/// 成就系统集成混入
/// 用于在导航完成、收藏路线等场景自动检查成就
mixin AchievementIntegrationMixin <T extends StatefulWidget> on State<T> {
  final AchievementService _achievementService = AchievementService();

  /// 导航完成后调用成就检查
  /// 
  /// [trailId] 路线ID
  /// [distance] 距离（米）
  /// [duration] 时长（秒）
  /// [isNight] 是否夜间
  /// [isRain] 是否雨天
  /// [isSolo] 是否独自
  Future<AchievementCheckResult?> checkTrailCompleted({
    required String trailId,
    required int distance,
    required int duration,
    bool isNight = false,
    bool isRain = false,
    bool isSolo = false,
  }) async {
    try {
      final stats = TrailStats(
        distance: distance,
        duration: duration,
        isNight: isNight,
        isRain: isRain,
        isSolo: isSolo,
      );

      final result = await _achievementService.checkAchievements(
        triggerType: 'trail_completed',
        trailId: trailId,
        stats: stats,
      );

      return result;
    } catch (e) {
      debugPrint('Achievement check failed: $e');
      return null;
    }
  }

  /// 收藏路线后调用成就检查
  /// 
  /// [trailId] 路线ID
  Future<void> checkBookmarkTrail(String trailId) async {
    try {
      // 收藏成就通常基于收藏数量触发
      // 这里触发一次检查，实际逻辑在服务端统计收藏数量
      await _achievementService.checkAchievements(
        triggerType: 'bookmark',
        trailId: trailId,
      );
    } catch (e) {
      debugPrint('Bookmark achievement check failed: $e');
    }
  }

  /// 分享后调用成就检查
  /// 
  /// [trailId] 路线ID（可选）
  Future<AchievementCheckResult?> checkShare({String? trailId}) async {
    try {
      final result = await _achievementService.checkAchievements(
        triggerType: 'share',
        trailId: trailId,
      );

      return result;
    } catch (e) {
      debugPrint('Share achievement check failed: $e');
      return null;
    }
  }

  /// 显示成就解锁弹窗
  void showAchievementUnlock(
    NewlyUnlockedAchievement achievement, {
    VoidCallback? onDismiss,
    VoidCallback? onShare,
  }) {
    if (!mounted) return;

    // 这里需要通过 Navigator 显示弹窗
    // 实际项目中应该导入 AchievementUnlockDialog
    // showDialog(...)
  }
}

/// 导航完成后的成就检查辅助类
class TrailCompletionChecker {
  static final AchievementService _achievementService = AchievementService();

  /// 检查导航完成成就
  /// 
  /// 在导航完成后调用此方法
  static Future<List<NewlyUnlockedAchievement>> check({
    required String trailId,
    required int distance,
    required int duration,
    DateTime? startTime,
    DateTime? endTime,
    bool isRain = false,
    bool isSolo = false,
  }) async {
    final isNight = _isNightTime(startTime, endTime);

    final stats = TrailStats(
      distance: distance,
      duration: duration,
      isNight: isNight,
      isRain: isRain,
      isSolo: isSolo,
    );

    try {
      final result = await _achievementService.checkAchievements(
        triggerType: 'trail_completed',
        trailId: trailId,
        stats: stats,
      );

      return result.newlyUnlocked;
    } catch (e) {
      debugPrint('Trail completion check failed: $e');
      return [];
    }
  }

  /// 判断是否为夜间徒步（18:00 - 06:00）
  static bool _isNightTime(DateTime? startTime, DateTime? endTime) {
    if (startTime == null && endTime == null) return false;

    final time = endTime ?? startTime!;
    final hour = time.hour;

    return hour >= 18 || hour < 6;
  }
}

/// 收藏成就检查辅助类
class BookmarkAchievementChecker {
  static final AchievementService _achievementService = AchievementService();

  /// 检查收藏成就
  /// 
  /// 在收藏路线后调用此方法
  static Future<void> check(String trailId) async {
    try {
      await _achievementService.checkAchievements(
        triggerType: 'manual',
        trailId: trailId,
      );
    } catch (e) {
      debugPrint('Bookmark achievement check failed: $e');
    }
  }
}
