import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../screens/achievements/achievement_unlock_dialog.dart';

/// 成就系统集成管理器
/// 提供全局的成就检查入口点
class AchievementIntegrationManager {
  static final AchievementIntegrationManager _instance =
      AchievementIntegrationManager._internal();
  factory AchievementIntegrationManager() => _instance;
  AchievementIntegrationManager._internal();

  final AchievementService _achievementService = AchievementService();
  BuildContext? _context;

  /// 初始化
  void initialize(BuildContext context) {
    _context = context;
    _setupRealtimeListener();
  }

  /// 设置实时通知监听
  void _setupRealtimeListener() {
    _achievementService.onAchievementUnlocked.listen((achievement) {
      if (_context != null && _context!.mounted) {
        _showUnlockDialog(_context!, achievement);
      }
    });
  }

  /// 显示解锁弹窗
  void _showUnlockDialog(
    BuildContext context,
    NewlyUnlockedAchievement achievement,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AchievementUnlockDialog(
        achievement: achievement,
        onDismiss: () {
          Navigator.of(dialogContext).pop();
          HapticFeedback.mediumImpact();
        },
        onShare: () {
          // TODO: 实现分享功能
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  /// 导航完成后检查成就
  /// 
  /// 在导航页面结束时调用
  Future<AchievementCheckResult?> onTrailCompleted({
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

      // 如果立即有解锁的成就，显示弹窗
      if (_context != null && _context!.mounted) {
        for (final unlocked in result.newlyUnlocked) {
          _showUnlockDialog(_context!, unlocked);
        }
      }

      return result;
    } catch (e) {
      debugPrint('Trail completion achievement check failed: $e');
      return null;
    }
  }

  /// 收藏路线后检查成就
  /// 
  /// 在收藏路线后调用
  Future<void> onTrailBookmarked(String trailId) async {
    try {
      await _achievementService.checkAchievements(
        triggerType: 'manual',
        trailId: trailId,
      );
    } catch (e) {
      debugPrint('Bookmark achievement check failed: $e');
    }
  }

  /// 分享路线后检查成就
  /// 
  /// 在分享路线后调用
  Future<void> onTrailShared(String? trailId) async {
    try {
      await _achievementService.checkAchievements(
        triggerType: 'share',
        trailId: trailId,
      );
    } catch (e) {
      debugPrint('Share achievement check failed: $e');
    }
  }

  /// 手动触发成就检查
  /// 
  /// 用于测试或其他特殊场景
  Future<AchievementCheckResult?> manualCheck() async {
    try {
      final result = await _achievementService.checkAchievements(
        triggerType: 'manual',
      );

      return result;
    } catch (e) {
      debugPrint('Manual achievement check failed: $e');
      return null;
    }
  }

  /// 判断是否为夜间
  bool _isNightTime(DateTime? startTime, DateTime? endTime) {
    if (startTime == null && endTime == null) return false;
    final time = endTime ?? startTime!;
    final hour = time.hour;
    return hour >= 18 || hour < 6;
  }

  /// 清理
  void dispose() {
    _context = null;
  }
}

/// 全局扩展方法，方便在页面中调用
extension AchievementIntegrationExtension on State {
  /// 获取成就管理器
  AchievementIntegrationManager get achievementManager {
    return AchievementIntegrationManager();
  }

  /// 检查导航完成成就
  Future<AchievementCheckResult?> checkTrailAchievements({
    required String trailId,
    required int distance,
    required int duration,
    DateTime? startTime,
    DateTime? endTime,
    bool isRain = false,
    bool isSolo = false,
  }) {
    return achievementManager.onTrailCompleted(
      trailId: trailId,
      distance: distance,
      duration: duration,
      startTime: startTime,
      endTime: endTime,
      isRain: isRain,
      isSolo: isSolo,
    );
  }

  /// 检查收藏成就
  Future<void> checkBookmarkAchievements(String trailId) {
    return achievementManager.onTrailBookmarked(trailId);
  }
}
