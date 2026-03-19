import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 地图内存优化配置
class MapMemoryConfig {
  /// 瓦片缓存最大数量
  static const int maxTileCacheSize = 128;
  
  /// 瓦片缓存最大内存（MB）
  static const int maxTileCacheMemoryMB = 50;
  
  /// 最大缩放级别
  static const double maxZoomLevel = 18.0;
  
  /// 最小缩放级别
  static const double minZoomLevel = 5.0;
  
  /// 地图区域外缓存层数
  static const int overPanDistance = 1;
  
  /// 是否启用内存回收
  static const bool enableMemoryTrim = true;
  
  /// 内存压力阈值（MB）
  static const int memoryPressureThresholdMB = 100;
  
  /// 后台时是否释放地图资源
  static const bool releaseOnBackground = true;
  
  /// 地图标记最大数量
  static const int maxMarkerCount = 500;
  
  /// 聚合标记的最小缩放级别
  static const double clusterZoomThreshold = 12.0;
}

/// 地图内存管理器
/// 
/// 功能：
/// - 瓦片缓存控制
/// - 内存压力监控
/// - 自动资源回收
/// - 标记聚合优化
class MapMemoryManager {
  static final MapMemoryManager _instance = MapMemoryManager._internal();
  factory MapMemoryManager() => _instance;
  MapMemoryManager._internal();

  // 瓦片缓存队列（LRU）
  final Map<String, _TileCacheEntry> _tileCache = {};
  final List<String> _lruQueue = [];
  
  // 标记缓存
  final Map<String, dynamic> _markerCache = {};
  
  // 内存使用监控
  int _currentMemoryUsageMB = 0;
  DateTime _lastTrimTime = DateTime.now();
  
  /// 获取当前内存使用（MB）
  int get currentMemoryUsageMB => _currentMemoryUsageMB;
  
  /// 添加瓦片到缓存
  void cacheTile(String tileKey, Uint8List tileData) {
    final sizeMB = tileData.lengthInBytes ~/ (1024 * 1024);
    
    // 检查是否需要清理
    if (_currentMemoryUsageMB + sizeMB > MapMemoryConfig.maxTileCacheMemoryMB) {
      _trimCache();
    }
    
    // 更新LRU队列
    _lruQueue.remove(tileKey);
    _lruQueue.add(tileKey);
    
    _tileCache[tileKey] = _TileCacheEntry(
      data: tileData,
      sizeMB: sizeMB,
      timestamp: DateTime.now(),
    );
    
    _currentMemoryUsageMB += sizeMB;
  }
  
  /// 获取缓存的瓦片
  Uint8List? getCachedTile(String tileKey) {
    final entry = _tileCache[tileKey];
    if (entry != null) {
      // 更新LRU
      _lruQueue.remove(tileKey);
      _lruQueue.add(tileKey);
      return entry.data;
    }
    return null;
  }
  
  /// 清理过期缓存
  void _trimCache() {
    final now = DateTime.now();
    if (now.difference(_lastTrimTime).inSeconds < 5) {
      return; // 5秒内不重复清理
    }
    _lastTrimTime = now;
    
    // 按LRU清理
    while (_currentMemoryUsageMB > MapMemoryConfig.maxTileCacheMemoryMB * 0.8 &&
           _lruQueue.isNotEmpty) {
      final oldestKey = _lruQueue.removeAt(0);
      final entry = _tileCache.remove(oldestKey);
      if (entry != null) {
        _currentMemoryUsageMB -= entry.sizeMB;
      }
    }
    
    // 清理过期数据（超过5分钟未使用）
    final expiredKeys = _tileCache.entries
        .where((e) => now.difference(e.value.timestamp).inMinutes > 5)
        .map((e) => e.key)
        .toList();
    
    for (final key in expiredKeys) {
      final entry = _tileCache.remove(key);
      if (entry != null) {
        _lruQueue.remove(key);
        _currentMemoryUsageMB -= entry.sizeMB;
      }
    }
  }
  
  /// 应用进入后台时释放资源
  void onAppBackground() {
    if (MapMemoryConfig.releaseOnBackground) {
      _trimCache();
      // 释放更多资源
      _markerCache.clear();
    }
  }
  
  /// 应用返回前台
  void onAppForeground() {
    // 恢复必要的资源
  }
  
  /// 内存压力处理
  void onMemoryPressure() {
    // 紧急清理
    _tileCache.clear();
    _lruQueue.clear();
    _markerCache.clear();
    _currentMemoryUsageMB = 0;
  }
  
