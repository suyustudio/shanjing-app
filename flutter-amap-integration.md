# Flutter 高德地图插件 (amap_flutter_map) 集成指南

## 依赖配置

### pubspec.yaml

```yaml
dependencies:
  amap_flutter_map: ^3.0.0
  amap_flutter_location: ^3.0.0
  permission_handler: ^10.2.0
```

---

## Android 配置

### 1. android/app/build.gradle.kts

```kotlin
dependencies {
    implementation("com.amap.api:3dmap-location-search:latest.integration")
}

defaultConfig {
    ndk {
        abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
    }
}
```

### 2. AndroidManifest.xml

```xml
<!-- 权限 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />

<!-- API Key -->
<application>
    <meta-data 
        android:name="com.amap.api.v2.apikey" 
        android:value="YOUR_ANDROID_API_KEY" />
</application>
```

### 3. MainActivity.kt - 隐私合规

```kotlin
import com.amap.api.maps.MapsInitializer

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // 必须在 super.onCreate 之前调用
        MapsInitializer.updatePrivacyShow(this, true, true)
        MapsInitializer.updatePrivacyAgree(this, true)
        super.onCreate(savedInstanceState)
    }
}
```

---

## iOS 配置

### 1. Info.plist

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>用于获取您的当前位置信息</string>
```

### 2. Podfile

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_LOCATION=1',
      ]
    end
  end
end
```

---

## 基础使用示例

```dart
import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Map<String, Marker> _markers = {};
  
  @override
  void initState() {
    super.initState();
    // 设置 API Key
    AMapFlutterLocation.setApiKey("ANDROID_KEY", "IOS_KEY");
    // 隐私合规
    AMapFlutterLocation.updatePrivacyShow(true, true);
    AMapFlutterLocation.updatePrivacyAgree(true);
    // 申请权限
    requestPermission();
  }

  Future<void> requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // 权限已授予
    }
  }

  void addMarker(LatLng position) {
    final marker = Marker(
      position: position,
      icon: BitmapDescriptor.defaultMarker,
    );
    setState(() {
      _markers[marker.id] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AMapWidget(
        privacyStatement: const AMapPrivacyStatement(
          hasAgree: true, 
          hasContains: true, 
          hasShow: true,
        ),
        initialCameraPosition: CameraPosition(
          target: LatLng(39.9042, 116.4074), // 北京
          zoom: 15,
        ),
        myLocationStyleOptions: MyLocationStyleOptions(true),
        markers: Set<Marker>.of(_markers.values),
        onMapCreated: (controller) {
          // 地图创建完成回调
        },
        onTap: (latLng) {
          addMarker(latLng);
        },
      ),
    );
  }
}
```

---

## 关键 API

| 组件 | 说明 |
|------|------|
| `AMapWidget` | 地图组件 |
| `CameraPosition` | 相机位置 (target + zoom) |
| `Marker` | 标记点 |
| `Polyline` | 折线 |
| `MyLocationStyleOptions` | 定位样式 |
| `AMapPrivacyStatement` | 隐私声明 |

---

## 注意事项

1. **导航功能**：高德 Flutter SDK 不支持导航，需用百度 SDK
2. **隐私合规**：必须在 `super.onCreate()` 前调用隐私接口
3. **API Key**：需在高德开放平台申请
4. **权限**：Android 6.0+ 需动态申请定位权限
