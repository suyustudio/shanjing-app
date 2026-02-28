# Flutter 导航进度显示组件

## 概述
极简导航进度组件，用于显示路线完成进度、当前位置和剩余距离。

## 组件实现

### NavigationProgressWidget

```dart
import 'package:flutter/material.dart';

class NavigationProgressWidget extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double remainingDistance; // 米
  final VoidCallback? onTap;

  const NavigationProgressWidget({
    Key? key,
    required this.progress,
    required this.remainingDistance,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).toInt();
    final distanceText = _formatDistance(remainingDistance);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 进度百分比
            Text(
              '$percent% 完成',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // 进度条 + 当前位置标记
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 背景条
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // 进度填充
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFF2D968A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // 当前位置标记
                Positioned(
                  left: (progress.clamp(0.0, 1.0) * 100).toDouble(),
                  child: _CurrentPositionMarker(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 剩余距离
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '剩余 $distanceText',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }
}

// 当前位置标记
class _CurrentPositionMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Color(0xFF2D968A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2D968A).withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
```

## 使用示例

```dart
class NavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 地图区域
          Container(color: Colors.grey[300]),
          
          // 导航进度组件
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: NavigationProgressWidget(
              progress: 0.35, // 35% 完成
              remainingDistance: 2500, // 2.5km 剩余
              onTap: () {
                // 点击查看详情
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 属性说明

| 属性 | 类型 | 说明 |
|------|------|------|
| `progress` | double | 进度值 0.0 - 1.0 |
| `remainingDistance` | double | 剩余距离（米）|
| `onTap` | VoidCallback? | 点击回调 |

## 效果预览

```
┌─────────────────────────────┐
│  35% 完成                    │
│  ████████●───────────────── │
│  📍 剩余 2.5 km              │
└─────────────────────────────┘
```

- ● = 当前位置标记（蓝色圆点）
- █ = 已完成路线
- ─ = 剩余路线

## 深色模式适配

### 颜色适配表

| 元素 | 浅色模式 | 深色模式 |
|------|----------|----------|
| 卡片背景 | `Colors.white` | `Color(0xFF1E1E1E)` |
| 主文本 | `Colors.black87` | `Colors.white` |
| 副文本 | `Colors.grey[600]` | `Colors.grey[400]` |
| 进度条背景 | `Colors.grey[200]` | `Color(0xFF3A3A3A)` |
| 进度条填充 | `Color(0xFF2D968A)` | `Color(0xFF4DB6AC)` |
| 位置标记 | `Color(0xFF2D968A)` | `Color(0xFF4DB6AC)` |

### 深色模式实现

```dart
// navigation_progress_dark.dart
class NavigationProgressWidget extends StatelessWidget {
  final double progress;
  final double remainingDistance;
  final VoidCallback? onTap;

  const NavigationProgressWidget({
    Key? key,
    required this.progress,
    required this.remainingDistance,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percent = (progress * 100).clamp(0, 100).toInt();
    final distanceText = _formatDistance(remainingDistance);

    // 颜色配置
    final cardBg = isDark ? Color(0xFF1E1E1E) : Colors.white;
    final primaryText = isDark ? Colors.white : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];
    final progressBg = isDark ? Color(0xFF3A3A3A) : Colors.grey[200];
    final progressFill = isDark ? Color(0xFF4DB6AC) : Color(0xFF2D968A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 进度百分比
            Text(
              '$percent% 完成',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 8),
            
            // 进度条
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: progressBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: progressFill,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  left: (progress.clamp(0.0, 1.0) * 100).toDouble(),
                  child: _CurrentPositionMarker(isDark: isDark),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 剩余距离
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: secondaryText),
                const SizedBox(width: 4),
                Text(
                  '剩余 $distanceText',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }
}

// 当前位置标记（适配深色模式）
class _CurrentPositionMarker extends StatelessWidget {
  final bool isDark;

  const _CurrentPositionMarker({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Color(0xFF4DB6AC) : Color(0xFF2D968A);
    
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
```

## 扩展建议

如需增强功能，可考虑：
- 添加预计到达时间 (ETA)
- 支持分段路线显示
- 添加转弯提示图标
