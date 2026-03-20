// recording_service.dart
// 山径APP - 轨迹录制服务

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math show cos, sqrt, atan2, sin, pi, Random;
import 'package:flutter/material.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/recording_model.dart';
import 'api_client.dart';

/// 轨迹录制服务
/// 
/// 提供GPS轨迹录制、POI标记、离线存储和上传功能
class RecordingService extends ChangeNotifier {
  static const String _storageKey = 'recording_sessions';
  static const String _storageDirectory = 'recordings';
  
  // 录制间隔（毫秒）- 每秒1点
  static const int _recordingInterval = 1000;
  
  // 最小精度要求（米）
  static const double _minAccuracy = 20.0;
  
  // 最小移动距离（米）- 过滤GPS抖动
  static const double _minMoveDistance = 3.0;

  // 高德定位插件
  AMapFlutterLocation? _locationPlugin;
  StreamSubscription<Map<String, Object>>? _locationSubscription;
  
  // 录制定时器
  Timer? _recordingTimer;
  
  // 当前会话
  RecordingSession? _currentSession;
  RecordingSession? get currentSession => _currentSession;
  
  // 录制状态
  RecordingStatus get status => _currentSession?.status ?? RecordingStatus.idle;
  bool get isRecording => status == RecordingStatus.recording;
  bool get isPaused => status == RecordingStatus.paused;
  
  // 统计数据
  RecordingStats _stats = RecordingStats.empty();
  RecordingStats get stats => _stats;
  
  // 临时轨迹点（用于实时显示）
  final List<TrackPoint> _tempTrackPoints = [];
  List<TrackPoint> get tempTrackPoints => List.unmodifiable(_tempTrackPoints);
  
  // 位置历史（用于平滑处理）
  final List<TrackPoint> _positionHistory = [];
  static const int _maxHistorySize = 3;
  
  // 最后记录的位置
  TrackPoint? _lastTrackPoint;
  
  // 当前GPS位置
  TrackPoint? _currentPosition;
  TrackPoint? get currentPosition => _currentPosition;
  
  // 会话开始时的位置
  TrackPoint? _startPosition;
  
  // API客户端
  final ApiClient _apiClient = ApiClient();

  // 回调
  VoidCallback? onRecordingStarted;
  VoidCallback? onRecordingPaused;
  VoidCallback? onRecordingResumed;
  VoidCallback? onRecordingStopped;
  Function(String error)? onError;
  VoidCallback? onLocationUpdated;

  /// 初始化定位服务
  Future<bool> initialize() async {
    try {
      // 请求权限
      final locationStatus = await Permission.location.request();
      final locationAlwaysStatus = await Permission.locationAlways.request();
      
      if (locationStatus.isDenied || locationAlwaysStatus.isDenied) {
        onError?.call('需要定位权限才能录制轨迹');
        return false;
      }

      // 初始化高德定位
      _locationPlugin = AMapFlutterLocation();
      
      // 设置定位选项
      await _locationPlugin?.setLocationOption(AMapLocationOption(
        locationMode: AMapLocationMode.highAccuracy,
        needAddress: true,
        interval: 1000,
      ));

      // 监听定位结果
      _locationSubscription = _locationPlugin
          ?.onLocationChanged()
          .listen(_onLocationChanged);

      return true;
    } catch (e) {
      onError?.call('定位初始化失败: $e');
      return false;
    }
  }

