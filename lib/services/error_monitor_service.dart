// ================================================================
// Error Monitoring Service
// 错误监控服务 - 异常上报、错误分类统计
// ================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 错误级别
enum ErrorLevel {
  debug,      // 调试信息
  info,       // 一般信息
  warning,    // 警告
  error,      // 错误
  critical,   // 严重错误
  fatal,      // 致命错误
}

/// 错误分类
enum ErrorCategory {
  network,        // 网络错误
  api,            // API 错误
  database,       // 数据库错误
  ui,             // UI 错误
  businessLogic,  // 业务逻辑错误
  unknown,        // 未知错误
  flutter,        // Flutter 框架错误
  native,         // 原生平台错误
}

/// 错误报告
class ErrorReport {
  final String id;
  final ErrorLevel level;
  final ErrorCategory category;
  final String message;
  final String? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  final String? userId;
  final String? sessionId;
  final String? route;
  final Map<String, dynamic>? deviceInfo;

  ErrorReport({
    String? id,
    required this.level,
    required this.category,
    required this.message,
    this.stackTrace,
    this.context,
    this.userId,
    this.sessionId,
    this.route,
    this.deviceInfo,
  }) : id = id ?? _generateErrorId(),
       timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level.name,
    'category': category.name,
    'message': message,
    'stack_trace': stackTrace,
    'timestamp': timestamp.toIso8601String(),
    'context': context,
    'user_id': userId,
    'session_id': sessionId,
    'route': route,
    'device_info': deviceInfo,
  };

  static String _generateErrorId() {
    return 'err_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }
}

/// 错误统计
class ErrorStats {
  final Map<ErrorLevel, int> _byLevel = {};
  final Map<ErrorCategory, int> _byCategory = {};
  final Map<String, int> _byMessage = {};
  int _total = 0;

  void record(ErrorReport report) {
    _total++;
    _byLevel[report.level] = (_byLevel[report.level] ?? 0) + 1;
    _byCategory[report.category] = (_byCategory[report.category] ?? 0) + 1;
    _byMessage[report.message] = (_byMessage[report.message] ?? 0) + 1;
  }

  int get total => _total;
  Map<ErrorLevel, int> get byLevel => Map.unmodifiable(_byLevel);
  Map<ErrorCategory, int> get byCategory => Map.unmodifiable(_byCategory);
  Map<String, int> get byMessage => Map.unmodifiable(_byMessage);

  /// 获取最常见的错误消息
  List<MapEntry<String, int>> getTopErrors({int limit = 10}) {
    final sorted = _byMessage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  Map<String, dynamic> toJson() => {
    'total': _total,
    'by_level': _byLevel.map((k, v) => MapEntry(k.name, v)),
    'by_category': _byCategory.map((k, v) => MapEntry(k.name, v)),
    'top_errors': getTopErrors().map((e) => {'message': e.key, 'count': e.value}).toList(),
  };

  void reset() {
    _total = 0;
    _byLevel.clear();
    _byCategory.clear();
    _byMessage.clear();
  }
}

/// 错误监控服务
class ErrorMonitorService {
  static final ErrorMonitorService _instance = ErrorMonitorService._internal();
  static ErrorMonitorService get instance => _instance;

  ErrorMonitorService._internal();

  // 错误队列
  final List<ErrorReport> _errorQueue = [];
  static const int _maxQueueSize = 100;

  // 错误统计
  final ErrorStats _stats = ErrorStats();

  // 会话信息
  String? _sessionId;
  String? _userId;
  String? _currentRoute;

  // 配置
  ErrorLevel _minReportLevel = ErrorLevel.error;
  bool _isFlutterErrorHandlerSet = false;
  bool _isPlatformErrorHandlerSet = false;

  // 流控制器
  final _errorController = StreamController<ErrorReport>.broadcast();
  Stream<ErrorReport> get errorStream => _errorController.stream;

  /// 初始化错误监控
  void initialize({
    String? sessionId,
    String? userId,
    ErrorLevel minReportLevel = ErrorLevel.error,
    bool catchFlutterErrors = true,
    bool catchPlatformErrors = true,
  }) {
    _sessionId = sessionId;
    _userId = userId;
    _minReportLevel = minReportLevel;

    if (catchFlutterErrors && !_isFlutterErrorHandlerSet) {
      _setupFlutterErrorHandler();
    }

    if (catchPlatformErrors && !_isPlatformErrorHandlerSet) {
      _setupPlatformErrorHandler();
    }
  }

