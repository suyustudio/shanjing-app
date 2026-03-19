import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:provider/provider.dart';
import 'providers/emergency_contact_provider.dart';
import 'providers/lifeline_provider.dart';
import 'analytics/analytics_service.dart';
import 'screens/map_screen_simple.dart';
import 'screens/discovery_screen.dart';
import 'screens/profile_screen.dart';
import 'constants/design_system.dart';
import 'utils/performance_optimizer.dart';

// 稳定版本 - 使用简化的地图页面（无定位、无离线功能）
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 性能优化：初始化
  PerformanceOptimizer.initialize();

  // 加载环境变量
  await dotenv.load(fileName: ".env");
  PerformanceOptimizer.markPhase('env_loaded');

  // 高德地图隐私合规设置
  AMapFlutterLocation.updatePrivacyShow(true, true);
  AMapFlutterLocation.updatePrivacyAgree(true);
  
  // 设置高德地图 API Key（Android）
  const androidApiKey = 'e17f8ae117d84e2d2d394a2124866603';
  AMapFlutterLocation.setApiKey(androidApiKey, "");
  PerformanceOptimizer.markPhase('map_initialized');

  // 初始化埋点服务
  await AnalyticsService().initialize(
    androidKey: '',
    iosKey: '',
    debugMode: true,
  );
  PerformanceOptimizer.markPhase('analytics_initialized');

  // 性能优化：设置首选方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 打印启动性能报告
  PerformanceOptimizer.printStartupReport();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmergencyContactProvider()),
        ChangeNotifierProvider(create: (_) => LifelineProvider()),
      ],
      child: MaterialApp(
        title: '山径',
        theme: DesignSystem.lightTheme,
        darkTheme: DesignSystem.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainScreen(),
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

  final List<Widget> _pages = const [
    MapScreenSimple(),
    DiscoveryScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = const ['地图', '发现', '我的'];
  final List<IconData> _icons = const [
    Icons.map_outlined,
    Icons.explore_outlined,
    Icons.person_outline,
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
        items: List.generate(3, (index) => BottomNavigationBarItem(
          icon: Icon(_icons[index]),
          label: _titles[index],
        )),
      ),
    );
  }
}
