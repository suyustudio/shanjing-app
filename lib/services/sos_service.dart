import 'api_client.dart';
import 'api_config.dart';

/// 位置信息
class Location {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;

  Location({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (altitude != null) 'altitude': altitude,
    if (accuracy != null) 'accuracy': accuracy,
  };
}

/// SOS 服务
class SosService {
  static final SosService _instance = SosService._internal();
  factory SosService() => _instance;
  SosService._internal();

  final ApiClient _client = ApiClient();

  /// 触发 SOS
  /// 
  /// 调用后端 POST /sos/trigger
  /// 返回 true 表示成功，false 表示失败
  Future<bool> triggerSos(Location location) async {
    try {
      final response = await _client.post(
        '/sos/trigger',
        body: location.toJson(),
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }
}
