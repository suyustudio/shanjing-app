import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import '../analytics/analytics.dart';
import '../widgets/app_app_bar.dart';
import '../widgets/sos_button.dart';
import '../constants/design_system.dart';
import '../utils/permission_manager.dart';
import '../services/sos_service.dart';
import '../services/sos_service_enhanced.dart' show SOSSendResult;

/// 导航状态枚举
enum NavigationStatus {
  /// 正常导航中
  navigating,
  /// 偏航
  offRoute,
  /// 到达目的地
  arrived,
  /// 信号弱
  weakSignal,
}

/// GPS 位置点
class GPSPoint {
  final double latitude;
  final double longitude;
  final double accuracy; // 精度（米）
  final double? altitude;
  final double? speed;
  final DateTime timestamp;

  GPSPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    required this.timestamp,
  });

  /// 计算两点间距离（米）
  double distanceTo(GPSPoint other) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = _toRadians(other.latitude - latitude);
    final double dLon = _toRadians(other.longitude - longitude);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(other.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;
}

/// 导航指令
class NavigationInstruction {
  final String text;
  final String? voiceText;
  final double? distance; // 距离下一个指令的距离（米）

  NavigationInstruction({
    required this.text,
    this.voiceText,
    this.distance,
  });
}

/// 导航模式枚举
enum NavigationMode {
  /// 规划模式 - 显示路径预览，等待用户确认
  preview,
  /// 导航模式 - 实际导航中
  navigating,
}

/// 增强版导航页面
/// 包含：GPS精度过滤、偏航检测、语音播报、导航进度
class NavigationScreen extends StatefulWidget {
  final String routeName;
  final List<LatLng>? routePoints; // 路线轨迹点
  final LatLng? routeStartPoint; // 路线起点（用于规划到起点的路径）

