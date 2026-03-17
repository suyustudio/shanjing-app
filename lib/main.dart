import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'analytics/analytics.dart';
import 'screens/map_screen.dart';
import 'screens/discovery_screen.dart';
import 'screens/profile_screen.dart';
import 'services/offline_map_manager.dart';
import 'services/network_manager.dart';
import 'constants/design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载环境变量 - 添加错误处理
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('警告: 无法加载.env文件: $e');
  }

  // 性能优化：设置首选方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化离线地图管理器 - 临时禁用，原生代码未实现
  // await OfflineMapManager().initialize();

  // 初始化网络管理器 - 临时禁用
  // await NetworkManager().initialize();

  // 初始化埋点 SDK - 临时禁用
  // await AnalyticsService().initialize(...);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Builder 获取正确的 context
    return MaterialApp(
      title: '杭州旅游指南',
      // 亮色主题
      theme: DesignSystem.lightTheme,
      // 暗黑主题
      darkTheme: DesignSystem.darkTheme,
      // 跟随系统主题设置
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          // 在这里设置系统UI样式
          final brightness = MediaQuery.platformBrightnessOf(context);
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: brightness == Brightness.dark 
                  ? Brightness.light 
                  : Brightness.dark,
              statusBarBrightness: brightness == Brightness.dark 
                  ? Brightness.dark 
                  : Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: brightness == Brightness.dark 
                  ? Brightness.light 
                  : Brightness.dark,
            ),
          );
          return const MainScreen();
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const KeepAlivePage(child: MapScreen()),
    const KeepAlivePage(child: DiscoveryScreen()),
    const KeepAlivePage(child: ProfileScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

/// 保持页面状态的包装器
class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
