// permission_service.dart
// 山径APP - 权限管理服务

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import '../constants/design_system.dart';

/// 权限状态
enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

/// GPS状态
class GpsStatus {
  final bool isEnabled;
  final bool hasPermission;
  final PermissionStatus permissionStatus;

  GpsStatus({
    required this.isEnabled,
    required this.hasPermission,
    required this.permissionStatus,
  });

  bool get isReady => isEnabled && hasPermission;
}

/// 权限管理服务
/// 
/// 统一管理应用所需权限的申请和检查
class PermissionService {
  PermissionService._();

  // ==================== 权限检查 ====================

  /// 检查位置权限状态
  static Future<GpsStatus> checkLocationStatus() async {
    // 检查位置服务是否开启
    final isLocationEnabled = await Permission.location.serviceStatus.isEnabled;
    
    // 检查位置权限
    final locationStatus = await Permission.location.status;
    final hasLocationPermission = locationStatus.isGranted;

    return GpsStatus(
      isEnabled: isLocationEnabled,
      hasPermission: hasLocationPermission,
      permissionStatus: _convertPermissionStatus(locationStatus),
    );
  }

  /// 检查相机权限
  static Future<PermissionStatus> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return _convertPermissionStatus(status);
  }

  /// 检查存储权限
  static Future<PermissionStatus> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      return _convertPermissionStatus(status);
    } else {
      final status = await Permission.photos.status;
      return _convertPermissionStatus(status);
    }
  }

  /// 检查所有录制所需权限
  static Future<Map<String, PermissionStatus>> checkAllRecordingPermissions() async {
    final locationStatus = await Permission.location.status;
    final cameraStatus = await Permission.camera.status;
    final storageStatus = Platform.isAndroid
        ? await Permission.storage.status
        : await Permission.photos.status;

    return {
      'location': _convertPermissionStatus(locationStatus),
      'camera': _convertPermissionStatus(cameraStatus),
      'storage': _convertPermissionStatus(storageStatus),
    };
  }

  // ==================== 权限申请 ====================

  /// 申请录制所需的所有权限（顺序申请）
  /// 
  /// 顺序：位置 → 相机 → 存储
  static Future<bool> requestRecordingPermissions(BuildContext context) async {
    // 1. 申请位置权限
    final locationGranted = await _requestLocationPermission(context);
    if (!locationGranted) return false;

    // 2. 申请相机权限
    final cameraGranted = await _requestCameraPermission(context);
    if (!cameraGranted) return false;

    // 3. 申请存储权限
    final storageGranted = await _requestStoragePermission(context);
    if (!storageGranted) return false;

    return true;
  }

  /// 申请位置权限
  static Future<bool> _requestLocationPermission(BuildContext context) async {
    // 检查当前状态
    final status = await Permission.location.status;
    
    if (status.isGranted) return true;
    
    if (status.isPermanentlyDenied) {
      // 引导用户去设置
      if (context.mounted) {
        await _showPermissionDialog(
          context,
          title: '需要位置权限',
          message: '轨迹录制需要定位权限来记录您的运动轨迹。请在设置中开启位置权限。',
          icon: Icons.location_on,
          onOpenSettings: openAppSettings,
        );
      }
      return false;
    }

    // 申请权限
    final result = await Permission.location.request();
    
    if (result.isGranted) return true;
    
    // 被拒绝
    if (context.mounted) {
      await _showPermissionDeniedDialog(
        context,
        title: '位置权限被拒绝',
        message: '没有位置权限无法录制轨迹。您可以在设置中重新开启。',
      );
    }
    return false;
  }

  /// 申请相机权限
  static Future<bool> _requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) return true;
    
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDialog(
          context,
          title: '需要相机权限',
          message: '标记POI时需要拍摄照片。请在设置中开启相机权限。',
          icon: Icons.camera_alt,
          onOpenSettings: openAppSettings,
        );
      }
      return false;
    }

    final result = await Permission.camera.request();
    
    if (result.isGranted) return true;
    
    if (context.mounted) {
      await _showPermissionDeniedDialog(
        context,
        title: '相机权限被拒绝',
        message: '没有相机权限无法拍摄POI照片。',
      );
    }
    return false;
  }

  /// 申请存储权限
  static Future<bool> _requestStoragePermission(BuildContext context) async {
    final permission = Platform.isAndroid ? Permission.storage : Permission.photos;
    final status = await permission.status;
    
    if (status.isGranted) return true;
    
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDialog(
          context,
          title: '需要存储权限',
          message: '保存录制数据需要存储权限。请在设置中开启存储权限。',
          icon: Icons.storage,
          onOpenSettings: openAppSettings,
        );
      }
      return false;
    }

    final result = await permission.request();
    
    if (result.isGranted) return true;
    
    if (context.mounted) {
      await _showPermissionDeniedDialog(
        context,
        title: '存储权限被拒绝',
        message: '没有存储权限无法保存录制数据。',
      );
    }
    return false;
  }

  // ==================== 设置跳转 ====================

  /// 打开应用设置
  static Future<void> openAppSettings() async {
    await AppSettings.openAppSettings();
  }

  /// 打开位置设置
  static Future<void> openLocationSettings() async {
    await AppSettings.openLocationSettings();
  }

  // ==================== 对话框 ====================

  /// 显示权限引导对话框
  static Future<void> _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required VoidCallback onOpenSettings,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(icon, size: 48, color: DesignSystem.getPrimary(context)),
        title: Text(title, style: DesignSystem.getTitleLarge(context)),
        content: Text(
          message,
          style: DesignSystem.getBodyMedium(context),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('取消', style: TextStyle(color: DesignSystem.getTextSecondary(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOpenSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.getPrimary(context),
              foregroundColor: DesignSystem.textInverse,
            ),
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 显示权限被拒绝对话框
  static Future<void> _showPermissionDeniedDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.getSurface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.error_outline, size: 48, color: DesignSystem.getError(context)),
        title: Text(title, style: DesignSystem.getTitleLarge(context)),
        content: Text(
          message,
          style: DesignSystem.getBodyMedium(context),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  // ==================== 辅助方法 ====================

  /// 转换权限状态
  static PermissionStatus _convertPermissionStatus(PermissionStatus status) {
    if (status.isGranted) return PermissionStatus.granted;
    if (status.isPermanentlyDenied) return PermissionStatus.permanentlyDenied;
    if (status.isRestricted) return PermissionStatus.restricted;
    return PermissionStatus.denied;
  }

  /// 显示首次使用权限引导
  static Future<void> showFirstTimePermissionGuide(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DesignSystem.getSurface(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignSystem.getDivider(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '需要以下权限',
              style: DesignSystem.getHeadlineSmall(context),
            ),
            const SizedBox(height: 24),
            _buildPermissionItem(
              context,
              icon: Icons.location_on,
              title: '位置权限',
              description: '用于记录您的运动轨迹',
            ),
            const SizedBox(height: 16),
            _buildPermissionItem(
              context,
              icon: Icons.camera_alt,
              title: '相机权限',
              description: '用于拍摄POI标记照片',
            ),
            const SizedBox(height: 16),
            _buildPermissionItem(
              context,
              icon: Icons.storage,
              title: '存储权限',
              description: '用于保存录制数据',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.getPrimary(context),
                  foregroundColor: DesignSystem.textInverse,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('我知道了', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 构建权限项
  static Widget _buildPermissionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DesignSystem.getPrimary(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: DesignSystem.getPrimary(context)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DesignSystem.getTitleSmall(context, weight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: DesignSystem.getBodySmall(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}