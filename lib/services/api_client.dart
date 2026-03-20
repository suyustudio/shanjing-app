/**
 * API 客户端
 * 
 * 统一处理 HTTP 请求、错误处理、Token 管理
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// API 异常类
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;
  final dynamic data;

  ApiException({
    this.statusCode,
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message, code: $code)';
}

/// API 响应封装
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final String? errorCode;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    this.data,
    this.errorMessage,
    this.errorCode,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? parser,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: parser != null && json['data'] != null ? parser(json['data']) : json['data'],
      errorMessage: json['error']?['message'],
      errorCode: json['error']?['code'],
      meta: json['meta'],
    );
  }
}

/// API 客户端
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  String? _authToken;

  /// 设置认证 Token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// 清除认证 Token
  void clearAuthToken() {
    _authToken = null;
  }

  /// 获取请求头
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  /// 构建完整 URL
  String _buildUrl(String endpoint) {
    return ApiConfig.apiBaseUrl + endpoint;
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? parser,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(endpoint));
      
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        ));
      }

      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      return _handleResponse(response, parser);
    } on SocketException catch (e) {
      throw ApiException(message: '网络连接失败，请检查网络', code: 'NETWORK_ERROR');
    } on TimeoutException catch (e) {
      throw ApiException(message: '请求超时，请稍后重试', code: 'TIMEOUT');
    } catch (e) {
      throw ApiException(message: '请求失败: $e', code: 'UNKNOWN_ERROR');
    }
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));

      final response = await _client
          .post(
            uri,
            headers: _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      return _handleResponse(response, parser);
    } on SocketException catch (e) {
      throw ApiException(message: '网络连接失败，请检查网络', code: 'NETWORK_ERROR');
    } on TimeoutException catch (e) {
      throw ApiException(message: '请求超时，请稍后重试', code: 'TIMEOUT');
    } catch (e) {
      throw ApiException(message: '请求失败: $e', code: 'UNKNOWN_ERROR');
    }
  }

  /// PUT 请求
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));

      final response = await _client
          .put(
            uri,
            headers: _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      return _handleResponse(response, parser);
    } on SocketException catch (e) {
      throw ApiException(message: '网络连接失败，请检查网络', code: 'NETWORK_ERROR');
    } on TimeoutException catch (e) {
      throw ApiException(message: '请求超时，请稍后重试', code: 'TIMEOUT');
    } catch (e) {
      throw ApiException(message: '请求失败: $e', code: 'UNKNOWN_ERROR');
    }
  }

  /// DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));

      final response = await _client
          .delete(uri, headers: _getHeaders())
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      return _handleResponse(response, parser);
    } on SocketException catch (e) {
      throw ApiException(message: '网络连接失败，请检查网络', code: 'NETWORK_ERROR');
    } on TimeoutException catch (e) {
      throw ApiException(message: '请求超时，请稍后重试', code: 'TIMEOUT');
    } catch (e) {
      throw ApiException(message: '请求失败: $e', code: 'UNKNOWN_ERROR');
    }
  }

  /// 处理响应
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? parser,
  ) {
    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse.fromJson(body, parser);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['error']?['message'] ?? '请求失败',
        code: body['error']?['code'] ?? 'UNKNOWN_ERROR',
        data: body,
      );
    }
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}
