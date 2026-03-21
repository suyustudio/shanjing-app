// export_service.dart
// 山径APP - 轨迹数据导出服务（紧急修复版）

import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/recording_model.dart';

/// 轨迹数据导出服务
/// 
/// 提供录制数据导出功能，支持GPX和JSON格式
class ExportService {
  /// 导出录制会话为GPX格式
  static Future<String?> exportToGpx(RecordingSession session) async {
    try {
      final gpxContent = _buildGpxContent(session);
      final fileName = _generateFileName(session, 'gpx');
      return await _saveToFile(gpxContent, fileName);
    } catch (e) {
      print('GPX导出失败: $e');
      return null;
    }
  }

  /// 导出录制会话为JSON格式
  static Future<String?> exportToJson(RecordingSession session) async {
    try {
      final jsonContent = jsonEncode(session.toJson());
      final fileName = _generateFileName(session, 'json');
      return await _saveToFile(jsonContent, fileName);
    } catch (e) {
      print('JSON导出失败: $e');
      return null;
    }
  }

  /// 构建GPX内容
  static String _buildGpxContent(RecordingSession session) {
    final buffer = StringBuffer();

    // GPX头
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx xmlns="http://www.topografix.com/GPX/1/1"');
    buffer.writeln('     creator="山径APP"');
    buffer.writeln('     version="1.1"');
    buffer.writeln('     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"');
    buffer.writeln('     xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">');
    
    // 元数据
    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>${_escapeXml(session.trailName)}</name>');
    if (session.description != null && session.description!.isNotEmpty) {
      buffer.writeln('    <desc>${_escapeXml(session.description!)}</desc>');
    }
    buffer.writeln('    <time>${session.startTime.toIso8601String()}</time>');
    buffer.writeln('  </metadata>');

    // 轨迹
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>${_escapeXml(session.trailName)}</name>');
    if (session.description != null && session.description!.isNotEmpty) {
      buffer.writeln('    <desc>${_escapeXml(session.description!)}</desc>');
    }
    
    // 轨迹段
    buffer.writeln('    <trkseg>');
    
    // 轨迹点
    for (final point in session.trackPoints) {
      buffer.writeln('      <trkpt lat="${point.latitude}" lon="${point.longitude}">');
      if (point.altitude != 0) {
        buffer.writeln('        <ele>${point.altitude}</ele>');
      }
      buffer.writeln('        <time>${point.timestamp.toIso8601String()}</time>');
      if (point.speed != null && point.speed! > 0) {
        buffer.writeln('        <speed>${point.speed}</speed>');
      }
      if (point.accuracy != null && point.accuracy! > 0) {
        buffer.writeln('        <hdop>${point.accuracy}</hdop>');
      }
      buffer.writeln('      </trkpt>');
    }
    
    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');

    // POI标记
    if (session.pois.isNotEmpty) {
      for (final poi in session.pois) {
        buffer.writeln('  <wpt lat="${poi.latitude}" lon="${poi.longitude}">');
        if (poi.altitude != 0) {
          buffer.writeln('    <ele>${poi.altitude}</ele>');
        }
        buffer.writeln('    <name>${_escapeXml(poi.name)}</name>');
        if (poi.description != null && poi.description!.isNotEmpty) {
          buffer.writeln('    <desc>${_escapeXml(poi.description!)}</desc>');
        }
        buffer.writeln('    <sym>${_getPoiSymbol(poi.type)}</sym>');
        buffer.writeln('    <time>${poi.createdAt.toIso8601String()}</time>');
        buffer.writeln('  </wpt>');
      }
    }

    buffer.writeln('</gpx>');
    return buffer.toString();
  }

  /// 根据POI类型获取GPX符号
  static String _getPoiSymbol(PoiType type) {
    switch (type) {
      case PoiType.start:
        return 'Flag, Red';
      case PoiType.end:
        return 'Flag, Green';
      case PoiType.viewpoint:
        return 'Scenic Area';
      case PoiType.restroom:
        return 'Restroom';
      case PoiType.supply:
        return 'Food Service';
      case PoiType.danger:
        return 'Hazard';
      case PoiType.rest:
        return 'Campground';
      case PoiType.junction:
        return 'Trailhead';
      default:
        return 'Waypoint';
    }
  }

  /// 生成文件名
  static String _generateFileName(RecordingSession session, String extension) {
    final trailName = session.trailName ?? '未命名路线';
    final sanitizedName = trailName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    final timestamp = session.startTime.toIso8601String()
        .replaceAll(RegExp(r'[:.]'), '-')
        .replaceAll('T', '_');
    return '${sanitizedName}_${timestamp}.$extension';
  }

  /// 保存到文件
  static Future<String?> _saveToFile(String content, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/recordings_export/$fileName');
      
      // 确保目录存在
      await file.parent.create(recursive: true);
      
      await file.writeAsString(content);
      
      // 同时保存到Download目录（如果可能）
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final downloadFile = File('${downloadsDir.path}/$fileName');
          await downloadFile.writeAsString(content);
        }
      } catch (e) {
        // 忽略Download目录错误，主目录已保存成功
      }
      
      return file.path;
    } catch (e) {
      print('保存文件失败: $e');
      return null;
    }
  }

  /// XML转义
  static String _escapeXml(String? text) {
    if (text == null) return '';
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// 批量导出所有录制会话
  static Future<List<String>> exportAllToGpx(List<RecordingSession> sessions) async {
    final results = <String>[];
    for (final session in sessions) {
      final path = await exportToGpx(session);
      if (path != null) {
        results.add(path);
      }
    }
    return results;
  }

  /// 批量导出所有录制会话为JSON
  static Future<List<String>> exportAllToJson(List<RecordingSession> sessions) async {
    final results = <String>[];
    for (final session in sessions) {
      final path = await exportToJson(session);
      if (path != null) {
        results.add(path);
      }
    }
    return results;
  }

  /// 获取已导出的文件列表
  static Future<List<String>> getExportedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/recordings_export');
      
      if (!await exportDir.exists()) {
        return [];
      }
      
      final files = await exportDir.list().toList();
      return files
          .where((file) => file is File)
          .map((file) => (file as File).path)
          .toList();
    } catch (e) {
      return [];
    }
  }
}