import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/map_screen_simple.dart';
import 'screens/discovery_screen.dart';
import 'screens/profile_screen.dart';
import 'constants/design_system.dart';

// 稳定版本 - 使用简化的地图页面
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 性能优化：设置首选方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const StableApp());
}

class StableApp extends StatelessWidget {
  const StableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '山径',
      theme: DesignSystem.lightTheme,
      darkTheme: DesignSystem.darkTheme,
      themeMode: ThemeMode.system,
      home: const StableMainScreen(),
    );
  }
}

class StableMainScreen extends StatefulWidget {
  const StableMainScreen({super.key});

  @override
  State<StableMainScreen> createState() => _StableMainScreenState();
}

class _StableMainScreenState extends State<StableMainScreen> {
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
