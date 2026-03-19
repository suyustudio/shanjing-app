// auth_service.dart - 用户认证服务
// 山径APP - M3 用户系统
// 功能：登录/注册、Token管理、自动刷新

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../analytics/analytics.dart';

/// API 响应包装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorCode;
  final String? errorMessage;

  ApiResponse({
    required this.success,
    this.data,
    this.errorCode,
    this.errorMessage,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) parser,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? parser(json['data']) : null,
      errorCode: json['error']?['code'],
      errorMessage: json['error']?['message'],
    );
  }
}

/// 用户信息模型
class UserInfo {
  final String id;
  final String? nickname;
  final String? avatarUrl;
  final String? phone;
  final DateTime createdAt;

  UserInfo({
    required this.id,
    this.nickname,
    this.avatarUrl,
    this.phone,
    required this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'avatarUrl': avatarUrl,
    'phone': phone,
    'createdAt': createdAt.toIso8601String(),
  };

  UserInfo copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
    String? phone,
    DateTime? createdAt,
  }) {
    return UserInfo(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Token 信息模型
class TokenInfo {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final DateTime obtainedAt;

  TokenInfo({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.obtainedAt,
  });

  factory TokenInfo.fromJson(Map<String, dynamic> json) {
    return TokenInfo(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
      obtainedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
    'obtainedAt': obtainedAt.toIso8601String(),
  };

  /// 检查 Token 是否即将过期（5分钟内）
  bool get isExpiringSoon {
    final expiryTime = obtainedAt.add(Duration(seconds: expiresIn));
    final now = DateTime.now();
    return expiryTime.difference(now).inMinutes < 5;
  }

  /// 检查 Token 是否已过期
  bool get isExpired {
    final expiryTime = obtainedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expiryTime);
  }
}

/// 认证状态枚举
enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

/// 认证服务类
class AuthService {
  // SharedPreferences keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ==================== 配置 ====================
  
  String _baseUrl = 'https://api.shanjing.app';
  String get baseUrl => _baseUrl;
  
  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  // ==================== 状态管理 ====================
  
  final _authStatusController = StreamController<AuthStatus>.broadcast();
  Stream<AuthStatus> get authStatusStream => _authStatusController.stream;
  
  AuthStatus _authStatus = AuthStatus.uninitialized;
  AuthStatus get authStatus => _authStatus;
  
  UserInfo? _currentUser;
  UserInfo? get currentUser => _currentUser;
  
  TokenInfo? _tokenInfo;
  TokenInfo? get tokenInfo => _tokenInfo;

  // ==================== 持久化Key ====================
  
  static const String _prefsUserKey = 'auth_user';
  static const String _prefsTokenKey = 'auth_token';

  // ==================== 初始化 ====================
  
  /// 初始化认证服务
  Future<void> initialize() async {
    await _loadAuthState();
    _startTokenRefreshTimer();
  }

  /// 从本地存储加载认证状态
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载用户信息
      final userJson = prefs.getString(_prefsUserKey);
      if (userJson != null) {
        _currentUser = UserInfo.fromJson(jsonDecode(userJson));
      }
      
      // 加载 Token 信息
      final tokenJson = prefs.getString(_prefsTokenKey);
      if (tokenJson != null) {
        _tokenInfo = TokenInfo.fromJson(jsonDecode(tokenJson));
        
        // 检查 Token 是否已过期
        if (_tokenInfo!.isExpired) {
          // 尝试刷新 Token
          final refreshed = await _tryRefreshToken();
          if (!refreshed) {
            await _clearAuthState();
            _authStatus = AuthStatus.unauthenticated;
          } else {
            _authStatus = AuthStatus.authenticated;
          }
        } else {
          _authStatus = AuthStatus.authenticated;
        }
      } else {
        _authStatus = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('加载认证状态失败: $e');
      _authStatus = AuthStatus.unauthenticated;
    }
    
    _authStatusController.add(_authStatus);
  }

  /// 保存认证状态到本地
  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentUser != null) {
        await prefs.setString(_prefsUserKey, jsonEncode(_currentUser!.toJson()));
      } else {
        await prefs.remove(_prefsUserKey);
      }
      
      if (_tokenInfo != null) {
        await prefs.setString(_prefsTokenKey, jsonEncode(_tokenInfo!.toJson()));
      } else {
        await prefs.remove(_prefsTokenKey);
      }
    } catch (e) {
      debugPrint('保存认证状态失败: $e');
    }
  }

  /// 清除认证状态
  Future<void> _clearAuthState() async {
    _currentUser = null;
    _tokenInfo = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsUserKey);
      await prefs.remove(_prefsTokenKey);
    } catch (e) {
      debugPrint('清除认证状态失败: $e');
    }
  }

  // ==================== Token 刷新 ====================
  
  Timer? _refreshTimer;

  void _startTokenRefreshTimer() {
    _refreshTimer?.cancel();
    // 每分钟检查一次 Token 是否需要刷新
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_tokenInfo != null && _tokenInfo!.isExpiringSoon) {
        _tryRefreshToken();
      }
    });
  }

  Future<bool> _tryRefreshToken() async {
    if (_tokenInfo == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _tokenInfo!.refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<TokenInfo>.fromJson(
          jsonDecode(response.body),
          (data) => TokenInfo.fromJson(data),
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          _tokenInfo = apiResponse.data;
          await _saveAuthState();
          return true;
        }
      }
    } catch (e) {
      debugPrint('刷新 Token 失败: $e');
    }
    
    return false;
  }

  /// 使用密码登录（简化版）
  Future<ApiResponse<UserInfo>> loginWithPassword(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      
      final apiResponse = ApiResponse.fromJson(
        jsonDecode(response.body),
        (data) => {
          'user': UserInfo.fromJson(data['user']),
          'tokens': TokenInfo.fromJson(data['tokens']),
        },
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        _currentUser = apiResponse.data!['user'] as UserInfo;
        _tokenInfo = apiResponse.data!['tokens'] as TokenInfo;
        await _saveAuthState();
        _authStatus = AuthStatus.authenticated;
        _authStatusController.add(_authStatus);
        
        // 埋点：登录成功
        AnalyticsService().trackEvent(UserEvents.loginSuccess, params: {
          UserEvents.paramUserId: _currentUser?.id,
          UserEvents.paramPhone: phone,
          UserEvents.paramMethod: 'password',
        });
      } else {
        // 埋点：登录失败
        AnalyticsService().trackEvent(UserEvents.loginFailed, params: {
          UserEvents.paramPhone: phone,
          UserEvents.paramMethod: 'password',
          UserEvents.paramErrorCode: apiResponse.errorCode,
          UserEvents.paramErrorMessage: apiResponse.errorMessage,
        });
      }
      
      return ApiResponse(
        success: apiResponse.success,
        data: _currentUser,
        errorCode: apiResponse.errorCode,
        errorMessage: apiResponse.errorMessage,
      );
    } catch (e) {
      // 埋点：登录失败（网络错误）
      AnalyticsService().trackEvent(UserEvents.loginFailed, params: {
        UserEvents.paramPhone: phone,
        UserEvents.paramMethod: 'password',
        UserEvents.paramErrorCode: 'NETWORK_ERROR',
        UserEvents.paramErrorMessage: '网络请求失败: $e',
      });
      return ApiResponse(
        success: false,
        errorCode: 'NETWORK_ERROR',
        errorMessage: '网络请求失败: $e',
      );
    }
  }

  /// 使用密码注册（简化版）
  Future<ApiResponse<UserInfo>> registerWithPassword(
    String phone,
    String password, {
    String? nickname,
  }) async {
    try {
      final body = {
        'phone': phone,
        'password': password,
        if (nickname != null) 'nickname': nickname,
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      final apiResponse = ApiResponse.fromJson(
        jsonDecode(response.body),
        (data) => {
          'user': UserInfo.fromJson(data['user']),
          'tokens': TokenInfo.fromJson(data['tokens']),
        },
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        _currentUser = apiResponse.data!['user'] as UserInfo;
        _tokenInfo = apiResponse.data!['tokens'] as TokenInfo;
        await _saveAuthState();
        _authStatus = AuthStatus.authenticated;
        _authStatusController.add(_authStatus);
      }
      
      return ApiResponse(
        success: apiResponse.success,
        data: _currentUser,
        errorCode: apiResponse.errorCode,
        errorMessage: apiResponse.errorMessage,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        errorCode: 'NETWORK_ERROR',
        errorMessage: '网络请求失败: $e',
      );
    }
  }

  // ==================== 原有方法（保留兼容） ====================
  
  /// 获取带认证的请求头
  Map<String, String> getAuthHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_tokenInfo != null) {
      headers['Authorization'] = 'Bearer ${_tokenInfo!.accessToken}';
    }
    return headers;
  }

  /// 发送认证请求（自动处理 Token 刷新）
  Future<http.Response> sendAuthRequest(
    Future<http.Response> Function() request,
  ) async {
    // 如果 Token 即将过期，先刷新
    if (_tokenInfo != null && _tokenInfo!.isExpiringSoon) {
      final refreshed = await _tryRefreshToken();
      if (!refreshed) {
        await logout();
        throw Exception('Token 已过期，请重新登录');
      }
    }
    
    var response = await request();
    
    // 如果返回 401，尝试刷新 Token 后重试
    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        response = await request();
      } else {
        await logout();
        throw Exception('Token 已过期，请重新登录');
      }
    }
    
    return response;
  }

  // ==================== 认证 API ====================
  
  /// 发送短信验证码
  Future<ApiResponse<Map<String, dynamic>>> sendSmsCode(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/sms/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      
      return ApiResponse.fromJson(
        jsonDecode(response.body),
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        errorCode: 'NETWORK_ERROR',
        errorMessage: '网络请求失败: $e',
      );
    }
  }

  /// 手机号登录/注册（验证码方式）
  Future<ApiResponse<UserInfo>> loginByPhone(String phone, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/phone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      );
      
      final apiResponse = ApiResponse.fromJson(
        jsonDecode(response.body),
        (data) => {
          'user': UserInfo.fromJson(data['user']),
          'tokens': TokenInfo.fromJson(data['tokens']),
        },
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        _currentUser = apiResponse.data!['user'] as UserInfo;
        _tokenInfo = apiResponse.data!['tokens'] as TokenInfo;
        await _saveAuthState();
        _authStatus = AuthStatus.authenticated;
        _authStatusController.add(_authStatus);
        
        // 埋点：登录成功
        AnalyticsService().trackEvent(UserEvents.loginSuccess, params: {
          UserEvents.paramUserId: _currentUser?.id,
          UserEvents.paramPhone: phone,
          UserEvents.paramMethod: 'phone_code',
        });
      } else {
        // 埋点：登录失败
        AnalyticsService().trackEvent(UserEvents.loginFailed, params: {
          UserEvents.paramPhone: phone,
          UserEvents.paramMethod: 'phone_code',
          UserEvents.paramErrorCode: apiResponse.errorCode,
          UserEvents.paramErrorMessage: apiResponse.errorMessage,
        });
      }
      
      return ApiResponse(
        success: apiResponse.success,
        data: _currentUser,
        errorCode: apiResponse.errorCode,
        errorMessage: apiResponse.errorMessage,
      );
    } catch (e) {
      // 埋点：登录失败（网络错误）
      AnalyticsService().trackEvent(UserEvents.loginFailed, params: {
        UserEvents.paramPhone: phone,
        UserEvents.paramMethod: 'phone_code',
        UserEvents.paramErrorCode: 'NETWORK_ERROR',
        UserEvents.paramErrorMessage: '网络请求失败: $e',
      });
      return ApiResponse(
        success: false,
        errorCode: 'NETWORK_ERROR',
        errorMessage: '网络请求失败: $e',
      );
    }
  }

  /// 手机号注册
  Future<ApiResponse<UserInfo>> registerByPhone(
    String phone,
    String code, {
    String? nickname,
  }) async {
    try {
      final body = {
        'phone': phone,
        'code': code,
        if (nickname != null) 'nickname': nickname,
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/phone'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      final apiResponse = ApiResponse.fromJson(
        jsonDecode(response.body),
        (data) => {
          'user': UserInfo.fromJson(data['user']),
          'tokens': TokenInfo.fromJson(data['tokens']),
        },
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        _currentUser = apiResponse.data!['user'] as UserInfo;
        _tokenInfo = apiResponse.data!['tokens'] as TokenInfo;
        await _saveAuthState();
        _authStatus = AuthStatus.authenticated;
        _authStatusController.add(_authStatus);
      }
      
      return ApiResponse(
        success: apiResponse.success,
        data: _currentUser,
        errorCode: apiResponse.errorCode,
        errorMessage: apiResponse.errorMessage,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        errorCode: 'NETWORK_ERROR',
        errorMessage: '网络请求失败: $e',
      );
    }
  }

  /// 退出登录
  Future<ApiResponse<void>> logout() async {
    try {
      if (_tokenInfo != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: getAuthHeaders(),
          body: jsonEncode({'refreshToken': _tokenInfo!.refreshToken}),
        );
      }
    } catch (e) {
      debugPrint('服务器登出请求失败: $e');
    }
    
    // 无论服务器请求是否成功，都清除本地状态
    await _clearAuthState();
    _authStatus = AuthStatus.unauthenticated;
    _authStatusController.add(_authStatus);
    
    return ApiResponse(success: true, data: null);
  }

  /// 获取当前用户信息
  Future<ApiResponse<UserInfo>> getCurrentUser() async {
    try {
      final response = await sendAuthRequest(() => http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: getAuthHeaders(),
      ));
      
      final apiResponse = ApiResponse.fromJson(
        jsonDecode(response.body),
        (data) => UserInfo.fromJson(data),
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        _currentUser = apiResponse.data;
        await _saveAuthState();
      }
      
      return apiResponse;
    } catch (e) {
      return ApiResponse(
        success: false,
        errorCode: 'NETWORK_ERROR',
        errorMessage: '网络请求失败: $e',
      );
    }
  }

  /// 更新用户信息
  Future<ApiResponse<UserInfo>> updateUserInfo({
    String? nickname,
    String? avatarUrl,
    String? gender,
    DateTime? birthday,
    String? bio,
  }) async {
    try {
      final body = <String, dynamic>{
        if (nickname != null) 'nickname': nickname,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (gender != null) 'gender': gender,
        if (birthday != null) 'birthday': birthday.toIso8601String(),
        if (bio != null) 'bio': bio,
      };
      
      final response = await sendAuthRequest(() => http.patch(
        Uri.parse('$_baseUrl/users/me'),
        headers: getAuthHeaders(),
        body: jsonEncode(body),
      ));
      
      final apiResponse = ApiResponse.fromJson(
        jsonDecode(response.body),
        (data) => UserInfo.fromJson(data),
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        _currentUser = apiResponse.data;
        await _saveAuthState();
      }
      
      return apiResponse;
    } catch (e) {
      return ApiResponse(
        success: false,
        errorCode: 'NETWORK_ERROR',
        errorMessage: '网络请求失败: $e',
      );
    }
  }

  /// 检查是否已登录
  bool get isLoggedIn => _authStatus == AuthStatus.authenticated;

  /// 静态方法：检查登录状态
  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// 静态方法：获取用户信息
  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final userName = prefs.getString('user_name') ?? '游客';
    return {'id': userId, 'name': userName};
  }

  /// 静态方法：退出登录
  static Future<void> logoutStatic() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove('user_id');
    await prefs.remove('user_name');
  }

  /// 释放资源
  void dispose() {
    _refreshTimer?.cancel();
    _authStatusController.close();
  }
}
