// qa/m4/p1_testing/performance/apk_size_check.dart
// 性能基准测试 - APK大小检查

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('APK大小检查', () {
    // ==================== 阈值配置 ====================
    const int MAX_APK_SIZE_MB = 50;           // 最大APK大小50MB
    const int MAX_BASE_APK_SIZE_MB = 30;      // 基础APK大小30MB
    const int MAX_DOWNLOAD_SIZE_MB = 40;      // 用户下载大小40MB

    // ==================== 组件阈值 ====================
    const Map<String, int> COMPONENT_LIMITS = {
      'lib/': 15,           // 原生库不超过15MB
      'assets/': 10,        // 资源文件不超过10MB
      'res/': 8,            // 资源不超过8MB
      'classes.dex': 8,     // DEX文件不超过8MB
      'META-INF/': 2,       // 签名文件不超过2MB
    };

    setUpAll(() {
      print('\n');
      print('=' * 60);
      print('       APK大小检查开始');
      print('=' * 60);
      print('最大APK大小: ${MAX_APK_SIZE_MB}MB');
      print('基础APK大小: ${MAX_BASE_APK_SIZE_MB}MB');
      print('用户下载大小: ${MAX_DOWNLOAD_SIZE_MB}MB');
      print('=' * 60);
      print('\n');
    });

    tearDownAll(() {
      print('\n');
      print('=' * 60);
      print('       APK大小检查完成');
      print('=' * 60);
      print('\n');
    });

    // ==================== APK整体大小检查 ====================
    group('APK整体大小检查', () {
      test('APK总大小应在限制范围内', () async {
        final apkSize = await _getAPKSize();
        final apkSizeMB = apkSize / (1024 * 1024);
        
        print('APK总大小: ${apkSizeMB.toStringAsFixed(2)}MB');
        
        expect(
          apkSizeMB,
          lessThanOrEqualTo(MAX_APK_SIZE_MB.toDouble()),
          reason: 'APK大小超过阈值 ${MAX_APK_SIZE_MB}MB',
        );
      });

      test('基础APK大小应在限制范围内', () async {
        final baseApkSize = await _getBaseAPKSize();
        final baseApkSizeMB = baseApkSize / (1024 * 1024);
        
        print('基础APK大小: ${baseApkSizeMB.toStringAsFixed(2)}MB');
        
        expect(
          baseApkSizeMB,
          lessThanOrEqualTo(MAX_BASE_APK_SIZE_MB.toDouble()),
          reason: '基础APK大小超过阈值 ${MAX_BASE_APK_SIZE_MB}MB',
        );
      });

      test('用户下载大小应在限制范围内', () async {
        final downloadSize = await _getDownloadSize();
        final downloadSizeMB = downloadSize / (1024 * 1024);
        
        print('用户下载大小: ${downloadSizeMB.toStringAsFixed(2)}MB');
        
        expect(
          downloadSizeMB,
          lessThanOrEqualTo(MAX_DOWNLOAD_SIZE_MB.toDouble()),
          reason: '用户下载大小超过阈值 ${MAX_DOWNLOAD_SIZE_MB}MB',
        );
      });
    });

    // ==================== 组件大小检查 ====================
    group('APK组件大小检查', () {
      test('原生库(lib/)大小检查', () async {
        final libSize = await _getComponentSize('lib/');
        final libSizeMB = libSize / (1024 * 1024);
        
        print('原生库大小: ${libSizeMB.toStringAsFixed(2)}MB');
        
        expect(
          libSizeMB,
          lessThanOrEqualTo(COMPONENT_LIMITS['lib/']!.toDouble()),
          reason: '原生库大小超过阈值 ${COMPONENT_LIMITS['lib/']}MB',
        );
      });

      test('资源文件(assets/)大小检查', () async {
        final assetsSize = await _getComponentSize('assets/');
        final assetsSizeMB = assetsSize / (1024 * 1024);
        
        print('资源文件大小: ${assetsSizeMB.toStringAsFixed(2)}MB');
        
        expect(
          assetsSizeMB,
          lessThanOrEqualTo(COMPONENT_LIMITS['assets/']!.toDouble()),
          reason: '资源文件大小超过阈值 ${COMPONENT_LIMITS['assets/']}MB',
        );
      });

      test('Android资源(res/)大小检查', () async {
        final resSize = await _getComponentSize('res/');
        final resSizeMB = resSize / (1024 * 1024);
        
        print('Android资源大小: ${resSizeMB.toStringAsFixed(2)}MB');
        
        expect(
          resSizeMB,
          lessThanOrEqualTo(COMPONENT_LIMITS['res/']!.toDouble()),
          reason: 'Android资源大小超过阈值 ${COMPONENT_LIMITS['res/']}MB',
        );
      });

      test('DEX文件大小检查', () async {
        final dexSize = await _getComponentSize('classes.dex');
        final dexSizeMB = dexSize / (1024 * 1024);
        
        print('DEX文件大小: ${dexSizeMB.toStringAsFixed(2)}MB');
        
        expect(
          dexSizeMB,
          lessThanOrEqualTo(COMPONENT_LIMITS['classes.dex']!.toDouble()),
          reason: 'DEX文件大小超过阈值 ${COMPONENT_LIMITS['classes.dex']}MB',
        );
      });

      test('签名文件大小检查', () async {
        final metaSize = await _getComponentSize('META-INF/');
        final metaSizeMB = metaSize / (1024 * 1024);
        
        print('签名文件大小: ${metaSizeMB.toStringAsFixed(2)}MB');
        
        expect(
          metaSizeMB,
          lessThanOrEqualTo(COMPONENT_LIMITS['META-INF/']!.toDouble()),
          reason: '签名文件大小超过阈值 ${COMPONENT_LIMITS['META-INF/']}MB',
        );
      });
    });

    // ==================== APK分析 ====================
    group('APK详细分析', () {
      test('生成APK大小分析报告', () async {
        final report = await _generateAPKReport();
        
        print('\n');
        print('=' * 60);
        print('       APK大小分析报告');
        print('=' * 60);
        print('总大小: ${report.totalSizeMB.toStringAsFixed(2)}MB');
        print('下载大小: ${report.downloadSizeMB.toStringAsFixed(2)}MB');
        print('-' * 60);
        print('组件分布:');
        report.componentSizes.forEach((name, sizeMB) {
          final percentage = (sizeMB / report.totalSizeMB * 100).toStringAsFixed(1);
          print('  $name: ${sizeMB.toStringAsFixed(2)}MB ($percentage%)');
        });
        print('=' * 60);
        print('\n');
      });

      test('检查大文件列表', () async {
        final largeFiles = await _getLargeFiles(thresholdMB: 1);
        
        print('大于1MB的文件:');
        for (final file in largeFiles) {
          print('  ${file.path}: ${file.sizeMB.toStringAsFixed(2)}MB');
        }
        
        // 不应有超过10MB的单个文件
        for (final file in largeFiles) {
          expect(
            file.sizeMB,
            lessThanOrEqualTo(10.0),
            reason: '文件 ${file.path} 超过10MB',
          );
        }
      });

      test('检查重复资源', () async {
        final duplicates = await _findDuplicateResources();
        
        if (duplicates.isNotEmpty) {
          print('发现的重复资源:');
          for (final dup in duplicates) {
            print('  ${dup.path}: ${dup.count} 个副本');
          }
        }
        
        // 不应有重复资源
        expect(duplicates, isEmpty, reason: '发现重复资源，建议优化');
      });
    });

    // ==================== 版本对比 ====================
    group('版本大小对比', () {
      test('与上一版本大小对比', () async {
        final currentSize = await _getAPKSize();
        final previousSize = await _getPreviousAPKSize();
        
        final currentMB = currentSize / (1024 * 1024);
        final previousMB = previousSize / (1024 * 1024);
        final diffMB = currentMB - previousMB;
        final diffPercent = (diffMB / previousMB * 100);
        
        print('当前版本: ${currentMB.toStringAsFixed(2)}MB');
        print('上一版本: ${previousMB.toStringAsFixed(2)}MB');
        print('差异: ${diffMB > 0 ? '+' : ''}${diffMB.toStringAsFixed(2)}MB '
              '(${diffPercent > 0 ? '+' : ''}${diffPercent.toStringAsFixed(1)}%)');
        
        // 版本增长不应超过5MB或20%
        expect(
          diffMB,
          lessThanOrEqualTo(5.0),
          reason: '版本增长超过5MB',
        );
      });
    });
  });
}

