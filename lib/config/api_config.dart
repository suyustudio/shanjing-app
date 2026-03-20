// ================================================================
// API 配置
// 包含超时设置和重试机制
// ================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../constants/achievement_constants.dart';

/// API 配置类
class ApiConfig {
  const ApiConfig._();
  
  // 基础 URL 配置
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.shanjing.app',
  );
  
  static const String apiVersion = 'v1';
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  
  // 超时配置
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // 重试配置
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const double retryDelayMultiplier = 2.0;
  
  // 缓存配置
  static const Duration defaultCacheTtl = Duration(minutes: 5);
  
  // 限流配置
  static const int maxRequestsPerSecond = 10;
}

/// HTTP 客户端配置
class HttpClientConfig {
  static HttpClient createHttpClient() {
    final client = HttpClient()
      ..connectionTimeout = ApiConfig.connectionTimeout
      ..idleConnectionTimeout = const Duration(seconds: 60)
      ..maxConnectionsPerHost = 10;
    
    return client;
  }
  
  static http.Client createIOClient() {
    return IOClient(createHttpClient());
  }
}

/// API 响应包装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final int? statusCode;
  final DateTime? timestamp;
  
  const ApiResponse({
    required this.success,
    this.data,
    this.errorMessage,
    this.statusCode,
    this.timestamp,
  });
  
  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }
  
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      errorMessage: message,
      statusCode: statusCode,
      timestamp: DateTime.now(),
    );
  }
  
  bool get hasError => !success;
  bool get hasData => data != null;
}

/// API 异常类
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;
  final DateTime timestamp;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.endpoint,
  }) : timestamp = DateTime.now();
  
  @override
  String toString() {
    return 'ApiException: $message (status: $statusCode, endpoint: $endpoint)';
  }
}

/// 超时异常
class TimeoutException extends ApiException {
  TimeoutException({String? endpoint})
      : super(
          message: '请求超时，请检查网络连接',
          statusCode: 408,
          endpoint: endpoint,
        );
}

/// 网络异常
class NetworkException extends ApiException {
  NetworkException({String? endpoint, String? details})
      : super(
          message: '网络连接失败${details != null ? ': $details' : ''}',
          statusCode: 0,
          endpoint: endpoint,
        );
}

/// 带重试机制的 HTTP 请求工具类
class RetryableHttpClient {
  final http.Client _client;
  final int maxRetries;
  final Duration initialDelay;
  final double delayMultiplier;
  
  RetryableHttpClient({
    http.Client? client,
    this.maxRetries = ApiConfig.maxRetries,
    this.initialDelay = ApiConfig.initialRetryDelay,
    this.delayMultiplier = ApiConfig.retryDelayMultiplier,
  }) : _client = client ?? HttpClientConfig.createIOClient();
  
  /// 执行带重试的 GET 请求
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _executeWithRetry(
      () async => _client.get(url, headers: headers),
      url: url,
      timeout: timeout ?? ApiConfig.receiveTimeout,
    );
  }
  
  /// 执行带重试的 POST 请求
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    return _executeWithRetry(
      () async => _client.post(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      ),
      url: url,
      timeout: timeout ?? ApiConfig.receiveTimeout,
    );
  }
  
  /// 执行带重试的 PUT 请求
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    return _executeWithRetry(
      () async => _client.put(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      ),
      url: url,
      timeout: timeout ?? ApiConfig.receiveTimeout,
    );
  }
  
  /// 执行带重试的 DELETE 请求
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    return _executeWithRetry(
      () async => _client.delete(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      ),
      url: url,
      timeout: timeout ?? ApiConfig.receiveTimeout,
    );
  }
  
  /// 执行带重试的请求
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request, {
    required Uri url,
    required Duration timeout,
  }) async {
    var attempt = 0;
    var delay = initialDelay;
    
    while (true) {
      attempt++;
      
      try {
        final response = await request().timeout(timeout);
        
        // 检查是否需要重试 (5xx 错误)
        if (response.statusCode >= 500 && response.statusCode < 600 && attempt < maxRetries) {
          debugPrint('Server error ${response.statusCode}, retrying ($attempt/$maxRetries)...');
          await Future.delayed(delay);
          delay = Duration(milliseconds: (delay.inMilliseconds * delayMultiplier).round());
          continue;
        }
        
        return response;
      } on TimeoutException catch (e) {
        if (attempt >= maxRetries) {
          throw TimeoutException(endpoint: url.path);
        }
        debugPrint('Request timeout, retrying ($attempt/$maxRetries)...');
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * delayMultiplier).round());
      } on SocketException catch (e) {
        if (attempt >= maxRetries) {
          throw NetworkException(endpoint: url.path, details: e.message);
        }
        debugPrint('Network error, retrying ($attempt/$maxRetries)...');
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * delayMultiplier).round());
      } catch (e) {
        if (attempt >= maxRetries) {
          throw ApiException(
            message: 'Request failed: $e',
            endpoint: url.path,
          );
        }
        debugPrint('Request error: $e, retrying ($attempt/$maxRetries)...');
        await Future.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * delayMultiplier).round());
      }
    }
  }
  
  void close() {
    _client.close();
  }
}
