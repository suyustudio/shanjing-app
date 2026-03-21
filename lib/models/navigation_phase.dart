import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// 导航阶段枚举
/// 定义明确的导航流程阶段，用于实现真正的两阶段导航
enum NavigationPhase {
  /// 阶段1：规划到路线起点的路径
  /// 状态：正在计算从当前位置到路线起点的最佳路径
  planningToStart,
  
  /// 阶段1：导航到路线起点
  /// 状态：正在按照规划路径前往路线起点
  navigatingToStart,
  
  /// 阶段1.5：到达路线起点，预览路线
  /// 状态：已到达路线起点，显示路线预览，等待用户确认开始路线导航
  previewRoute,
  
  /// 阶段2：沿路线导航
  /// 状态：正在沿预设路线导航，使用高德专业导航服务
  navigatingRoute,
  
  /// 到达终点
  /// 状态：已成功到达路线终点，导航完成
  completed,
  
  /// 偏航（由高德SDK触发）
  /// 状态：检测到偏离规划路线，高德SDK正在重新规划
  offRoute,
  
  /// 错误状态
  /// 状态：导航过程中发生错误
  error,
}

/// 导航阶段扩展方法
extension NavigationPhaseExtension on NavigationPhase {
  /// 获取阶段描述
  String get description {
    switch (this) {
      case NavigationPhase.planningToStart:
        return '规划到起点的路径';
      case NavigationPhase.navigatingToStart:
        return '前往路线起点';
      case NavigationPhase.previewRoute:
        return '预览路线';
      case NavigationPhase.navigatingRoute:
        return '沿路线导航';
      case NavigationPhase.completed:
        return '导航完成';
      case NavigationPhase.offRoute:
        return '已偏航，重新规划中';
      case NavigationPhase.error:
        return '导航错误';
    }
  }
  
  /// 获取阶段图标
  String get icon {
    switch (this) {
      case NavigationPhase.planningToStart:
        return '🧭';
      case NavigationPhase.navigatingToStart:
        return '🚶‍♂️';
      case NavigationPhase.previewRoute:
        return '👀';
      case NavigationPhase.navigatingRoute:
        return '🗺️';
      case NavigationPhase.completed:
        return '✅';
      case NavigationPhase.offRoute:
        return '⚠️';
      case NavigationPhase.error:
        return '❌';
    }
  }
  
  /// 是否是进行中的状态
  bool get isInProgress {
    return this == NavigationPhase.planningToStart ||
           this == NavigationPhase.navigatingToStart ||
           this == NavigationPhase.navigatingRoute ||
           this == NavigationPhase.offRoute;
  }
  
  /// 是否是错误或完成状态
  bool get isTerminal {
    return this == NavigationPhase.completed ||
           this == NavigationPhase.error;
  }
  
  /// 获取阶段的颜色（根据状态）
  Color getColor(BuildContext context) {
    final designSystem = DesignSystem();
    switch (this) {
      case NavigationPhase.planningToStart:
        return designSystem.getPrimary(context).withOpacity(0.7);
      case NavigationPhase.navigatingToStart:
        return designSystem.getPrimary(context);
      case NavigationPhase.previewRoute:
        return designSystem.getInfo(context);
      case NavigationPhase.navigatingRoute:
        return designSystem.getSuccess(context);
      case NavigationPhase.completed:
        return designSystem.getSuccess(context);
      case NavigationPhase.offRoute:
        return designSystem.getWarning(context);
      case NavigationPhase.error:
        return designSystem.getError(context);
    }
  }
}