import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../constants/design_system.dart';

// 简化的地图页面 - 只显示地图，无定位、无离线功能
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  AMapController? _mapController;
  
  // 硬编码 API Key
  static const String _amapKey = 'e17f8ae117d84e2d2d394a2124866603';

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
            },
            // 只启用基本手势
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
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
                child: const Text(
                  '地图测试版 - 仅显示地图',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
    _mapController?.dispose();
    super.dispose();
  }
}
