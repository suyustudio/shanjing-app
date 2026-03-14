/// 用户行为相关事件定义
class UserEvents {
  UserEvents._();

  // ===== 事件名称 =====
  static const String appLaunch = 'app_launch';
  static const String appBackground = 'app_background';
  static const String appForeground = 'app_foreground';
  static const String search = 'search';
  static const String filterUse = 'filter_use';
  static const String login = 'login';
  static const String register = 'register';

  // ===== 参数键名 =====
  static const String paramLaunchSource = 'source';
  static const String paramLaunchTime = 'launch_time';
  static const String paramSessionDuration = 'session_duration';
  static const String paramSearchKeyword = 'keyword';
  static const String paramSearchResultCount = 'result_count';
  static const String paramFilterType = 'filter_type';
  static const String paramFilterValue = 'filter_value';
  static const String paramLoginType = 'login_type';
  static const String paramLoginSuccess = 'success';
  static const String paramIsNewUser = 'is_new_user';
}