  /// 设置用户ID
  void setUserId(String? userId) {
    _userId = userId;
  }

  /// 设置会话ID
  void setSessionId(String? sessionId) {
    _sessionId = sessionId;
  }

  /// 设置当前路由
  void setCurrentRoute(String? route) {
    _currentRoute = route;
  }

  /// 设置最低上报级别
  void setMinReportLevel(ErrorLevel level) {
    _minReportLevel = level;
  }

  /// 上报错误
  void reportError({
    required String message,
    ErrorLevel level = ErrorLevel.error,
    ErrorCategory category = ErrorCategory.unknown,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    // 过滤低级别错误
    if (_levelValue(level) < _levelValue(_minReportLevel)) {
      return;
    }

    final report = ErrorReport(
      level: level,
      category: category,
      message: message,
      stackTrace: stackTrace?.toString() ?? error?.toString(),
      context: context,
      userId: _userId,
      sessionId: _sessionId,
      route: _currentRoute,
    );

    _processError(report);
  }

  /// 上报异常
  void reportException(
    Object exception,
    StackTrace stackTrace, {
    ErrorCategory category = ErrorCategory.unknown,
    Map<String, dynamic>? context,
  }) {
    reportError(
      message: exception.toString(),
      level: ErrorLevel.error,
      category: category,
      error: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// 上报网络错误
  void reportNetworkError(String message, {
    String? url,
    int? statusCode,
    Map<String, dynamic>? extra,
  }) {
    reportError(
      message: message,
      level: ErrorLevel.warning,
      category: ErrorCategory.network,
      context: {
        'url': url,
        'status_code': statusCode,
        ...?extra,
      },
    );
  }

  /// 上报 API 错误
  void reportApiError(String apiName, dynamic error, {
    int? statusCode,
    String? response,
    Map<String, dynamic>? extra,
  }) {
    reportError(
      message: 'API Error: $apiName - $error',
      level: ErrorLevel.error,
      category: ErrorCategory.api,
      context: {
        'api': apiName,
        'status_code': statusCode,
        'response': response,
        ...?extra,
      },
    );
  }

  /// 上报数据库错误
  void reportDatabaseError(String operation, dynamic error, {
    String? table,
    Map<String, dynamic>? extra,
  }) {
    reportError(
      message: 'Database Error: $operation - $error',
      level: ErrorLevel.error,
      category: ErrorCategory.database,
      context: {
        'operation': operation,
        'table': table,
        ...?extra,
      },
    );
  }

  /// 快捷方法：Debug
  void debug(String message, {Map<String, dynamic>? context}) {
    reportError(message: message, level: ErrorLevel.debug, context: context);
  }

  /// 快捷方法：Info
  void info(String message, {Map<String, dynamic>? context}) {
    reportError(message: message, level: ErrorLevel.info, context: context);
  }

  /// 快捷方法：Warning
  void warning(String message, {Map<String, dynamic>? context, Object? error}) {
    reportError(
      message: message,
      level: ErrorLevel.warning,
      context: context,
      error: error,
    );
  }

  /// 快捷方法：Error
  void error(String message, {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {
    reportError(
      message: message,
      level: ErrorLevel.error,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 快捷方法：Critical
  void critical(String message, {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {
    reportError(
      message: message,
      level: ErrorLevel.critical,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 获取错误统计
  ErrorStats getStats() => _stats;

  /// 获取错误报告
  Map<String, dynamic> getErrorReport() {
    return _stats.toJson();
  }

  /// 获取所有错误
  List<ErrorReport> getAllErrors() {
    return List.unmodifiable(_errorQueue);
  }

  /// 获取最近的错误
  List<ErrorReport> getRecentErrors({int count = 10}) {
    final start = _errorQueue.length > count ? _errorQueue.length - count : 0;
    return _errorQueue.sublist(start);
  }

  /// 按级别获取错误
  List<ErrorReport> getErrorsByLevel(ErrorLevel level) {
    return _errorQueue.where((e) => e.level == level).toList();
  }

  /// 按分类获取错误
  List<ErrorReport> getErrorsByCategory(ErrorCategory category) {
    return _errorQueue.where((e) => e.category == category).toList();
  }

  /// 清空错误队列
  void clearErrors() {
    _errorQueue.clear();
    _stats.reset();
  }

  /// 刷新上报
  Future<void> flush() async {
    if (_errorQueue.isEmpty) return;

    // 这里可以接入第三方错误上报服务，如 Firebase Crashlytics、Sentry 等
    if (kDebugMode) {
      debugPrint('📊 ErrorMonitor: Flushing ${_errorQueue.length} errors');
      for (final report in _errorQueue) {
        debugPrint('  [${report.level.name}] ${report.category.name}: ${report.message}');
      }
    }

    // TODO: 发送到服务器或第三方服务
    // await _sendToServer(_errorQueue);

    _errorQueue.clear();
  }

  // ============ 私有方法 ============

  void _processError(ErrorReport report) {
    _errorQueue.add(report);
    _stats.record(report);
    _errorController.add(report);

    // 限制队列大小
    if (_errorQueue.length > _maxQueueSize) {
      _errorQueue.removeAt(0);
    }

    // 致命错误立即上报
    if (report.level == ErrorLevel.fatal || report.level == ErrorLevel.critical) {
      flush();
    }

    // 调试输出
    if (kDebugMode) {
      final emoji = _getLevelEmoji(report.level);
      debugPrint('$emoji [${report.level.name.toUpperCase()}] ${report.message}');
      if (report.stackTrace != null) {
        debugPrint('Stack: ${report.stackTrace!.substring(0, report.stackTrace!.length > 200 ? 200 : report.stackTrace!.length)}...');
      }
    }
  }

  void _setupFlutterErrorHandler() {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      // 上报 Flutter 错误
      reportError(
        message: details.exceptionAsString(),
        level: ErrorLevel.error,
        category: ErrorCategory.flutter,
        error: details.exception,
        stackTrace: details.stack,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );

      // 调用原始处理器
      originalOnError?.call(details);
    };
    _isFlutterErrorHandlerSet = true;
  }

  void _setupPlatformErrorHandler() {
    PlatformDispatcher.instance.onError = (error, stack) {
      reportError(
        message: error.toString(),
        level: ErrorLevel.error,
        category: ErrorCategory.native,
        error: error,
        stackTrace: stack,
      );
      return true;
    };
    _isPlatformErrorHandlerSet = true;
  }

  int _levelValue(ErrorLevel level) {
    switch (level) {
      case ErrorLevel.debug: return 0;
      case ErrorLevel.info: return 1;
      case ErrorLevel.warning: return 2;
      case ErrorLevel.error: return 3;
      case ErrorLevel.critical: return 4;
      case ErrorLevel.fatal: return 5;
    }
  }

  String _getLevelEmoji(ErrorLevel level) {
    switch (level) {
      case ErrorLevel.debug: return '🔍';
      case ErrorLevel.info: return 'ℹ️';
      case ErrorLevel.warning: return '⚠️';
      case ErrorLevel.error: return '❌';
      case ErrorLevel.critical: return '🚨';
      case ErrorLevel.fatal: return '💥';
    }
  }

  /// 释放资源
  void dispose() {
    _errorController.close();
  }
}

/// 简化的 Random 类
class Random {
  static final _random = DateTime.now().millisecondsSinceEpoch;
  int nextInt(int max) => (_random % max).abs();
}

/// 错误监控 Mixin，方便在 State 类中使用
mixin ErrorMonitorMixin<T extends StatefulWidget> on State<T> {
  void captureError(Object error, StackTrace stackTrace, {ErrorCategory category = ErrorCategory.ui}) {
    ErrorMonitorService.instance.reportException(error, stackTrace, category: category);
  }

  Future<R> captureAsyncError<R>(Future<R> Function() operation, {ErrorCategory category = ErrorCategory.businessLogic}) async {
    try {
      return await operation();
    } catch (e, stack) {
      ErrorMonitorService.instance.reportException(e, stack, category: category);
      rethrow;
    }
  }
}