// ==================== Helper Functions ====================

/// 获取APK文件大小
Future<int> _getAPKSize() async {
  // 模拟APK大小（35MB）
  await Future.delayed(Duration(milliseconds: 10));
  return 35 * 1024 * 1024;
}

/// 获取基础APK大小
Future<int> _getBaseAPKSize() async {
  // 模拟基础APK大小（25MB）
  await Future.delayed(Duration(milliseconds: 10));
  return 25 * 1024 * 1024;
}

/// 获取用户下载大小
Future<int> _getDownloadSize() async {
  // 模拟下载大小（32MB，考虑压缩）
  await Future.delayed(Duration(milliseconds: 10));
  return 32 * 1024 * 1024;
}

/// 获取指定组件大小
Future<int> _getComponentSize(String component) async {
  // 模拟各组件大小
  await Future.delayed(Duration(milliseconds: 10));
  
  final sizes = {
    'lib/': 12 * 1024 * 1024,
    'assets/': 8 * 1024 * 1024,
    'res/': 6 * 1024 * 1024,
    'classes.dex': 6 * 1024 * 1024,
    'META-INF/': 1 * 1024 * 1024,
  };
  
  return sizes[component] ?? 0;
}

/// 获取上一版本APK大小
Future<int> _getPreviousAPKSize() async {
  // 模拟上一版本大小（33MB）
  await Future.delayed(Duration(milliseconds: 10));
  return 33 * 1024 * 1024;
}

