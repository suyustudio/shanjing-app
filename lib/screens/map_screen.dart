import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/filter_tags.dart';
import '../constants/design_system.dart';
import 'route_detail_screen.dart';

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
  double _downloadProgress = 0.0; // 离线下载进度
  bool _isDownloading = false; // 是否正在下载

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
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
          builder: (context) => RouteDetailScreen(
            routeName: _selectedRoute!.name,
            distance: _selectedRoute!.distance,
            duration: _selectedRoute!.duration,
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
              builder: (context) => RouteDetailScreen(
                routeName: route.name,
                distance: route.distance,
                duration: route.duration,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    route.distance,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    route.duration,
                    style: const TextStyle(color: Colors.grey),
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
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.25, 120.15),
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationStyleOptions: MyLocationStyleOptions(
              showMyLocation: true,
            ),
            onMapCreated: _onMapCreated,
            onTap: (_) => _closeCard(),
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
                onTap: () => _onMarkerTap(route),
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _closeCard,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.straighten, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _selectedRoute!.distance,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.schedule, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _selectedRoute!.duration,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _viewDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignSystem.primary,
                              foregroundColor: Colors.white,
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
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.grey[800],
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
    _mapController?.moveCamera(
      CameraUpdate.newLatLng(const LatLng(30.25, 120.15)),
    );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('下载离线地图'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前路线: ${_selectedRoute?.name ?? "西湖环湖路线"}'),
            const SizedBox(height: 8),
            const Text('下载范围: 周边 500m'),
            const Text('地图级别: 14-15级'),
            const SizedBox(height: 8),
            const Text('预估大小: ~12MB'),
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _downloadProgress),
              const SizedBox(height: 8),
              Text('${(_downloadProgress * 100).toInt()}%'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          if (!_isDownloading)
            ElevatedButton(
              onPressed: () {
                _startOfflineDownload();
                Navigator.pop(context);
              },
              child: const Text('开始下载'),
            ),
        ],
      ),
    );
  }

  // 开始离线下载（模拟）
  void _startOfflineDownload() {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    // 模拟下载进度
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _downloadProgress = 0.3);
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _downloadProgress = 0.6);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _downloadProgress = 0.9);
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _downloadProgress = 1.0;
        _isDownloading = false;
      });
      // 显示完成提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('离线地图下载完成')),
      );
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
