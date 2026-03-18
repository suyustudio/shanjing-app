import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/eta_record.dart';

/// 智能ETA服务
/// 根据历史数据计算推荐用时，支持动态调整
class SmartEtaService {
  static const String _recordsKey = 'smart_eta_records';
  static const String _userSettingsKey = 'smart_eta_settings';
  static const int _maxRecordsPerRoute = 20; // 每路线最多保存记录数
  static const int _minRecordsForReliableEta = 3; // 可靠ETA所需的最少记录数

  static final SmartEtaService _instance = SmartEtaService._internal();
  factory SmartEtaService() => _instance;
  SmartEtaService._internal();

  SharedPreferences? _prefs;

  /// 用户设置
  SmartEtaSettings _settings = SmartEtaSettings();
  SmartEtaSettings get settings => _settings;

  /// 初始化服务
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      final jsonString = _prefs?.getString(_userSettingsKey);
      if (jsonString != null) {
        _settings = SmartEtaSettings.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      _settings = SmartEtaSettings();
    }
  }

  /// 保存设置
  Future<void> saveSettings(SmartEtaSettings settings) async {
    await initialize();
    _settings = settings;
    await _prefs?.setString(_userSettingsKey, jsonEncode(settings.toJson()));
  }

  /// 获取推荐ETA
  /// [routeId] 路线ID
  /// [distanceMeters] 路线距离（米）
  /// [elevationGain] 累计爬升（米）
  Future<EtaRecommendation> getRecommendedEta(
    String routeId, {
    double? distanceMeters,
    double? elevationGain,
  }) async {
    await initialize();

    final records = await _getRouteRecords(routeId);
    
    if (records.isEmpty) {
      // 无历史记录，返回默认值
      return EtaRecommendation(
        routeId: routeId,
        recommendedDuration: _estimateFromRouteData(distanceMeters, elevationGain),
        confidence: 0.0,
        source: EtaSource.routeData,
        message: '基于路线数据估算',
      );
    }

    // 计算基础平均用时
    final avgDuration = _calculateAverageDuration(records);
    
    // 应用调整因子
    final adjustedDuration = _applyAdjustments(avgDuration, records);
    
    // 计算置信度
    final confidence = _calculateConfidence(records);

    return EtaRecommendation(
      routeId: routeId,
      recommendedDuration: adjustedDuration,
      confidence: confidence,
      source: confidence > 0.7 
          ? EtaSource.historicalData 
          : EtaSource.mixed,
      basedOnRecords: records.length,
      message: '基于 ${records.length} 次历史记录',
      statistics: _calculateStatistics(records),
    );
  }

  /// 根据当前速度动态计算ETA
  Duration calculateDynamicEta({
    required double currentSpeed, // m/s
    required double remainingDistance, // meters
    Duration? baseEta,
  }) {
    if (currentSpeed <= 0) {
      return baseEta ?? const Duration(hours: 1);
    }

    // 基于当前速度计算
    final seconds = remainingDistance / currentSpeed;
    final speedBasedEta = Duration(seconds: seconds.ceil());

    if (baseEta == null) {
      return speedBasedEta;
    }

    // 结合基础ETA和实时速度（加权平均）
    final baseSeconds = baseEta.inSeconds;
    final speedSeconds = speedBasedEta.inSeconds;
    
    // 权重：已完成比例越高，当前速度权重越大
    // 简单起见，使用固定权重
    const speedWeight = 0.6;
    const baseWeight = 0.4;
    
    final adjustedSeconds = (speedSeconds * speedWeight + baseSeconds * baseWeight).ceil();
    
    return Duration(seconds: adjustedSeconds);
  }

  /// 记录实际用时
  Future<bool> recordActualDuration({
    required String routeId,
    required Duration actualDuration,
    required DateTime startTime,
    required DateTime endTime,
    double? distanceMeters,
    WeatherCondition? weather,
    int? groupSize,
    String? notes,
  }) async {
    await initialize();

    try {
      final record = EtaRecord.create(
        routeId: routeId,
        userId: await _getUserId(),
        actualDuration: actualDuration,
        distanceMeters: distanceMeters ?? 0,
        startTime: startTime,
        endTime: endTime,
        weather: weather,
        groupSize: groupSize,
        notes: notes,
      );

      await _addRecord(record);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取路线的历史记录
  Future<List<EtaRecord>> getRouteHistory(String routeId) async {
    await initialize();
    return _getRouteRecords(routeId);
  }

  /// 获取所有历史记录
  Future<List<EtaRecord>> getAllHistory() async {
    await initialize();
    
    final allRecords = await _getAllRecords();
    // 按时间倒序排列
    allRecords.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return allRecords;
  }

  /// 清除历史记录
  Future<bool> clearHistory({String? routeId}) async {
    await initialize();

    try {
      if (routeId == null) {
        // 清除所有记录
        await _prefs?.remove(_recordsKey);
      } else {
        // 清除特定路线的记录
        final allRecords = await _getAllRecords();
        allRecords.removeWhere((r) => r.routeId == routeId);
        await _saveAllRecords(allRecords);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取ETA统计信息
  Future<EtaStatistics?> getStatistics(String routeId) async {
    await initialize();

    final records = await _getRouteRecords(routeId);
    if (records.isEmpty) return null;

    return _calculateStatistics(records);
  }

  // ========== 私有方法 ==========

  /// 获取路线的历史记录
  Future<List<EtaRecord>> _getRouteRecords(String routeId) async {
    final allRecords = await _getAllRecords();
    return allRecords.where((r) => r.routeId == routeId).toList();
  }

  /// 获取所有记录
  Future<List<EtaRecord>> _getAllRecords() async {
    final jsonString = _prefs?.getString(_recordsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => EtaRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 保存所有记录
  Future<void> _saveAllRecords(List<EtaRecord> records) async {
    final jsonString = jsonEncode(records.map((e) => e.toJson()).toList());
    await _prefs?.setString(_recordsKey, jsonString);
  }

  /// 添加记录（限制数量）
  Future<void> _addRecord(EtaRecord record) async {
    var allRecords = await _getAllRecords();
    
    // 添加新记录
    allRecords.add(record);
    
    // 按路线分组并限制数量
    final grouped = <String, List<EtaRecord>>{};
    for (final r in allRecords) {
      grouped.putIfAbsent(r.routeId, () => []).add(r);
    }
    
    // 每路线只保留最近N条
    final limitedRecords = <EtaRecord>[];
    for (final entries in grouped.values) {
      entries.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      limitedRecords.addAll(entries.take(_maxRecordsPerRoute));
    }
    
    await _saveAllRecords(limitedRecords);
  }

  /// 计算平均用时
  Duration _calculateAverageDuration(List<EtaRecord> records) {
    if (records.isEmpty) return const Duration(hours: 1);

    // 使用中位数来减少异常值影响
    final durations = records.map((r) => r.actualDuration.inSeconds).toList()..sort();
    
    if (durations.length.isOdd) {
      final medianSeconds = durations[durations.length ~/ 2];
      return Duration(seconds: medianSeconds);
    } else {
      final mid = durations.length ~/ 2;
      final medianSeconds = (durations[mid - 1] + durations[mid]) ~/ 2;
      return Duration(seconds: medianSeconds);
    }
  }

  /// 应用调整因子
  Duration _applyAdjustments(Duration baseDuration, List<EtaRecord> records) {
    var adjustedSeconds = baseDuration.inSeconds.toDouble();

    // 1. 时间段调整
    final currentHour = DateTime.now().hour;
    if (currentHour >= 6 && currentHour <= 10) {
      // 早晨：可能体力好，稍微快一点
      adjustedSeconds *= 0.95;
    } else if (currentHour >= 17 && currentHour <= 20) {
      // 傍晚：可能疲劳，稍微慢一点
      adjustedSeconds *= 1.05;
    }

    // 2. 季节调整
    final currentSeason = _getCurrentSeason();
    switch (currentSeason) {
      case Season.summer:
        // 夏天炎热，可能慢一些
        adjustedSeconds *= 1.1;
        break;
      case Season.winter:
        // 冬天寒冷，可能慢一些
        adjustedSeconds *= 1.05;
        break;
      default:
        break;
    }

    // 3. 用户自定义调整
    adjustedSeconds *= (1 + _settings.paceAdjustment);

    // 4. 安全系数（默认增加10%缓冲）
    adjustedSeconds *= (1 + _settings.safetyBuffer);

    return Duration(seconds: adjustedSeconds.ceil());
  }

  /// 计算置信度
  double _calculateConfidence(List<EtaRecord> records) {
    if (records.length < _minRecordsForReliableEta) {
      return records.length / _minRecordsForReliableEta * 0.5;
    }

    // 计算变异系数（标准差/均值）
    final durations = records.map((r) => r.actualDuration.inSeconds.toDouble()).toList();
    final mean = durations.reduce((a, b) => a + b) / durations.length;
    
    if (mean == 0) return 0.5;

    final variance = durations
        .map((d) => pow(d - mean, 2))
        .reduce((a, b) => a + b) / durations.length;
    final stdDev = sqrt(variance);
    final cv = stdDev / mean;

    // 变异系数越小，置信度越高
    // CV < 0.1: 高置信度
    // CV > 0.3: 低置信度
    if (cv < 0.1) return 0.95;
    if (cv > 0.3) return 0.5;
    return 0.95 - (cv - 0.1) / 0.2 * 0.45;
  }

  /// 计算统计信息
  EtaStatistics _calculateStatistics(List<EtaRecord> records) {
    final durations = records.map((r) => r.actualDuration).toList();
    final avgDuration = _calculateAverageDuration(records);
    
    durations.sort((a, b) => a.inSeconds.compareTo(b.inSeconds));
    final minDuration = durations.first;
    final maxDuration = durations.last;
    
    final avgSpeed = records.map((r) => r.avgSpeed).reduce((a, b) => a + b) / records.length;
    
    // 推荐ETA = 平均值 + 安全系数
    final recommendedEta = Duration(
      seconds: (avgDuration.inSeconds * (1 + _settings.safetyBuffer)).ceil(),
    );

    return EtaStatistics(
      routeId: records.first.routeId,
      recordCount: records.length,
      averageDuration: avgDuration,
      minDuration: minDuration,
      maxDuration: maxDuration,
      averageSpeed: avgSpeed,
      recommendedEta: recommendedEta,
      confidence: _calculateConfidence(records),
    );
  }

  /// 从路线数据估算
  Duration _estimateFromRouteData(double? distanceMeters, double? elevationGain) {
    // 默认速度：3km/h = 0.83 m/s
    const defaultSpeed = 0.83;
    
    var estimatedSeconds = 0.0;
    
    if (distanceMeters != null && distanceMeters > 0) {
      estimatedSeconds = distanceMeters / defaultSpeed;
    } else {
      // 默认1小时
      estimatedSeconds = 3600;
    }

    // 考虑爬升（每100米增加10分钟）
    if (elevationGain != null && elevationGain > 0) {
      estimatedSeconds += (elevationGain / 100) * 600;
    }

    // 增加安全系数
    estimatedSeconds *= (1 + _settings.safetyBuffer);

    return Duration(seconds: estimatedSeconds.ceil());
  }

  /// 获取当前季节
  Season _getCurrentSeason() {
    final month = DateTime.now().month;
    switch (month) {
      case 3:
      case 4:
      case 5:
        return Season.spring;
      case 6:
      case 7:
      case 8:
        return Season.summer;
      case 9:
      case 10:
      case 11:
        return Season.autumn;
      case 12:
      case 1:
      case 2:
        return Season.winter;
      default:
        return Season.unknown;
    }
  }

  /// 获取用户ID
  Future<String> _getUserId() async {
    // 实际项目中应从用户服务获取
    return 'current_user';
  }
}

/// ETA推荐结果
class EtaRecommendation {
  final String routeId;
  final Duration recommendedDuration;
  final double confidence; // 0.0 - 1.0
  final EtaSource source;
  final int? basedOnRecords;
  final String message;
  final EtaStatistics? statistics;

  EtaRecommendation({
    required this.routeId,
    required this.recommendedDuration,
    required this.confidence,
    required this.source,
    this.basedOnRecords,
    required this.message,
    this.statistics,
  });

  String get formattedDuration {
    final hours = recommendedDuration.inHours;
    final minutes = recommendedDuration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}小时${minutes > 0 ? ' ${minutes}分钟' : ''}';
    } else {
      return '${minutes}分钟';
    }
  }

  String get confidenceText {
    if (confidence >= 0.8) return '高置信度';
    if (confidence >= 0.5) return '中等置信度';
    return '低置信度';
  }

  Color get confidenceColor {
    if (confidence >= 0.8) return const Color(0xFF22C55E);
    if (confidence >= 0.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  String toString() {
    return 'EtaRecommendation($routeId: $formattedDuration, confidence: ${(confidence * 100).toStringAsFixed(0)}%)';
  }
}

/// 智能ETA用户设置
class SmartEtaSettings {
  bool useHistoricalData;
  bool considerWeather;
  bool considerTimeOfDay;
  double confidenceThreshold;
  Duration minRecommendedDuration;
  Duration maxRecommendedDuration;

  SmartEtaSettings({
    this.useHistoricalData = true,
    this.considerWeather = true,
    this.considerTimeOfDay = true,
    this.confidenceThreshold = 0.5,
    this.minRecommendedDuration = const Duration(minutes: 15),
    this.maxRecommendedDuration = const Duration(hours: 8),
  });

  factory SmartEtaSettings.fromJson(Map<String, dynamic> json) {
    return SmartEtaSettings(
      useHistoricalData: json['useHistoricalData'] ?? true,
      considerWeather: json['considerWeather'] ?? true,
      considerTimeOfDay: json['considerTimeOfDay'] ?? true,
      confidenceThreshold: json['confidenceThreshold'] ?? 0.5,
      minRecommendedDuration: Duration(minutes: json['minRecommendedDurationMinutes'] ?? 15),
      maxRecommendedDuration: Duration(hours: json['maxRecommendedDurationHours'] ?? 8),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'useHistoricalData': useHistoricalData,
      'considerWeather': considerWeather,
      'considerTimeOfDay': considerTimeOfDay,
      'confidenceThreshold': confidenceThreshold,
      'minRecommendedDurationMinutes': minRecommendedDuration.inMinutes,
      'maxRecommendedDurationHours': maxRecommendedDuration.inHours,
    };
  }
}
