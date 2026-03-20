// ================================================================
// API Service
// API 服务基础类
// ================================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API 服务类
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;

  ApiService._internal();

  // API 基础 URL
  String _baseUrl = 'http://localhost:3000/api';
  String? _authToken;

  // 获取/设置基础 URL
  String get baseUrl => _baseUrl;
  set baseUrl(String url) => _baseUrl = url;

  // 获取/设置认证 Token
  String? get authToken => _authToken;
  set authToken(String? token) => _authToken = token;

  /// 发送 GET 请求
  Future<Map<String, dynamic>> get(String path) async {
    final url = Uri.parse('$_baseUrl$path');
    
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('GET 请求失败: $e');
      throw Exception('网络请求失败: $e');
    }
  }

  /// 发送 POST 请求
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('POST 请求失败: $e');
      throw Exception('网络请求失败: $e');
    }
  }

  /// 发送 PUT 请求
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    
    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('PUT 请求失败: $e');
      throw Exception('网络请求失败: $e');
    }
  }

  /// 发送 DELETE 请求
  Future<Map<String, dynamic>> delete(String path) async {
    final url = Uri.parse('$_baseUrl$path');
    
    try {
      final response = await http.delete(
        url,
        headers: _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('DELETE 请求失败: $e');
      throw Exception('网络请求失败: $e');
    }
  }

  /// 获取请求头
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = body['message'] ?? '请求失败';
      throw Exception(message);
    }
  }
}
