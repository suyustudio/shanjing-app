// recording_screen.dart
// 山径APP - 轨迹录制主界面 (P1修复版)

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/recording_model.dart';
import '../services/recording_service.dart';
import '../widgets/poi_marker_dialog.dart';
import '../constants/design_system.dart';

/// 轨迹录制页面
class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with TickerProviderStateMixin {
  // 高德地图控制器
  AMapController? _mapController;
  
  // 录制服务
  late RecordingService _recordingService;
  
  // 动画控制器 - 录制指示器呼吸灯效果 (1.5s循环)
  late AnimationController _pulseController;
  
  // 电池状态
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batterySubscription;
  int _batteryLevel = 100;
  bool _isPowerSaveMode = false;
  bool _hasShownPowerSaveAlert = false;
  
  // GPS信号状态
  bool _isGpsWeak = false;
  double _gpsAccuracy = 0;
  
  // 页面状态
  bool _isInitializing = true;
  String? _errorMessage;
  bool _showPoiList = false;
  
  // 照片选择器
  final ImagePicker _imagePicker = ImagePicker();
  
  // 地图状态
  LatLng? _currentPosition;
  List<LatLng> _trackPoints = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  
  // 音频播放器（用于提示音）
  bool _enableAudioFeedback = true;

  @override
  void initState() {
    super.initState();
    // 录制指示器呼吸灯效果 - 1.5s循环 (P1修复#8)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _initializeService();
    _initBatteryMonitoring();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _batterySubscription?.cancel();
    super.dispose();
  }

  /// 初始化电池监控 (P1修复#5)
  Future<void> _initBatteryMonitoring() async {
    try {
      // 获取当前电量
      _batteryLevel = await _battery.batteryLevel;
      
      // 监听电量变化
      _batterySubscription = _battery.onBatteryStateChanged.listen((state) async {
        final level = await _battery.batteryLevel;
        if (mounted) {
          setState(() {
            _batteryLevel = level;
          });
          
          // 电量低于20%时提示省电模式
          if (level <= 20 && !_hasShownPowerSaveAlert && !_isPowerSaveMode) {
            _showPowerSaveModeDialog();
          }
        }
      });
    } catch (e) {
      debugPrint('Battery monitoring init failed: $e');
    }
  }

