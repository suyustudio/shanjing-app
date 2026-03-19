/**
 * 通用工具类
 * 
 * 提供项目中常用的公共方法和扩展函数
 * 
 * @author 山径开发团队
 * @since M4 P2
 */

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 字符串扩展
extension StringExtensions on String {
  /// 截断字符串，超过长度显示省略号
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength - suffix.length) + suffix;
  }

  /// 判断是否为空或仅包含空白字符
  bool get isBlank => trim().isEmpty;

  /// 判断是否不为空且不包含仅空白字符
  bool get isNotBlank => trim().isNotEmpty;

  /// 转换为驼峰命名
  String toCamelCase() {
    final words = split(RegExp(r'[_\s]+'));
    if (words.isEmpty) return this;
    
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join();
  }

  /// 转换为蛇形命名
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'^_'), '');
  }

  /// 隐藏手机号中间四位
  String maskPhone() {
    if (length != 11) return this;
    return '${substring(0, 3)}****${substring(7)}';
  }

  /// 隐藏邮箱用户名部分
  String maskEmail() {
    final parts = split('@');
    if (parts.length != 2) return this;
    
    final local = parts[0];
    final domain = parts[1];
    
    if (local.length <= 2) {
      return '${local[0]}***@$domain';
    }
    
    return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}@$domain';
  }
}

/// 数字扩展
extension NumExtensions on num {
  /// 格式化为距离（米/公里）
  String formatDistance() {
    if (this < 1000) {
      return '${toStringAsFixed(0)}m';
    }
    return '${(this / 1000).toStringAsFixed(1)}km';
  }

  /// 格式化为时长（分钟/小时）
  String formatDuration() {
    if (this < 60) {
      return '${toStringAsFixed(0)}分钟';
    }
    final hours = this ~/ 60;
    final minutes = this % 60;
    if (minutes == 0) {
      return '${hours}小时';
    }
    return '${hours}小时${minutes.toStringAsFixed(0)}分钟';
  }

  /// 格式化为海拔
  String formatElevation() {
    return '${toStringAsFixed(0)}m';
  }

  /// 格式化为百分比
  String formatPercent({int decimalPlaces = 1}) {
    return '${(this * 100).toStringAsFixed(decimalPlaces)}%';
  }

  /// 限制在指定范围内
  num clamp(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

/// 日期时间扩展
extension DateTimeExtensions on DateTime {
  /// 格式化为相对时间（刚刚、几分钟前等）
  String toRelativeTime() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) {
      return '刚刚';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    }
    if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前';
    }
    if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}个月前';
    }
    return '${(diff.inDays / 365).floor()}年前';
  }

  /// 格式化为日期字符串
  String toDateString() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// 格式化为时间字符串
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  /// 格式化为日期时间字符串
  String toDateTimeString() {
    return DateFormat('yyyy-MM-dd HH:mm').format(this);
  }

  /// 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 是否是昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// 获取星期几（中文）
  String get weekdayName {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[weekday - 1];
  }
}

/// 列表扩展
extension ListExtensions<T> on List<T> {
  /// 安全获取元素，越界返回 null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// 分割列表为固定大小的块
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  /// 去重
  List<T> distinct() {
    return toSet().toList();
  }

  /// 根据条件去重
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    return where((item) {
      final key = keySelector(item);
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }
}

/// 颜色扩展
extension ColorExtensions on Color {
  /// 转换为十六进制字符串
  String toHex() {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// 调整透明度
  Color withOpacityValue(double opacity) {
    return withAlpha((opacity * 255).round());
  }

  /// 变亮
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// 变暗
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

/// 通用工具类
class CommonUtils {
  CommonUtils._();

  /// 生成随机字符串
  static String randomString(int length, {String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'}) {
    final random = Random();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// 生成随机数字验证码
  static String randomCode(int length) {
    final random = Random();
    return List.generate(length, (_) => random.nextInt(10)).join();
  }

  /// 深度复制 Map
  static Map<String, dynamic> deepCopyMap(Map<String, dynamic> original) {
    return jsonDecode(jsonEncode(original)) as Map<String, dynamic>;
  }

  /// 验证手机号
  static bool isValidPhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  /// 验证邮箱
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 计算两点之间的距离（米）
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371000; // 地球半径（米）
    
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// 计算两点之间的方位角
  static double calculateBearing(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLng = _toRadians(lng2 - lng1);
    
    final y = sin(dLng) * cos(_toRadians(lat2));
    final x = cos(_toRadians(lat1)) * sin(_toRadians(lat2)) -
        sin(_toRadians(lat1)) * cos(_toRadians(lat2)) * cos(dLng);
    
    final bearing = atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  /// 角度转弧度
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// 弧度转角度
  static double _toDegrees(double radians) {
    return radians * 180 / pi;
  }

  /// 防抖函数
  static VoidCallback debounce(
    VoidCallback action, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Timer? timer;
    
    return () {
      timer?.cancel();
      timer = Timer(delay, action);
    };
  }

  /// 节流函数
  static VoidCallback throttle(
    VoidCallback action, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    bool isThrottled = false;
    
    return () {
      if (isThrottled) return;
      
      isThrottled = true;
      action();
      
      Timer(delay, () {
        isThrottled = false;
      });
    };
  }

  /// 延迟执行
  static Future<void> delay(Duration duration) {
    return Future.delayed(duration);
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// 格式化数字（带千分位）
  static String formatNumber(num number) {
    return NumberFormat('#,###').format(number);
  }

  /// 安全解析 JSON
  static dynamic safeJsonDecode(String jsonString, {dynamic defaultValue}) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return defaultValue;
    }
  }

  /// 安全转换为字符串
  static String safeToString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// 安全转换为整数
  static int safeToInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// 安全转换为双精度浮点数
  static double safeToDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}
