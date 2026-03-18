import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/design_system.dart';

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
        setState(() {
          _currentPosition = LatLng(latitude, longitude);
          _isLocating = false;
        });
        // 位置已更新，markers 会自动重新构建
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
            // 显示当前位置标记
            markers: _locationMarkers,
          ),
          
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
                        : (_currentPosition != null ? '已定位' : '地图 v2 - 含定位'),
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
