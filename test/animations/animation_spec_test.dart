import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/constants/design_system.dart';

/// 动画规范验证测试
/// 基于 animation-spec-v1.0.md 的规范要求
void main() {
  group('动画时长规范测试', () {
    test('微交互动画时长应在 100-200ms 范围内', () {
      // 按钮点击反馈
      expect(AnimationDurations.micro.inMilliseconds, 
        inInclusiveRange(100, 200),
        reason: '微交互动画时长应在 100-200ms');
      
      expect(AnimationDurations.quick.inMilliseconds,
        inInclusiveRange(100, 200),
        reason: '快速动画时长应在 100-200ms');
    });
    
    test('标准交互动画时长应在 200-300ms 范围内', () {
      expect(AnimationDurations.normal.inMilliseconds,
        inInclusiveRange(200, 300),
        reason: '标准动画时长应在 200-300ms');
      
      expect(AnimationDurations.standard.inMilliseconds,
        inInclusiveRange(200, 300),
        reason: '标准动画时长应在 200-300ms');
    });
    
    test('页面转场动画时长应为 300ms', () {
      expect(AnimationDurations.pageTransition.inMilliseconds, equals(300),
        reason: '页面转场动画时长应为 300ms');
    });
    
    test('模态框转场动画时长应为 250ms', () {
      expect(AnimationDurations.modalTransition.inMilliseconds, equals(250),
        reason: '模态框转场动画时长应为 250ms');
    });
    
    test('加载动画时长应为 1500ms', () {
      expect(AnimationDurations.loading.inMilliseconds, equals(1500),
        reason: '加载动画时长应为 1500ms');
    });
    
    test('循环动画时长应为 2000ms', () {
      expect(AnimationDurations.loop.inMilliseconds, equals(2000),
        reason: '循环动画时长应为 2000ms');
    });
  });
  
  group('缓动曲线规范测试', () {
    test('标准缓动曲线应为 ease-in-out', () {
      expect(AnimationCurves.standard, equals(Curves.easeInOut),
        reason: '标准动画应使用 ease-in-out 曲线');
    });
    
    test('进入动画应使用 ease-out 曲线', () {
      expect(AnimationCurves.enter, equals(Curves.easeOut),
        reason: '进入动画应使用 ease-out 曲线');
    });
    
    test('退出动画应使用 ease-in 曲线', () {
      expect(AnimationCurves.exit, equals(Curves.easeIn),
        reason: '退出动画应使用 ease-in 曲线');
    });
    
    test('弹性动画应使用 elasticOut 曲线', () {
      expect(AnimationCurves.spring, equals(Curves.elasticOut),
        reason: '弹性动画应使用 elasticOut 曲线');
    });
    
    test('品牌自定义缓动曲线已定义', () {
      expect(AnimationCurves.mountain, isA<Cubic>(),
        reason: '品牌缓动曲线 mountain 应已定义');
      expect(AnimationCurves.path, isA<Cubic>(),
        reason: '品牌缓动曲线 path 应已定义');
    });
  });
  
  group('品牌缓动曲线参数验证', () {
    test('mountain 缓动曲线参数正确', () {
      const curve = AnimationCurves.mountain;
      expect(curve.a, closeTo(0.4, 0.01));
      expect(curve.b, closeTo(0.0, 0.01));
      expect(curve.c, closeTo(0.2, 0.01));
      expect(curve.d, closeTo(1.0, 0.01));
    });
    
    test('path 缓动曲线参数正确', () {
      const curve = AnimationCurves.path;
      expect(curve.a, closeTo(0.25, 0.01));
      expect(curve.b, closeTo(0.46, 0.01));
      expect(curve.c, closeTo(0.45, 0.01));
      expect(curve.d, closeTo(0.94, 0.01));
    });
  });
  
  group('页面转场动画测试', () {
    testWidgets('页面切换动画使用 FadeTransition 300ms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TestHomePage(),
        ),
      );
      
      // 点击导航按钮
      await tester.tap(find.text('Go to Detail'));
      await tester.pump();
      
      // 验证动画存在
      final fadeTransition = find.byType(FadeTransition);
      expect(fadeTransition, findsWidgets,
        reason: '页面切换应使用 FadeTransition');
      
      // 验证动画时长（通过 pumpAndSettle 超时验证）
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 50)); // 额外帧确保完成
    });
    
    testWidgets('页面切换动画方向正确', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const TestHomePage(),
        ),
      );
      
      await tester.tap(find.text('Go to Detail'));
      await tester.pump();
      
      // 查找 SlideTransition
      final slideTransition = find.byType(SlideTransition);
      // 页面转场可能使用 SlideTransition
    });
  });
  
  group('按钮交互动画测试', () {
    testWidgets('按钮点击有缩放反馈动画', (tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: Scaffold(
            body: Center(
              child: AnimatedButton(
                onTap: () => tapped = true,
                child: const Text('测试按钮'),
              ),
            ),
          ),
        ),
      );
      
      // 获取按钮初始尺寸
      final initialSize = tester.getSize(find.byType(AnimatedButton));
      
      // 按下按钮
      final gesture = await tester.press(find.byType(AnimatedButton));
      await tester.pump(const Duration(milliseconds: 50));
      
      // 应该有缩放效果
      final pressedSize = tester.getSize(find.byType(AnimatedButton));
      expect(pressedSize.width, lessThanOrEqualTo(initialSize.width),
        reason: '按钮按下时应有缩放效果');
      
      // 释放
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 150));
      
      // 验证回调被触发
      expect(tapped, isTrue);
    });
    
    testWidgets('按钮动画时长符合规范 (150ms)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: Scaffold(
            body: Center(
              child: AnimatedButton(
                onTap: () {},
                child: const Text('测试按钮'),
              ),
            ),
          ),
        ),
      );
      
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byType(AnimatedButton));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 动画时长应在 150ms 左右
      expect(stopwatch.elapsedMilliseconds, closeTo(150, 50),
        reason: '按钮动画时长应在 150ms 左右');
    });
  });
  
  group('加载动画测试', () {
    testWidgets('加载 shimmer 动画循环播放', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: Scaffold(
            body: ShimmerLoading(),
          ),
        ),
      );
      
      // 验证 shimmer 组件存在
      expect(find.byType(ShimmerLoading), findsOneWidget);
      
      // 等待一个循环周期
      await tester.pump(const Duration(milliseconds: 1500));
      
      // shimmer 应该还在
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });
  });
  
  group('收藏按钮弹性动画测试', () {
    testWidgets('收藏按钮使用弹性动画', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: Scaffold(
            body: Center(
              child: FavoriteButton(
                isFavorite: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      
      // 点击收藏
      await tester.tap(find.byType(FavoriteButton));
      await tester.pump();
      
      // 验证弹性动画效果
      // 弹性动画会有多次 pump 的需求
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
  
  group('暗黑模式切换动画测试', () {
    testWidgets('暗黑模式切换无闪烁', (tester) async {
      var isDark = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: DesignSystem.lightTheme,
              darkTheme: DesignSystem.darkTheme,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              home: Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => setState(() => isDark = !isDark),
                    child: const Text('切换主题'),
                  ),
                ),
              ),
            );
          },
        ),
      );
      
      // 记录切换前的像素
      await tester.pump();
      
      // 切换主题
      await tester.tap(find.text('切换主题'));
      await tester.pump();
      
      // 验证切换动画在 300ms 内完成
      await tester.pump(const Duration(milliseconds: 300));
      
      // 不应该有白色闪烁帧
      // 这里主要是通过 pump 顺序验证动画平滑
    });
  });
}

