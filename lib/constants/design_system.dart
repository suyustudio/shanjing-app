import 'package:flutter/material.dart';

/// 设计系统常量
class DesignSystem {
  DesignSystem._();

  // ==================== 亮色模式颜色 ====================
  
  // 主色调
  static const Color primary = Color(0xFF2D968A);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF1F6B62);
  
  // 背景色
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  static const Color backgroundTertiary = Color(0xFFEEEEEE);
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textInverse = Color(0xFFFFFFFF);
  
  // 边框和分割线
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // 功能色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ==================== 暗黑模式颜色 ====================
  
  // 主色调（暗黑模式下保持相同或微调）
  static const Color primaryDarkMode = Color(0xFF4DB6AC);
  static const Color primaryLightDarkMode = Color(0xFF80CBC4);
  static const Color primaryDarkDarkMode = Color(0xFF2D968A);
  
  // 背景色（暗黑模式）
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundSecondaryDark = Color(0xFF1E1E1E);
  static const Color backgroundTertiaryDark = Color(0xFF2C2C2C);
  static const Color backgroundElevatedDark = Color(0xFF242424);
  
  // 文字颜色（暗黑模式）
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF808080);
  static const Color textInverseDark = Color(0xFF121212);
  
  // 边框和分割线（暗黑模式）
  static const Color borderDark = Color(0xFF404040);
  static const Color dividerDark = Color(0xFF333333);
  
  // 功能色（暗黑模式 - 保持相同或微调亮度）
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warningDark = Color(0xFFFFD54F);
  static const Color errorDark = Color(0xFFE57373);
  static const Color infoDark = Color(0xFF64B5F6);

  // ==================== 动态颜色获取 ====================
  
  /// 根据当前主题获取主色调
  static Color getPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? primaryDarkMode 
        : primary;
  }
  
  /// 根据当前主题获取背景色
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? backgroundDark 
        : background;
  }
  
  /// 根据当前主题获取次级背景色
  static Color getBackgroundSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? backgroundSecondaryDark 
        : backgroundSecondary;
  }
  
  /// 根据当前主题获取三级背景色
  static Color getBackgroundTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? backgroundTertiaryDark 
        : backgroundTertiary;
  }
  
  /// 根据当前主题获取卡片/浮层背景色
  static Color getBackgroundElevated(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? backgroundElevatedDark 
        : background;
  }
  
  /// 根据当前主题获取主要文字颜色
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textPrimaryDark 
        : textPrimary;
  }
  
  /// 根据当前主题获取次级文字颜色
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textSecondaryDark 
        : textSecondary;
  }
  
  /// 根据当前主题获取三级文字颜色
  static Color getTextTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textTertiaryDark 
        : textTertiary;
  }
  
  /// 根据当前主题获取反色文字
  static Color getTextInverse(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? textInverseDark 
        : textInverse;
  }
  
  /// 根据当前主题获取边框颜色
  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? borderDark 
        : border;
  }
  
  /// 根据当前主题获取分割线颜色
  static Color getDivider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? dividerDark 
        : divider;
  }
  
  /// 根据当前主题获取成功色
  static Color getSuccess(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? successDark 
        : success;
  }
  
  /// 根据当前主题获取警告色
  static Color getWarning(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? warningDark 
        : warning;
  }
  
  /// 根据当前主题获取错误色
  static Color getError(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? errorDark 
        : error;
  }
  
  /// 根据当前主题获取信息色
  static Color getInfo(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? infoDark 
        : info;
  }

  // ==================== 字体大小 ====================
  static const double fontHeading = 18;
  static const double fontBody = 14;
  static const double fontSmall = 12;
  static const double fontLarge = 20;
  static const double fontXLarge = 24;

  // ==================== 间距 ====================
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXLarge = 32;

  // ==================== 圆角 ====================
  static const double radius = 8;
  static const double radiusLarge = 12;
  static const double radiusXLarge = 16;
  static const double radiusCircular = 999;

  // ==================== 阴影 ====================
  static List<BoxShadow> getShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark 
            ? Colors.black.withOpacity(0.3) 
            : Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  static List<BoxShadow> getShadowLight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark 
            ? Colors.black.withOpacity(0.2) 
            : Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  // ==================== 主题数据 ====================
  
  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: textInverse,
        primaryContainer: primaryLight,
        onPrimaryContainer: textInverse,
        secondary: primary,
        onSecondary: textInverse,
        secondaryContainer: primaryLight,
        onSecondaryContainer: textInverse,
        surface: background,
        onSurface: textPrimary,
        surfaceContainerHighest: backgroundSecondary,
        onSurfaceVariant: textSecondary,
        outline: border,
        error: error,
        onError: textInverse,
        errorContainer: Color(0xFFFFEBEE),
        onErrorContainer: error,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: textInverse,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: background,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textInverse,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: primary),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundSecondary,
        selectedColor: primary,
        labelStyle: const TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: textInverse),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCircular),
        ),
      ),
    );
  }
  
  /// 暗黑主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDarkMode,
        onPrimary: textInverseDark,
        primaryContainer: primaryDarkDarkMode,
        onPrimaryContainer: textInverseDark,
        secondary: primaryDarkMode,
        onSecondary: textInverseDark,
        secondaryContainer: primaryDarkDarkMode,
        onSecondaryContainer: textInverseDark,
        surface: backgroundDark,
        onSurface: textPrimaryDark,
        surfaceContainerHighest: backgroundSecondaryDark,
        onSurfaceVariant: textSecondaryDark,
        outline: borderDark,
        error: errorDark,
        onError: textInverseDark,
        errorContainer: Color(0xFF3D1F1F),
        onErrorContainer: errorDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundSecondaryDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: backgroundSecondaryDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkMode,
          foregroundColor: textInverseDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkMode,
          side: const BorderSide(color: primaryDarkMode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDarkMode,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundTertiaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: primaryDarkMode),
        ),
        hintStyle: const TextStyle(color: textTertiaryDark),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerDark,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundSecondaryDark,
        selectedItemColor: primaryDarkMode,
        unselectedItemColor: textSecondaryDark,
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: primaryDarkMode,
        unselectedLabelColor: textSecondaryDark,
        indicatorColor: primaryDarkMode,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundTertiaryDark,
        selectedColor: primaryDarkMode,
        labelStyle: const TextStyle(color: textPrimaryDark),
        secondaryLabelStyle: const TextStyle(color: textInverseDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCircular),
        ),
      ),
    );
  }
}
