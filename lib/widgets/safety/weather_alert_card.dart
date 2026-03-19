import 'package:flutter/material.dart';
import '../../services/weather_service.dart';
import '../../constants/design_system.dart';

/// 天气预警卡片组件
/// 在路线详情页显示天气信息和预警
class WeatherAlertCard extends StatelessWidget {
  final WeatherData weather;
  final List<WeatherAlert> alerts;
  final VoidCallback? onRefresh;
  final VoidCallback? onMoreTap;

  const WeatherAlertCard({
    Key? key,
    required this.weather,
    this.alerts = const [],
    this.onRefresh,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAlerts = alerts.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAlerts 
            ? DesignSystem.getError(context).withOpacity(0.05)
            : DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasAlerts 
              ? DesignSystem.getError(context).withOpacity(0.3)
              : DesignSystem.getDivider(context),
          width: hasAlerts ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Icon(
                hasAlerts ? Icons.warning_amber : Icons.wb_sunny_outlined,
                color: hasAlerts 
                    ? DesignSystem.getError(context)
                    : DesignSystem.getPrimary(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                hasAlerts ? '天气预警' : '天气预报',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.getTextPrimary(context),
                ),
              ),
              const Spacer(),
              if (onRefresh != null)
                GestureDetector(
                  onTap: onRefresh,
                  child: Icon(
                    Icons.refresh,
                    color: DesignSystem.getTextTertiary(context),
                    size: 18,
                  ),
                ),
              if (onRefresh != null) const SizedBox(width: 12),
              if (onMoreTap != null)
                GestureDetector(
                  onTap: onMoreTap,
                  child: Text(
                    '详情',
                    style: TextStyle(
                      fontSize: 13,
                      color: DesignSystem.getPrimary(context),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 天气信息
          Row(
            children: [
              // 天气图标和温度
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: weather.getColor(context).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  weather.icon,
                  color: weather.getColor(context),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${weather.temperature.toStringAsFixed(0)}°C',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: DesignSystem.getTextPrimary(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          weather.weather,
                          style: TextStyle(
                            fontSize: 16,
                            color: DesignSystem.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${weather.windDirection}风 ${weather.windPower} · 湿度${weather.humidity}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: DesignSystem.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // 预警列表
          if (hasAlerts) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _buildAlertItem(context, alert)),
          ],
          
          // 更新时间
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '更新于 ${_formatTime(weather.reportTime)}',
              style: TextStyle(
                fontSize: 11,
                color: DesignSystem.getTextTertiary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, WeatherAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alert.getSeverityColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: alert.getSeverityColor(context).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            alert.icon,
            color: alert.getSeverityColor(context),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: alert.getSeverityColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: DesignSystem.getTextSecondary(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// 路线难度提示卡片
class TrailDifficultyCard extends StatelessWidget {
  final String difficulty;
  final int difficultyLevel;
  final bool isFirstAttempt;
  final String? userExperience;
  final VoidCallback? onMoreTap;

  const TrailDifficultyCard({
    Key? key,
    required this.difficulty,
    required this.difficultyLevel,
    this.isFirstAttempt = false,
    this.userExperience,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _getDifficultyColor(context);
    final personalizedTip = _generatePersonalizedTip();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: difficultyColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: difficultyColor.withOpacity(0.3),
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
                Icons.trending_up,
                color: difficultyColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '路线难度',
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
                    '详情',
                    style: TextStyle(
                      fontSize: 13,
                      color: DesignSystem.getPrimary(context),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 难度等级
          Row(
            children: [
              // 难度徽章
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  difficulty,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: difficultyColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 星级评分
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < difficultyLevel ? Icons.star : Icons.star_border,
                    color: index < difficultyLevel 
                        ? DesignSystem.getWarning(context)
                        : DesignSystem.getDivider(context),
                    size: 20,
                  );
                }),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // 难度说明
          Text(
            _getDifficultyDescription(),
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.getTextSecondary(context),
              height: 1.5,
            ),
          ),
          
          // 个性化提示
          if (personalizedTip != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignSystem.getInfo(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DesignSystem.getInfo(context).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: DesignSystem.getInfo(context),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      personalizedTip,
                      style: TextStyle(
                        fontSize: 13,
                        color: DesignSystem.getTextSecondary(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDifficultyColor(BuildContext context) {
    switch (difficulty) {
      case '简单':
        return DesignSystem.getSuccess(context);
      case '中等':
        return DesignSystem.getWarning(context);
      case '困难':
        return DesignSystem.getError(context);
      default:
        return DesignSystem.getTextTertiary(context);
    }
  }

  String _getDifficultyDescription() {
    switch (difficulty) {
      case '简单':
        return '适合新手和家庭出行，路况良好，坡度平缓，全程约2-3小时可完成。';
      case '中等':
        return '适合有一定户外经验的徒步者，有部分坡度和不平整路段，需要较好体力。';
      case '困难':
        return '需要丰富户外经验和良好体能，可能有陡峭路段、复杂地形，请充分评估自身能力。';
      default:
        return '请根据路线情况评估难度，做好充分准备。';
    }
  }

  String? _generatePersonalizedTip() {
    if (isFirstAttempt && difficultyLevel >= 3) {
      return '💡 这是您首次尝试此难度路线，建议结伴而行，并携带充足的补给。';
    }
    
    if (difficultyLevel >= 4) {
      return '⚠️ 高难度路线，建议提前查看攻略，评估自身体能和经验。';
    }
    
    if (userExperience != null) {
      return '🎯 $userExperience';
    }
    
    return null;
  }
}
