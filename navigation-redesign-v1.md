# 山径APP - 导航功能重构设计文档 (v1.0)

## 概述
基于用户决策（方案A），立即集成高德导航SDK (`amap_flutter_navi`)，实现真正的两阶段导航，替换当前的自定义"伪导航"逻辑。

## 问题诊断

### 当前问题
1. **过程和阶段不清晰**
   - 定义了 `NavigationMode.preview` 和 `NavigationMode.navigating`，但逻辑混杂
   - 没有明确的"当前位置→路线起点"和"路线起点→路线终点"阶段划分

2. **未调用高德导航服务**
   - 所有"导航"都是自定义逻辑：
     - 路径规划：`_calculatePreviewPath()` 只是画条直线
     - 偏航检测：自定义阈值判断 (`_offRouteThreshold = 50.0`)
     - 语音播报：自己算距离然后 `FlutterTts.speak()`
   - 没有使用高德专业的导航SDK

### 后果
- 导航不可靠，容易偏航
- 语音播报不专业
- 无法处理复杂路况
- 用户体验差

## 解决方案：真正的两阶段导航

### 1. 新的状态机设计
```dart
/// 明确的导航阶段
enum NavigationPhase {
  /// 阶段1：规划到起点的路径
  planningToStart,
  
  /// 阶段1：前往起点（高德路径规划）
  navigatingToStart,
  
  /// 阶段1.5：到达起点，预览路线
  previewRoute,
  
  /// 阶段2：沿路线导航（高德导航服务）
  navigatingRoute,
  
  /// 到达终点
  completed,
  
  /// 偏航（由高德SDK触发）
  offRoute,
}
```

### 2. 阶段1：当前位置 → 路线起点
**技术栈**: 高德 `AMapNavi.calculateWalkRoute`
**功能**:
- 调用高德步行路径规划API
- 显示规划路径、预计时间、距离
- 语音引导："前方100米左转，前往路线起点"
- 到达起点后自动进入阶段2

### 3. 阶段2：路线起点 → 路线终点
**技术栈**: 高德 `AMapNavi.startNavi`
**功能**:
- 专业步行导航服务
- 实时偏航检测 + 自动重新规划
- 高德专业语音播报
- 路口放大图、车道指引

## 技术实现

### 1. 依赖添加
```yaml
# pubspec.yaml
dependencies:
  amap_flutter_navi: ^3.0.0  # 已添加
```

### 2. Android 配置
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        ndk {
            // 设置支持的SO库架构
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
        }
    }
}

dependencies {
    implementation 'com.amap.api:navi-3dmap:latest.integration'
    implementation 'com.amap.api:search:latest.integration'
}
```

### 3. iOS 配置
```ruby
# Podfile
pod 'AMapNavi', '~> 9.0'
pod 'AMapSearch', '~> 9.0'
```

### 4. 代码重构要点

#### 4.1 状态管理
```dart
class _NavigationScreenState extends State<NavigationScreen> {
  // 新的状态管理
  NavigationPhase _phase = NavigationPhase.planningToStart;
  
  // 高德导航控制器
  late AMapNaviController _naviController;
  
  // 阶段1数据
  List<LatLng> _planToStartPath = [];
  double _planToStartDistance = 0;
  int _planToStartTime = 0;
  
  // 阶段2数据
  bool _isNaviStarted = false;
  
  @override
  void initState() {
    super.initState();
    _initNaviController();
    _startPhase1();
  }
  
