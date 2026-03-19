/**
 * iOS 离线地图配置
 * 
 * M4 P2 任务：iOS 离线地图适配基础配置
 * 完整功能实现推迟到 M5
 * 
 * 注意：本文件仅包含基础项目配置，不涉及完整离线地图功能
 * 
 * @author 山径开发团队
 * @since M4 P2
 */

import 'dart:io';

/// iOS 离线地图配置
class IOSOfflineMapConfig {
  IOSOfflineMapConfig._();

  /// 是否启用 iOS 离线地图功能
  /// 
  /// M4 P2 阶段禁用完整功能，仅做基础配置
  static const bool enableOfflineMap = false;

  /// 离线地图数据版本
  static const String offlineDataVersion = '1.0.0';

  /// 离线地图数据基础 URL
  static const String offlineDataBaseUrl = 'https://offline.shanjing.com/ios/maps';

  /// 离线地图数据存储路径（iOS 沙盒）
  static String get offlineDataPath {
    if (!Platform.isIOS) return '';
    
    // iOS 文档目录路径
    // 实际路径: /var/mobile/Containers/Data/Application/{UUID}/Documents/offline_maps
    return 'Documents/offline_maps';
  }

  /// 离线地图缓存目录（临时文件）
  static String get offlineCachePath {
    if (!Platform.isIOS) return '';
    
    // iOS 缓存目录
    // 实际路径: /var/mobile/Containers/Data/Application/{UUID}/Library/Caches/offline_maps
    return 'Library/Caches/offline_maps';
  }

  /// 支持的离线地图区域
  static const List<String> supportedRegions = [
    'hangzhou',     // 杭州
    'shanghai',     // 上海
    'nanjing',      // 南京
    'suzhou',       // 苏州
  ];

  /// 默认离线地图区域
  static const String defaultRegion = 'hangzhou';

  /// 离线地图数据包大小限制（MB）
  static const int maxOfflinePackageSizeMB = 200;

  /// 离线地图最小存储空间要求（MB）
  static const int minStorageSpaceMB = 500;

  /// 离线地图瓦片格式
  static const String tileFormat = 'pbf';

  /// 离线地图瓦片大小（像素）
  static const int tileSize = 256;

  /// 支持的缩放级别范围
  static const Map<String, int> zoomLevels = {
    'min': 10,
    'max': 17,
  };

  /// iOS 特定配置
  static const Map<String, dynamic> iosSpecificConfig = {
    // 使用 Apple Maps 作为离线地图基础
    'useAppleMapsBase': true,
    
    // 后台下载配置
    'backgroundDownloadEnabled': true,
    
    // 蜂窝网络下载限制
    'cellularDownloadLimitMB': 50,
    
    // 自动清理过期数据
    'autoCleanupEnabled': true,
    
    // 数据过期时间（天）
    'dataExpirationDays': 30,
  };
}

/// iOS 离线地图管理器（M4 P2 仅提供接口，M5 实现完整功能）
class IOSOfflineMapManager {
  static final IOSOfflineMapManager _instance = IOSOfflineMapManager._internal();
  factory IOSOfflineMapManager() => _instance;
  IOSOfflineMapManager._internal();

  bool _isInitialized = false;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化离线地图（M4 P2 仅记录状态，不实现功能）
  /// 
  /// 返回值：
  /// - true: 初始化成功或功能已禁用
  /// - false: 初始化失败
  Future<bool> initialize() async {
    if (!Platform.isIOS) {
      print('[IOSOfflineMap] 非 iOS 平台，跳过初始化');
      return true;
    }

    if (!IOSOfflineMapConfig.enableOfflineMap) {
      print('[IOSOfflineMap] 离线地图功能已禁用（M4 P2 阶段）');
      return true;
    }

    try {
      // M5 阶段实现完整初始化逻辑
      print('[IOSOfflineMap] 初始化中...（M5 完整实现）');
      _isInitialized = true;
      return true;
    } catch (e) {
      print('[IOSOfflineMap] 初始化失败: $e');
      return false;
    }
  }

  /// 检查离线地图数据是否可用
  /// 
  /// M4 P2 阶段始终返回 false
  Future<bool> isOfflineDataAvailable(String region) async {
    if (!IOSOfflineMapConfig.enableOfflineMap) return false;
    
    // M5 阶段实现完整检查逻辑
    return false;
  }

  /// 获取离线地图数据下载进度
  /// 
  /// M4 P2 阶段返回 0
  Future<double> getDownloadProgress(String region) async {
    if (!IOSOfflineMapConfig.enableOfflineMap) return 0.0;
    
    // M5 阶段实现完整进度获取
    return 0.0;
  }

