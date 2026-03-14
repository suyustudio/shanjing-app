import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// ============================================
/// 山径APP - 空状态组件 (Empty State Component)
/// ============================================
/// 
/// 提供统一的空状态设计语言，包含预设类型和自定义选项
/// 
/// 使用示例:
/// ```dart
/// // 网络错误空状态
/// AppEmpty.network(
///   onRetry: () => loadData(),
/// )
/// 
/// // 搜索为空
/// AppEmpty.search(
///   onClearFilter: () => clearFilters(),
/// )
/// 
/// // 自定义空状态
/// AppEmpty.custom(
///   illustration: MyIllustration(),
///   title: '自定义标题',
///   description: '自定义描述',
///   primaryAction: AppEmptyAction(
///     label: '操作',
///     onPressed: () {},
///   ),
/// )
/// ```

/// 空状态动作按钮配置
class AppEmptyAction {
  final String label;
  final VoidCallback onPressed;
  final AppEmptyActionType type;

  const AppEmptyAction({
    required this.label,
    required this.onPressed,
    this.type = AppEmptyActionType.primary,
  });
}

/// 动作按钮类型
enum AppEmptyActionType {
  primary,    // 主操作按钮
  secondary,  // 次操作按钮
}

/// 空状态预设类型
enum AppEmptyType {
  network,    // 无网络
  search,     // 无搜索结果
  favorite,   // 收藏为空
  download,   // 下载列表为空
  location,   // GPS信号弱
  permission, // 无权限
  error,      // 通用错误
  data,       // 无数据
}

/// ============================================
/// 主组件: AppEmpty
/// ============================================
class AppEmpty extends StatelessWidget {
  // === 通用属性 ===
  final Widget? illustration;
  final IconData? icon;
  final String? title;
  final String? description;
  final AppEmptyAction? primaryAction;
  final AppEmptyAction? secondaryAction;
  final EdgeInsetsGeometry? padding;
  
  // === 预设类型 ===
  final AppEmptyType? type;

  const AppEmpty({
    super.key,
    this.illustration,
    this.icon,
    this.title,
    this.description,
    this.primaryAction,
    this.secondaryAction,
    this.padding,
    this.type,
  });

  // ============================================
  // 预设工厂构造函数
  // ============================================

  /// 网络错误 - 无网络连接
  factory AppEmpty.network({
    Key? key,
    VoidCallback? onRetry,
    VoidCallback? onOpenSettings,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.network,
      icon: Icons.wifi_off_outlined,
      title: '网络好像断开了',
      description: '请检查网络设置后重试',
      primaryAction: onRetry != null
          ? AppEmptyAction(
              label: '重新加载',
              onPressed: onRetry,
              type: AppEmptyActionType.primary,
            )
          : null,
      secondaryAction: onOpenSettings != null
          ? AppEmptyAction(
              label: '检查设置',
              onPressed: onOpenSettings,
              type: AppEmptyActionType.secondary,
            )
          : null,
    );
  }

  /// 搜索为空 - 无搜索结果
  factory AppEmpty.search({
    Key? key,
    VoidCallback? onClearFilter,
    VoidCallback? onBrowseRecommended,
    String? keyword,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.search,
      icon: Icons.search_off_outlined,
      title: keyword != null ? '没有找到"$keyword"' : '没有找到相关路线',
      description: '换个关键词试试，或浏览推荐路线',
      primaryAction: onBrowseRecommended != null
          ? AppEmptyAction(
              label: '查看推荐',
              onPressed: onBrowseRecommended,
              type: AppEmptyActionType.primary,
            )
          : null,
      secondaryAction: onClearFilter != null
          ? AppEmptyAction(
              label: '清空筛选',
              onPressed: onClearFilter,
              type: AppEmptyActionType.secondary,
            )
          : null,
    );
  }

  /// 收藏为空
  factory AppEmpty.favorite({
    Key? key,
    VoidCallback? onExplore,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.favorite,
      illustration: const _EmptyBoxIllustration(),
      title: '还没有收藏任何路线',
      description: '收藏喜欢的路线，随时查看和导航',
      primaryAction: onExplore != null
          ? AppEmptyAction(
              label: '去发现',
              onPressed: onExplore,
              type: AppEmptyActionType.primary,
            )
          : null,
    );
  }

