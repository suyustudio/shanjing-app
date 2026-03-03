import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'offline_map_manager.dart';

/// 离线地图存储管理器
/// 管理离线地图的元数据和缓存信息
class OfflineMapStorage {
  static const String _metadataFileName = 'offline_map_metadata.json';
  static const String _cacheDirName = 'offline_map_cache';
  
  static final OfflineMapStorage _instance = OfflineMapStorage._internal();
  factory OfflineMapStorage() => _instance;
  OfflineMapStorage._internal();

  /// 获取应用文档目录
  Future<Directory> _getAppDir() async {
    return await getApplicationDocumentsDirectory();
  }

  /// 获取离线地图缓存目录
  Future<Directory> _getCacheDir() async {
    final appDir = await _getAppDir();
    final cacheDir = Directory('${appDir.path}/$_cacheDirName');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// 获取元数据文件路径
  Future<File> _getMetadataFile() async {
    final appDir = await _getAppDir();
    return File('${appDir.path}/$_metadataFileName');
  }

  /// 保存离线地图元数据
  Future<void> saveMetadata(Map<String, dynamic> metadata) async {
    try {
      final file = await _getMetadataFile();
      await file.writeAsString(jsonEncode(metadata));
    } catch (e) {
      print('保存离线地图元数据失败: $e');
    }
  }

  /// 读取离线地图元数据
  Future<Map<String, dynamic>?> loadMetadata() async {
    try {
      final file = await _getMetadataFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      print('读取离线地图元数据失败: $e');
    }
    return null;
  }

  /// 保存离线城市列表
  Future<void> saveOfflineCities(List<OfflineCity> cities) async {
    try {
      final metadata = await loadMetadata() ?? {};
      metadata['offlineCities'] = cities.map((c) => c.toMap()).toList();
      metadata['lastUpdate'] = DateTime.now().toIso8601String();
      await saveMetadata(metadata);
    } catch (e) {
      print('保存离线城市列表失败: $e');
    }
  }

  /// 加载离线城市列表
  Future<List<OfflineCity>> loadOfflineCities() async {
    try {
      final metadata = await loadMetadata();
      if (metadata != null && metadata['offlineCities'] != null) {
        final cities = (metadata['offlineCities'] as List)
            .map((c) => OfflineCity.fromMap(c))
            .toList();
        return cities;
      }
    } catch (e) {
      print('加载离线城市列表失败: $e');
    }
    return [];
  }

  /// 保存下载记录
  Future<void> saveDownloadRecord(String cityCode, String cityName, int size) async {
    try {
      final metadata = await loadMetadata() ?? {};
      final records = (metadata['downloadRecords'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      
      // 查找是否已有记录
      final existingIndex = records.indexWhere((r) => r['cityCode'] == cityCode);
      final record = {
        'cityCode': cityCode,
        'cityName': cityName,
        'size': size,
        'downloadTime': DateTime.now().toIso8601String(),
      };
      
      if (existingIndex >= 0) {
        records[existingIndex] = record;
      } else {
        records.add(record);
      }
      
      metadata['downloadRecords'] = records;
      await saveMetadata(metadata);
    } catch (e) {
      print('保存下载记录失败: $e');
    }
  }

  /// 获取下载记录
  Future<List<Map<String, dynamic>>> getDownloadRecords() async {
    try {
      final metadata = await loadMetadata();
      if (metadata != null && metadata['downloadRecords'] != null) {
        return (metadata['downloadRecords'] as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('获取下载记录失败: $e');
    }
    return [];
  }

  /// 删除下载记录
  Future<void> deleteDownloadRecord(String cityCode) async {
    try {
      final metadata = await loadMetadata() ?? {};
      final records = (metadata['downloadRecords'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      records.removeWhere((r) => r['cityCode'] == cityCode);
      metadata['downloadRecords'] = records;
      await saveMetadata(metadata);
    } catch (e) {
      print('删除下载记录失败: $e');
    }
  }

  /// 获取总存储大小
  Future<int> getTotalStorageSize() async {
    try {
      final cacheDir = await _getCacheDir();
      int totalSize = 0;
      
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('获取总存储大小失败: $e');
      return 0;
    }
  }

  /// 清理过期缓存
  Future<int> cleanExpiredCache({Duration maxAge = const Duration(days: 30)}) async {
    try {
      final cacheDir = await _getCacheDir();
      final now = DateTime.now();
      int cleanedSize = 0;
      
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);
          
          if (age > maxAge) {
            final size = await entity.length();
            await entity.delete();
            cleanedSize += size;
          }
        }
      }
      
      return cleanedSize;
    } catch (e) {
      print('清理过期缓存失败: $e');
      return 0;
    }
  }

  /// 格式化文件大小
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
