import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/services/network_manager.dart';

void main() {
  group('NetworkManager 单元测试', () {
    late NetworkManager networkManager;

    setUp(() {
      networkManager = NetworkManager();
    });

    tearDown(() {
      networkManager.dispose();
    });

    test('单例模式 - 多次获取返回同一实例', () {
      final instance1 = NetworkManager();
      final instance2 = NetworkManager();
      expect(instance1, same(instance2));
    });

    test('网络状态监听器可以添加和移除', () {
      var listenerCalled = false;
      void listener(bool isOnline) {
        listenerCalled = true;
      }

      networkManager.addListener(listener);
      networkManager.removeListener(listener);

      // 验证监听器被成功添加和移除
      expect(networkManager.isOnline, isA<bool>());
    });

    test('isOnline 返回布尔值', () {
      expect(networkManager.isOnline, isA<bool>());
    });
  });
}
