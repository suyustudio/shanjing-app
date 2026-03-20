// recording_model.dart
// 山径APP - 轨迹录制数据模型

import 'dart:convert';

/// 录制状态枚举
enum RecordingStatus {
  /// 空闲/未开始
  idle,
  /// 录制中
  recording,
  /// 已暂停
  paused,
  /// 已结束
  finished,
}

/// POI类型枚举
enum PoiType {
  /// 起点
  start,
  /// 终点
  end,
  /// 路口
  junction,
  /// 观景点
  viewpoint,
  /// 卫生间
  restroom,
  /// 补给点
  supply,
  /// 危险点
  danger,
  /// 休息点
  rest,
}

/// POI类型扩展
extension PoiTypeExtension on PoiType {
  String get displayName {
    switch (this) {
      case PoiType.start:
        return '起点';
      case PoiType.end:
        return '终点';
      case PoiType.junction:
        return '路口';
      case PoiType.viewpoint:
        return '观景点';
      case PoiType.restroom:
        return '卫生间';
      case PoiType.supply:
        return '补给点';
      case PoiType.danger:
        return '危险点';
      case PoiType.rest:
        return '休息点';
    }
  }

  String get icon {
    switch (this) {
      case PoiType.start:
        return 'flag';
      case PoiType.end:
        return 'sports_score';
      case PoiType.junction:
        return 'call_split';
      case PoiType.viewpoint:
        return 'photo_camera';
      case PoiType.restroom:
        return 'wc';
      case PoiType.supply:
        return 'local_drink';
      case PoiType.danger:
        return 'warning';
      case PoiType.rest:
        return 'chair';
    }
  }
}

/// GPS轨迹点
class TrackPoint {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final double? speed;
  final DateTime timestamp;

  TrackPoint({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    this.speed,
    required this.timestamp,
  });

  factory TrackPoint.fromJson(Map<String, dynamic> json) {
    return TrackPoint(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      altitude: (json['altitude'] ?? 0).toDouble(),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      speed: json['speed']?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// POI标记点
class PoiMarker {
  final String id;
  final double latitude;
  final double longitude;
  final double altitude;
  final PoiType type;
  final String? name;
  final String? description;
  final List<String> photoUrls;
  final DateTime createdAt;

  PoiMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.type,
    this.name,
    this.description,
    this.photoUrls = const [],
    required this.createdAt,
  });

  factory PoiMarker.fromJson(Map<String, dynamic> json) {
    return PoiMarker(
      id: json['id'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      altitude: (json['altitude'] ?? 0).toDouble(),
      type: PoiType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PoiType.viewpoint,
      ),
      name: json['name'],
      description: json['description'],
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'type': type.name,
      'name': name,
      'description': description,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PoiMarker copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? altitude,
    PoiType? type,
    String? name,
    String? description,
    List<String>? photoUrls,
    DateTime? createdAt,
  }) {
    return PoiMarker(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 轨迹录制会话
class RecordingSession {
  final String id;
  final String? userId;
  final String? trailName;
  final RecordingStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final double totalDistanceMeters;
  final double elevationGain;
  final double elevationLoss;
  final List<TrackPoint> trackPoints;
  final List<PoiMarker> pois;
  final bool isUploaded;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecordingSession({
    required this.id,
    this.userId,
    this.trailName,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.totalDistanceMeters,
    required this.elevationGain,
    required this.elevationLoss,
    this.trackPoints = const [],
    this.pois = const [],
    this.isUploaded = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecordingSession.fromJson(Map<String, dynamic> json) {
    return RecordingSession(
      id: json['id'] ?? '',
      userId: json['userId'],
      trailName: json['trailName'],
      status: RecordingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RecordingStatus.idle,
      ),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null,
      durationSeconds: json['durationSeconds'] ?? 0,
      totalDistanceMeters: (json['totalDistanceMeters'] ?? 0).toDouble(),
      elevationGain: (json['elevationGain'] ?? 0).toDouble(),
      elevationLoss: (json['elevationLoss'] ?? 0).toDouble(),
      trackPoints: (json['trackPoints'] as List? ?? [])
          .map((p) => TrackPoint.fromJson(p))
          .toList(),
      pois: (json['pois'] as List? ?? [])
          .map((p) => PoiMarker.fromJson(p))
          .toList(),
      isUploaded: json['isUploaded'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'trailName': trailName,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'totalDistanceMeters': totalDistanceMeters,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
      'trackPoints': trackPoints.map((p) => p.toJson()).toList(),
      'pois': pois.map((p) => p.toJson()).toList(),
      'isUploaded': isUploaded,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RecordingSession copyWith({
    String? id,
    String? userId,
    String? trailName,
    RecordingStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    double? totalDistanceMeters,
    double? elevationGain,
    double? elevationLoss,
    List<TrackPoint>? trackPoints,
    List<PoiMarker>? pois,
    bool? isUploaded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trailName: trailName ?? this.trailName,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      trackPoints: trackPoints ?? this.trackPoints,
      pois: pois ?? this.pois,
      isUploaded: isUploaded ?? this.isUploaded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取格式化的时长显示
  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 获取格式化的距离显示（公里）
  String get formattedDistance {
    if (totalDistanceMeters < 1000) {
      return '${totalDistanceMeters.toStringAsFixed(0)} 米';
    } else {
      return '${(totalDistanceMeters / 1000).toStringAsFixed(2)} 公里';
    }
  }

  /// 获取照片数量
  int get photoCount {
    return pois.fold(0, (sum, poi) => sum + poi.photoUrls.length);
  }
}

/// 录制统计数据
class RecordingStats {
  final double currentSpeed;
  final double averageSpeed;
  final double maxSpeed;
  final double currentAltitude;
  final double maxAltitude;
  final double minAltitude;
  final int pointCount;

  RecordingStats({
    this.currentSpeed = 0,
    this.averageSpeed = 0,
    this.maxSpeed = 0,
    this.currentAltitude = 0,
    this.maxAltitude = 0,
    this.minAltitude = 0,
    this.pointCount = 0,
  });

  factory RecordingStats.empty() => RecordingStats();
}

/// 轨迹上传请求
class TrailUploadRequest {
  final String sessionId;
  final String trailName;
  final String? description;
  final String city;
  final String district;
  final String difficulty;
  final List<String> tags;

  TrailUploadRequest({
    required this.sessionId,
    required this.trailName,
    this.description,
    required this.city,
    required this.district,
    required this.difficulty,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'trailName': trailName,
      'description': description,
      'city': city,
      'district': district,
      'difficulty': difficulty,
      'tags': tags,
    };
  }
}

/// 轨迹上传响应
class TrailUploadResponse {
  final bool success;
  final String? trailId;
  final String? message;
  final String? error;

  TrailUploadResponse({
    required this.success,
    this.trailId,
    this.message,
    this.error,
  });

  factory TrailUploadResponse.fromJson(Map<String, dynamic> json) {
    return TrailUploadResponse(
      success: json['success'] ?? false,
      trailId: json['data']?['trailId'],
      message: json['message'],
      error: json['error']?['message'],
    );
  }
}

/// 本地存储的录制数据（用于离线保存）
class LocalRecordingData {
  final List<RecordingSession> sessions;

  LocalRecordingData({
    this.sessions = const [],
  });

  factory LocalRecordingData.fromJson(Map<String, dynamic> json) {
    return LocalRecordingData(
      sessions: (json['sessions'] as List? ?? [])
          .map((s) => RecordingSession.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory LocalRecordingData.fromJsonString(String jsonString) {
    return LocalRecordingData.fromJson(jsonDecode(jsonString));
  }
}
