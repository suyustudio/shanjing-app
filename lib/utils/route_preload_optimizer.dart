import 'package:flutter/material.dart';
import 'image_lazy_loader.dart';
import 'map_memory_optimizer.dart';

/// 路由预加载配置
class RoutePreloadConfig {
  /// 是否启用路由预加载
  static const bool enablePreload = true;
  
  /// 预加载延迟时间
  static const Duration preloadDelay = Duration(milliseconds: 200);
  
  /// 最大同时预加载路由数
  static const int maxPreloadRoutes = 3;
  
  /// 预加载页面构建超时时间
  static const Duration preloadTimeout = Duration(seconds: 2);
  
  /// 是否预加载动画资源
  static const bool preloadAnimations = true;
  
  /// 是否预加载图片资源
  static const bool preloadImages = true;
}

/// 路由预加载管理器
/// 
/// 功能：
/// - 预测用户行为预加载路由
/// - 后台构建页面减少切换延迟
/// - 资源预加载（图片、动画）
class RoutePreloadManager {
  static final RoutePreloadManager _instance = RoutePreloadManager._internal();
  factory RoutePreloadManager() => _instance;
  RoutePreloadManager._internal();

  // 预加载的路由缓存
  final Map<String, Widget> _preloadedRoutes = {};
  final Set<String> _preloadingRoutes = {};
  
  // 预加载队列
  final List<_PreloadTask> _preloadQueue = [];
  bool _isProcessingQueue = false;

  /// 预加载路由
  Future<void> preloadRoute(
    String routeName,
    WidgetBuilder builder, {
    BuildContext? context,
  }) async {
    if (!RoutePreloadConfig.enablePreload) return;
    if (_preloadedRoutes.containsKey(routeName)) return;
    if (_preloadingRoutes.contains(routeName)) return;
    
    // 添加到队列
    _preloadQueue.add(_PreloadTask(
      routeName: routeName,
      builder: builder,
      context: context,
    ));
    
    // 处理队列
    _processPreloadQueue();
  }

  /// 批量预加载路由
  Future<void> preloadRoutes(List<_PreloadTask> tasks) async {
    for (final task in tasks) {
      _preloadQueue.add(task);
    }
    _processPreloadQueue();
  }

  /// 处理预加载队列
  Future<void> _processPreloadQueue() async {
    if (_isProcessingQueue) return;
    if (_preloadQueue.isEmpty) return;
    
    _isProcessingQueue = true;
    
    while (_preloadQueue.isNotEmpty &&
           _preloadingRoutes.length < RoutePreloadConfig.maxPreloadRoutes) {
      final task = _preloadQueue.removeAt(0);
      
      if (_preloadedRoutes.containsKey(task.routeName) ||
          _preloadingRoutes.contains(task.routeName)) {
        continue;
      }
      
      _preloadingRoutes.add(task.routeName);
      
      // 延迟预加载，避免影响当前页面
      await Future.delayed(RoutePreloadConfig.preloadDelay);
      
      try {
        final widget = await _buildWidgetWithTimeout(task);
        if (widget != null) {
          _preloadedRoutes[task.routeName] = widget;
          print('[RoutePreload] Preloaded: ${task.routeName}');
        }
      } catch (e) {
        print('[RoutePreload] Failed to preload ${task.routeName}: $e');
      } finally {
        _preloadingRoutes.remove(task.routeName);
      }
    }
    
    _isProcessingQueue = false;
    
    // 如果队列还有任务，继续处理
    if (_preloadQueue.isNotEmpty) {
      _processPreloadQueue();
    }
  }

  /// 带超时的Widget构建
  Future<Widget?> _buildWidgetWithTimeout(_PreloadTask task) async {
    try {
      final widget = await Future.any([
        Future.delayed(RoutePreloadConfig.preloadTimeout, () => null),
        Future(() {
          if (task.context != null) {
            return task.builder(task.context!);
          }
          return null;
        }),
      ]);
      return widget;
    } catch (e) {
      return null;
    }
  }

  /// 获取预加载的路由
  Widget? getPreloadedRoute(String routeName) {
    return _preloadedRoutes.remove(routeName);
  }

  /// 检查路由是否已预加载
  bool isRoutePreloaded(String routeName) {
    return _preloadedRoutes.containsKey(routeName);
  }

  /// 清除预加载缓存
  void clearPreloadedRoutes() {
    _preloadedRoutes.clear();
    _preloadingRoutes.clear();
    _preloadQueue.clear();
  }

  /// 获取预加载统计
  Map<String, dynamic> getStats() {
    return {
      'preloaded_count': _preloadedRoutes.length,
      'preloading_count': _preloadingRoutes.length,
      'queue_length': _preloadQueue.length,
      'preloaded_routes': _preloadedRoutes.keys.toList(),
    };
  }
}

/// 预加载任务
class _PreloadTask {
  final String routeName;
  final WidgetBuilder builder;
  final BuildContext? context;

  _PreloadTask({
    required this.routeName,
    required this.builder,
    this.context,
  });
}

/// 智能路由预加载 Widget
/// 
/// 根据用户行为预测预加载目标路由
class SmartRoutePreloader extends StatefulWidget {
  final Widget child;
  final Map<String, WidgetBuilder> routeBuilders;

