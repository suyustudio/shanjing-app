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
  
  // 自定义标记图标
  BitmapDescriptor? _startMarkerIcon;
  BitmapDescriptor? _endMarkerIcon;
  BitmapDescriptor? _loopMarkerIcon;
  
  // 测试路线数据（杭州西湖周边）- 更多点让曲线更平滑，增加停车场
  final List<Map<String, dynamic>> _testRoutes = const [
    {
      'id': '1',
      'name': '断桥残雪',
      'position': LatLng(30.259, 120.148),
      'difficulty': '简单',
      // 白堤漫步路线 - 贝塞尔曲线平滑路径（50点）
      'path': [
        LatLng(30.257500, 120.146500),
        LatLng(30.257567, 120.146552),
        LatLng(30.257634, 120.146605),
        LatLng(30.257701, 120.146658),
        LatLng(30.257768, 120.146711),
        LatLng(30.257835, 120.146764),
        LatLng(30.257901, 120.146817),
        LatLng(30.257967, 120.146871),
        LatLng(30.258033, 120.146925),
        LatLng(30.258098, 120.146979),
        LatLng(30.258164, 120.147033),
        LatLng(30.258229, 120.147088),
        LatLng(30.258294, 120.147143),
        LatLng(30.258359, 120.147198),
        LatLng(30.258423, 120.147253),
        LatLng(30.258487, 120.147309),
        LatLng(30.258551, 120.147364),
        LatLng(30.258615, 120.147420),
        LatLng(30.258679, 120.147477),
        LatLng(30.258742, 120.147533),
        LatLng(30.258806, 120.147590),
        LatLng(30.258869, 120.147647),
        LatLng(30.258931, 120.147704),
        LatLng(30.258994, 120.147761),
        LatLng(30.259056, 120.147819),
        LatLng(30.259118, 120.147877),
        LatLng(30.259180, 120.147935),
        LatLng(30.259242, 120.147993),
        LatLng(30.259303, 120.148052),
        LatLng(30.259365, 120.148111),
        LatLng(30.259426, 120.148170),
        LatLng(30.259486, 120.148229),
        LatLng(30.259547, 120.148289),
        LatLng(30.259607, 120.148348),
        LatLng(30.259667, 120.148408),
        LatLng(30.259727, 120.148469),
        LatLng(30.259787, 120.148529),
        LatLng(30.259847, 120.148590),
        LatLng(30.259906, 120.148651),
        LatLng(30.259965, 120.148712),
        LatLng(30.260024, 120.148773),
        LatLng(30.260082, 120.148835),
        LatLng(30.260141, 120.148897),
        LatLng(30.260199, 120.148959),
        LatLng(30.260257, 120.149021),
        LatLng(30.260315, 120.149084),
        LatLng(30.260372, 120.149147),
        LatLng(30.260429, 120.149210),
        LatLng(30.260486, 120.149273),
        LatLng(30.260543, 120.149336),
        LatLng(30.260600, 120.149400),
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
      // 苏堤完整路线 - S形贝塞尔曲线（60点）
      'path': [
        LatLng(30.228000, 120.136500),
        LatLng(30.228224, 120.136483),
        LatLng(30.228447, 120.136464),
        LatLng(30.228670, 120.136443),
        LatLng(30.228892, 120.136419),
        LatLng(30.229114, 120.136394),
        LatLng(30.229335, 120.136366),
        LatLng(30.229556, 120.136336),
        LatLng(30.229776, 120.136304),
        LatLng(30.229996, 120.136270),
        LatLng(30.230215, 120.136234),
        LatLng(30.230434, 120.136195),
        LatLng(30.230652, 120.136154),
        LatLng(30.230870, 120.136111),
        LatLng(30.231088, 120.136066),
        LatLng(30.231304, 120.136019),
        LatLng(30.231521, 120.135970),
        LatLng(30.231737, 120.135918),
        LatLng(30.231952, 120.135864),
        LatLng(30.232167, 120.135808),
        LatLng(30.232382, 120.135750),
        LatLng(30.232596, 120.135690),
        LatLng(30.232809, 120.135628),
        LatLng(30.233022, 120.135563),
        LatLng(30.233235, 120.135496),
        LatLng(30.233447, 120.135427),
        LatLng(30.233658, 120.135356),
        LatLng(30.233870, 120.135283),
        LatLng(30.234080, 120.135207),
        LatLng(30.234290, 120.135130),
        LatLng(30.234500, 120.135050),
        LatLng(30.234710, 120.134970),
        LatLng(30.234920, 120.134893),
        LatLng(30.235130, 120.134817),
        LatLng(30.235342, 120.134744),
        LatLng(30.235553, 120.134673),
        LatLng(30.235765, 120.134604),
        LatLng(30.235978, 120.134537),
        LatLng(30.236191, 120.134472),
        LatLng(30.236404, 120.134410),
        LatLng(30.236618, 120.134350),
        LatLng(30.236833, 120.134292),
        LatLng(30.237048, 120.134236),
        LatLng(30.237263, 120.134182),
        LatLng(30.237479, 120.134130),
        LatLng(30.237696, 120.134081),
        LatLng(30.237912, 120.134034),
        LatLng(30.238130, 120.133989),
        LatLng(30.238348, 120.133946),
        LatLng(30.238566, 120.133905),
        LatLng(30.238785, 120.133866),
        LatLng(30.239004, 120.133830),
        LatLng(30.239224, 120.133796),
        LatLng(30.239444, 120.133764),
        LatLng(30.239665, 120.133734),
        LatLng(30.239886, 120.133706),
        LatLng(30.240108, 120.133681),
        LatLng(30.240330, 120.133657),
        LatLng(30.240553, 120.133636),
        LatLng(30.240776, 120.133617),
        LatLng(30.241000, 120.133600),
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
      // 灵隐到飞来峰 - 双段贝塞尔曲线（60点）
      'path': [
        LatLng(30.238000, 120.098000),
        LatLng(30.238086, 120.098088),
        LatLng(30.238172, 120.098175),
        LatLng(30.238260, 120.098260),
        LatLng(30.238349, 120.098344),
        LatLng(30.238438, 120.098426),
        LatLng(30.238529, 120.098507),
        LatLng(30.238621, 120.098586),
        LatLng(30.238713, 120.098664),
        LatLng(30.238807, 120.098740),
        LatLng(30.238901, 120.098815),
        LatLng(30.238997, 120.098888),
        LatLng(30.239093, 120.098960),
        LatLng(30.239191, 120.099030),
        LatLng(30.239290, 120.099099),
        LatLng(30.239389, 120.099166),
        LatLng(30.239490, 120.099232),
        LatLng(30.239591, 120.099297),
        LatLng(30.239693, 120.099360),
        LatLng(30.239797, 120.099421),
        LatLng(30.239901, 120.099481),
        LatLng(30.240007, 120.099540),
        LatLng(30.240113, 120.099597),
        LatLng(30.240221, 120.099652),
        LatLng(30.240329, 120.099707),
        LatLng(30.240438, 120.099759),
        LatLng(30.240549, 120.099810),
        LatLng(30.240660, 120.099860),
        LatLng(30.240772, 120.099908),
        LatLng(30.240886, 120.099955),
        LatLng(30.241000, 120.100000),
        LatLng(30.241131, 120.100071),
        LatLng(30.241262, 120.100143),
        LatLng(30.241392, 120.100216),
        LatLng(30.241521, 120.100290),
        LatLng(30.241649, 120.100366),
        LatLng(30.241776, 120.100442),
        LatLng(30.241903, 120.100520),
        LatLng(30.242029, 120.100598),
        LatLng(30.242154, 120.100678),
        LatLng(30.242278, 120.100759),
        LatLng(30.242402, 120.100840),
        LatLng(30.242524, 120.100923),
        LatLng(30.242646, 120.101007),
        LatLng(30.242767, 120.101092),
        LatLng(30.242888, 120.101178),
        LatLng(30.243007, 120.101266),
        LatLng(30.243126, 120.101354),
        LatLng(30.243244, 120.101443),
        LatLng(30.243362, 120.101534),
        LatLng(30.243478, 120.101625),
        LatLng(30.243594, 120.101718),
        LatLng(30.243709, 120.101812),
        LatLng(30.243823, 120.101906),
        LatLng(30.243936, 120.102002),
        LatLng(30.244049, 120.102099),
        LatLng(30.244161, 120.102197),
        LatLng(30.244272, 120.102296),
        LatLng(30.244382, 120.102396),
        LatLng(30.244491, 120.102498),
        LatLng(30.244600, 120.102600),
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
      // 天竺路 - 蜿蜒S形贝塞尔曲线（45点）
      'path': [
        LatLng(30.232000, 120.086000),
        LatLng(30.232087, 120.086121),
        LatLng(30.232177, 120.086237),
        LatLng(30.232269, 120.086349),
        LatLng(30.232365, 120.086458),
        LatLng(30.232463, 120.086562),
        LatLng(30.232563, 120.086662),
        LatLng(30.232667, 120.086758),
        LatLng(30.232773, 120.086849),
        LatLng(30.232882, 120.086937),
        LatLng(30.232994, 120.087020),
        LatLng(30.233109, 120.087100),
        LatLng(30.233226, 120.087175),
        LatLng(30.233346, 120.087246),
        LatLng(30.233469, 120.087313),
        LatLng(30.233594, 120.087376),
        LatLng(30.233723, 120.087434),
        LatLng(30.233854, 120.087489),
        LatLng(30.233987, 120.087539),
        LatLng(30.234124, 120.087586),
        LatLng(30.234263, 120.087628),
        LatLng(30.234405, 120.087666),
        LatLng(30.234550, 120.087700),
        LatLng(30.234695, 120.087734),
        LatLng(30.234837, 120.087772),
        LatLng(30.234976, 120.087814),
        LatLng(30.235113, 120.087861),
        LatLng(30.235246, 120.087911),
        LatLng(30.235377, 120.087966),
        LatLng(30.235506, 120.088024),
        LatLng(30.235631, 120.088087),
        LatLng(30.235754, 120.088154),
        LatLng(30.235874, 120.088225),
        LatLng(30.235991, 120.088300),
        LatLng(30.236106, 120.088380),
        LatLng(30.236218, 120.088463),
        LatLng(30.236327, 120.088551),
        LatLng(30.236433, 120.088642),
        LatLng(30.236537, 120.088738),
        LatLng(30.236637, 120.088838),
        LatLng(30.236735, 120.088942),
        LatLng(30.236831, 120.089051),
        LatLng(30.236923, 120.089163),
        LatLng(30.237013, 120.089279),
        LatLng(30.237100, 120.089400),
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
    _loadMarkerIcons();
  }

  /// 加载自定义标记图标
  Future<void> _loadMarkerIcons() async {
    final startIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/markers/marker_start_xhdpi.png',
    );
    final endIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/markers/marker_end_xhdpi.png',
    );
    final loopIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/markers/marker_loop_xhdpi.png',
    );
    
    setState(() {
      _startMarkerIcon = startIcon;
      _endMarkerIcon = endIcon;
      _loopMarkerIcon = loopIcon;
    });
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

  // 路线标记 - 使用自定义起点/终点图标
  Set<Marker> get _routeMarkers {
    final markers = <Marker>{};
    
    for (final route in _testRoutes) {
      final path = route['path'] as List<dynamic>?;
      
      if (path != null && path.isNotEmpty) {
        // 添加起点标记
        markers.add(Marker(
          position: path.first as LatLng,
          icon: _startMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: '${route['name']} - 起点',
            snippet: '难度: ${route['difficulty']}',
          ),
        ));
        
        // 添加终点标记
        markers.add(Marker(
          position: path.last as LatLng,
          icon: _endMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: '${route['name']} - 终点',
            snippet: '难度: ${route['difficulty']}',
          ),
        ));
      }
    }
    
    return markers;
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
