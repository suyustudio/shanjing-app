import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/api_config.dart';
import '../models/achievement.dart';
import 'auth_service.dart';

/// 成就服务接口
abstract class IAchievementService {
  /// 获取所有成就定义
  Future<List<Achievement>> getAllAchievements();

  /// 获取用户成就列表
  Future<UserAchievementSummary> getUserAchievements({bool includeHidden = false});

  /// 检查并解锁成就
  Future<AchievementCheckResult> checkAchievements({
    required String triggerType,
    String? trailId,
    TrailStats? stats,
  });

  /// 获取单个成就的进度
  Future<double> getAchievementProgress(String achievementId);

  /// 标记成就已查看
  Future<void> markAchievementViewed(String achievementId);

  /// 生成成就分享图片
  Future<String> generateShareImage(Achievement achievement);

  /// 新成就解锁事件流
  Stream<NewlyUnlockedAchievement> get onAchievementUnlocked;

  /// 成就进度更新事件流
  Stream<ProgressUpdatedAchievement> get onProgressUpdated;

  /// 连接到实时通知服务
  Future<void> connectRealtime();

  /// 断开实时通知服务
  void disconnectRealtime();
}

/// 成就服务实现
class AchievementService implements IAchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final AuthService _authService = AuthService();
  io.Socket? _socket;

  final StreamController<NewlyUnlockedAchievement> _achievementUnlockedController =
      StreamController<NewlyUnlockedAchievement>.broadcast();
  final StreamController<ProgressUpdatedAchievement> _progressUpdatedController =
      StreamController<ProgressUpdatedAchievement>.broadcast();

  List<Achievement>? _cachedAchievements;
  DateTime? _cacheTimestamp;
  static const Duration _cacheValidity = Duration(minutes: 30);

  @override
  Stream<NewlyUnlockedAchievement> get onAchievementUnlocked =>
      _achievementUnlockedController.stream;

  @override
  Stream<ProgressUpdatedAchievement> get onProgressUpdated =>
      _progressUpdatedController.stream;

  /// 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<Achievement>> getAllAchievements() async {
    // 检查缓存
    if (_cachedAchievements != null &&
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) < _cacheValidity) {
      return _cachedAchievements!;
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/achievements'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final achievements = (data['data'] as List)
          .map((json) => Achievement.fromJson(json))
          .toList();

      // 更新缓存
      _cachedAchievements = achievements;
      _cacheTimestamp = DateTime.now();

      return achievements;
    } else {
      throw Exception('Failed to load achievements: ${response.body}');
    }
  }

  @override
  Future<UserAchievementSummary> getUserAchievements({
    bool includeHidden = false,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/achievements/user?includeHidden=$includeHidden',
      ),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserAchievementSummary.fromJson(data['data']);
    } else {
      throw Exception('Failed to load user achievements: ${response.body}');
    }
  }

  @override
  Future<AchievementCheckResult> checkAchievements({
    required String triggerType,
    String? trailId,
    TrailStats? stats,
  }) async {
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

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/achievements/check'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = AchievementCheckResult.fromJson(data['data']);

      // 触发本地事件
      for (final unlocked in result.newlyUnlocked) {
        _achievementUnlockedController.add(unlocked);
      }
      for (final updated in result.progressUpdated) {
        _progressUpdatedController.add(updated);
      }

      return result;
    } else {
      throw Exception('Failed to check achievements: ${response.body}');
    }
  }

  @override
  Future<double> getAchievementProgress(String achievementId) async {
    final summary = await getUserAchievements();
    final achievement = summary.achievements.firstWhere(
      (a) => a.achievementId == achievementId,
      orElse: () => throw Exception('Achievement not found'),
    );
    return achievement.percentage;
  }

  @override
  Future<void> markAchievementViewed(String achievementId) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/achievements/$achievementId/viewed'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark achievement as viewed: ${response.body}');
    }
  }

  @override
  Future<String> generateShareImage(Achievement achievement) async {
    // TODO: 实现分享图片生成
    // 可以使用 screenshot 包生成图片
    // 或者调用后端 API 生成
    throw UnimplementedError('Share image generation not implemented yet');
  }

  @override
  Future<void> connectRealtime() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final token = await _authService.getToken();
    final userId = await _authService.getUserId();

    _socket = io.io(ApiConfig.wsUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {
        'token': token,
        'userId': userId,
      },
      'namespace': '/achievements',
    });

    _socket!.onConnect((_) {
      print('Connected to achievements realtime service');
      _socket!.emit('achievements:subscribe');
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from achievements realtime service');
    });

    _socket!.on('achievement:unlocked', (data) {
      final unlocked = NewlyUnlockedAchievement.fromJson(data);
      _achievementUnlockedController.add(unlocked);
    });

    _socket!.on('achievement:progress', (data) {
      final updated = ProgressUpdatedAchievement.fromJson(data);
      _progressUpdatedController.add(updated);
    });

    _socket!.on('achievements:subscribed', (data) {
      print('Subscribed to achievements: $data');
    });

    _socket!.on('error', (error) {
      print('Socket error: $error');
    });
  }

  @override
  void disconnectRealtime() {
    _socket?.disconnect();
    _socket = null;
  }

  /// 清除缓存
  void clearCache() {
    _cachedAchievements = null;
    _cacheTimestamp = null;
  }

  /// 销毁
  void dispose() {
    disconnectRealtime();
    _achievementUnlockedController.close();
    _progressUpdatedController.close();
  }
}
