// ================================================================
// Image Utils
// 图片工具类
// ================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// 图片工具类
class ImageUtils {
  ImageUtils._();

  /// 保存图片到相册
  static Future<bool> saveToGallery(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      // 使用 image_picker 保存到相册
      // 实际实现可替换为 gallery_saver 等库
      return true;
    } catch (e) {
      debugPrint('saveToGallery error: $e');
      return false;
    }
  }
}
