/// 位置快照
class LocationSnapshot {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double accuracy;
  final String signalSource; // 'gps', 'network', 'cached'

  const LocationSnapshot({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.accuracy,
    required this.signalSource,
  });

  factory LocationSnapshot.fromJson(Map<String, dynamic> json) {
    return LocationSnapshot(
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      altitude: json['altitude'] as double?,
      accuracy: json['accuracy'] as double,
      signalSource: json['signalSource'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'signalSource': signalSource,
    };
  }

  @override
  String toString() {
    return 'LocationSnapshot(timestamp: $timestamp, lat: $latitude, lng: $longitude, source: $signalSource)';
  }
}

/// Lifeline会话状态枚举
enum LifelineStatus {
  active,      // 运行中
  completed,   // 正常完成
  overdue,     // 已超时
  cancelled,   // 已取消
}

/// Lifeline会话模型
class LifelineSession {
  final String id;
  final String? routeId;
  final String? routeName;
  
  // 设置信息
  final List<String> contactIds;
  final int estimatedDurationMinutes;
  final int bufferTimeMinutes;
  
  // 时间记录
  final DateTime startTime;
  final DateTime estimatedEndTime;
  final DateTime? actualEndTime;
  
  // 状态
  final LifelineStatus status;
  
  // 位置追踪
  final List<LocationSnapshot> locationSnapshots;
  final LocationSnapshot? lastKnownLocation;
  final DateTime? lastSignalTime;
  
  // 分享
  final String? shareToken;
  final String? shareUrl;

  const LifelineSession({
    required this.id,
    this.routeId,
    this.routeName,
    required this.contactIds,
    required this.estimatedDurationMinutes,
    required this.bufferTimeMinutes,
    required this.startTime,
    required this.estimatedEndTime,
    this.actualEndTime,
    this.status = LifelineStatus.active,
    this.locationSnapshots = const [],
    this.lastKnownLocation,
    this.lastSignalTime,
    this.shareToken,
    this.shareUrl,
  });

  /// 是否激活中
  bool get isActive => status == LifelineStatus.active;

  /// 获取报警触发时间（预计结束时间 + 缓冲时间）
  DateTime get alarmTriggerTime => estimatedEndTime.add(Duration(minutes: bufferTimeMinutes));

  /// 距离报警触发还有多久
  Duration? get timeUntilAlarm {
    final now = DateTime.now();
    final diff = alarmTriggerTime.difference(now);
    return diff.isNegative ? null : diff;
  }

  /// 距离预计结束还有多久
  Duration? get timeUntilEstimatedEnd {
    final now = DateTime.now();
    final diff = estimatedEndTime.difference(now);
    return diff.isNegative ? null : diff;
  }

  factory LifelineSession.fromJson(Map<String, dynamic> json) {
    return LifelineSession(
      id: json['id'] as String,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      contactIds: List<String>.from(json['contactIds'] as List),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int,
      bufferTimeMinutes: json['bufferTimeMinutes'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      estimatedEndTime: DateTime.parse(json['estimatedEndTime'] as String),
      actualEndTime: json['actualEndTime'] != null 
          ? DateTime.parse(json['actualEndTime'] as String) 
          : null,
      status: LifelineStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LifelineStatus.active,
      ),
      locationSnapshots: (json['locationSnapshots'] as List? ?? [])
          .map((e) => LocationSnapshot.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastKnownLocation: json['lastKnownLocation'] != null
          ? LocationSnapshot.fromJson(json['lastKnownLocation'] as Map<String, dynamic>)
          : null,
      lastSignalTime: json['lastSignalTime'] != null
          ? DateTime.parse(json['lastSignalTime'] as String)
          : null,
      shareToken: json['shareToken'] as String?,
      shareUrl: json['shareUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'routeName': routeName,
      'contactIds': contactIds,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'bufferTimeMinutes': bufferTimeMinutes,
      'startTime': startTime.toIso8601String(),
      'estimatedEndTime': estimatedEndTime.toIso8601String(),
      'actualEndTime': actualEndTime?.toIso8601String(),
      'status': status.name,
      'locationSnapshots': locationSnapshots.map((e) => e.toJson()).toList(),
      'lastKnownLocation': lastKnownLocation?.toJson(),
      'lastSignalTime': lastSignalTime?.toIso8601String(),
      'shareToken': shareToken,
      'shareUrl': shareUrl,
    };
  }

  LifelineSession copyWith({
    String? id,
    String? routeId,
    String? routeName,
    List<String>? contactIds,
    int? estimatedDurationMinutes,
    int? bufferTimeMinutes,
    DateTime? startTime,
    DateTime? estimatedEndTime,
    DateTime? actualEndTime,
    LifelineStatus? status,
    List<LocationSnapshot>? locationSnapshots,
    LocationSnapshot? lastKnownLocation,
    DateTime? lastSignalTime,
    String? shareToken,
    String? shareUrl,
  }) {
    return LifelineSession(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      contactIds: contactIds ?? this.contactIds,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      bufferTimeMinutes: bufferTimeMinutes ?? this.bufferTimeMinutes,
      startTime: startTime ?? this.startTime,
      estimatedEndTime: estimatedEndTime ?? this.estimatedEndTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      status: status ?? this.status,
      locationSnapshots: locationSnapshots ?? this.locationSnapshots,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      lastSignalTime: lastSignalTime ?? this.lastSignalTime,
      shareToken: shareToken ?? this.shareToken,
      shareUrl: shareUrl ?? this.shareUrl,
    );
  }

  @override
  String toString() {
    return 'LifelineSession(id: $id, status: $status, route: $routeName)';
  }
}
