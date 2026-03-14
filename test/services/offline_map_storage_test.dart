import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/services/offline_map_storage.dart';

void main() {
  group('OfflineMapStorage 单元测试', () {
    late OfflineMapStorage storage;

    setUp(() {
      storage = OfflineMapStorage();
    });

    test('单例模式 - 多次获取返回同一实例', () {
      final instance1 = OfflineMapStorage();
      final instance2 = OfflineMapStorage();
      expect(instance1, same(instance2));
    });

    test('formatSize 格式化文件大小正确', () {
      expect(storage.formatSize(0), equals('0 B'));
      expect(storage.formatSize(512), equals('512 B'));
      expect(storage.formatSize(1024), equals('1.0 KB'));
      expect(storage.formatSize(1536), equals('1.5 KB'));
      expect(storage.formatSize(1024 * 1024), equals('1.0 MB'));
      expect(storage.formatSize(1536 * 1024), equals('1.5 MB'));
      expect(storage.formatSize(1024 * 1024 * 1024), equals('1.0 GB'));
      expect(storage.formatSize(1536 * 1024 * 1024), equals('1.5 GB'));
    });

    test('formatSize 边缘值处理', () {
      // 测试 0.99 KB 显示
      expect(storage.formatSize(1013), contains('B'));
      // 测试 1.01 KB 显示
      expect(storage.formatSize(1034), contains('KB'));
    });
  });
}
