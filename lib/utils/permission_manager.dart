import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限管理工具类
/// 统一处理应用所需的所有权限申请
class PermissionManager {
  /// 检查定位权限状态
  static Future<PermissionStatus> checkLocationPermission() async {
    return await Permission.location.status;
  }

  /// 检查后台定位权限状态
  static Future<PermissionStatus> checkBackgroundLocationPermission() async {
    return await Permission.locationAlways.status;
  }

  /// 检查存储权限状态
  static Future<PermissionStatus> checkStoragePermission() async {
    return await Permission.storage.status;
  }

  /// 检查相机权限状态
  static Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  /// 检查通知权限状态
  static Future<PermissionStatus> checkNotificationPermission() async {
    return await Permission.notification.status;
  }

  /// 请求基础定位权限（前台定位）
  static Future<PermissionStatus> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status;
  }

  /// 请求后台定位权限
  /// 注意：必须先获得前台定位权限后才能申请后台定位权限
  static Future<PermissionStatus> requestBackgroundLocationPermission() async {
    // 首先检查前台定位权限
    final locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      // 先申请前台定位权限
      final foregroundStatus = await Permission.location.request();
      if (!foregroundStatus.isGranted) {
        return foregroundStatus;
      }
    }

    // 申请后台定位权限
    final status = await Permission.locationAlways.request();
    return status;
  }

  /// 请求存储权限
  static Future<PermissionStatus> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status;
  }

  /// 请求相机权限
  static Future<PermissionStatus> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status;
  }

  /// 请求通知权限
  static Future<PermissionStatus> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status;
  }

  /// 请求地图所需的所有权限
  /// 包括：定位、存储
  static Future<Map<String, PermissionStatus>> requestMapPermissions() async {
    final results = <String, PermissionStatus>{};

    // 请求定位权限
    results['location'] = await requestLocationPermission();

    // 请求存储权限（离线地图需要）
    results['storage'] = await requestStoragePermission();

    return results;
  }

  /// 请求导航所需的所有权限
  /// 包括：前台定位、后台定位、通知
  static Future<Map<String, PermissionStatus>> requestNavigationPermissions() async {
    final results = <String, PermissionStatus>{};

    // 请求前台定位权限
    results['location'] = await requestLocationPermission();

    // 请求后台定位权限（导航需要）
    results['backgroundLocation'] = await requestBackgroundLocationPermission();

    // 请求通知权限（导航播报需要）
    results['notification'] = await requestNotificationPermission();

    return results;
  }

  /// 检查是否所有地图权限都已授予
  static Future<bool> hasAllMapPermissions() async {
    final locationStatus = await Permission.location.status;
    return locationStatus.isGranted;
  }

  /// 检查是否所有导航权限都已授予
  static Future<bool> hasAllNavigationPermissions() async {
    final locationStatus = await Permission.location.status;
    final backgroundStatus = await Permission.locationAlways.status;
    return locationStatus.isGranted && backgroundStatus.isGranted;
  }

  /// 打开应用设置页面
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// 显示权限拒绝对话框
  static void showPermissionDeniedDialog(
    BuildContext context, {
    required String title,
    required String content,
    VoidCallback? onOpenSettings,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onOpenSettings != null) {
                onOpenSettings();
              } else {
                openAppSettings();
              }
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 显示权限永久拒绝对话框
  static void showPermissionPermanentlyDeniedDialog(
    BuildContext context, {
    required String permissionName,
  }) {
    showPermissionDeniedDialog(
      context,
      title: '需要$permissionName权限',
      content: '请在系统设置中允许应用访问$permissionName，以确保功能正常使用。',
    );
  }
}