  /// 下载列表为空
  factory AppEmpty.download({
    Key? key,
    VoidCallback? onGoDownload,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.download,
      illustration: const _EmptyMapIllustration(),
      title: '还没有下载离线地图',
      description: '下载离线地图，无网络也能导航',
      primaryAction: onGoDownload != null
          ? AppEmptyAction(
              label: '去下载',
              onPressed: onGoDownload,
              type: AppEmptyActionType.primary,
            )
          : null,
    );
  }

  /// GPS信号弱
  factory AppEmpty.location({
    Key? key,
    VoidCallback? onCheckSettings,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.location,
      illustration: const _WeakSignalIllustration(),
      title: 'GPS信号较弱',
      description: '请检查定位设置，或移动到开阔地带',
      primaryAction: onCheckSettings != null
          ? AppEmptyAction(
              label: '检查设置',
              onPressed: onCheckSettings,
              type: AppEmptyActionType.primary,
            )
          : null,
    );
  }

  /// 无权限
  factory AppEmpty.permission({
    Key? key,
    required String permissionName,
    required String permissionDescription,
    VoidCallback? onRequestPermission,
    IconData icon = Icons.location_off_outlined,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.permission,
      icon: icon,
      title: '需要$permissionName',
      description: permissionDescription,
      primaryAction: onRequestPermission != null
          ? AppEmptyAction(
              label: '开启权限',
              onPressed: onRequestPermission,
              type: AppEmptyActionType.primary,
            )
          : null,
    );
  }

  /// 通用错误
  factory AppEmpty.error({
    Key? key,
    String? title,
    String? description,
    VoidCallback? onRetry,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.error,
      icon: Icons.error_outline,
      title: title ?? '出错了',
      description: description ?? '请稍后重试',
      primaryAction: onRetry != null
          ? AppEmptyAction(
              label: '重新加载',
              onPressed: onRetry,
              type: AppEmptyActionType.primary,
            )
          : null,
    );
  }

  /// 无数据
  factory AppEmpty.data({
    Key? key,
    String? title,
    String? description,
    VoidCallback? onRefresh,
  }) {
    return AppEmpty(
      key: key,
      type: AppEmptyType.data,
      icon: Icons.inbox_outlined,
      title: title ?? '暂无数据',
      description: description,
      primaryAction: onRefresh != null
          ? AppEmptyAction(
              label: '刷新',
              onPressed: onRefresh,
              type: AppEmptyActionType.primary,
            )
          : null,
    );
  }

  // ============================================
  // 构建方法
  // ============================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 获取颜色
    final titleColor = isDark ? Colors.grey[300] : DesignSystem.textPrimary;
    final descColor = isDark ? Colors.grey[500] : DesignSystem.textSecondary;
    final iconColor = _getIconColor(context, isDark);

    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // === 插画/图标 ===
            if (illustration != null)
              _buildIllustration(context)
            else if (icon != null)
              _buildIcon(context, iconColor),
            
            const SizedBox(height: 24),
            
            // === 标题 ===
            if (title != null)
              _buildTitle(context, titleColor),
            
            // === 描述 ===
            if (description != null) ...[
              const SizedBox(height: 8),
              _buildDescription(context, descColor),
            ],
            
            // === 操作按钮 ===
            if (primaryAction != null || secondaryAction != null) ...[
              const SizedBox(height: 32),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  // === 构建子组件 ===

  Widget _buildIllustration(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: illustration,
    );
  }

