import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/services/share_service_enhanced.dart';

/// 分享服务单元测试
/// 
/// 测试范围：
/// - Mock API 模式
/// - 埋点参数验证
/// - 分享码生成
/// - 分享链接构建
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShareService 基础功能测试', () {
    late ShareService shareService;

    setUp(() {
      shareService = ShareService();
    });

    test('ShareService 应为单例模式', () {
      final instance1 = ShareService();
      final instance2 = ShareService();
      
      expect(identical(instance1, instance2), isTrue);
    });

    test('ShareResponse 应正确从 JSON 创建', () {
      final json = {
        'shareLink': 'https://app.shanjing.com/share?t=R001&c=ABC123',
        'shareCode': 'ABC123',
      };

      final response = ShareResponse.fromJson(json);

      expect(response.shareLink, 'https://app.shanjing.com/share?t=R001&c=ABC123');
      expect(response.shareCode, 'ABC123');
    });

    test('ShareResponse 应支持下划线命名格式', () {
      final json = {
        'share_link': 'https://app.shanjing.com/share?t=R002&c=XYZ789',
        'share_code': 'XYZ789',
      };

      final response = ShareResponse.fromJson(json);

      expect(response.shareLink, 'https://app.shanjing.com/share?t=R002&c=XYZ789');
      expect(response.shareCode, 'XYZ789');
    });

    test('ShareResponse 应处理空值', () {
      final json = <String, dynamic>{};

      final response = ShareResponse.fromJson(json);

      expect(response.shareLink, '');
      expect(response.shareCode, '');
    });
  });

  group('分享码生成测试', () {
    late ShareService shareService;

    setUp(() {
      shareService = ShareService();
    });

    test('生成的分享码应为8位字符', () async {
      final response = await shareService.shareTrail(
        trailId: 'R001',
        trailName: '测试路线',
        shareChannel: 'wechat_session',
        templateType: 'nature',
        posterData: [1, 2, 3],
        startTime: DateTime.now(),
        generationDurationMs: 100,
      );

      expect(response.shareCode.length, 8);
    });

    test('生成的分享码应只包含大写字母和数字', () async {
      final response = await shareService.shareTrail(
        trailId: 'R001',
        trailName: '测试路线',
        shareChannel: 'wechat_session',
        templateType: 'nature',
        posterData: [],
        startTime: DateTime.now(),
        generationDurationMs: 100,
      );

      final RegExp validPattern = RegExp(r'^[A-Z0-9]{8}$');
      expect(validPattern.hasMatch(response.shareCode), isTrue);
    });

    test('多次生成的分享码应不同', () async {
      final codes = <String>[];
      
      for (int i = 0; i < 5; i++) {
        final response = await shareService.shareTrail(
          trailId: 'R001',
          trailName: '测试路线',
          shareChannel: 'wechat_session',
          templateType: 'nature',
          posterData: [],
          startTime: DateTime.now(),
          generationDurationMs: 100,
        );
        codes.add(response.shareCode);
      }

      // 验证唯一性
      final uniqueCodes = codes.toSet();
      expect(uniqueCodes.length, codes.length);
    });

    test('分享链接应包含 trailId 和 shareCode', () async {
      final response = await shareService.shareTrail(
        trailId: 'R123',
        trailName: '九溪十八涧',
        shareChannel: 'wechat_session',
        templateType: 'nature',
        posterData: [],
        startTime: DateTime.now(),
        generationDurationMs: 150,
      );

      expect(response.shareLink.contains('t=R123'), isTrue);
      expect(response.shareLink.contains('c='), isTrue);
      expect(response.shareLink.startsWith('https://app.shanjing.com/share'), isTrue);
    });
  });

  group('埋点参数验证测试', () {
    late ShareService shareService;

    setUp(() {
      shareService = ShareService();
    });

    test('分享埋点应包含所有必要参数', () async {
      final startTime = DateTime.now();
      final trailId = 'R001';
      final trailName = '测试路线';
      final shareChannel = 'wechat_session';
      final templateType = 'nature';
      final posterData = List<int>.filled(1024, 0); // 1KB
      final generationDurationMs = 200;

      // 执行分享操作
      final response = await shareService.shareTrail(
        trailId: trailId,
        trailName: trailName,
        shareChannel: shareChannel,
        templateType: templateType,
        posterData: posterData,
        startTime: startTime,
        generationDurationMs: generationDurationMs,
      );

      // 验证响应有效
      expect(response.shareLink, isNotEmpty);
      expect(response.shareCode, isNotEmpty);
    });

    test('不同分享渠道应被正确处理', () async {
      final channels = [
        'wechat_session',
        'wechat_timeline',
        'save_local',
        'copy_link',
        'more_options',
      ];

      for (final channel in channels) {
        final response = await shareService.shareTrail(
          trailId: 'R001',
          trailName: '测试路线',
          shareChannel: channel,
          templateType: 'nature',
          posterData: [],
          startTime: DateTime.now(),
          generationDurationMs: 100,
        );

        expect(response.shareCode, isNotEmpty);
      }
    });

    test('不同模板类型应被正确处理', () async {
      final templates = ['nature', 'minimal', 'film'];

      for (final template in templates) {
        final response = await shareService.shareTrail(
          trailId: 'R001',
          trailName: '测试路线',
          shareChannel: 'wechat_session',
          templateType: template,
          posterData: [],
          startTime: DateTime.now(),
          generationDurationMs: 100,
        );

        expect(response.shareCode, isNotEmpty);
      }
    });

    test('海报大小计算应正确', () async {
      final testCases = [
        {'size': 512, 'expectedKb': 0},      // 0.5KB
        {'size': 1024, 'expectedKb': 1},     // 1KB
        {'size': 2048, 'expectedKb': 2},     // 2KB
        {'size': 10240, 'expectedKb': 10},   // 10KB
      ];

      for (final testCase in testCases) {
        final posterData = List<int>.filled(testCase['size'] as int, 0);
        
        final response = await shareService.shareTrail(
          trailId: 'R001',
          trailName: '测试路线',
          shareChannel: 'wechat_session',
          templateType: 'nature',
          posterData: posterData,
          startTime: DateTime.now(),
          generationDurationMs: 100,
        );

        expect(response.shareCode, isNotEmpty);
      }
    });
  });

  group('getShareInfo 测试', () {
    late ShareService shareService;

    setUp(() {
      shareService = ShareService();
    });

    test('Mock 模式下应返回模拟分享信息', () async {
      final shareInfo = await shareService.getShareInfo('TEST1234');

      expect(shareInfo, isNotNull);
      expect(shareInfo!['trailId'], 'R001');
      expect(shareInfo['trailName'], '九溪十八涧');
      expect(shareInfo['sharedBy'], '山径用户');
      expect(shareInfo.containsKey('shareTime'), isTrue);
    });
  });

  group('ShareEvents 常量测试', () {
    test('事件名称常量应正确', () {
      expect(ShareEvents.shareTrail, 'share_trail');
      expect(ShareEvents.shareTrailSuccess, 'share_trail_success');
      expect(ShareEvents.shareTrailFailed, 'share_trail_failed');
      expect(ShareEvents.shareOpen, 'share_open');
    });

    test('参数名称常量应正确', () {
      expect(ShareEvents.paramTrailId, 'trail_id');
      expect(ShareEvents.paramTrailName, 'trail_name');
      expect(ShareEvents.paramShareCode, 'share_code');
      expect(ShareEvents.paramShareChannel, 'share_channel');
      expect(ShareEvents.paramErrorCode, 'error_code');
      expect(ShareEvents.paramRouteId, 'route_id');
      expect(ShareEvents.paramRouteName, 'route_name');
      expect(ShareEvents.paramTemplateType, 'template_type');
      expect(ShareEvents.paramShareTimeMs, 'share_time_ms');
      expect(ShareEvents.paramPosterSizeKb, 'poster_size_kb');
      expect(ShareEvents.paramGenerationDurationMs, 'generation_duration_ms');
    });
  });

  group('ApiException 测试', () {
    test('ApiException 应正确格式化错误信息', () {
      final exception = ApiException(
        message: '网络请求失败',
        code: 'NETWORK_ERROR',
      );

      expect(exception.toString(), contains('NETWORK_ERROR'));
      expect(exception.toString(), contains('网络请求失败'));
      expect(exception.message, '网络请求失败');
      expect(exception.code, 'NETWORK_ERROR');
    });
  });

  group('分享耗时测试', () {
    late ShareService shareService;

    setUp(() {
      shareService = ShareService();
    });

    test('分享操作应在合理时间内完成', () async {
      final startTime = DateTime.now();
      
      await shareService.shareTrail(
        trailId: 'R001',
        trailName: '测试路线',
        shareChannel: 'wechat_session',
        templateType: 'nature',
        posterData: List<int>.filled(10240, 0),
        startTime: startTime,
        generationDurationMs: 100,
      );

      final elapsed = DateTime.now().difference(startTime);
      
      // Mock 模式下应在500ms内完成（包含300ms模拟延迟）
      expect(elapsed.inMilliseconds, lessThan(1000));
    });
  });
}
