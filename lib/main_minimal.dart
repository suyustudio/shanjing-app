import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

// 最小化地图测试 - 确保能正常显示
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MinimalMapApp());
}

class MinimalMapApp extends StatelessWidget {
  const MinimalMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '山径 - 地图测试',
      home: const MinimalMapScreen(),
    );
  }
}

class MinimalMapScreen extends StatefulWidget {
  const MinimalMapScreen({super.key});

  @override
  State<MinimalMapScreen> createState() => _MinimalMapScreenState();
}

class _MinimalMapScreenState extends State<MinimalMapScreen> {
  AMapController? _mapController;

  // 硬编码 API Key（仅用于测试，生产环境应使用环境变量）
  static const String _amapKey = 'e17f8ae117d84e2d2d394a2124866603';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('山径 - 地图测试'),
        backgroundColor: Colors.teal,
      ),
      body: AMapWidget(
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
          target: LatLng(30.25, 120.15), // 杭州
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          debugPrint('地图创建成功');
        },
        // 禁用所有可能导致崩溃的功能
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 移动到杭州
          _mapController?.moveCamera(
            CameraUpdate.newCameraPosition(
              const CameraPosition(
                target: LatLng(30.25, 120.15),
                zoom: 14,
              ),
            ),
          );
        },
        child: const Icon(Icons.location_on),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
