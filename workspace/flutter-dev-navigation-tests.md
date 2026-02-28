# Flutter 导航模块单元测试文档

## 概述

本文档描述 Flutter 导航模块的单元测试实现，覆盖轨迹匹配算法、GPS 精度过滤和偏航检测三大核心功能。

---

## 测试文件结构

```
test/
└── navigation/
    └── matching_test.dart    # 导航模块单元测试
```

---

## 测试覆盖范围

### 1. 轨迹匹配算法单元测试（5个用例）

| 用例ID | 测试名称 | 描述 | 预期结果 |
|--------|----------|------|----------|
| UT-001 | 精确匹配 | 坐标精确在路线上 | 匹配成功，偏差≈0，状态"正常" |
| UT-002 | 轻微偏离 | 坐标偏离路线<10m | 匹配最近点，记录偏差，状态"正常" |
| UT-003 | 严重偏离 | 坐标偏离路线>50m | 状态"偏离路线"，触发偏航标记 |
| UT-004 | 信号丢失 | 连续多点无信号 | 批量匹配，使用插值估算位置 |
| UT-005 | 路线切换 | 接近岔路口 | 正确识别目标分支，进度更新 |

**核心测试代码：**
```dart
test('精确匹配 - 坐标在路线上', () {
  final gpsPoint = const LatLng(30.2020, 120.1000);
  final result = TrackMatcher.match(gpsPoint, testRoute);

  expect(result.status, equals("正常"));
  expect(result.isDeviated, isFalse);
  expect(result.distanceToRoute, lessThan(1.0));
});
```

---

### 2. GPS 精度过滤单元测试

| 测试场景 | 输入 | 预期结果 |
|----------|------|----------|
| 精度优秀 | accuracy ≤ 5m | isValid=true, status='excellent' |
| 精度良好 | 5m < accuracy ≤ 10m | isValid=true, status='good' |
| 精度一般 | 10m < accuracy ≤ 20m | isValid=false, status='fair' |
| 精度差 | accuracy > 20m | isValid=false, status='poor' |
| 精度过滤集成 | accuracy > 10m | TrackMatcher返回"精度不足" |
| 速度异常 | speed > 50m/s | isValid=false, 标记速度异常 |
| 数据过时 | timestamp > 5s前 | isValid=false, 标记数据过时 |

**精度阈值：**
```dart
static const double MIN_ACCURACY = 10.0;  // 最小可接受精度
static const double MAX_SPEED = 50.0;      // 最大合理速度 50m/s (180km/h)
```

---

### 3. 偏航检测单元测试

| 测试场景 | 输入 | 预期结果 |
|----------|------|----------|
| 在路线上 | 距离路线 < 30m | isDeviating=false |
| 轻微偏离 | 距离路线 < 30m | isDeviating=false |
| 严重偏航 | 距离路线 > 30m | isDeviating=true |
| 边界测试 | 距离 ≈ 30m | 根据精度可能为true/false |
| 空路线 | routePoints=[] | isDeviating=false |
| 回到正轨 | 从偏航回到路线 | isDeviating=false |
| 批量检测 | 多个位置点 | 正确识别每个点的偏航状态 |

**偏航阈值：**
```dart
static const double deviationThreshold = 30.0;  // 30米阈值
```

---

## 核心类说明

### TrackMatcher - 轨迹匹配器

```dart
class TrackMatcher {
  // 偏离阈值（米）
  static const double deviationThreshold = 30.0;
  
  // GPS 精度阈值（米）
  static const double accuracyThreshold = 10.0;

  // 匹配 GPS 点到路线
  static TrackMatchingResult match(
    LatLng gpsPoint,
    RoutePath route, {
    double threshold = deviationThreshold,
    double? accuracy,  // GPS 精度（可选）
  });

  // 快速检查是否偏离
  static bool isDeviated(...);

  // 批量匹配
  static List<TrackMatchingResult> matchBatch(...);
}
```

### GPSAccuracyFilter - GPS 精度过滤器

```dart
class GPSAccuracyFilter {
  static bool isAccuracyAcceptable(double accuracy);
  static String getAccuracyStatus(double accuracy);
  static GPSQuality checkQuality({
    required double accuracy,
    double? speed,
    DateTime? timestamp,
  });
}
```

### DeviationDetector - 偏航检测器

```dart
class DeviationDetector {
  static bool isDeviating(
    LatLng currentPosition, 
    List<LatLng> routePoints
  );
  
  static double getDeviationDistance(
    LatLng currentPosition, 
    List<LatLng> routePoints
  );
}
```

---

## 运行测试

### 运行所有测试
```bash
flutter test test/navigation/matching_test.dart
```

### 运行特定测试组
```bash
# 仅运行轨迹匹配测试
flutter test test/navigation/matching_test.dart --name "轨迹匹配算法单元测试"

# 仅运行 GPS 精度过滤测试
flutter test test/navigation/matching_test.dart --name "GPS 精度过滤单元测试"

# 仅运行偏航检测测试
flutter test test/navigation/matching_test.dart --name "偏航检测单元测试"
```

### 详细输出
```bash
flutter test test/navigation/matching_test.dart -v
```

---

## 测试数据

测试使用杭州九溪附近的模拟坐标：

```dart
// 测试路线
final testRoute = RoutePath.fromCoordinates([
  const LatLng(30.2000, 120.1000),
  const LatLng(30.2010, 120.1000),
  const LatLng(30.2020, 120.1000),
  const LatLng(30.2030, 120.1000),
  const LatLng(30.2040, 120.1000),
]);
```

---

## 集成测试场景

### 场景1：正常导航流程
1. GPS 更新位置
2. 精度检查通过
3. 轨迹匹配成功
4. 进度更新

### 场景2：偏航后重新规划
1. 正常行进
2. 检测到偏航（距离>30m）
3. 触发偏航警告
4. 重新规划路线

### 场景3：GPS 精度不足
1. 高精度数据 → 正常导航
2. 低精度数据（>10m）→ 暂停导航
3. 提示用户等待更好的 GPS 信号

---

## 关键指标验证

| 指标 | 要求 | 测试验证 |
|------|------|----------|
| 匹配精度 | ±5m | 精确匹配测试用例 |
| 响应时间 | <100ms | 算法复杂度 O(n) |
| 偏航检测 | >30m 触发 | 偏航检测单元测试 |
| 精度过滤 | >10m 拒绝 | GPS 精度过滤测试 |

---

## 注意事项

1. **坐标系**：测试使用 WGS84 坐标系（GPS 标准）
2. **距离计算**：使用 Haversine 公式计算地球表面距离
3. **精度参数**：TrackMatcher.match() 的 accuracy 参数为可选，向后兼容
4. **边界情况**：空路线、单点路线均已处理

---

## 后续优化

1. 添加性能测试（响应时间 <100ms）
2. 添加并发测试（批量匹配）
3. 添加边界条件测试（极坐标附近）
4. 集成到 CI/CD 流程

---

*文档版本: 1.0 | 日期: 2026-02-28*