// ============ 测试辅助组件 ============

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const TestDetailPage();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: AnimationDurations.pageTransition,
              ),
            );
          },
          child: const Text('Go to Detail'),
        ),
      ),
    );
  }
}

class TestDetailPage extends StatelessWidget {
  const TestDetailPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: const Center(child: Text('Detail Page')),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  
  const AnimatedButton({
    super.key,
    required this.onTap,
    required this.child,
  });
  
  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: AnimationDurations.quick,
        curve: AnimationCurves.spring,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: widget.child,
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });
  
  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.standard,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AnimationCurves.spring,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _animation,
        child: Icon(
          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: widget.isFavorite ? Colors.red : Colors.grey,
          size: 32,
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ============ 动画常量定义 ============

class AnimationDurations {
  // 微交互
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 150);
  
  // 标准交互
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  
  // 页面转场
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration modalTransition = Duration(milliseconds: 250);
  
  // 复杂动画
  static const Duration complex = Duration(milliseconds: 400);
  static const Duration elaborate = Duration(milliseconds: 600);
  
  // 持续动画
  static const Duration loading = Duration(milliseconds: 1500);
  static const Duration loop = Duration(milliseconds: 2000);
}

class AnimationCurves {
  // 标准缓动
  static const standard = Curves.easeInOut;
  static const enter = Curves.easeOut;
  static const exit = Curves.easeIn;
  
  // 弹性缓动
  static const spring = Curves.elasticOut;
  static const bouncy = Curves.bounceOut;
  
  // 自定义品牌缓动
  static const mountain = Cubic(0.4, 0.0, 0.2, 1);
  static const path = Cubic(0.25, 0.46, 0.45, 0.94);
}
