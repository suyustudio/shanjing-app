import 'dart:convert';

/// ETA历史记录模型
/// 用于智能ETA推荐算法
class EtaRecord {
  final String id;
  final String routeId;
  final String userId;
  final DateTime recordedAt;
  final Duration actualDuration;
  final double distanceMeters;
  final double avgSpeed; // m/s
  final DateTime startTime;
  final DateTime endTime;
  final WeatherCondition? weather;
  final Season season;
  final DayOfWeek dayOfWeek;
  final int? groupSize;
  final String? notes;

  EtaRecord({
    required this.id,
    required this.routeId,
    required this.userId,
    required this.recordedAt,
    required this.actualDuration,
    required this.distanceMeters,
    required this.avgSpeed,
    required this.startTime,
    required this.endTime,
    this.weather,
    required this.season,
    required this.dayOfWeek,
    this.groupSize,
    this.notes,
  });

  /// 创建新记录
  factory EtaRecord.create({
    required String routeId,
    required String userId,
    required Duration actualDuration,
    required double distanceMeters,
    required DateTime startTime,
    required DateTime endTime,
    WeatherCondition? weather,
    int? groupSize,
    String? notes,
  }) {
    final avgSpeed = distanceMeters / actualDuration.inSeconds;
    
    return EtaRecord(
      id: 'eta_${DateTime.now().millisecondsSinceEpoch}_${userId.hashCode}',
      routeId: routeId,
      userId: userId,
      recordedAt: DateTime.now(),
      actualDuration: actualDuration,
      distanceMeters: distanceMeters,
      avgSpeed: avgSpeed,
      startTime: startTime,
      endTime: endTime,
      weather: weather,
      season: _getSeason(startTime),
      dayOfWeek: _getDayOfWeek(startTime),
      groupSize: groupSize,
      notes: notes,
    );
  }

  /// 从JSON解析
  factory EtaRecord.fromJson(Map<String, dynamic> json) {
    return EtaRecord(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      userId: json['userId'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      actualDuration: Duration(seconds: json['actualDurationSeconds'] as int),
      distanceMeters: json['distanceMeters'] as double,
      avgSpeed: json['avgSpeed'] as double,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      weather: json['weather'] != null 
          ? WeatherCondition.values.firstWhere(
              (e) => e.name == json['weather'],
              orElse: () => WeatherCondition.unknown,
            )
          : null,
      season: Season.values.firstWhere(
        (e) => e.name == json['season'],
        orElse: () => Season.unknown,
      ),
      dayOfWeek: DayOfWeek.values.firstWhere(
        (e) => e.name == json['dayOfWeek'],
        orElse: () => DayOfWeek.unknown,
      ),
      groupSize: json['groupSize'] as int?,
      notes: json['notes'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'userId': userId,
      'recordedAt': recordedAt.toIso8601String(),
      'actualDurationSeconds': actualDuration.inSeconds,
      'distanceMeters': distanceMeters,
      'avgSpeed': avgSpeed,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'weather': weather?.name,
      'season': season.name,
      'dayOfWeek': dayOfWeek.name,
      'groupSize': groupSize,
      'notes': notes,
    };
  }

  /// 获取季节
  static Season _getSeason(DateTime date) {
    final month = date.month;
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

  /// 获取星期几
  static DayOfWeek _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.unknown;
    }
  }

  /// 复制并修改
  EtaRecord copyWith({
    String? id,
    String? routeId,
    String? userId,
    DateTime? recordedAt,
    Duration? actualDuration,
    double? distanceMeters,
    double? avgSpeed,
    DateTime? startTime,
    DateTime? endTime,
    WeatherCondition? weather,
    Season? season,
    DayOfWeek? dayOfWeek,
    int? groupSize,
    String? notes,
  }) {
    return EtaRecord(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      userId: userId ?? this.userId,
      recordedAt: recordedAt ?? this.recordedAt,
      actualDuration: actualDuration ?? this.actualDuration,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weather: weather ?? this.weather,
      season: season ?? this.season,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      groupSize: groupSize ?? this.groupSize,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'EtaRecord(routeId: $routeId, duration: ${actualDuration.inMinutes}min)';
  }
}

/// 天气条件
enum WeatherCondition {
  sunny,      // 晴天
  cloudy,     // 多云
  rainy,      // 雨天
  snowy,      // 雪天
  foggy,      // 雾天
  windy,      // 大风
  unknown,    // 未知
}

/// 季节
enum Season {
  spring,     // 春
  summer,     // 夏
  autumn,     // 秋
  winter,     // 冬
  unknown,    // 未知
}

/// 星期
enum DayOfWeek {
  monday,     // 周一
  tuesday,    // 周二
  wednesday,  // 周三
  thursday,   // 周四
  friday,     // 周五
  saturday,   // 周六
  sunday,     // 周日
  unknown,    // 未知
}

/// ETA统计结果
class EtaStatistics {
  final String routeId;
  final int recordCount;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final double averageSpeed;
  final Duration recommendedEta;
  final double confidence; // 0.0 - 1.0

  EtaStatistics({
    required this.routeId,
    required this.recordCount,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.averageSpeed,
    required this.recommendedEta,
    required this.confidence,
  });

  /// 获取推荐时间的显示文本
  String get formattedRecommendedEta {
    final hours = recommendedEta.inHours;
    final minutes = recommendedEta.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}小时${minutes > 0 ? ' ${minutes}分钟' : ''}';
    } else {
      return '${minutes}分钟';
    }
  }

  @override
  String toString() {
    return 'EtaStatistics(routeId: $routeId, avg: ${averageDuration.inMinutes}min, recommended: $formattedRecommendedEta)';
  }
}
