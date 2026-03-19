# Test Lab 紧急修复报告

**报告日期**: 2026-03-19  
**问题来源**: Firebase Test Lab Build #125  
**修复版本**: Build #126  
**状态**: 🟡 修复中

---

## 1. 问题定位

### 1.1 错误节点分析
- **位置**: MainActivity-18 附近
- **用户路径**: 地点详情页 → 功能入口跳转过程中
- **错误类型**: 非崩溃类错误（断言失败或 UI 超时）
- **视觉特征**: 红褐色全屏错误页

### 1.2 根因分析

根据代码审查，发现以下潜在问题：

#### 🔴 问题 1: 参数传递不完整
**位置**: `map_screen_simple.dart` 第 700-713 行

当跳转到 `TrailDetailScreen` 时，构造的 fallback 数据缺少必要字段：

```dart
trailData: {
  'id': route['id'],
  'name': route['name'],
  'difficulty': route['difficulty'] == '简单' ? 'easy' : ..., // 值转换不匹配
  'distance': route['distance'] ?? 5.0,
  'duration': route['duration'] ?? 120,
  'coordinates': ..., // 可能为 null
  'description': ...,
  'coverImage': route['previewImage'], // 字段名不一致！
}
```

**问题细节**:
1. `coverImage` 在 `TrailDetailScreen` 中期望的是 `coverUrl`，导致图片加载失败
2. `difficulty` 值转换后（easy/medium/hard）与组件期望的中文值不匹配
3. `coordinates` 当 `route['path']` 为 null 时会导致空列表

#### 🔴 问题 2: 空指针风险
**位置**: `trail_detail_screen.dart` 第 120-135 行

```dart
Map<String, dynamic> get _trailData {
  if (widget.trailData != null) {
    return widget.trailData!;  // 可能包含不完整数据
  }
  // 默认数据...
}
```

即使 `trailData` 不为 null，内部字段可能缺失，导致后续使用时报错。

#### 🔴 问题 3: 错误页面设计问题
**位置**: 错误状态页面显示为红褐色全屏
- 视觉冲击过强，给用户焦虑感
- 缺乏友好的恢复操作按钮
- 与 App 整体设计风格不一致

---

## 2. 修复方案

### P0 - 立即修复

#### 修复 1: 统一参数传递格式

**文件**: `lib/screens/map_screen_simple.dart`

修改 `_onRouteCardTap` 方法，确保传递的数据格式与 `TrailDetailScreen` 期望的格式一致：

```dart
void _onRouteCardTap(Map<String, dynamic> route) {
  // 统一使用构造的数据，确保字段完整
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TrailDetailScreen(
        trailData: {
          'id': route['id'] ?? 'unknown',
          'name': route['name'] ?? '未知路线',
          'difficulty': route['difficulty'] ?? '简单', // 保持中文
          'difficultyLevel': _getDifficultyLevel(route['difficulty']),
          'distance': route['distance'] ?? 5.0,
          'duration': route['duration'] ?? 120,
          'elevation': route['elevation'] ?? 0,
          'coordinates': _extractCoordinates(route['path']),
          'description': '${route['name'] ?? '此路线'}是一条风景优美的徒步路线，难度${route['difficulty'] ?? '简单'}。',
          'coverUrl': route['previewImage'] ?? '', // 统一使用 coverUrl
          'isFavorite': false,
          'parkingLots': route['parkingLots'] ?? [],
        },
      ),
    ),
  );
}

int _getDifficultyLevel(String? difficulty) {
  switch (difficulty) {
    case '简单': return 1;
    case '中等': return 3;
    case '困难': return 5;
    default: return 1;
  }
}

List<List<double>> _extractCoordinates(dynamic path) {
  if (path == null || path is! List || path.isEmpty) {
    return [];
  }
  try {
    return path.map((latLng) {
      if (latLng is LatLng) {
        return [latLng.longitude, latLng.latitude];
      }
      return null;
    }).whereType<List<double>>().toList();
  } catch (e) {
    return [];
  }
}
```

#### 修复 2: 增强 TrailDetailScreen 数据防御

**文件**: `lib/screens/trail_detail_screen.dart`

