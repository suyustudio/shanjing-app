/**
 * 公共错误处理工具类
 * 
 * 提供统一的错误处理、错误转换和用户友好的错误消息
 * 
 * @author 山径开发团队
 * @since M4 P2
 */

import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'result.dart';

/// 应用错误类型枚举
enum AppErrorType {
  /// 网络错误
  network,
  
  /// 超时错误
  timeout,
  
  /// 服务器错误
  server,
  
  /// 认证错误
  authentication,
  
  /// 授权错误
  authorization,
  
  /// 数据解析错误
  parsing,
  
  /// 本地存储错误
  storage,
  
  /// 位置服务错误
  location,
  
  /// 未知错误
  unknown,
}

/// 应用错误类
class AppError implements Exception {
  /// 错误类型
  final AppErrorType type;
  
  /// 错误消息（用户友好）
  final String message;
  
  /// 原始错误
  final dynamic originalError;
  
  /// 错误代码
  final String? code;
  
  /// 是否应该重试
  final bool isRetryable;
  
  /// 是否需要用户操作
  final bool requiresUserAction;

  AppError({
    required this.type,
    required this.message,
    this.originalError,
    this.code,
    this.isRetryable = false,
    this.requiresUserAction = false,
  });

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, code: $code, isRetryable: $isRetryable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppError &&
        other.type == type &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(type, message, code);
}

/// 错误处理器
class ErrorHandler {
  ErrorHandler._();

  /// 将原始错误转换为应用错误
  static AppError handle(dynamic error, {String? context}) {
    // 已经是 AppError 则直接返回
    if (error is AppError) {
      return error;
    }

    // 根据错误类型转换
    if (error is SocketException) {
      return AppError(
        type: AppErrorType.network,
        message: '网络连接失败，请检查网络设置',
        originalError: error,
        code: 'NETWORK_ERROR',
        isRetryable: true,
        requiresUserAction: true,
      );
    }

    if (error is TimeoutException) {
      return AppError(
        type: AppErrorType.timeout,
        message: '请求超时，请稍后重试',
        originalError: error,
        code: 'TIMEOUT',
        isRetryable: true,
      );
    }

    if (error is FormatException) {
      return AppError(
        type: AppErrorType.parsing,
        message: '数据解析失败，请更新应用到最新版本',
        originalError: error,
        code: 'PARSE_ERROR',
        isRetryable: false,
      );
    }

    if (error is PlatformException) {
      return _handlePlatformException(error);
    }

    if (error is HttpException) {
      return AppError(
        type: AppErrorType.server,
        message: '服务器响应异常，请稍后重试',
        originalError: error,
        code: 'HTTP_ERROR',
        isRetryable: true,
      );
    }

    // 默认未知错误
    return AppError(
      type: AppErrorType.unknown,
      message: '发生未知错误，请重试',
      originalError: error,
      code: 'UNKNOWN_ERROR',
      isRetryable: true,
    );
  }

  /// 处理平台异常
  static AppError _handlePlatformException(PlatformException error) {
    switch (error.code) {
      case 'PERMISSION_DENIED':
        return AppError(
          type: AppErrorType.authorization,
          message: '权限被拒绝，请在设置中开启相关权限',
          originalError: error,
          code: 'PERMISSION_DENIED',
          isRetryable: false,
          requiresUserAction: true,
        );
      case 'LOCATION_SERVICES_DISABLED':
        return AppError(
          type: AppErrorType.location,
          message: '位置服务未开启，请在设置中开启GPS',
          originalError: error,
          code: 'LOCATION_DISABLED',
          isRetryable: false,
          requiresUserAction: true,
        );
      default:
        return AppError(
          type: AppErrorType.unknown,
          message: '系统错误: ${error.message}',
          originalError: error,
          code: error.code,
          isRetryable: true,
        );
    }
  }

