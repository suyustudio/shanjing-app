/// SOS 紧急求助相关事件定义
class SosEvents {
  SosEvents._();

  // ===== 事件名称 =====
  static const String sosTriggered = 'sos_triggered';
  static const String sosSuccess = 'sos_success';
  static const String sosFailed = 'sos_failed';
  static const String sosCancelled = 'sos_cancelled';

  // ===== 参数键名 =====
  static const String paramLatitude = 'latitude';
  static const String paramLongitude = 'longitude';
  static const String paramAltitude = 'altitude';
  static const String paramAccuracy = 'accuracy';
  static const String paramErrorCode = 'error_code';
  static const String paramTriggerMethod = 'trigger_method'; // button, volume_key, voice
}