/// 导航相关事件定义
class NavigationEvents {
  NavigationEvents._();

  // ===== 事件名称 =====
  static const String navigationStart = 'navigation_start';
  static const String navigationPause = 'navigation_pause';
  static const String navigationResume = 'navigation_resume';
  static const String navigationOffTrack = 'navigation_off_track';
  static const String navigationSosTrigger = 'navigation_sos_trigger';
  static const String navigationComplete = 'navigation_complete';

  // ===== 参数键名 =====
  static const String paramRouteId = 'route_id';
  static const String paramRouteName = 'route_name';
  static const String paramStartLocation = 'start_location';
  static const String paramEndLocation = 'end_location';
  static const String paramDuration = 'duration';
  static const String paramDistance = 'distance';
  static const String paramOffTrackDistance = 'off_track_distance';
  static const String paramOffTrackDuration = 'off_track_duration';
  static const String paramSosLocation = 'trigger_location';
  static const String paramContactCount = 'contact_count';
  static const String paramSendMethod = 'send_method';
  static const String paramSendSuccess = 'send_success';
  
  // ===== 新增参数键名（符合 data-tracking-spec-v1.2） =====
  static const String paramRouteDistanceM = 'route_distance_m';
  static const String paramRouteDurationMin = 'route_duration_min';
  static const String paramDifficulty = 'difficulty';
  static const String paramStartType = 'start_type';
  static const String paramLocationEnabled = 'location_enabled';
  static const String paramLocationAccuracyM = 'location_accuracy_m';
  static const String paramOfflineMode = 'offline_mode';
  static const String paramVoiceEnabled = 'voice_enabled';
  static const String paramStartTimestamp = 'start_timestamp';
}
