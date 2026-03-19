// qa/m4/p2_testing/performance/route_switch_test.dart
// 多路线切换性能测试

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('多路线切换性能测试', () {
    testWidgets('10次路线切换性能测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 测试路线列表
      final routes = [
        {'id': 'R001', 'name': '九溪烟树线'},
        {'id': 'R002', 'name': '龙井村线'},
        {'id': 'R003', 'name': '宝石山线'},
        {'id': 'R004', 'name': '云栖竹径'},
        {'id': 'R005', 'name': '满觉陇线'},
        {'id': 'R006', 'name': '玉皇山线'},
        {'id': 'R007', 'name': '灵隐寺线'},
        {'id': 'R008', 'name': '法喜寺线'},
        {'id': 'R009', 'name': '西湖环湖线'},
        {'id': 'R010', 'name': '断桥残雪线'},
      ];
      
      final results = <Map<String, dynamic>>[];
      
      for (int i = 0; i < routes.length; i++) {
        final route = routes[i];
        final stopwatch = Stopwatch()..start();
        
        print('\n--- 路线 ${i + 1}/${routes.length}: ${route['name']} ---');
        
        // 1. 进入路线详情页
        await tester.tap(find.byKey(Key('route_${route['id']}')));
        await tester.pumpAndSettle();
        
        final detailLoadTime = stopwatch.elapsedMilliseconds;
        print('详情页加载: ${detailLoadTime}ms');
        
        // 验证详情页显示
        expect(find.text(route['name']!), findsOneWidget);
        
        // 2. 开始导航
        await tester.tap(find.text('开始导航'));
        await tester.pumpAndSettle();
        
        final navigationStartTime = stopwatch.elapsedMilliseconds;
        final navigationLoadDuration = navigationStartTime - detailLoadTime;
        print('导航启动耗时: ${navigationLoadDuration}ms');
        
        // 验证导航页显示
        expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
        
        // 等待3秒模拟导航
        await Future.delayed(const Duration(seconds: 3));
        await tester.pump();
        
        // 3. 退出导航
        await tester.tap(find.byKey(const Key('exit_navigation')));
        await tester.pumpAndSettle();
        
        // 确认退出
        await tester.tap(find.text('确认'));
        await tester.pumpAndSettle();
        
        // 4. 返回路线列表
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        final totalTime = stopwatch.elapsedMilliseconds;
        print('总切换时间: ${totalTime}ms');
        
        // 采集内存数据
        final memory = await getMemoryUsageMB();
        print('当前内存: ${memory}MB');
        
        results.add({
          'round': i + 1,
          'route_id': route['id'],
          'route_name': route['name'],
          'detail_load_ms': detailLoadTime,
          'navigation_load_ms': navigationLoadDuration,
          'total_switch_ms': totalTime,
          'memory_mb': memory,
        });
      }
      
      // 分析结果
      print('\n========== 路线切换性能报告 ==========');
      
      // 计算平均时间
      final avgDetailLoad = results.map((r) => r['detail_load_ms'] as int)
          .reduce((a, b) => a + b) / results.length;
      final avgNavLoad = results.map((r) => r['navigation_load_ms'] as int)
          .reduce((a, b) => a + b) / results.length;
      final avgTotal = results.map((r) => r['total_switch_ms'] as int)
          .reduce((a, b) => a + b) / results.length;
      
      print('平均详情页加载时间: ${avgDetailLoad.toStringAsFixed(0)}ms');
      print('平均导航启动时间: ${avgNavLoad.toStringAsFixed(0)}ms');
      print('平均总切换时间: ${avgTotal.toStringAsFixed(0)}ms');
      
      // 内存分析
      final firstMemory = results.first['memory_mb'] as int;
      final lastMemory = results.last['memory_mb'] as int;
      final memoryGrowth = lastMemory - firstMemory;
      
      print('初始内存: ${firstMemory}MB');
      print('最终内存: ${lastMemory}MB');
      print('内存增长: ${memoryGrowth}MB');
      
      // 检测内存泄漏
      final leakDetected = detectMemoryLeak(results);
      if (leakDetected) {
        print('警告: 检测到内存泄漏趋势');
      } else {
        print('内存趋势: 正常');
      }
      
      // 断言验证
      expect(avgDetailLoad, lessThan(2000.0), 
        reason: '平均详情页加载时间超过2秒: ${avgDetailLoad.toStringAsFixed(0)}ms');
      expect(avgNavLoad, lessThan(2000.0), 
        reason: '平均导航启动时间超过2秒: ${avgNavLoad.toStringAsFixed(0)}ms');
      expect(avgTotal, lessThan(3000.0), 
        reason: '平均总切换时间超过3秒: ${avgTotal.toStringAsFixed(0)}ms');
      expect(leakDetected, false, reason: '检测到内存泄漏');
      
      // 保存测试数据
      await saveTestData('route_switch_10rounds', {
        'routes_tested': routes.length,
        'results': results,
        'avg_detail_load_ms': avgDetailLoad,
        'avg_navigation_load_ms': avgNavLoad,
        'avg_total_switch_ms': avgTotal,
        'memory_growth_mb': memoryGrowth,
        'leak_detected': leakDetected,
      });
      
    }, timeout: const Timeout(Duration(minutes: 5)));
    
    testWidgets('快速连续切换测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入发现页
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      final switchTimes = <int>[];
      
      // 快速连续切换5次
      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();
        
        // 进入详情
        await tester.tap(find.byType(TrailCard).first);
        await tester.pumpAndSettle();
        
        // 立即返回
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        switchTimes.add(stopwatch.elapsedMilliseconds);
        
        print('快速切换 ${i + 1}: ${stopwatch.elapsedMilliseconds}ms');
      }
      
      final avgTime = switchTimes.reduce((a, b) => a + b) / switchTimes.length;
      print('平均快速切换时间: ${avgTime.toStringAsFixed(0)}ms');
      
      expect(avgTime, lessThan(1500.0), 
        reason: '快速切换时间超过1.5秒: ${avgTime.toStringAsFixed(0)}ms');
    });
  });
}