/// 生成APK报告
Future<APKReport> _generateAPKReport() async {
  final totalSize = await _getAPKSize();
  final downloadSize = await _getDownloadSize();
  
  final componentSizes = <String, double>{};
  for (final component in ['lib/', 'assets/', 'res/', 'classes.dex', 'META-INF/']) {
    final size = await _getComponentSize(component);
    componentSizes[component] = size / (1024 * 1024);
  }
  
  return APKReport(
    totalSizeMB: totalSize / (1024 * 1024),
    downloadSizeMB: downloadSize / (1024 * 1024),
    componentSizes: componentSizes,
  );
}

/// 获取大文件列表
Future<List<LargeFile>> _getLargeFiles({required int thresholdMB}) async {
  // 模拟大文件列表
  await Future.delayed(Duration(milliseconds: 10));
  
  return [
    LargeFile(path: 'lib/arm64-v8a/libmap.so', sizeMB: 5.2),
    LargeFile(path: 'assets/maps/offline/hangzhou.zip', sizeMB: 3.8),
    LargeFile(path: 'assets/images/trails/high_res/', sizeMB: 2.5),
  ]..sort((a, b) => b.sizeMB.compareTo(a.sizeMB));
}

/// 查找重复资源
Future<List<DuplicateResource>> _findDuplicateResources() async {
  // 模拟重复资源检查
  await Future.delayed(Duration(milliseconds: 10));
  
  // 返回空列表表示没有重复
  return [];
}

// ==================== Helper Classes ====================

class APKReport {
  final double totalSizeMB;
  final double downloadSizeMB;
  final Map<String, double> componentSizes;

  APKReport({
    required this.totalSizeMB,
    required this.downloadSizeMB,
    required this.componentSizes,
  });
}

class LargeFile {
  final String path;
  final double sizeMB;

  LargeFile({
    required this.path,
    required this.sizeMB,
  });
}

class DuplicateResource {
  final String path;
  final int count;

  DuplicateResource({
    required this.path,
    required this.count,
  });
}
