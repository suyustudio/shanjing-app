// M5 测试工具类
// 提供测试辅助函数和模拟数据

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 测试辅助类
class TestHelpers {
  static SharedPreferences? _prefs;
  
  /// 初始化
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // ==================== 应用状态管理 ====================
  
  /// 清除应用数据（模拟首次启动）
  static Future<void> clearAppData() async {
    await _prefs?.clear();
    await _prefs?.setBool('onboarding_completed', false);
  }
  
  /// 设置引导完成状态
  static Future<void> setOnboardingCompleted() async {
    await _prefs?.setBool('onboarding_completed', true);
  }
  
  /// 检查引导是否完成
  static Future<bool> isOnboardingCompleted() async {
    return _prefs?.getBool('onboarding_completed') ?? false;
  }
  
  /// 重启应用
  static Future<void> restartApp(WidgetTester tester) async {
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  }
  
  // ==================== 成就数据管理 ====================
  
  /// 清除成就数据
  static Future<void> clearAchievementData() async {
    await _prefs?.remove('achievements');
    await _prefs?.remove('user_stats');
  }
  
  /// 解锁模拟成就
  static Future<void> unlockMockAchievements(List<Achievement> achievements) async {
    final data = achievements.map((a) => a.toJson()).toList();
    await _prefs?.setString('achievements', jsonEncode(data));
  }
  
  /// 获取用户成就
  static Future<List<Achievement>> getUserAchievements() async {
    final data = _prefs?.getString('achievements');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Achievement.fromJson(e)).toList();
  }
  
  /// 获取服务端成就
  static Future<List<Achievement>> getServerAchievements() async {
    // 模拟API调用
    final response = await mockApiCall('/user/achievements');
    return (response['data'] as List)
        .map((e) => Achievement.fromJson(e))
        .toList();
  }
  
  /// 模拟完成路线
  static Future<void> simulateTrailComplete({
    required String trailId,
    required int distance,
  }) async {
    // 更新本地统计
    final stats = await getUserStats();
    stats.totalDistance += distance;
    stats.completedTrails.add(trailId);
    await _prefs?.setString('user_stats', jsonEncode(stats.toJson()));
    
    // 触发成就检查
    await AchievementService.checkAchievements(stats);
  }
  
  /// 模拟每周徒步
  static Future<void> simulateWeeklyTrailComplete({
    required int weeks,
    required int trailsPerWeek,
  }) async {
    for (int w = 0; w < weeks; w++) {
      for (int t = 0; t < trailsPerWeek; t++) {
        await simulateTrailComplete(
          trailId: 'trail_w${w}_t$t',
          distance: 3000,
        );
      }
    }
  }
  
  /// 模拟分享
  static Future<void> simulateShare({
    required String trailId,
    required String channel,
  }) async {
    await ShareService.share(trailId: trailId, channel: channel);
  }
  
  /// 获取用户统计
  static Future<UserStats> getUserStats() async {
    final data = _prefs?.getString('user_stats');
    if (data == null) return UserStats();
    return UserStats.fromJson(jsonDecode(data));
  }
  
  // ==================== 推荐测试数据 ====================
  
  /// 加载模拟路线数据
  static Future<void> loadMockTrailData() async {
    final trails = [
      Trail(
        id: 'trail_hz_1',
        name: '九溪烟树',
        city: '杭州',
        difficulty: 'easy',
        distanceKm: 3.5,
        sceneryType: 'forest',
        rating: 4.8,
        popularity: 1500,
      ),
      Trail(
        id: 'trail_hz_2',
        name: '龙井村环线',
        city: '杭州',
        difficulty: 'medium',
        distanceKm: 8.0,
        sceneryType: 'tea',
        rating: 4.6,
        popularity: 1200,
      ),
      Trail(
        id: 'trail_sh_1',
        name: '佘山徒步',
        city: '上海',
        difficulty: 'easy',
        distanceKm: 2.8,
        sceneryType: 'mountain',
        rating: 4.2,
        popularity: 800,
      ),
      // ... 更多测试数据
    ];
    
    await _prefs?.setString('mock_trails', jsonEncode(trails.map((t) => t.toJson()).toList()));
  }
  
  /// 设置用户位置
  static Future<void> setUserLocation({
    required double lat,
    required double lng,
  }) async {
    await _prefs?.setDouble('user_lat', lat);
    await _prefs?.setDouble('user_lng', lng);
  }
  
  /// 设置用户画像
  static Future<void> setUserProfile({
    double? avgDistance,
    String? preferredDifficulty,
    String? preferredScenery,
  }) async {
    final profile = {
      'avg_distance': avgDistance,
      'preferred_difficulty': preferredDifficulty,
      'preferred_scenery': preferredScenery,
    };
    await _prefs?.setString('user_profile', jsonEncode(profile));
  }
  
  /// 清除用户画像
  static Future<void> clearUserProfile() async {
    await _prefs?.remove('user_profile');
  }
  
  /// 获取推荐列表
  static Future<List<Trail>> getRecommendations({int count = 10}) async {
    final response = await mockApiCall('/recommendations?limit=$count');
    return (response['data'] as List)
        .map((e) => Trail.fromJson(e))
        .toList();
  }
  
  /// 触发推荐加载
  static Future<void> triggerRecommendationLoad() async {
    // 模拟触发推荐加载
  }
  
  /// 注册新用户
  static Future<void> registerNewUser() async {
    await mockApiCall('/auth/register', method: 'POST');
  }
  
  // ==================== 网络模拟 ====================
  
  /// 设置网络状态
  static Future<void> setNetworkEnabled(bool enabled) async {
    MockNetworkInterceptor.setEnabled(enabled);
  }
  
  /// 模拟服务端错误
  static Future<void> simulateServerError(String endpoint) async {
    MockNetworkInterceptor.addError(endpoint, statusCode: 500);
  }
  
  /// 模拟API调用
  static Future<Map<String, dynamic>> mockApiCall(
    String endpoint, {
    String method = 'GET',
  }) async {
    return await MockNetworkInterceptor.request(endpoint, method: method);
  }
  
  // ==================== 性能测试 ====================
  
  /// 模拟低内存环境
  static Future<void> simulateLowMemory() async {
    // 在测试环境中模拟低内存
    TestWidgetsFlutterBinding.ensureInitialized();
  }
  
  /// 测量FPS
  static Future<double> measureFPS({
    required Duration duration,
    required WidgetTester tester,
  }) async {
    int frames = 0;
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < duration) {
      await tester.pump(Duration(milliseconds: 16));
      frames++;
    }
    
    return frames / duration.inSeconds;
  }
  
  // ==================== 埋点测试 ====================
  
  /// 清除埋点事件
  static Future<void> clearAnalyticsEvents() async {
    await _prefs?.remove('analytics_events');
  }
  
  /// 获取埋点事件
  static Future<List<String>> getAnalyticsEvents() async {
    final data = _prefs?.getString('analytics_events');
    if (data == null) return [];
    return List<String>.from(jsonDecode(data));
  }
  
  // ==================== 微信登录模拟 ====================
  
  /// 模拟微信登录成功
  static Future<void> simulateWechatLoginSuccess() async {
    await _prefs?.setString('auth_token', 'mock_token_12345');
    await _prefs?.setString('user_id', 'mock_user_12345');
  }
  
  // ==================== M4数据模拟 ====================
  
  /// 加载M4测试数据
  static Future<void> loadM4TestData() async {
    // 模拟M4用户数据
    await _prefs?.setString('m4_user_data', jsonEncode({
      'total_distance': 50000,
      'completed_trails': ['trail_1', 'trail_2', 'trail_3'],
      'favorites': ['trail_1', 'trail_4'],
    }));
  }
  
  /// 加载M4用户数据
  static Future<void> loadM4UserData() async {
    final m4Data = _prefs?.getString('m4_user_data');
    if (m4Data != null) {
      final data = jsonDecode(m4Data);
      await _prefs?.setString('user_stats', jsonEncode({
        'total_distance': data['total_distance'],
        'completed_trails': data['completed_trails'],
      }));
    }
  }
  
  /// 获取收藏
  static Future<List<String>> getFavorites() async {
    final data = _prefs?.getString('favorites');
    if (data == null) return [];
    return List<String>.from(jsonDecode(data));
  }
  
  /// 模拟M4已安装
  static Future<void> simulateM4Installed() async {
    await _prefs?.setString('app_version', '1.0.0');
    await _prefs?.setBool('onboarding_completed', true);
  }
  
  /// 触发SOS
  static Future<void> triggerSOS() async {
    // 模拟SOS触发
  }
  
  /// 设置暗黑模式
  static Future<void> setDarkMode(bool enabled) async {
    await _prefs?.setBool('dark_mode', enabled);
  }
}