  Widget _buildIcon(BuildContext context, Color? color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(context),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40,
        color: color ?? DesignSystem.getPrimary(context),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, Color? color) {
    return Text(
      title!,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context, Color? color) {
    return Text(
      description!,
      style: TextStyle(
        fontSize: 14,
        color: color,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        if (secondaryAction != null)
          _buildActionButton(context, secondaryAction!, AppEmptyActionType.secondary),
        if (primaryAction != null)
          _buildActionButton(context, primaryAction!, AppEmptyActionType.primary),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, AppEmptyAction action, AppEmptyActionType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (type == AppEmptyActionType.primary) {
      return ElevatedButton(
        onPressed: action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignSystem.getPrimary(context),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          action.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return OutlinedButton(
        onPressed: action.onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.grey[300] : DesignSystem.textPrimary,
          side: BorderSide(
            color: isDark ? Colors.grey[600]! : DesignSystem.border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          action.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }

  // === 辅助方法 ===

  Color? _getIconColor(BuildContext context, bool isDark) {
    if (type == null) return isDark ? Colors.grey[500] : DesignSystem.textTertiary;
    
    switch (type!) {
      case AppEmptyType.network:
      case AppEmptyType.error:
        return isDark ? Colors.grey[500] : DesignSystem.textTertiary;
      case AppEmptyType.search:
        return isDark ? Colors.grey[500] : DesignSystem.textTertiary;
      case AppEmptyType.favorite:
      case AppEmptyType.download:
      case AppEmptyType.location:
        return DesignSystem.getPrimary(context).withOpacity(0.8);
      case AppEmptyType.permission:
        return DesignSystem.getPrimary(context);
      case AppEmptyType.data:
        return isDark ? Colors.grey[500] : DesignSystem.textTertiary;
    }
  }

  Color? _getIconBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = DesignSystem.getPrimary(context);
    
    if (type == AppEmptyType.favorite ||
        type == AppEmptyType.download ||
        type == AppEmptyType.location) {
      return baseColor.withOpacity(isDark ? 0.15 : 0.1);
    }
    
    return isDark ? Colors.grey[800] : Colors.grey[100];
  }
}

/// ============================================
/// 自定义空状态构建器
/// ============================================
class AppEmptyBuilder extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String? description;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const AppEmptyBuilder({
    super.key,
    required this.illustration,
    required this.title,
    this.description,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmpty(
      illustration: illustration,
      title: title,
      description: description,
      primaryAction: primaryActionLabel != null && onPrimaryAction != null
          ? AppEmptyAction(
              label: primaryActionLabel!,
              onPressed: onPrimaryAction!,
            )
          : null,
      secondaryAction: secondaryActionLabel != null && onSecondaryAction != null
          ? AppEmptyAction(
              label: secondaryActionLabel!,
              onPressed: onSecondaryAction!,
              type: AppEmptyActionType.secondary,
            )
          : null,
    );
  }
}

/// ============================================
/// 内置插画组件 - 简约户外风格
/// ============================================

/// 空盒子插画 - 用于收藏为空
class _EmptyBoxIllustration extends StatelessWidget {
  const _EmptyBoxIllustration();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = DesignSystem.getPrimary(context);
    final lineColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;

    return CustomPaint(
      size: const Size(120, 120),
      painter: _EmptyBoxPainter(
        primaryColor: primaryColor,
        lineColor: lineColor,
        isDark: isDark,
      ),
    );
  }
}

class _EmptyBoxPainter extends CustomPainter {
  final Color primaryColor;
  final Color lineColor;
  final bool isDark;

  _EmptyBoxPainter({
    required this.primaryColor,
    required this.lineColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 绘制盒子轮廓
    final boxPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final boxPath = Path()
      ..moveTo(centerX - 30, centerY + 10)
      ..lineTo(centerX - 30, centerY + 30)
      ..lineTo(centerX + 30, centerY + 30)
      ..lineTo(centerX + 30, centerY + 10);
    
    canvas.drawPath(boxPath, boxPaint);

    // 绘制盒子开口
    final openPath = Path()
      ..moveTo(centerX - 35, centerY + 10)
      ..lineTo(centerX - 25, centerY - 10)
      ..lineTo(centerX + 25, centerY - 10)
      ..lineTo(centerX + 35, centerY + 10);
    
    canvas.drawPath(openPath, boxPaint);

    // 绘制盒盖（打开状态）
    final lidPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final lidPath = Path()
      ..moveTo(centerX - 25, centerY - 10)
      ..lineTo(centerX - 15, centerY - 35)
      ..lineTo(centerX + 20, centerY - 30)
      ..lineTo(centerX + 25, centerY - 10);
    
    canvas.drawPath(lidPath, lidPaint);

    // 绘制一颗小星星（表示收藏）
    final starPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final starPath = Path();
    final starCenter = Offset(centerX, centerY - 5);
    const starRadius = 8.0;
    
    for (int i = 0; i < 5; i++) {
      final angle = (i * 144 - 90) * 3.14159 / 180;
      final x = starCenter.dx + starRadius * cos(angle);
      final y = starCenter.dy + starRadius * sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
      
      final innerAngle = ((i * 144 + 72) - 90) * 3.14159 / 180;
      final innerX = starCenter.dx + starRadius * 0.4 * cos(innerAngle);
      final innerY = starCenter.dy + starRadius * 0.4 * sin(innerAngle);
      starPath.lineTo(innerX, innerY);
    }
    starPath.close();
    
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 空地图插画 - 用于离线地图为空
class _EmptyMapIllustration extends StatelessWidget {
  const _EmptyMapIllustration();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = DesignSystem.getPrimary(context);
    final lineColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;

    return CustomPaint(
      size: const Size(120, 120),
      painter: _EmptyMapPainter(
        primaryColor: primaryColor,
        lineColor: lineColor,
        isDark: isDark,
      ),
    );
  }
}

class _EmptyMapPainter extends CustomPainter {
  final Color primaryColor;
  final Color lineColor;
  final bool isDark;

  _EmptyMapPainter({
    required this.primaryColor,
    required this.lineColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 绘制地图轮廓（折叠的地图）
    final mapPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 左侧面板
    final leftPanel = Path()
      ..moveTo(centerX - 25, centerY - 30)
      ..lineTo(centerX - 5, centerY - 35)
      ..lineTo(centerX - 5, centerY + 25)
      ..lineTo(centerX - 25, centerY + 30)
      ..close();
    
    canvas.drawPath(leftPanel, mapPaint);

    // 右侧面板
    final rightPanel = Path()
      ..moveTo(centerX - 5, centerY - 35)
      ..lineTo(centerX + 25, centerY - 30)
      ..lineTo(centerX + 25, centerY + 30)
      ..lineTo(centerX - 5, centerY + 25)
      ..close();
    
    canvas.drawPath(rightPanel, mapPaint);

    // 绘制地图上的路径线条
    final pathPaint = Paint()
      ..color = primaryColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 左侧路径
    canvas.drawLine(
      Offset(centerX - 20, centerY - 10),
      Offset(centerX - 10, centerY + 5),
      pathPaint,
    );

    // 右侧路径
    final rightPath = Path()
      ..moveTo(centerX + 5, centerY - 15)
      ..lineTo(centerX + 15, centerY - 5)
      ..lineTo(centerX + 20, centerY + 10);
    
    canvas.drawPath(rightPath, pathPaint);

    // 绘制下载图标
    final downloadPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(centerX - 3, centerY - 5)
      ..lineTo(centerX + 3, centerY - 5)
      ..lineTo(centerX + 3, centerY - 12)
      ..lineTo(centerX - 3, centerY - 12)
      ..close()
      ..moveTo(centerX, centerY - 8)
      ..lineTo(centerX - 6, centerY - 18)
      ..lineTo(centerX + 6, centerY - 18)
      ..close();
    
    canvas.drawPath(arrowPath, downloadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => false;
}

/// GPS弱信号插画
class _WeakSignalIllustration extends StatelessWidget {
  const _WeakSignalIllustration();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = DesignSystem.getPrimary(context);
    final lineColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;
    final warningColor = DesignSystem.warning;

    return CustomPaint(
      size: const Size(120, 120),
      painter: _WeakSignalPainter(
        primaryColor: primaryColor,
        lineColor: lineColor,
        warningColor: warningColor,
        isDark: isDark,
      ),
    );
  }
}

class _WeakSignalPainter extends CustomPainter {
  final Color primaryColor;
  final Color lineColor;
  final Color warningColor;
  final bool isDark;

  _WeakSignalPainter({
    required this.primaryColor,
    required this.lineColor,
    required this.warningColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 绘制定位图标
    final pinPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final pinPath = Path()
      ..moveTo(centerX, centerY - 20)
      ..cubicTo(
        centerX - 15, centerY - 20,
        centerX - 15, centerY - 5,
        centerX, centerY + 15
      )
      ..cubicTo(
        centerX + 15, centerY - 5,
        centerX + 15, centerY - 20,
        centerX, centerY - 20
      );
    
    canvas.drawPath(pinPath, pinPaint);

    // 定位点中心
    final centerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(centerX, centerY - 12),
      4,
      centerPaint,
    );

    // 绘制减弱的信号波纹（只有一层，且颜色较淡）
    final signalPaint = Paint()
      ..color = warningColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX + 20, centerY + 10), width: 30, height: 30),
      -0.8,
      1.6,
      false,
      signalPaint,
    );

    // 绘制感叹号
    final warningPaint = Paint()
      ..color = warningColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX + 25, centerY + 5),
      8,
      warningPaint,
    );

    final exclamationPaint = Paint()
      ..color = isDark ? Colors.grey[800]! : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(centerX + 25, centerY + 2),
      Offset(centerX + 25, centerY + 6),
      exclamationPaint,
    );

    // 绘制感叹号底部圆点
    canvas.drawCircle(
      Offset(centerX + 25, centerY + 8),
      1,
      exclamationPaint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter) => false;
}