  /// 显示省电模式提示 (P1修复#5)
  void _showPowerSaveModeDialog() {
    _hasShownPowerSaveAlert = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.battery_alert, color: DesignSystem.getWarning(context)),
            const SizedBox(width: 8),
            Text('电量不足', style: DesignSystem.getTitleLarge(context)),
          ],
        ),
        content: Text(
          '当前电量 $_batteryLevel%，建议开启省电模式。\n\n省电模式将降低GPS采样频率以延长续航。',
          style: DesignSystem.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _isPowerSaveMode = true);
              _recordingService.setPowerSaveMode(true);
              Navigator.of(context).pop();
              _showSnackBar('已开启省电模式');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getWarning(context),
              foregroundColor: DesignSystem.textInverse,
            ),
            child: const Text('开启省电模式'),
          ),
        ],
      ),
    );
  }

  /// 初始化服务
  Future<void> _initializeService() async {
    _recordingService = RecordingService();
    _recordingService.onRecordingStarted = _onRecordingStarted;
    _recordingService.onRecordingPaused = _onRecordingPaused;
    _recordingService.onRecordingResumed = _onRecordingResumed;
    _recordingService.onRecordingStopped = _onRecordingStopped;
    _recordingService.onError = _onError;
    _recordingService.onLocationUpdated = _onLocationUpdated;
    _recordingService.onGpsAccuracyChanged = _onGpsAccuracyChanged;

    final initialized = await _recordingService.initialize();
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
        if (!initialized) {
          _errorMessage = '定位初始化失败，请检查权限设置';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _recordingService,
      child: Scaffold(
        backgroundColor: DesignSystem.getBackground(context),
        body: Stack(
          children: [
            // 地图层
            _buildMap(),
            
            // GPS信号弱提示 (P1修复#6)
            if (_isGpsWeak && _recordingService.isRecording)
              _buildGpsWeakBanner(),
            
            // 顶部状态栏
            _buildTopBar(),
            
            // 底部控制面板 (P1修复#3)
            _buildBottomPanel(),
            
            // POI列表（可展开）
            if (_showPoiList) _buildPoiListPanel(),
            
            // 初始化加载
            if (_isInitializing) _buildLoadingOverlay(),
            
            // 错误提示
            if (_errorMessage != null) _buildErrorOverlay(),
          ],
        ),
      ),
    );
  }

  /// 构建GPS信号弱提示条 (P1修复#6)
  Widget _buildGpsWeakBanner() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: DesignSystem.getError(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: DesignSystem.getShadow(context),
        ),
        child: Row(
          children: [
            Icon(Icons.gps_off, color: DesignSystem.textInverse, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'GPS信号弱，定位精度不足',
                style: TextStyle(
                  color: DesignSystem.textInverse,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '精度: ${_gpsAccuracy.toStringAsFixed(0)}m',
              style: TextStyle(
                color: DesignSystem.textInverse.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建地图
  Widget _buildMap() {
    return AMapWidget(
      apiKey: const AMapApiKey(
        iosKey: '',
        androidKey: '',
      ),
      initialCameraPosition: const CameraPosition(
        target: LatLng(30.259, 120.148), // 默认杭州
        zoom: 15,
      ),
      polylines: _polylines,
      markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
        // 移动到当前位置
        if (_currentPosition != null) {
          _mapController?.moveCamera(
            CameraUpdate.newLatLng(_currentPosition!),
          );
        }
      },
    );
  }

  /// 构建顶部状态栏
  Widget _buildTopBar() {
    return SafeArea(
      child: Consumer<RecordingService>(
        builder: (context, service, child) {
          final status = service.status;
          final session = service.currentSession;
          
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isGpsWeak && service.isRecording
                  ? DesignSystem.getError(context).withOpacity(0.95) // GPS弱时变红 (P1修复#6)
                  : DesignSystem.getSurface(context).withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: DesignSystem.getShadow(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 状态指示器行
                Row(
                  children: [
                    // 录制状态指示灯 - 呼吸灯效果 (P1修复#8)
                    if (status == RecordingStatus.recording)
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_pulseController),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: DesignSystem.getError(context),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: DesignSystem.getError(context).withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: status == RecordingStatus.paused 
                              ? DesignSystem.getWarning(context) 
                              : DesignSystem.getTextTertiary(context),
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isGpsWeak && service.isRecording
                            ? DesignSystem.textInverse
                            : DesignSystem.getTextPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    // 电量显示 (P1修复#5)
                    _buildBatteryIndicator(),
                    const SizedBox(width: 12),
                    // POI数量
                    if (session != null) ...[
                      _buildStatChip(
                        Icons.location_on,
                        '${session.pois.length}',
                        DesignSystem.getInfo(context),
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.photo,
                        '${session.photoCount}',
                        DesignSystem.getPrimary(context),
                      ),
                    ],
                  ],
                ),
                
                if (session != null) ...[
                  const Divider(height: 16),
                  // 录制数据 - 使用 DIN Alternate Bold 32px (P1修复#7)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItemWithFont(
                        '时长',
                        _isGpsWeak && service.isRecording ? '--:--' : session.formattedDuration,
                        Icons.timer,
                      ),
                      _buildStatItemWithFont(
                        '距离',
                        _isGpsWeak && service.isRecording ? '--' : session.formattedDistance,
                        Icons.straighten,
                      ),
                      _buildStatItemWithFont(
                        '爬升',
                        _isGpsWeak && service.isRecording ? '--' : '${session.elevationGain.toStringAsFixed(0)}m',
                        Icons.trending_up,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建电量指示器 (P1修复#5)
  Widget _buildBatteryIndicator() {
    Color batteryColor;
    IconData batteryIcon;
    
    if (_batteryLevel <= 20) {
      batteryColor = DesignSystem.getError(context);
      batteryIcon = Icons.battery_alert;
    } else if (_batteryLevel <= 50) {
      batteryColor = DesignSystem.getWarning(context);
      batteryIcon = Icons.battery_3_bar;
    } else {
      batteryColor = DesignSystem.getSuccess(context);
      batteryIcon = Icons.battery_full;
    }
    
    // 省电模式指示
    if (_isPowerSaveMode) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco,
            size: 16,
            color: DesignSystem.getWarning(context),
          ),
          const SizedBox(width: 4),
          Text(
            '省电',
            style: TextStyle(
              fontSize: 12,
              color: DesignSystem.getWarning(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(batteryIcon, size: 16, color: batteryColor),
        const SizedBox(width: 2),
        Text(
          '$_batteryLevel%',
          style: TextStyle(
            fontSize: 12,
            color: batteryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建统计项 - 使用 DIN Alternate Bold 字体 (P1修复#7)
  Widget _buildStatItemWithFont(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: DesignSystem.getTextSecondary(context)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: DesignSystem.getTextSecondary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 32, // 32px (P1修复#7)
            fontWeight: FontWeight.bold,
            // DIN Alternate Bold 字体 - 在 Flutter 中需要配置字体包
            // 这里使用系统等宽字体作为替代，实际项目中需要添加字体文件
            fontFamily: 'DINAlternate', 
            color: DesignSystem.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  /// 构建统计项（旧版，保留兼容）
  Widget _buildStatItem(String label, String value, IconData icon) {
    return _buildStatItemWithFont(label, value, icon);
  }

  /// 构建统计芯片
  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部控制面板 (P1修复#3) - [标记POI][拍照][暂停][结束]，72px圆形按钮
  Widget _buildBottomPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Consumer<RecordingService>(
          builder: (context, service, child) {
            final status = service.status;
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignSystem.getSurface(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignSystem.getTextPrimary(context).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 控制按钮行 - [标记POI][拍照][暂停][结束] (P1修复#3)
                    if (status == RecordingStatus.recording)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 1. 标记POI按钮 - 72px圆形
                          _buildCircularControlButton(
                            icon: Icons.add_location_alt,
                            label: '标记',
                            color: DesignSystem.getWarning(context),
                            onPressed: () => _showPoiMarkerDialog(),
                            size: 72,
                          ),
                          // 2. 拍照按钮 - 72px圆形 (P1修复#4)
                          _buildCircularControlButton(
                            icon: Icons.camera_alt,
                            label: '拍照',
                            color: DesignSystem.getInfo(context),
                            onPressed: () => _takeTrailPhoto(),
                            size: 72,
                          ),
                          // 3. 暂停按钮 - 72px圆形
                          _buildCircularControlButton(
                            icon: Icons.pause,
                            label: '暂停',
                            color: DesignSystem.getWarning(context),
                            onPressed: _pauseRecording,
                            size: 72,
                          ),
                          // 4. 结束按钮 - 72px圆形
                          _buildCircularControlButton(
                            icon: Icons.stop,
                            label: '结束',
                            color: DesignSystem.getError(context),
                            onPressed: _confirmStopRecording,
                            size: 72,
                          ),
                        ],
                      )
                    else if (status == RecordingStatus.paused)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 暂停状态下：继续 | 结束 | 放弃
                          _buildCircularControlButton(
                            icon: Icons.play_arrow,
                            label: '继续',
                            color: DesignSystem.getSuccess(context),
                            onPressed: _resumeRecording,
                            size: 72,
                          ),
                          _buildCircularControlButton(
                            icon: Icons.stop,
                            label: '结束',
                            color: DesignSystem.getError(context),
                            onPressed: _confirmStopRecording,
                            size: 72,
                          ),
                          _buildCircularControlButton(
                            icon: Icons.delete_outline,
                            label: '放弃',
                            color: DesignSystem.getTextSecondary(context),
                            onPressed: _confirmDiscardRecording,
                            size: 72,
                          ),
                        ],
                      )
                    else if (status == RecordingStatus.idle)
                      // 开始录制大按钮
                      _buildLargeStartButton()
                    else
                      // 已完成状态
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCircularControlButton(
                            icon: Icons.check,
                            label: '已完成',
                            color: DesignSystem.getTextTertiary(context),
                            onPressed: null,
                            size: 72,
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // POI列表切换按钮（仅录制/暂停时显示）
                    if (status == RecordingStatus.recording || status == RecordingStatus.paused)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showPoiList = !_showPoiList;
                          });
                        },
                        icon: Icon(
                          _showPoiList ? Icons.expand_more : Icons.expand_less,
                          color: DesignSystem.getTextSecondary(context),
                        ),
                        label: Text(
                          _showPoiList ? '收起标记列表' : '查看标记列表',
                          style: TextStyle(color: DesignSystem.getTextSecondary(context)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建圆形控制按钮 - 72px (P1修复#3)
  Widget _buildCircularControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required double size,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: onPressed != null ? color : DesignSystem.getTextTertiary(context).withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Icon(
                icon,
                color: DesignSystem.textInverse,
                size: size * 0.35,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: onPressed != null ? color : DesignSystem.getTextTertiary(context),
          ),
        ),
      ],
    );
  }

  /// 构建大开始按钮
  Widget _buildLargeStartButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: DesignSystem.getError(context),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: DesignSystem.getError(context).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _startRecording,
              customBorder: const CircleBorder(),
              child: const Icon(
                Icons.fiber_manual_record,
                color: DesignSystem.textInverse,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '开始录制',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: DesignSystem.getError(context),
          ),
        ),
      ],
    );
  }

  /// 构建POI列表面板
  Widget _buildPoiListPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 200,
      child: Consumer<RecordingService>(
        builder: (context, service, child) {
          final pois = service.currentSession?.pois ?? [];
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: DesignSystem.getSurface(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: DesignSystem.getShadow(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题栏
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: DesignSystem.getInfo(context)),
                      const SizedBox(width: 8),
                      Text(
                        '已标记点 (${pois.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: DesignSystem.getTextPrimary(context),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showPoiList = false;
                          });
                        },
                        icon: Icon(Icons.close, color: DesignSystem.getTextSecondary(context)),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: DesignSystem.getDivider(context)),
                // POI列表
                if (pois.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '还没有标记点\n点击"标记"按钮添加',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: DesignSystem.getTextSecondary(context)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: pois.length,
                      itemBuilder: (context, index) {
                        final poi = pois[index];
                        return PoiMarkerCard(
                          poi: poi,
                          onTap: () => _focusOnPoi(poi),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建加载遮罩
  Widget _buildLoadingOverlay() {
    return Container(
      color: DesignSystem.getBackground(context).withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: DesignSystem.getPrimary(context)),
            const SizedBox(height: 16),
            Text(
              '正在初始化定位服务...',
              style: TextStyle(color: DesignSystem.getTextPrimary(context)),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误遮罩
  Widget _buildErrorOverlay() {
    return Container(
      color: DesignSystem.getBackground(context).withOpacity(0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: DesignSystem.getError(context)),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: DesignSystem.getTextPrimary(context), fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== 事件处理 ==========

  void _onRecordingStarted() {
    HapticFeedback.mediumImpact();
    if (_enableAudioFeedback) {
      // 播放提示音
    }
    _showSnackBar('开始录制轨迹');
  }

  void _onRecordingPaused() {
    HapticFeedback.mediumImpact();
    _showSnackBar('录制已暂停');
  }

  void _onRecordingResumed() {
    HapticFeedback.mediumImpact();
    _showSnackBar('继续录制');
  }

  void _onRecordingStopped() {
    HapticFeedback.heavyImpact();
    _showSnackBar('录制已结束，数据已保存');
    
    // 显示上传对话框
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showUploadDialog();
      }
    });
  }

  void _onError(String error) {
    _showSnackBar(error, isError: true);
  }

  void _onLocationUpdated() {
    final position = _recordingService.currentPosition;
    if (position != null) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        
        // 更新轨迹线
        final trackPoints = _recordingService.tempTrackPoints;
        _trackPoints = trackPoints
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        
        _updatePolylines();
        _updateMarkers();
      });

      // 跟随模式：移动地图到当前位置
      if (_recordingService.isRecording && _mapController != null) {
        _mapController?.moveCamera(
          CameraUpdate.newLatLng(_currentPosition!),
        );
      }
    }
  }

  /// GPS精度变化回调 (P1修复#6)
  void _onGpsAccuracyChanged(double accuracy) {
    setState(() {
      _gpsAccuracy = accuracy;
      _isGpsWeak = accuracy > 20.0; // 精度大于20米认为信号弱
    });
  }

  // ========== 控制方法 ==========

  Future<void> _startRecording() async {
    // 显示路线信息预填写对话框（紧急修复）
    final trailInfo = await _showTrailInfoDialog();
    if (trailInfo == null) {
      return; // 用户取消
    }

    // 检查并申请必要权限
    final hasPermissions = await _checkAndRequestPermissions();
    if (!hasPermissions) {
      _showSnackBar('需要定位、相机和存储权限才能录制', isError: true);
      return;
    }

    final result = await _recordingService.startRecording(trailName: trailInfo['name']);
    if (!result && mounted) {
      _showSnackBar('无法开始录制，请检查GPS信号', isError: true);
    }
  }

  /// 显示路线信息预填写对话框（紧急修复）
  Future<Map<String, dynamic>?> _showTrailInfoDialog() async {
    final trailNameController = TextEditingController();
    final cityController = TextEditingController(text: '上海');
    final descriptionController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('路线信息', style: DesignSystem.getTitleLarge(context)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: trailNameController,
                decoration: InputDecoration(
                  labelText: '路线名称*',
                  hintText: '例如：世纪公园环线',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLength: 50,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: '城市',
                  hintText: '例如：上海',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: '路线描述（可选）',
                  hintText: '简单描述这条路线...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 8),
              Text(
                '*为必填项。路线名称将用于保存和识别轨迹。',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignSystem.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (trailNameController.text.trim().isEmpty) {
                _showSnackBar('请填写路线名称', isError: true);
                return;
              }
              Navigator.of(context).pop({
                'name': trailNameController.text.trim(),
                'city': cityController.text.trim(),
                'description': descriptionController.text.trim(),
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getPrimary(context),
              foregroundColor: DesignSystem.textInverse,
            ),
            child: const Text('开始录制'),
          ),
        ],
      ),
    );
  }

  /// 检查并申请必要权限（紧急修复）
  Future<bool> _checkAndRequestPermissions() async {
    // 需要定位、相机、存储权限
    final permissions = [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        return false;
      }
    }

    return true;
  }

  Future<void> _pauseRecording() async {
    await _recordingService.pauseRecording();
  }

  Future<void> _resumeRecording() async {
    await _recordingService.resumeRecording();
  }

  Future<void> _confirmStopRecording() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('结束录制', style: DesignSystem.getTitleLarge(context)),
        content: Text(
          '确定要结束当前轨迹录制吗？结束后可以上传路线。',
          style: DesignSystem.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getError(context),
              foregroundColor: DesignSystem.textInverse,
            ),
            child: const Text('结束'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _recordingService.stopRecording();
    }
  }

  Future<void> _confirmDiscardRecording() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('放弃录制', style: DesignSystem.getTitleLarge(context)),
        content: Text(
          '确定要放弃当前录制吗？已记录的数据将丢失。',
          style: DesignSystem.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getError(context),
              foregroundColor: DesignSystem.textInverse,
            ),
            child: const Text('放弃'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 删除当前会话
      final sessionId = _recordingService.currentSession?.id;
      if (sessionId != null) {
        await _recordingService.deleteSession(sessionId);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showPoiMarkerDialog() {
    PoiMarkerDialog.show(
      context: context,
      onConfirm: (type, name, description, photos) {
        _recordingService.addPoi(
          type: type,
          name: name,
          description: description,
        );
        // 更新POI照片
        if (photos.isNotEmpty) {
          // 这里需要获取刚添加的POI ID来更新照片
          // 简化处理：暂时不关联照片
        }
      },
    );
  }

  /// 拍摄轨迹照片 (P1修复#4) - 独立拍照功能
  Future<void> _takeTrailPhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        // 将照片关联到轨迹（而非特定POI）
        await _recordingService.addTrailPhoto(photo.path);
        if (mounted) {
          _showSnackBar('照片已保存到轨迹');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('拍照失败: $e', isError: true);
      }
    }
  }

  Future<void> _showUploadDialog() async {
    final session = _recordingService.currentSession;
    if (session == null) return;

    // 跳转到编辑页面
    Navigator.of(context).pushReplacementNamed(
      '/recording/edit',
      arguments: session,
    );
  }

  void _focusOnPoi(PoiMarker poi) {
    _mapController?.moveCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(poi.latitude, poi.longitude),
        18,
      ),
    );
    setState(() {
      _showPoiList = false;
    });
  }

  // ========== 辅助方法 ==========

  void _updatePolylines() {
    _polylines.clear();
    
    if (_trackPoints.length >= 2) {
      _polylines.add(Polyline(
        points: _trackPoints,
        color: DesignSystem.getPrimary(context),
        width: 5,
      ));
    }
  }

  void _updateMarkers() {
    _markers.clear();
    
    // 添加POI标记
    final pois = _recordingService.currentSession?.pois ?? [];
    for (final poi in pois) {
      _markers.add(Marker(
        position: LatLng(poi.latitude, poi.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerHue(poi.type),
        ),
        infoWindow: InfoWindow(
          title: poi.name ?? poi.type.displayName,
          snippet: poi.description,
        ),
      ));
    }
  }

  double _getMarkerHue(PoiType type) {
    switch (type) {
      case PoiType.start:
        return BitmapDescriptor.hueGreen;
      case PoiType.end:
        return BitmapDescriptor.hueRed;
      case PoiType.danger:
        return BitmapDescriptor.hueRose;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }

  String _getStatusText(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.idle:
        return '准备就绪';
      case RecordingStatus.recording:
        return '正在录制';
      case RecordingStatus.paused:
        return '已暂停';
      case RecordingStatus.finished:
      case RecordingStatus.submitted:
      case RecordingStatus.reviewing:
      case RecordingStatus.approved:
      case RecordingStatus.rejected:
        return '已完成';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? DesignSystem.getError(context) : null,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
