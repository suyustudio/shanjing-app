// qa/m4/p1_testing/analytics/analytics_api_failure_test.dart
// 埋点专项测试 - API失败时的埋点处理（3个场景）

import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../utils/analytics_verifier.dart';
import '../utils/network_simulator.dart';

@GenerateMocks([http.Client])
void main() {
  group('API失败埋点处理测试 - 3个场景', () {
    late AnalyticsVerifier analyticsVerifier;
    late NetworkSimulator networkSimulator;
    late MockClient mockClient;

    setUp(() {
      analyticsVerifier = AnalyticsVerifier();
      networkSimulator = NetworkSimulator();
      mockClient = MockClient();
    });

    tearDown(() async {
      await analyticsVerifier.clearCache();
      await networkSimulator.restoreNetwork();
    });

    // ==================== 场景1: SOS API超时失败 ====================
    group('场景1: SOS API超时失败埋点', () {
      test('SOS触发接口10秒超时埋点', () async {
        final startTime = DateTime.now();
        
        // 模拟API超时
        when(mockClient.post(
          any,
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 15)); // 超过10秒超时
          return http.Response('{}', 200);
        });

        try {
          await mockClient.post(
            Uri.parse('https://api.shanjing.app/sos/trigger'),
            body: {'route_id': 'R001'},
          ).timeout(Duration(seconds: 10));
        } on TimeoutException catch (e) {
          final responseTime = DateTime.now().difference(startTime).inMilliseconds;
          
          // 上报API失败埋点
          await analyticsVerifier.trackEvent({
            'event_name': 'api_request_failed',
            'api_name': 'sos_trigger',
            'error_type': 'timeout',
            'http_status': 0,
            'error_message': e.toString(),
            'response_time_ms': responseTime,
            'network_type': 'wifi',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }

        // 验证
        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        expect(failEvents.length, equals(1));
        expect(failEvents[0]['api_name'], equals('sos_trigger'));
        expect(failEvents[0]['error_type'], equals('timeout'));
        expect(failEvents[0]['response_time_ms'], greaterThanOrEqualTo(10000));
      });

      test('SOS接口网络错误埋点', () async {
        final startTime = DateTime.now();
        
        // 模拟网络错误
        when(mockClient.post(
          any,
          body: anyNamed('body'),
        )).thenThrow(SocketException('Connection refused'));

        try {
          await mockClient.post(
            Uri.parse('https://api.shanjing.app/sos/trigger'),
            body: {'route_id': 'R001'},
          );
        } on SocketException catch (e) {
          final responseTime = DateTime.now().difference(startTime).inMilliseconds;
          
          await analyticsVerifier.trackEvent({
            'event_name': 'api_request_failed',
            'api_name': 'sos_trigger',
            'error_type': 'network_error',
            'http_status': 0,
            'error_message': e.toString(),
            'response_time_ms': responseTime,
            'network_type': '4g',
            'route_id': 'R001',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }

        // 验证
        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        expect(failEvents[0]['error_type'], equals('network_error'));
        expect(failEvents[0]['error_message'], contains('Connection refused'));
      });

      test('SOS接口服务器错误埋点', () async {
        // 模拟服务器500错误
        when(mockClient.post(
          any,
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Internal Server Error', 500));

        final startTime = DateTime.now();
        
        final response = await mockClient.post(
          Uri.parse('https://api.shanjing.app/sos/trigger'),
          body: {'route_id': 'R001'},
        );
        
        final responseTime = DateTime.now().difference(startTime).inMilliseconds;

        if (response.statusCode != 200) {
          await analyticsVerifier.trackEvent({
            'event_name': 'api_request_failed',
            'api_name': 'sos_trigger',
            'error_type': 'server_error',
            'http_status': 500,
            'error_message': response.body,
            'response_time_ms': responseTime,
            'network_type': 'wifi',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }

        // 验证
        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        expect(failEvents[0]['error_type'], equals('server_error'));
        expect(failEvents[0]['http_status'], equals(500));
      });
    });

    // ==================== 场景2: 分享API失败 ====================
    group('场景2: 分享API失败埋点', () {
      test('海报生成接口失败埋点', () async {
        final testCases = [
          {'status': 400, 'error': 'Bad Request', 'type': 'client_error'},
          {'status': 429, 'error': 'Too Many Requests', 'type': 'client_error'},
          {'status': 500, 'error': 'Server Error', 'type': 'server_error'},
          {'status': 503, 'error': 'Service Unavailable', 'type': 'server_error'},
        ];

        for (final testCase in testCases) {
          when(mockClient.post(
            any,
            body: anyNamed('body'),
          )).thenAnswer((_) async => 
            http.Response(testCase['error'] as String, testCase['status'] as int));

          final startTime = DateTime.now();
          
          final response = await mockClient.post(
            Uri.parse('https://api.shanjing.app/share/generate'),
            body: {
              'route_id': 'R001',
              'template_type': 'nature',
            },
          );
          
          final responseTime = DateTime.now().difference(startTime).inMilliseconds;

          if (response.statusCode != 200) {
            await analyticsVerifier.trackEvent({
              'event_name': 'api_request_failed',
              'api_name': 'share_generate',
              'error_type': testCase['type'],
              'http_status': testCase['status'],
              'error_message': response.body,
              'response_time_ms': responseTime,
              'network_type': 'wifi',
              'template_type': 'nature',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          }
        }

        // 验证所有错误都被记录
        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        expect(failEvents.length, equals(4));
        
        // 验证状态码分布
        final statusCodes = failEvents.map((e) => e['http_status']).toList();
        expect(statusCodes, containsAll([400, 429, 500, 503]));
      });

      test('分享接口带指数退避重试的埋点', () async {
        var attemptCount = 0;
        final retryDelays = [1000, 2000, 4000, 8000, 16000]; // 毫秒
        
        when(mockClient.post(
          any,
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          attemptCount++;
          if (attemptCount <= 3) {
            return http.Response('Server Busy', 503);
          }
          return http.Response('{"url":"https://share.shanjing.app/abc"}', 200);
        });

        // 执行带重试的请求
        for (var attempt = 0; attempt < 5; attempt++) {
          final startTime = DateTime.now();
          
          try {
            final response = await mockClient.post(
              Uri.parse('https://api.shanjing.app/share/generate'),
              body: {'route_id': 'R001'},
            );
            
            final responseTime = DateTime.now().difference(startTime).inMilliseconds;

            if (response.statusCode == 200) {
              // 最终成功
              await analyticsVerifier.trackEvent({
                'event_name': 'api_request_success',
                'api_name': 'share_generate',
                'attempt_count': attempt + 1,
                'response_time_ms': responseTime,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
              });
              break;
            } else {
              // 记录失败
              await analyticsVerifier.trackEvent({
                'event_name': 'api_request_failed',
                'api_name': 'share_generate',
                'error_type': 'server_error',
                'http_status': response.statusCode,
                'attempt_count': attempt + 1,
                'response_time_ms': responseTime,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
              });
              
              // 等待后退
              if (attempt < retryDelays.length - 1) {
                await Future.delayed(Duration(milliseconds: retryDelays[attempt]));
              }
            }
          } catch (e) {
            // 最终失败
            if (attempt == 4) {
              await analyticsVerifier.trackEvent({
                'event_name': 'api_request_final_failed',
                'api_name': 'share_generate',
                'total_attempts': attempt + 1,
                'final_error': e.toString(),
                'timestamp': DateTime.now().millisecondsSinceEpoch,
              });
            }
          }
        }

        // 验证重试流程埋点
        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        final successEvents = await analyticsVerifier.getEventsByName('api_request_success');
        
        expect(failEvents.length, equals(3)); // 前3次失败
        expect(successEvents.length, equals(1)); // 第4次成功
        expect(successEvents[0]['attempt_count'], equals(4));
      });
    });

    // ==================== 场景3: 导航API失败 ====================
    group('场景3: 导航API失败埋点', () {
      test('路线规划接口失败埋点', () async {
        final startTime = DateTime.now();
        
        when(mockClient.get(any)).thenAnswer((_) async =
          http.Response('Route Not Found', 404));

        final response = await mockClient.get(
          Uri.parse('https://api.shanjing.app/navigation/route?from=...'),
        );
        
        final responseTime = DateTime.now().difference(startTime).inMilliseconds;

        if (response.statusCode != 200) {
          await analyticsVerifier.trackEvent({
            'event_name': 'api_request_failed',
            'api_name': 'navigation_route',
            'error_type': 'client_error',
            'http_status': 404,
            'error_message': response.body,
            'response_time_ms': responseTime,
            'network_type': 'wifi',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }

        // 验证
        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        expect(failEvents[0]['api_name'], equals('navigation_route'));
        expect(failEvents[0]['http_status'], equals(404));
      });

      test('实时路况接口失败埋点', () async {
        final startTime = DateTime.now();
        
        // 模拟请求被取消
        when(mockClient.get(any)).thenThrow(
          HttpException('Connection closed before full header was received'));

        try {
          await mockClient.get(
            Uri.parse('https://api.shanjing.app/navigation/traffic'),
          );
        } catch (e) {
          final responseTime = DateTime.now().difference(startTime).inMilliseconds;
          
          await analyticsVerifier.trackEvent({
            'event_name': 'api_request_failed',
            'api_name': 'navigation_traffic',
            'error_type': 'network_error',
            'http_status': 0,
            'error_message': e.toString(),
            'response_time_ms': responseTime,
            'network_type': '4g',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }

        // 验证
        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        expect(failEvents[0]['error_message'], contains('Connection closed'));
      });
    });

    group('API失败埋点边界测试', () {
      test('不同网络类型下的错误记录', () async {
        final networkTypes = ['wifi', '4g', '3g', '2g', 'none'];
        
        for (final networkType in networkTypes) {
          await analyticsVerifier.trackEvent({
            'event_name': 'api_request_failed',
            'api_name': 'sos_trigger',
            'error_type': 'timeout',
            'http_status': 0,
            'error_message': 'Request timeout',
            'response_time_ms': 10000,
            'network_type': networkType,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }

        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        expect(failEvents.length, equals(5));
        
        final recordedTypes = failEvents.map((e) => e['network_type']).toList();
        expect(recordedTypes, containsAll(networkTypes));
      });

      test('错误信息长度限制测试', () async {
        // 超长错误信息
        final longErrorMessage = 'Error: ' + 'x' * 5000;
        
        await analyticsVerifier.trackEvent({
          'event_name': 'api_request_failed',
          'api_name': 'sos_trigger',
          'error_type': 'unknown',
          'http_status': 0,
          'error_message': longErrorMessage,
          'response_time_ms': 1000,
          'network_type': 'wifi',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 验证错误信息被正确截断或存储
        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        expect(failEvents[0]['error_message'], isNotNull);
        expect(failEvents[0]['error_message'].toString().length, lessThanOrEqualTo(5000));
      });

      test('并发API失败的埋点处理', () async {
        // 同时发起多个API请求
        final futures = List.generate(10, (i) => async {
          await analyticsVerifier.trackEvent({
            'event_name': 'api_request_failed',
            'api_name': 'api_$i',
            'error_type': 'server_error',
            'http_status': 500 + i,
            'error_message': 'Server error $i',
            'response_time_ms': (i + 1) * 100,
            'network_type': 'wifi',
            'timestamp': DateTime.now().millisecondsSinceEpoch + i,
          });
        });

        await Future.wait(futures);

        final failEvents = await analyticsVerifier.getEventsByName('api_request_failed');
        expect(failEvents.length, equals(10));
      });
    });
  });
}

// ==================== Mock Classes ====================
class MockClient extends Mock implements http.Client {}
