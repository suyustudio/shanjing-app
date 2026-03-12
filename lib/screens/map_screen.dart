import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/filter_tags.dart';
import '../constants/design_system.dart';
import '../services/offline_map_manager.dart';
import '../utils/permission_manager.dart';
import 'trail_detail_screen.dart';
import 'offline_map_screen.dart';

class RouteInfo {
  final String name;
  final String distance;
  final String duration;
  final LatLng position;
  final String difficulty; // easy, moderate, hard

  const RouteInfo({
    required this.name,
    required this.distance,
    required this.duration,
    required this.position,
    this.difficulty = 'easy',
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _hasPermission = false;
  String _selectedTag = '全部';
  RouteInfo? _selectedRoute;
  final ScrollController _scrollController = ScrollController();
  AMapController? _mapController;
  double _currentZoom = 14;
  int _currentTab = 0; // 0: 地图, 1: 列表
  
  // 离线地图管理
  final OfflineMapManager _offlineManager = OfflineMapManager();
  bool _isOfflineMode = false;
  List<OfflineCity> _downloadedCities = [];
  
  // 高德定位
  late AMapFlutterLocation _locationPlugin;
  StreamSubscription<Map<String, Object>>? _locationSubscription;
  LatLng? _currentLocation; // 当前真实GPS位置

  final List<RouteInfo> _routes = const [
    RouteInfo(
      name: '西湖环湖路线',
      distance: '10.5 km',
      duration: '2小时30分',
      position: LatLng(30.25, 120.15),
      difficulty: 'easy',
    ),
    RouteInfo(
      name: '灵隐寺徒步',
      distance: '5.2 km',
      duration: '1小时45分',
      position: LatLng(30.24, 120.10),
      difficulty: 'moderate',
    ),
    RouteInfo(
      name: '龙井茶园漫步',
      distance: '3.8 km',
      duration: '1小时15分',
      position: LatLng(30.22, 120.12),
      difficulty: 'hard',
    ),
  ];

  // trail-data-001.json 的33个坐标点 [经度, 纬度]
  final List<List<double>> _trailCoords = const [
    [120.1085, 30.2008],
    [120.1092, 30.2015],
    [120.1098, 30.2022],
    [120.1105, 30.2029],
    [120.1112, 30.2036],
    [120.1118, 30.2043],
    [120.1124, 30.2050],
    [120.1130, 30.2057],
    [120.1136, 30.2064],
    [120.1142, 30.2071],
    [120.1148, 30.2078],
    [120.1154, 30.2085],
    [120.1160, 30.2092],
    [120.1166, 30.2099],
    [120.1172, 30.2106],
    [120.1178, 30.2113],
    [120.1184, 30.2120],
    [120.1190, 30.2127],
    [120.1196, 30.2134],
    [120.1202, 30.2141],
    [120.1208, 30.2148],
    [120.1214, 30.2155],
    [120.1220, 30.2162],
    [120.1226, 30.2169],
    [120.1232, 30.2176],
    [120.1238, 30.2183],
    [120.1244, 30.2190],
    [120.1250, 30.2197],
    [120.1256, 30.2204],
    [120.1262, 30.2211],
    [120.1268, 30.2218],
    [120.1274, 30.2225],
    [120.1280, 30.2232],
  ];

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _initOfflineManager();
  }
  
  /// 初始化离线地图管理器
  Future<void> _initOfflineManager() async {
    await _offlineManager.initialize();
    _loadDownloadedCities();
  }
  
  /// 加载已下载的离线地图
  Future<void> _loadDownloadedCities() async {
    final cities = await _offlineManager.getDownloadedOfflineMapList();
    setState(() {
      _downloadedCities = cities;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // 停止定位并释放资源
    _locationSubscription?.cancel();
    _locationPlugin.stopLocation();
    _locationPlugin.destroy();
    // 释放离线地图管理器
    _offlineManager.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    // 请求地图所需权限（定位、存储）
    final results = await PermissionManager.requestMapPermissions();
    
    final locationStatus = results['location'];
    final storageStatus = results['storage'];

    setState(() {
      _hasPermission = locationStatus == PermissionStatus.granted;
    });

    if (locationStatus == PermissionStatus.granted) {
      _initLocation();
    } else if (locationStatus == PermissionStatus.permanentlyDenied) {
      // 权限被永久拒绝，显示设置对话框
      if (mounted) {
        PermissionManager.showPermissionPermanentlyDeniedDialog(
          context,
          permissionName: '定位',
        );
      }
    } else if (locationStatus == PermissionStatus.denied) {
      // 权限被拒绝，显示提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需要定位权限才能显示当前位置'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    // 检查存储权限（离线地图需要）
    if (storageStatus == PermissionStatus.denied || storageStatus == PermissionStatus.permanentlyDenied) {
      debugPrint('存储权限被拒绝，离线地图功能可能受限');
    }
  }
  
  /// 初始化高德定位
  void _initLocation() {
    _locationPlugin = AMapFlutterLocation();
    
    // 使用默认定位参数
    // 高德地图 SDK 3.0+ 使用不同的 API
    // 暂时使用基本定位功能

    // 监听定位结果
    _locationSubscription = _locationPlugin.onLocationChanged().listen(
      _onLocationUpdate,
      onError: (error) {
        debugPrint('定位错误: $error');
      },
    );

    // 开始定位
    _locationPlugin.startLocation();
  }
  
  /// 处理定位更新
  void _onLocationUpdate(Map<String, Object> location) {
    final double? latitude = location['latitude'] as double?;
    final double? longitude = location['longitude'] as double?;
    final double? accuracy = location['accuracy'] as double?;

    if (latitude != null && longitude != null) {
      setState(() {
        _currentLocation = LatLng(latitude, longitude);
      });
      debugPrint('定位更新: lat=$latitude, lng=$longitude, accuracy=${accuracy ?? "unknown"}m');
    }
  }

  void _onSearch(String text) {
    print('搜索: $text');
  }

  void _onMarkerTap(RouteInfo route) {
    setState(() {
      if (_selectedRoute?.name == route.name) {
        _selectedRoute = null;
      } else {
        _selectedRoute = route;
      }
    });
  }

  void _closeCard() {
    setState(() {
      _selectedRoute = null;
    });
  }

  void _viewDetails() {
    if (_selectedRoute != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrailDetailScreen(
            trailData: {
              'name': _selectedRoute!.name,
              'distance': _selectedRoute!.distance,
              'duration': _selectedRoute!.duration,
            },
          ),
        ),
      );
    }
  }

  Widget _buildRouteCard(RouteInfo route) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrailDetailScreen(
                trailData: {
                  'name': route.name,
                  'distance': route.distance,
                  'duration': route.duration,
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.straighten, size: 16, color: DesignSystem.getTextSecondary(context)),
                  const SizedBox(width: 4),
                  Text(
                    route.distance,
                    style: TextStyle(color: DesignSystem.getTextSecondary(context)),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: DesignSystem.getTextSecondary(context)),
                  const SizedBox(width: 4),
                  Text(
                    route.duration,
                    style: TextStyle(color: DesignSystem.getTextSecondary(context)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top - 48,
      child: Stack(
        children: [
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
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.25, 120.15),
              zoom: 14,
            ),
            onMapCreated: _onMapCreated,
            onTap: (_) => _closeCard(),
            // 手势控制 - amap_flutter_map 3.0 使用 gesturesEnabled
            gesturesEnabled: true,
            // myLocationEnabled 参数在 amap_flutter_map 3.0+ 中已移除
            // 使用定位插件单独控制
            markers: _routes.asMap().entries.map((entry) {
              final index = entry.key;
              final route = entry.value;
              return Marker(
                position: route.position,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  route.difficulty == 'easy' ? BitmapDescriptor.hueGreen :
                  route.difficulty == 'moderate' ? BitmapDescriptor.hueOrange :
                  BitmapDescriptor.hueRed,
                ),
                infoWindow: InfoWindow(
                  title: route.name,
                  snippet: '${route.distance} · ${route.duration}',
                ),
                onTap: (String id) => _onMarkerTap(route),
              );
            }).toSet(),
            polylines: {
              Polyline(
                points: _trailCoords.map((c) => LatLng(c[1], c[0])).toList(),
                color: Colors.blue,
                width: 6,
              ),
            },
          ),
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {},
              child: Column(
                children: [
                  SearchBar(
                    hintText: '搜索地点',
                    onSubmitted: _onSearch,
                  ),
                  const SizedBox(height: 8),
                  FilterTags(
                    selectedTag: _selectedTag,
                    onSelect: (tag) {
                      debugPrint('筛选标签: $tag');
                      setState(() {
                        _selectedTag = tag;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_selectedRoute != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedRoute!.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: DesignSystem.getTextPrimary(context),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 20, color: DesignSystem.getTextSecondary(context)),
                              onPressed: _closeCard,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.straighten, size: 16, color: DesignSystem.getTextSecondary(context)),
                            const SizedBox(width: 4),
                            Text(
                              _selectedRoute!.distance,
                              style: TextStyle(color: DesignSystem.getTextSecondary(context)),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.schedule, size: 16, color: DesignSystem.getTextSecondary(context)),
                            const SizedBox(width: 4),
                            Text(
                              _selectedRoute!.duration,
                              style: TextStyle(color: DesignSystem.getTextSecondary(context)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _viewDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.getPrimary(context),
                              foregroundColor: DesignSystem.getTextInverse(context),
                            ),
                            child: const Text('查看详情'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // 右下角控制按钮
          Positioned(
            right: 16,
            bottom: _selectedRoute != null ? 180 : 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 离线地图下载按钮
                _buildControlButton(
                  icon: Icons.download,
                  onTap: _showOfflineDownloadDialog,
                ),
                const SizedBox(height: 12),
                // 定位按钮
                _buildControlButton(
                  icon: Icons.my_location,
                  onTap: _goToMyLocation,
                ),
                const SizedBox(height: 12),
                // 放大按钮
                _buildControlButton(
                  icon: Icons.add,
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 8),
                // 缩小按钮
                _buildControlButton(
                  icon: Icons.remove,
                  onTap: _zoomOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DesignSystem.getBackgroundElevated(context),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: DesignSystem.getTextPrimary(context),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBar(
            hintText: '搜索路线',
            onSubmitted: _onSearch,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilterTags(
            selectedTag: _selectedTag,
            onSelect: (tag) {
              debugPrint('筛选标签: $tag');
              setState(() {
                _selectedTag = tag;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _routes.length,
            itemBuilder: (context, index) => _buildRouteCard(_routes[index]),
          ),
        ),
      ],
    );
  }

  void _onMapCreated(AMapController controller) {
    _mapController = controller;
  }

  void _goToMyLocation() {
    if (_currentLocation != null) {
      _mapController?.moveCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    } else {
      // 如果还没有获取到定位，使用默认位置
      _mapController?.moveCamera(
        CameraUpdate.newLatLng(const LatLng(30.25, 120.15)),
      );
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(3, 20);
    });
    _mapController?.moveCamera(
      CameraUpdate.zoomTo(_currentZoom),
    );
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(3, 20);
    });
    _mapController?.moveCamera(
      CameraUpdate.zoomTo(_currentZoom),
    );
  }

  // 显示离线下载弹窗
  void _showOfflineDownloadDialog() {
    // 跳转到离线地图管理页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OfflineMapScreen(),
      ),
    ).then((_) {
      // 返回时刷新已下载列表
      _loadDownloadedCities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            title: const Text('杭州西湖'),
            foregroundColor: Colors.white,
            expandedHeight: 0,
            floating: true,
            snap: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      DesignSystem.primary.withOpacity(0.9),
                      DesignSystem.primary.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: DesignSystem.primary.withOpacity(0.7),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _currentTab == 0 ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                color: _currentTab == 0 ? Colors.white : Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '地图',
                                style: TextStyle(
                                  color: _currentTab == 0 ? Colors.white : Colors.white70,
                                  fontWeight: _currentTab == 0 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _currentTab == 1 ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list,
                                color: _currentTab == 1 ? Colors.white : Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '列表',
                                style: TextStyle(
                                  color: _currentTab == 1 ? Colors.white : Colors.white70,
                                  fontWeight: _currentTab == 1 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: _currentTab == 0 ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
    );
  }
}
