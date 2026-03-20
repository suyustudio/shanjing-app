// ================================================================
// Achievement Service
// 成就系统服务层 (Enhanced with Timeout, Retry & Structured Logging)
// ================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../constants/achievement_constants.dart';
import '../models/achievement_model.dart';

/// 成就服务类
class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  static AchievementService get instance => _instance;

  AchievementService._internal();

  final RetryableHttpClient _client = RetryableHttpClient();

  // 成就解锁流控制器
  final _achievementUnlockedController =
      StreamController<NewlyUnlockedAchievement>.broadcast();
  Stream<NewlyUnlockedAchievement> get onAchievementUnlocked =>
      _achievementUnlockedController.stream;

  // 缓存
  UserAchievementSummary? _cachedSummary;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = CacheTtl.medium;

  /// 获取所有成就定义
  Future<List<AchievementModel>> getAllAchievements() async {
    final timer = _logPerformance('getAllAchievements');
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/achievements'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> achievements = data['data'];
          timer.end(success: true, count: achievements.length);
          return achievements.map((json) => AchievementModel.fromJson(json)).toList();
        }
      }
      timer.end(success: false, statusCode: response.statusCode);
      return [];
    } on TimeoutException catch (e) {
      debugPrint('获取成就定义超时: $e');
      timer.end(success: false, error: 'timeout');
      return [];
    } on NetworkException catch (e) {
      debugPrint('获取成就定义网络错误: $e');
      timer.end(success: false, error: 'network');
      return [];
    } catch (e) {
      debugPrint('获取成就定义失败: $e');
      timer.end(success: false, error: e.toString());
      return [];
    }
  }

  /// 获取用户成就汇总
  Future<UserAchievementSummary> getUserAchievements({
    bool forceRefresh = false,
  }) async {
    // 检查缓存
    if (!forceRefresh &&
        _cachedSummary != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      _logDebug('返回缓存的用户成就数据');
      return _cachedSummary!;
    }

    final timer = _logPerformance('getUserAchievements');
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/achievements/user/me'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final summary = UserAchievementSummary.fromJson(data['data']);

          // 更新缓存
          _cachedSummary = summary;
          _cacheTime = DateTime.now();

          timer.end(
            success: true,
            totalCount: summary.totalCount,
            unlockedCount: summary.unlockedCount,
          );
          return summary;
        }
      }
      timer.end(success: false, statusCode: response.statusCode);
      return const UserAchievementSummary();
    } on TimeoutException catch (e) {
      debugPrint('获取用户成就超时: $e');
      timer.end(success: false, error: 'timeout');
      return const UserAchievementSummary();
    } on NetworkException catch (e) {
      debugPrint('获取用户成就网络错误: $e');
      timer.end(success: false, error: 'network');
      return const UserAchievementSummary();
    } catch (e) {
      debugPrint('获取用户成就失败: $e');
      timer.end(success: false, error: e.toString());
      return const UserAchievementSummary();
    }
  }

  /// 获取指定用户成就
  Future<UserAchievementSummary> getUserAchievementsById(String userId) async {
    final timer = _logPerformance('getUserAchievementsById', {'userId': userId});
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/achievements/user/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          timer.end(success: true, userId: userId);
          return UserAchievementSummary.fromJson(data['data']);
        }
      }
      timer.end(success: false, statusCode: response.statusCode);
      return const UserAchievementSummary();
    } on TimeoutException catch (e) {
      debugPrint('获取用户成就超时: $e');
      timer.end(success: false, error: 'timeout');
      return const UserAchievementSummary();
    } on NetworkException catch (e) {
      debugPrint('获取用户成就网络错误: $e');
      timer.end(success: false, error: 'network');
      return const UserAchievementSummary();
    } catch (e) {
      debugPrint('获取用户成就失败: $e');
      timer.end(success: false, error: e.toString());
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
    final timer = _logPerformance('checkAchievements', {
      'triggerType': triggerType,
      'trailId': trailId,
    });

    // 验证触发类型
    if (!AchievementConstants.validTriggerTypes.contains(triggerType)) {
      debugPrint('无效的触发类型: $triggerType');
      timer.end(success: false, error: 'invalid_trigger_type');
      return const CheckAchievementResult();
    }

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

      final response = await _client.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/achievements/check'),
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final result = CheckAchievementResult.fromJson(data['data']);

          // 发送解锁事件
          for (final achievement in result.newlyUnlocked) {
            _achievementUnlockedController.add(achievement);
          }

          // 清除缓存
          _cachedSummary = null;

          timer.end(
            success: true,
            newlyUnlockedCount: result.newlyUnlocked.length,
            progressUpdatedCount: result.progressUpdated.length,
          );
          return result;
        }
      }
      timer.end(success: false, statusCode: response.statusCode);
      return const CheckAchievementResult();
    } on TimeoutException catch (e) {
      debugPrint('检查成就超时: $e');
      timer.end(success: false, error: 'timeout');
      return const CheckAchievementResult();
    } on NetworkException catch (e) {
      debugPrint('检查成就网络错误: $e');
      timer.end(success: false, error: 'network');
      return const CheckAchievementResult();
    } catch (e) {
      debugPrint('检查成就失败: $e');
      timer.end(success: false, error: e.toString());
      return const CheckAchievementResult();
    }
  }

  /// 标记成就已查看
  Future<bool> markAchievementViewed(String achievementId) async {
    final timer = _logPerformance('markAchievementViewed', {'achievementId': achievementId});
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/achievements/$achievementId/viewed'),
      );

      final success = response.statusCode == 200;
      timer.end(success: success, statusCode: response.statusCode);
      return success;
    } on TimeoutException catch (e) {
      debugPrint('标记成就已查看超时: $e');
      timer.end(success: false, error: 'timeout');
      return false;
    } on NetworkException catch (e) {
      debugPrint('标记成就已查看网络错误: $e');
      timer.end(success: false, error: 'network');
      return false;
    } catch (e) {
      debugPrint('标记成就已查看失败: $e');
      timer.end(success: false, error: e.toString());
      return false;
    }
  }

  /// 标记所有成就已查看
  Future<bool> markAllAchievementsViewed() async {
    final timer = _logPerformance('markAllAchievementsViewed');
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.apiBaseUrl}/achievements/viewed/all'),
      );

      final success = response.statusCode == 200;
      if (success) {
        _cachedSummary = null;
      }
      timer.end(success: success, statusCode: response.statusCode);
      return success;
    } on TimeoutException catch (e) {
      debugPrint('标记所有成就已查看超时: $e');
      timer.end(success: false, error: 'timeout');
      return false;
    } on NetworkException catch (e) {
      debugPrint('标记所有成就已查看网络错误: $e');
      timer.end(success: false, error: 'network');
      return false;
    } catch (e) {
      debugPrint('标记所有成就已查看失败: $e');
      timer.end(success: false, error: e.toString());
      return false;
    }
  }

  /// 获取用户统计
  Future<UserStatsModel> getUserStats() async {
    final timer = _logPerformance('getUserStats');
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.apiBaseUrl}/users/me/stats'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          timer.end(success: true);
          return UserStatsModel.fromJson(data['data']);
        }
      }
      timer.end(success: false, statusCode: response.statusCode);
      return const UserStatsModel();
    } on TimeoutException catch (e) {
      debugPrint('获取用户统计超时: $e');
      timer.end(success: false, error: 'timeout');
      return const UserStatsModel();
    } on NetworkException catch (e) {
      debugPrint('获取用户统计网络错误: $e');
      timer.end(success: false, error: 'network');
      return const UserStatsModel();
    } catch (e) {
      debugPrint('获取用户统计失败: $e');
      timer.end(success: false, error: e.toString());
      return const UserStatsModel();
    }
  }

  /// 清除缓存
  void clearCache() {
    _cachedSummary = null;
    _cacheTime = null;
    _logDebug('缓存已清除');
  }

  /// 释放资源
  void dispose() {
    _achievementUnlockedController.close();
    _client.close();
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
        if (value >= DistanceConstants.oneKm) {
          return '${(value / DistanceConstants.oneKm).toStringAsFixed(1)}km';
        }
        return '${value}m';
      case AchievementCategory.frequency:
        return '$value周';
      default:
        return '$value次';
    }
  }

  // ==================== 日志辅助 ====================

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[AchievementService] $message');
    }
  }

  _PerformanceTimer _logPerformance(String operation, [Map<String, dynamic>? context]) {
    return _PerformanceTimer(operation, context);
  }
}

