# GPS 定位修复验证报告

## 修复时间
2026-03-03 13:35

## 问题描述
高德定位 API 未完全配置，代码中被注释，导致定位功能无法正常工作。

## 修复内容

### 1. lib/screens/map_screen.dart

#### 变更摘要
- 导入 `amap_flutter_location` SDK
- 添加定位相关状态变量
- 实现定位初始化和更新处理
- 启用地图当前位置显示

#### 关键代码变更

**导入 SDK:**
```dart
import 'package:amap_flutter_location/amap_flutter_location.dart';
```

**状态变量:**
```dart
// 高德定位
late AMapFlutterLocation _locationPlugin;
StreamSubscription<Map<String, Object>>? _locationSubscription;
LatLng? _currentLocation; // 当前真实GPS位置
```

**定位初始化:**
```dart
void _initLocation() {
  _locationPlugin = AMapFlutterLocation();
  
  _locationPlugin.setLocationOption(
    AMapLocationOption(
      locationMode: AMapLocationMode.Hight_Accuracy,
      needAddress: true,
      locationInterval: 5000,
      onceLocation: false,
      geoLanguage: GeoLanguage.DEFAULT,
    ),
  );

  _locationSubscription = _locationPlugin.onLocationChanged().listen(
    _onLocationUpdate,
    onError: (error) {
      debugPrint('定位错误: $error');
    },
  );

  _locationPlugin.startLocation();
}
```

**定位更新处理:**
```dart
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
```

**资源释放:**
```dart
@override
void dispose() {
  _scrollController.dispose();
  _locationSubscription?.cancel();
  _locationPlugin.stopLocation();
  _locationPlugin.destroy();
  super.dispose();
}
```

**地图定位显示:**
```dart
AMapWidget(
  // ...
  myLocationEnabled: _hasPermission,
  myLocationStyle: MyLocationStyle(
    showMyLocation: true,
    circleFillColor: Colors.blue.withOpacity(0.2),
    circleStrokeColor: Colors.blue,
    circleStrokeWidth: 1,
  ),
  // ...
)
```

---

### 2. lib/screens/navigation_screen.dart

#### 变更摘要
- 取消高德定位 API 注释
- 实现权限申请流程
- 启用地图当前位置显示
- 添加定位资源释放

#### 关键代码变更

**启用定位变量:**
```dart
// 高德地图定位
late AMapFlutterLocation _locationPlugin;
StreamSubscription<Map<String, Object>>? _locationSubscription;
```

**权限申请:**
```dart
Future<void> _requestLocationPermission() async {
  final status = await Permission.location.request();
  if (status.isGranted) {
    _initLocation();
  } else {
    // 权限被拒绝，使用默认位置
    setState(() {
      _currentPosition = GPSPoint(
        latitude: 30.25,
        longitude: 120.15,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );
      _currentLatLng = const LatLng(30.25, 120.15);
    });
  }
}
```

**定位初始化:**
```dart
void _initLocation() {
  _locationPlugin = AMapFlutterLocation();
  
  _locationPlugin.setLocationOption(
    AMapLocationOption(
      locationMode: AMapLocationMode.Hight_Accuracy,
      needAddress: true,
      locationInterval: 2000,
      onceLocation: false,
      geoLanguage: GeoLanguage.DEFAULT,
    ),
  );

  _locationSubscription = _locationPlugin.onLocationChanged().listen(
    _onLocationUpdate,
    onError: (error) {
      debugPrint('定位错误: $error');
    },
  );

  _locationPlugin.startLocation();
}
```

**地图定位显示:**
```dart
AMapWidget(
  // ...
  myLocationEnabled: true,
  myLocationStyle: MyLocationStyle(
    showMyLocation: true,
    circleFillColor: Colors.blue.withOpacity(0.2),
    circleStrokeColor: Colors.blue,
    circleStrokeWidth: 1,
  ),
  onMapCreated: (controller) {
    _mapController = controller;
  },
  // ...
)
```

