import 'package:integration_test/integration_test.dart';

// 导入所有 E2E 测试套件
import 'core_flow_test.dart' as core_flow;
import 'favorite_test.dart' as favorite;
import 'offline_map_test.dart' as offline_map;
import 'search_test.dart' as search;
import 'boundary_cases_test.dart' as boundary_cases;

/// 山径APP 完整 E2E 测试套件
/// 
/// 运行命令:
/// ```bash
/// # 运行所有 E2E 测试
/// flutter test integration_test/e2e_all_test.dart
/// 
/// # 运行特定测试组
/// flutter test integration_test/e2e_all_test.dart --plain-name "核心流程"
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  print('========================================');
  print('山径APP E2E 测试套件启动');
  print('========================================');

  // 运行所有测试套件
  group('山径APP 完整 E2E 测试', () {
    print('\n📱 开始核心流程测试...');
    core_flow.main();
    
    print('\n❤️ 开始收藏功能测试...');
    favorite.main();
    
    print('\n🗺️ 开始离线地图测试...');
    offline_map.main();
    
    print('\n🔍 开始搜索功能测试...');
    search.main();
    
    print('\n⚠️ 开始边界场景测试...');
    boundary_cases.main();
  });

  print('\n========================================');
  print('所有 E2E 测试执行完成');
  print('========================================');
}
