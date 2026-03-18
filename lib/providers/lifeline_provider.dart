import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/lifeline_session.dart';
import '../services/lifeline_service.dart';

/// Lifeline状态管理
class LifelineProvider extends ChangeNotifier {
  final LifelineService _service = LifelineService();
  
  LifelineSession? _currentSession;
  bool _isLoading = false;
  String? _error;
  
  // 实时倒计时
  TimerNotifier? _timerNotifier;

  // Getters
  LifelineSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isActive => _currentSession?.isActive ?? false;
  bool get isOverdue => _currentSession?.status == LifelineStatus.overdue;

  /// 初始化并加载当前会话
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    try {
      await _service.initialize();
      _currentSession = await _service.getCurrentSession();
      
      // 设置回调
      _service.onSessionUpdate = (session) {
        _currentSession = session;
        notifyListeners();
      };
      
      _service.onAlarm = (type) {
        // 报警通知
        notifyListeners();
      };

      // 如果有活跃会话，启动倒计时
      if (_currentSession?.isActive ?? false) {
        _startTimer();
      }
    } catch (e) {
      _setError('初始化失败: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 启动Lifeline
  Future<bool> startLifeline({
    required List<String> contactIds,
    required int estimatedDurationMinutes,
    required int bufferTimeMinutes,
    String? routeId,
    String? routeName,
  }) async {
    if (contactIds.isEmpty) {
      _setError('请至少选择一位紧急联系人');
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final session = await _service.startLifeline(
        contactIds: contactIds,
        estimatedDurationMinutes: estimatedDurationMinutes,
        bufferTimeMinutes: bufferTimeMinutes,
        routeId: routeId,
        routeName: routeName,
      );

      if (session != null) {
        _currentSession = session;
        _startTimer();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('启动失败');
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError('启动Lifeline失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 停止Lifeline（正常完成）
  Future<bool> stopLifeline() async {
    _setLoading(true);
    _clearError();

    try {
      await _service.stopLifeline(completed: true);
      _currentSession = await _service.getCurrentSession();
      _stopTimer();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('停止Lifeline失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 取消Lifeline
  Future<bool> cancelLifeline() async {
    _setLoading(true);
    _clearError();

    try {
      await _service.stopLifeline(completed: false);
      _currentSession = await _service.getCurrentSession();
      _stopTimer();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('取消Lifeline失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 延长预计时间
  Future<bool> extendTime(int additionalMinutes) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _service.extendEstimatedTime(additionalMinutes);
      if (success) {
        _currentSession = await _service.getCurrentSession();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('延长失败');
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError('延长失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 刷新状态
  Future<void> refresh() async {
    _currentSession = await _service.getCurrentSession();
    notifyListeners();
  }

  /// 手动发送报警
  Future<bool> sendAlarm({String? message}) async {
    _setLoading(true);
    try {
      final success = await _service.sendAlarm(customMessage: message);
      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('发送报警失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 发送SOS
  Future<bool> sendSOS({String? note}) async {
    _setLoading(true);
    try {
      final success = await _service.sendSOS(note: note);
      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('发送SOS失败: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// 获取剩余时间（倒计时）
  Duration? get remainingTime {
    if (_currentSession == null || !_currentSession!.isActive) return null;
    return _currentSession!.timeUntilEstimatedEnd;
  }

  /// 获取格式化的剩余时间
  String get formattedRemainingTime {
    final time = remainingTime;
    if (time == null) return '--:--';
    
    final hours = time.inHours;
    final minutes = time.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:00';
    }
  }

  /// 获取预计返回时间字符串
  String? get estimatedReturnTimeString {
    final time = _currentSession?.estimatedEndTime;
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 检查是否即将超时（剩余时间少于15分钟）
  bool get isAboutToTimeout {
    final time = remainingTime;
    if (time == null) return false;
    return time.inMinutes <= 15;
  }

  /// 清空错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 释放资源
  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String message) {
    _error = message;
  }

  void _clearError() {
    _error = null;
  }

  void _startTimer() {
    _timerNotifier?.dispose();
    _timerNotifier = TimerNotifier(() {
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timerNotifier?.dispose();
    _timerNotifier = null;
  }
}

/// 简单的计时器通知器
class TimerNotifier {
  late final Timer _timer;

  TimerNotifier(VoidCallback onTick) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      onTick();
    });
  }

  void dispose() {
    _timer.cancel();
  }
}