**资源释放:**
```dart
@override
void dispose() {
  _flutterTts.stop();
  _locationSubscription?.cancel();
  _locationPlugin.stopLocation();
  _locationPlugin.destroy();
  super.dispose();
}
```

---

### 3. android/app/src/main/AndroidManifest.xml

#### 变更摘要
- 创建完整的 AndroidManifest.xml
- 添加高德地图 API Key 配置
- 添加定位服务声明
- 添加所有必要权限

#### 完整配置
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="山径"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- 高德地图 API Key -->
        <meta-data
            android:name="com.amap.api.v2.apikey"
            android:value="${AMAP_API_KEY}" />
        
        <!-- 定位服务 -->
        <service android:name="com.amap.api.location.APSService" />
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    
    <!-- 网络权限 -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- 定位权限 -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    
    <!-- 存储权限（离线地图需要） -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <!-- 其他权限 -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- 硬件特性声明 -->
    <uses-feature android:name="android.hardware.location" android:required="true" />
    <uses-feature android:name="android.hardware.location.gps" android:required="false" />
</manifest>
```

---

## 验证检查清单

### 代码审查
| 检查项 | 状态 | 说明 |
|--------|------|------|
| 高德定位 SDK 导入 | ✅ | `amap_flutter_location` 已导入 |
| 定位变量声明 | ✅ | `_locationPlugin` 和 `_locationSubscription` 已声明 |
| 定位初始化 | ✅ | `_initLocation()` 已实现 |
| 定位更新处理 | ✅ | `_onLocationUpdate()` 已实现 |
| 权限申请 | ✅ | `Permission.location.request()` 已调用 |
| 资源释放 | ✅ | `dispose()` 中正确释放 |
| 地图定位显示 | ✅ | `myLocationEnabled` 和 `myLocationStyle` 已配置 |

### AndroidManifest 检查
| 检查项 | 状态 | 说明 |
|--------|------|------|
| API Key 配置 | ✅ | `com.amap.api.v2.apikey` 已配置 |
| 定位服务 | ✅ | `APSService` 已声明 |
| FINE_LOCATION 权限 | ✅ | 已添加 |
| COARSE_LOCATION 权限 | ✅ | 已添加 |
| BACKGROUND_LOCATION 权限 | ✅ | 已添加 |
| 存储权限 | ✅ | 已添加 |
| 硬件特性声明 | ✅ | 已添加 |

### 功能验证（需真机测试）
| 检查项 | 状态 | 说明 |
|--------|------|------|
| 定位权限弹窗 | ⏳ | 需真机验证 |
| GPS 位置获取 | ⏳ | 需真机验证 |
| 地图当前位置显示 | ⏳ | 需真机验证 |
| 导航定位更新 | ⏳ | 需真机验证 |
| 偏航检测 | ⏳ | 需真机验证 |
| GPS精度过滤 | ⏳ | 需真机验证 |

---

## 待测试场景

1. **首次启动权限申请**
   - 允许定位：应正常获取GPS位置
   - 拒绝定位：应使用默认位置

2. **GPS信号强度**
   - 强信号：精度 < 10m，正常导航
   - 弱信号：显示"信号弱"状态

3. **偏航检测**
   - 偏离路线 > 50m：触发偏航提醒
   - 返回路线：显示"已回到正确路线"

4. **后台定位**
   - 应用后台运行：继续获取定位（需后台权限）

---

## 修复影响

### 修复前
- 地图使用固定坐标 (30.25, 120.15)
- 导航使用模拟定位数据
- GPS定位功能完全不可用

### 修复后
- 地图显示真实GPS位置
- 导航使用真实定位数据
- 支持偏航检测和语音播报
- 支持GPS精度过滤

---

## 后续建议

1. **真机测试**：尽快在真实设备上验证定位功能
2. **后台保活**：考虑集成后台定位保活机制
3. **电量优化**：评估定位频率对电量的影响
4. **错误处理**：完善定位失败的降级策略

---

**报告生成时间**: 2026-03-03 13:35  
**修复状态**: ✅ 代码修复完成，待真机验证
