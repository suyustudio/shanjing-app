import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 音量键服务
/// 监听音量下键连按3次触发SOS
/// 
/// 注意：这是一个模拟实现，因为Flutter无法直接监听硬件音量键
/// 实际实现需要使用原生代码（Android的VolumeKeyListener或类似方案）
class VolumeKeyService extends WidgetsBindingObserver {
  static const String _prefsKey = 'volume_key_service_enabled';
  static const String _triggerTimestampKey = 'volume_key_last_trigger';
  static const int _triggerCooldownSeconds = 30; // 触发冷却时间
  static const int _keyPressWindowMs = 1500; // 按键时间窗口（1.5秒内按3次）
  static const int _requiredPresses = 3; // 需要按3次

  static final VolumeKeyService _instance = VolumeKeyService._internal();
  factory VolumeKeyService() => _instance;
  VolumeKeyService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isEnabled = false;

  // 按键记录
  final List<DateTime> _keyPresses = [];
  Timer? _resetTimer;

  // 状态回调
  VoidCallback? onTrigger;
  Function(bool isEnabled)? onStatusChanged;

  /// 是否正在监听
  bool get isListening => _isListening;

  /// 是否已启用
  bool get isEnabled => _isEnabled;

  /// 初始化服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _isEnabled = _prefs?.getBool(_prefsKey) ?? false;
    
    // 注册应用生命周期监听
    WidgetsBinding.instance.addObserver(this);
    
    _isInitialized = true;

    // 如果之前已启用，自动开始监听
    if (_isEnabled) {
      await startListening();
    }
  }

  /// 开始监听音量键
  /// 
  /// ⚠️ 重要说明：
  /// Flutter本身无法直接监听音量键。实际实现需要：
  /// 1. 使用 platform channel 调用原生代码
  /// 2. Android: 注册 VolumeKeyListener 或使用 AccessibilityService
  /// 3. iOS: 无法监听音量键（系统限制）
  /// 
  /// 以下是一个模拟实现框架，需要配合原生代码才能正常工作
  Future<bool> startListening() async {
    await initialize();

    if (_isListening) return true;

    try {
      // 检查权限
      final hasPermission = await _checkPermission();
      if (!hasPermission) {
        return false;
      }

      _isListening = true;
      
      // 实际项目中，这里应该调用原生代码开始监听音量键
      // 例如：await _channel.invokeMethod('startVolumeKeyListening');
      
      // 模拟：使用系统事件（仅用于演示）
      _setupMockListener();

      onStatusChanged?.call(true);
      return true;
    } catch (e) {
      _isListening = false;
      return false;
    }
  }

  /// 停止监听
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    _resetTimer?.cancel();
    _keyPresses.clear();

    // 实际项目中，这里应该调用原生代码停止监听
    // 例如：await _channel.invokeMethod('stopVolumeKeyListening');

    onStatusChanged?.call(false);
  }

  /// 启用/禁用服务
  Future<bool> setEnabled(bool enabled) async {
    await initialize();

    _isEnabled = enabled;
    await _prefs?.setBool(_prefsKey, enabled);

    if (enabled) {
      return await startListening();
    } else {
      await stopListening();
      return true;
    }
  }

  /// 切换启用状态
  Future<bool> toggle() async {
    return await setEnabled(!_isEnabled);
  }

  /// 检查是否触发（用于原生代码回调）
  bool checkTrigger() {
    final now = DateTime.now();
    
    // 检查冷却时间
    final lastTrigger = _prefs?.getString(_triggerTimestampKey);
    if (lastTrigger != null) {
      final lastTriggerTime = DateTime.tryParse(lastTrigger);
      if (lastTriggerTime != null) {
        final cooldownEnd = lastTriggerTime.add(
          const Duration(seconds: _triggerCooldownSeconds),
        );
        if (now.isBefore(cooldownEnd)) {
          return false; // 冷却中
        }
      }
    }

    // 检查按键记录
    _cleanupOldPresses(now);
    
    if (_keyPresses.length >= _requiredPresses) {
      // 触发SOS
      _recordTrigger();
      _keyPresses.clear();
      onTrigger?.call();
      return true;
    }

    return false;
  }

  /// 记录按键（由原生代码调用）
  void recordKeyPress() {
    if (!_isListening) return;

    final now = DateTime.now();
    _cleanupOldPresses(now);
    _keyPresses.add(now);

    // 启动重置计时器
    _resetTimer?.cancel();
    _resetTimer = Timer(
      const Duration(milliseconds: _keyPressWindowMs),
      () {
        _keyPresses.clear();
      },
    );

    // 检查是否触发
    checkTrigger();
  }

  /// 模拟按键（用于测试）
  void simulateKeyPress() {
    recordKeyPress();
  }

  /// 获取冷却剩余时间
  Duration? getCooldownRemaining() {
    final lastTrigger = _prefs?.getString(_triggerTimestampKey);
    if (lastTrigger == null) return null;

    final lastTriggerTime = DateTime.tryParse(lastTrigger);
    if (lastTriggerTime == null) return null;

    final cooldownEnd = lastTriggerTime.add(
      const Duration(seconds: _triggerCooldownSeconds),
    );
    final now = DateTime.now();

    if (now.isBefore(cooldownEnd)) {
      return cooldownEnd.difference(now);
    }

    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 应用生命周期变化处理
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用回到前台
        if (_isEnabled && !_isListening) {
          startListening();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // 应用进入后台
        // 注意：后台监听音量键在大多数平台上是不可能的
        // 需要在原生层使用特殊方案（如AccessibilityService）
        break;
      default:
        break;
    }
  }

  /// 释放资源
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopListening();
    _resetTimer?.cancel();
  }

  // ========== 私有方法 ==========

  /// 检查权限
  Future<bool> _checkPermission() async {
    // 实际项目中需要检查：
    // 1. Android: SYSTEM_ALERT_WINDOW 或 AccessibilityService 权限
    // 2. iOS: 无法监听音量键
    
    // 这里返回true作为模拟
    return true;
  }

  /// 清理过期的按键记录
  void _cleanupOldPresses(DateTime now) {
    final cutoff = now.subtract(const Duration(milliseconds: _keyPressWindowMs));
    _keyPresses.removeWhere((press) => press.isBefore(cutoff));
  }

  /// 记录触发时间
  void _recordTrigger() {
    _prefs?.setString(_triggerTimestampKey, DateTime.now().toIso8601String());
  }

  /// 设置模拟监听器（仅用于演示）
  void _setupMockListener() {
    // 实际项目中，这里应该使用 platform channel 接收原生事件
    // 例如：
    // _channel.setMethodCallHandler((call) async {
    //   if (call.method == 'onVolumeDown') {
    //     recordKeyPress();
    //   }
    // });
    
    // 模拟实现：通过键盘事件（仅用于开发测试）
    // 注意：这只是一个演示，实际需要使用原生代码
  }
}

