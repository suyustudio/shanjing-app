import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/design_system.dart';
import '../../services/sos_service_enhanced.dart';
import '../../analytics/analytics.dart';
import '../../analytics/events/sos_events.dart';

/// SOS页面（增强版）
/// 
/// 功能特性：
/// - 5秒倒计时确认流程（倒计时期间可取消）
/// - 弱网/无信号场景降级处理
/// - 显示发送进度和重试状态
class SOSScreenEnhanced extends StatefulWidget {
  final String? routeId;
  final String? routeName;
  
  const SOSScreenEnhanced({
    super.key,
    this.routeId,
    this.routeName,
  });

  @override
  State<SOSScreenEnhanced> createState() => _SOSScreenEnhancedState();
}

class _SOSScreenEnhancedState extends State<SOSScreenEnhanced>
    with TickerProviderStateMixin {
  final SosService _sosService = SosService();

  // 页面状态
  SOSUIState _currentState = SOSUIState.initial;
  
  // 倒计时相关
  static const int _countdownDuration = 5; // 5秒倒计时
  int _countdownRemaining = _countdownDuration;
  Timer? _countdownTimer;
  
  // 动画控制器
  late AnimationController _pulseController;
  late AnimationController _countdownAnimationController;
  
  // 发送状态
  int _retryCount = 0;
  String _statusMessage = '';
  SOSSendStatus? _sendResult;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _countdownAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _countdownDuration),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _countdownAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
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

  Future<bool> _onWillPop() async {
    if (_currentState == SOSUIState.sending || _currentState == SOSUIState.success) {
      return false;
    }
    if (_currentState == SOSUIState.countdown) {
      _cancelCountdown();
      return false;
    }
    return true;
  }

  Color _getBackgroundColor() {
    switch (_currentState) {
      case SOSUIState.initial:
        return Colors.white;
      case SOSUIState.countdown:
      case SOSUIState.sending:
      case SOSUIState.failed:
        return const Color(0xFF1A1A2E); // 深色背景
      case SOSUIState.success:
        return const Color(0xFFF0FFF4); // 浅绿色
    }
  }

  Widget _buildCurrentState() {
    switch (_currentState) {
      case SOSUIState.initial:
        return _buildInitialState();
      case SOSUIState.countdown:
        return _buildCountdownState();
      case SOSUIState.sending:
        return _buildSendingState();
      case SOSUIState.success:
        return _buildSuccessState();
      case SOSUIState.failed:
        return _buildFailedState();
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
            Icons.warning_amber_rounded,
            size: 80,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
          // 标题
          Text(
            '紧急求助',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: DesignSystem.spacingMedium),
          // 说明
          Text(
            '请仅在真正紧急的情况下使用此功能\n系统将向您的紧急联系人发送求救信息',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
          const Spacer(),
          // SOS按钮
          _buildSOSButton(),
          const SizedBox(height: DesignSystem.spacingXLarge),
          // 重要提示
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '如遇生命危险，请直接拨打 110/120',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
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
      onTap: _startCountdown,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 180,
            height: 180,
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
                  blurRadius: 30 + (_pulseController.value * 15),
                  spreadRadius: 8 + (_pulseController.value * 8),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '点击触发',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ========== 倒计时状态 ==========
  Widget _buildCountdownState() {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // 倒计时标题
          Text(
            '即将发送求救信号',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_countdownRemaining}秒后将自动发送',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 60),
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
                  strokeWidth: 12,
                  color: Colors.white.withOpacity(0.1),
                ),
                // 进度圆环
                AnimatedBuilder(
                  animation: _countdownAnimationController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: 1 - _countdownAnimationController.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.red.shade400,
                      ),
                    );
                  },
                ),
                // 中心倒计时
                Center(
                  child: Text(
                    '$_countdownRemaining',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          // 立即发送按钮
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _sendSOSImmediately,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                '立即发送',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 取消按钮
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: _cancelCountdown,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '取消',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // ========== 发送中状态 ==========
  Widget _buildSendingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: Colors.red,
              strokeWidth: 6,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '正在发送求救信号...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          if (_retryCount > 0) ...[
            const SizedBox(height: 16),
            Text(
              '网络不稳定，正在重试 ($_retryCount/${SOSRetryConfig.maxRetries})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade300,
              ),
            ),
          ],
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  '正在获取精确位置',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
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
            '求救信号已发送',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 12),
          // 副标题
          Text(
            '紧急联系人将收到您的位置信息',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          // 状态信息
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildStatusRow(
                  icon: Icons.people,
                  title: '紧急联系人',
                  value: '已通知',
                  color: Colors.green,
                ),
                const Divider(height: 24),
                _buildStatusRow(
                  icon: Icons.location_on,
                  title: '当前位置',
                  value: '已共享',
                  color: Colors.green,
                ),
                if (_sendResult?.retryCount != null) ...[
                  const Divider(height: 24),
                  _buildStatusRow(
                    icon: Icons.network_check,
                    title: '发送状态',
                    value: '重试${_sendResult!.retryCount}次后成功',
                    color: Colors.orange,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '请保持手机电量充足，系统将每5分钟更新一次位置',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                    ),
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
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '知道了',
                style: TextStyle(
                  fontSize: 18,
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

  // ========== 失败/降级状态 ==========
  Widget _buildFailedState() {
    final isSavedLocal = _sendResult?.result == SOSSendResult.savedLocal ||
                         _sendResult?.result == SOSSendResult.weakNetwork;
    
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingLarge),
      child: Column(
        children: [
          const Spacer(),
          // 状态图标
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isSavedLocal ? Colors.orange.shade100 : Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSavedLocal ? Icons.save : Icons.error_outline,
              size: 56,
              color: isSavedLocal ? Colors.orange.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 32),
          // 标题
          Text(
            isSavedLocal ? '求救信息已保存' : '发送失败',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isSavedLocal ? Colors.orange.shade800 : Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 16),
          // 说明
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                height: 1.6,
              ),
            ),
          ),
          const Spacer(),
          // 操作按钮
          if (isSavedLocal) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // 提示用户如何操作
                  _showOfflineModeHelp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '了解离线模式',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _retrySendSOS,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '重试发送',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // 取消按钮
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('返回', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingLarge),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ========== 业务逻辑 ==========
  void _startCountdown() {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _currentState = SOSUIState.countdown;
      _countdownRemaining = _countdownDuration;
    });

    // 启动动画
    _countdownAnimationController.reset();
    _countdownAnimationController.forward();

    // 每秒更新倒计时
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownRemaining--;
      });

      // 震动反馈（最后3秒加强）
      if (_countdownRemaining <= 3 && _countdownRemaining > 0) {
        HapticFeedback.heavyImpact();
      }

      if (_countdownRemaining <= 0) {
        timer.cancel();
        _sendSOS(triggerType: 'auto');
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownAnimationController.stop();
    
    // 埋点：取消SOS
    _sosService.trackCancel(
      cancelStage: 'countdown',
      countdownRemainingSec: _countdownRemaining,
      routeId: widget.routeId,
    );
    
    setState(() {
      _currentState = SOSUIState.initial;
      _countdownRemaining = _countdownDuration;
    });
  }

  void _sendSOSImmediately() {
    _countdownTimer?.cancel();
    _countdownAnimationController.stop();
    _sendSOS(triggerType: 'manual');
  }

  Future<void> _sendSOS({required String triggerType}) async {
    setState(() {
      _currentState = SOSUIState.sending;
      _retryCount = 0;
    });

    // 获取当前位置（模拟）
    final location = Location(
      latitude: 30.2741,
      longitude: 120.1551,
      accuracy: 8.5,
    );

    // 调用SOS服务
    final result = await _sosService.triggerSos(
      location: location,
      triggerType: triggerType,
      countdownRemainingSec: _countdownRemaining,
      routeId: widget.routeId,
      sendMethod: 'both',
      enableRetry: true,
    );

    if (!mounted) return;

    setState(() {
      _sendResult = result;
      _statusMessage = result.message;
      
      if (result.result == SOSSendResult.success) {
        _currentState = SOSUIState.success;
        _retryCount = result.retryCount ?? 0;
      } else if (result.result == SOSSendResult.savedLocal ||
                 result.result == SOSSendResult.weakNetwork) {
        // 弱网/无信号场景：降级处理
        _currentState = SOSUIState.failed;
      } else {
        _currentState = SOSUIState.failed;
      }
    });
  }

  void _retrySendSOS() {
    _sendSOS(triggerType: 'manual');
  }

  void _showOfflineModeHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('离线求救模式'),
        content: const Text(
          '当您处于无信号区域时，求救信息会自动保存到本地。\n\n'
          '当手机恢复网络连接后：\n'
          '1. 应用会自动尝试重新发送\n'
          '2. 建议您移动到信号较好的位置\n'
          '3. 也可以手动拨打紧急电话'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

/// SOS UI 状态枚举
enum SOSUIState {
  initial,    // 初始状态
  countdown,  // 倒计时中
  sending,    // 发送中
  success,    // 发送成功
  failed,     // 发送失败/降级
}