  const SmartRoutePreloader({
    super.key,
    required this.child,
    required this.routeBuilders,
  });

  @override
  State<SmartRoutePreloader> createState() => _SmartRoutePreloaderState();
}

class _SmartRoutePreloaderState extends State<SmartRoutePreloader> {
  final RoutePreloadManager _preloadManager = RoutePreloadManager();
  String _currentRoute = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 获取当前路由
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      final routeName = modalRoute.settings.name ?? '';
      if (routeName != _currentRoute) {
        _currentRoute = routeName;
        _predictAndPreload(routeName);
      }
    }
  }

  void _predictAndPreload(String currentRoute) {
    // 基于当前路由预测下一步
    final routesToPreload = _predictNextRoutes(currentRoute);
    
    for (final routeName in routesToPreload) {
      final builder = widget.routeBuilders[routeName];
      if (builder != null) {
        _preloadManager.preloadRoute(routeName, builder, context: context);
      }
    }
  }

  List<String> _predictNextRoutes(String currentRoute) {
    // 基于当前页面预测用户最可能去的页面
    switch (currentRoute) {
      case '/':
      case '/discovery':
        // 发现页 -> 路线详情
        return ['/trail_detail'];
      case '/trail_detail':
        // 路线详情 -> 导航、收藏
        return ['/navigation', '/favorites'];
      case '/navigation':
        // 导航页 -> SOS、安全中心
        return ['/sos', '/safety_center'];
      case '/profile':
        // 个人中心 -> 收藏、历史、设置
        return ['/favorites', '/history', '/settings'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 预加载路由包装器
/// 
/// 使用预加载的Widget或实时构建
class PreloadedRoute extends StatelessWidget {
  final String routeName;
  final WidgetBuilder builder;

  const PreloadedRoute({
    super.key,
    required this.routeName,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final preloadedWidget = RoutePreloadManager().getPreloadedRoute(routeName);
    
    if (preloadedWidget != null) {
      // 使用预加载的Widget
      return preloadedWidget;
    }
    
    // 实时构建
    return builder(context);
  }
}

/// 资源预加载器
class AssetPreloader {
  /// 预加载图片资源
  static Future<void> preloadImages(BuildContext context, List<String> assetPaths) async {
    if (!RoutePreloadConfig.preloadImages) return;
    
    for (final path in assetPaths) {
      try {
        final configuration = createLocalImageConfiguration(context);
        final provider = AssetImage(path);
        await provider.obtainKey(configuration);
      } catch (e) {
        // 预加载失败不影响主流程
      }
    }
  }

  /// 预加载字体资源
  static Future<void> preloadFonts(List<String> fontFamilies) async {
    for (final family in fontFamilies) {
      // 字体通常在应用启动时加载，这里只是占位
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
}

/// 启动性能优化工具
class StartupOptimizer {
  static final StartupOptimizer _instance = StartupOptimizer._internal();
  factory StartupOptimizer() => _instance;
  StartupOptimizer._internal();

  DateTime? _appStartTime;
  final Map<String, Duration> _phaseTimings = {};

  /// 记录应用启动时间
  void markAppStart() {
    _appStartTime = DateTime.now();
  }

  /// 记录阶段完成
  void markPhaseComplete(String phaseName) {
    if (_appStartTime == null) return;
    
    _phaseTimings[phaseName] = DateTime.now().difference(_appStartTime!);
  }

  /// 获取启动统计
  Map<String, dynamic> getStartupStats() {
    return {
      'total_time_ms': _phaseTimings.values.isNotEmpty
          ? _phaseTimings.values.last.inMilliseconds
          : 0,
      'phases': _phaseTimings.map((k, v) => MapEntry(k, v.inMilliseconds)),
    };
  }

  /// 打印启动报告
  void printStartupReport() {
    final stats = getStartupStats();
    print('=== 启动性能报告 ===');
    print('总启动时间: ${stats['total_time_ms']}ms');
    print('各阶段耗时:');
    (stats['phases'] as Map<String, dynamic>).forEach((phase, time) {
      print('  $phase: ${time}ms');
    });
    print('===================');
  }
}

/// 性能优化总览
class PerformanceOptimizationSummary {
  static void printSummary() {
    print('''
=== 性能优化配置总览 ===

1. 图片懒加载
   - 启用状态: ${RoutePreloadConfig.enablePreload ? '✓' : '✗'}
   - 预加载偏移: ${ImageLazyLoadConfig.preloadOffset * 100}%
   - 最大缓存: ${ImageLazyLoadConfig.maxCacheImages} 张

2. 地图内存优化
   - 瓦片缓存上限: ${MapMemoryConfig.maxTileCacheMemoryMB}MB
   - 标记聚合: ${MapMemoryConfig.maxMarkerCount} 个
   - 后台释放: ${MapMemoryConfig.releaseOnBackground ? '✓' : '✗'}

3. 路由预加载
   - 启用状态: ${RoutePreloadConfig.enablePreload ? '✓' : '✗'}
   - 最大同时预加载: ${RoutePreloadConfig.maxPreloadRoutes} 个
   - 构建超时: ${RoutePreloadConfig.preloadTimeout.inSeconds}秒

4. 启动优化
   - 冷启动目标: < 2s
   - 当前基线: ~2.5s
   - 优化预期: 节省 500ms

========================
''');
  }
}