  /// 下载离线地图数据
  /// 
  /// M4 P2 阶段仅记录日志，不执行实际下载
  Future<bool> downloadOfflineData(String region) async {
    if (!IOSOfflineMapConfig.enableOfflineMap) {
      print('[IOSOfflineMap] 下载功能已禁用（M4 P2 阶段）');
      return false;
    }

    if (!IOSOfflineMapConfig.supportedRegions.contains(region)) {
      print('[IOSOfflineMap] 不支持的区域: $region');
      return false;
    }

    print('[IOSOfflineMap] 开始下载 $region 离线地图数据（M5 完整实现）');
    // M5 阶段实现完整下载逻辑
    return false;
  }

  /// 暂停下载
  /// 
  /// M4 P2 阶段为空实现
  Future<void> pauseDownload(String region) async {
    if (!IOSOfflineMapConfig.enableOfflineMap) return;
    
    print('[IOSOfflineMap] 暂停下载 $region（M5 完整实现）');
  }

  /// 恢复下载
  /// 
  /// M4 P2 阶段为空实现
  Future<void> resumeDownload(String region) async {
    if (!IOSOfflineMapConfig.enableOfflineMap) return;
    
    print('[IOSOfflineMap] 恢复下载 $region（M5 完整实现）');
  }

  /// 删除离线地图数据
  /// 
  /// M4 P2 阶段为空实现
  Future<bool> deleteOfflineData(String region) async {
    if (!IOSOfflineMapConfig.enableOfflineMap) return false;
    
    print('[IOSOfflineMap] 删除 $region 离线地图数据（M5 完整实现）');
    return false;
  }

  /// 获取已下载区域列表
  /// 
  /// M4 P2 阶段返回空列表
  Future<List<String>> getDownloadedRegions() async {
    if (!IOSOfflineMapConfig.enableOfflineMap) return [];
    
    // M5 阶段实现完整逻辑
    return [];
  }

  /// 计算离线地图数据大小
  /// 
  /// M4 P2 阶段返回预估大小
  Future<int> calculateDataSize(String region) async {
    if (!IOSOfflineMapConfig.enableOfflineMap) return 0;
    
    // 预估大小（MB）
    const estimatedSizes = {
      'hangzhou': 120,
      'shanghai': 150,
      'nanjing': 100,
      'suzhou': 80,
    };
    
    return estimatedSizes[region] ?? 100;
  }

  /// 检查存储空间
  /// 
  /// M4 P2 阶段始终返回 true
  Future<bool> checkStorageSpace() async {
    if (!IOSOfflineMapConfig.enableOfflineMap) return true;
    
    // M5 阶段实现完整检查
    return true;
  }

  /// 释放资源
  /// 
  /// M4 P2 阶段仅重置状态
  Future<void> dispose() async {
    _isInitialized = false;
    print('[IOSOfflineMap] 资源已释放');
  }
}

/// iOS 离线地图事件（M5 阶段完整实现）
class IOSOfflineMapEvent {
  /// 下载开始
  static const String downloadStarted = 'download_started';
  
  /// 下载进度更新
  static const String downloadProgress = 'download_progress';
  
  /// 下载完成
  static const String downloadCompleted = 'download_completed';
  
  /// 下载失败
  static const String downloadFailed = 'download_failed';
  
  /// 下载暂停
  static const String downloadPaused = 'download_paused';
  
  /// 下载恢复
  static const String downloadResumed = 'download_resumed';
  
  /// 数据过期
  static const String dataExpired = 'data_expired';
  
  /// 存储空间不足
  static const String storageInsufficient = 'storage_insufficient';
}

/// iOS 离线地图错误码（M5 阶段完整实现）
class IOSOfflineMapError {
  /// 初始化失败
  static const String initFailed = 'INIT_FAILED';
  
  /// 网络错误
  static const String networkError = 'NETWORK_ERROR';
  
  /// 存储空间不足
  static const String insufficientStorage = 'INSUFFICIENT_STORAGE';
  
  /// 数据损坏
  static const String dataCorrupted = 'DATA_CORRUPTED';
  
  /// 下载取消
  static const String downloadCancelled = 'DOWNLOAD_CANCELLED';
  
  /// 不支持的区域
  static const String unsupportedRegion = 'UNSUPPORTED_REGION';
  
  /// 已是最新版本
  static const String alreadyLatest = 'ALREADY_LATEST';
}
