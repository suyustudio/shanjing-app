/// 用户行为相关事件定义
class UserEvents {
  UserEvents._();

  // ===== 应用生命周期事件 =====
  static const String appLaunch = 'app_launch';
  static const String appBackground = 'app_background';
  static const String appForeground = 'app_foreground';
  
  // ===== 搜索和筛选事件 =====
  static const String search = 'search';
  static const String filterUse = 'filter_use';
  
  // ===== 登录/注册事件 (M3) =====
  static const String login = 'login';
  static const String register = 'register';
  static const String sendSmsCode = 'send_sms_code';
  static const String loginAttempt = 'login_attempt';
  static const String loginSuccess = 'login_success';
  static const String loginFailed = 'login_failed';
  static const String registerAttempt = 'register_attempt';
  static const String registerSuccess = 'register_success';
  static const String registerFailed = 'register_failed';
  static const String logout = 'logout';

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
  static const String paramPhone = 'phone';
  static const String paramMethod = 'method';
  static const String paramUserId = 'user_id';
  static const String paramError = 'error';
  static const String paramErrorCode = 'error_code';
}
