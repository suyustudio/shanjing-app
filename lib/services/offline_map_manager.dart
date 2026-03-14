/**
 * 离线地图管理器
 * 
 * 已集成高德地图离线SDK原生实现
 * - Android: 通过 MethodChannel 调用原生 SDK
 * - iOS: 待实现
 * 
 * 功能：
 * - 离线地图下载、暂停、继续、删除
 * - 实时下载进度监听
 * - 网络状态自动检测与离线模式切换
 */

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
      cityCode: map['cityCode']?.toString() ?? '',
      cityName: map['cityName']?.toString() ?? '',
      cityPinyin: map['cityPinyin']?.toString(),
      dataSize: map['dataSize'] as int?,
      downloadSize: map['downloadSize'] as int?,
      ratio: map['ratio'] as int?,
      status: map['status'] as int?,
      update: map['update'] as bool?,
      version: map['version'] as int?,
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
  
  /// 获取格式化的大小字符串
  String get formattedSize {
    if (dataSize == null) return '未知大小';
    final size = dataSize!;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
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
  
  String get displayName {
    switch (this) {
      case OfflineMapDownloadStatus.waiting:
        return '等待中';
      case OfflineMapDownloadStatus.downloading:
        return '下载中';
      case OfflineMapDownloadStatus.paused:
        return '已暂停';
      case OfflineMapDownloadStatus.completed:
        return '已完成';
      case OfflineMapDownloadStatus.error:
        return '下载错误';
      case OfflineMapDownloadStatus.networkError:
        return '网络错误';
      case OfflineMapDownloadStatus.ioError:
        return '存储错误';
      case OfflineMapDownloadStatus.wifiError:
        return 'WiFi错误';
      case OfflineMapDownloadStatus.noSpaceError:
        return '空间不足';
      default:
        return '未知状态';
    }
  }
}

/// 下载进度事件
class DownloadProgressEvent {
  final String cityCode;
  final String cityName;
  final int status;
  final int progress;
  
  DownloadProgressEvent({
    required this.cityCode,
    required this.cityName,
    required this.status,
    required this.progress,
  });
  
  factory DownloadProgressEvent.fromMap(Map<dynamic, dynamic> map) {
    return DownloadProgressEvent(
      cityCode: map['cityCode']?.toString() ?? '',
      cityName: map['cityName']?.toString() ?? '',
      status: map['status'] as int? ?? -1,
      progress: map['progress'] as int? ?? 0,
    );
  }
}

/// 离线地图管理器
/// 
/// 已集成高德地图离线SDK原生实现
class OfflineMapManager {
  static const MethodChannel _channel = MethodChannel('com.shanjing/offline_map');
  static const EventChannel _eventChannel = EventChannel('com.shanjing/offline_map_events');
  
  static final OfflineMapManager _instance = OfflineMapManager._internal();
  factory OfflineMapManager() => _instance;
  OfflineMapManager._internal();

  StreamSubscription? _downloadSubscription;
  StreamSubscription? _connectivitySubscription;
  final Map<String, Function(OfflineCity city, int status, int progress)> _downloadListeners = {};
  bool _isInitialized = false;
  bool _isOfflineMode = false;
  
  /// 网络状态流控制器
  final _offlineModeController = StreamController<bool>.broadcast();
  Stream<bool> get offlineModeStream => _offlineModeController.stream;
  bool get isOfflineMode => _isOfflineMode;

  /// 初始化状态
  bool get isInitialized => _isInitialized;

