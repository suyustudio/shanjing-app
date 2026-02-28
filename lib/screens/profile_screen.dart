import 'package:flutter/material.dart';
import '../constants/design_system.dart';
import '../widgets/app_app_bar.dart';

/// 我的页面
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: '我的',
      ),
      body: ListView(
        children: [
          // 用户信息区域
          _buildUserHeader(),
          const Divider(),
          // 设置入口列表
          _buildSettingsList(),
        ],
      ),
    );
  }

  /// 用户头像和昵称区域
  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
        children: [
          // 用户头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DesignSystem.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: DesignSystem.primary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          // 用户昵称
          const Text(
            '徒步爱好者',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingSmall),
          // 用户 ID
          const Text(
            '@hiker_001',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          // 编辑资料按钮
          OutlinedButton(
            onPressed: () {
              debugPrint('编辑资料 clicked');
            },
            child: const Text('编辑资料'),
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
          // 统计卡片
          _buildStatsCard(),
        ],
      ),
    );
  }

  /// 统计卡片
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignSystem.radius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 已走路线
          _StatItem(value: '12', label: '已走路线'),
          // 分隔线
          SizedBox(
            height: 40,
            child: VerticalDivider(width: 1),
          ),
          // 总里程
          _StatItem(value: '156.8', label: '总里程(km)'),
          // 分隔线
          SizedBox(
            height: 40,
            child: VerticalDivider(width: 1),
          ),
          // 总时长
          _StatItem(value: '48.5', label: '总时长(h)'),
        ],
      ),
    );
  }

  /// 设置入口列表
  Widget _buildSettingsList() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('设置'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('消息通知'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('帮助与反馈'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('关于我们'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}

/// 统计项组件
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DesignSystem.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: DesignSystem.fontSmall,
            color: DesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }
}
