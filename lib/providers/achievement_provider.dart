// ================================================================
// Achievement Provider
// 成就系统状态管理
// ================================================================

import 'package:flutter/foundation.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';

/// 成就状态管理类
class AchievementProvider extends ChangeNotifier {
  final AchievementService _achievementService = AchievementService.instance;

  // 状态
  UserAchievementSummary? _summary;
  UserStatsModel? _stats;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserAchievementSummary? get summary => _summary;
  UserStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 是否有新解锁成就
  bool get hasNewAchievements => _summary?.newUnlockedCount > 0 ?? false;

  // 解锁成就数量
  int get unlockedCount => _summary?.unlockedCount ?? 0;

  // 总成就数量
  int get totalCount => _summary?.totalCount ?? 0;

  /// 加载用户成就
  Future<void> loadUserAchievements({bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _achievementService.getUserAchievements(
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载用户统计
  Future<void> loadUserStats() async {
    try {
      _stats = await _achievementService.getUserStats();
      notifyListeners();
    } catch (e) {
      debugPrint('加载用户统计失败: $e');
    }
  }

  /// 检查并解锁成就
  Future<CheckAchievementResult> checkAchievements({
    required String triggerType,
    String? trailId,
    TrailStats? stats,
  }) async {
    try {
      final result = await _achievementService.checkAchievements(
        triggerType: triggerType,
        trailId: trailId,
        stats: stats,
      );

      // 如果有新解锁，刷新列表
      if (result.newlyUnlocked.isNotEmpty) {
        await loadUserAchievements(forceRefresh: true);
      }

      return result;
    } catch (e) {
      debugPrint('检查成就失败: $e');
      return const CheckAchievementResult();
    }
  }

  /// 标记成就已查看
  Future<void> markAchievementViewed(String achievementId) async {
    final success = await _achievementService.markAchievementViewed(achievementId);
    if (success) {
      // 更新本地状态
      if (_summary != null) {
        final updatedAchievements = _summary!.achievements.map((a) {
          if (a.achievementId == achievementId) {
            return a.copyWith(isNew: false);
          }
          return a;
        }).toList();

        _summary = _summary!.copyWith(
          achievements: updatedAchievements,
          newUnlockedCount: _summary!.newUnlockedCount - 1,
        );
        notifyListeners();
      }
    }
  }

  /// 标记所有成就已查看
  Future<void> markAllAchievementsViewed() async {
    final success = await _achievementService.markAllAchievementsViewed();
    if (success) {
      // 更新本地状态
      if (_summary != null) {
        final updatedAchievements = _summary!.achievements.map((a) {
          if (a.isNew) {
            return a.copyWith(isNew: false);
          }
          return a;
        }).toList();

        _summary = _summary!.copyWith(
          achievements: updatedAchievements,
          newUnlockedCount: 0,
        );
        notifyListeners();
      }
    }
  }

  /// 按类别筛选成就
  List<UserAchievementModel> getAchievementsByCategory(
    AchievementCategory category,
  ) {
    if (_summary == null) return [];
    return _summary!.achievements
        .where((a) => a.category == category.name)
        .toList();
  }

  /// 获取已解锁成就
  List<UserAchievementModel> get unlockedAchievements {
    if (_summary == null) return [];
    return _summary!.achievements.where((a) => a.isUnlocked).toList();
  }

  /// 获取未解锁成就
  List<UserAchievementModel> get lockedAchievements {
    if (_summary == null) return [];
    return _summary!.achievements.where((a) => !a.isUnlocked).toList();
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 刷新所有数据
  Future<void> refresh() async {
    await Future.wait([
      loadUserAchievements(forceRefresh: true),
      loadUserStats(),
    ]);
  }
}
