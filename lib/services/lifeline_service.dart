import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import '../models/emergency_contact.dart';
import '../models/lifeline_session.dart';
import 'emergency_contact_service.dart';

/// Lifeline服务
/// 管理位置追踪、超时检测和报警逻辑
class LifelineService {
  static const String _sessionKey = 'lifeline_session';
  static const String _locationHistoryKey = 'lifeline_location_history';
  
  // 定位频率: 每5分钟或每500米
  static const int _locationIntervalSeconds = 300; // 5分钟
  static const double _locationDistanceFilter = 500; // 500米

  static final LifelineService _instance = LifelineService._internal();
  factory LifelineService() => _instance;
  LifelineService._internal();

  SharedPreferences? _prefs;
  AMapFlutterLocation? _locationPlugin;
  StreamSubscription<Map<String, Object>>? _locationSubscription;
  Timer? _countdownTimer;
  Timer? _alarmCheckTimer;

  // 状态回调
  Function(LifelineSession)? onSessionUpdate;
  Function(String)? onAlarm;
  Function(LocationSnapshot)? onLocationUpdate;

  /// 初始化服务
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    _locationPlugin ??= AMapFlutterLocation();
  }

  /// 启动Lifeline会话
  Future<LifelineSession?> startLifeline({
    required List<String> contactIds,
    required int estimatedDurationMinutes,
    required int bufferTimeMinutes,
    String? routeId,
    String? routeName,
  }) async {
    await initialize();

    if (contactIds.isEmpty) {
      throw Exception('必须至少选择一位紧急联系人');
    }

    final now = DateTime.now();
    final session = LifelineSession(
      id: _generateSessionId(),
      routeId: routeId,
      routeName: routeName,
      contactIds: contactIds,
      estimatedDurationMinutes: estimatedDurationMinutes,
      bufferTimeMinutes: bufferTimeMinutes,
      startTime: now,
      estimatedEndTime: now.add(Duration(minutes: estimatedDurationMinutes)),
      status: LifelineStatus.active,
      shareToken: _generateShareToken(),
      shareUrl: null, // 暂不实现分享链接
    );

    await _saveSession(session);
    await _startLocationTracking();
    _startTimers(session);

    return session;
  }

  /// 停止Lifeline会话
  Future<void> stopLifeline({bool completed = true}) async {
    await initialize();
    
    final session = await getCurrentSession();
    if (session == null || !session.isActive) {
      return;
    }

    final updatedSession = session.copyWith(
      status: completed ? LifelineStatus.completed : LifelineStatus.cancelled,
      actualEndTime: DateTime.now(),
    );

    await _saveSession(updatedSession);
    await _stopLocationTracking();
    _stopTimers();
  }

  /// 获取当前会话
  Future<LifelineSession?> getCurrentSession() async {
    await initialize();
    final jsonString = _prefs?.getString(_sessionKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      return LifelineSession.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  /// 检查是否有激活的会话
  Future<bool> hasActiveSession() async {
    final session = await getCurrentSession();
    return session?.isActive ?? false;
  }

  /// 延长预计结束时间
  Future<bool> extendEstimatedTime(int additionalMinutes) async {
    final session = await getCurrentSession();
    if (session == null || !session.isActive) {
      return false;
    }

    final newEstimatedEnd = session.estimatedEndTime.add(Duration(minutes: additionalMinutes));
    final updatedSession = session.copyWith(
      estimatedEndTime: newEstimatedEnd,
    );

    await _saveSession(updatedSession);
    _startTimers(updatedSession);
    onSessionUpdate?.call(updatedSession);
    return true;
  }

  /// 获取位置历史
  Future<List<LocationSnapshot>> getLocationHistory() async {
    await initialize();
    final jsonString = _prefs?.getString(_locationHistoryKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => LocationSnapshot.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取最新位置
  Future<LocationSnapshot?> getLatestLocation() async {
    final session = await getCurrentSession();
    return session?.lastKnownLocation;
  }

  /// 手动记录位置（用于测试或紧急情况）
  Future<void> recordLocation({
    required double latitude,
    required double longitude,
    double? altitude,
    double accuracy = 0,
  }) async {
    final snapshot = LocationSnapshot(
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracy: accuracy,
      signalSource: 'manual',
    );

    await _updateSessionWithLocation(snapshot);
    onLocationUpdate?.call(snapshot);
  }

  /// 模拟发送报警（实际项目中接入短信服务）
  Future<bool> sendAlarm({String? customMessage}) async {
    try {
      final session = await getCurrentSession();
      if (session == null) return false;

      final contacts = await EmergencyContactService().getAllContacts();
      final targetContacts = contacts
          .where((c) => session.contactIds.contains(c.id))
          .toList();

      if (targetContacts.isEmpty) return false;

      // 获取最后已知位置
      final lastLocation = session.lastKnownLocation;
      final locationStr = lastLocation != null 
          ? '最后位置：${lastLocation.latitude.toStringAsFixed(6)}, ${lastLocation.longitude.toStringAsFixed(6)}'
          : '位置信息获取失败';

      // 构建消息
      final message = customMessage ?? 
          '【山径APP紧急提醒】\n'
          '您的亲友超时未归，可能需要帮助。\n'
          '$locationStr\n'
          '时间：${DateTime.now().toString()}\n'
          '请及时联系确认安全。';

      // 模拟发送短信（P0阶段预留接口）
      for (final contact in targetContacts) {
        await _simulateSendSMS(contact.phone, message);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 模拟发送SOS（实际项目中接入短信服务）
  Future<bool> sendSOS({String? note}) async {
    try {
      final session = await getCurrentSession();
      final lastLocation = session?.lastKnownLocation;
      
      final contacts = await EmergencyContactService().getAllContacts();
      final targetContacts = session != null
          ? contacts.where((c) => session.contactIds.contains(c.id)).toList()
          : contacts;

      if (targetContacts.isEmpty) return false;

      final locationStr = lastLocation != null 
          ? '位置：${lastLocation.latitude.toStringAsFixed(6)}, ${lastLocation.longitude.toStringAsFixed(6)}'
          : '位置信息获取中...';

      final message = '【山径APP紧急求救】\n'
          '紧急情况！我需要帮助！\n'
          '$locationStr\n'
          '${note != null ? '备注：$note\n' : ''}'
          '时间：${DateTime.now().toString()}';

      // 模拟发送
      for (final contact in targetContacts) {
        await _simulateSendSMS(contact.phone, message);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 清理历史数据
  Future<void> clearHistory() async {
    await _prefs?.remove(_locationHistoryKey);
    await _prefs?.remove(_sessionKey);
  }

  // ========== 私有方法 ==========

  /// 启动定位追踪
  Future<void> _startLocationTracking() async {
    if (_locationPlugin == null) return;

    // 请求定位权限
    await _locationPlugin?.setLocationOption(AMapLocationOption(
      onceLocation: false,
      locationInterval: _locationIntervalSeconds * 1000,
      pausesLocationUpdatesAutomatically: false,
      desiredAccuracy: CLLocationAccuracy.kCLLocationAccuracyBest,
    ));

    _locationSubscription?.cancel();
    _locationSubscription = _locationPlugin?.onLocationChanged().listen(
      (Map<String, Object> result) {
        _handleLocationUpdate(result);
      },
      onError: (error) {
        // 定位错误处理
      },
    );

    _locationPlugin?.startLocation();
  }

  /// 停止定位追踪
  Future<void> _stopLocationTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _locationPlugin?.stopLocation();
  }

  /// 处理定位更新
  void _handleLocationUpdate(Map<String, Object> result) {
    final latitude = result['latitude'] as double?;
    final longitude = result['longitude'] as double?;
    final altitude = result['altitude'] as double?;
    final accuracy = result['accuracy'] as double? ?? 0;

    if (latitude == null || longitude == null) return;

    final snapshot = LocationSnapshot(
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracy: accuracy,
      signalSource: result['provider'] as String? ?? 'gps',
    );

    _updateSessionWithLocation(snapshot);
    onLocationUpdate?.call(snapshot);
  }

  /// 更新会话位置信息
  Future<void> _updateSessionWithLocation(LocationSnapshot snapshot) async {
    final session = await getCurrentSession();
    if (session == null || !session.isActive) return;

    final updatedSnapshots = List<LocationSnapshot>.from(session.locationSnapshots)
      ..add(snapshot);

    // 只保留最近100个位置点
    if (updatedSnapshots.length > 100) {
      updatedSnapshots.removeAt(0);
    }

    final updatedSession = session.copyWith(
      locationSnapshots: updatedSnapshots,
      lastKnownLocation: snapshot,
      lastSignalTime: DateTime.now(),
    );

    await _saveSession(updatedSession);
    await _appendLocationHistory(snapshot);
  }

  /// 保存会话
  Future<void> _saveSession(LifelineSession session) async {
    await initialize();
    await _prefs?.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  /// 追加位置历史
  Future<void> _appendLocationHistory(LocationSnapshot snapshot) async {
    final history = await getLocationHistory();
    history.add(snapshot);
    
    // 只保留最近500个位置点
    while (history.length > 500) {
      history.removeAt(0);
    }

    await _prefs?.setString(
      _locationHistoryKey, 
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  /// 启动计时器
  void _startTimers(LifelineSession session) {
    _stopTimers();

    // 倒计时更新计时器（每秒）
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      onSessionUpdate?.call(session);
    });

    // 报警检测计时器（每分钟检查一次）
    _alarmCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _checkAlarm(session);
    });
  }

  /// 停止计时器
  void _stopTimers() {
    _countdownTimer?.cancel();
    _alarmCheckTimer?.cancel();
    _countdownTimer = null;
    _alarmCheckTimer = null;
  }

  /// 检查是否需要报警
  Future<void> _checkAlarm(LifelineSession session) async {
    if (!session.isActive) return;

    final now = DateTime.now();
    final alarmTime = session.alarmTriggerTime;

    if (now.isAfter(alarmTime)) {
      // 更新状态为超时
      final updatedSession = session.copyWith(status: LifelineStatus.overdue);
      await _saveSession(updatedSession);
      
      // 触发报警
      onAlarm?.call('LIFELINE_OVERDUE');
      await sendAlarm();
    }
  }

  /// 生成会话ID
  String _generateSessionId() {
    return 'lifeline_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// 生成分享令牌
  String _generateShareToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (_) => chars[Random().nextInt(chars.length)]).join();
  }

  /// 模拟发送短信（预留接口）
  Future<void> _simulateSendSMS(String phone, String message) async {
    // P0阶段仅模拟，实际接入短信服务
    // 示例：sms_mms 或 http API
    print('[SMS SIMULATION] To: $phone');
    print('[SMS SIMULATION] Message: $message');
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
