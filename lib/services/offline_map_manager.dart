import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// 离线地图城市信息
class OfflineCity {
  final String cityCode;
  final String cityName;
  final String? cityPinyin;
  final int? dataSize;
  final int? downloadSize;
  final int? ratio;
  final int? status;
  final bool? update;
  final int? version;

  OfflineCity({
    required this.cityCode,
    required this.cityName,
    this.cityPinyin,
    this.dataSize,
    this.downloadSize,
    this.ratio,
    this.status,
    this.update,
    this.version,
  });

  factory OfflineCity.fromMap(Map<dynamic, dynamic> map) {
    return OfflineCity(
      cityCode: map['cityCode'] ?? '',
      cityName: map['cityName'] ?? '',
      cityPinyin: map['cityPinyin'],
      dataSize: map['dataSize'],
      downloadSize: map['downloadSize'],
      ratio: map['ratio'],
      status: map['status'],
      update: map['update'],
      version: map['version'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cityCode': cityCode,
      'cityName': cityName,
      'cityPinyin': cityPinyin,
      'dataSize': dataSize,
      'downloadSize': downloadSize,
      'ratio': ratio,
      'status': status,
      'update': update,
      'version': version,
    };
  }
}

/// 离线地图下载状态
enum OfflineMapDownloadStatus {
  waiting(0),
  downloading(1),
  paused(2),
  completed(3),
  error(4),
  networkError(5),
  ioError(6),
  wifiError(7),
  noSpaceError(8),
  unknown(-1);

  final int value;
  const OfflineMapDownloadStatus(this.value);

  static OfflineMapDownloadStatus fromValue(int value) {
    return OfflineMapDownloadStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OfflineMapDownloadStatus.unknown,
    );
  }
}

/// 离线地图管理器
/// 负责管理离线地图的下载、存储和状态监控
class OfflineMapManager {
  static const MethodChannel _channel = MethodChannel('com.shanjing/offline_map');
  static const EventChannel _eventChannel = EventChannel('com.shanjing/offline_map_events');
  
  static final OfflineMapManager _instance = OfflineMapManager._internal();
  factory OfflineMapManager() => _instance;
  OfflineMapManager._internal();

  StreamSubscription? _downloadSubscription;
  final Map<String, Function(OfflineCity city, int status, int progress)> _downloadListeners = {};
  bool _isInitialized = false;

