import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import '../constants/design_system.dart';

/// 地图自定义标记组件
/// 
/// 提供统一的起点、终点、停车场标记图标生成
/// 支持多种尺寸和状态（正常/选中/悬停）
/// 
/// 使用示例：
/// ```dart
/// Marker(
///   markerId: MarkerId('start'),
///   position: LatLng(30.259, 120.148),
///   icon: await CustomMarkers.start(),
///   infoWindow: InfoWindow(title: '起点'),
/// )
/// ```
class CustomMarkers {
  CustomMarkers._();

  // ==================== 尺寸配置 ====================
  
  /// @1x 基础尺寸
  static const double sizeSmall = 36.0;
  
  /// @2x 标准尺寸（默认）
  static const double sizeMedium = 48.0;
  
  /// @3x 大尺寸
  static const double sizeLarge = 64.0;
  
  /// 选中状态尺寸
  static const double sizeSelected = 56.0;
  
  /// 点击区域尺寸（超出视觉边界）
  static const double hitAreaSize = 64.0;

  // ==================== 颜色配置 ====================
  
  /// 起点标记颜色
  static const Color startColor = Color(0xFF4CAF50);
  static const Color startColorDark = Color(0xFF2E7D32);
  static const Color startColorLight = Color(0xFF81C784);
  
  /// 终点标记颜色
  static const Color endColor = Color(0xFFFF5722);
  static const Color endColorDark = Color(0xFFD84315);
  static const Color endColorLight = Color(0xFF8A65);
  
  /// 停车场标记颜色
  static const Color parkingColor = Color(0xFF2196F3);
  static const Color parkingColorDark = Color(0xFF1565C0);
  static const Color parkingColorLight = Color(0xFF64B5F6);

  // ==================== 缓存机制 ====================
  
  static BitmapDescriptor? _startMarkerCache;
  static BitmapDescriptor? _endMarkerCache;
  static BitmapDescriptor? _parkingMarkerCache;
  static BitmapDescriptor? _startSelectedCache;
  static BitmapDescriptor? _endSelectedCache;
  static BitmapDescriptor? _parkingSelectedCache;

  // ==================== 公共方法 ====================

  /// 获取起点标记图标
  /// 
  /// [size] 图标尺寸，默认 48dp
  /// [selected] 是否选中状态
  static Future<BitmapDescriptor> start({
    double size = sizeMedium,
    bool selected = false,
  }) async {
    if (selected && _startSelectedCache != null) {
      return _startSelectedCache!;
    }
    if (!selected && _startMarkerCache != null) {
      return _startMarkerCache!;
    }

    final icon = await _createMarkerFromSvg(
      'assets/markers/marker_start.svg',
      size: selected ? sizeSelected : size,
    );

    if (selected) {
      _startSelectedCache = icon;
    } else {
      _startMarkerCache = icon;
    }
    return icon;
  }

  /// 获取终点标记图标
  /// 
  /// [size] 图标尺寸，默认 48dp
  /// [selected] 是否选中状态
  static Future<BitmapDescriptor> end({
    double size = sizeMedium,
    bool selected = false,
  }) async {
    if (selected && _endSelectedCache != null) {
      return _endSelectedCache!;
    }
    if (!selected && _endMarkerCache != null) {
      return _endMarkerCache!;
    }

    final icon = await _createMarkerFromSvg(
      'assets/markers/marker_end.svg',
      size: selected ? sizeSelected : size,
    );

    if (selected) {
      _endSelectedCache = icon;
    } else {
      _endMarkerCache = icon;
    }
    return icon;
  }

  /// 获取停车场标记图标
  /// 
  /// [size] 图标尺寸，默认 48dp
  /// [selected] 是否选中状态
  static Future<BitmapDescriptor> parking({
    double size = sizeMedium,
    bool selected = false,
  }) async {
    if (selected && _parkingSelectedCache != null) {
      return _parkingSelectedCache!;
    }
    if (!selected && _parkingMarkerCache != null) {
      return _parkingMarkerCache!;
    }

    final icon = await _createMarkerFromSvg(
      'assets/markers/marker_parking.svg',
      size: selected ? sizeSelected : size,
    );

    if (selected) {
      _parkingSelectedCache = icon;
    } else {
      _parkingMarkerCache = icon;
    }
    return icon;
  }