  /// 根据 HTTP 状态码创建错误
  static AppError fromHttpStatus(int statusCode, {String? message}) {
    switch (statusCode) {
      case 400:
        return AppError(
          type: AppErrorType.server,
          message: message ?? '请求参数错误',
          code: 'BAD_REQUEST',
          isRetryable: false,
        );
      case 401:
        return AppError(
          type: AppErrorType.authentication,
          message: '登录已过期，请重新登录',
          code: 'UNAUTHORIZED',
          isRetryable: false,
          requiresUserAction: true,
        );
      case 403:
        return AppError(
          type: AppErrorType.authorization,
          message: '没有权限执行此操作',
          code: 'FORBIDDEN',
          isRetryable: false,
        );
      case 404:
        return AppError(
          type: AppErrorType.server,
          message: '请求的资源不存在',
          code: 'NOT_FOUND',
          isRetryable: false,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return AppError(
          type: AppErrorType.server,
          message: '服务器繁忙，请稍后重试',
          code: 'SERVER_ERROR',
          isRetryable: true,
        );
      default:
        return AppError(
          type: AppErrorType.unknown,
          message: message ?? '请求失败',
          code: 'HTTP_$statusCode',
          isRetryable: statusCode >= 500,
        );
    }
  }

  /// 获取用户友好的错误消息
  static String getUserMessage(AppError error) {
    return error.message;
  }

  /// 获取开发者调试信息
  static String getDebugInfo(AppError error) {
    final buffer = StringBuffer();
    buffer.writeln('=== 错误详情 ===');
    buffer.writeln('类型: ${error.type}');
    buffer.writeln('消息: ${error.message}');
    buffer.writeln('代码: ${error.code}');
    buffer.writeln('可重试: ${error.isRetryable}');
    buffer.writeln('需要用户操作: ${error.requiresUserAction}');
    if (error.originalError != null) {
      buffer.writeln('原始错误: ${error.originalError}');
    }
    buffer.writeln('===============');
    return buffer.toString();
  }
}

/// 安全的异步执行包装器
/// 
/// 自动捕获和处理异常，避免未捕获的异常导致应用崩溃
/// 返回 Result<T> 类型，显式处理成功/失败状态
/// 
/// 使用示例:
/// ```dart
/// Result<String> result = await safeAsync(() => fetchData());
/// 
/// result
///   .onSuccess((data) => print('成功: $data'))
///   .onFailure((error) => print('失败: ${error.message}'));
/// ```
Future<Result<T>> safeAsync<T>(
  Future<T> Function() action, {
  Function(AppError error)? onError,
}) async {
  try {
    final value = await action();
    return Success(value);
  } catch (e) {
    final appError = ErrorHandler.handle(e);
    
    // 记录错误日志
    _logError(appError);
    
    // 调用错误回调
    onError?.call(appError);
    
    return Failure(appError);
  }
}

/// 带重试的异步执行
/// 
/// [action] 要执行的操作
/// [maxRetries] 最大重试次数
/// [retryDelay] 重试延迟
/// [shouldRetry] 自定义重试条件
/// 
/// 返回 Result<T>，即使失败也不会抛出异常
Future<Result<T>> retryAsync<T>(
  Future<T> Function() action, {
  int maxRetries = 3,
  Duration retryDelay = const Duration(seconds: 1),
  bool Function(dynamic error)? shouldRetry,
}) async {
  int attempts = 0;
  AppError? lastError;
  
  while (attempts <= maxRetries) {
    try {
      final value = await action();
      return Success(value);
    } catch (e) {
      final appError = ErrorHandler.handle(e);
      lastError = appError;
      
      // 判断是否应该重试
      final canRetry = attempts < maxRetries &&
          (shouldRetry?.call(e) ?? appError.isRetryable);
      
      if (!canRetry) {
        return Failure(appError);
      }
      
      // 等待后重试
      await Future.delayed(retryDelay * (attempts + 1));
      attempts++;
    }
  }
  
  // 所有重试都失败
  return Failure(lastError!);
}

/// 记录错误日志
void _logError(AppError error) {
  // 实际项目中应使用日志框架
  // ignore: avoid_print
  print('[ERROR] ${ErrorHandler.getDebugInfo(error)}');
}

/// 错误边界 Widget（用于 Flutter）
/// 
/// 捕获子组件的错误并显示友好的错误界面
/*
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget Function(AppError error) errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    required this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        ErrorWidget.builder = (errorDetails) {
          final appError = AppError(
            type: AppErrorType.unknown,
            message: '组件渲染出错',
            originalError: errorDetails.exception,
          );
          return errorBuilder(appError);
        };
        return child;
      },
    );
  }
}
*/
