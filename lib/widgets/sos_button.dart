import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/design_system.dart';

/// SOS 紧急求助按钮
/// 
/// 特性：
/// - 呼吸动画效果
/// - 红色醒目设计
/// - 点击触发倒计时
class SOSButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;

  const SOSButton({
    super.key,
    required this.onPressed,
    this.size = 72,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        // 呼吸效果计算
        final value = _breathingController.value;
        final sinValue = math.sin(value * 2 * math.pi);
        
        // 阴影参数
        final shadowOpacity = 0.5 + 0.2 * sinValue;
        final shadowBlur = 20 + 10 * sinValue;
        final spreadRadius = 2 + 2 * sinValue;
        
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.95 : 1.0),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isPressed 
                    ? DesignSystem.getError(context).withOpacity(0.9)
                    : DesignSystem.getError(context),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignSystem.getError(context).withOpacity(shadowOpacity),
                    blurRadius: shadowBlur,
                    spreadRadius: spreadRadius,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emergency,
                      color: Colors.white,
                      size: widget.size * 0.35,
                    ),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.size * 0.18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// SOS 倒计时确认页面
/// 
/// 5秒倒计时，用户可取消
class SOSCountdownScreen extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SOSCountdownScreen({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<SOSCountdownScreen> createState() => _SOSCountdownScreenState();
}

class _SOSCountdownScreenState extends State<SOSCountdownScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _countdown = 5;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onConfirm();
      }
    });
    
    // 每秒更新倒计时数字
    _startCountdownTimer();
  }
  
  void _startCountdownTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        return _countdown > 0;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 警告图标
              _buildWarningIcon(),
              
              const SizedBox(height: 32),
              
              // 标题
              Text(
                '即将发送 SOS 求助信息',
                style: DesignSystem.getTitleLarge(
                  context,
                  weight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // 说明文字
              Text(
                '我们将向您的紧急联系人发送当前位置和求助信息',
                style: DesignSystem.getBodyLarge(
                  context,
                  color: DesignSystem.getTextSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // 倒计时
              _buildCountdown(),
              
              const SizedBox(height: 48),
              
              // 说明
              Text(
                '倒计时结束后自动发送，点击下方按钮可取消',
                style: DesignSystem.getBodyMedium(
                  context,
                  color: DesignSystem.getTextTertiary(context),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // 取消按钮
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: DesignSystem.getWarning(context).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.warning_amber_rounded,
        size: 64,
        color: DesignSystem.getWarning(context),
      ),
    );
  }

  Widget _buildCountdown() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 背景圆环
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                backgroundColor: DesignSystem.getDivider(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  DesignSystem.getDivider(context),
                ),
              ),
            ),
            // 进度圆环
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: _controller.value,
                strokeWidth: 8,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DesignSystem.getError(context),
                ),
              ),
            ),
            // 数字
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: _countdown <= 3 ? 56 : 48,
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.getError(context),
                  ),
                  child: Text('$_countdown'),
                ),
                Text(
                  '秒',
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignSystem.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.onCancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignSystem.getBackgroundSecondary(context),
          foregroundColor: DesignSystem.getTextPrimary(context),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '取消',
          style: DesignSystem.getBodyLarge(
            context,
            weight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// SOS 发送成功页面
class SOSSuccessScreen extends StatelessWidget {
  final List<Map<String, String>> contacts;
  final String location;
  final String time;
  final VoidCallback onBackToNavigation;
  final VoidCallback onCallEmergency;

  const SOSSuccessScreen({
    super.key,
    required this.contacts,
    required this.location,
    required this.time,
    required this.onBackToNavigation,
    required this.onCallEmergency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // 成功图标
              _buildSuccessIcon(),
              
              const SizedBox(height: 32),
              
              // 标题
              Text(
                '求助信息已发送',
                style: DesignSystem.getTitleLarge(
                  context,
                  weight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // 联系人列表
              _buildContactsCard(context),
              
              const SizedBox(height: 16),
              
              // 位置信息
              _buildLocationInfo(context),
              
              const SizedBox(height: 16),
              
              // 时间
              _buildTimeInfo(context),
              
              const Spacer(),
              
              // 返回导航按钮
              _buildBackButton(context),
              
              const SizedBox(height: 12),
              
              // 拨打紧急电话按钮
              _buildEmergencyCallButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: DesignSystem.getSuccess(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 64,
              color: DesignSystem.getSuccess(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '已发送给以下联系人：',
            style: DesignSystem.getBodyMedium(
              context,
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          ...contacts.map((contact) => _buildContactItem(context, contact)),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, Map<String, String> contact) {
    final name = contact['name'] ?? '';
    final phone = contact['phone'] ?? '';
    final maskedPhone = _maskPhone(phone);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.phone_android,
            size: 18,
            color: DesignSystem.getPrimary(context),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: DesignSystem.getBodyMedium(context),
          ),
          const SizedBox(width: 8),
          Text(
            maskedPhone,
            style: DesignSystem.getBodySmall(
              context,
              color: DesignSystem.getTextTertiary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 18,
          color: DesignSystem.getPrimary(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '当前位置：$location',
            style: DesignSystem.getBodyMedium(
              context,
              color: DesignSystem.getTextSecondary(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 18,
          color: DesignSystem.getTextTertiary(context),
        ),
        const SizedBox(width: 8),
        Text(
          '发送时间：$time',
          style: DesignSystem.getBodySmall(
            context,
            color: DesignSystem.getTextTertiary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onBackToNavigation,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignSystem.getPrimary(context),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '返回导航',
          style: DesignSystem.getBodyLarge(
            context,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCallButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onCallEmergency,
        icon: const Icon(Icons.phone, size: 20),
        label: const Text('拨打紧急电话'),
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignSystem.getError(context),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }
}

/// SOS 完整流程组件
class SOSFlow {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SOSCountdownScreen(
        onConfirm: _handleSOSConfirm,
        onCancel: _handleSOSCancel,
      ),
    );
  }

  static void _handleSOSConfirm() {
    // 实际发送SOS逻辑
    debugPrint('SOS sent');
  }

  static void _handleSOSCancel() {
    // 取消SOS
    debugPrint('SOS cancelled');
  }
}
