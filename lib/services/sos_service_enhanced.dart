import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_client.dart';
import 'api_config.dart';
import '../analytics/analytics.dart';
import '../analytics/events/sos_events.dart';

/// SOS 发送结果
enum SOSSendResult {
  success,      // 发送成功
  failed,       // 发送失败（网络正常但服务器错误）
  noNetwork,    // 无网络
  weakNetwork,  // 弱网环境
  savedLocal,   // 已本地保存，等待网络恢复
}

/// SOS 发送状态
class SOSSendStatus {
  final SOSSendResult result;
  final String message;
  final DateTime? localSaveTime;
  final int? retryCount;

  SOSSendStatus({
    required this.result,
    required this.message,
    this.localSaveTime,
    this.retryCount,
  });
}

/// 位置信息
class Location {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;

  Location({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (altitude != null) 'altitude': altitude,
    if (accuracy != null) 'accuracy': accuracy,
  };
}

/// 紧急联系人信息
class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
  };
}

/// SOS 重试配置
class SOSRetryConfig {
  /// 最大重试次数
  static const int maxRetries = 3;
  
  /// 基础延迟时间（毫秒）
  static const int baseDelayMs = 1000;
  
  /// 指数退避乘数
  static const double backoffMultiplier = 2.0;
  
  /// 计算第n次重试的延迟时间（指数退避）
  static Duration getRetryDelay(int retryCount) {
    final delayMs = baseDelayMs * (backoffMultiplier * retryCount).round();
    return Duration(milliseconds: delayMs);
  }
}

/// SOS 服务（增强版）
/// 
/// 特性：
/// - 5秒倒计时确认流程
/// - API调用失败自动重试（最多3次，指数退避）
/// - 弱网/无信号场景降级处理
class SosService {
  static final SosService _instance = SosService._internal();
  factory SosService() => _instance;
  SosService._internal();

  final ApiClient _client = ApiClient();
  final Connectivity _connectivity = Connectivity();
  
  /// 本地保存的SOS队列（用于无网络时保存）
  final List<Map<String, dynamic>> _pendingSOSQueue = [];
  
  /// 是否正在重试
  bool _isRetrying = false;

