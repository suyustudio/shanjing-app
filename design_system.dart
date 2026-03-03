import 'package:flutter/material.dart';

/// ============================================
/// 暗黑模式设计系统 - Dark Mode Design System
/// ============================================

/// 暗黑模式颜色常量
class DarkColors {
  // 主色调
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  // 背景色
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFF262626);
  static const Color surfaceElevated = Color(0xFF2D2D2D);
  
  // 文字颜色
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textTertiary = Color(0xFF737373);
  static const Color textDisabled = Color(0xFF525252);
  
  // 边框和分割线
  static const Color border = Color(0xFF404040);
  static const Color divider = Color(0xFF2A2A2A);
  
  // 功能色
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // 特殊状态
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x40000000);
  static const Color scrim = Color(0x99000000);
}

/// 亮色模式颜色常量
class LightColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x1F000000);
  static const Color scrim = Color(0x99000000);
}

/// ============================================
/// 主题数据定义
/// ============================================

/// 暗黑模式主题数据
class DarkThemeData {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // 颜色方案
    colorScheme: const ColorScheme.dark(
      primary: DarkColors.primary,
      onPrimary: Colors.white,
      primaryContainer: DarkColors.primaryDark,
      onPrimaryContainer: Colors.white,
      secondary: DarkColors.primaryLight,
      onSecondary: Colors.white,
      surface: DarkColors.surface,
      onSurface: DarkColors.textPrimary,
      surfaceContainerHighest: DarkColors.surfaceVariant,
      onSurfaceVariant: DarkColors.textSecondary,
      outline: DarkColors.border,
      error: DarkColors.error,
      onError: Colors.white,
      background: DarkColors.background,
      onBackground: DarkColors.textPrimary,
    ),
    
    // 脚手架背景
    scaffoldBackgroundColor: DarkColors.background,
    
    // 应用栏主题
    appBarTheme: const AppBarTheme(
      backgroundColor: DarkColors.surface,
      foregroundColor: DarkColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    
    // 卡片主题
    cardTheme: CardTheme(
      color: DarkColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DarkColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: DarkColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: DarkColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: DarkColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: DarkColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DarkColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    
    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: DarkColors.divider,
      thickness: 1,
      space: 1,
    ),
    
    // 文字主题
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: DarkColors.textPrimary),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: DarkColors.textPrimary),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: DarkColors.textPrimary),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: DarkColors.textPrimary),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: DarkColors.textPrimary),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: DarkColors.textPrimary),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: DarkColors.textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: DarkColors.textPrimary),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DarkColors.textSecondary),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: DarkColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: DarkColors.textPrimary),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: DarkColors.textSecondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DarkColors.textPrimary),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: DarkColors.textSecondary),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: DarkColors.textTertiary),
    ),
  );
}

/// 亮色模式主题数据
class LightThemeData {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme.light(
      primary: LightColors.primary,
      onPrimary: Colors.white,
      primaryContainer: LightColors.primaryLight,
      onPrimaryContainer: LightColors.primaryDark,
      secondary: LightColors.primaryLight,
      onSecondary: Colors.white,
      surface: LightColors.surface,
      onSurface: LightColors.textPrimary,
      surfaceContainerHighest: LightColors.surfaceVariant,
      onSurfaceVariant: LightColors.textSecondary,
      outline: LightColors.border,
      error: LightColors.error,
      onError: Colors.white,
      background: LightColors.background,
      onBackground: LightColors.textPrimary,
    ),
    
    scaffoldBackgroundColor: LightColors.background,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: LightColors.surface,
      foregroundColor: LightColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    
    cardTheme: CardTheme(
      color: LightColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: LightColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: LightColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: LightColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    dividerTheme: const DividerThemeData(
      color: LightColors.divider,
      thickness: 1,
      space: 1,
    ),
  );
}

/// ============================================
/// 主题切换工具
/// ============================================

/// 主题模式枚举
enum ThemeMode {
  light,
  dark,
  system,
}

/// 主题管理器 - 用于管理应用主题状态
class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  /// 当前是否为暗黑模式
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // system 模式需要根据平台判断
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }
  
  /// 获取当前主题数据
  ThemeData get currentTheme => isDarkMode ? DarkThemeData.theme : LightThemeData.theme;
  
  /// 切换到亮色模式
  void setLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }
  
  /// 切换到暗黑模式
  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }
  
  /// 跟随系统
  void setSystemMode() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
  
  /// 切换主题（亮色/暗黑）
  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }
  
  /// 设置指定主题模式
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

/// 主题扩展 - 方便在 BuildContext 上获取主题相关数据
extension ThemeExtension on BuildContext {
  /// 获取主题管理器
  ThemeManager get themeManager => ThemeManager();
  
  /// 当前是否为暗黑模式
  bool get isDarkMode => ThemeManager().isDarkMode;
  
  /// 获取颜色（根据当前主题自动适配）
  AppColors get appColors => isDarkMode ? DarkAppColors() : LightAppColors();
}

/// 应用颜色抽象类
abstract class AppColors {
  Color get background;
  Color get surface;
  Color get surfaceVariant;
  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;
  Color get border;
  Color get divider;
}

/// 暗黑模式应用颜色
class DarkAppColors implements AppColors {
  @override
  Color get background => DarkColors.background;
  @override
  Color get surface => DarkColors.surface;
  @override
  Color get surfaceVariant => DarkColors.surfaceVariant;
  @override
  Color get textPrimary => DarkColors.textPrimary;
  @override
  Color get textSecondary => DarkColors.textSecondary;
  @override
  Color get textTertiary => DarkColors.textTertiary;
  @override
  Color get border => DarkColors.border;
  @override
  Color get divider => DarkColors.divider;
}

/// 亮色模式应用颜色
class LightAppColors implements AppColors {
  @override
  Color get background => LightColors.background;
  @override
  Color get surface => LightColors.surface;
  @override
  Color get surfaceVariant => LightColors.surfaceVariant;
  @override
  Color get textPrimary => LightColors.textPrimary;
  @override
  Color get textSecondary => LightColors.textSecondary;
  @override
  Color get textTertiary => LightColors.textTertiary;
  @override
  Color get border => LightColors.border;
  @override
  Color get divider => LightColors.divider;
}