  const NavigationScreen({
    super.key,
    required this.routeName,
    this.routePoints,
    this.routeStartPoint,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with AnalyticsMixin, WidgetsBindingObserver {
  // 高德地图定位 - 改为可空类型避免未初始化崩溃
  AMapFlutterLocation? _locationPlugin;
  StreamSubscription<Map<String, Object>>? _locationSubscription;

  // 埋点相关
  @override
  String get pageId => PageEvents.pageNavigation;

  @override
  String get pageName => PageEvents.nameNavigation;

  @override
  Map<String, dynamic>? get pageParams => {
        'route_name': widget.routeName,
      };

  // 导航计时（用于计算导航完成时长）
  DateTime? _navigationStartTime;
  bool _navigationCompleted = false;

  // 语音播报
  FlutterTts? _flutterTts;
  bool _isTtsInitialized = false;
  bool _isTtsAvailable = false; // TTS 是否可用

  // GPS 精度过滤
  static const double _minAccuracy = 10.0; // 最小精度要求（米）
  static const int _maxHistorySize = 5; // 历史位置最大数量
  final List<GPSPoint> _positionHistory = []; // 位置历史

  // 偏航检测
  static const double _offRouteThreshold = 50.0; // 偏航阈值（米）
  static const int _offRouteConfirmCount = 3; // 确认偏航所需连续次数
  int _offRouteCount = 0;
  int _totalDeviationCount = 0; // 总偏航次数
  NavigationStatus _status = NavigationStatus.navigating;

  // 暂停统计
  int _pauseCount = 0;
  int _pauseDurationSec = 0;
  DateTime? _lastPauseTime;
  
  // 拍照统计
  int _photoCount = 0;
  
  // 实际行走距离
  double _actualDistanceTraveled = 0;

  // 导航进度
  double _totalDistance = 0; // 总距离（米）
  double _remainingDistance = 0; // 剩余距离（米）
  int _estimatedArrivalMinutes = 0; // 预计到达时间（分钟）

  // 当前位置
  GPSPoint? _currentPosition;
  LatLng? _currentLatLng;

  // 路线轨迹
  late List<LatLng> _routePoints;
  int _currentRouteIndex = 0; // 当前在路线上的位置索引

  // 语音播报控制
  DateTime? _lastVoiceTime;
  static const int _minVoiceInterval = 10; // 最小语音间隔（秒）

  // 地图控制器
  AMapController? _mapController;
  
  // 地图 Widget 的 key，用于正确管理生命周期
  final GlobalKey _mapKey = GlobalKey();

  // 导航模式
  NavigationMode _navigationMode = NavigationMode.preview;
  
  // 到路线起点的规划路径
  List<LatLng> _previewPath = [];
  double _previewDistance = 0;
  bool _isCalculatingPreview = false;

  // 用于防止重复 dispose
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _navigationStartTime = DateTime.now();
    _initRoutePoints();
    _initTts();
    _requestLocationPermission().then((_) {
      // ✅ 埋点：导航初始化完成后触发 navigation_start
      if (mounted && !_navigationCompleted) {
        _trackNavigationStart();
      }
    });
  }
  
  /// 上报 navigation_start 事件
  void _trackNavigationStart() {
    if (!mounted || _navigationCompleted) return;
    
    final startTimestamp = DateTime.now().millisecondsSinceEpoch;
    
    AnalyticsService().trackEvent(
      NavigationEvents.navigationStart,
      params: {
        NavigationEvents.paramRouteName: widget.routeName,
        NavigationEvents.paramRouteDistanceM: _totalDistance.round(),
        NavigationEvents.paramRouteDurationMin: (_totalDistance / 1.4 / 60).ceil(),
        NavigationEvents.paramDifficulty: 'medium', // 默认中等难度，实际应从路线数据获取
        NavigationEvents.paramStartType: 'normal',
        NavigationEvents.paramLocationEnabled: _currentPosition != null,
        NavigationEvents.paramLocationAccuracyM: _currentPosition?.accuracy ?? 0.0,
        NavigationEvents.paramOfflineMode: false, // 默认非离线模式
        NavigationEvents.paramVoiceEnabled: _isTtsInitialized && _isTtsAvailable,
        NavigationEvents.paramStartTimestamp: startTimestamp,
      },
    );
  }

  @override
  void dispose() {
    // 防止重复 dispose
    if (_isDisposing) return;
    _isDisposing = true;
    
    // 先标记导航完成，防止后续事件上报
    _navigationCompleted = true;
    
    // 移除生命周期观察器（在取消订阅之前）
    WidgetsBinding.instance.removeObserver(this);
    
    // 取消定位订阅（最先取消，避免收到新位置更新）
    _locationSubscription?.cancel();
    _locationSubscription = null;
    
    // 停止定位（不调用 destroy，避免崩溃）
    try {
      _locationPlugin?.stopLocation();
    } catch (e) {
      debugPrint('停止定位时出错: $e');
    }
    
    // 停止 TTS
    try {
      if (_isTtsInitialized && _flutterTts != null) {
        _flutterTts!.stop();
      }
    } catch (e) {
      debugPrint('停止 TTS 时出错: $e');
    }
    
    // 释放地图控制器引用（但不销毁，让 Widget 自己处理）
    _mapController = null;
    
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 先检查 mounted 和 disposing 状态，避免页面关闭后执行
    if (!mounted || _isDisposing || _navigationCompleted) return;
    
    // 监听应用前后台切换
    if (state == AppLifecycleState.paused) {
      // 应用进入后台
      AnalyticsService().trackEvent(
        UserEvents.appBackground,
        params: {
          'source_page': pageId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } else if (state == AppLifecycleState.resumed) {
      // 应用回到前台
      AnalyticsService().trackEvent(
        UserEvents.appForeground,
        params: {
          'source_page': pageId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    }
  }

  /// 初始化路线点
  void _initRoutePoints() {
    debugPrint('🗺️ NavigationScreen 初始化路线点');
    debugPrint('🗺️ widget.routePoints: ${widget.routePoints}');
    
    if (widget.routePoints != null && widget.routePoints!.isNotEmpty) {
      debugPrint('🗺️ 使用传入的 routePoints，第一个点: ${widget.routePoints!.first}');
      _routePoints = widget.routePoints!;
    } else {
      debugPrint('🗺️ routePoints 为空，使用默认杭州数据！');
      _routePoints = const [
        LatLng(30.24, 120.14),
        LatLng(30.245, 120.145),
        LatLng(30.25, 120.15),
        LatLng(30.255, 120.155),
        LatLng(30.26, 120.16),
      ];
    }
    
    _calculateTotalDistance();
    _remainingDistance = _totalDistance;
    
    // 计算初始预计时间（假设步行速度 1.4m/s）
    const double walkingSpeed = 1.4; // 米/秒
    _estimatedArrivalMinutes = (_totalDistance / walkingSpeed / 60).ceil();
    
    debugPrint('🗺️ 总距离: $_totalDistance 米, 预计时间: $_estimatedArrivalMinutes 分钟');
  }

  /// 计算总距离
  void _calculateTotalDistance() {
    _totalDistance = 0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      _totalDistance += _calculateDistance(_routePoints[i], _routePoints[i + 1]);
    }
  }

  /// 计算两点间距离（简化版）
  double _calculateDistance(LatLng p1, LatLng p2) {
    const double earthRadius = 6371000;
    final double dLat = (p2.latitude - p1.latitude) * pi / 180;
    final double dLon = (p2.longitude - p1.longitude) * pi / 180;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(p1.latitude * pi / 180) *
            cos(p2.latitude * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// 初始化定位权限
  Future<void> _requestLocationPermission() async {
    // 请求导航所需的所有权限（前台定位、后台定位、通知）
    final results = await PermissionManager.requestNavigationPermissions();
    
    final locationStatus = results['location'];
    final backgroundStatus = results['backgroundLocation'];
    final notificationStatus = results['notification'];

    if (locationStatus == PermissionStatus.granted) {
      _initLocation();
      
      // 检查后台定位权限
      if (backgroundStatus != PermissionStatus.granted) {
        debugPrint('后台定位权限未授予，导航可能在后台无法正常工作');
        if (mounted && !_isDisposing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('建议开启后台定位权限，以确保导航在锁屏时正常工作'),
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: '去设置',
                onPressed: PermissionManager.openAppSettings,
              ),
            ),
          );
        }
      }
      
      // 检查通知权限
      if (notificationStatus != PermissionStatus.granted) {
        debugPrint('通知权限未授予，语音播报可能受限');
      }
    } else if (locationStatus == PermissionStatus.permanentlyDenied) {
      // 权限被永久拒绝
      if (mounted && !_isDisposing) {
        PermissionManager.showPermissionDeniedDialog(
          context,
          title: '需要定位权限',
          content: '导航功能需要定位权限才能正常工作。请在系统设置中开启定位权限。',
        );
      }
      // 使用默认位置
      _useDefaultLocation();
    } else {
      // 权限被拒绝
      if (mounted && !_isDisposing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需要定位权限才能开始导航'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      _useDefaultLocation();
    }
  }
  
  /// 使用默认位置
  void _useDefaultLocation() {
    if (!mounted || _isDisposing) return;
    setState(() {
      _currentPosition = GPSPoint(
        latitude: 30.25,
        longitude: 120.15,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );
      _currentLatLng = const LatLng(30.25, 120.15);
    });
  }

  /// 初始化高德定位
  void _initLocation() {
    try {
      _locationPlugin = AMapFlutterLocation();
      
      // 设置定位选项 - 导航需要高精度、高频率定位
      _locationPlugin?.setLocationOption(AMapLocationOption(
        locationInterval: 2000, // 2秒更新一次
        needAddress: false,
        onceLocation: false,
        locationMode: AMapLocationMode.hightAccuracy,
      ));
      
      // 监听定位结果
      _locationSubscription = _locationPlugin?.onLocationChanged().listen(
        _onLocationUpdate,
        onError: (error) {
          debugPrint('定位错误: $error');
        },
        onDone: () {
          debugPrint('定位流已关闭');
        },
      );

      // 开始定位
      _locationPlugin?.startLocation();
      debugPrint('🚀 高德定位已启动');
    } catch (e) {
      debugPrint('定位初始化错误: $e');
      _useDefaultLocation();
    }
  }

  /// 初始化语音播报 - 增强版，包含可用性检查
  Future<void> _initTts() async {
    try {
      _flutterTts = FlutterTts();
      
      // 检查 TTS 可用性
      final isAvailable = await _flutterTts!.isLanguageAvailable('zh-CN');
      if (isAvailable != true) {
        debugPrint('⚠️ TTS 中文语音不可用');
        _isTtsAvailable = false;
        return;
      }
      
      await _flutterTts!.setLanguage('zh-CN');
      await _flutterTts!.setSpeechRate(0.5);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);
      
      _isTtsInitialized = true;
      _isTtsAvailable = true;
      debugPrint('✅ TTS 初始化成功');
    } catch (e) {
      debugPrint('⚠️ TTS 初始化失败: $e');
      _isTtsInitialized = false;
      _isTtsAvailable = false;
    }
  }

  /// 处理定位更新
  void _onLocationUpdate(Map<String, Object> location) {
    // 检查 mounted 和 disposing 状态，避免页面关闭后更新状态
    if (!mounted || _isDisposing || _navigationCompleted) return;
    
    final double? latitude = location['latitude'] as double?;
    final double? longitude = location['longitude'] as double?;
    final double? accuracy = location['accuracy'] as double?;
    final double? altitude = location['altitude'] as double?;
    final double? speed = location['speed'] as double?;

    if (latitude == null || longitude == null) return;

    final point = GPSPoint(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy ?? 100.0,
      altitude: altitude,
      speed: speed,
      timestamp: DateTime.now(),
    );

    // GPS 精度过滤
    if (!_filterGPSPoint(point)) {
      debugPrint('GPS 精度不足，过滤: accuracy=${point.accuracy}m');
      if (!mounted || _isDisposing) return;
      setState(() => _status = NavigationStatus.weakSignal);
      return;
    }

    if (!mounted || _isDisposing) return;
    setState(() {
      _currentPosition = point;
      _currentLatLng = LatLng(latitude, longitude);
      _status = NavigationStatus.navigating;
    });

    // 在导航模式下才移动地图和更新进度
    if (_navigationMode == NavigationMode.navigating) {
      // 移动地图相机到当前位置（跟随定位）
      if (_mapController != null && _currentLatLng != null) {
        _mapController!.moveCamera(
          CameraUpdate.newLatLng(_currentLatLng!),
        );
      }

      // 更新导航进度
      _updateNavigationProgress();

      // 偏航检测
      _checkOffRoute();

      // 语音播报
      _speakNavigationInstruction();
    } else {
      // 预览模式：计算到起点的路径
      _calculatePreviewPath();
    }
  }

  /// 计算到路线起点的预览路径
  void _calculatePreviewPath() {
    if (_currentPosition == null) return;
    
    final routeStart = widget.routeStartPoint ?? 
        (_routePoints.isNotEmpty ? _routePoints.first : null);
    
    if (routeStart == null) return;
    
    // 简化的路径规划：直接连接当前位置和路线起点
    final currentLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    
    // 检查是否已经靠近起点
    final distanceToStart = _calculateDistance(currentLatLng, routeStart);
    
    if (!mounted || _isDisposing) return;
    setState(() {
      _previewDistance = distanceToStart;
      _previewPath = [currentLatLng, routeStart];
    });
  }

  /// 开始实际导航
  void _startActualNavigation() {
    if (!mounted || _isDisposing) return;
    
    setState(() {
      _navigationMode = NavigationMode.navigating;
      _navigationStartTime = DateTime.now(); // 重置导航开始时间
    });
    
    _speak('开始导航，请跟随路线行走');
    
    // 上报实际导航开始事件
    AnalyticsService().trackEvent(
      NavigationEvents.navigationStart,
      params: {
        NavigationEvents.paramRouteName: widget.routeName,
        'mode': 'actual_navigation',
        NavigationEvents.paramStartTimestamp: DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// GPS 精度过滤
  /// 返回 true 表示该点可用
  bool _filterGPSPoint(GPSPoint point) {
    // 1. 精度检查
    if (point.accuracy > _minAccuracy) {
      return false;
    }

    // 2. 添加到历史
    _positionHistory.add(point);
    if (_positionHistory.length > _maxHistorySize) {
      _positionHistory.removeAt(0);
    }

    // 3. 速度合理性检查（如果有历史数据）
    if (_positionHistory.length >= 2) {
      final prev = _positionHistory[_positionHistory.length - 2];
      final distance = point.distanceTo(prev);
      final timeDiff = point.timestamp.difference(prev.timestamp).inSeconds;

      if (timeDiff > 0) {
        final speed = distance / timeDiff; // 米/秒
        // 如果速度超过 20m/s (72km/h)，认为是异常点
        if (speed > 20) {
          _positionHistory.removeLast();
          return false;
        }
      }
    }

    return true;
  }

  /// 更新导航进度
  void _updateNavigationProgress() {
    if (_currentPosition == null || _routePoints.isEmpty) return;
    // 检查 mounted 状态，避免页面关闭后更新状态
    if (!mounted || _isDisposing || _navigationCompleted) return;

    // 找到当前位置在路线上的最近点
    double minDistance = double.infinity;
    int nearestIndex = 0;

    for (int i = 0; i < _routePoints.length; i++) {
      final distance = _calculateDistance(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        _routePoints[i],
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    _currentRouteIndex = nearestIndex;

    // 计算剩余距离
    double remainingDistance = 0;
    for (int i = nearestIndex; i < _routePoints.length - 1; i++) {
      remainingDistance += _calculateDistance(_routePoints[i], _routePoints[i + 1]);
    }

    // 计算预计到达时间（假设步行速度 1.4m/s）
    const double walkingSpeed = 1.4; // 米/秒
    final estimatedMinutes = (remainingDistance / walkingSpeed / 60).ceil();

    // 更新状态
    if (!mounted || _isDisposing) return;
    setState(() {
      _remainingDistance = remainingDistance;
      _estimatedArrivalMinutes = estimatedMinutes;
    });

    // 检查是否到达终点
    if (nearestIndex >= _routePoints.length - 1) {
      if (!mounted || _isDisposing) return;
      setState(() => _status = NavigationStatus.arrived);
      _navigationCompleted = true;
      
      // 上报导航完成事件（符合 data-tracking-spec-v1.2）
      if (_navigationStartTime != null) {
        final completionTimestamp = DateTime.now().millisecondsSinceEpoch;
        final actualDurationSec = DateTime.now().difference(_navigationStartTime!).inSeconds;
        final actualDistanceM = _totalDistance - _remainingDistance;
        final plannedDurationMin = (_totalDistance / 1.4 / 60).ceil();
        final avgSpeedMs = actualDurationSec > 0 ? actualDistanceM / actualDurationSec : 0.0;
        
        // ✅ trail_navigate_complete 事件（根据规范 v1.2 保留此名称）
        AnalyticsService().trackEvent(
          TrailEvents.trailNavigateComplete,
          params: {
            TrailEvents.paramRouteName: widget.routeName,
            TrailEvents.paramCompletionType: 'auto', // 自动到达终点
            TrailEvents.paramActualDistanceM: actualDistanceM.round(),
            TrailEvents.paramActualDurationSec: actualDurationSec,
            TrailEvents.paramPlannedDistanceM: _totalDistance.round(),
            TrailEvents.paramPlannedDurationMin: plannedDurationMin,
            TrailEvents.paramDeviationCount: _totalDeviationCount,
            TrailEvents.paramAvgSpeedMs: double.parse(avgSpeedMs.toStringAsFixed(2)),
            TrailEvents.paramPauseCount: _pauseCount,
            TrailEvents.paramPauseDurationSec: _pauseDurationSec,
            TrailEvents.paramPhotoCount: _photoCount,
            TrailEvents.paramCompletionTimestamp: completionTimestamp,
          },
        );
        
        AnalyticsService().trackEvent(
          NavigationEvents.navigationComplete,
          params: {
            NavigationEvents.paramRouteName: widget.routeName,
            NavigationEvents.paramDuration: actualDurationSec,
          },
        );
      }
      
      _speak('您已到达目的地，导航结束');
    }
  }

  /// 偏航检测
  void _checkOffRoute() {
    if (_currentPosition == null) return;
    // 检查 mounted 状态，避免页面关闭后更新状态
    if (!mounted || _isDisposing || _navigationCompleted) return;

    // 计算当前位置到路线最近点的距离
    double minDistance = double.infinity;
    for (final point in _routePoints) {
      final distance = _calculateDistance(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        point,
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    // 偏航判断
    if (minDistance > _offRouteThreshold) {
      _offRouteCount++;
      if (_offRouteCount >= _offRouteConfirmCount) {
        if (!mounted || _isDisposing) return;
        setState(() => _status = NavigationStatus.offRoute);
        _totalDeviationCount++; // 统计总偏航次数
        _speak('您已偏离路线，请返回');
        
        // 上报偏航事件
        AnalyticsService().trackEvent(
          NavigationEvents.navigationOffTrack,
          params: {
            NavigationEvents.paramRouteName: widget.routeName,
            NavigationEvents.paramOffTrackDistance: minDistance,
          },
        );
      }
    } else {
      _offRouteCount = 0;
      if (_status == NavigationStatus.offRoute) {
        if (!mounted || _isDisposing) return;
        setState(() => _status = NavigationStatus.navigating);
        _speak('已回到正确路线');
        
        // 上报恢复导航事件
        AnalyticsService().trackEvent(
          NavigationEvents.navigationResume,
          params: {
            NavigationEvents.paramRouteName: widget.routeName,
          },
        );
      }
    }
  }

  /// 语音播报导航指令
  void _speakNavigationInstruction() {
    if (!_isTtsInitialized || !_isTtsAvailable || _flutterTts == null) return;
    if (_currentPosition == null) return;

    // 检查语音间隔
    final now = DateTime.now();
    if (_lastVoiceTime != null) {
      final secondsSinceLastVoice = now.difference(_lastVoiceTime!).inSeconds;
      if (secondsSinceLastVoice < _minVoiceInterval) {
        return;
      }
    }

    // 生成导航指令
    String? instruction;
    if (_remainingDistance < 50) {
      instruction = '即将到达目的地';
    } else if (_remainingDistance < 200) {
      instruction = '距离目的地还有${_remainingDistance.toInt()}米';
    } else if (_remainingDistance < 1000) {
      instruction = '距离目的地还有${(_remainingDistance / 100).toStringAsFixed(1)}百米';
    } else {
      instruction = '距离目的地还有${(_remainingDistance / 1000).toStringAsFixed(1)}公里，预计${_estimatedArrivalMinutes}分钟到达';
    }

    if (instruction != null) {
      _speak(instruction);
      _lastVoiceTime = now;
    }
  }

  /// 语音播报
  Future<void> _speak(String text) async {
    if (!_isTtsInitialized || !_isTtsAvailable || _flutterTts == null) return;
    try {
      await _flutterTts!.speak(text);
    } catch (e) {
      debugPrint('语音播报失败: $e');
    }
  }

  /// 获取状态颜色
  Color _getStatusColor(BuildContext context) {
    switch (_status) {
      case NavigationStatus.navigating:
        return DesignSystem.getPrimary(context);
      case NavigationStatus.offRoute:
        return DesignSystem.getWarning(context);
      case NavigationStatus.arrived:
        return DesignSystem.getSuccess(context);
      case NavigationStatus.weakSignal:
        return DesignSystem.getTextTertiary(context);
    }
  }

  /// 获取状态文本
  String _getStatusText() {
    switch (_status) {
      case NavigationStatus.navigating:
        return '导航中';
      case NavigationStatus.offRoute:
        return '已偏航';
      case NavigationStatus.arrived:
        return '已到达';
      case NavigationStatus.weakSignal:
        return '信号弱';
    }
  }

  /// 重新规划路线
  /// 基于当前位置重新计算到终点的路线
  void _recalculateRoute() {
    if (_currentPosition == null) {
      _speak('定位信息不足，无法重新规划');
      return;
    }

    // 更新路线起点为当前位置
    // 保留终点，重新计算中间路径点
    if (_routePoints.isNotEmpty) {
      final destination = _routePoints.last;
      
      // 检查 mounted 状态，避免页面关闭后调用 setState
      if (!mounted || _isDisposing) return;
      
      setState(() {
        // 简化的重新规划：直接从当前位置到终点
        // 实际项目中应该调用地图 API 进行路径规划
        _routePoints = [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          destination,
        ];
        
        // 重置导航状态
        _currentRouteIndex = 0;
        _offRouteCount = 0;
        _status = NavigationStatus.navigating;
        
        // 重新计算总距离
        _calculateTotalDistance();
        _remainingDistance = _totalDistance;
      });

      _speak('路线已重新规划');
      
      // 检查 mounted 状态，避免页面关闭后操作地图
      if (!mounted || _isDisposing) return;
      
      // 移动地图视角到新路线
      _mapController?.moveCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  /// 触发 SOS 求助
  Future<void> _triggerSos() async {
    if (_currentPosition == null) {
      if (mounted && !_isDisposing) {
        SosStatusSnackBar.showError(context);
      }
      return;
    }

    final location = Location(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      altitude: _currentPosition!.altitude,
      accuracy: _currentPosition!.accuracy,
    );

    // ✅ 调用新的 API，包含所有必需参数
    final result = await SosService().triggerSos(
      location: location,
      triggerType: 'manual', // 用户主动触发
      countdownRemainingSec: 0, // 倒计时已结束
      routeId: null, // 可选参数
      sendMethod: 'both',
    );
    
    final success = result.result == SOSSendResult.success;

    if (mounted && !_isDisposing) {
      if (success) {
        SosStatusSnackBar.showSuccess(context);
      } else {
        SosStatusSnackBar.showError(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppAppBar(
          title: _navigationMode == NavigationMode.preview 
              ? '路线预览: ${widget.routeName}'
              : '导航: ${widget.routeName}',
          backgroundColor: _getStatusColor(context),
          foregroundColor: DesignSystem.getTextInverse(context),
          showBack: true,
        ),
        body: Stack(
          children: [
            // 高德地图
            AMapWidget(
              key: _mapKey,
              apiKey: AMapApiKey(
                iosKey: dotenv.env['AMAP_KEY'] ?? '',
                androidKey: dotenv.env['AMAP_KEY'] ?? '',
              ),
              // 隐私合规声明 - 必须设置，否则地图不会显示
              privacyStatement: const AMapPrivacyStatement(
                hasContains: true,
                hasShow: true,
                hasAgree: true,
              ),
              initialCameraPosition: CameraPosition(
                target: _routePoints.isNotEmpty ? _routePoints.first : (_currentLatLng ?? const LatLng(30.25, 120.15)),
                zoom: 17,
              ),
              // myLocationEnabled 参数在 amap_flutter_map 3.0+ 中已移除
              // 使用定位插件单独控制
              onMapCreated: (controller) {
                // 检查 mounted 状态，避免页面关闭后设置控制器
                if (!mounted || _isDisposing) {
                  // 如果页面已关闭，直接释放控制器
                  return;
                }
                _mapController = controller;
              },
              polylines: _buildPolylines(),
              markers: _buildMarkers(),
            ),

            // 导航信息卡片
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _navigationMode == NavigationMode.preview
                  ? _buildPreviewCard(context)
                  : _buildInfoCard(context),
            ),

            // 底部控制栏
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _navigationMode == NavigationMode.preview
                  ? _buildPreviewBottomCard(context)
                  : _buildBottomCard(context),
            ),

            // SOS 紧急按钮
            if (_navigationMode == NavigationMode.navigating)
              Positioned(
                bottom: 100,
                right: 16,
                child: SOSButton(
                  onTriggered: _triggerSos,
                  size: 56,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 处理返回键
  Future<bool> _onWillPop() async {
    if (_navigationMode == NavigationMode.navigating) {
      // 导航中返回，显示确认对话框
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('结束导航？'),
          content: const Text('您正在导航中，确定要结束导航吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('继续导航'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.getError(context),
                foregroundColor: DesignSystem.getTextInverse(context),
              ),
              child: const Text('结束导航'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  /// 构建地图折线
  Set<Polyline> _buildPolylines() {
    final polylines = <Polyline>{};
    
    // 添加主路线
    if (_routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          points: _routePoints,
          color: _navigationMode == NavigationMode.navigating 
              ? DesignSystem.getPrimary(context)
              : DesignSystem.getPrimary(context).withOpacity(0.5),
          width: 6,
        ),
      );
    }
    
    // 预览模式下，添加从当前位置到起点的路径
    if (_navigationMode == NavigationMode.preview && _previewPath.isNotEmpty) {
      polylines.add(
        Polyline(
          points: _previewPath,
          color: Colors.blue,
          width: 4,
          dashed: true, // 虚线表示规划路径
        ),
      );
    }
    
    return polylines;
  }

  /// 构建地图标记
  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // 路线起点
    if (_routePoints.isNotEmpty) {
      markers.add(
        Marker(
          position: _routePoints.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: '路线起点'),
        ),
      );
    }

    // 路线终点
    if (_routePoints.length > 1) {
      markers.add(
        Marker(
          position: _routePoints.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: '路线终点'),
        ),
      );
    }

    // 当前位置（仅在导航模式下显示）
    if (_navigationMode == NavigationMode.navigating && _currentLatLng != null) {
      markers.add(
        Marker(
          position: _currentLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: '当前位置'),
        ),
      );
    }

    return markers;
  }

  /// 构建预览模式信息卡片
  Widget _buildPreviewCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: DesignSystem.getBackgroundElevated(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.map_outlined,
                  color: DesignSystem.getPrimary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  '路线预览',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.getTextPrimary(context),
                  ),
                ),
                const Spacer(),
                if (_currentPosition != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DesignSystem.getSuccess(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: DesignSystem.getSuccess(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '已定位',
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignSystem.getSuccess(context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 距离信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  context: context,
                  icon: Icons.straighten,
                  value: '${_totalDistance.toStringAsFixed(0)} m',
                  label: '路线总长',
                ),
                if (_previewDistance > 0)
                  _buildInfoItem(
                    context: context,
                    icon: Icons.near_me,
                    value: _previewDistance < 1000 
                        ? '${_previewDistance.toStringAsFixed(0)} m'
                        : '${(_previewDistance / 1000).toStringAsFixed(1)} km',
                    label: '距起点',
                  ),
                _buildInfoItem(
                  context: context,
                  icon: Icons.access_time,
                  value: '${(_totalDistance / 1.4 / 60).ceil()} 分',
                  label: '预计用时',
                ),
              ],
            ),
            
            // 定位提示
            if (_currentPosition == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignSystem.getWarning(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: DesignSystem.getWarning(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '正在获取当前位置...',
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignSystem.getWarning(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建预览模式底部卡片
  Widget _buildPreviewBottomCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: DesignSystem.getBackgroundElevated(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.routeName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignSystem.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('返回'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _currentPosition != null 
                        ? _startActualNavigation 
                        : null,
                    icon: const Icon(Icons.navigation),
                    label: const Text('开始导航'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.getPrimary(context),
                      foregroundColor: DesignSystem.getTextInverse(context),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '点击"开始导航"后，系统将引导您前往路线起点',
              style: TextStyle(
                fontSize: 12,
                color: DesignSystem.getTextTertiary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建导航模式信息卡片
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: DesignSystem.getBackgroundElevated(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态指示
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(context),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(context),
                  ),
                ),
                const Spacer(),
                if (_currentPosition != null)
                  Text(
                    'GPS精度: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                    style: TextStyle(
                      fontSize: 12,
                      color: _currentPosition!.accuracy <= _minAccuracy
                          ? DesignSystem.getSuccess(context)
                          : DesignSystem.getWarning(context),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 距离和时间
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  context: context,
                  icon: Icons.location_on,
                  value: '${_remainingDistance.toStringAsFixed(0)} m',
                  label: '剩余距离',
                ),
                _buildInfoItem(
                  context: context,
                  icon: Icons.access_time,
                  value: '$_estimatedArrivalMinutes 分',
                  label: '预计时间',
                ),
                _buildInfoItem(
                  context: context,
                  icon: Icons.trending_up,
                  value: _totalDistance > 0
                    ? '${((_totalDistance - _remainingDistance) / _totalDistance * 100).toStringAsFixed(0)}%'
                    : '0%',
                  label: '完成进度',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: DesignSystem.getPrimary(context), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DesignSystem.getTextPrimary(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DesignSystem.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  /// 构建导航模式底部控制卡片
  Widget _buildBottomCard(BuildContext context) {
    return Card(
      elevation: 4,
      color: DesignSystem.getBackgroundElevated(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.routeName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignSystem.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 语音开关
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isTtsAvailable = !_isTtsAvailable;
                    });
                    _speak(_isTtsAvailable ? '语音播报已开启' : '语音播报已关闭');
                  },
                  icon: Icon(
                    _isTtsAvailable ? Icons.volume_up : Icons.volume_off,
                    color: _isTtsAvailable ? DesignSystem.getPrimary(context) : DesignSystem.getTextTertiary(context),
                  ),
                ),

                // 结束导航按钮
                ElevatedButton.icon(
                  onPressed: () {
                    _speak('导航结束');
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.getError(context),
                    foregroundColor: DesignSystem.getTextInverse(context),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.stop),
                  label: const Text('结束导航'),
                ),

                // 重新规划
                IconButton(
                  onPressed: () {
                    _speak('正在重新规划路线');
                    _recalculateRoute();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: DesignSystem.getPrimary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
