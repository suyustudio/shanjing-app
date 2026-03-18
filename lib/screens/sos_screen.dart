import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/design_system.dart';
import '../../providers/lifeline_provider.dart';

/// SOS页面
/// 完整的SOS触发流程：长按→确认→发送
class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with TickerProviderStateMixin {
  // 页面状态
  SOSState _currentState = SOSState.initial;
  
  // 长按倒计时
  double _longPressProgress = 0.0;
  Timer? _longPressTimer;
  static const int _longPressDurationSeconds = 5;
  
  // 确认倒计时
  int _confirmCountdown = 10;
  Timer? _confirmTimer;
  
  // 滑动确认
  double _slideProgress = 0.0;
  
  // 动画控制器
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _confirmTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentState == SOSState.sending || _currentState == SOSState.success) {
          return false;
        }
        if (_currentState != SOSState.initial) {
          _resetState();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: _getBackgroundColor(),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentState(),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_currentState) {
      case SOSState.initial:
        return Colors.white;
      case SOSState.counting:
      case SOSState.confirming:
      case SOSState.sending:
        return const Color(0xFF1A1A2E); // 深色背景
      case SOSState.success:
        return Colors.green.shade50;
    }
  }

  Widget _buildCurrentState() {
    switch (_currentState) {
      case SOSState.initial:
        return _buildInitialState();
      case SOSState.counting:
        return _buildCountingState();
      case SOSState.confirming:
        return _buildConfirmingState();
      case SOSState.sending:
        return _buildSendingState();
      case SOSState.success:
        return _buildSuccessState();
    }
  }

  // ========== 初始状态 ==========
  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
        children: [
          // 返回按钮
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          const Spacer(),
          // 警告图标
          Icon(
            Icons.warning_amber,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
          // 标题
          Text(
            '紧急求助',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingSmall),
          // 说明
          Text(
            '请仅在真正紧急的情况下使用此功能\n系统将向您的紧急联系人发送求救信息',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const Spacer(),
          // SOS按钮
          _buildSOSButton(),
          const SizedBox(height: DesignSystem.spacingLarge),
          // 提示
          Text(
            '长按5秒触发',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          // 重要提示
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '如遇生命危险，请直接拨打 110/120',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startLongPress(),
      onLongPressEnd: (_) => _cancelLongPress(),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade400,
                  Colors.red.shade700,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3 + (_pulseController.value * 0.2)),
                  blurRadius: 20 + (_pulseController.value * 10),
                  spreadRadius: 5 + (_pulseController.value * 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ========== 长按倒计时状态 ==========
  Widget _buildCountingState() {
    final remainingSeconds = (_longPressProgress * _longPressDurationSeconds).ceil();
    
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 倒计时圆环
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 背景圆环
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 8,
                  color: Colors.white.withOpacity(0.2),
                ),
                // 进度圆环
                CircularProgressIndicator(
                  value: _longPressProgress,
                  strokeWidth: 8,
                  color: Colors.red,
                ),
                // 中心文字
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_longPressDurationSeconds',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '秒后发送',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          // 松开取消提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              '松开手指取消',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== 确认状态 ==========
  Widget _buildConfirmingState() {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
        children: [
          const Spacer(),
          // 警告图标
          Icon(
            Icons.warning_amber,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 24),
          // 标题
          const Text(
            '即将发送SOS信号',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // 说明
          Text(
            '系统将：\n• 获取您当前精确位置\n• 通知您的紧急联系人\n• 记录救援所需信息',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.8),
              height: 1.8,
            ),
          ),
          const Spacer(),
          // 倒计时
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_confirmCountdown 秒后自动发送',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 滑动确认
          _buildSlideToConfirm(),
          const SizedBox(height: 16),
          // 取消按钮
          TextButton(
            onPressed: _resetState,
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
        ],
      ),
    );
  }

  Widget _buildSlideToConfirm() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _slideProgress += details.delta.dx / 300;
          _slideProgress = _slideProgress.clamp(0.0, 1.0);
        });
      },
      onHorizontalDragEnd: (_) {
        if (_slideProgress >= 0.9) {
          _sendSOS();
        } else {
          setState(() {
            _slideProgress = 0.0;
          });
        }
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            // 背景文字
            Center(
              child: Opacity(
                opacity: 1 - _slideProgress,
                child: const Text(
                  '滑动立即发送 →',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // 滑块
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: EdgeInsets.only(
                left: _slideProgress * (MediaQuery.of(context).size.width - 80 - 64),
              ),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== 发送中状态 ==========
  Widget _buildSendingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: Colors.red,
              strokeWidth: 6,
            ),
          ),
          SizedBox(height: 32),
          Text(
            '正在发送SOS信号...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '请保持手机畅通',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ========== 成功状态 ==========
  Widget _buildSuccessState() {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
        children: [
          const Spacer(),
          // 成功图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 64,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 32),
          // 标题
          Text(
            'SOS已发送成功',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 16),
          // 说明
          Text(
            '• 紧急联系人已收到通知\n'
            '• 您的位置已共享\n'
            '• 请保持手机电量充足',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.8,
            ),
          ),
          const Spacer(),
          // 位置更新提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: DesignSystem.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '持续更新位置中',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: DesignSystem.getTextPrimary(context),
                        ),
                      ),
                      Text(
                        '系统将每5分钟更新一次位置',
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignSystem.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 返回按钮
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '我知道了',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
        ],
      ),
    );
  }

  // ========== 状态切换方法 ==========
  void _startLongPress() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentState = SOSState.counting;
      _longPressProgress = 0.0;
    });

    // 每秒更新进度
    const updateInterval = Duration(milliseconds: 50);
    final totalUpdates = (_longPressDurationSeconds * 1000) ~/ updateInterval.inMilliseconds;
    var currentUpdate = 0;

    _longPressTimer = Timer.periodic(updateInterval, (timer) {
      currentUpdate++;
      setState(() {
        _longPressProgress = currentUpdate / totalUpdates;
      });

      // 每秒震动一次
      if (currentUpdate % (1000 ~/ updateInterval.inMilliseconds) == 0) {
        HapticFeedback.lightImpact();
      }

      if (currentUpdate >= totalUpdates) {
        timer.cancel();
        _enterConfirmState();
      }
    });
  }

  void _cancelLongPress() {
    _longPressTimer?.cancel();
    if (_currentState == SOSState.counting) {
      _resetState();
    }
  }

  void _enterConfirmState() {
    HapticFeedback.heavyImpact();
    setState(() {
      _currentState = SOSState.confirming;
      _confirmCountdown = 10;
      _slideProgress = 0.0;
    });

    // 开始确认倒计时
    _confirmTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _confirmCountdown--;
      });

      if (_confirmCountdown <= 0) {
        timer.cancel();
        _sendSOS();
      }
    });
  }

  Future<void> _sendSOS() async {
    _confirmTimer?.cancel();
    
    setState(() {
      _currentState = SOSState.sending;
    });

    // 调用服务发送SOS
    final provider = context.read<LifelineProvider>();
    final success = await provider.sendSOS();

    if (success && mounted) {
      setState(() {
        _currentState = SOSState.success;
      });
    } else if (mounted) {
      // 发送失败，返回初始状态
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('发送失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
      _resetState();
    }
  }

  void _resetState() {
    _longPressTimer?.cancel();
    _confirmTimer?.cancel();
    setState(() {
      _currentState = SOSState.initial;
      _longPressProgress = 0.0;
      _confirmCountdown = 10;
      _slideProgress = 0.0;
    });
  }
}

/// SOS状态枚举
enum SOSState {
  initial,    // 初始状态
  counting,   // 长按倒计时中
  confirming, // 确认界面
  sending,    // 发送中
  success,    // 发送成功
}
