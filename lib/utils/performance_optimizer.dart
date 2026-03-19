/// M4 P1 性能优化模块
/// 
/// 导出所有性能优化相关工具类
/// 
/// 使用方法：
/// ```dart
/// import 'utils/performance_optimizer.dart';
/// ```

// 图片懒加载
export 'image_lazy_loader.dart';

// 地图内存优化
export 'map_memory_optimizer.dart';

// 路由预加载优化
export 'route_preload_optimizer.dart';

// 资源压缩
export 'asset_compression.dart';

/// 性能优化初始化
/// 
/// 在应用启动时调用
import 'package:flutter/material.dart';
import 'route_preload_optimizer.dart';
import 'asset_compression.dart';

class PerformanceOptimizer {
  /// 初始化性能优化
  static void initialize() {
    // 记录启动时间
    StartupOptimizer().markAppStart();
    
    // 打印优化配置
    PerformanceOptimizationUtils.printCompleteReport();
  }
  
  /// 标记启动阶段完成
  static void markPhase(String phaseName) {
    StartupOptimizer().markPhaseComplete(phaseName);
  }
  
  /// 打印启动报告
  static void printStartupReport() {
    StartupOptimizer().printStartupReport();
  }
}
