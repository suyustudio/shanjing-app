import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限类型枚举
enum PermissionType {
  location,
  storage,
  notification,
}

/// 权限状态包装类
class PermissionState {
  final PermissionType type;
  final PermissionStatus status;
  final bool isGranted;
  final bool isPermanentlyDenied;

  const PermissionState({
    required this.type,
    required this.status,
    required this.isGranted,
    required this.isPermanentlyDenied,
  });

  @override
  String toString() {
    return 'PermissionState{type: $type, status: $status, isGranted: $isGranted}';
  }
}

/// 权限管理器
/// 处理所有权限申请和状态检查
class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  /// 权限说明文本
  static const Map<PermissionType, Map<String, String>> _permissionDescriptions = {
    PermissionType.location: {
      'title': '位置权限',
      'description': '用于路线导航和轨迹记录',
      'icon': '📍',
    },
    PermissionType.storage: {
      'title': '存储权限',
      'description': '用于保存离线地图',
      'icon': '💾',
    },
    PermissionType.notification: {
      'title': '通知权限',
      'description': '用于安全提醒和重要通知',
      'icon': '🔔',
    },
  };

  /// 获取权限说明
  Map<String, String> getPermissionDescription(PermissionType type) {
    return _permissionDescriptions[type] ?? {
      'title': '未知权限',
      'description': '',
      'icon': '❓',
    };
  }

  /// 将 PermissionType 转换为 permission_handler 的 Permission
  Permission _getPermission(PermissionType type) {
    switch (type) {
      case PermissionType.location:
        return Permission.location;
      case PermissionType.storage:
        return Permission.storage;
      case PermissionType.notification:
        return Permission.notification;
    }
  }

  /// 检查单个权限状态
  Future<PermissionState> checkPermission(PermissionType type) async {
    final permission = _getPermission(type);
    final status = await permission.status;

    return PermissionState(
      type: type,
      status: status,
      isGranted: status.isGranted,
      isPermanentlyDenied: status.isPermanentlyDenied,
    );
  }

  /// 检查多个权限状态
  Future<Map<PermissionType, PermissionState>> checkPermissions(
    List<PermissionType> types,
  ) async {
    final results = <PermissionType, PermissionState>{};
    for (final type in types) {
      results[type] = await checkPermission(type);
    }
    return results;
  }

  /// 申请单个权限
  Future<PermissionState> requestPermission(PermissionType type) async {
    final permission = _getPermission(type);
    final status = await permission.request();

    return PermissionState(
      type: type,
      status: status,
      isGranted: status.isGranted,
      isPermanentlyDenied: status.isPermanentlyDenied,
    );
  }

  /// 申请多个权限
  Future<Map<PermissionType, PermissionState>> requestPermissions(
    List<PermissionType> types,
  ) async {
    final results = <PermissionType, PermissionState>{};
    for (final type in types) {
      results[type] = await requestPermission(type);
    }
    return results;
  }

  /// 申请所有必要权限
  Future<Map<PermissionType, PermissionState>> requestAllPermissions() async {
    return requestPermissions([
      PermissionType.location,
      PermissionType.storage,
      PermissionType.notification,
    ]);
  }

  /// 检查是否所有必要权限都已授权
  Future<bool> areAllPermissionsGranted() async {
    final results = await checkPermissions([
      PermissionType.location,
      PermissionType.storage,
      PermissionType.notification,
    ]);

    return results.values.every((state) => state.isGranted);
  }

  /// 获取未授权的权限列表
  Future<List<PermissionType>> getDeniedPermissions() async {
    final results = await checkPermissions([
      PermissionType.location,
      PermissionType.storage,
      PermissionType.notification,
    ]);

    return results.entries
        .where((entry) => !entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();
  }

  /// 打开应用设置页面
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// 显示权限说明对话框
  Future<bool?> showPermissionExplanationDialog(
    BuildContext context,
    PermissionType type,
  ) async {
    final desc = getPermissionDescription(type);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(desc['icon'] ?? ''),
            const SizedBox(width: 8),
            Text(desc['title'] ?? ''),
          ],
        ),
        content: Text(desc['description'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('去授权'),
          ),
        ],
      ),
    );
  }

  /// 显示权限被拒绝的提示对话框
  Future<void> showPermissionDeniedDialog(
    BuildContext context,
    PermissionType type,
  ) async {
    final desc = getPermissionDescription(type);

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${desc['title']}被拒绝'),
        content: Text(
          '您已拒绝${desc['title']}，这可能会影响部分功能的使用。您可以在设置中随时开启。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 显示跳过后可在设置中开启的提示
  void showSkipTip(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('您可以在设置中随时开启权限'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
