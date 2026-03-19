import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/constants/design_system.dart';

/// 像素级视觉测试
/// 基于 design-hifi-v1.0.md 的高保真设计规范
void main() {
  group('路线详情页 - 封面图区域像素级测试', () {
    testWidgets('封面图区域高度应为 200px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      // 查找封面图容器
      final coverContainer = find.byKey(const Key('trail_cover_image'));
      expect(coverContainer, findsOneWidget);
      
      final size = tester.getSize(coverContainer);
      expect(size.height, equals(200.0),
        reason: '封面图区域高度应为 200px');
    });
    
    testWidgets('封面图底部圆角应为 12px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final coverContainer = find.byKey(const Key('trail_cover_image'));
      final container = tester.widget<Container>(coverContainer);
      final decoration = container.decoration as BoxDecoration?;
      
      expect(decoration, isNotNull,
        reason: '封面图应有 BoxDecoration');
      
      final borderRadius = decoration?.borderRadius as BorderRadius?;
      expect(borderRadius, isNotNull,
        reason: '封面图应有 BorderRadius');
      
      // 验证底部圆角为 12px
      expect(borderRadius?.bottomLeft.x, equals(12.0),
        reason: '封面图底部左侧圆角应为 12px');
      expect(borderRadius?.bottomRight.x, equals(12.0),
        reason: '封面图底部右侧圆角应为 12px');
    });
    
    testWidgets('封面图渐变遮罩存在', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      // 查找渐变遮罩
      final gradientOverlay = find.byKey(const Key('cover_gradient_overlay'));
      expect(gradientOverlay, findsOneWidget,
        reason: '封面图应有渐变遮罩确保文字可读性');
    });
    
    testWidgets('难度标签位置正确（左下 16px, 12px）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final coverContainer = find.byKey(const Key('trail_cover_image'));
      final difficultyTag = find.byKey(const Key('difficulty_tag'));
      
      expect(difficultyTag, findsOneWidget);
      
      final coverRect = tester.getRect(coverContainer);
      final tagRect = tester.getRect(difficultyTag);
      
      // 验证距离左边界 16px
      expect(tagRect.left - coverRect.left, equals(16.0),
        reason: '难度标签应距离左边界 16px');
      
      // 验证距离下边界 12px
      expect(coverRect.bottom - tagRect.bottom, equals(12.0),
        reason: '难度标签应距离下边界 12px');
    });
  });
  
  group('路线详情页 - 路线名称区像素级测试', () {
    testWidgets('路线名称字号应为 22px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final title = find.byKey(const Key('trail_name'));
      expect(title, findsOneWidget);
      
      final textWidget = tester.widget<Text>(title);
      final style = textWidget.style;
      
      expect(style?.fontSize, equals(22.0),
        reason: '路线名称字号应为 22px');
    });
    
    testWidgets('路线名称字重应为 Semibold (w600)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final title = find.byKey(const Key('trail_name'));
      final textWidget = tester.widget<Text>(title);
      final style = textWidget.style;
      
      expect(style?.fontWeight, equals(FontWeight.w600),
        reason: '路线名称字重应为 Semibold (600)');
    });
    
    testWidgets('路线名称行高应为 30px (约 1.36)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final title = find.byKey(const Key('trail_name'));
      final textWidget = tester.widget<Text>(title);
      final style = textWidget.style;
      
      expect(style?.height, closeTo(30 / 22, 0.1),
        reason: '路线名称行高应为 30px (约 1.36)');
    });
    
    testWidgets('路线名称上边距应为 16px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final coverContainer = find.byKey(const Key('trail_cover_image'));
      final title = find.byKey(const Key('trail_name'));
      
      final coverRect = tester.getRect(coverContainer);
      final titleRect = tester.getRect(title);
      
      expect(titleRect.top - coverRect.bottom, equals(16.0),
        reason: '路线名称应距离封面图 16px');
    });
    
    testWidgets('路线名称最大行数应为 2 行', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final title = find.byKey(const Key('trail_name'));
      final textWidget = tester.widget<Text>(title);
      
      expect(textWidget.maxLines, equals(2),
        reason: '路线名称最大应为 2 行');
      expect(textWidget.overflow, equals(TextOverflow.ellipsis),
        reason: '路线名称超出应显示省略号');
    });
  });
  
  group('路线详情页 - 核心数据区像素级测试', () {
    testWidgets('核心数据区高度应为 88px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final statsSection = find.byKey(const Key('trail_stats_section'));
      expect(statsSection, findsOneWidget);
      
      final size = tester.getSize(statsSection);
      expect(size.height, equals(88.0),
        reason: '核心数据区高度应为 88px');
    });
    
    testWidgets('核心数据区三列等分布局', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final statsSection = find.byKey(const Key('trail_stats_section'));
      final sectionWidth = tester.getSize(statsSection).width;
      
      // 每个数据项应占 1/3 宽度（减去间距）
      final statItems = find.byKey(const Key('stat_item'));
      expect(statItems, findsNWidgets(3));
      
      // 验证每个项目宽度大致相等
      final firstItemWidth = tester.getSize(statItems.first).width;
      expect(firstItemWidth, closeTo(sectionWidth / 3, 20),
        reason: '数据项应大致等分布局');
    });
    
    testWidgets('核心数据数字字号统一', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final statValues = find.byKey(const Key('stat_value'));
      expect(statValues, findsWidgets);
      
      // 验证所有数值使用相同字号
      final firstValue = tester.widget<Text>(statValues.first);
      final fontSize = firstValue.style?.fontSize;
      
      expect(fontSize, isNotNull);
      expect(fontSize, equals(24.0),
        reason: '核心数据数值字号应为 24px');
    });
  });
  
  group('难度标签 - 像素级规范测试', () {
    testWidgets('难度标签内边距应为 4px 垂直, 8px 水平', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: Center(
              child: DifficultyTag(difficulty: '休闲'),
            ),
          ),
        ),
      );
      
      final tag = find.byType(DifficultyTag);
      final container = tester.widget<Container>(tag);
      final padding = container.padding as EdgeInsets?;
      
      expect(padding?.top, equals(4.0),
        reason: '难度标签上内边距应为 4px');
      expect(padding?.bottom, equals(4.0),
        reason: '难度标签下内边距应为 4px');
      expect(padding?.left, equals(8.0),
        reason: '难度标签左内边距应为 8px');
      expect(padding?.right, equals(8.0),
        reason: '难度标签右内边距应为 8px');
    });
    
    testWidgets('难度标签圆角应为 4px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: Center(
              child: DifficultyTag(difficulty: '休闲'),
            ),
          ),
        ),
      );
      
      final tag = find.byType(DifficultyTag);
      final container = tester.widget<Container>(tag);
      final decoration = container.decoration as BoxDecoration?;
      final borderRadius = decoration?.borderRadius as BorderRadius?;
      
      expect(borderRadius?.topLeft.x, equals(4.0),
        reason: '难度标签圆角应为 4px');
    });
    
    testWidgets('难度标签色值符合设计规范', (tester) async {
      // 休闲 - 翠竹绿
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: Center(
              child: DifficultyTag(difficulty: '休闲'),
            ),
          ),
        ),
      );
      
      final easyTag = find.byType(DifficultyTag);
      var container = tester.widget<Container>(easyTag);
      var decoration = container.decoration as BoxDecoration?;
      
      expect(decoration?.color, equals(const Color(0xFF4CAF50)),
        reason: '休闲难度标签背景色应为 #4CAF50');
      
      // 轻度 - 黄绿
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: Center(
              child: DifficultyTag(difficulty: '轻度'),
            ),
          ),
        ),
      );
      
      final mediumTag = find.byType(DifficultyTag);
      container = tester.widget<Container>(mediumTag);
      decoration = container.decoration as BoxDecoration?;
      
      expect(decoration?.color, equals(const Color(0xFF8BC34A)),
        reason: '轻度难度标签背景色应为 #8BC34A');
      
      // 进阶 - 橙黄
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: Center(
              child: DifficultyTag(difficulty: '进阶'),
            ),
          ),
        ),
      );
      
      final hardTag = find.byType(DifficultyTag);
      container = tester.widget<Container>(hardTag);
      decoration = container.decoration as BoxDecoration?;
      
      expect(decoration?.color, equals(const Color(0xFFFF9800)),
        reason: '进阶难度标签背景色应为 #FF9800');
      
      // 挑战 - 红色
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: Center(
              child: DifficultyTag(difficulty: '挑战'),
            ),
          ),
        ),
      );
      
      final extremeTag = find.byType(DifficultyTag);
      container = tester.widget<Container>(extremeTag);
      decoration = container.decoration as BoxDecoration?;
      
      expect(decoration?.color, equals(const Color(0xFFF44336)),
        reason: '挑战难度标签背景色应为 #F44336');
    });
  });
  
  group('底部操作栏 - 像素级规范测试', () {
    testWidgets('底部操作栏按钮高度应为 48px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final primaryButton = find.byKey(const Key('primary_action_button'));
      expect(primaryButton, findsOneWidget);
      
      final size = tester.getSize(primaryButton);
      expect(size.height, equals(48.0),
        reason: '底部操作栏按钮高度应为 48px');
    });
    
    testWidgets('底部操作栏按钮圆角应为 12px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final primaryButton = find.byKey(const Key('primary_action_button'));
      final button = tester.widget<ElevatedButton>(primaryButton);
      final style = button.style as ButtonStyle?;
      
      // 验证圆角
      final shape = style?.shape?.resolve({});
      if (shape is RoundedRectangleBorder) {
        expect(shape.borderRadius, equals(BorderRadius.circular(12)),
          reason: '按钮圆角应为 12px');
      }
    });
    
    testWidgets('底部操作栏按钮间距应为 12px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TrailDetailPage(),
        ),
      );
      
      final buttonsRow = find.byKey(const Key('bottom_action_row'));
      final row = tester.widget<Row>(buttonsRow);
      
      // 验证间距
      expect(row.spacing, equals(12.0),
        reason: '底部操作栏按钮间距应为 12px');
    });
  });
  
  group('颜色 Token 精确值验证', () {
    test('主品牌色应为 #2D968A', () {
      expect(DesignSystem.primary, equals(const Color(0xFF2D968A)),
        reason: '主品牌色应为 #2D968A');
    });
    
    test('路线名称颜色应为 #111827', () {
      expect(DesignSystem.trailTitleColor, equals(const Color(0xFF111827)),
        reason: '路线名称颜色应为 #111827');
    });
    
    test('评分图标颜色应为 #FFB800', () {
      expect(DesignSystem.ratingColor, equals(const Color(0xFFFFB800)),
        reason: '评分图标颜色应为 #FFB800');
    });
    
    test('暗黑模式主按钮颜色应为 #3DAB9E', () {
      expect(DesignSystem.darkPrimary, equals(const Color(0xFF3DAB9E)),
        reason: '暗黑模式主按钮颜色应为 #3DAB9E');
    });
    
    test('暗黑模式背景色应为 #0A0F14', () {
      expect(DesignSystem.darkBackground, equals(const Color(0xFF0A0F14)),
        reason: '暗黑模式背景色应为 #0A0F14');
    });
    
    test('暗黑模式卡片背景应为 #141C24', () {
      expect(DesignSystem.darkSurface, equals(const Color(0xFF141C24)),
        reason: '暗黑模式卡片背景应为 #141C24');
    });
  });
}

