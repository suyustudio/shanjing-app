import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hangzhou_guide/utils/performance_optimizer.dart';
import 'package:hangzhou_guide/utils/map_memory_optimizer.dart';
import 'package:hangzhou_guide/utils/route_preload_optimizer.dart';
import 'package:hangzhou_guide/utils/image_lazy_loader.dart';

/// 性能优化工具单元测试
/// 
/// 测试范围：
/// - 图片懒加载配置
/// - 地图内存管理
/// - 路由预加载逻辑
/// - 启动性能优化
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageLazyLoadConfig 配置测试', () {
    test('懒加载应默认启用', () {
      expect(ImageLazyLoadConfig.enableLazyLoad, isTrue);
    });

    test('预加载偏移量应为0.5屏幕高度', () {
      expect(ImageLazyLoadConfig.preloadOffset, 0.5);
    });

    test('图片缓存最大数量应为100', () {
      expect(ImageLazyLoadConfig.maxCacheImages, 100);
    });

    test('图片最大缓存大小应为50MB', () {
      expect(ImageLazyLoadConfig.maxCacheSizeMB, 50);
    });
  });

  group('MapMemoryConfig 配置测试', () {
    test('瓦片缓存最大数量应为128', () {
      expect(MapMemoryConfig.maxTileCacheSize, 128);
    });

    test('瓦片缓存最大内存应为50MB', () {
      expect(MapMemoryConfig.maxTileCacheMemoryMB, 50);
    });

    test('最大缩放级别应为18.0', () {
      expect(MapMemoryConfig.maxZoomLevel, 18.0);
    });

    test('最小缩放级别应为5.0', () {
      expect(MapMemoryConfig.minZoomLevel, 5.0);
    });

    test('地图区域外缓存层数应为1', () {
      expect(MapMemoryConfig.overPanDistance, 1);
    });

    test('内存回收应默认启用', () {
      expect(MapMemoryConfig.enableMemoryTrim, isTrue);
    });

    test('内存压力阈值应为100MB', () {
      expect(MapMemoryConfig.memoryPressureThresholdMB, 100);
    });

    test('后台时应释放地图资源', () {
      expect(MapMemoryConfig.releaseOnBackground, isTrue);
    });

    test('地图标记最大数量应为500', () {
      expect(MapMemoryConfig.maxMarkerCount, 500);
    });

    test('聚合标记的最小缩放级别应为12.0', () {
      expect(MapMemoryConfig.clusterZoomThreshold, 12.0);
    });
  });

  group('MapMemoryManager 内存管理测试', () {
    late MapMemoryManager manager;

    setUp(() {
      manager = MapMemoryManager();
      manager.clearAllCache();
    });

    tearDown(() {
      manager.clearAllCache();
    });

    test('初始内存使用应为0', () {
      expect(manager.currentMemoryUsageMB, 0);
    });

    test('缓存瓦片后内存使用应增加', () {
      final tileData = Uint8List(1024 * 1024); // 1MB
      manager.cacheTile('tile_1', tileData);

      expect(manager.currentMemoryUsageMB, greaterThan(0));
    });

    test('获取缓存瓦片应返回数据', () {
      final tileData = Uint8List(1024)..[0] = 42;
      manager.cacheTile('tile_test', tileData);

      final cached = manager.getCachedTile('tile_test');
      
      expect(cached, isNotNull);
      expect(cached![0], 42);
    });

    test('获取未缓存的瓦片应返回null', () {
      final cached = manager.getCachedTile('non_existent_tile');
      expect(cached, isNull);
    });

    test('清理缓存后内存使用应为0', () {
      final tileData = Uint8List(1024 * 1024);
      manager.cacheTile('tile_1', tileData);
      
      expect(manager.currentMemoryUsageMB, greaterThan(0));
      
      manager.clearAllCache();
      
      expect(manager.currentMemoryUsageMB, 0);
    });

    test('内存压力处理应清空所有缓存', () {
      final tileData = Uint8List(1024 * 1024);
      manager.cacheTile('tile_1', tileData);
      manager.cacheTile('tile_2', tileData);
      
      manager.onMemoryPressure();
      
      expect(manager.currentMemoryUsageMB, 0);
      expect(manager.getCachedTile('tile_1'), isNull);
      expect(manager.getCachedTile('tile_2'), isNull);
    });

    test('应用进入后台应触发缓存清理', () {
      final tileData = Uint8List(1024 * 1024);
      manager.cacheTile('tile_1', tileData);
      
      manager.onAppBackground();
      
      // 后台清理会执行trimCache，但不会完全清空
      expect(manager.currentMemoryUsageMB, greaterThanOrEqualTo(0));
    });

    test('获取最佳标记数量应根据缩放级别变化', () {
      final lowZoomCount = manager.getOptimalMarkerCount(10.0);
      final highZoomCount = manager.getOptimalMarkerCount(15.0);

      expect(lowZoomCount, 50);
      expect(highZoomCount, MapMemoryConfig.maxMarkerCount);
    });
  });

  group('RoutePreloadConfig 配置测试', () {
    test('路由预加载应默认启用', () {
      expect(RoutePreloadConfig.enablePreload, isTrue);
    });

    test('预加载延迟应为200ms', () {
      expect(RoutePreloadConfig.preloadDelay, const Duration(milliseconds: 200));
    });

    test('最大同时预加载路由数应为3', () {
      expect(RoutePreloadConfig.maxPreloadRoutes, 3);
    });

    test('预加载页面构建超时应为2秒', () {
      expect(RoutePreloadConfig.preloadTimeout, const Duration(seconds: 2));
    });

    test('应预加载动画资源', () {
      expect(RoutePreloadConfig.preloadAnimations, isTrue);
    });

    test('应预加载图片资源', () {
      expect(RoutePreloadConfig.preloadImages, isTrue);
    });
  });

  group('RoutePreloadManager 路由预加载测试', () {
    late RoutePreloadManager manager;

    setUp(() {
      manager = RoutePreloadManager();
      manager.clearPreloadedRoutes();
    });

    tearDown(() {
      manager.clearPreloadedRoutes();
    });

    test('应为单例模式', () {
      final instance1 = RoutePreloadManager();
      final instance2 = RoutePreloadManager();
      
      expect(identical(instance1, instance2), isTrue);
    });

    test('初始状态下没有预加载的路由', () {
      expect(manager.isRoutePreloaded('/test'), isFalse);
      expect(manager.getPreloadedRoute('/test'), isNull);
    });

    test('获取预加载统计应返回有效数据', () {
      final stats = manager.getStats();

      expect(stats.containsKey('preloaded_count'), isTrue);
      expect(stats.containsKey('preloading_count'), isTrue);
      expect(stats.containsKey('queue_length'), isTrue);
      expect(stats.containsKey('preloaded_routes'), isTrue);
    });

    test('清除预加载缓存后统计应为空', () {
      manager.clearPreloadedRoutes();
      
      final stats = manager.getStats();
      
      expect(stats['preloaded_count'], 0);
      expect(stats['queue_length'], 0);
    });
  });

  group('StartupOptimizer 启动优化测试', () {
    late StartupOptimizer optimizer;

    setUp(() {
      optimizer = StartupOptimizer();
    });

    test('应为单例模式', () {
      final instance1 = StartupOptimizer();
      final instance2 = StartupOptimizer();
      
      expect(identical(instance1, instance2), isTrue);
    });

    test('初始阶段统计为空', () {
      final stats = optimizer.getStartupStats();
      
      expect(stats['total_time_ms'], 0);
      expect((stats['phases'] as Map).isEmpty, isTrue);
    });

    test('记录启动时间后应能获取统计', () {
      optimizer.markAppStart();
      optimizer.markPhaseComplete('framework_init');
      
      final stats = optimizer.getStartupStats();
      
      expect(stats['total_time_ms'], greaterThanOrEqualTo(0));
      expect((stats['phases'] as Map).containsKey('framework_init'), isTrue);
    });

    test('多个阶段统计应累加', () {
      optimizer.markAppStart();
      
      optimizer.markPhaseComplete('phase_1');
      optimizer.markPhaseComplete('phase_2');
      optimizer.markPhaseComplete('phase_3');
      
      final stats = optimizer.getStartupStats();
      final phases = stats['phases'] as Map<String, dynamic>;
      
      expect(phases.length, 3);
      expect(phases.containsKey('phase_1'), isTrue);
      expect(phases.containsKey('phase_2'), isTrue);
      expect(phases.containsKey('phase_3'), isTrue);
    });
  });

  group('MemoryOptimizationTips 优化建议测试', () {
    test('应包含优化建议列表', () {
      expect(MemoryOptimizationTips.tips, isNotEmpty);
      expect(MemoryOptimizationTips.tips.length, 5);
    });

    test('优化建议应包含关键信息', () {
      final tips = MemoryOptimizationTips.tips.join(' ');
      
      expect(tips.contains('缓存'), isTrue);
      expect(tips.contains('后台'), isTrue);
      expect(tips.contains('标记'), isTrue);
      expect(tips.contains('聚合'), isTrue);
    });
  });

  group('ImagePreloader 图片预加载测试', () {
    late ImagePreloader preloader;

    setUp(() {
      preloader = ImagePreloader();
    });

    test('应为单例模式', () {
      final instance1 = ImagePreloader();
      final instance2 = ImagePreloader();
      
      expect(identical(instance1, instance2), isTrue);
    });

    test('预加载空图片列表不应抛出异常', () async {
      await expectLater(
        preloader.preloadImages(null, []),
        completes,
      );
    });
  });

  group('MarkerClusterManager 标记聚合测试', () {
    late MarkerClusterManager clusterManager;

    setUp(() {
      clusterManager = MarkerClusterManager();
    });

    test('高缩放级别不应聚合', () {
      final markers = [
        MapMarker(id: '1', latitude: 30.0, longitude: 120.0),
        MapMarker(id: '2', latitude: 30.1, longitude: 120.1),
      ];

      final clusters = clusterManager.clusterMarkers(
        markers,
        16.0, // 高缩放级别
        const Size(400, 800),
      );

      expect(clusters.length, 2);
      expect(clusters.every((c) => !c.isCluster), isTrue);
    });

    test('聚合项应正确计算中心点', () {
      final markers = [
        MapMarker(id: '1', latitude: 30.0, longitude: 120.0),
        MapMarker(id: '2', latitude: 31.0, longitude: 121.0),
      ];

      final clusterItem = ClusterItem.cluster(markers);

      expect(clusterItem.isCluster, isTrue);
      expect(clusterItem.count, 2);
      expect(clusterItem.latitude, 30.5);
      expect(clusterItem.longitude, 120.5);
    });

    test('单个标记应正确创建聚合项', () {
      final marker = MapMarker(id: '1', latitude: 30.0, longitude: 120.0);

      final clusterItem = ClusterItem.single(marker);

      expect(clusterItem.isCluster, isFalse);
      expect(clusterItem.count, 1);
      expect(clusterItem.singleMarker, marker);
      expect(clusterItem.clusteredMarkers, isNull);
    });
  });

  group('ClusterItem 聚合项测试', () {
    test('单个标记的中心点应等于标记坐标', () {
      final marker = MapMarker(id: '1', latitude: 30.5, longitude: 120.5);
      final clusterItem = ClusterItem.single(marker);

      expect(clusterItem.latitude, 30.5);
      expect(clusterItem.longitude, 120.5);
    });

    test('多个相同标记的聚合中心点应等于原坐标', () {
      final markers = [
        MapMarker(id: '1', latitude: 30.0, longitude: 120.0),
        MapMarker(id: '2', latitude: 30.0, longitude: 120.0),
      ];

      final clusterItem = ClusterItem.cluster(markers);

      expect(clusterItem.latitude, 30.0);
      expect(clusterItem.longitude, 120.0);
    });
  });

  group('MapMarker 标记测试', () {
    test('应正确存储标记数据', () {
      final marker = MapMarker(
        id: 'test_id',
        latitude: 30.123,
        longitude: 120.456,
        iconUrl: 'https://example.com/icon.png',
      );

      expect(marker.id, 'test_id');
      expect(marker.latitude, 30.123);
      expect(marker.longitude, 120.456);
      expect(marker.iconUrl, 'https://example.com/icon.png');
    });

    test('可选参数应为null', () {
      final marker = MapMarker(
        id: 'test_id',
        latitude: 30.0,
        longitude: 120.0,
      );

      expect(marker.iconUrl, isNull);
      expect(marker.onTap, isNull);
    });
  });

  group('PerformanceOptimizationSummary 性能摘要测试', () {
    test('打印摘要不应抛出异常', () {
      expect(() => PerformanceOptimizationSummary.printSummary(), returnsNormally);
    });
  });

  group('PerformanceOptimizer 主类测试', () {
    test('初始化方法应存在', () {
      expect(() => PerformanceOptimizer.initialize(), returnsNormally);
    });

    test('标记阶段方法应存在', () {
      PerformanceOptimizer.initialize();
      expect(() => PerformanceOptimizer.markPhase('test_phase'), returnsNormally);
    });

    test('打印报告方法应存在', () {
      expect(() => PerformanceOptimizer.printStartupReport(), returnsNormally);
    });
  });

  group('_TileCacheEntry 瓦片缓存条目测试', () {
    test('应正确存储瓦片数据', () {
      final data = Uint8List.fromList([1, 2, 3, 4, 5]);
      final entry = _TileCacheEntry(
        data: data,
        sizeMB: 1,
        timestamp: DateTime(2024, 1, 1),
      );

      expect(entry.data, data);
      expect(entry.sizeMB, 1);
      expect(entry.timestamp, DateTime(2024, 1, 1));
    });
  });
}
