import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:hangzhou_guide/services/offline_map_manager.dart';

void main() {
  group('OfflineMapManager Tests', () {
    const MethodChannel channel = MethodChannel('com.shanjing/offline_map');
    const EventChannel eventChannel = EventChannel('com.shanjing/offline_map_events');
    
    TestWidgetsFlutterBinding.ensureInitialized();
    
    setUp(() {
      // 设置MethodChannel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'initialize':
            return true;
          case 'getOfflineCityList':
            return [
              {
                'cityCode': '330100',
                'cityName': '杭州市',
                'cityPinyin': 'hangzhou',
                'dataSize': 1024000,
                'downloadSize': 0,
                'ratio': 0,
                'status': 0,
                'update': false,
                'version': 1,
              }
            ];
          case 'getHotCityList':
            return [
              {
                'cityCode': '330100',
                'cityName': '杭州市',
                'cityPinyin': 'hangzhou',
                'dataSize': 1024000,
                'downloadSize': 0,
                'ratio': 0,
                'status': 0,
                'update': false,
                'version': 1,
              }
            ];
          case 'downloadOfflineMap':
            return true;
          case 'pauseDownload':
            return true;
          case 'resumeDownload':
            return true;
          case 'deleteOfflineMap':
            return true;
          case 'getDownloadedOfflineMapList':
            return [];
          case 'isCityDownloaded':
            return false;
          case 'getDownloadProgress':
            return 0;
          case 'clearAllOfflineMaps':
            return true;
          default:
            return null;
        }
      });
    });
    
    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
    
    test('OfflineCity fromMap/toMap', () {
      final map = {
        'cityCode': '330100',
        'cityName': '杭州市',
        'cityPinyin': 'hangzhou',
        'dataSize': 1024000,
        'downloadSize': 512000,
        'ratio': 50,
        'status': 1,
        'update': true,
        'version': 2,
      };
      
      final city = OfflineCity.fromMap(map);
      expect(city.cityCode, '330100');
      expect(city.cityName, '杭州市');
      expect(city.cityPinyin, 'hangzhou');
      expect(city.dataSize, 1024000);
      expect(city.downloadSize, 512000);
      expect(city.ratio, 50);
      expect(city.status, 1);
      expect(city.update, true);
      expect(city.version, 2);
      
      final toMap = city.toMap();
      expect(toMap['cityCode'], '330100');
      expect(toMap['cityName'], '杭州市');
    });
    
    test('OfflineMapDownloadStatus fromValue', () {
      expect(OfflineMapDownloadStatus.fromValue(0), OfflineMapDownloadStatus.waiting);
      expect(OfflineMapDownloadStatus.fromValue(1), OfflineMapDownloadStatus.downloading);
      expect(OfflineMapDownloadStatus.fromValue(2), OfflineMapDownloadStatus.paused);
      expect(OfflineMapDownloadStatus.fromValue(3), OfflineMapDownloadStatus.completed);
      expect(OfflineMapDownloadStatus.fromValue(4), OfflineMapDownloadStatus.error);
      expect(OfflineMapDownloadStatus.fromValue(-999), OfflineMapDownloadStatus.unknown);
    });
    
    test('initialize returns true', () async {
      final manager = OfflineMapManager();
      final result = await manager.initialize();
      expect(result, true);
    });
    
    test('getOfflineCityList returns list', () async {
      final manager = OfflineMapManager();
      await manager.initialize();
      final cities = await manager.getOfflineCityList();
      expect(cities, isA<List<OfflineCity>>());
      expect(cities.length, 1);
      expect(cities.first.cityName, '杭州市');
    });
    
    test('getHotCityList returns list', () async {
      final manager = OfflineMapManager();
      await manager.initialize();
      final cities = await manager.getHotCityList();
      expect(cities, isA<List<OfflineCity>>());
      expect(cities.length, 1);
    });
    
    test('downloadOfflineMap returns true', () async {
      final manager = OfflineMapManager();
      final result = await manager.downloadOfflineMap('330100', '杭州市');
      expect(result, true);
    });
    
    test('pauseDownload returns true', () async {
      final manager = OfflineMapManager();
      final result = await manager.pauseDownload('330100');
      expect(result, true);
    });
    
    test('resumeDownload returns true', () async {
      final manager = OfflineMapManager();
      final result = await manager.resumeDownload('330100');
      expect(result, true);
    });
    
    test('deleteOfflineMap returns true', () async {
      final manager = OfflineMapManager();
      final result = await manager.deleteOfflineMap('330100');
      expect(result, true);
    });
    
    test('getDownloadedOfflineMapList returns list', () async {
      final manager = OfflineMapManager();
      final cities = await manager.getDownloadedOfflineMapList();
      expect(cities, isA<List<OfflineCity>>());
    });
    
    test('isCityDownloaded returns false', () async {
      final manager = OfflineMapManager();
      final result = await manager.isCityDownloaded('330100');
      expect(result, false);
    });
    
    test('getDownloadProgress returns 0', () async {
      final manager = OfflineMapManager();
      final progress = await manager.getDownloadProgress('330100');
      expect(progress, 0);
    });
    
    test('addDownloadListener and removeDownloadListener', () {
      final manager = OfflineMapManager();
      var called = false;
      
      void listener(OfflineCity city, int status, int progress) {
        called = true;
      }
      
      manager.addDownloadListener('330100', listener);
      manager.removeDownloadListener('330100');
      
      // 验证可以添加和移除监听器
      expect(called, false);
    });
    
    test('clearAllOfflineMaps returns true', () async {
      final manager = OfflineMapManager();
      final result = await manager.clearAllOfflineMaps();
      expect(result, true);
    });
  });
}
