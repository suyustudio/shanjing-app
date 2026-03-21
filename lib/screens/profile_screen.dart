import 'package:flutter/material.dart';
import '../analytics/analytics.dart';
import '../constants/design_system.dart';
import '../widgets/app_app_bar.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'safety_center_screen.dart';
import 'recordings_list_screen.dart';
import 'recording_qualification_screen.dart';

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

  // 登录状态
  bool _isLoggedIn = false;
  String _userName = '游客';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// 检查登录状态
  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthService.checkLoginStatus();
    final userInfo = await AuthService.getUserInfo();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _userName = userInfo['name'] ?? '游客';
      _userId = userInfo['id'] ?? '';
    });
  }

  /// 跳转到登录页
  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    ).then((_) => _checkLoginStatus()); // 返回后刷新登录状态
  }

  /// 跳转到安全中心
  void _goToSafetyCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SafetyCenterScreen()),
    );
  }

  /// 跳转到我的采集
  void _goToMyRecordings() {
    // 检查登录状态
    if (!_isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }
    
    // 检查采集资格（模拟）
    final hasQualification = true; // 实际应该从服务获取
    
    if (!hasQualification) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecordingQualificationScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecordingsListScreen()),
      );
    }
  }

  /// 显示需要登录的对话框
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('需要登录', style: DesignSystem.getTitleLarge(context)),
        content: Text(
          '请先登录后再使用采集功能',
          style: DesignSystem.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _goToLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getPrimary(context),
              foregroundColor: DesignSystem.textInverse,
            ),
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }

  /// 退出登录
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logoutStatic();
              _checkLoginStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已退出登录')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

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
          // 用户头像（可点击登录）
          GestureDetector(
            onTap: _isLoggedIn ? null : _goToLogin,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DesignSystem.getPrimary(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isLoggedIn ? Icons.person : Icons.person_outline,
                size: 40,
                color: DesignSystem.getPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          // 用户昵称
          Text(
            _userName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DesignSystem.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingSmall),
          // 用户 ID 或登录提示
          Text(
            _isLoggedIn 
              ? (_userId.isNotEmpty ? '@$_userId' : '')
              : '点击头像登录',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          // 登录/编辑资料按钮
          if (!_isLoggedIn)
            ElevatedButton(
              onPressed: _goToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.getPrimary(context),
                foregroundColor: Colors.white,
              ),
              child: const Text('立即登录'),
            )
          else
            OutlinedButton(
              onPressed: () {
                debugPrint('编辑资料 clicked');
              },
              child: const Text('编辑资料'),
            ),
          const SizedBox(height: DesignSystem.spacingLarge),
          // 统计卡片（仅登录显示）
          if (_isLoggedIn) _buildStatsCard(context),
          const SizedBox(height: DesignSystem.spacingLarge),
          // 紧急采集入口（下周三上海采集用）
          if (_isLoggedIn) _buildEmergencyRecordingCard(context),
        ],
      ),
    );
  }

  /// 紧急采集入口卡片
  Widget _buildEmergencyRecordingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingMedium),
      decoration: BoxDecoration(
        color: DesignSystem.getPrimary(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radius),
        border: Border.all(
          color: DesignSystem.getPrimary(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.emergency_recording,
                color: DesignSystem.getPrimary(context),
                size: 24,
              ),
              const SizedBox(width: DesignSystem.spacingMedium),
              Expanded(
                child: Text(
                  '紧急采集入口（上海采集用）',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.getTextPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          Text(
            '下周三上海采集数据使用。跳过审核流程，直接开始录制。',
            style: TextStyle(
              fontSize: 13,
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          ElevatedButton(
            onPressed: () {
              // 直接跳转到录制页面，跳过所有检查
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecordingScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getPrimary(context),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radius),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, size: 20),
                SizedBox(width: 8),
                Text('开始采集', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
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
        // 我的采集（新增）
        ListTile(
          leading: Icon(
            Icons.videocam,
            color: DesignSystem.getPrimary(context),
          ),
          title: Text(
            '我的采集',
            style: TextStyle(
              color: DesignSystem.getTextPrimary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '管理和提交录制的路线',
            style: TextStyle(
              fontSize: 12,
              color: DesignSystem.getTextTertiary(context),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: DesignSystem.getTextTertiary(context),
          ),
          onTap: _goToMyRecordings,
        ),
        Divider(color: DesignSystem.getDivider(context)),
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
        // SOS安全中心
        ListTile(
          leading: Icon(
            Icons.emergency,
            color: Colors.red.shade400,
          ),
          title: Text(
            '安全中心',
            style: TextStyle(
              color: DesignSystem.getTextPrimary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '紧急求助 & 位置分享',
            style: TextStyle(
              fontSize: 12,
              color: DesignSystem.getTextTertiary(context),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: DesignSystem.getTextTertiary(context),
          ),
          onTap: _goToSafetyCenter,
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
        // 退出登录（仅登录显示）
        if (_isLoggedIn) ...[
          Divider(color: DesignSystem.getDivider(context)),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              '退出登录',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
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