  /// 初始化离线地图管理器
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // 请求存储权限
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        print('存储权限未授权');
        return false;
      }

      // 监听下载事件
      _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          _handleDownloadEvent(event);
        },
        onError: (dynamic error) {
          print('离线地图事件错误: $error');
        },
      );

      // 初始化原生SDK
      final result = await _channel.invokeMethod<bool>('initialize');
      _isInitialized = result ?? false;
      return _isInitialized;
    } catch (e) {
      print('初始化离线地图失败: $e');
      return false;
    }
  }

  /// 获取可下载的城市列表
  Future<List<OfflineCity>> getOfflineCityList() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getOfflineCityList');
      return result.map((e) => OfflineCity.fromMap(e)).toList();
    } catch (e) {
      print('获取城市列表失败: $e');
      return [];
    }
  }

  /// 获取热门城市列表
  Future<List<OfflineCity>> getHotCityList() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getHotCityList');
      return result.map((e) => OfflineCity.fromMap(e)).toList();
    } catch (e) {
      print('获取热门城市列表失败: $e');
      return [];
    }
  }

  /// 开始下载离线地图
  Future<bool> downloadOfflineMap(String cityCode, String cityName) async {
    try {
      final result = await _channel.invokeMethod<bool>('downloadOfflineMap', {
        'cityCode': cityCode,
        'cityName': cityName,
      });
      return result ?? false;
    } catch (e) {
      print('下载离线地图失败: $e');
      return false;
    }
  }

  /// 暂停下载
  Future<bool> pauseDownload(String cityCode) async {
    try {
      final result = await _channel.invokeMethod<bool>('pauseDownload', {
        'cityCode': cityCode,
      });
      return result ?? false;
    } catch (e) {
      print('暂停下载失败: $e');
      return false;
    }
  }

  /// 继续下载
  Future<bool> resumeDownload(String cityCode) async {
    try {
      final result = await _channel.invokeMethod<bool>('resumeDownload', {
        'cityCode': cityCode,
      });
      return result ?? false;
    } catch (e) {
      print('继续下载失败: $e');
      return false;
    }
  }

  /// 删除离线地图
  Future<bool> deleteOfflineMap(String cityCode) async {
    try {
      final result = await _channel.invokeMethod<bool>('deleteOfflineMap', {
        'cityCode': cityCode,
      });
      return result ?? false;
    } catch (e) {
      print('删除离线地图失败: $e');
      return false;
    }
  }

  /// 获取已下载的离线地图列表
  Future<List<OfflineCity>> getDownloadedOfflineMapList() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getDownloadedOfflineMapList');
      return result.map((e) => OfflineCity.fromMap(e)).toList();
    } catch (e) {
      print('获取已下载列表失败: $e');
      return [];
    }
  }

  /// 检查城市是否已下载
  Future<bool> isCityDownloaded(String cityCode) async {
    try {
      final result = await _channel.invokeMethod<bool>('isCityDownloaded', {
        'cityCode': cityCode,
      });
      return result ?? false;
    } catch (e) {
      print('检查下载状态失败: $e');
      return false;
    }
  }

  /// 获取下载进度
  Future<int> getDownloadProgress(String cityCode) async {
    try {
      final result = await _channel.invokeMethod<int>('getDownloadProgress', {
        'cityCode': cityCode,
      });
      return result ?? 0;
    } catch (e) {
      print('获取下载进度失败: $e');
      return 0;
    }
  }

  /// 添加下载监听器
  void addDownloadListener(
    String cityCode,
    Function(OfflineCity city, int status, int progress) listener,
  ) {
    _downloadListeners[cityCode] = listener;
  }

  /// 移除下载监听器
  void removeDownloadListener(String cityCode) {
    _downloadListeners.remove(cityCode);
  }

  /// 处理下载事件
  void _handleDownloadEvent(dynamic event) {
    if (event is Map) {
      final cityCode = event['cityCode'] as String?;
      final cityName = event['cityName'] as String?;
      final status = event['status'] as int? ?? -1;
      final progress = event['progress'] as int? ?? 0;
      final completeCode = event['completeCode'] as int? ?? 0;

      if (cityCode != null && _downloadListeners.containsKey(cityCode)) {
        final city = OfflineCity(
          cityCode: cityCode,
          cityName: cityName ?? '',
          ratio: progress,
        );
        _downloadListeners[cityCode]!(city, status, completeCode);
      }
    }
  }

  /// 获取离线地图存储路径
  Future<String?> getOfflineMapPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final offlinePath = '${directory.path}/amap_offline';
      final dir = Directory(offlinePath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return offlinePath;
    } catch (e) {
      print('获取离线地图路径失败: $e');
      return null;
    }
  }

  /// 获取离线地图总大小（字节）
  Future<int> getTotalOfflineMapSize() async {
    try {
      final path = await getOfflineMapPath();
      if (path == null) return 0;

      final dir = Directory(path);
      if (!await dir.exists()) return 0;

      int totalSize = 0;
      await for (final file in dir.list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      print('获取离线地图大小失败: $e');
      return 0;
    }
  }

  /// 清理所有离线地图数据
  Future<bool> clearAllOfflineMaps() async {
    try {
      final path = await getOfflineMapPath();
      if (path == null) return false;

      final dir = Directory(path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      // 同时清理原生SDK的离线地图
      await _channel.invokeMethod('clearAllOfflineMaps');
      return true;
    } catch (e) {
      print('清理离线地图失败: $e');
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _downloadSubscription?.cancel();
    _downloadListeners.clear();
  }
}
