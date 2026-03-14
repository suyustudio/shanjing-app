import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/utils/permission_manager.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('PermissionManager 单元测试', () {
    
    test('PermissionManager 是静态工具类', () {
      // PermissionManager 应该可以直接调用静态方法
      expect(PermissionManager.checkLocationPermission, isA<Function>());
      expect(PermissionManager.requestLocationPermission, isA<Function>());
    });

    test('权限方法返回 Future', () {
      // 验证所有权限检查方法返回 Future
      expect(PermissionManager.checkLocationPermission(), isA<Future<PermissionStatus>>());
      expect(PermissionManager.checkStoragePermission(), isA<Future<PermissionStatus>>());
      expect(PermissionManager.checkCameraPermission(), isA<Future<PermissionStatus>>());
      expect(PermissionManager.checkNotificationPermission(), isA<Future<PermissionStatus>>());
      expect(PermissionManager.checkBackgroundLocationPermission(), isA<Future<PermissionStatus>>());
    });

    test('权限请求方法返回 Future', () {
      // 验证所有权限请求方法返回 Future
      expect(PermissionManager.requestLocationPermission(), isA<Future<PermissionStatus>>());
      expect(PermissionManager.requestStoragePermission(), isA<Future<PermissionStatus>>());
      expect(PermissionManager.requestCameraPermission(), isA<Future<PermissionStatus>>());
      expect(PermissionManager.requestNotificationPermission(), isA<Future<PermissionStatus>>());
      expect(PermissionManager.requestBackgroundLocationPermission(), isA<Future<PermissionStatus>>());
    });

    test('批量权限请求方法返回 Future<Map>', () {
      expect(PermissionManager.requestMapPermissions(), isA<Future<Map<String, PermissionStatus>>>());
      expect(PermissionManager.requestNavigationPermissions(), isA<Future<Map<String, PermissionStatus>>>());
    });

    test('权限检查方法返回 Future<bool>', () {
      expect(PermissionManager.hasAllMapPermissions(), isA<Future<bool>>());
      expect(PermissionManager.hasAllNavigationPermissions(), isA<Future<bool>>());
    });

    test('打开应用设置返回 Future<bool>', () {
      expect(PermissionManager.openAppSettings(), isA<Future<bool>>());
    });
  });
}
