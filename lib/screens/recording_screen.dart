// recording_screen.dart
// 山径APP - 轨迹录制主界面

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:provider/provider.dart';
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
  
  // 动画控制器
  late AnimationController _pulseController;
  
  // 页面状态
  bool _isInitializing = true;
  String? _errorMessage;
  bool _showPoiList = false;
  
  // 地图状态
  LatLng? _currentPosition;
  List<LatLng> _trackPoints = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _initializeService();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
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
        body: Stack(
          children: [
            // 地图层
            _buildMap(),
            
            // 顶部状态栏
            _buildTopBar(),
            
            // 底部控制面板
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
      myLocationEnabled: true,
      myLocationStyleOptions: MyLocationStyleOptions(
        showMyLocation: true,
        myLocationType: MyLocationType.location_rotate,
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
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 状态指示器
                Row(
                  children: [
                    // 录制状态指示灯
                    if (status == RecordingStatus.recording)
                      FadeTransition(
                        opacity: _pulseController,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: status == RecordingStatus.paused 
                              ? Colors.orange 
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(status),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // POI数量
                    if (session != null) ...[
                      _buildStatChip(
                        Icons.location_on,
                        '${session.pois.length}',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.photo,
                        '${session.photoCount}',
                        Colors.purple,
                      ),
                    ],
                  ],
                ),
                
                if (session != null) ...[
                  const Divider(height: 16),
                  // 录制数据
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '时长',
                        session.formattedDuration,
                        Icons.timer,
                      ),
                      _buildStatItem(
                        '距离',
                        session.formattedDistance,
                        Icons.straighten,
                      ),
                      _buildStatItem(
                        '爬升',
                        '${session.elevationGain.toStringAsFixed(0)}m',
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

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建统计芯片
  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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

  /// 构建底部控制面板
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
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 控制按钮行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 左侧：POI列表切换
                      _buildControlButton(
                        icon: Icons.list,
                        label: '标记点',
                        color: Colors.blue,
                        onPressed: () {
                          setState(() {
                            _showPoiList = !_showPoiList;
                          });
                        },
                        isActive: _showPoiList,
                      ),
                      
                      // 中间：主控制按钮
                      _buildMainControlButton(status),
                      
                      // 右侧：添加POI
                      _buildControlButton(
                        icon: Icons.add_location_alt,
                        label: '标记',
                        color: Colors.orange,
                        onPressed: status == RecordingStatus.recording
                            ? () => _showPoiMarkerDialog()
                            : null,
                        isActive: false,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 次要控制按钮
                  if (status != RecordingStatus.idle)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 结束录制按钮
                        ElevatedButton.icon(
                          onPressed: _confirmStopRecording,
                          icon: const Icon(Icons.stop),
                          label: const Text('结束录制'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        
                        if (status == RecordingStatus.paused) ...[
                          const SizedBox(width: 16),
                          // 放弃录制按钮
                          OutlinedButton.icon(
                            onPressed: _confirmDiscardRecording,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('放弃'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建主控制按钮
  Widget _buildMainControlButton(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.idle:
        return _buildLargeButton(
          icon: Icons.fiber_manual_record,
          label: '开始录制',
          color: Colors.red,
          onPressed: _startRecording,
          size: 80,
        );
      
      case RecordingStatus.recording:
        return _buildLargeButton(
          icon: Icons.pause,
          label: '暂停',
          color: Colors.orange,
          onPressed: _pauseRecording,
          size: 80,
        );
      
      case RecordingStatus.paused:
        return _buildLargeButton(
          icon: Icons.play_arrow,
          label: '继续',
          color: Colors.green,
          onPressed: _resumeRecording,
          size: 80,
        );
      
      case RecordingStatus.finished:
        return _buildLargeButton(
          icon: Icons.check,
          label: '已完成',
          color: Colors.grey,
          onPressed: null,
          size: 80,
        );
    }
  }

  /// 构建大按钮
  Widget _buildLargeButton({
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
            color: onPressed != null ? color : Colors.grey[400],
            shape: BoxShape.circle,
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
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
                color: Colors.white,
                size: size * 0.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: onPressed != null ? color : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive 
                ? color.withOpacity(0.2) 
                : (onPressed != null ? Colors.grey[100] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Icon(
                icon,
                color: onPressed != null 
                    ? (isActive ? color : Colors.grey[700]) 
                    : Colors.grey[400],
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: onPressed != null 
                ? (isActive ? color : Colors.grey[700]) 
                : Colors.grey[400],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题栏
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '已标记点 (${pois.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showPoiList = false;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // POI列表
                if (pois.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      '还没有标记点\n点击"标记"按钮添加',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
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
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              '正在初始化定位服务...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误遮罩
  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
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

  // ========== 控制方法 ==========

  Future<void> _startRecording() async {
    final result = await _recordingService.startRecording();
    if (!result && mounted) {
      _showSnackBar('无法开始录制，请检查GPS信号', isError: true);
    }
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
        title: const Text('结束录制'),
        content: const Text('确定要结束当前轨迹录制吗？结束后可以上传路线。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        title: const Text('放弃录制'),
        content: const Text('确定要放弃当前录制吗？已记录的数据将丢失。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

  Future<void> _showUploadDialog() async {
    final session = _recordingService.currentSession;
    if (session == null) return;

    final TextEditingController nameController = TextEditingController(
      text: session.trailName,
    );
    final TextEditingController cityController = TextEditingController();
    final TextEditingController districtController = TextEditingController();
    String difficulty = 'EASY';

    if (!mounted) return;

    final shouldUpload = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('上传路线'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '路线名称',
                  hintText: '给这条路线起个名字',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: '城市',
                  hintText: '例如：杭州',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: districtController,
                decoration: const InputDecoration(
                  labelText: '区域',
                  hintText: '例如：西湖区',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: difficulty,
                decoration: const InputDecoration(labelText: '难度'),
                items: const [
                  DropdownMenuItem(value: 'EASY', child: Text('简单')),
                  DropdownMenuItem(value: 'MODERATE', child: Text('中等')),
                  DropdownMenuItem(value: 'HARD', child: Text('困难')),
                ],
                onChanged: (value) => difficulty = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('稍后上传'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('上传'),
          ),
        ],
      ),
    );

    if (shouldUpload == true && mounted) {
      _showSnackBar('正在上传...');
      
      final response = await _recordingService.uploadTrail(
        sessionId: session.id,
        trailName: nameController.text,
        city: cityController.text,
        district: districtController.text,
        difficulty: difficulty,
      );

      if (mounted) {
        if (response?.success == true) {
          _showSnackBar('上传成功！等待审核后发布');
        } else {
          _showSnackBar('上传失败: ${response?.error ?? "未知错误"}', isError: true);
        }
      }
    }
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
        color: Colors.blue,
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
        return '已完成';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : null,
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
