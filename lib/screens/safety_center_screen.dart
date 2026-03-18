import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../constants/design_system.dart';
import '../widgets/app_app_bar.dart';

/// 安全中心页面
/// 包含：SOS紧急求助、位置分享(Lifeline)功能
class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  bool _isSendingSOS = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: '安全中心',
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignSystem.spacingLarge),
        children: [
          // SOS 区域
          _buildSOSSection(context),
          const SizedBox(height: DesignSystem.spacingLarge),
          // Lifeline 区域（未来扩展）
          _buildLifelineSection(context),
          const SizedBox(height: DesignSystem.spacingLarge),
          // 安全提示
          _buildSafetyTips(context),
        ],
      ),
    );
  }

  /// SOS 紧急求助区域
  Widget _buildSOSSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emergency,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          Text(
            '紧急求助',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingSmall),
          Text(
            '在紧急情况下，长按下方按钮 3 秒发送 SOS 信号，我们会记录您的位置并通知紧急联系人。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
          // SOS 按钮
          GestureDetector(
            onLongPressStart: (_) => _startSOSCountdown(),
            onLongPressEnd: (_) => _cancelSOSCountdown(),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: _isSendingSOS
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          Text(
            '长按 3 秒触发',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }

  /// Lifeline 位置分享区域（未来扩展）
  Widget _buildLifelineSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      decoration: BoxDecoration(
        color: DesignSystem.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignSystem.getDivider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.share_location,
                color: DesignSystem.getPrimary(context),
              ),
              const SizedBox(width: DesignSystem.spacingSmall),
              Text(
                '位置分享 (Lifeline)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.getTextPrimary(context),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '即将上线',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          Text(
            '出发徒步前，可以将您的实时位置分享给紧急联系人。如果您超过预定时间未返回，系统会自动通知联系人。',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          // 示意功能列表
          _buildFeatureItem(
            context,
            icon: Icons.people_outline,
            text: '选择最多 5 位紧急联系人',
          ),
          _buildFeatureItem(
            context,
            icon: Icons.timer_outlined,
            text: '设置预计完成时间',
          ),
          _buildFeatureItem(
            context,
            icon: Icons.location_on_outlined,
            text: '实时位置追踪分享',
          ),
          _buildFeatureItem(
            context,
            icon: Icons.notifications_active_outlined,
            text: '超时自动报警',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: DesignSystem.getTextTertiary(context),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 安全提示
  Widget _buildSafetyTips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 手机有信号时，优先使用系统紧急呼叫功能\n'
            '• 保持手机电量，建议携带充电宝\n'
            '• 出发前告知亲友您的行程计划\n'
            '• 恶劣天气避免单独徒步',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Timer? _sosTimer;

  /// 开始SOS倒计时
  void _startSOSCountdown() {
    setState(() => _isSendingSOS = true);
    
    _sosTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _showSOSConfirmation();
      }
    });
  }

  /// 取消SOS倒计时
  void _cancelSOSCountdown() {
    _sosTimer?.cancel();
    setState(() => _isSendingSOS = false);
  }

  /// 显示SOS确认弹窗
  void _showSOSConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('确认发送 SOS'),
          ],
        ),
        content: const Text(
          '您即将发送紧急求助信号。\n\n'
          '系统将：\n'
          '• 记录您当前位置\n'
          '• 通知您的紧急联系人\n'
          '• 保存救援所需信息\n\n'
          '请确认您确实处于紧急情况。',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isSendingSOS = false);
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认发送'),
          ),
        ],
      ),
    );
  }

  /// 发送SOS
  void _sendSOS() {
    // TODO: 接入真实SOS API
    // 1. 获取当前位置
    // 2. 调用后端API
    // 3. 通知紧急联系人
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS信号已发送！正在获取您的位置...'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
    
    setState(() => _isSendingSOS = false);
    
    // 模拟发送成功
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showSOSSuccessDialog();
      }
    });
  }

  /// 显示SOS发送成功
  void _showSOSSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('SOS已发送'),
        content: const Text(
          '您的紧急求助信号已成功发送。\n\n'
          '• 紧急联系人已收到通知\n'
          '• 您的位置已被记录\n'
          '• 请保持手机畅通\n\n'
          '如情况允许，请尝试移动到更开阔的地带以获得更好的信号。',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    super.dispose();
  }
}