// ============ 测试辅助组件 ============

class TrailDetailPage extends StatelessWidget {
  const TrailDetailPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图区域
          Container(
            key: const Key('trail_cover_image'),
            height: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage('https://example.com/image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // 渐变遮罩
                Positioned.fill(
                  child: Container(
                    key: const Key('cover_gradient_overlay'),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                // 难度标签
                Positioned(
                  left: 16,
                  bottom: 12,
                  child: Container(
                    key: const Key('difficulty_tag'),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '休闲',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 路线名称
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Text(
              '九溪十八涧',
              key: const Key('trail_name'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 30 / 22,
                color: Color(0xFF111827),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // 核心数据区
          Container(
            key: const Key('trail_stats_section'),
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('5.6', '公里'),
                _buildStatItem('2.5', '小时'),
                _buildStatItem('120', '爬升米'),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 底部操作栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              key: const Key('bottom_action_row'),
              spacing: 12,
              children: [
                Expanded(
                  child: ElevatedButton(
                    key: const Key('primary_action_button'),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D968A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('开始导航'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.share),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String value, String unit) {
    return Column(
      key: const Key('stat_item'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          key: const Key('stat_value'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        Text(
          unit,
          key: const Key('stat_unit'),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class DifficultyTag extends StatelessWidget {
  final String difficulty;
  
  const DifficultyTag({
    super.key,
    required this.difficulty,
  });
  
  Color get _backgroundColor {
    switch (difficulty) {
      case '休闲':
        return const Color(0xFF4CAF50);
      case '轻度':
        return const Color(0xFF8BC34A);
      case '进阶':
        return const Color(0xFFFF9800);
      case '挑战':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4CAF50);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
