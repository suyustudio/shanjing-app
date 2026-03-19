import 'api_client.dart';
import 'api_config.dart';
import '../analytics/analytics.dart';

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
    // 埋点：SOS 触发
    AnalyticsService().trackEvent(SosEvents.sosTriggered, params: {
      SosEvents.paramLatitude: location.latitude,
      SosEvents.paramLongitude: location.longitude,
      SosEvents.paramAccuracy: location.accuracy,
    });

    try {
      final response = await _client.post(
        '/sos/trigger',
        body: location.toJson(),
      );
      
      if (response.success) {
        // 埋点：SOS 发送成功
        AnalyticsService().trackEvent(SosEvents.sosSuccess, params: {
          SosEvents.paramLatitude: location.latitude,
          SosEvents.paramLongitude: location.longitude,
        });
      } else {
        // 埋点：SOS 发送失败
        AnalyticsService().trackEvent(SosEvents.sosFailed, params: {
          SosEvents.paramLatitude: location.latitude,
          SosEvents.paramLongitude: location.longitude,
          SosEvents.paramErrorCode: response.errorCode ?? 'SOS_FAILED',
        });
      }
      
      return response.success;
    } catch (e) {
      // 埋点：SOS 发送失败（异常）
      AnalyticsService().trackEvent(SosEvents.sosFailed, params: {
        SosEvents.paramLatitude: location.latitude,
        SosEvents.paramLongitude: location.longitude,
        SosEvents.paramErrorCode: e is ApiException ? (e as ApiException).code : 'NETWORK_ERROR',
      });
      return false;
    }
  }
}
