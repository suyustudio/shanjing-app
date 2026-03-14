import 'package:flutter/material.dart';
import '../analytics/analytics.dart';
import '../constants/design_system.dart';
import '../widgets/app_app_bar.dart';

/// 我的页面
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AnalyticsMixin {
  // 埋点相关
  @override
  String get pageId => PageEvents.pageProfile;

  @override
  String get pageName => PageEvents.nameProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: '我的',
      ),
      body: ListView(
        children: [
          // 用户信息区域
          _buildUserHeader(context),
          Divider(color: DesignSystem.getDivider(context)),
          // 设置入口列表
          _buildSettingsList(context),
        ],
      ),
    );
  }

  /// 用户头像和昵称区域
  Widget _buildUserHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
        children: [
          // 用户头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DesignSystem.getPrimary(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: DesignSystem.getPrimary(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          // 用户昵称
          Text(
            '徒步爱好者',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignSystem.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingSmall),
          // 用户 ID
          Text(
            '@hiker_001',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.getTextSecondary(context),
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
          _buildStatsCard(context),
        ],
      ),
    );
  }

  /// 统计卡片
  Widget _buildStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingMedium),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(DesignSystem.radius),
        boxShadow: DesignSystem.getShadowLight(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 已走路线
          _StatItem(value: '12', label: '已走路线'),
          // 分隔线
          SizedBox(
            height: 40,
            child: VerticalDivider(
              width: 1,
              color: DesignSystem.getDivider(context),
            ),
          ),
          // 总里程
          _StatItem(value: '156.8', label: '总里程(km)'),
          // 分隔线
          SizedBox(
            height: 40,
            child: VerticalDivider(
              width: 1,
              color: DesignSystem.getDivider(context),
            ),
          ),
          // 总时长
          _StatItem(value: '48.5', label: '总时长(h)'),
        ],
      ),
    );
  }

  /// 设置入口列表
  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.settings,
            color: DesignSystem.getTextSecondary(context),
          ),
          title: Text(
            '设置',
            style: TextStyle(color: DesignSystem.getTextPrimary(context)),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: DesignSystem.getTextTertiary(context),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.notifications,
            color: DesignSystem.getTextSecondary(context),
          ),
          title: Text(
            '消息通知',
            style: TextStyle(color: DesignSystem.getTextPrimary(context)),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: DesignSystem.getTextTertiary(context),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.help_outline,
            color: DesignSystem.getTextSecondary(context),
          ),
          title: Text(
            '帮助与反馈',
            style: TextStyle(color: DesignSystem.getTextPrimary(context)),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: DesignSystem.getTextTertiary(context),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.info_outline,
            color: DesignSystem.getTextSecondary(context),
          ),
          title: Text(
            '关于我们',
            style: TextStyle(color: DesignSystem.getTextPrimary(context)),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: DesignSystem.getTextTertiary(context),
          ),
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DesignSystem.getPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: DesignSystem.fontSmall,
            color: DesignSystem.getTextSecondary(context),
          ),
        ),
      ],
    );
  }
}
