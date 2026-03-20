// ================================================================
// Achievement Service
// 成就系统服务层
// ================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/achievement_model.dart';

/// 成就服务类
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  static AchievementService get instance => _instance;

  AchievementService._internal();

  final ApiService _apiService = ApiService.instance;

  // 成就解锁流控制器
  final _achievementUnlockedController =
      StreamController<NewlyUnlockedAchievement>.broadcast();
  Stream<NewlyUnlockedAchievement> get onAchievementUnlocked =>
      _achievementUnlockedController.stream;

  // 缓存
  UserAchievementSummary? _cachedSummary;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  /// 获取所有成就定义
  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      final response = await _apiService.get('/achievements');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => AchievementModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('获取成就定义失败: $e');
      return [];
    }
  }

  /// 获取用户成就汇总
  Future<UserAchievementSummary> getUserAchievements({
    bool forceRefresh = false,
  }) async {
    // 检查缓存
    if (!forceRefresh &&&
        _cachedSummary != null &&&amp;
        _cacheTime != null &&&amp;
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedSummary!;
    }

    try {
      final response = await _apiService.get('/achievements/user/me');
      final summary = UserAchievementSummary.fromJson(response['data']);

      // 更新缓存
      _cachedSummary = summary;
      _cacheTime = DateTime.now();

      return summary;
    } catch (e) {
      debugPrint('获取用户成就失败: $e');
      return const UserAchievementSummary();
    }
  }

  /// 获取指定用户成就
  Future<UserAchievementSummary> getUserAchievementsById(String userId) async {
    try {
      final response = await _apiService.get('/achievements/user/$userId');
      return UserAchievementSummary.fromJson(response['data']);
    } catch (e) {
      debugPrint('获取用户成就失败: $e');
      return const UserAchievementSummary();
    }
  }

  /// 检查并解锁成就
  /// 
  /// [triggerType] 触发类型: trail_completed, share, manual
  /// [trailId] 路线ID（可选）
  /// [stats] 轨迹统计数据（可选）
  Future<CheckAchievementResult> checkAchievements({
    required String triggerType,
    String? trailId,
    TrailStats? stats,
  }) async {
    try {
      final body = <String, dynamic>{
        'triggerType': triggerType,
      };

      if (trailId != null) {
        body['trailId'] = trailId;
      }

      if (stats != null) {
        body['stats'] = {
          'distance': stats.distance,
          'duration': stats.duration,
          'isNight': stats.isNight,
          'isRain': stats.isRain,
          'isSolo': stats.isSolo,
        };
      }

      final response = await _apiService.post('/achievements/check', body: body);
      final result = CheckAchievementResult.fromJson(response['data']);

      // 发送解锁事件
      for (final achievement in result.newlyUnlocked) {
        _achievementUnlockedController.add(achievement);
      }

      // 清除缓存
      _cachedSummary = null;

      return result;
    } catch (e) {
      debugPrint('检查成就失败: $e');
      return const CheckAchievementResult();
    }
  }

  /// 标记成就已查看
  Future<bool> markAchievementViewed(String achievementId) async {
    try {
      await _apiService.put('/achievements/$achievementId/viewed');
      return true;
    } catch (e) {
      debugPrint('标记成就已查看失败: $e');
      return false;
    }
  }

  /// 标记所有成就已查看
  Future<bool> markAllAchievementsViewed() async {
    try {
      await _apiService.put('/achievements/viewed/all');
      _cachedSummary = null;
      return true;
    } catch (e) {
      debugPrint('标记所有成就已查看失败: $e');
      return false;
    }
  }

  /// 获取用户统计
  Future<UserStatsModel> getUserStats() async {
    try {
      final response = await _apiService.get('/users/me/stats');
      return UserStatsModel.fromJson(response['data']);
    } catch (e) {
      debugPrint('获取用户统计失败: $e');
      return const UserStatsModel();
    }
  }

  /// 清除缓存
  void clearCache() {
    _cachedSummary = null;
    _cacheTime = null;
  }

  /// 释放资源
  void dispose() {
    _achievementUnlockedController.close();
  }

  // ==================== 辅助方法 ====================

  /// 获取成就类别显示名称
  static String getCategoryDisplayName(AchievementCategory category) {
    switch (category) {
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

  /// 获取成就等级显示名称
  static String getLevelDisplayName(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return '铜';
      case AchievementLevel.silver:
        return '银';
      case AchievementLevel.gold:
        return '金';
      case AchievementLevel.diamond:
        return '钻石';
    }
  }

  /// 获取成就等级颜色
  static int getLevelColor(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return 0xFFCD7F32;
      case AchievementLevel.silver:
        return 0xFFC0C0C0;
      case AchievementLevel.gold:
        return 0xFFFFD700;
      case AchievementLevel.diamond:
        return 0xFF00CED1;
    }
  }

  /// 格式化进度数值
  static String formatProgress(int value, AchievementCategory category) {
    switch (category) {
      case AchievementCategory.distance:
        // 距离转换为公里
        if (value >= 1000) {
          return '${(value / 1000).toStringAsFixed(1)}km';
        }
        return '${value}m';
      case AchievementCategory.frequency:
        return '$value周';
      default:
        return '$value次';
    }
  }
}