  /// 初始化离线地图管理器
  /// 
  /// 会请求存储权限并初始化原生SDK
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // 请求存储权限
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        debugPrint('离线地图: 存储权限未授权');
        return false;
      }

      // 监听下载事件
      _downloadSubscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          _handleDownloadEvent(event);
        },
        onError: (dynamic error) {
          debugPrint('离线地图: 事件错误 - $error');
        },
      );

      // 监听网络状态变化
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
        _handleConnectivityChange(result);
      });

      // 检查当前网络状态
      final connectivityResult = await Connectivity().checkConnectivity();
      _handleConnectivityChange(connectivityResult);

      // 初始化原生SDK
      final result = await _channel.invokeMethod<bool>('initialize');
      _isInitialized = result ?? false;
      debugPrint('离线地图: 初始化${_isInitialized ? "成功" : "失败"}');
      return _isInitialized;
    } on MissingPluginException catch (e) {
      debugPrint('离线地图: 原生插件未实现 - $e');
      debugPrint('离线地图: Android原生代码已集成，请确保重新编译应用');
      return false;
    } catch (e) {
      debugPrint('离线地图: 初始化失败 - $e');
      return false;
    }
  }

  /// 处理网络状态变化
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasOffline = _isOfflineMode;
    _isOfflineMode = result == ConnectivityResult.none;
    
    if (wasOffline != _isOfflineMode) {
      debugPrint('离线地图: 网络状态变化 - ${_isOfflineMode ? "离线" : "在线"}');
      _offlineModeController.add(_isOfflineMode);
    }
  }

  /// 检查指定城市是否可以使用离线地图
  Future<bool> canUseOfflineMap(String cityCode) async {
    if (!_isOfflineMode) return false;
    return await isCityDownloaded(cityCode);
  }

  /// 获取最适合的离线地图城市
  /// 
  /// 根据当前位置返回最适合的已下载离线地图城市
  Future<OfflineCity?> getBestOfflineCity(String? currentCityName) async {
    final downloaded = await getDownloadedOfflineMapList();
    if (downloaded.isEmpty) return null;
    
    // 如果提供了当前城市名称，尝试匹配
    if (currentCityName != null) {
      try {
        final match = downloaded.firstWhere(
          (city) => city.cityName.contains(currentCityName) || 
                    currentCityName.contains(city.cityName),
        );
        return match;
      } catch (_) {
        // 没有找到匹配，返回第一个
        return downloaded.first;
      }
    }
    
    // 返回第一个已下载的城市
    return downloaded.first;
  }

  /// 获取可下载的城市列表
  Future<List<OfflineCity>> getOfflineCityList() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getOfflineCityList');
      return result.map((e) => OfflineCity.fromMap(e as Map<dynamic, dynamic>)).toList();
    } on MissingPluginException {
      debugPrint('离线地图: 原生插件未实现 getOfflineCityList');
      return [];
    } catch (e) {
      debugPrint('离线地图: 获取城市列表失败 - $e');
      return [];
    }
  }

  /// 获取热门城市列表
  Future<List<OfflineCity>> getHotCityList() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getHotCityList');
      return result.map((e) => OfflineCity.fromMap(e as Map<dynamic, dynamic>)).toList();
    } on MissingPluginException {
      debugPrint('离线地图: 原生插件未实现 getHotCityList');
      return [];
    } catch (e) {
      debugPrint('离线地图: 获取热门城市列表失败 - $e');
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
    } on MissingPluginException {
      debugPrint('离线地图: 原生插件未实现 downloadOfflineMap');
      return false;
    } catch (e) {
      debugPrint('离线地图: 下载失败 - $e');
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
    } on MissingPluginException {
      debugPrint('离线地图: 原生插件未实现 pauseDownload');
      return false;
    } catch (e) {
      debugPrint('离线地图: 暂停下载失败 - $e');
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
    } on MissingPluginException {
      debugPrint('离线地图: 原生插件未实现 resumeDownload');
      return false;
    } catch (e) {
      debugPrint('离线地图: 继续下载失败 - $e');
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
    } on MissingPluginException {
      debugPrint('离线地图: 原生插件未实现 deleteOfflineMap');
      return false;
    } catch (e) {
      debugPrint('离线地图: 删除失败 - $e');
      return false;
    }
  }

  /// 获取已下载的离线地图列表
  Future<List<OfflineCity>> getDownloadedOfflineMapList() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getDownloadedOfflineMapList');
      return result.map((e) => OfflineCity.fromMap(e as Map<dynamic, dynamic>)).toList();
    } on MissingPluginException {
      debugPrint('离线地图: 原生插件未实现 getDownloadedOfflineMapList');
      return [];
    } catch (e) {
      debugPrint('离线地图: 获取已下载列表失败 - $e');
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
    } on MissingPluginException {
      return false;
    } catch (e) {
      debugPrint('离线地图: 检查下载状态失败 - $e');
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
    } on MissingPluginException {
      return 0;
    } catch (e) {
      debugPrint('离线地图: 获取下载进度失败 - $e');
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
      debugPrint('离线地图: 获取存储路径失败 - $e');
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
      debugPrint('离线地图: 获取总大小失败 - $e');
      return 0;
    }
  }

  /// 格式化大小
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
      try {
        await _channel.invokeMethod('clearAllOfflineMaps');
      } on MissingPluginException {
        // 原生插件未实现，忽略
      }
      return true;
    } catch (e) {
      debugPrint('离线地图: 清理失败 - $e');
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _downloadSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _offlineModeController.close();
    _downloadListeners.clear();
  }
}
