// ================================================================
// Achievement State Manager
// 成就系统状态管理 - 支持错误状态显示
// ================================================================

import 'package:flutter/foundation.dart';
import '../models/achievement_model.dart';
import 'achievement_errors.dart';

/// 加载状态
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// 成就列表状态
class AchievementListState {
  final LoadingState state;
  final List<AchievementModel>? achievements;
  final AchievementServiceError? error;

  const AchievementListState({
    this.state = LoadingState.idle,
    this.achievements,
    this.error,
  });

  const AchievementListState.idle() : this(state: LoadingState.idle);
  const AchievementListState.loading() : this(state: LoadingState.loading);
  
  const AchievementListState.success(List<AchievementModel> data)
    : this(state: LoadingState.success, achievements: data);
  
  const AchievementListState.error(AchievementServiceError err)
    : this(state: LoadingState.error, error: err);

  bool get isLoading => state == LoadingState.loading;
  bool get hasError => state == LoadingState.error;
  bool get hasData => achievements != null && achievements!.isNotEmpty;
}

/// 用户成就状态
class UserAchievementState {
  final LoadingState state;
  final UserAchievementSummary? summary;
  final AchievementServiceError? error;

  const UserAchievementState({
    this.state = LoadingState.idle,
    this.summary,
    this.error,
  });

  const UserAchievementState.idle() : this(state: LoadingState.idle);
  const UserAchievementState.loading() : this(state: LoadingState.loading);
  
  const UserAchievementState.success(UserAchievementSummary data)
    : this(state: LoadingState.success, summary: data);
  
  const UserAchievementState.error(AchievementServiceError err)
    : this(state: LoadingState.error, error: err);

  bool get isLoading => state == LoadingState.loading;
  bool get hasError => state == LoadingState.error;
  bool get hasData => summary != null;
  int get unlockedCount => summary?.unlockedCount ?? 0;
  int get totalCount => summary?.totalCount ?? 0;
}

/// 检查成就状态
class CheckAchievementState {
  final LoadingState state;
  final CheckAchievementResult? result;
  final AchievementServiceError? error;

  const CheckAchievementState({
    this.state = LoadingState.idle,
    this.result,
    this.error,
  });

  const CheckAchievementState.idle() : this(state: LoadingState.idle);
  const CheckAchievementState.loading() : this(state: LoadingState.loading);
  
  const CheckAchievementState.success(CheckAchievementResult data)
    : this(state: LoadingState.success, result: data);
  
  const CheckAchievementState.error(AchievementServiceError err)
    : this(state: LoadingState.error, error: err);

  bool get isLoading => state == LoadingState.loading;
  bool get hasError => state == LoadingState.error;
  bool get hasNewUnlocks => 
    result != null && result!.newlyUnlocked.isNotEmpty;
  List<NewlyUnlockedAchievement> get newUnlocks => 
    result?.newlyUnlocked ?? [];
}

/// 成就状态管理器
class AchievementStateManager extends ChangeNotifier {
  // 状态
  AchievementListState _achievementListState = const AchievementListState.idle();
  UserAchievementState _userAchievementState = const UserAchievementState.idle();
  CheckAchievementState _checkAchievementState = const CheckAchievementState.idle();

  // Getters
  AchievementListState get achievementListState => _achievementListState;
  UserAchievementState get userAchievementState => _userAchievementState;
  CheckAchievementState get checkAchievementState => _checkAchievementState;

  // 设置成就列表状态
  void setAchievementListState(AchievementListState state) {
    _achievementListState = state;
    notifyListeners();
  }

  // 设置用户成就状态
  void setUserAchievementState(UserAchievementState state) {
    _userAchievementState = state;
    notifyListeners();
  }

  // 设置检查成就状态
  void setCheckAchievementState(CheckAchievementState state) {
    _checkAchievementState = state;
    notifyListeners();
  }

  // 重置所有状态
  void reset() {
    _achievementListState = const AchievementListState.idle();
    _userAchievementState = const UserAchievementState.idle();
    _checkAchievementState = const CheckAchievementState.idle();
    notifyListeners();
  }

  // ==================== 便捷方法 ====================

  /// 开始加载成就列表
  void startLoadingAchievements() {
    setAchievementListState(const AchievementListState.loading());
  }

  /// 成就列表加载成功
  void achievementsLoaded(List<AchievementModel> achievements) {
    setAchievementListState(AchievementListState.success(achievements));
  }

  /// 成就列表加载失败
  void achievementsLoadFailed(AchievementServiceError error) {
    setAchievementListState(AchievementListState.error(error));
  }

  /// 开始加载用户成就
  void startLoadingUserAchievements() {
    setUserAchievementState(const UserAchievementState.loading());
  }

  /// 用户成就加载成功
  void userAchievementsLoaded(UserAchievementSummary summary) {
    setUserAchievementState(UserAchievementState.success(summary));
  }

  /// 用户成就加载失败
  void userAchievementsLoadFailed(AchievementServiceError error) {
    setUserAchievementState(UserAchievementState.error(error));
  }

  /// 开始检查成就
  void startCheckingAchievements() {
    setCheckAchievementState(const CheckAchievementState.loading());
  }

  /// 检查成就成功
  void achievementsChecked(CheckAchievementResult result) {
    setCheckAchievementState(CheckAchievementState.success(result));
  }

  /// 检查成就失败
  void achievementsCheckFailed(AchievementServiceError error) {
    setCheckAchievementState(CheckAchievementState.error(error));
  }

  /// 清除错误状态
  void clearErrors() {
    if (_achievementListState.hasError) {
      _achievementListState = const AchievementListState.idle();
    }
    if (_userAchievementState.hasError) {
      _userAchievementState = const UserAchievementState.idle();
    }
    if (_checkAchievementState.hasError) {
      _checkAchievementState = const CheckAchievementState.idle();
    }
    notifyListeners();
  }
}

/// 错误信息本地化
class AchievementErrorLocalizations {
  /// 获取错误显示的标题
  static String getErrorTitle(AchievementServiceError error) {
    switch (error.code) {
      case 'NETWORK_ERROR':
        return '网络连接失败';
      case 'SERVER_ERROR':
        return '服务器错误';
      case 'VALIDATION_ERROR':
        return '输入有误';
      case 'ACHIEVEMENT_NOT_FOUND':
        return '成就不存在';
      case 'INVALID_TRIGGER_TYPE':
        return '操作类型无效';
      case 'CONCURRENT_MODIFICATION':
        return '操作冲突';
      case 'CACHE_ERROR':
        return '缓存错误';
      default:
        return '操作失败';
    }
  }

  /// 获取错误显示的描述
  static String getErrorDescription(AchievementServiceError error) {
    if (error.message.isNotEmpty) {
      return error.message;
    }
    
    switch (error.code) {
      case 'NETWORK_ERROR':
        return '请检查网络连接后重试';
      case 'SERVER_ERROR':
        return '服务器暂时不可用，请稍后重试';
      case 'VALIDATION_ERROR':
        return error is AchievementValidationError
          ? '${error.field}: ${error.constraint}'
          : '请检查输入内容';
      case 'CONCURRENT_MODIFICATION':
        return '数据正在被其他操作修改，请稍后重试';
      default:
        return '发生未知错误，请稍后重试';
    }
  }

  /// 获取建议的操作按钮文本
  static String getActionButtonText(AchievementServiceError error) {
    switch (error.code) {
      case 'NETWORK_ERROR':
      case 'SERVER_ERROR':
      case 'CONCURRENT_MODIFICATION':
        return '重试';
      case 'VALIDATION_ERROR':
        return '修改';
      default:
        return '确定';
    }
  }
}