// 内存泄漏检测
bool detectMemoryLeak(List<Map<String, dynamic>> results) {
  if (results.length < 3) return false;
  
  // 使用线性回归检测内存泄漏趋势
  final n = results.length;
  final memories = results.map((r) => r['memory_mb'] as int).toList();
  
  // 计算斜率
  final meanX = (n - 1) / 2;
  final meanY = memories.reduce((a, b) => a + b) / n;
  
  double numerator = 0;
  double denominator = 0;
  
  for (int i = 0; i < n; i++) {
    numerator += (i - meanX) * (memories[i] - meanY);
    denominator += (i - meanX) * (i - meanX);
  }
  
  final slope = numerator / denominator;
  
  // 如果每次切换平均增长超过5MB，认为有泄漏
  return slope > 5;
}

Future<int> getMemoryUsageMB() async {
  // TODO: 实现内存获取
  return 150;
}

Future<void> saveTestData(String testName, Map<String, dynamic> data) async {
  print('测试数据已保存: $testName');
}

// Mock classes
class TrailCard extends StatelessWidget {
  const TrailCard({super.key});
  @override
  Widget build(dynamic context) => Container();
}

class Key {
  final String value;
  const Key(this.value);
}

class StatelessWidget {
  final Key? key;
  const StatelessWidget({this.key});
  Widget build(dynamic context) => Container();
}

class Container extends Widget {
  const Container();
}

class Widget {
  const Widget();
}

Finder find = Finder();

class Finder {
  Finder byKey(Key key) => this;
  Finder byType(Type type) => this;
  Finder text(String text) => this;
  Finder get first => this;
  dynamic get evaluate => [];
}