修改 `_trailData` getter 添加字段校验和默认值：

```dart
Map<String, dynamic> get _trailData {
  final data = widget.trailData;
  
  if (data == null) {
    return _getDefaultTrailData();
  }
  
  // 防御性复制，确保所有必需字段存在
  return {
    'id': data['id'] ?? 'trail_unknown',
    'name': data['name'] ?? '未知路线',
    'difficulty': data['difficulty'] ?? '简单',
    'difficultyLevel': data['difficultyLevel'] ?? _getDifficultyLevel(data['difficulty']),
    'distance': (data['distance'] ?? 5.0).toDouble(),
    'duration': data['duration'] ?? 120,
    'elevation': data['elevation'] ?? 0,
    'description': data['description'] ?? '暂无路线描述',
    'coverUrl': data['coverUrl'] ?? data['coverImage'] ?? data['previewImage'] ?? '',
    'isFavorite': data['isFavorite'] ?? false,
    'coordinates': data['coordinates'] ?? [],
    'parkingLots': data['parkingLots'] ?? [],
  };
}

Map<String, dynamic> _getDefaultTrailData() => {
  'id': 'trail_001',
  'name': '西湖环湖步道',
  'coverUrl': 'https://picsum.photos/400/240',
  'difficulty': '中等',
  'difficultyLevel': 3,
  'distance': 12.5,
  'duration': 240,
  'elevation': 150,
  'description': '这是一条风景优美的徒步路线...',
  'isFavorite': false,
};

int _getDifficultyLevel(dynamic difficulty) {
  final d = difficulty?.toString() ?? '';
  switch (d) {
    case '简单':
    case 'easy':
      return 1;
    case '中等':
    case 'medium':
      return 3;
    case '困难':
    case 'hard':
      return 5;
    default:
      return 1;
  }
}
```

#### 修复 3: 优化错误页面

**文件**: `lib/widgets/app_error.dart`

重新设计错误页面，移除红褐色全屏背景：

```dart
import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// 优化后的通用错误状态组件
class AppError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;
  final String? title;

  const AppError({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText = '重试',
    this.icon = Icons.error_outline,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: DesignSystem.getBackground(context), // 使用应用背景色，非红色
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 使用插画风格图标，而非警告图标
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.grey[700] : Colors.grey[200])!,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              // 标题
              if (title != null) ...[
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // 错误信息
              Text(
                message,
                style: TextStyle(
                  color: DesignSystem.getTextSecondary(context),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(retryText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.getPrimary(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // 返回按钮（次要操作）
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('返回上一页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### P1 - 明日优化

1. **添加错误边界 (Error Boundary)**
   - 在关键页面添加 Flutter Error Boundary
   - 捕获渲染错误，防止红屏

2. **完善日志上报**
   - 在参数传递错误时上报详细日志
   - 便于后续分析问题

3. **测试覆盖**
   - 为地点详情页添加单元测试
   - 覆盖各种数据缺失场景

---

## 3. 本地复现步骤

```bash
# 1. 启动模拟器（Pixel API 30）
emulator -avd Pixel_4_API_30 &

# 2. 安装 APK
adb install build/app/outputs/flutter-apk/app-release.apk

# 3. 打开 App，进入地图页面
# 4. 点击路线卡片进入详情页
# 5. 观察是否出现红褐色错误页
```

---

## 4. 验证清单

- [ ] 地点详情页正常显示，无红屏
- [ ] 路线图片正确加载
- [ ] 难度标签显示正确（中文）
- [ ] 点击"开始导航"正常跳转
- [ ] 错误页面使用浅色背景
- [ ] Test Lab 重新测试通过

---

## 5. 后续行动

| 任务 | 负责人 | 截止时间 | 状态 |
|------|--------|----------|------|
| 提交修复代码 | Dev | 今晚 | ⏳ |
| 本地验证修复 | Dev | 今晚 | ⏳ |
| 构建 Build #126 | CI | 明天 | ⏳ |
| Test Lab 回归测试 | QA | 明天 | ⏳ |
| 设计验收错误页 | Design | 明天 | ⏳ |

---

**报告生成**: 2026-03-19 23:00  
**修复提交**: 待完成
