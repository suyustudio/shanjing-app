import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/design_system.dart';
import 'trail_detail_screen.dart';

// 地图页面 v2 - 添加定位功能
class MapScreenSimple extends StatefulWidget {
  const MapScreenSimple({super.key});

  @override
  State<MapScreenSimple> createState() => _MapScreenSimpleState();
}

class _MapScreenSimpleState extends State<MapScreenSimple> {
  AMapController? _mapController;
  AMapFlutterLocation? _locationPlugin;
  
  // 当前位置
  LatLng? _currentPosition;
  bool _isLocating = false;
  
  // 测试路线数据（杭州西湖周边）- 更多点让曲线更平滑，增加停车场
  final List<Map<String, dynamic>> _testRoutes = const [
    {
      'id': '1',
      'name': '断桥残雪',
      'position': LatLng(30.259, 120.148),
      'difficulty': '简单',
      // 白堤漫步路线
      'path': [
        LatLng(30.2575, 120.1465),
        LatLng(30.2578, 120.1468),
        LatLng(30.2580, 120.1470),
        LatLng(30.2582, 120.1472),
        LatLng(30.2585, 120.1474),
        LatLng(30.2588, 120.1476),
        LatLng(30.2590, 120.1478),
        LatLng(30.2592, 120.1480),
        LatLng(30.2594, 120.1482),
        LatLng(30.2596, 120.1484),
        LatLng(30.2598, 120.1486),
        LatLng(30.2600, 120.1488),
        LatLng(30.2602, 120.1490),
        LatLng(30.2604, 120.1492),
        LatLng(30.2606, 120.1494),
      ],
      // 停车场位置
      'parkingLots': [
        {'name': '白堤停车场', 'position': LatLng(30.2585, 120.1470)},
        {'name': '北山街停车场', 'position': LatLng(30.2605, 120.1495)},
      ],
      // 预览图
      'previewImage': 'https://picsum.photos/seed/duanqiao/400/200',
    },
    {
      'id': '2',
      'name': '苏堤春晓',
      'position': LatLng(30.235, 120.135),
      'difficulty': '中等',
      // 苏堤完整路线
      'path': [
        LatLng(30.2280, 120.1365),
        LatLng(30.2285, 120.1363),
        LatLng(30.2290, 120.1360),
        LatLng(30.2295, 120.1358),
        LatLng(30.2300, 120.1356),
        LatLng(30.2305, 120.1355),
        LatLng(30.2310, 120.1354),
        LatLng(30.2315, 120.1354),
        LatLng(30.2320, 120.1353),
        LatLng(30.2325, 120.1353),
        LatLng(30.2330, 120.1352),
        LatLng(30.2335, 120.1352),
        LatLng(30.2340, 120.1351),
        LatLng(30.2345, 120.1351),
        LatLng(30.2350, 120.1350),
        LatLng(30.2355, 120.1349),
        LatLng(30.2360, 120.1348),
        LatLng(30.2365, 120.1347),
        LatLng(30.2370, 120.1346),
        LatLng(30.2375, 120.1345),
        LatLng(30.2380, 120.1344),
        LatLng(30.2385, 120.1343),
        LatLng(30.2390, 120.1342),
        LatLng(30.2395, 120.1341),
        LatLng(30.2400, 120.1340),
        LatLng(30.2405, 120.1338),
        LatLng(30.2410, 120.1336),
      ],
      'parkingLots': [
        {'name': '苏堤南口停车场', 'position': LatLng(30.2280, 120.1365)},
        {'name': '花港观鱼停车场', 'position': LatLng(30.2305, 120.1358)},
        {'name': '曲院风荷停车场', 'position': LatLng(30.2400, 120.1335)},
      ],
      'previewImage': 'https://picsum.photos/seed/sudi/400/200',
    },
    {
      'id': '3',
      'name': '灵隐寺',
      'position': LatLng(30.242, 120.100),
      'difficulty': '困难',
      // 灵隐到飞来峰
      'path': [
        LatLng(30.2380, 120.0980),
        LatLng(30.2383, 120.0982),
        LatLng(30.2386, 120.0984),
        LatLng(30.2389, 120.0986),
        LatLng(30.2392, 120.0988),
        LatLng(30.2395, 120.0990),
        LatLng(30.2398, 120.0992),
        LatLng(30.2401, 120.0994),
        LatLng(30.2404, 120.0996),
        LatLng(30.2407, 120.0998),
        LatLng(30.2410, 120.1000),
        LatLng(30.2413, 120.1002),
        LatLng(30.2416, 120.1004),
        LatLng(30.2419, 120.1006),
        LatLng(30.2422, 120.1008),
        LatLng(30.2425, 120.1010),
        LatLng(30.2428, 120.1012),
        LatLng(30.2431, 120.1014),
        LatLng(30.2434, 120.1016),
        LatLng(30.2437, 120.1018),
        LatLng(30.2440, 120.1020),
        LatLng(30.2443, 120.1023),
        LatLng(30.2446, 120.1026),
      ],
      'parkingLots': [
        {'name': '灵隐停车场', 'position': LatLng(30.2375, 120.0975)},
        {'name': '灵隐百货停车场', 'position': LatLng(30.2390, 120.0985)},
        {'name': '梅灵北路停车场', 'position': LatLng(30.2440, 120.1025)},
      ],
      'previewImage': 'https://picsum.photos/seed/lingyin/400/200',
    },
    {
      'id': '4',
      'name': '法喜寺',
      'position': LatLng(30.235, 120.088),
      'difficulty': '中等',
      // 天竺路
      'path': [
        LatLng(30.2320, 120.0860),
        LatLng(30.2323, 120.0862),
        LatLng(30.2326, 120.0864),
        LatLng(30.2329, 120.0866),
        LatLng(30.2332, 120.0868),
        LatLng(30.2335, 120.0870),
        LatLng(30.2338, 120.0872),
        LatLng(30.2341, 120.0874),
        LatLng(30.2344, 120.0876),
        LatLng(30.2347, 120.0878),
        LatLng(30.2350, 120.0880),
        LatLng(30.2353, 120.0882),
        LatLng(30.2356, 120.0884),
        LatLng(30.2359, 120.0886),
        LatLng(30.2362, 120.0888),
        LatLng(30.2365, 120.0890),
        LatLng(30.2368, 120.0892),
        LatLng(30.2371, 120.0894),
      ],
      'parkingLots': [
        {'name': '法喜寺停车场', 'position': LatLng(30.2315, 120.0855)},
        {'name': '天竺路停车场', 'position': LatLng(30.2340, 120.0875)},
      ],
      'previewImage': 'https://picsum.photos/seed/faxi/400/200',
    },
  ];
  