  /// 预加载所有标记图标
  /// 
  /// 建议在应用启动时调用，避免首次使用时卡顿
  static Future<void> preload() async {
    await Future.wait([
      start(),
      end(),
      parking(),
      start(selected: true),
      end(selected: true),
      parking(selected: true),
    ]);
  }

  /// 清除缓存
  static void clearCache() {
    _startMarkerCache = null;
    _endMarkerCache = null;
    _parkingMarkerCache = null;
    _startSelectedCache = null;
    _endSelectedCache = null;
    _parkingSelectedCache = null;
  }

  // ==================== 私有方法 ====================

  /// 从 SVG 文件创建 BitmapDescriptor
  static Future<BitmapDescriptor> _createMarkerFromSvg(
    String assetPath, {
    required double size,
  }) async {
    try {
      // 加载 SVG 数据
      final svgString = await rootBundle.loadString(assetPath);
      
      // 创建 DrawableRoot
      final drawable = await svg.fromSvgString(svgString, assetPath);
      
      // 创建 Picture
      final picture = drawable.toPicture(
        size: Size(size, size),
      );
      
      // 转换为 Image
      final image = await picture.toImage(
        size.toInt(),
        size.toInt(),
      );
      
      // 转换为 ByteData
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to convert image to byte data');
      }
      
      // 创建 BitmapDescriptor
      return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
    } catch (e) {
      debugPrint('❌ 创建标记图标失败: $e');
      // 回退到默认标记
      return BitmapDescriptor.defaultMarker;
    }
  }

  /// 创建自定义标记 Widget（用于预览或测试）
  static Widget buildMarkerPreview({
    required MarkerType type,
    double size = sizeMedium,
    bool selected = false,
  }) {
    String assetPath;
    Color bgColor;
    
    switch (type) {
      case MarkerType.start:
        assetPath = 'assets/markers/marker_start.svg';
        bgColor = startColor;
        break;
      case MarkerType.end:
        assetPath = 'assets/markers/marker_end.svg';
        bgColor = endColor;
        break;
      case MarkerType.parking:
        assetPath = 'assets/markers/marker_parking.svg';
        bgColor = parkingColor;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: selected 
            ? Border.all(color: Colors.white, width: 3)
            : null,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: selected 
            ? [
                BoxShadow(
                  color: bgColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
      ),
    );
  }
}

/// 标记类型枚举
enum MarkerType {
  /// 起点
  start,
  
  /// 终点
  end,
  
  /// 停车场
  parking,
}

/// 标记状态枚举
enum MarkerState {
  /// 正常状态
  normal,
  
  /// 选中状态
  selected,
  
  /// 悬停/按下状态
  hovered,
  
  /// 禁用状态
  disabled,
}

/// 标记尺寸配置类
class MarkerSizeConfig {
  /// 地图缩放级别对应的标记尺寸
  static double getSizeForZoomLevel(double zoomLevel) {
    if (zoomLevel < 12) {
      return CustomMarkers.sizeSmall; // 36dp
    } else if (zoomLevel < 15) {
      return CustomMarkers.sizeMedium; // 48dp
    } else {
      return CustomMarkers.sizeLarge; // 64dp
    }
  }
}

/// 标记配置扩展
extension MarkerConfig on Marker {
  /// 创建带自定义图标的标记（便捷方法）
  static Future<Marker> createStartMarker({
    required String markerId,
    required LatLng position,
    String? title,
    String? snippet,
    bool selected = false,
  }) async {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: await CustomMarkers.start(selected: selected),
      infoWindow: title != null 
          ? InfoWindow(title: title, snippet: snippet)
          : InfoWindow.noText,
      anchor: const Offset(0.5, 1.0), // 锚点在底部中心
    );
  }

  static Future<Marker> createEndMarker({
    required String markerId,
    required LatLng position,
    String? title,
    String? snippet,
    bool selected = false,
  }) async {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: await CustomMarkers.end(selected: selected),
      infoWindow: title != null 
          ? InfoWindow(title: title, snippet: snippet)
          : InfoWindow.noText,
      anchor: const Offset(0.5, 1.0),
    );
  }

  static Future<Marker> createParkingMarker({
    required String markerId,
    required LatLng position,
    String? name,
    bool selected = false,
  }) async {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: await CustomMarkers.parking(selected: selected),
      infoWindow: name != null 
          ? InfoWindow(title: '🅿️ $name', snippet: '停车场')
          : InfoWindow.noText,
      anchor: const Offset(0.5, 0.5), // 停车场图标锚点居中
    );
  }
}
