import 'package:flutter/material.dart';
import '../constants/design_system.dart';

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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getWarning(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignSystem.getWarning(context).withOpacity(0.3),
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
                color: DesignSystem.getWarning(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.getTextPrimary(context),
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
                      color: DesignSystem.getPrimary(context),
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
                color: DesignSystem.getTextSecondary(context),
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
  /// 注意：此方法需要在有 DesignSystem 导入的上下文中调用
  Color getSeverityColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    
    switch (severity) {
      case TipSeverity.low:
        return isDark ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50);
      case TipSeverity.medium:
        return isDark ? const Color(0xFFFFA726) : const Color(0xFFFFA726);
      case TipSeverity.high:
        return isDark ? const Color(0xFFEF5350) : const Color(0xFFEF5350);
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
        category: TipCategory.equipment,
      ));
    }

    // 根据爬升生成提示
    if (elevation >= 500) {
      tips.add(SafetyTip(
        message: '累计爬升较大（${elevation}m），注意控制节奏，避免高反',
        severity: TipSeverity.medium,
        category: TipCategory.terrain,
      ));
    } else if (elevation >= 300) {
      tips.add(SafetyTip(
        message: '有一定海拔爬升，建议携带登山杖辅助',
        severity: TipSeverity.low,
        category: TipCategory.equipment,
      ));
    }

    // 根据路线名称和描述分析特殊地形
    final lowerName = name.toLowerCase();
    final lowerDesc = description.toLowerCase();

    // 涉水路段
    if (lowerName.contains('溪') || 
        lowerName.contains('涧') || 
        lowerDesc.contains('涉水') ||
        lowerDesc.contains('过河')) {
      tips.add(SafetyTip(
        message: '本路线有涉水路段，请注意防滑，建议穿防水登山鞋',
        severity: TipSeverity.medium,
        category: TipCategory.terrain,
      ));
    }

    // 悬崖/陡峭路段
    if (lowerDesc.contains('悬崖') || 
        lowerDesc.contains('陡峭') || 
        lowerDesc.contains('险') ||
        lowerName.contains('崖')) {
      tips.add(SafetyTip(
        message: '本路线有陡峭路段，请小心行走，不要冒险拍照',
        severity: TipSeverity.high,
        category: TipCategory.terrain,
      ));
    }

    // 密林路段
    if (lowerDesc.contains('林') || 
        lowerDesc.contains('森') ||
        lowerDesc.contains('树')) {
      tips.add(SafetyTip(
        message: '途径林区，建议穿长袖衣物，携带驱虫喷雾',
        severity: TipSeverity.low,
        category: TipCategory.wildlife,
      ));
    }

    // 草甸/开阔地
    if (lowerDesc.contains('草甸') || 
        lowerDesc.contains('草原') ||
        lowerDesc.contains('开阔')) {
      tips.add(SafetyTip(
        message: '有开阔路段，注意防晒，雷雨天气避免在此停留',
        severity: TipSeverity.medium,
        category: TipCategory.weather,
      ));
    }

    // 山洞/隧道
    if (lowerDesc.contains('洞') || 
        lowerDesc.contains('隧道')) {
      tips.add(SafetyTip(
        message: '途径隧道或山洞，建议携带头灯或手电筒',
        severity: TipSeverity.medium,
        category: TipCategory.equipment,
      ));
    }

    // 冬季/雪地
    if (lowerDesc.contains('雪') || lowerName.contains('雪')) {
      tips.add(SafetyTip(
        message: '本路线可能有积雪或结冰，建议携带冰爪',
        severity: TipSeverity.high,
        category: TipCategory.weather,
      ));
    }

    // 补充默认提示（如果提示较少）
    if (tips.isEmpty) {
      tips.add(SafetyTip(
        message: '出发前请检查装备，告知亲友行程安排',
        severity: TipSeverity.low,
        category: TipCategory.general,
      ));
    }

    // 返回前3条提示（避免过多）
    return tips.take(3).toList();
  }

  /// 根据用户历史记录生成个性化建议
  static List<SafetyTip> generatePersonalizedTips({
    required Map<String, dynamic> trailData,
    required List<Map<String, dynamic>> userHistory,
  }) {
    final tips = generateFromTrailData(trailData);

    // 分析用户历史
    if (userHistory.isEmpty) {
      // 新用户
      final difficultyLevel = trailData['difficultyLevel'] as int? ?? 1;
      if (difficultyLevel >= 3) {
        tips.insert(0, SafetyTip(
          message: '这是您首次尝试此难度路线，建议结伴而行',
          severity: TipSeverity.high,
          category: TipCategory.difficulty,
        ));
      }
    } else {
      // 分析用户能力
      final maxDifficulty = userHistory
          .map((h) => h['difficultyLevel'] as int? ?? 1)
          .reduce((a, b) => a > b ? a : b);
      
      final currentDifficulty = trailData['difficultyLevel'] as int? ?? 1;
      
      if (currentDifficulty > maxDifficulty + 1) {
        tips.insert(0, SafetyTip(
          message: '此路线难度超过您以往经验，请充分评估自身能力',
          severity: TipSeverity.high,
          category: TipCategory.difficulty,
        ));
      }
    }

    return tips.take(4).toList();
  }
}
