import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

/// SOS事件模型
/// 用于缓存离线状态下的SOS报警信息
class SosEvent {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime? sentAt;
  final SosEventStatus status;
  final SosLocation location;
  final String? note;
  final List<String> contactIds;
  final int retryCount;
  final DateTime? lastRetryAt;
  final String? errorMessage;

  // 加密密钥（实际项目中应从安全存储获取）
  static const String _encryptionKey = 'shanjing_sos_event_key_32bytes!';

  SosEvent({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.sentAt,
    this.status = SosEventStatus.pending,
    required this.location,
    this.note,
    required this.contactIds,
    this.retryCount = 0,
    this.lastRetryAt,
    this.errorMessage,
  });

  /// 创建新的SOS事件
  factory SosEvent.create({
    required String userId,
    required SosLocation location,
    String? note,
    required List<String> contactIds,
  }) {
    return SosEvent(
      id: 'sos_${DateTime.now().millisecondsSinceEpoch}_${userId.hashCode}',
      userId: userId,
      createdAt: DateTime.now(),
      location: location,
      note: note,
      contactIds: contactIds,
    );
  }

  /// 从JSON解析
  factory SosEvent.fromJson(Map<String, dynamic> json) {
    return SosEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt'] as String) : null,
      status: SosEventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SosEventStatus.pending,
      ),
      location: SosLocation.fromJson(json['location'] as Map<String, dynamic>),
      note: json['note'] as String?,
      contactIds: List<String>.from(json['contactIds'] as List),
      retryCount: json['retryCount'] as int? ?? 0,
      lastRetryAt: json['lastRetryAt'] != null 
          ? DateTime.parse(json['lastRetryAt'] as String) 
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'status': status.name,
      'location': location.toJson(),
      'note': note,
      'contactIds': contactIds,
      'retryCount': retryCount,
      'lastRetryAt': lastRetryAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  /// 加密存储
  String encryptForStorage() {
    try {
      final key = encrypt.Key.fromUtf8(_encryptionKey.substring(0, 32));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      final jsonString = jsonEncode(toJson());
      final encrypted = encrypter.encrypt(jsonString, iv: iv);
      
      return '${base64Encode(iv.bytes)}.${encrypted.base64}';
    } catch (e) {
      // 加密失败时返回明文（仅用于开发调试）
      return 'PLAIN:${jsonEncode(toJson())}';
    }
  }

  /// 解密读取
  static SosEvent? decryptFromStorage(String encryptedData) {
    try {
      if (encryptedData.startsWith('PLAIN:')) {
        // 明文存储（仅用于开发调试）
        final jsonString = encryptedData.substring(6);
        return SosEvent.fromJson(jsonDecode(jsonString));
      }

      final parts = encryptedData.split('.');
      if (parts.length != 2) return null;

      final key = encrypt.Key.fromUtf8(_encryptionKey.substring(0, 32));
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      
      final decrypted = encrypter.decrypt64(parts[1], iv: iv);
      return SosEvent.fromJson(jsonDecode(decrypted));
    } catch (e) {
      return null;
    }
  }

  /// 复制并修改
  SosEvent copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? sentAt,
    SosEventStatus? status,
    SosLocation? location,
    String? note,
    List<String>? contactIds,
    int? retryCount,
    DateTime? lastRetryAt,
    String? errorMessage,
  }) {
    return SosEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      location: location ?? this.location,
      note: note ?? this.note,
      contactIds: contactIds ?? this.contactIds,
      retryCount: retryCount ?? this.retryCount,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 检查是否已过期（超过7天）
  bool get isExpired {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return createdAt.isBefore(sevenDaysAgo);
  }

  /// 检查是否可以重试
  bool get canRetry {
    if (status == SosEventStatus.sent) return false;
    if (retryCount >= 5) return false;
    if (isExpired) return false;
    
    // 限制重试频率：每次重试间隔至少5分钟
    if (lastRetryAt != null) {
      final nextRetryTime = lastRetryAt!.add(const Duration(minutes: 5));
      if (DateTime.now().isBefore(nextRetryTime)) return false;
    }
    
    return true;
  }

  @override
  String toString() {
    return 'SosEvent(id: $id, status: ${status.name}, createdAt: $createdAt)';
  }
}

/// SOS事件状态
enum SosEventStatus {
  pending,     // 待发送
  sending,     // 发送中
  sent,        // 已发送
  failed,      // 发送失败
  expired,     // 已过期
}

/// SOS位置信息
class SosLocation {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double accuracy;
  final DateTime timestamp;
  final String? address;
  final String? routeId;
  final String? routeName;

  SosLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.accuracy,
    required this.timestamp,
    this.address,
    this.routeId,
    this.routeName,
  });

  factory SosLocation.fromJson(Map<String, dynamic> json) {
    return SosLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      altitude: json['altitude'] as double?,
      accuracy: json['accuracy'] as double? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      address: json['address'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
      'routeId': routeId,
      'routeName': routeName,
    };
  }

  @override
  String toString() {
    return 'SosLocation($latitude, $longitude)';
  }
}
