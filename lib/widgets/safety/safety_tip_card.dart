import 'package:flutter/material.dart';

/// 安全提示卡片组件
/// 根据路线特点显示相应的安全建议
class SafetyTipCard extends StatelessWidget {
  final List<SafetyTip> tips;
  final VoidCallback? onMoreTap;

  const SafetyTipCard({
    Key? key,
    required this.tips,
    this.onMoreTap,
  }) : super(key: key);

  /// 根据路线数据生成安全提示
  factory SafetyTipCard.fromTrailData({
    Key? key,
    required Map<String, dynamic> trailData,
    VoidCallback? onMoreTap,
  }) {
    final tips = SafetyTipGenerator.generateFromTrailData(trailData);
    return SafetyTipCard(
      key: key,
      tips: tips,
      onMoreTap: onMoreTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // 颜色定义
    final Color warningColor = const Color(0xFFFFA726);
    final Color textPrimaryColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
    final Color textSecondaryColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF666666);
    final Color primaryColor = const Color(0xFF2D968A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: warningColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimaryColor,
                ),
              ),
              const Spacer(),
              if (onMoreTap != null)
                GestureDetector(
                  onTap: onMoreTap,
                  child: Text(
                    '更多',
                    style: TextStyle(
                      fontSize: 13,
                      color: primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 提示列表
          ...tips.map((tip) => _buildTipItem(context, tip)),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, SafetyTip tip) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final Color textSecondaryColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF666666);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: tip.getSeverityColor(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip.message,
              style: TextStyle(
                fontSize: 14,
                color: textSecondaryColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 安全提示数据模型
class SafetyTip {
  final String message;
  final TipSeverity severity;
  final TipCategory category;

  SafetyTip({
    required this.message,
    this.severity = TipSeverity.medium,
    this.category = TipCategory.general,
  });

  /// 在 Widget 中获取实际颜色
  Color getSeverityColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    
    switch (severity) {
      case TipSeverity.low:
        return const Color(0xFF4CAF50);
      case TipSeverity.medium:
        return const Color(0xFFFFA726);
      case TipSeverity.high:
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF4CAF50);
    }
  }
}

/// 提示严重度
enum TipSeverity {
  low,
  medium,
  high,
}

/// 提示分类
enum TipCategory {
  general, // 一般
  terrain, // 地形
  weather, // 天气
  equipment, // 装备
  difficulty, // 难度
  wildlife, // 野生动物
  water, // 水源
}

/// 安全提示生成器
class SafetyTipGenerator {
  /// 根据路线数据生成安全提示
  static List<SafetyTip> generateFromTrailData(Map<String, dynamic> trailData) {
    final tips = <SafetyTip>[];

    // 获取路线信息
    final difficulty = trailData['difficulty']?.toString() ?? '';
    final difficultyLevel = trailData['difficultyLevel'] as int? ?? 1;
    final distance = (trailData['distance'] as num?)?.toDouble() ?? 0;
    final elevation = (trailData['elevation'] as num?)?.toDouble() ?? 0;
    final name = trailData['name']?.toString() ?? '';
    final description = trailData['description']?.toString() ?? '';

    // 根据难度等级生成提示
    if (difficultyLevel >= 4) {
      tips.add(SafetyTip(
        message: '本路线难度较高，建议有丰富的户外经验者尝试',
        severity: TipSeverity.high,
        category: TipCategory.difficulty,
      ));
    } else if (difficultyLevel >= 3) {
      tips.add(SafetyTip(
        message: '本路线有一定难度，建议有一定户外基础的徒步者',
        severity: TipSeverity.medium,
        category: TipCategory.difficulty,
      ));
    }

    // 根据距离生成提示
    if (distance >= 15) {
      tips.add(SafetyTip(
        message: '本路线较长（${distance}km），建议带足水和食物，注意体力分配',
        severity: TipSeverity.medium,
        category: TipCategory.difficulty,
      ));
    } else if (distance >= 8) {
      tips.add(SafetyTip(
        message: '本路线距离适中（${distance}km），建议准备适量的水和食物',
        severity: TipSeverity.low,
        category: TipCategory.difficulty,
      ));
    }

    // 根据海拔生成提示
    if (elevation >= 500) {
      tips.add(SafetyTip(
        message: '本路线有较大爬升（${elevation}m），建议携带登山杖，注意心率',
        severity: TipSeverity.medium,
        category: TipCategory.terrain,
      ));
    }

    // 根据描述关键词生成提示
    if (description.contains('涉水') || name.contains('溪') || name.contains('瀑')) {
      tips.add(SafetyTip(
        message: '本路线有涉水路段，雨后路面湿滑，请穿防滑鞋，注意安全',
        severity: TipSeverity.medium,
        category: TipCategory.terrain,
      ));
    }

    if (description.contains('台阶') || name.contains('寺') || name.contains('岳')) {
      tips.add(SafetyTip(
        message: '本路线有较多台阶，注意保护膝盖，建议携带护膝',
        severity: TipSeverity.low,
        category: TipCategory.terrain,
      ));
    }

    if (description.contains('野路') || description.contains('未开发')) {
      tips.add(SafetyTip(
        message: '本路线包含未开发路段，建议携带轨迹导航，结伴而行',
        severity: TipSeverity.high,
        category: TipCategory.terrain,
      ));
    }

    // 默认提示
    if (tips.isEmpty) {
      tips.add(SafetyTip(
        message: '徒步前请检查装备，确保手机电量充足，建议开启行程守护',
        severity: TipSeverity.low,
        category: TipCategory.general,
      ));
    }

    return tips;
  }
}
