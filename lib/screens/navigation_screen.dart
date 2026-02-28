import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../widgets/app_app_bar.dart';
import '../constants/design_system.dart';

class NavigationScreen extends StatelessWidget {
  final String routeName;

  const NavigationScreen({
    super.key,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: '导航: $routeName',
        backgroundColor: DesignSystem.primary,
        foregroundColor: Colors.white,
        showBack: true,
      ),
      body: Stack(
        children: [
          AMapWidget(
            apiKey: AMapApiKey(
              iosKey: dotenv.env['AMAP_KEY'] ?? '',
              androidKey: dotenv.env['AMAP_KEY'] ?? '',
            ),
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.25, 120.15),
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationStyleOptions: MyLocationStyleOptions(
              showMyLocation: true,
            ),
            polylines: {
              Polyline(
                points: const [
                  LatLng(30.24, 120.14),
                  LatLng(30.245, 120.145),
                  LatLng(30.25, 120.15),
                  LatLng(30.255, 120.155),
                  LatLng(30.26, 120.16),
                ],
                color: DesignSystem.primary,
                width: 6,
              ),
            },
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      routeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.navigation, color: DesignSystem.primary),
                        SizedBox(width: 8),
                        Text('正在导航中...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('结束导航'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
