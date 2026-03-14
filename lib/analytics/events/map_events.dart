/// 地图交互相关事件定义
class MapEvents {
  MapEvents._();

  // ===== 事件名称 =====
  static const String mapMarkerClick = 'map_marker_click';
  static const String mapRouteClick = 'map_route_click';
  static const String mapZoom = 'map_zoom';
  static const String offlineMapDownload = 'offline_map_download';
  static const String offlineMapDelete = 'offline_map_delete';

  // ===== 参数键名 =====
  static const String paramMarkerId = 'marker_id';
  static const String paramMarkerType = 'marker_type'; // poi/trail/start/end
  static const String paramRouteId = 'route_id';
  static const String paramZoomLevel = 'zoom_level';
  static const String paramZoomDirection = 'direction'; // in/out
  static const String paramCityCode = 'city_code';
  static const String paramCityName = 'city_name';
  static const String paramPackageSize = 'package_size';
  static const String paramDownloadResult = 'result';
  static const String paramDeleteReason = 'reason';
}
