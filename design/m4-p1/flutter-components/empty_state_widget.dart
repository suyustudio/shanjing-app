import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 山径APP - 空状态组件库
/// 提供9种空状态场景的插画展示

/// 空状态类型枚举
enum EmptyStateType {
  noNetwork,
  noSearchResult,
  noFavorites,
  noHistory,
  mapLoadingFailed,
  locationFailed,
  offlineMapEmpty,
  noNotification,
  featureDevelopment,
}

/// 空状态配置数据
class EmptyStateConfig {
  final String illustrationAsset;
  final String title;
  final String? description;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  const EmptyStateConfig({
    required this.illustrationAsset,
    required this.title,
    this.description,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryTap,
    this.onSecondaryTap,
  });
}

/// 空状态插画组件
/// 
/// 使用示例:
/// ```dart
/// EmptyStateWidget(
///   type: EmptyStateType.noNetwork,
///   onPrimaryTap: () => retryConnection(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final double illustrationSize;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final bool useReducedMotion;

  const EmptyStateWidget({
    Key? key,
    required this.type,
    this.illustrationSize = 160,
    this.onPrimaryTap,
    this.onSecondaryTap,
    this.useReducedMotion = false,
  }) : super(key: key);

  EmptyStateConfig get _config {
    switch (type) {
      case EmptyStateType.noNetwork:
        return EmptyStateConfig(
          illustrationAsset: 'assets/illustrations/empty-no-network.svg',
          title: '网络信号似乎走失了',
          description: '请检查网络设置，或稍后再试',
          primaryButtonText: '重新加载',
          secondaryButtonText: '检查设置',
          onPrimaryTap: onPrimaryTap,
          onSecondaryTap: onSecondaryTap,
        );
      case EmptyStateType.noSearchResult:
        return EmptyStateConfig(
          illustrationAsset: 'assets/illustrations/empty-search-result.svg',
          title: '没有找到相关路线',
          description: '换个关键词试试，或浏览推荐路线',
          primaryButtonText: '查看推荐',
          onPrimaryTap: onPrimaryTap,
        );
      case EmptyStateType.noFavorites:
        return EmptyStateConfig(
          illustrationAsset: 'assets/illustrations/empty-favorites.svg',
          title: '还没有收藏',
          description: '收藏喜欢的路线，随时开启徒步之旅',
          primaryButtonText: '去发现路线',
          onPrimaryTap: onPrimaryTap,
        );
      case EmptyStateType.noHistory:
        return EmptyStateConfig(
          illustrationAsset: 'assets/illustrations/empty-history.svg',
          title: '还没有徒步记录',
          description: '开始你的第一次山野探索吧',
          primaryButtonText: '开始记录',
          onPrimaryTap: onPrimaryTap,
        );
      case EmptyStateType.mapLoadingFailed:
        return EmptyStateConfig(
          illustrationAsset: 'assets/illustrations/error-map-loading.svg',
          title: '地图加载失败了',
          description: '数据暂时迷路了，请检查网络后重试',
          primaryButtonText: '重新加载',
          secondaryButtonText: '返回首页',
          onPrimaryTap: onPrimaryTap,
          onSecondaryTap: onSecondaryTap,
        );
      case EmptyStateType.locationFailed:
        return EmptyStateConfig(
          illustrationAsset: 'assets/illustrations/error-location.svg',
          title: '定位服务暂时不可用',
          description: '请检查定位权限设置',
          primaryButtonText: '检查权限',
          secondaryButtonText: '手动选择',
          onPrimaryTap: onPrimaryTap,
          onSecondaryTap: onSecondaryTap,
        );
      case EmptyStateType.offlineMapEmpty:
        return EmptyStateConfig(
          illustrationAsset: 'assets/illustrations/empty-offline-map.svg',
          title: '暂无离线地图',
          description: '下载离线地图，无网络也能导航',
          primaryButtonText: '下载地图',
          onPrimaryTap: onPrimaryTap,
        );
      case EmptyStateType.noNotification:
        return EmptyStateConfig(
          illustrationAsset: 'assets/illustrations/empty-notification.svg',
          title: '还没有新消息',
          description: '山野静谧，去探索吧',
          primaryButtonText: '去探险',
          onPrimaryTap: onPrimaryTap,
        );
      case EmptyStateType.featureDevelopment:
        return EmptyStateConfig(
          illustrationAsset: 'assets/illustrations/feature-development.svg',
          title: '功能开发中',
          description: '我们正在努力搭建营地，敬请期待',
          primaryButtonText: '知道了',
          onPrimaryTap: onPrimaryTap,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: useReducedMotion ? Duration.zero : Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 插画区域
          _buildIllustration(config.illustrationAsset, isDark),
          SizedBox(height: 24),
          // 标题
          Text(
            config.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          // 描述
          if (config.description != null) ...[
            SizedBox(height: 8),
            Text(
              config.description!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          // 按钮区域
          if (config.primaryButtonText != null) ...[
            SizedBox(height: 24),
            _buildPrimaryButton(config),
          ],
          if (config.secondaryButtonText != null) ...[
            SizedBox(height: 12),
            _buildSecondaryButton(config),
          ],
        ],
      ),
    );
  }

  Widget _buildIllustration(String assetPath, bool isDark) {
    // 根据主题切换暗黑模式资源
    final darkAssetPath = assetPath.replaceAll('.svg', '_dark.svg');
    final actualPath = isDark ? darkAssetPath : assetPath;
    
    if (useReducedMotion) {
      // 减少动画模式：静态展示
      return SvgPicture.asset(
        actualPath,
        width: illustrationSize,
        height: illustrationSize,
        placeholderBuilder: (context) => _buildPlaceholder(),
      );
    }
    
    // 正常模式：带入场动画
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: SvgPicture.asset(
        actualPath,
        width: illustrationSize,
        height: illustrationSize,
        placeholderBuilder: (context) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: illustrationSize,
      height: illustrationSize,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildPrimaryButton(EmptyStateConfig config) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: config.onPrimaryTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2D968A),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          config.primaryButtonText!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(EmptyStateConfig config) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: config.onSecondaryTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF2D968A),
          padding: EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Color(0xFF2D968A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          config.secondaryButtonText!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// 空状态包装器 - 用于页面集成
class EmptyStateWrapper extends StatelessWidget {
  final bool isEmpty;
  final EmptyStateType type;
  final Widget child;
  final VoidCallback? onAction;

  const EmptyStateWrapper({
    Key? key,
    required this.isEmpty,
    required this.type,
    required this.child,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isEmpty) return child;
    
    return Center(
      child: SingleChildScrollView(
        child: EmptyStateWidget(
          type: type,
          onPrimaryTap: onAction,
        ),
      ),
    );
  }
}

/// 用于列表的空状态项
class EmptyStateListItem extends StatelessWidget {
  final EmptyStateType type;
  final double height;

  const EmptyStateListItem({
    Key? key,
    required this.type,
    this.height = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Center(
        child: EmptyStateWidget(
          type: type,
          illustrationSize: 120,
        ),
      ),
    );
  }
}