// ==================== 数据模型 ====================

class Achievement {
  final String id;
  final String name;
  final String currentLevel;
  
  Achievement({
    required this.id,
    required this.name,
    this.currentLevel = 'bronze',
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'current_level': currentLevel,
  };
  
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    name: json['name'],
    currentLevel: json['current_level'],
  );
}

class UserStats {
  int totalDistance;
  List<String> completedTrails;
  
  UserStats({
    this.totalDistance = 0,
    this.completedTrails = const [],
  });
  
  Map<String, dynamic> toJson() => {
    'total_distance': totalDistance,
    'completed_trails': completedTrails,
  };
  
  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalDistance: json['total_distance'] ?? 0,
    completedTrails: List<String>.from(json['completed_trails'] ?? []),
  );
}

class Trail {
  final String id;
  final String name;
  final String city;
  final String difficulty;
  final double distanceKm;
  final String sceneryType;
  final double rating;
  final int popularity;
  
  Trail({
    required this.id,
    required this.name,
    required this.city,
    required this.difficulty,
    required this.distanceKm,
    required this.sceneryType,
    required this.rating,
    required this.popularity,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'difficulty': difficulty,
    'distance_km': distanceKm,
    'scenery_type': sceneryType,
    'rating': rating,
    'popularity': popularity,
  };
  
  factory Trail.fromJson(Map<String, dynamic> json) => Trail(
    id: json['id'],
    name: json['name'],
    city: json['city'],
    difficulty: json['difficulty'],
    distanceKm: json['distance_km'],
    sceneryType: json['scenery_type'],
    rating: json['rating'],
    popularity: json['popularity'],
  );
}

// ==================== Mock类 ====================

class MockNetworkInterceptor {
  static bool _enabled = true;
  static final Map<String, int> _errors = {};
  
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }
  
  static void addError(String endpoint, {required int statusCode}) {
    _errors[endpoint] = statusCode;
  }
  
  static Future<Map<String, dynamic>> request(
    String endpoint, {
    String method = 'GET',
  }) async {
    if (!_enabled) {
      throw Exception('Network is disabled');
    }
    
    if (_errors.containsKey(endpoint)) {
      throw Exception('HTTP ${_errors[endpoint]}');
    }
    
    // 返回模拟数据
    return {
      'code': 200,
      'message': 'success',
      'data': [],
    };
  }
}

class AchievementService {
  static Future<List<Achievement>> checkAchievements(UserStats stats) async {
    // 成就检查逻辑
    return [];
  }
}

class ShareService {
  static Future<void> share({
    required String trailId,
    required String channel,
  }) async {}
}
