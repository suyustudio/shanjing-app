import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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

/// 增强版导航页面
/// 包含：GPS精度过滤、偏航检测、语音播报、导航进度
class NavigationScreen extends StatefulWidget {
  final String routeName;
  final List<LatLng>? routePoints; // 路线轨迹点

  const NavigationScreen({
    super.key,
    required this.routeName,
    this.routePoints,
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
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;

  // GPS 精度过滤
  static const double _minAccuracy = 10.0; // 最小精度要求（米）
  static const int _maxHistorySize = 5; // 历史位置最大数量
  final List<GPSPoint> _positionHistory = []; // 位置历史

  // 偏航检测
  static const double _offRouteThreshold = 50.0; // 偏航阈值（米）
  static const int _offRouteConfirmCount = 3; // 确认偏航所需连续次数
  int _offRouteCount = 0;
  NavigationStatus _status = NavigationStatus.navigating;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _navigationStartTime = DateTime.now();
    _initRoutePoints();
    _initTts();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 如果导航未完成，上报导航退出事件
    if (!_navigationCompleted && _navigationStartTime != null) {
      final duration = DateTime.now().difference(_navigationStartTime!).inSeconds;
      AnalyticsService().trackEvent(
        NavigationEvents.navigationPause,
        params: {
          NavigationEvents.paramRouteName: widget.routeName,
          NavigationEvents.paramDuration: duration,
          'reason': 'page_closed',
        },
      );
    }
    _locationSubscription?.cancel();
    // 安全释放定位资源 - 检查是否已初始化
    try {
      _locationPlugin?.stopLocation();
    } catch (e) {
      debugPrint('释放定位资源时出错: $e');
    }
    // 安全停止 TTS
    try {
      if (_isTtsInitialized) {
        _flutterTts.stop();
      }
    } catch (e) {
      debugPrint('停止 TTS 时出错: $e');
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
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
        if (mounted) {
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
      if (mounted) {
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
      if (mounted) {
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
    // 检查是否已在 main.dart 中初始化
    // 高德地图 SDK 只需要全局初始化一次
    try {
      _locationPlugin = AMapFlutterLocation();
      
      // 监听定位结果
      _locationSubscription = _locationPlugin?.onLocationChanged().listen(
        _onLocationUpdate,
        onError: (error) {
          debugPrint('定位错误: $error');
        },
      );

      // 开始定位
      _locationPlugin?.startLocation();
    } catch (e) {
      debugPrint('定位初始化错误: $e');
      // 使用默认位置
      _useDefaultLocation();
    }
  }

  /// 初始化语音播报
  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('zh-CN');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isTtsInitialized = true;
    } catch (e) {
      debugPrint('TTS 初始化失败: $e');
    }
  }

  /// 处理定位更新
  void _onLocationUpdate(Map<String, Object> location) {
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
      setState(() => _status = NavigationStatus.weakSignal);
      return;
    }

    setState(() {
      _currentPosition = point;
      _currentLatLng = LatLng(latitude, longitude);
      _status = NavigationStatus.navigating;
    });

    // 更新导航进度
    _updateNavigationProgress();

    // 偏航检测
    _checkOffRoute();

    // 语音播报
    _speakNavigationInstruction();
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
    setState(() {
      _remainingDistance = remainingDistance;
      _estimatedArrivalMinutes = estimatedMinutes;
    });

    // 检查是否到达终点
    if (nearestIndex >= _routePoints.length - 1) {
      setState(() => _status = NavigationStatus.arrived);
      _navigationCompleted = true;
      
      // 上报导航完成事件
      if (_navigationStartTime != null) {
        final duration = DateTime.now().difference(_navigationStartTime!).inSeconds;
        AnalyticsService().trackEvent(
          TrailEvents.trailNavigateComplete,
          params: {
            TrailEvents.paramRouteName: widget.routeName,
            TrailEvents.paramCompletionTime: duration,
          },
        );
        AnalyticsService().trackEvent(
          NavigationEvents.navigationComplete,
          params: {
            NavigationEvents.paramRouteName: widget.routeName,
            NavigationEvents.paramDuration: duration,
          },
        );
      }
      
      _speak('您已到达目的地，导航结束');
    }
  }

  /// 偏航检测
  void _checkOffRoute() {
    if (_currentPosition == null) return;

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
        setState(() => _status = NavigationStatus.offRoute);
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
    if (!_isTtsInitialized || _currentPosition == null) return;

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
    if (!_isTtsInitialized) return;
    try {
      await _flutterTts.speak(text);
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
      SosStatusSnackBar.showError(context);
      return;
    }

    final location = Location(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      altitude: _currentPosition!.altitude,
      accuracy: _currentPosition!.accuracy,
    );

    final success = await SosService().triggerSos(location);

    if (mounted) {
      if (success) {
        SosStatusSnackBar.showSuccess(context);
      } else {
        SosStatusSnackBar.showError(context);
      }
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: '导航: ${widget.routeName}',
        backgroundColor: _getStatusColor(context),
        foregroundColor: DesignSystem.getTextInverse(context),
        showBack: true,
      ),
      body: Stack(
        children: [
          // 高德地图
          AMapWidget(
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
              _mapController = controller;
            },
            polylines: {
              Polyline(
                points: _routePoints,
                color: DesignSystem.getPrimary(context),
                width: 6,
              ),
            },
            markers: _buildMarkers(),
          ),

          // 导航信息卡片
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildInfoCard(context),
          ),

          // 底部控制栏
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildBottomCard(context),
          ),

          // SOS 紧急按钮
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
    );
  }

  /// 构建地图标记
  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // 起点
    if (_routePoints.isNotEmpty) {
      markers.add(
        Marker(
          position: _routePoints.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: '起点'),
        ),
      );
    }

    // 终点
    if (_routePoints.length > 1) {
      markers.add(
        Marker(
          position: _routePoints.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: '终点'),
        ),
      );
    }

    return markers;
  }

  /// 构建顶部信息卡片
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

  /// 构建底部控制卡片
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
                      _isTtsInitialized = !_isTtsInitialized;
                    });
                    _speak(_isTtsInitialized ? '语音播报已开启' : '语音播报已关闭');
                  },
                  icon: Icon(
                    _isTtsInitialized ? Icons.volume_up : Icons.volume_off,
                    color: _isTtsInitialized ? DesignSystem.getPrimary(context) : DesignSystem.getTextTertiary(context),
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