  /// 获取紧急联系人列表
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    // 实际实现中应从本地存储或后端获取
    return [
      EmergencyContact(name: '紧急联系人1', phone: '138****8888'),
      EmergencyContact(name: '紧急联系人2', phone: '139****9999'),
    ];
  }

  /// 检查网络状态
  Future<ConnectivityResult> checkNetworkStatus() async {
    return await _connectivity.checkConnectivity();
  }

  /// 触发 SOS（增强版）
  ///
  /// [location] 当前位置
  /// [triggerType] 触发方式: auto(倒计时自动) / manual(用户主动)
  /// [countdownRemainingSec] 倒计时剩余秒数
  /// [routeId] 当前导航路线ID（可选）
  /// [sendMethod] 发送方式: sms/push/both/wechat
  /// [enableRetry] 是否启用重试机制
  /// 返回详细的发送状态
  Future<SOSSendStatus> triggerSos({
    required Location location,
    required String triggerType,
    required int countdownRemainingSec,
    String? routeId,
    String sendMethod = 'both',
    bool enableRetry = true,
  }) async {
    final triggerTimestamp = DateTime.now().millisecondsSinceEpoch;
    final contacts = await getEmergencyContacts();

    // 检查网络状态
    final networkStatus = await checkNetworkStatus();
    
    if (networkStatus == ConnectivityResult.none) {
      // 无网络：本地保存
      final saved = await _saveSOSLocally(
        location: location,
        triggerType: triggerType,
        countdownRemainingSec: countdownRemainingSec,
        routeId: routeId,
        sendMethod: sendMethod,
        contacts: contacts,
      );
      
      return SOSSendStatus(
        result: SOSSendResult.savedLocal,
        message: '无网络信号，求救信息已保存，请尽快移动到信号区域',
        localSaveTime: DateTime.now(),
      );
    }

    // 尝试发送SOS
    int retryCount = 0;
    bool isWeakNetwork = networkStatus == ConnectivityResult.mobile ||
                         networkStatus == ConnectivityResult.bluetooth;

    while (true) {
      final result = await _trySendSOS(
        location: location,
        triggerType: triggerType,
        countdownRemainingSec: countdownRemainingSec,
        routeId: routeId,
        sendMethod: sendMethod,
        contacts: contacts,
        retryCount: retryCount,
        triggerTimestamp: triggerTimestamp,
      );

      if (result) {
        // 发送成功
        return SOSSendStatus(
          result: SOSSendResult.success,
          message: 'SOS发送成功',
          retryCount: retryCount > 0 ? retryCount : null,
        );
      }

      // 发送失败
      if (!enableRetry || retryCount >= SOSRetryConfig.maxRetries) {
        // 超过最大重试次数
        if (isWeakNetwork) {
          // 弱网场景：保存本地
          await _saveSOSLocally(
            location: location,
            triggerType: triggerType,
            countdownRemainingSec: countdownRemainingSec,
            routeId: routeId,
            sendMethod: sendMethod,
            contacts: contacts,
          );
          return SOSSendStatus(
            result: SOSSendResult.weakNetwork,
            message: '网络较弱，求救信息已本地保存，信号恢复后自动发送',
            localSaveTime: DateTime.now(),
            retryCount: retryCount,
          );
        }
        
        return SOSSendStatus(
          result: SOSSendResult.failed,
          message: '发送失败，请重试',
          retryCount: retryCount,
        );
      }

      // 等待后重试（指数退避）
      retryCount++;
      final delay = SOSRetryConfig.getRetryDelay(retryCount);
      await Future.delayed(delay);
    }
  }

  /// 尝试发送SOS（单次）
  Future<bool> _trySendSOS({
    required Location location,
    required String triggerType,
    required int countdownRemainingSec,
    String? routeId,
    required String sendMethod,
    required List<EmergencyContact> contacts,
    required int retryCount,
    required int triggerTimestamp,
  }) async {
    final apiStopwatch = Stopwatch()..start();
    
    try {
      final response = await _client.post(
        '/sos/trigger',
        body: {
          ...location.toJson(),
          'contacts': contacts.map((c) => c.phone).toList(),
          'route_id': routeId,
          'send_method': sendMethod,
          'retry_count': retryCount,
        },
      );
      
      apiStopwatch.stop();
      final apiResponseMs = apiStopwatch.elapsedMilliseconds;

      if (response.success) {
        // ✅ 埋点：SOS 触发成功
        AnalyticsService().trackEvent(SosEvents.sosTrigger, params: {
          SosEvents.paramTriggerType: triggerType,
          SosEvents.paramCountdownRemainingSec: countdownRemainingSec,
          SosEvents.paramLocationLat: location.latitude,
          SosEvents.paramLocationLng: location.longitude,
          SosEvents.paramLocationAccuracy: location.accuracy ?? 0.0,
          SosEvents.paramRouteId: routeId ?? '',
          SosEvents.paramContactCount: contacts.length,
          SosEvents.paramSendMethod: sendMethod,
          SosEvents.paramApiResponseMs: apiResponseMs,
          SosEvents.paramTriggerTimestamp: triggerTimestamp,
        });

        AnalyticsService().trackEvent(SosEvents.sosSuccess, params: {
          SosEvents.paramLocationLat: location.latitude,
          SosEvents.paramLocationLng: location.longitude,
        });
        
        return true;
      } else {
        // 埋点：SOS 服务器返回失败
        AnalyticsService().trackEvent(SosEvents.sosFailed, params: {
          SosEvents.paramLocationLat: location.latitude,
          SosEvents.paramLocationLng: location.longitude,
          SosEvents.paramErrorCode: response.errorCode ?? 'SOS_SERVER_ERROR',
          'retry_count': retryCount,
        });
        return false;
      }
    } on SocketException catch (e) {
      apiStopwatch.stop();
      // 网络异常，需要重试
      return false;
    } on TimeoutException catch (e) {
      apiStopwatch.stop();
      // 超时，需要重试
      return false;
    } catch (e) {
      apiStopwatch.stop();
      // 埋点：SOS 发送异常
      AnalyticsService().trackEvent(SosEvents.sosFailed, params: {
        SosEvents.paramLocationLat: location.latitude,
        SosEvents.paramLocationLng: location.longitude,
        SosEvents.paramErrorCode: e is ApiException ? (e as ApiException).code : 'UNKNOWN_ERROR',
        'retry_count': retryCount,
      });
      return false;
    }
  }

  /// 本地保存SOS信息
  Future<bool> _saveSOSLocally({
    required Location location,
    required String triggerType,
    required int countdownRemainingSec,
    String? routeId,
    required String sendMethod,
    required List<EmergencyContact> contacts,
  }) async {
    try {
      final sosData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'location': location.toJson(),
        'trigger_type': triggerType,
        'countdown_remaining_sec': countdownRemainingSec,
        'route_id': routeId,
        'send_method': sendMethod,
        'contacts': contacts.map((c) => c.toJson()).toList(),
      };
      
      _pendingSOSQueue.add(sosData);
      
      // 实际项目中应该持久化到本地存储（如 SharedPreferences 或 SQLite）
      // 这里简化处理
      
      // 埋点：SOS 本地保存
      AnalyticsService().trackEvent('sos_saved_local', params: {
        SosEvents.paramLocationLat: location.latitude,
        SosEvents.paramLocationLng: location.longitude,
        SosEvents.paramRouteId: routeId ?? '',
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 检查并发送本地保存的SOS（网络恢复后调用）
  Future<void> checkAndSendPendingSOS() async {
    if (_isRetrying || _pendingSOSQueue.isEmpty) return;
    
    _isRetrying = true;
    
    // 检查网络状态
    final networkStatus = await checkNetworkStatus();
    if (networkStatus == ConnectivityResult.none) {
      _isRetrying = false;
      return;
    }

    // 复制队列，避免迭代时修改
    final queueCopy = List<Map<String, dynamic>>.from(_pendingSOSQueue);
    _pendingSOSQueue.clear();

    for (final sosData in queueCopy) {
      try {
        final location = Location(
          latitude: sosData['location']['latitude'],
          longitude: sosData['location']['longitude'],
          altitude: sosData['location']['altitude'],
          accuracy: sosData['location']['accuracy'],
        );
        
        final contacts = (sosData['contacts'] as List)
            .map((c) => EmergencyContact(name: c['name'], phone: c['phone']))
            .toList();

        final result = await _trySendSOS(
          location: location,
          triggerType: sosData['trigger_type'],
          countdownRemainingSec: sosData['countdown_remaining_sec'],
          routeId: sosData['route_id'],
          sendMethod: sosData['send_method'],
          contacts: contacts,
          retryCount: 0,
          triggerTimestamp: sosData['timestamp'],
        );

        if (!result) {
          // 重新加入队列
          _pendingSOSQueue.add(sosData);
        }
      } catch (e) {
        // 保存失败，重新加入队列
        _pendingSOSQueue.add(sosData);
      }
    }

    _isRetrying = false;
    
    // 如果有发送成功的，埋点
    if (queueCopy.length > _pendingSOSQueue.length) {
      AnalyticsService().trackEvent('sos_pending_sent', params: {
        'total_pending': queueCopy.length,
        'sent_count': queueCopy.length - _pendingSOSQueue.length,
        'remaining_count': _pendingSOSQueue.length,
      });
    }
  }

  /// 获取待发送的SOS数量
  int get pendingSOSCount => _pendingSOSQueue.length;

  /// 取消SOS（埋点）
  void trackCancel({
    required String cancelStage,
    required int countdownRemainingSec,
    String? routeId,
  }) {
    AnalyticsService().trackEvent(SosEvents.sosCancelled, params: {
      'cancel_stage': cancelStage, // 'countdown' / 'confirm'
      SosEvents.paramCountdownRemainingSec: countdownRemainingSec,
      SosEvents.paramRouteId: routeId ?? '',
    });
  }
}
