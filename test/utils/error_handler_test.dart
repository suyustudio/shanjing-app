import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/utils/error_handler.dart';
import 'package:hangzhou_guide/utils/result.dart';

void main() {
  group('AppError', () {
    test('should create AppError with all properties', () {
      final error = AppError(
        type: AppErrorType.network,
        message: '网络错误',
        code: 'NETWORK_001',
        isRetryable: true,
        requiresUserAction: true,
      );

      expect(error.type, AppErrorType.network);
      expect(error.message, '网络错误');
      expect(error.code, 'NETWORK_001');
      expect(error.isRetryable, true);
      expect(error.requiresUserAction, true);
    });

    test('should have correct default values', () {
      final error = AppError(
        type: AppErrorType.unknown,
        message: '未知错误',
      );

      expect(error.isRetryable, false);
      expect(error.requiresUserAction, false);
      expect(error.code, isNull);
      expect(error.originalError, isNull);
    });

    test('should format toString correctly', () {
      final error = AppError(
        type: AppErrorType.server,
        message: '服务器错误',
        code: 'SERVER_500',
        isRetryable: true,
      );

      expect(error.toString(), contains('AppError'));
      expect(error.toString(), contains('server'));
      expect(error.toString(), contains('服务器错误'));
    });

    test('should implement equality correctly', () {
      final error1 = AppError(
        type: AppErrorType.network,
        message: '网络错误',
        code: 'NET001',
      );
      final error2 = AppError(
        type: AppErrorType.network,
        message: '网络错误',
        code: 'NET001',
      );
      final error3 = AppError(
        type: AppErrorType.server,
        message: '服务器错误',
        code: 'SRV001',
      );

      expect(error1, equals(error2));
      expect(error1.hashCode, equals(error2.hashCode));
      expect(error1, isNot(equals(error3)));
    });
  });

  group('ErrorHandler.handle', () {
    test('should return AppError as-is if already AppError', () {
      final originalError = AppError(
        type: AppErrorType.network,
        message: '网络错误',
      );

      final result = ErrorHandler.handle(originalError);

      expect(result, equals(originalError));
    });

    test('should handle SocketException as network error', () {
      final socketException = SocketException('Connection refused');

      final result = ErrorHandler.handle(socketException);

      expect(result.type, AppErrorType.network);
      expect(result.isRetryable, true);
      expect(result.requiresUserAction, true);
      expect(result.code, 'NETWORK_ERROR');
    });

    test('should handle TimeoutException as timeout error', () {
      final timeoutException = TimeoutException('Request timeout');

      final result = ErrorHandler.handle(timeoutException);

      expect(result.type, AppErrorType.timeout);
      expect(result.isRetryable, true);
      expect(result.code, 'TIMEOUT');
    });

    test('should handle FormatException as parsing error', () {
      final formatException = FormatException('Invalid JSON');

      final result = ErrorHandler.handle(formatException);

      expect(result.type, AppErrorType.parsing);
      expect(result.isRetryable, false);
      expect(result.code, 'PARSE_ERROR');
    });

    test('should handle HttpException as server error', () {
      final httpException = HttpException('500 Internal Server Error');

      final result = ErrorHandler.handle(httpException);

      expect(result.type, AppErrorType.server);
      expect(result.isRetryable, true);
      expect(result.code, 'HTTP_ERROR');
    });

    test('should handle unknown error type', () {
      final unknownError = Exception('Something went wrong');

      final result = ErrorHandler.handle(unknownError);

      expect(result.type, AppErrorType.unknown);
      expect(result.isRetryable, true);
      expect(result.code, 'UNKNOWN_ERROR');
    });
  });

  group('ErrorHandler.fromHttpStatus', () {
    test('should create error for 400 status code', () {
      final result = ErrorHandler.fromHttpStatus(400);

      expect(result.type, AppErrorType.server);
      expect(result.code, 'BAD_REQUEST');
      expect(result.isRetryable, false);
    });

    test('should create error for 401 status code', () {
      final result = ErrorHandler.fromHttpStatus(401);

      expect(result.type, AppErrorType.authentication);
      expect(result.code, 'UNAUTHORIZED');
      expect(result.requiresUserAction, true);
    });

    test('should create error for 500+ status codes', () {
      for (final code in [500, 502, 503, 504]) {
        final result = ErrorHandler.fromHttpStatus(code);
        expect(result.type, AppErrorType.server);
        expect(result.isRetryable, true);
      }
    });
  });

  group('ErrorHandler.getUserMessage', () {
    test('should return user-friendly message', () {
      final error = AppError(
        type: AppErrorType.network,
        message: '网络连接失败',
      );

      final message = ErrorHandler.getUserMessage(error);

      expect(message, '网络连接失败');
    });
  });

  group('ErrorHandler.getDebugInfo', () {
    test('should return detailed debug information', () {
      final error = AppError(
        type: AppErrorType.server,
        message: '服务器错误',
        code: 'ERR_001',
        isRetryable: true,
        requiresUserAction: false,
      );

      final debugInfo = ErrorHandler.getDebugInfo(error);

      expect(debugInfo, contains('服务器错误'));
      expect(debugInfo, contains('ERR_001'));
      expect(debugInfo, contains('类型:'));
      expect(debugInfo, contains('可重试:'));
    });
  });

  group('safeAsync', () {
    test('should return Success when action succeeds', () async {
      final result = await safeAsync(() async {
        await Future.delayed(Duration(milliseconds: 10));
        return 'success data';
      });

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.value, 'success data');
      expect(result.error, isNull);
    });

    test('should return Failure when action throws', () async {
      final result = await safeAsync(() async {
        throw Exception('Test error');
      });

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.value, isNull);
      expect(result.error, isNotNull);
      expect(result.error!.type, AppErrorType.unknown);
    });

    test('should call onError callback on failure', () async {
      AppError? capturedError;

      await safeAsync(() async {
        throw SocketException('Connection failed');
      }, onError: (error) {
        capturedError = error;
      });

      expect(capturedError, isNotNull);
      expect(capturedError!.type, AppErrorType.network);
    });
  });

  group('retryAsync', () {
    test('should return Success on first attempt', () async {
      var callCount = 0;

      final result = await retryAsync(() async {
        callCount++;
        return 'data';
      });

      expect(result.isSuccess, true);
      expect(callCount, 1);
    });

    test('should retry on retryable error and eventually succeed', () async {
      var callCount = 0;

      final result = await retryAsync(() async {
        callCount++;
        if (callCount < 3) {
          throw SocketException('Connection failed');
        }
        return 'data';
      }, maxRetries: 3);

      expect(result.isSuccess, true);
      expect(callCount, 3);
    });

    test('should return Failure after max retries exceeded', () async {
      var callCount = 0;

      final result = await retryAsync(() async {
        callCount++;
        throw SocketException('Connection failed');
      }, maxRetries: 2, retryDelay: Duration(milliseconds: 1));

      expect(result.isFailure, true);
      expect(callCount, 3); // Initial + 2 retries
    });
  });

  group('PlatformException handling', () {
    test('should handle PERMISSION_DENIED', () {
      final exception = PlatformException(
        code: 'PERMISSION_DENIED',
        message: 'Permission denied',
      );

      final result = ErrorHandler.handle(exception);

      expect(result.type, AppErrorType.authorization);
      expect(result.code, 'PERMISSION_DENIED');
      expect(result.requiresUserAction, true);
    });

    test('should handle LOCATION_SERVICES_DISABLED', () {
      final exception = PlatformException(
        code: 'LOCATION_SERVICES_DISABLED',
        message: 'Location disabled',
      );

      final result = ErrorHandler.handle(exception);

      expect(result.type, AppErrorType.location);
      expect(result.code, 'LOCATION_DISABLED');
      expect(result.requiresUserAction, true);
    });

    test('should handle unknown platform exceptions', () {
      final exception = PlatformException(
        code: 'UNKNOWN_PLATFORM_ERROR',
        message: 'Unknown error',
      );

      final result = ErrorHandler.handle(exception);

      expect(result.type, AppErrorType.unknown);
      expect(result.code, 'UNKNOWN_PLATFORM_ERROR');
    });
  });
}
