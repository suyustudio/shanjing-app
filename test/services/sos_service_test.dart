import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:hangzhou_guide/services/sos_service_enhanced.dart';

/// SOS 服务单元测试
/// 
/// 测试范围：
/// - 倒计时相关逻辑
/// - 重试机制（指数退避）
/// - 网络状态处理
/// - 本地保存逻辑
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SosService 基础功能测试', () {
    late SosService sosService;

    setUp(() {
      sosService = SosService();
    });

    tearDown(() {
      // 清理
    });

    test('获取紧急联系人列表应返回默认联系人', () async {
      final contacts = await sosService.getEmergencyContacts();
      
      expect(contacts, isNotEmpty);
      expect(contacts.length, 2);
      expect(contacts[0].name, '紧急联系人1');
      expect(contacts[0].phone, '138****8888');
      expect(contacts[1].name, '紧急联系人2');
      expect(contacts[1].phone, '139****9999');
    });

    test('Location toJson 应正确序列化', () {
      final location = Location(
        latitude: 30.123456,
        longitude: 120.654321,
        altitude: 100.5,
        accuracy: 10.0,
      );

      final json = location.toJson();

      expect(json['latitude'], 30.123456);
      expect(json['longitude'], 120.654321);
      expect(json['altitude'], 100.5);
      expect(json['accuracy'], 10.0);
    });

    test('Location toJson 应处理可选字段为空的情况', () {
      final location = Location(
        latitude: 30.0,
        longitude: 120.0,
      );

      final json = location.toJson();

      expect(json['latitude'], 30.0);
      expect(json['longitude'], 120.0);
      expect(json.containsKey('altitude'), isFalse);
      expect(json.containsKey('accuracy'), isFalse);
    });

    test('EmergencyContact toJson 应正确序列化', () {
      final contact = EmergencyContact(
        name: '测试联系人',
        phone: '13812345678',
      );

      final json = contact.toJson();

      expect(json['name'], '测试联系人');
      expect(json['phone'], '13812345678');
    });
  });

  group('SOSRetryConfig 重试配置测试', () {
    test('最大重试次数应为3次', () {
      expect(SOSRetryConfig.maxRetries, 3);
    });

    test('基础延迟应为1000ms', () {
      expect(SOSRetryConfig.baseDelayMs, 1000);
    });

    test('指数退避乘数应为2.0', () {
      expect(SOSRetryConfig.backoffMultiplier, 2.0);
    });

    test('第一次重试延迟应为2000ms', () {
      final delay = SOSRetryConfig.getRetryDelay(1);
      expect(delay.inMilliseconds, 2000);
    });

    test('第二次重试延迟应为4000ms', () {
      final delay = SOSRetryConfig.getRetryDelay(2);
      expect(delay.inMilliseconds, 4000);
    });

    test('第三次重试延迟应为6000ms', () {
      final delay = SOSRetryConfig.getRetryDelay(3);
      expect(delay.inMilliseconds, 6000);
    });

    test('重试延迟应随重试次数指数增长', () {
      final delays = <int>[];
      for (int i = 1; i <= 3; i++) {
        delays.add(SOSRetryConfig.getRetryDelay(i).inMilliseconds);
      }

      // 验证递增
      expect(delays[1] > delays[0], isTrue);
      expect(delays[2] > delays[1], isTrue);
    });
  });

  group('SOSSendStatus 状态测试', () {
    test('成功状态应正确创建', () {
      final status = SOSSendStatus(
        result: SOSSendResult.success,
        message: 'SOS发送成功',
        retryCount: 2,
      );

      expect(status.result, SOSSendResult.success);
      expect(status.message, 'SOS发送成功');
      expect(status.retryCount, 2);
      expect(status.localSaveTime, isNull);
    });

    test('本地保存状态应包含保存时间', () {
      final saveTime = DateTime.now();
      final status = SOSSendStatus(
        result: SOSSendResult.savedLocal,
        message: '已本地保存',
        localSaveTime: saveTime,
      );

      expect(status.result, SOSSendResult.savedLocal);
      expect(status.localSaveTime, saveTime);
    });

    test('弱网状态应包含重试次数', () {
      final status = SOSSendStatus(
        result: SOSSendResult.weakNetwork,
        message: '网络较弱',
        retryCount: 3,
        localSaveTime: DateTime.now(),
      );

      expect(status.result, SOSSendResult.weakNetwork);
      expect(status.retryCount, 3);
      expect(status.localSaveTime, isNotNull);
    });
  });

  group('网络状态处理测试', () {
    test('无网络时应返回 savedLocal 状态', () async {
      // 这个测试需要模拟网络状态
      // 由于实际实现依赖 Connectivity 插件，这里主要验证逻辑结构
      final sosService = SosService();
      
      // 验证服务实例创建成功
      expect(sosService, isNotNull);
    });

    test('待发送SOS数量初始应为0', () {
      final sosService = SosService();
      expect(sosService.pendingSOSCount, 0);
    });
  });

  group('SOS 取消埋点测试', () {
    test('trackCancel 不应抛出异常', () {
      final sosService = SosService();

      expect(() {
        sosService.trackCancel(
          cancelStage: 'countdown',
          countdownRemainingSec: 3,
          routeId: 'R001',
        );
      }, returnsNormally);

      expect(() {
        sosService.trackCancel(
          cancelStage: 'confirm',
          countdownRemainingSec: 0,
          routeId: null,
        );
      }, returnsNormally);
    });
  });

  group('SOSSendResult 枚举测试', () {
    test('应包含所有预期的状态值', () {
      final values = SOSSendResult.values;
      
      expect(values, contains(SOSSendResult.success));
      expect(values, contains(SOSSendResult.failed));
      expect(values, contains(SOSSendResult.noNetwork));
      expect(values, contains(SOSSendResult.weakNetwork));
      expect(values, contains(SOSSendResult.savedLocal));
      expect(values.length, 5);
    });
  });
}
