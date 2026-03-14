import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// SOS 紧急求助按钮
/// 
/// 特性：
/// - 长按 3 秒触发（防止误触）
/// - 倒计时显示
/// - 发送状态反馈
class SOSButton extends StatefulWidget {
  final Future<void> Function()? onTriggered;
  final double size;

  const SOSButton({
    super.key,
    this.onTriggered,
    this.size = 64,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  bool _isPressing = false;
  bool _isSending = false;
  int _countdown = 3;

  Future<void>? _countdownFuture;

  void _onLongPressStart(LongPressStartDetails details) {
    if (_isSending) return;
    setState(() => _isPressing = true);
    _startCountdown();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_isSending) return;
    _cancelCountdown();
    setState(() {
      _isPressing = false;
      _countdown = 3;
    });
  }

  void _startCountdown() {
    _countdownFuture = Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isPressing) return false;
      
      setState(() => _countdown--);
      
      if (_countdown <= 0) {
        _triggerSos();
        return false;
      }
      return true;
    });
  }

  void _cancelCountdown() {
    _countdownFuture = null;
  }

  Future<void> _triggerSos() async {
    setState(() {
      _isPressing = false;
      _isSending = true;
      _countdown = 3;
    });

    try {
      await widget.onTriggered?.call();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isSending 
              ? DesignSystem.getSuccess(context)
              : DesignSystem.getError(context),
          boxShadow: [
            BoxShadow(
              color: DesignSystem.getError(context).withOpacity(_isPressing ? 0.6 : 0.3),
              blurRadius: _isPressing ? 16 : 8,
              spreadRadius: _isPressing ? 4 : 2,
            ),
          ],
        ),
        child: Center(
          child: _isSending
              ? const Icon(Icons.check, color: Colors.white, size: 32)
              : _isPressing
                  ? Text(
                      '$_countdown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Icon(
                      Icons.warning_amber,
                      color: Colors.white,
                      size: 28,
                    ),
        ),
      ),
    );
  }
}

/// SOS 状态提示
class SosStatusSnackBar {
  static void showSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('SOS 求助已发送'),
          ],
        ),
        backgroundColor: DesignSystem.getSuccess(context),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text('SOS 发送失败，请重试'),
          ],
        ),
        backgroundColor: DesignSystem.getError(context),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
