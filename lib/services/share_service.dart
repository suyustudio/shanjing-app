/**
 * 分享服务
 *
 * 处理路线分享功能，调用后端 API 生成分享链接
 */

import 'api_client.dart';
import 'api_config.dart';
import '../analytics/analytics.dart';

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

/// 分享服务
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  final ApiClient _apiClient = ApiClient();

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
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/share/trail',
        body: {'trailId': trailId},
        parser: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final shareResponse = ShareResponse.fromJson(response.data!);

        // ✅ 埋点：分享成功（在分享成功后触发）
        final shareTimeMs = DateTime.now().difference(startTime).inMilliseconds;
        AnalyticsService().trackEvent(ShareEvents.shareTrail, params: {
          ShareEvents.paramRouteId: trailId,
          ShareEvents.paramRouteName: trailName,
          ShareEvents.paramShareChannel: shareChannel,
          ShareEvents.paramTemplateType: templateType,
          ShareEvents.paramShareTimeMs: shareTimeMs,
          ShareEvents.paramPosterSizeKb: posterData.length ~/ 1024,
          ShareEvents.paramGenerationDurationMs: generationDurationMs,
          ShareEvents.paramShareCode: shareResponse.shareCode,
        });

        AnalyticsService().trackEvent(ShareEvents.shareTrailSuccess, params: {
          ShareEvents.paramTrailId: trailId,
          ShareEvents.paramShareCode: shareResponse.shareCode,
        });

        return shareResponse;
      }

      // 埋点：分享失败
      AnalyticsService().trackEvent(ShareEvents.shareTrailFailed, params: {
        ShareEvents.paramTrailId: trailId,
        ShareEvents.paramErrorCode: response.errorCode ?? 'SHARE_FAILED',
      });

      throw ApiException(
        message: response.errorMessage ?? '分享失败，请稍后重试',
        code: response.errorCode ?? 'SHARE_FAILED',
      );
    } catch (e) {
      // 埋点：分享失败（异常）
      AnalyticsService().trackEvent(ShareEvents.shareTrailFailed, params: {
        ShareEvents.paramTrailId: trailId,
        ShareEvents.paramErrorCode: e is ApiException ? e.code : 'UNKNOWN_ERROR',
      });
      rethrow;
    }
  }

  /// 获取分享信息
  ///
  /// [shareCode] 分享码
  Future<Map<String, dynamic>?> getShareInfo(String shareCode) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/share/$shareCode',
      parser: (data) => data as Map<String, dynamic>,
    );

    if (response.success) {
      return response.data;
    }

    return null;
  }
}
