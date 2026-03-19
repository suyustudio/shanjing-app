import 'dart:math';
import '../analytics/analytics_service.dart';
import '../analytics/events/share_events.dart';

/// 分享响应数据
class ShareResponse {
  final String shareLink;
  final String shareCode;

  ShareResponse({
    required this.shareLink,
    required this.shareCode,
  });

  factory ShareResponse.fromJson(Map<String, dynamic> json) {
    return ShareResponse(
      shareLink: json['shareLink'] ?? json['share_link'] ?? '',
      shareCode: json['shareCode'] ?? json['share_code'] ?? '',
    );
  }
}

/// API 异常
class ApiException implements Exception {
  final String message;
  final String code;

  ApiException({required this.message, required this.code});

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}

/// 分享服务（增强版 - 支持Mock模式）
/// 
/// 支持两种模式：
/// 1. Mock模式：本地生成分享链接，无需后端
/// 2. API模式：调用后端 /share/trail 端点
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// 是否使用Mock模式（当后端端点不可用时）
  static const bool _useMock = true;
  
  /// Mock分享链接基础URL
  static const String _mockBaseUrl = 'https://app.shanjing.com/share';

  /// 分享路线
  ///
  /// [trailId] 路线ID
  /// [trailName] 路线名称
  /// [shareChannel] 分享渠道: wechat_session/wechat_timeline/save_local/copy_link/more_options
  /// [templateType] 海报模板类型: nature/minimal/film
  /// [posterData] 海报数据（用于计算大小）
  /// [startTime] 分享开始时间（用于计算耗时）
  /// [generationDurationMs] 海报生成耗时
  /// 返回分享链接
  Future<ShareResponse> shareTrail({
    required String trailId,
    required String trailName,
    required String shareChannel,
    required String templateType,
    required List<int> posterData,
    required DateTime startTime,
    required int generationDurationMs,
  }) async {
    if (_useMock) {
      return _mockShareTrail(
        trailId: trailId,
        trailName: trailName,
        shareChannel: shareChannel,
        templateType: templateType,
        posterData: posterData,
        startTime: startTime,
        generationDurationMs: generationDurationMs,
      );
    } else {
      // API模式 - 实际调用后端
      return _apiShareTrail(
        trailId: trailId,
        trailName: trailName,
        shareChannel: shareChannel,
        templateType: templateType,
        posterData: posterData,
        startTime: startTime,
        generationDurationMs: generationDurationMs,
      );
    }
  }

  /// Mock分享实现
  Future<ShareResponse> _mockShareTrail({
    required String trailId,
    required String trailName,
    required String shareChannel,
    required String templateType,
    required List<int> posterData,
    required DateTime startTime,
    required int generationDurationMs,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 生成分享码
    final shareCode = _generateShareCode();
    
    // 构建分享链接
    final shareLink = '$_mockBaseUrl?t=$trailId&c=$shareCode';
    
    final response = ShareResponse(
      shareLink: shareLink,
      shareCode: shareCode,
    );

    // ✅ 埋点：分享成功（符合 data-tracking-spec-v1.2 规范）
    final shareTimeMs = DateTime.now().difference(startTime).inMilliseconds;
    
    AnalyticsService().trackEvent(ShareEvents.shareTrail, params: {
      ShareEvents.paramRouteId: trailId,
      ShareEvents.paramRouteName: trailName,
      ShareEvents.paramShareChannel: shareChannel,
      ShareEvents.paramTemplateType: templateType,
      ShareEvents.paramShareTimeMs: shareTimeMs,
      ShareEvents.paramPosterSizeKb: posterData.length ~/ 1024,
      ShareEvents.paramGenerationDurationMs: generationDurationMs,
      ShareEvents.paramShareCode: shareCode,
    });

    AnalyticsService().trackEvent(ShareEvents.shareTrailSuccess, params: {
      ShareEvents.paramTrailId: trailId,
      ShareEvents.paramTrailName: trailName,
      ShareEvents.paramShareCode: shareCode,
    });

    return response;
  }

  /// API分享实现（调用后端）
  Future<ShareResponse> _apiShareTrail({
    required String trailId,
    required String trailName,
    required String shareChannel,
    required String templateType,
    required List<int> posterData,
    required DateTime startTime,
    required int generationDurationMs,
  }) async {
    // 实际项目中调用后端API
    // final response = await apiClient.post('/share/trail', body: {...});
    
    // 暂时fallback到mock
    return _mockShareTrail(
      trailId: trailId,
      trailName: trailName,
      shareChannel: shareChannel,
      templateType: templateType,
      posterData: posterData,
      startTime: startTime,
      generationDurationMs: generationDurationMs,
    );
  }

  /// 获取分享信息
  ///
  /// [shareCode] 分享码
  Future<Map<String, dynamic>?> getShareInfo(String shareCode) async {
    if (_useMock) {
      // Mock实现
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'trailId': 'R001',
        'trailName': '九溪十八涧',
        'sharedBy': '山径用户',
        'shareTime': DateTime.now().toIso8601String(),
      };
    } else {
      // API实现
      // final response = await apiClient.get('/share/$shareCode');
      // return response.data;
      return null;
    }
  }

  /// 生成分享码
  String _generateShareCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

/// Analytics Service stub（如果尚未导入）
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  void trackEvent(String event, {Map<String, dynamic>? params}) {
    // 实际埋点实现
    print('[Analytics] $event: $params');
  }
}

/// Share Events stub（如果尚未导入）
class ShareEvents {
  ShareEvents._();

  static const String shareTrail = 'share_trail';
  static const String shareTrailSuccess = 'share_trail_success';
  static const String shareTrailFailed = 'share_trail_failed';
  static const String shareOpen = 'share_open';

  static const String paramTrailId = 'trail_id';
  static const String paramTrailName = 'trail_name';
  static const String paramShareCode = 'share_code';
  static const String paramShareChannel = 'share_channel';
  static const String paramErrorCode = 'error_code';
  
  static const String paramRouteId = 'route_id';
  static const String paramRouteName = 'route_name';
  static const String paramTemplateType = 'template_type';
  static const String paramShareTimeMs = 'share_time_ms';
  static const String paramPosterSizeKb = 'poster_size_kb';
  static const String paramGenerationDurationMs = 'generation_duration_ms';
}