  // 硬编码 API Key
  static const String _amapKey = 'e17f8ae117d84e2d2d394a2124866603';

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  /// 初始化定位
  void _initLocation() {
    _locationPlugin = AMapFlutterLocation();
    
    // 设置定位选项
    AMapFlutterLocation.setApiKey(_amapKey, _amapKey);
    
    // 监听定位结果
    _locationPlugin?.onLocationChanged().listen((Map<String, Object> result) {
      debugPrint('📍 定位更新: $result');
      
      final double? latitude = result['latitude'] as double?;
      final double? longitude = result['longitude'] as double?;
      
      if (latitude != null && longitude != null && mounted) {
        final newPosition = LatLng(latitude, longitude);
        setState(() {
          _currentPosition = newPosition;
          _isLocating = false;
        });
        // 自动移动地图到当前位置
        _mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newPosition,
              zoom: 16,
            ),
          ),
        );
      }
    });
  }

  /// 请求定位权限并开始定位
  Future<void> _startLocation() async {
    // 请求权限
    final status = await Permission.location.request();
    
    if (status.isGranted) {
      setState(() => _isLocating = true);
      
      // 开始定位
      _locationPlugin?.startLocation();
      
      // 5秒后自动停止（省电）
      Future.delayed(const Duration(seconds: 5), () {
        _stopLocation();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要定位权限才能获取当前位置')),
        );
      }
    }
  }

  /// 停止定位
  void _stopLocation() {
    _locationPlugin?.stopLocation();
    if (mounted) {
      setState(() => _isLocating = false);
    }
  }

  // 当前位置标记
  Set<Marker> get _locationMarkers {
    if (_currentPosition == null) return {};
    return {
      Marker(
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(
          title: '当前位置',
          snippet: '我在这里',
        ),
      ),
    };
  }

  // 路线标记
  Set<Marker> get _routeMarkers {
    return _testRoutes.map((route) {
      final double hueColor;
      switch (route['difficulty']) {
        case '简单':
          hueColor = BitmapDescriptor.hueGreen;
          break;
        case '困难':
          hueColor = BitmapDescriptor.hueRed;
          break;
        case '中等':
        default:
          hueColor = BitmapDescriptor.hueOrange;
          break;
      }

      return Marker(
        position: route['position'] as LatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(hueColor),
        infoWindow: InfoWindow(
          title: route['name'] as String,
          snippet: '难度: ${route['difficulty']}',
        ),
        onTap: (String id) => _onRouteTap(route),
      );
    }).toSet();
  }

  // 所有标记（位置 + 路线 + 停车场）
  Set<Marker> get _allMarkers {
    return {..._locationMarkers, ..._routeMarkers, ..._parkingMarkers};
  }

  // 停车场标记
  Set<Marker> get _parkingMarkers {
    final markers = <Marker>{};
    for (final route in _testRoutes) {
      final parkingLots = route['parkingLots'] as List<dynamic>?;
      if (parkingLots != null) {
        for (final parking in parkingLots) {
          markers.add(
            Marker(
              position: parking['position'] as LatLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(
                title: '🅿️ ${parking['name']}',
                snippet: '停车场',
              ),
            ),
          );
        }
      }
    }
    return markers;
  }

  // 路线轨迹线
  Set<Polyline> get _routePolylines {
    return _testRoutes.map((route) {
      final Color lineColor;
      switch (route['difficulty']) {
        case '简单':
          lineColor = Colors.green;
          break;
        case '困难':
          lineColor = Colors.red;
          break;
        case '中等':
        default:
          lineColor = Colors.orange;
          break;
      }

      return Polyline(
        points: route['path'] as List<LatLng>,
        color: lineColor,
        width: 4,
      );
    }).toSet();
  }

  /// 点击路线标记
  void _onRouteTap(Map<String, dynamic> route) {
    debugPrint('📍 点击路线: ${route['name']}');
    // 移动到路线位置
    _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: route['position'] as LatLng,
          zoom: 16,
        ),
      ),
    );
    // 显示提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${route['name']} - 难度: ${route['difficulty']}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 点击路线卡片 - 跳转到详情页
  void _onRouteCardTap(Map<String, dynamic> route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrailDetailScreen(
          trailData: {
            'id': route['id'],
            'name': route['name'],
            'difficulty': route['difficulty'],
            'difficultyLevel': route['difficulty'] == '简单' ? 2 : route['difficulty'] == '困难' ? 4 : 3,
            'distance': 5.0,
            'duration': 120,
            'elevation': 50,
            'description': '${route['name']}是一条风景优美的徒步路线，难度${route['difficulty']}。',
            'previewImage': route['previewImage'],
            'parkingLots': route['parkingLots'],
          },
        ),
      ),
    );
  }

  /// 显示SOS紧急求助对话框
  void _showSOSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('紧急求助'),
          ],
        ),
        content: const Text(
          '您即将触发紧急求助功能，将向紧急联系人发送您的位置信息。\n\n确定要发送吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('发送求助'),
          ),
        ],
      ),
    );
  }

  /// 触发SOS求助
  void _triggerSOS() {
    // 获取当前位置
    final position = _currentPosition;
    
    // 显示倒计时
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SOSCountdownDialog(
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          _sendSOSMessage(position);
        },
      ),
    );
  }

  /// 发送SOS消息
  void _sendSOSMessage(LatLng? position) {
    // TODO: 调用后端SOS API
    // 目前仅显示提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          position != null
            ? 'SOS已发送！位置：${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'
            : 'SOS已发送！（位置未知，请确保GPS已开启）',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// 构建底部路线卡片列表
  Widget _buildBottomRouteList() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          itemCount: _testRoutes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final route = _testRoutes[index];
            final Color difficultyColor;
            switch (route['difficulty']) {
              case '简单':
                difficultyColor = Colors.green;
                break;
              case '困难':
                difficultyColor = Colors.red;
                break;
              case '中等':
              default:
                difficultyColor = Colors.orange;
                break;
            }

            return GestureDetector(
              onTap: () => _onRouteCardTap(route),
              child: Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignSystem.getBackgroundElevated(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: difficultyColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            route['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '难度: ${route['difficulty']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignSystem.getTextSecondary(context),
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

  /// 定位到当前位置
  void _goToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 16,
          ),
        ),
      );
      // 位置标记已通过 markers 参数自动显示
    } else {
      // 没有位置，先获取
      _startLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 高德地图
          AMapWidget(
            apiKey: const AMapApiKey(
              iosKey: _amapKey,
              androidKey: _amapKey,
            ),
            privacyStatement: const AMapPrivacyStatement(
              hasContains: true,
              hasShow: true,
              hasAgree: true,
            ),
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.25, 120.15), // 杭州西湖
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              debugPrint('✅ 地图创建成功');
              // amap_flutter_map 3.0+ 不支持 setMyLocationEnabled
              // 定位通过 amap_flutter_location 获取，位置标记通过 Marker 添加
            },
            // 只启用基本手势
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            // 显示所有标记（当前位置 + 路线）
            markers: _allMarkers,
            // 显示路线轨迹线
            polylines: _routePolylines,
          ),
          
          // 底部路线卡片列表
          _buildBottomRouteList(),
          
          // 顶部安全区域提示
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: DesignSystem.getPrimary(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLocating)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(Icons.location_on, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _isLocating 
                        ? '正在定位...' 
                        : (_currentPosition != null ? '已定位' : '地图 v7 - 含SOS'),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 定位到当前位置
          FloatingActionButton.small(
            heroTag: 'myLocation',
            onPressed: _isLocating ? null : _goToCurrentLocation,
            backgroundColor: _currentPosition != null ? Colors.green : null,
            child: _isLocating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          // 定位到杭州
          FloatingActionButton.small(
            heroTag: 'hangzhou',
            onPressed: () {
              _mapController?.moveCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(
                    target: LatLng(30.25, 120.15),
                    zoom: 14,
                  ),
                ),
              );
            },
            child: const Icon(Icons.location_city),
          ),
          const SizedBox(height: 8),
          // 放大
          FloatingActionButton.small(
            heroTag: 'zoomIn',
            onPressed: () {
              _mapController?.moveCamera(CameraUpdate.zoomIn());
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          // 缩小
          FloatingActionButton.small(
            heroTag: 'zoomOut',
            onPressed: () {
              _mapController?.moveCamera(CameraUpdate.zoomOut());
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 16),
          // SOS紧急求助按钮
          FloatingActionButton(
            heroTag: 'sos',
            onPressed: _showSOSDialog,
            backgroundColor: Colors.red,
            child: const Text(
              'SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopLocation();
    _locationPlugin?.destroy();
    super.dispose();
  }
}

/// SOS倒计时对话框
class _SOSCountdownDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _SOSCountdownDialog({
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<_SOSCountdownDialog> createState() => _SOSCountdownDialogState();
}

class _SOSCountdownDialogState extends State<_SOSCountdownDialog> {
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        widget.onConfirm();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red),
          SizedBox(width: 8),
          Text('即将发送求助'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('将在倒计时结束后自动发送求助信息'),
          const SizedBox(height: 24),
          Text(
            '$_countdown',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            widget.onCancel();
          },
          child: const Text('取消发送'),
        ),
      ],
    );
  }
}
