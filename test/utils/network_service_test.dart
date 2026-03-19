import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// 被测试的服务（示例，实际项目中应该替换为真实的网络服务类）
class NetworkService {
  final Connectivity _connectivity;
  StreamSubscription? _subscription;
  ConnectivityResult _currentStatus = ConnectivityResult.none;

  NetworkService(this._connectivity);

  ConnectivityResult get currentStatus => _currentStatus;

  Stream<ConnectivityResult> get onStatusChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _currentStatus = result;
      return result;
    });
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _currentStatus = results.isNotEmpty ? results.first : ConnectivityResult.none;
    return _currentStatus != ConnectivityResult.none;
  }

  void dispose() {
    _subscription?.cancel();
  }
}

// Mock 类
class MockConnectivity extends Mock implements Connectivity {}

@GenerateMocks([Connectivity])
void main() {
  group('NetworkService', () {
    late MockConnectivity mockConnectivity;
    late NetworkService networkService;

    setUp(() {
      mockConnectivity = MockConnectivity();
      networkService = NetworkService(mockConnectivity);
    });

    tearDown(() {
      networkService.dispose();
    });

    group('checkConnectivity', () {
      test('should return true when connected to wifi', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi]);

        final isConnected = await networkService.checkConnectivity();

        expect(isConnected, true);
        expect(networkService.currentStatus, ConnectivityResult.wifi);
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('should return true when connected to mobile', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.mobile]);

        final isConnected = await networkService.checkConnectivity();

        expect(isConnected, true);
        expect(networkService.currentStatus, ConnectivityResult.mobile);
      });

      test('should return false when not connected', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.none]);

        final isConnected = await networkService.checkConnectivity();

        expect(isConnected, false);
        expect(networkService.currentStatus, ConnectivityResult.none);
      });

      test('should handle empty connectivity results', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => []);

        final isConnected = await networkService.checkConnectivity();

        expect(isConnected, false);
        expect(networkService.currentStatus, ConnectivityResult.none);
      });
    });

    group('onStatusChanged', () {
      test('should emit connectivity changes', () async {
        final controller = StreamController<List<ConnectivityResult>>();
        
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => controller.stream);

        final events = <ConnectivityResult>[];
        final subscription = networkService.onStatusChanged.listen(events.add);

        controller.add([ConnectivityResult.wifi]);
        await Future.delayed(Duration.zero);
        
        controller.add([ConnectivityResult.mobile]);
        await Future.delayed(Duration.zero);
        
        controller.add([ConnectivityResult.none]);
        await Future.delayed(Duration.zero);

        expect(events, [
          ConnectivityResult.wifi,
          ConnectivityResult.mobile,
          ConnectivityResult.none,
        ]);

        await subscription.cancel();
        await controller.close();
      });

      test('should update current status on connectivity change', () async {
        final controller = StreamController<List<ConnectivityResult>>();
        
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => controller.stream);

        final subscription = networkService.onStatusChanged.listen((_) {});

        controller.add([ConnectivityResult.wifi]);
        await Future.delayed(Duration.zero);
        expect(networkService.currentStatus, ConnectivityResult.wifi);

        controller.add([ConnectivityResult.mobile]);
        await Future.delayed(Duration.zero);
        expect(networkService.currentStatus, ConnectivityResult.mobile);

        await subscription.cancel();
        await controller.close();
      });

      test('should handle empty results in stream', () async {
        final controller = StreamController<List<ConnectivityResult>>();
        
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => controller.stream);

        final events = <ConnectivityResult>[];
        final subscription = networkService.onStatusChanged.listen(events.add);

        controller.add([]);
        await Future.delayed(Duration.zero);

        expect(events, [ConnectivityResult.none]);
        expect(networkService.currentStatus, ConnectivityResult.none);

        await subscription.cancel();
        await controller.close();
      });
    });

    group('edge cases', () {
      test('should handle multiple connectivity results', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.wifi, ConnectivityResult.mobile]);

        await networkService.checkConnectivity();

        expect(networkService.currentStatus, ConnectivityResult.wifi);
      });

      test('should handle bluetooth connectivity', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.bluetooth]);

        final isConnected = await networkService.checkConnectivity();

        expect(isConnected, true);
        expect(networkService.currentStatus, ConnectivityResult.bluetooth);
      });

      test('should handle ethernet connectivity', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => [ConnectivityResult.ethernet]);

        final isConnected = await networkService.checkConnectivity();

        expect(isConnected, true);
        expect(networkService.currentStatus, ConnectivityResult.ethernet);
      });
    });
  });

  group('Connectivity mocking examples', () {
    test('demonstrates how to mock connectivity checks', () async {
      final mockConnectivity = MockConnectivity();

      // 模拟有网络连接
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final result1 = await mockConnectivity.checkConnectivity();
      expect(result1, contains(ConnectivityResult.wifi));

      // 模拟无网络连接
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final result2 = await mockConnectivity.checkConnectivity();
      expect(result2, contains(ConnectivityResult.none));
    });

    test('demonstrates how to mock connectivity stream', () async {
      final mockConnectivity = MockConnectivity();
      final controller = StreamController<List<ConnectivityResult>>();

      when(mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => controller.stream);

      final results = <List<ConnectivityResult>>[];
      final subscription = mockConnectivity.onConnectivityChanged.listen(results.add);

      controller.add([ConnectivityResult.wifi]);
      controller.add([ConnectivityResult.mobile]);
      controller.add([ConnectivityResult.none]);

      await Future.delayed(Duration.zero);

      expect(results.length, 3);
      expect(results[0], [ConnectivityResult.wifi]);
      expect(results[1], [ConnectivityResult.mobile]);
      expect(results[2], [ConnectivityResult.none]);

      await subscription.cancel();
      await controller.close();
    });
  });
}