  void _initNaviController() {
    _naviController = AMapNaviController();
    _naviController.onNaviInfoUpdate = _onNaviInfoUpdate;
    _naviController.onCalculateRouteSuccess = _onCalculateRouteSuccess;
    _naviController.onOffRouteDetected = _onOffRouteDetected;
    _naviController.onArrivedDestination = _onArrivedDestination;
  }
}
```

#### 4.2 阶段1：规划到起点
```dart
void _startPhase1() async {
  // 1. 获取当前位置
  final currentPos = await _getCurrentPosition();
  final startPos = widget.routeStartPoint ?? _routePoints.first;
  
  // 2. 调用高德路径规划
  final result = await _naviController.calculateWalkRoute(
    start: LatLng(currentPos.latitude, currentPos.longitude),
    end: startPos,
  );
  
  if (result.success) {
    setState(() {
      _phase = NavigationPhase.navigatingToStart;
      _planToStartPath = result.path;
      _planToStartDistance = result.distance;
      _planToStartTime = result.time;
    });
    
    // 3. 开始导航到起点
    _naviController.startWalkNavi();
  }
}
```

#### 4.3 阶段2：路线导航
```dart
void _startPhase2() async {
  // 1. 设置路线点
  await _naviController.setRoutePoints(_routePoints);
  
  // 2. 开始路线导航
  final result = await _naviController.startWalkNavi(
    routeIndex: 0,
    strategy: WalkStrategy.MULTI_PATH,
  );
  
  if (result) {
    setState(() {
      _phase = NavigationPhase.navigatingRoute;
      _isNaviStarted = true;
    });
  }
}
```

#### 4.4 偏航处理（由高德SDK处理）
```dart
void _onOffRouteDetected() {
  // 高德SDK自动检测偏航
  setState(() => _phase = NavigationPhase.offRoute);
  
  // 高德会自动重新规划路线
  // 我们只需要更新UI状态
  _speak('您已偏航，正在重新规划路线');
}
```

#### 4.5 语音播报（使用高德SDK）
```dart
void _onNaviInfoUpdate(AMapNaviInfo naviInfo) {
  // 高德SDK提供专业的语音播报
  // 我们只需要处理UI更新
  
  setState(() {
    _remainingDistance = naviInfo.remainingDistance;
    _estimatedArrivalMinutes = naviInfo.remainingTime ~/ 60;
  });
}
```

## 迁移策略

### 1. 保留现有功能
- 保持现有的UI布局和样式
- 保持SOS按钮、拍照、POI标记等辅助功能
- 保持埋点统计

### 2. 逐步替换
1. **先添加依赖和配置**（今天）
2. **实现阶段1路径规划**（今天）
3. **实现阶段2导航**（明天）
4. **替换偏航检测和语音**（明天）
5. **全面测试**（后天）

### 3. 向后兼容
- 如果高德SDK初始化失败，回退到当前逻辑
- 添加错误处理和降级方案

## 测试计划

### 单元测试
- [ ] 导航状态机转换
- [ ] 高德SDK初始化
- [ ] 路径规划API调用
- [ ] 偏航检测回调

### 集成测试
- [ ] 阶段1完整流程（当前位置→起点）
- [ ] 阶段2完整流程（起点→终点）
- [ ] 偏航后重新规划
- [ ] 语音播报集成

### 真机测试
- [ ] 不同GPS精度环境
- [ ] 网络异常情况
- [ ] 电量消耗测试

## 风险与应对

| 风险 | 概率 | 影响 | 应对措施 |
|------|------|------|----------|
| 高德SDK集成问题 | 中 | 高 | 分步验证，官方示例参考 |
| Android/iOS配置差异 | 高 | 中 | 分别配置，逐步测试 |
| 性能问题 | 低 | 低 | 监控内存和电量使用 |
| 下周三采集时间 | 低 | 高 | 确保基础功能可用，优化可后续 |

## 时间线

### 今天 (2026-03-21)
- [ ] 添加 `amap_flutter_navi` 依赖
- [ ] Android/iOS 原生配置
- [ ] 设计新的 `NavigationPhase` 状态机
- [ ] 实现阶段1路径规划基础

### 明天 (2026-03-22)
- [ ] 完善阶段1导航到起点
- [ ] 实现阶段2路线导航
- [ ] 替换偏航检测为高德SDK回调
- [ ] 替换语音播报为高德导航语音

### 后天 (2026-03-23)
- [ ] 全面测试
- [ ] 修复问题
- [ ] 文档更新
- [ ] 性能优化

## 成功标准

1. **功能完整性**
   - 两阶段导航清晰划分
   - 高德专业路径规划
   - 自动偏航检测和重新规划
   - 专业语音播报

2. **性能指标**
   - 路径规划响应时间 < 3秒
   - 导航启动时间 < 2秒
   - 电量消耗增加 < 15%
   - 内存占用增加 < 20MB

3. **用户体验**
   - 导航准确率 > 95%
   - 语音播报清晰度 > 90%
   - 偏航后重新规划时间 < 10秒

## 附录

### 高德导航SDK文档
- [Android集成文档](https://lbs.amap.com/api/android-sdk/guide/create-project/navigation)
- [iOS集成文档](https://lbs.amap.com/api/ios-sdk/guide/create-project/navigation)
- [Flutter插件文档](https://pub.dev/packages/amap_flutter_navi)

### 相关文件
- `lib/screens/navigation_screen.dart` - 主导航页面
- `pubspec.yaml` - 依赖配置
- `android/app/build.gradle` - Android配置
- `ios/Podfile` - iOS配置