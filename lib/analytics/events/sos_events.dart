/// SOS 紧急求助相关事件定义
class SosEvents {
  SosEvents._();

  // ===== 事件名称 =====
  // ✅ 修正：使用 sos_trigger 而不是 sos_triggered
  static const String sosTrigger = 'sos_trigger';
  static const String sosSuccess = 'sos_success';
  static const String sosFailed = 'sos_failed';
  static const String sosCancelled = 'sos_cancelled';

  // ===== 参数键名（旧版兼容） =====
  static const String paramLatitude = 'latitude';
  static const String paramLongitude = 'longitude';
  static const String paramAltitude = 'altitude';
  static const String paramAccuracy = 'accuracy';
  static const String paramErrorCode = 'error_code';
  static const String paramTriggerMethod = 'trigger_method'; // button, volume_key, voice
  
  // ===== 新增参数键名（符合 data-tracking-spec-v1.2） =====
  static const String paramTriggerType = 'trigger_type'; // auto/manual
  static const String paramCountdownRemainingSec = 'countdown_remaining_sec';
  static const String paramLocationLat = 'location_lat';
  static const String paramLocationLng = 'location_lng';
  static const String paramLocationAccuracy = 'location_accuracy';
  static const String paramRouteId = 'route_id';
  static const String paramContactCount = 'contact_count';
  static const String paramSendMethod = 'send_method'; // sms/push/both/wechat
  static const String paramApiResponseMs = 'api_response_ms';
  static const String paramTriggerTimestamp = 'trigger_timestamp';
}