/// 性能计时器
class _PerformanceTimer {
  final String operation;
  final Map<String, dynamic>? context;
  final DateTime _startTime;

  _PerformanceTimer(this.operation, [this.context]) : _startTime = DateTime.now();

  void end({
    bool success = true,
    int? statusCode,
    String? error,
    int? count,
    int? totalCount,
    int? unlockedCount,
    int? newlyUnlockedCount,
    int? progressUpdatedCount,
    String? userId,
    String? achievementId,
    String? triggerType,
    String? trailId,
  }) {
    final duration = DateTime.now().difference(_startTime);
    final buffer = StringBuffer();
    buffer.write('[PERF] operation=$operation');
    buffer.write(' duration=${duration.inMilliseconds}ms');
    buffer.write(' status=${success ? 'SUCCESS' : 'FAILED'}');

    if (context != null) {
      context.forEach((key, value) {
        buffer.write(' $key=$value');
      });
    }

    if (statusCode != null) buffer.write(' statusCode=$statusCode');
    if (error != null) buffer.write(' error=$error');
    if (count != null) buffer.write(' count=$count');
    if (totalCount != null) buffer.write(' totalCount=$totalCount');
    if (unlockedCount != null) buffer.write(' unlockedCount=$unlockedCount');
    if (newlyUnlockedCount != null) buffer.write(' newlyUnlockedCount=$newlyUnlockedCount');
    if (progressUpdatedCount != null) buffer.write(' progressUpdatedCount=$progressUpdatedCount');
    if (userId != null) buffer.write(' userId=$userId');
    if (achievementId != null) buffer.write(' achievementId=$achievementId');
    if (triggerType != null) buffer.write(' triggerType=$triggerType');
    if (trailId != null) buffer.write(' trailId=$trailId');

    // 慢操作警告 (>500ms)
    if (duration.inMilliseconds > 500) {
      buffer.write(' [SLOW]');
      debugPrint('[AchievementService] ${buffer.toString()}');
    } else if (kDebugMode) {
      debugPrint('[AchievementService] ${buffer.toString()}');
    }
  }
}
