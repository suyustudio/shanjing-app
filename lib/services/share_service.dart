/**
 * 分享服务
 * 
 * 处理路线分享功能，调用后端 API 生成分享链接
 */

import 'api_client.dart';
import 'api_config.dart';

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
  /// 返回分享链接
  Future<ShareResponse> shareTrail(String trailId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/share/trail',
      body: {'trailId': trailId},
      parser: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return ShareResponse.fromJson(response.data!);
    }

    throw ApiException(
      message: response.errorMessage ?? '分享失败，请稍后重试',
      code: response.errorCode ?? 'SHARE_FAILED',
    );
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
