import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../widgets/map_markers.dart';

/// 使用自定义标记的示例页面
/// 
/// 展示如何在实际地图中集成新的标记图标
class CustomMarkerExample extends StatefulWidget {
  const CustomMarkerExample({super.key});

  @override
  State<CustomMarkerExample> createState() => _CustomMarkerExampleState();
}

class _CustomMarkerExampleState extends State<CustomMarkerExample> {
  AMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  // 示例位置（杭州西湖周边）
  final LatLng _startPosition = const LatLng(30.259, 120.148);
  final LatLng _endPosition = const LatLng(30.260, 120.149);
  final LatLng _parkingPosition = const LatLng(30.2585, 120.1475);

  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  /// 初始化自定义标记
  Future<void> _initMarkers() async {
    // 预加载图标
    await CustomMarkers.preload();

    // 创建标记
    final markers = <Marker>{
      // 起点标记
      Marker(
        markerId: const MarkerId('start'),
        position: _startPosition,
        icon: await CustomMarkers.start(),
        infoWindow: const InfoWindow(
          title: '起点',
          snippet: '从这里开始你的徒步之旅',
        ),
        anchor: const Offset(0.5, 1.0), // 锚点在底部中心
      ),
      
      // 终点标记
      Marker(
        markerId: const MarkerId('end'),
        position: _endPosition,
        icon: await CustomMarkers.end(),
        infoWindow: const InfoWindow(
          title: '终点',
          snippet: '恭喜你完成徒步！',
        ),
        anchor: const Offset(0.5, 1.0),
      ),
      
      // 停车场标记
      Marker(
        markerId: const MarkerId('parking'),
        position: _parkingPosition,
        icon: await CustomMarkers.parking(),
        infoWindow: const InfoWindow(
          title: '🅿️ 白堤停车场',
          snippet: '24小时营业',
        ),
        anchor: const Offset(0.5, 0.5), // 停车场锚点居中
      ),
    };

    setState(() {
      _markers = markers;
      _isLoading = false;
    });
  }

  /// 切换标记选中状态
  Future<void> _toggleMarkerSelection(String markerId) async {
    final updatedMarkers = _markers.map((marker) {
      if (marker.markerId.value == markerId) {
        // 切换选中状态
        final isSelected = marker.icon == BitmapDescriptor.defaultMarker;
        
        // 根据类型重新加载图标
        BitmapDescriptor newIcon;
        if (markerId == 'start') {
          newIcon = await CustomMarkers.start(selected: !isSelected);
        } else if (markerId == 'end') {
          newIcon = await CustomMarkers.end(selected: !isSelected);
        } else {
          newIcon = await CustomMarkers.parking(selected: !isSelected);
        }
        
        return Marker(
          markerId: marker.markerId,
          position: marker.position,
          icon: newIcon,
          infoWindow: marker.infoWindow,
          anchor: marker.anchor,
        );
      }
      return marker;
    }).toSet();

    setState(() {
      _markers = updatedMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义标记示例'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              CustomMarkers.clearCache();
              _initMarkers();
            },
            tooltip: '重新加载图标',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 地图
          AMapWidget(
            initialCameraPosition: CameraPosition(
              target: _startPosition,
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            onMarkerTapped: (marker) {
              debugPrint('点击标记: ${marker.markerId.value}');
              _toggleMarkerSelection(marker.markerId.value);
            },
          ),
          
          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // 说明面板
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '使用说明',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      color: CustomMarkers.startColor,
                      label: '起点标记（绿色水滴形）',
                    ),
                    _buildLegendItem(
                      color: CustomMarkers.endColor,
                      label: '终点标记（橙红色水滴形）',
                    ),
                    _buildLegendItem(
                      color: CustomMarkers.parkingColor,
                      label: '停车场标记（蓝色圆形P字）',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '点击标记切换选中状态',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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

  Widget _buildLegendItem({required Color color, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// 快速集成指南代码片段
/*

### 1. 基础使用

```dart
Marker(
  markerId: MarkerId('parking_1'),
  position: LatLng(30.259, 120.148),
  icon: await CustomMarkers.parking(),
  infoWindow: InfoWindow(title: '停车场'),
  anchor: Offset(0.5, 0.5), // 居中锚点
)
```

### 2. 批量创建标记

```dart
Future<Set<Marker>> buildParkingMarkers(
  List<LatLng> parkingLocations,
) async {
  final markers = <Marker>{};
  
  for (int i = 0; i < parkingLocations.length; i++) {
    markers.add(
      Marker(
        markerId: MarkerId('parking_$i'),
        position: parkingLocations[i],
        icon: await CustomMarkers.parking(),
        infoWindow: InfoWindow(title: '停车场 #$i'),
      ),
    );
  }
  
  return markers;
}
```

### 3. 带选中状态的标记

```dart
class _MyMapState extends State<MyMap> {
  String? _selectedMarkerId;
  
  Future<BitmapDescriptor> _getMarkerIcon(
    String markerId,
    MarkerType type,
  ) async {
    final isSelected = _selectedMarkerId == markerId;
    
    switch (type) {
      case MarkerType.start:
        return await CustomMarkers.start(selected: isSelected);
      case MarkerType.end:
        return await CustomMarkers.end(selected: isSelected);
      case MarkerType.parking:
        return await CustomMarkers.parking(selected: isSelected);
    }
  }
}
```

### 4. 应用启动时预加载

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 预加载标记图标
  await CustomMarkers.preload();
  
  runApp(MyApp());
}
```

*/
