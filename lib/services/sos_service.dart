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

/// 紧急联系人信息
class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.phone,
  });
}

/// SOS 服务
class SosService {
  static final SosService _instance = SosService._internal();
  factory SosService() => _instance;
  SosService._internal();

  final ApiClient _client = ApiClient();

  /// 获取紧急联系人列表
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    // 实际实现中应从本地存储或后端获取
    // 这里返回示例数据
    return [
      EmergencyContact(name: '紧急联系人1', phone: '138****8888'),
      EmergencyContact(name: '紧急联系人2', phone: '139****9999'),
    ];
  }

  /// 触发 SOS
  ///
  /// [location] 当前位置
  /// [triggerType] 触发方式: auto(倒计时自动) / manual(用户主动)
  /// [countdownRemainingSec] 倒计时剩余秒数
  /// [routeId] 当前导航路线ID（可选）
  /// [sendMethod] 发送方式: sms/push/both/wechat
  /// 返回 true 表示成功，false 表示失败
  Future<bool> triggerSos({
    required Location location,
    required String triggerType,
    required int countdownRemainingSec,
    String? routeId,
    String sendMethod = 'both',
  }) async {
    final triggerTimestamp = DateTime.now().millisecondsSinceEpoch;

    // 获取紧急联系人
    final contacts = await getEmergencyContacts();

    // 调用后端 API
    final apiStopwatch = Stopwatch()..start();
    try {
      final response = await _client.post(
        '/sos/trigger',
        body: {
          ...location.toJson(),
          'contacts': contacts.map((c) => c.phone).toList(),
          'route_id': routeId,
          'send_method': sendMethod,
        },
      );
      apiStopwatch.stop();
      final apiResponseMs = apiStopwatch.elapsedMilliseconds;

      if (response.success) {
        // ✅ 埋点：SOS 触发（在 API 成功后触发）
        AnalyticsService().trackEvent(SosEvents.sosTrigger, params: {
          SosEvents.paramTriggerType: triggerType,
          SosEvents.paramCountdownRemainingSec: countdownRemainingSec,
          SosEvents.paramLocationLat: location.latitude,
          SosEvents.paramLocationLng: location.longitude,
          SosEvents.paramLocationAccuracy: location.accuracy ?? 0.0,
          SosEvents.paramRouteId: routeId ?? '',
          SosEvents.paramContactCount: contacts.length,
          SosEvents.paramSendMethod: sendMethod,
          SosEvents.paramApiResponseMs: apiResponseMs,
          SosEvents.paramTriggerTimestamp: triggerTimestamp,
        });

        // 埋点：SOS 发送成功
        AnalyticsService().trackEvent(SosEvents.sosSuccess, params: {
          SosEvents.paramLocationLat: location.latitude,
          SosEvents.paramLocationLng: location.longitude,
        });
      } else {
        // 埋点：SOS 发送失败
        AnalyticsService().trackEvent(SosEvents.sosFailed, params: {
          SosEvents.paramLocationLat: location.latitude,
          SosEvents.paramLocationLng: location.longitude,
          SosEvents.paramErrorCode: response.errorCode ?? 'SOS_FAILED',
        });
      }

      return response.success;
    } catch (e) {
      apiStopwatch.stop();
      // 埋点：SOS 发送失败（异常）
      AnalyticsService().trackEvent(SosEvents.sosFailed, params: {
        SosEvents.paramLocationLat: location.latitude,
        SosEvents.paramLocationLng: location.longitude,
        SosEvents.paramErrorCode: e is ApiException ? (e as ApiException).code : 'NETWORK_ERROR',
      });
      return false;
    }
  }
}
