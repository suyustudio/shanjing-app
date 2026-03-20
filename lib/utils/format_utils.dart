// format_utils.dart
// 山径APP - 格式化工具

/// 格式化工具类
class FormatUtils {
  /// 格式化距离
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toInt()}米';
    }
    return '${km.toStringAsFixed(1)}公里';
  }

  /// 格式化时长
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes分钟';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours小时';
    }
    return '$hours小时${mins}分钟';
  }

  /// 格式化日期
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return '刚刚';
        }
        return '${diff.inMinutes}分钟前';
      }
      return '${diff.inHours}小时前';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}个月前';
    } else {
      return '${date.year}-${_pad(date.month)}-${_pad(date.day)}';
    }
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