/// 音量键监听原生代码示例（Android）
/// 
/// 在 MainActivity.kt 中添加：
/// ```kotlin
/// class MainActivity : FlutterActivity() {
///     private val VOLUME_KEY_CHANNEL = "com.shanjing/volume_key"
///     private var eventSink: EventSink? = null
///     
///     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
///         super.configureFlutterEngine(flutterEngine)
///         
///         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOLUME_KEY_CHANNEL)
///             .setMethodCallHandler { call, result ->
///                 when (call.method) {
///                     "startListening" -> {
///                         startVolumeKeyListening()
///                         result.success(true)
///                     }
///                     "stopListening" -> {
///                         stopVolumeKeyListening()
///                         result.success(true)
///                     }
///                     else -> result.notImplemented()
///                 }
///             }
///     }
///     
///     private fun startVolumeKeyListening() {
///         // 注册音量键监听
///         // 注意：需要特殊权限才能监听音量键
///     }
///     
///     override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
///         if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
///             MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, VOLUME_KEY_CHANNEL)
///                 .invokeMethod("onVolumeDown", null)
///             return true // 消费事件
///         }
///         return super.onKeyDown(keyCode, event)
///     }
/// }
/// ```
/// 
/// 更好的方案是使用 AccessibilityService：
/// ```kotlin
/// class VolumeKeyAccessibilityService : AccessibilityService() {
///     override fun onAccessibilityEvent(event: AccessibilityEvent) {
///         // 监听音量变化事件
///     }
///     
///     override fun onInterrupt() {}
///     
///     override fun onServiceConnected() {
///         super.onServiceConnected()
///         // 服务连接后开始监听
///     }
/// }
/// ```
/// 
/// 在 AndroidManifest.xml 中声明：
/// ```xml
/// <service
///     android:name=".VolumeKeyAccessibilityService"
///     android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
///     android:exported="true">
///     <intent-filter>
///         <action android:name="android.accessibilityservice.AccessibilityService" />
///     </intent-filter>
///     <meta-data
///         android:name="android.accessibilityservice"
///         android:resource="@xml/accessibility_service_config" />
/// </service>
/// ```