  /// 获取适合当前状态的标记显示数量
  int getOptimalMarkerCount(double zoomLevel) {
    if (zoomLevel < MapMemoryConfig.clusterZoomThreshold) {
      // 缩放级别低时使用聚合，减少标记数量
      return 50;
    }
    return MapMemoryConfig.maxMarkerCount;
  }
  
  /// 释放所有缓存
  void clearAllCache() {
    _tileCache.clear();
    _lruQueue.clear();
    _markerCache.clear();
    _currentMemoryUsageMB = 0;
  }
}

/// 瓦片缓存条目
class _TileCacheEntry {
  final Uint8List data;
  final int sizeMB;
  final DateTime timestamp;

  _TileCacheEntry({
    required this.data,
    required this.sizeMB,
    required this.timestamp,
  });
}

/// 地图资源管理 Widget
class MapResourceManager extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBackground;
  final VoidCallback? onForeground;

  const MapResourceManager({
    super.key,
    required this.child,
    this.onBackground,
    this.onForeground,
  });

  @override
  State<MapResourceManager> createState() => _MapResourceManagerState();
}

class _MapResourceManagerState extends State<MapResourceManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      MapMemoryManager().onAppBackground();
      widget.onBackground?.call();
    } else if (state == AppLifecycleState.resumed) {
      MapMemoryManager().onAppForeground();
      widget.onForeground?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 地图标记聚合器
class MarkerClusterManager {
  final double clusterRadius;
  final int maxClusterZoom;

  MarkerClusterManager({
    this.clusterRadius = 60.0,
    this.maxClusterZoom = 15,
  });

  /// 对标记进行聚合
  List<ClusterItem> clusterMarkers(
    List<MapMarker> markers,
    double zoomLevel,
    Size mapSize,
  ) {
    if (zoomLevel > maxClusterZoom) {
      // 高缩放级别不聚合
      return markers.map((m) => ClusterItem.single(m)).toList();
    }

    // 简单的网格聚合算法
    final clusters = <String, List<MapMarker>>{};
    
    for (final marker in markers) {
      final gridKey = _getGridKey(marker, zoomLevel);
      clusters.putIfAbsent(gridKey, () => []).add(marker);
    }

    return clusters.entries.map((entry) {
      if (entry.value.length == 1) {
        return ClusterItem.single(entry.value.first);
      } else {
        return ClusterItem.cluster(entry.value);
      }
    }).toList();
  }

  String _getGridKey(MapMarker marker, double zoomLevel) {
    // 根据缩放级别计算网格大小
    final gridSize = 256.0 / (1 << (zoomLevel.toInt() - 1));
    final gridX = (marker.longitude / gridSize).floor();
    final gridY = (marker.latitude / gridSize).floor();
    return '$gridX,$gridY';
  }
}

/// 地图标记数据
class MapMarker {
  final String id;
  final double latitude;
  final double longitude;
  final String? iconUrl;
  final VoidCallback? onTap;

  MapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.iconUrl,
    this.onTap,
  });
}

/// 聚合项
class ClusterItem {
  final MapMarker? singleMarker;
  final List<MapMarker>? clusteredMarkers;
  final bool isCluster;
  final int count;

  ClusterItem.single(MapMarker marker)
      : singleMarker = marker,
        clusteredMarkers = null,
        isCluster = false,
        count = 1;

  ClusterItem.cluster(List<MapMarker> markers)
      : singleMarker = null,
        clusteredMarkers = markers,
        isCluster = true,
        count = markers.length;

  double get latitude => isCluster
      ? clusteredMarkers!.map((m) => m.latitude).reduce((a, b) => a + b) / count
      : singleMarker!.latitude;

  double get longitude => isCluster
      ? clusteredMarkers!.map((m) => m.longitude).reduce((a, b) => a + b) / count
      : singleMarker!.longitude;
}

/// 内存优化建议
class MemoryOptimizationTips {
  static const List<String> tips = [
    '地图瓦片缓存限制在50MB以内',
    '后台时自动释放地图资源',
    '标记数量超过500时启用聚合',
    '低缩放级别自动聚合标记减少渲染压力',
    '定期清理过期瓦片缓存',
  ];

  static void printOptimizationStatus() {
    final manager = MapMemoryManager();
    print('=== 地图内存优化状态 ===');
    print('当前内存使用: ${manager.currentMemoryUsageMB}MB');
    print('瓦片缓存上限: ${MapMemoryConfig.maxTileCacheMemoryMB}MB');
    print('标记数量上限: ${MapMemoryConfig.maxMarkerCount}');
    print('========================');
  }
}