  /// 开始录制
  Future<bool> startRecording({String? trailName}) async {
    if (_currentSession != null && 
        (_currentSession!.status == RecordingStatus.recording ||
         _currentSession!.status == RecordingStatus.paused)) {
      onError?.call('已有正在进行的录制');
      return false;
    }

    try {
      // 确保定位已启动
      _locationPlugin?.startLocation();

      // 等待获取第一个有效位置
      TrackPoint? startPoint;
      int attempts = 0;
      while (startPoint == null && attempts < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_currentPosition != null && _currentPosition!.accuracy <= _minAccuracy) {
          startPoint = _currentPosition;
        }
        attempts++;
      }

      if (startPoint == null) {
        onError?.call('无法获取有效GPS信号，请检查定位设置');
        return false;
      }

      _startPosition = startPoint;

      // 创建新会话
      final now = DateTime.now();
      _currentSession = RecordingSession(
        id: _generateSessionId(),
        trailName: trailName ?? '未命名路线',
        status: RecordingStatus.recording,
        startTime: now,
        durationSeconds: 0,
        totalDistanceMeters: 0,
        elevationGain: 0,
        elevationLoss: 0,
        trackPoints: [startPoint],
        pois: [],
        createdAt: now,
        updatedAt: now,
      );

      // 添加起点POI
      await addPoi(
        type: PoiType.start,
        name: '起点',
        description: '路线开始位置',
      );

      // 开始录制定时器
      _startRecordingTimer();

      // 清空临时数据
      _tempTrackPoints.clear();
      _positionHistory.clear();
      _lastTrackPoint = startPoint;
      _tempTrackPoints.add(startPoint);

      notifyListeners();
      onRecordingStarted?.call();
      
      return true;
    } catch (e) {
      onError?.call('开始录制失败: $e');
      return false;
    }
  }

  /// 暂停录制
  Future<bool> pauseRecording() async {
    if (_currentSession == null || 
        _currentSession!.status != RecordingStatus.recording) {
      return false;
    }

    try {
      _recordingTimer?.cancel();
      
      _currentSession = _currentSession!.copyWith(
        status: RecordingStatus.paused,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      onRecordingPaused?.call();
      
      // 保存到本地
      await _saveCurrentSession();
      
      return true;
    } catch (e) {
      onError?.call('暂停录制失败: $e');
      return false;
    }
  }

  /// 继续录制
  Future<bool> resumeRecording() async {
    if (_currentSession == null || 
        _currentSession!.status != RecordingStatus.paused) {
      return false;
    }

    try {
      _currentSession = _currentSession!.copyWith(
        status: RecordingStatus.recording,
        updatedAt: DateTime.now(),
      );

      _startRecordingTimer();

      notifyListeners();
      onRecordingResumed?.call();
      
      return true;
    } catch (e) {
      onError?.call('继续录制失败: $e');
      return false;
    }
  }

  /// 结束录制
  Future<RecordingSession?> stopRecording() async {
    if (_currentSession == null) return null;

    try {
      _recordingTimer?.cancel();
      
      final now = DateTime.now();
      
      // 添加终点POI
      if (_currentPosition != null) {
        await addPoi(
          type: PoiType.end,
          name: '终点',
          description: '路线结束位置',
        );
      }

      _currentSession = _currentSession!.copyWith(
        status: RecordingStatus.finished,
        endTime: now,
        updatedAt: now,
      );

      // 保存最终会话
      await _saveCurrentSession();

      final finishedSession = _currentSession;
      
      _currentSession = null;
      _tempTrackPoints.clear();
      _positionHistory.clear();
      _lastTrackPoint = null;
      _stats = RecordingStats.empty();

      notifyListeners();
      onRecordingStopped?.call();
      
      return finishedSession;
    } catch (e) {
      onError?.call('结束录制失败: $e');
      return null;
    }
  }

  /// 添加POI标记
  Future<PoiMarker?> addPoi({
    required PoiType type,
    String? name,
    String? description,
    List<String> photoUrls = const [],
  }) async {
    if (_currentSession == null || _currentPosition == null) {
      onError?.call('当前没有正在进行的录制');
      return null;
    }

    try {
      final poi = PoiMarker(
        id: _generatePoiId(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        altitude: _currentPosition!.altitude,
        type: type,
        name: name ?? type.displayName,
        description: description,
        photoUrls: photoUrls,
        createdAt: DateTime.now(),
      );

      final updatedPois = [..._currentSession!.pois, poi];
      
      _currentSession = _currentSession!.copyWith(
        pois: updatedPois,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      
      // 实时保存
      await _saveCurrentSession();
      
      return poi;
    } catch (e) {
      onError?.call('添加POI失败: $e');
      return null;
    }
  }

  /// 更新POI照片
  Future<bool> updatePoiPhotos(String poiId, List<String> photoUrls) async {
    if (_currentSession == null) return false;

    try {
      final updatedPois = _currentSession!.pois.map((poi) {
        if (poi.id == poiId) {
          return poi.copyWith(photoUrls: photoUrls);
        }
        return poi;
      }).toList();

      _currentSession = _currentSession!.copyWith(
        pois: updatedPois,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      await _saveCurrentSession();
      
      return true;
    } catch (e) {
      onError?.call('更新POI照片失败: $e');
      return false;
    }
  }

  /// 获取所有未上传的录制会话
  Future<List<RecordingSession>> getPendingSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null) return [];

      final data = LocalRecordingData.fromJsonString(jsonString);
      return data.sessions.where((s) => !s.isUploaded).toList();
    } catch (e) {
      onError?.call('读取录制记录失败: $e');
      return [];
    }
  }

  /// 获取所有录制会话
  Future<List<RecordingSession>> getAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null) return [];

      final data = LocalRecordingData.fromJsonString(jsonString);
      return data.sessions;
    } catch (e) {
      onError?.call('读取录制记录失败: $e');
      return [];
    }
  }

  /// 更新录制会话
  Future<bool> updateSession(RecordingSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      LocalRecordingData data;
      if (jsonString != null) {
        data = LocalRecordingData.fromJsonString(jsonString);
      } else {
        data = LocalRecordingData();
      }

      // 查找并替换现有会话
      final existingIndex = data.sessions.indexWhere((s) => s.id == session.id);

      List<RecordingSession> updatedSessions;
      if (existingIndex >= 0) {
        updatedSessions = [...data.sessions];
        updatedSessions[existingIndex] = session;
      } else {
        updatedSessions = [...data.sessions, session];
      }

      final updatedData = LocalRecordingData(sessions: updatedSessions);
      await prefs.setString(_storageKey, updatedData.toJsonString());

      notifyListeners();
      return true;
    } catch (e) {
      onError?.call('更新录制记录失败: $e');
      return false;
    }
  }

  /// 提交审核
  Future<bool> submitForReview(RecordingSession session) async {
    try {
      // 调用API提交审核
      final response = await _apiClient.post(
        '/trails/recording/submit',
        body: {
          'sessionId': session.id,
          'trailName': session.trailName,
          'description': session.description,
          'city': session.city,
          'district': session.district,
          'difficulty': session.difficulty?.name ?? 'EASY',
          'tags': session.tags,
          'trackData': session.toJson(),
        },
      );

      if (response.success == true) {
        // 更新本地状态为审核中
        final updatedSession = session.copyWith(
          submissionStatus: SubmissionStatus.reviewing,
          updatedAt: DateTime.now(),
        );
        await updateSession(updatedSession);
        return true;
      } else {
        onError?.call(response.errorMessage ?? '提交失败');
        return false;
      }
    } catch (e) {
      onError?.call('提交审核失败: $e');
      return false;
    }
  }

  /// 上传轨迹到服务器
  Future<TrailUploadResponse?> uploadTrail({
    required String sessionId,
    required String trailName,
    String? description,
    required String city,
    required String district,
    required String difficulty,
    List<String> tags = const [],
  }) async {
    try {
      // 获取会话数据
      final session = await _getSessionById(sessionId);
      if (session == null) {
        return TrailUploadResponse(
          success: false,
          error: '未找到录制会话',
        );
      }

      // 准备上传数据
      final request = TrailUploadRequest(
        sessionId: sessionId,
        trailName: trailName,
        description: description,
        city: city,
        district: district,
        difficulty: difficulty,
        tags: tags,
      );

      // 调用API上传
      final response = await _apiClient.post(
        '/trails/recording/upload',
        body: {
          ...request.toJson(),
          'trackData': session.toJson(),
        },
      );

      if (response.success == true) {
        // 标记为已上传
        await _markSessionUploaded(sessionId);
        
        return TrailUploadResponse.fromJson(response.data);
      } else {
        return TrailUploadResponse(
          success: false,
          error: response.errorMessage ?? '上传失败',
        );
      }
    } catch (e) {
      return TrailUploadResponse(
        success: false,
        error: '上传失败: $e',
      );
    }
  }

  /// 删除录制会话
  Future<bool> deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null) return false;

      final data = LocalRecordingData.fromJsonString(jsonString);
      final updatedSessions = data.sessions
          .where((s) => s.id != sessionId)
          .toList();

      final updatedData = LocalRecordingData(sessions: updatedSessions);
      await prefs.setString(_storageKey, updatedData.toJsonString());

      notifyListeners();
      return true;
    } catch (e) {
      onError?.call('删除录制记录失败: $e');
      return false;
    }
  }

  /// 清理已上传的旧记录
  Future<void> cleanupOldSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null) return;

      final data = LocalRecordingData.fromJsonString(jsonString);
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final updatedSessions = data.sessions.where((s) {
        // 保留未上传的记录
        if (!s.isUploaded) return true;
        // 保留30天内上传的记录
        return s.updatedAt.isAfter(thirtyDaysAgo);
      }).toList();

      final updatedData = LocalRecordingData(sessions: updatedSessions);
      await prefs.setString(_storageKey, updatedData.toJsonString());
    } catch (e) {
      // 静默处理清理错误
    }
  }

  /// 更新路线名称
  Future<bool> updateTrailName(String name) async {
    if (_currentSession == null) return false;

    _currentSession = _currentSession!.copyWith(
      trailName: name,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
    await _saveCurrentSession();
    return true;
  }

  // ========== 私有方法 ==========

  /// 定位变化回调
  void _onLocationChanged(Map<String, Object> location) {
    try {
      final latitude = (location['latitude'] as num?)?.toDouble();
      final longitude = (location['longitude'] as num?)?.toDouble();
      final altitude = (location['altitude'] as num?)?.toDouble() ?? 0;
      final accuracy = (location['accuracy'] as num?)?.toDouble() ?? 0;
      final speed = (location['speed'] as num?)?.toDouble();
      final timestamp = DateTime.now();

      if (latitude == null || longitude == null) return;

      final trackPoint = TrackPoint(
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        accuracy: accuracy,
        speed: speed,
        timestamp: timestamp,
      );

      _currentPosition = trackPoint;
      
      // 添加到历史
      _positionHistory.add(trackPoint);
      if (_positionHistory.length > _maxHistorySize) {
        _positionHistory.removeAt(0);
      }

      // 如果在录制中，处理轨迹点
      if (isRecording) {
        _processTrackPoint(trackPoint);
      }

      onLocationUpdated?.call();
    } catch (e) {
      // 静默处理定位错误
    }
  }

  /// 处理轨迹点
  void _processTrackPoint(TrackPoint point) {
    // 精度过滤
    if (point.accuracy > _minAccuracy) return;

    // 距离过滤
    if (_lastTrackPoint != null) {
      final distance = _calculateDistance(
        _lastTrackPoint!.latitude,
        _lastTrackPoint!.longitude,
        point.latitude,
        point.longitude,
      );
      
      if (distance < _minMoveDistance) return;

      // 更新总距离
      final newDistance = _currentSession!.totalDistanceMeters + distance;
      
      // 计算海拔变化
      double elevationGain = _currentSession!.elevationGain;
      double elevationLoss = _currentSession!.elevationLoss;
      final altitudeDiff = point.altitude - _lastTrackPoint!.altitude;
      
      if (altitudeDiff > 0.5) {
        elevationGain += altitudeDiff;
      } else if (altitudeDiff < -0.5) {
        elevationLoss += altitudeDiff.abs();
      }

      _currentSession = _currentSession!.copyWith(
        totalDistanceMeters: newDistance,
        elevationGain: elevationGain,
        elevationLoss: elevationLoss,
      );
    }

    // 添加到轨迹点列表
    final updatedPoints = [..._currentSession!.trackPoints, point];
    _currentSession = _currentSession!.copyWith(trackPoints: updatedPoints);
    
    _tempTrackPoints.add(point);
    _lastTrackPoint = point;

    // 更新统计
    _updateStats();

    notifyListeners();
  }

  /// 更新统计数据
  void _updateStats() {
    if (_currentSession == null || _currentSession!.trackPoints.isEmpty) {
      _stats = RecordingStats.empty();
      return;
    }

    final points = _currentSession!.trackPoints;
    double maxSpeed = 0;
    double maxAltitude = points.first.altitude;
    double minAltitude = points.first.altitude;
    double totalSpeed = 0;
    int speedCount = 0;

    for (final point in points) {
      if (point.speed != null && point.speed! > 0) {
        maxSpeed = point.speed! > maxSpeed ? point.speed! : maxSpeed;
        totalSpeed += point.speed!;
        speedCount++;
      }
      
      if (point.altitude > maxAltitude) maxAltitude = point.altitude;
      if (point.altitude < minAltitude) minAltitude = point.altitude;
    }

    _stats = RecordingStats(
      currentSpeed: points.last.speed ?? 0,
      averageSpeed: speedCount > 0 ? totalSpeed / speedCount : 0,
      maxSpeed: maxSpeed,
      currentAltitude: points.last.altitude,
      maxAltitude: maxAltitude,
      minAltitude: minAltitude,
      pointCount: points.length,
    );
  }

  /// 开始录制定时器
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    
    _recordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onTick(),
    );
  }

  /// 定时器回调
  void _onTick() {
    if (_currentSession == null || !isRecording) return;

    final newDuration = _currentSession!.durationSeconds + 1;
    
    _currentSession = _currentSession!.copyWith(
      durationSeconds: newDuration,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }

  /// 保存当前会话到本地
  Future<void> _saveCurrentSession() async {
    if (_currentSession == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      LocalRecordingData data;
      if (jsonString != null) {
        data = LocalRecordingData.fromJsonString(jsonString);
      } else {
        data = LocalRecordingData();
      }

      // 查找并替换现有会话，或添加新会话
      final existingIndex = data.sessions.indexWhere(
        (s) => s.id == _currentSession!.id
      );

      List<RecordingSession> updatedSessions;
      if (existingIndex >= 0) {
        updatedSessions = [...data.sessions];
        updatedSessions[existingIndex] = _currentSession!;
      } else {
        updatedSessions = [...data.sessions, _currentSession!];
      }

      final updatedData = LocalRecordingData(sessions: updatedSessions);
      await prefs.setString(_storageKey, updatedData.toJsonString());
    } catch (e) {
      // 静默处理保存错误
    }
  }

  /// 根据ID获取会话
  Future<RecordingSession?> _getSessionById(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) return null;

    final data = LocalRecordingData.fromJsonString(jsonString);
    return data.sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => null as RecordingSession,
    );
  }

  /// 标记会话为已上传
  Future<void> _markSessionUploaded(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) return;

    final data = LocalRecordingData.fromJsonString(jsonString);
    final updatedSessions = data.sessions.map((s) {
      if (s.id == sessionId) {
        return s.copyWith(isUploaded: true);
      }
      return s;
    }).toList();

    final updatedData = LocalRecordingData(sessions: updatedSessions);
    await prefs.setString(_storageKey, updatedData.toJsonString());
  }

  /// 生成会话ID
  String _generateSessionId() {
    return 'rec_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// 生成POI ID
  String _generatePoiId() {
    return 'poi_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// 计算两点间距离（米）
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _locationSubscription?.cancel();
    _locationPlugin?.stopLocation();
    _locationPlugin?.destroy();
    super.dispose();
  }
}
