import 'package:flutter/material.dart';
import '../constants/design_system.dart';
import '../widgets/app_empty.dart';
import '../widgets/app_skeleton.dart';

/// ============================================
/// 空状态设计展示页
/// 
/// 用于展示所有空状态设计的参考页面
/// ============================================
class EmptyStateShowcase extends StatelessWidget {
  const EmptyStateShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('空状态设计展示'),
        backgroundColor: DesignSystem.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(context, '预设空状态'),
          const SizedBox(height: 16),
          
          // 网络错误
          _buildShowcaseCard(
            context,
            title: '无网络连接',
            child: AppEmpty.network(
              onRetry: () {},
              onOpenSettings: () {},
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 搜索为空
          _buildShowcaseCard(
            context,
            title: '无搜索结果',
            child: AppEmpty.search(
              keyword: '西湖',
              onClearFilter: () {},
              onBrowseRecommended: () {},
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 收藏为空
          _buildShowcaseCard(
            context,
            title: '收藏为空',
            child: AppEmpty.favorite(
              onExplore: () {},
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 下载为空
          _buildShowcaseCard(
            context,
            title: '下载列表为空',
            child: AppEmpty.download(
              onGoDownload: () {},
            ),
          ),
          
          const SizedBox(height: 16),
          
          // GPS信号弱
          _buildShowcaseCard(
            context,
            title: 'GPS信号弱',
            child: AppEmpty.location(
              onCheckSettings: () {},
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 权限请求
          _buildShowcaseCard(
            context,
            title: '权限请求',
            child: AppEmpty.permission(
              permissionName: '位置权限',
              permissionDescription: '开启位置权限后，才能使用导航和路线推荐功能',
              onRequestPermission: () {},
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 通用错误
          _buildShowcaseCard(
            context,
            title: '通用错误',
            child: AppEmpty.error(
              title: '加载失败',
              description: '请稍后重试',
              onRetry: () {},
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 无数据
          _buildShowcaseCard(
            context,
            title: '无数据',
            child: AppEmpty.data(
              title: '暂无数据',
              description: '数据加载中，请稍候',
              onRefresh: () {},
            ),
          ),
          
          const SizedBox(height: 32),
          
          _buildSectionTitle(context, '骨架屏'),
          const SizedBox(height: 16),
          
          // 骨架屏展示
          _buildShowcaseCard(
            context,
            title: '列表骨架屏',
            height: 300,
            child: const SkeletonList(
              itemCount: 3,
              itemHeight: 72,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildShowcaseCard(
            context,
            title: '发现页骨架屏',
            height: 400,
            child: const SkeletonDiscovery(),
          ),
          
          const SizedBox(height: 16),
          
          _buildShowcaseCard(
            context,
            title: '路线详情骨架屏',
            height: 400,
            child: const SkeletonTrailDetail(),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: DesignSystem.getTitleLarge(context, weight: FontWeight.w600),
    );
  }

  Widget _buildShowcaseCard(
    BuildContext context, {
    required String title,
    required Widget child,
    double? height,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: DesignSystem.getShadowLight(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: DesignSystem.getPrimary(context).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: DesignSystem.getPrimary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: DesignSystem.getTitleSmall(
                    context,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: height,
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
