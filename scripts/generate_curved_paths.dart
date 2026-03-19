import 'dart:math';

/// 生成平滑曲线路径点
/// 使用二次贝塞尔曲线在起点和终点之间生成中间点
List<Map<String, double>> generateCurvedPath(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
  int numPoints, {
  double curvature = 0.0003, // 曲率大小
  bool curveRight = true, // 弯曲方向
}) {
  final points = <Map<String, double>>[];
  
  // 计算中点
  final midLat = (startLat + endLat) / 2;
  final midLng = (startLng + endLng) / 2;
  
  // 计算垂直方向（用于弯曲）
  final dLat = endLat - startLat;
  final dLng = endLng - startLng;
  final length = sqrt(dLat * dLat + dLng * dLng);
  
  // 垂直单位向量
  final perpLat = -dLng / length;
  final perpLng = dLat / length;
  
  // 控制点偏移
  final offset = curveRight ? curvature : -curvature;
  final controlLat = midLat + perpLat * offset;
  final controlLng = midLng + perpLng * offset;
  
  // 生成贝塞尔曲线点
  for (int i = 0; i <= numPoints; i++) {
    final t = i / numPoints;
    
    // 二次贝塞尔曲线公式
    final lat = pow(1 - t, 2) * startLat +
                2 * (1 - t) * t * controlLat +
                pow(t, 2) * endLat;
    final lng = pow(1 - t, 2) * startLng +
                2 * (1 - t) * t * controlLng +
                pow(t, 2) * endLng;
    
    points.add({'lat': lat, 'lng': lng});
  }
  
  return points;
}

/// 生成S形曲线路径
List<Map<String, double>> generateSPath(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
  int numPoints, {
  double curvature = 0.0004,
}) {
  final points = <Map<String, double>>[];
  
  final midLat = (startLat + endLat) / 2;
  final midLng = (startLng + endLng) / 2;
  
  // 第一段：起点到中点，向右弯
  final firstHalf = generateCurvedPath(
    startLat, startLng, midLat, midLng,
    numPoints ~/ 2,
    curvature: curvature,
    curveRight: true,
  );
  
  // 第二段：中点到终点，向左弯
  final secondHalf = generateCurvedPath(
    midLat, midLng, endLat, endLng,
    numPoints ~/ 2,
    curvature: curvature,
    curveRight: false,
  );
  
  // 合并（去掉中间重复的点）
  points.addAll(firstHalf);
  points.addAll(secondHalf.sublist(1));
  
  return points;
}

void main() {
  // 断桥残雪 - 白堤路线（轻微弯曲）
  final duanqiao = generateCurvedPath(
    30.2575, 120.1465, // 起点
    30.2606, 120.1494, // 终点
    50, // 50个点
    curvature: 0.0002,
    curveRight: false,
  );
  print('// 断桥残雪路线');
  for (final p in duanqiao) {
    print("        LatLng(${p['lat']!.toStringAsFixed(6)}, ${p['lng']!.toStringAsFixed(6)}),");
  }
  
  print('\n// 苏堤春晓路线 - S形');
  final sudi = generateSPath(
    30.2280, 120.1365,
    30.2410, 120.1336,
    60,
    curvature: 0.0005,
  );
  for (final p in sudi) {
    print("        LatLng(${p['lat']!.toStringAsFixed(6)}, ${p['lng']!.toStringAsFixed(6)}),");
  }
  
  print('\n// 灵隐寺路线 - 双弯曲');
  final lingyin1 = generateCurvedPath(
    30.2380, 120.0980,
    30.2410, 120.1000,
    30,
    curvature: 0.0004,
    curveRight: true,
  );
  final lingyin2 = generateCurvedPath(
    30.2410, 120.1000,
    30.2446, 120.1026,
    30,
    curvature: 0.0003,
    curveRight: false,
  );
  final lingyin = [...lingyin1, ...lingyin2.sublist(1)];
  for (final p in lingyin) {
    print("        LatLng(${p['lat']!.toStringAsFixed(6)}, ${p['lng']!.toStringAsFixed(6)}),");
  }
  
  print('\n// 法喜寺路线 - 蜿蜒');
  final faxi = generateSPath(
    30.2320, 120.0860,
    30.2371, 120.0894,
    45,
    curvature: 0.0006,
  );
  for (final p in faxi) {
    print("        LatLng(${p['lat']!.toStringAsFixed(6)}, ${p['lng']!.toStringAsFixed(6)}),");
  }
}
