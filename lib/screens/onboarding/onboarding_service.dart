import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 新手引导状态枚举
enum OnboardingStatus {
  notStarted, // 从未启动
  inProgress, // 进行中
  completed, // 已完成
  skipped, // 已跳过
}

/// 新手引导服务
/// 管理引导完成状态、当前步骤和重置功能
class OnboardingService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyOnboardingSkipped = 'onboarding_skipped';
  static const String _keyOnboardingCurrentPage = 'onboarding_current_page';
  static const String _keyOnboardingVersion = 'onboarding_version';
  static const String _currentVersion = '1.0';

  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  SharedPreferences? _prefs;

  /// 初始化服务
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 确保已初始化
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  /// 检查是否需要显示新手引导
  Future<bool> shouldShowOnboarding() async {
    await _ensureInitialized();

    final completed = _prefs?.getBool(_keyOnboardingCompleted) ?? false;
    final skipped = _prefs?.getBool(_keyOnboardingSkipped) ?? false;
    final version = _prefs?.getString(_keyOnboardingVersion);

    // 如果版本变更，需要重新显示引导
    if (version != _currentVersion) {
      return true;
    }

    return !completed && !skipped;
  }

  /// 获取当前引导状态
  Future<OnboardingStatus> getStatus() async {
    await _ensureInitialized();

    final completed = _prefs?.getBool(_keyOnboardingCompleted) ?? false;
    final skipped = _prefs?.getBool(_keyOnboardingSkipped) ?? false;
    final currentPage = _prefs?.getInt(_keyOnboardingCurrentPage) ?? 0;

    if (completed) return OnboardingStatus.completed;
    if (skipped) return OnboardingStatus.skipped;
    if (currentPage > 0) return OnboardingStatus.inProgress;
    return OnboardingStatus.notStarted;
  }

  /// 获取当前页面索引
  Future<int> getCurrentPage() async {
    await _ensureInitialized();
    return _prefs?.getInt(_keyOnboardingCurrentPage) ?? 0;
  }

  /// 更新当前页面索引
  Future<void> setCurrentPage(int page) async {
    await _ensureInitialized();
    await _prefs?.setInt(_keyOnboardingCurrentPage, page);
  }

  /// 标记引导完成
  Future<void> markCompleted() async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyOnboardingCompleted, true);
    await _prefs?.setBool(_keyOnboardingSkipped, false);
    await _prefs?.setString(_keyOnboardingVersion, _currentVersion);
    await _prefs?.setInt(_keyOnboardingCurrentPage, 0);

    if (kDebugMode) {
      print('[OnboardingService] 引导已标记为完成');
    }
  }

  /// 标记引导跳过
  Future<void> markSkipped() async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyOnboardingSkipped, true);
    await _prefs?.setString(_keyOnboardingVersion, _currentVersion);

    if (kDebugMode) {
      print('[OnboardingService] 引导已标记为跳过');
    }
  }

  /// 重置引导状态（用于重新触发）
  Future<void> reset() async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyOnboardingCompleted, false);
    await _prefs?.setBool(_keyOnboardingSkipped, false);
    await _prefs?.setInt(_keyOnboardingCurrentPage, 0);
    await _prefs?.remove(_keyOnboardingVersion);

    if (kDebugMode) {
      print('[OnboardingService] 引导状态已重置');
    }
  }

  /// 获取引导完成时间
  Future<DateTime?> getCompletedAt() async {
    await _ensureInitialized();
    final timestamp = _prefs?.getInt('onboarding_completed_at');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// 设置引导完成时间
  Future<void> setCompletedAt() async {
    await _ensureInitialized();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs?.setInt('onboarding_completed_at', now);
  }

  /// 记录引导开始时间（用于计算时长）
  Future<void> markStarted() async {
    await _ensureInitialized();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs?.setInt('onboarding_started_at', now);
  }

  /// 获取引导开始时间
  Future<DateTime?> getStartedAt() async {
    await _ensureInitialized();
    final timestamp = _prefs?.getInt('onboarding_started_at');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// 计算引导持续时间（秒）
  Future<int> getDurationSeconds() async {
    final startedAt = await getStartedAt();
    final completedAt = await getCompletedAt();

    if (startedAt != null && completedAt != null) {
      return completedAt.difference(startedAt).inSeconds;
    }
    return 0;
  }
}
