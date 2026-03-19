# 设计系统 - 浅色模式完整规范

> M4 P2 修复 - 浅色模式色值表

---

## 1. 颜色体系

### 1.1 主色调 (Primary Colors)

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `primary` | #6366F1 | #4F46E5 | 主按钮、链接、强调 |
| `primaryContainer` | #4338CA | #E0E7FF | 主色容器背景 |
| `onPrimary` | #FFFFFF | #FFFFFF | 主色上的文字 |
| `onPrimaryContainer` | #E0E7FF | #3730A3 | 主色容器上的文字 |

### 1.2 次要色 (Secondary Colors)

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `secondary` | #8B5CF6 | #7C3AED | 次要操作、标签 |
| `secondaryContainer` | #6D28D9 | #EDE9FE | 次要色容器背景 |
| `onSecondary` | #FFFFFF | #FFFFFF | 次要色上的文字 |
| `onSecondaryContainer` | #EDE9FE | #5B21B6 | 次要色容器上的文字 |

### 1.3 第三色 (Tertiary Colors)

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `tertiary` | #EC4899 | #DB2777 | 特殊强调、高亮 |
| `tertiaryContainer` | #BE185D | #FCE7F3 | 第三色容器背景 |
| `onTertiary` | #FFFFFF | #FFFFFF | 第三色上的文字 |
| `onTertiaryContainer` | #FCE7F3 | #9D174D | 第三色容器上的文字 |

---

## 2. 语义化颜色

### 2.1 背景色 (Background Colors)

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `background` | #0F0F0F | #FFFFFF | 页面主背景 |
| `onBackground` | #FFFFFF | #111827 | 主背景上的文字 |
| `surface` | #1F1F1F | #F3F4F6 | 卡片、面板背景 |
| `surfaceVariant` | #2D2D2D | #E5E7EB | 变体表面背景 |
| `surfaceHighlight` | #2A2A2A | #E5E7EB | 骨架屏高亮 |
| `onSurface` | #FFFFFF | #111827 | 表面上的主文字 |
| `onSurfaceVariant` | #9CA3AF | #6B7280 | 表面上的次文字 |

### 2.2 错误色 (Error Colors)

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `error` | #EF4444 | #DC2626 | 错误状态、删除 |
| `errorContainer` | #B91C1C | #FEE2E2 | 错误容器背景 |
| `onError` | #FFFFFF | #FFFFFF | 错误色上的文字 |
| `onErrorContainer` | #FEE2E2 | #991B1B | 错误容器上的文字 |

### 2.3 成功色 (Success Colors)

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `success` | #22C55E | #16A34A | 成功状态、完成 |
| `successContainer` | #15803D | #DCFCE7 | 成功容器背景 |
| `onSuccess` | #FFFFFF | #FFFFFF | 成功色上的文字 |
| `onSuccessContainer` | #DCFCE7 | #166534 | 成功容器上的文字 |

### 2.4 警告色 (Warning Colors)

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `warning` | #F59E0B | #D97706 | 警告状态、提醒 |
| `warningContainer` | #B45309 | #FEF3C7 | 警告容器背景 |
| `onWarning` | #000000 | #FFFFFF | 警告色上的文字 |
| `onWarningContainer` | #FEF3C7 | #92400E | 警告容器上的文字 |

### 2.5 信息色 (Info Colors)

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `info` | #3B82F6 | #2563EB | 信息提示 |
| `infoContainer` | #1D4ED8 | #DBEAFE | 信息容器背景 |
| `onInfo` | #FFFFFF | #FFFFFF | 信息色上的文字 |
| `onInfoContainer` | #DBEAFE | #1E40AF | 信息容器上的文字 |

---

## 3. 文字颜色

### 3.1 主文字色

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `textPrimary` | #FFFFFF | #111827 | 主要文字 |
| `textSecondary` | #9CA3AF | #6B7280 | 次要文字 |
| `textTertiary` | #6B7280 | #9CA3AF | 辅助文字 |
| `textDisabled` | #4B5563 | #D1D5DB | 禁用文字 |
| `textInverse` | #000000 | #FFFFFF | 反向文字 |

### 3.2 品牌文字色

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `textBrand` | #6366F1 | #4F46E5 | 品牌色文字 |
| `textLink` | #818CF8 | #4338CA | 链接文字 |
| `textLinkVisited` | #A78BFA | #6D28D9 | 已访问链接 |

---

## 4. 边框与分割线

| Token | Dark Mode | Light Mode | 用途 |
|-------|-----------|------------|------|
| `border` | #374151 | #E5E7EB | 默认边框 |
| `borderStrong` | #4B5563 | #D1D5DB | 强边框 |
| `borderWeak` | #1F2937 | #F3F4F6 | 弱边框 |
| `divider` | #374151 | #E5E7EB | 分割线 |
| `outline` | #4B5563 | #9CA3AF | 轮廓线 |

---

## 5. 状态色

| 状态 | Dark Mode | Light Mode | 用途 |
|------|-----------|------------|------|
| `hover` | rgba(255,255,255,0.05) | rgba(0,0,0,0.05) | 悬停背景 |
| `pressed` | rgba(255,255,255,0.1) | rgba(0,0,0,0.1) | 按下背景 |
| `selected` | rgba(99,102,241,0.2) | rgba(79,70,229,0.1) | 选中状态 |
| `focused` | rgba(99,102,241,0.5) | rgba(79,70,229,0.3) | 聚焦状态 |
| `dragged` | rgba(255,255,255,0.1) | rgba(0,0,0,0.05) | 拖拽状态 |

---

## 6. Flutter ThemeData 配置

```dart
class AppTheme {
  // 浅色模式
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // 颜色方案
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4F46E5),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE0E7FF),
        onPrimaryContainer: Color(0xFF3730A3),
        
        secondary: Color(0xFF7C3AED),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFEDE9FE),
        onSecondaryContainer: Color(0xFF5B21B6),
        
        tertiary: Color(0xFFDB2777),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFFCE7F3),
        onTertiaryContainer: Color(0xFF9D174D),
        
        error: Color(0xFFDC2626),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFEE2E2),
        onErrorContainer: Color(0xFF991B1B),
        
        background: Color(0xFFFFFFFF),
        onBackground: Color(0xFF111827),
        surface: Color(0xFFF3F4F6),
        onSurface: Color(0xFF111827),
        surfaceVariant: Color(0xFFE5E7EB),
        onSurfaceVariant: Color(0xFF6B7280),
        
        outline: Color(0xFF9CA3AF),
        outlineVariant: Color(0xFFE5E7EB),
        
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
      ),
      
      // 应用栏主题
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        color: const Color(0xFFF3F4F6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF111827),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4F46E5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),
      
      // Snackbar 主题
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F2937),
        contentTextStyle: const TextStyle(color: Color(0xFFFFFFFF)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // 暗黑模式
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF4338CA),
        onPrimaryContainer: Color(0xFFE0E7FF),
        
        secondary: Color(0xFF8B5CF6),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFF6D28D9),
        onSecondaryContainer: Color(0xFFEDE9FE),
        
        tertiary: Color(0xFFEC4899),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFBE185D),
        onTertiaryContainer: Color(0xFFFCE7F3),
        
        error: Color(0xFFEF4444),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFB91C1C),
        onErrorContainer: Color(0xFFFEE2E2),
        
        background: Color(0xFF0F0F0F),
        onBackground: Color(0xFFFFFFFF),
        surface: Color(0xFF1F1F1F),
        onSurface: Color(0xFFFFFFFF),
        surfaceVariant: Color(0xFF2D2D2D),
        onSurfaceVariant: Color(0xFF9CA3AF),
        
        outline: Color(0xFF4B5563),
        outlineVariant: Color(0xFF374151),
        
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F0F0F),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
      ),
      
      cardTheme: CardTheme(
        color: const Color(0xFF1F1F1F),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFFFFFF),
          side: const BorderSide(color: Color(0xFF374151)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF818CF8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 1,
        space: 1,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F1F1F),
        contentTextStyle: const TextStyle(color: Color(0xFFFFFFFF)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

---

## 7. 颜色使用对照表

### 7.1 组件颜色映射

| 组件 | 元素 | Dark Mode | Light Mode |
|------|------|-----------|------------|
| 页面 | 背景 | background #0F0F0F | backgroundLight #FFFFFF |
| 卡片 | 背景 | surface #1F1F1F | surfaceLight #F3F4F6 |
| 卡片 | 边框 | border #374151 | borderLight #E5E7EB |
| 按钮 (主) | 背景 | primary #6366F1 | primaryLight #4F46E5 |
| 按钮 (次) | 边框 | border #374151 | borderLight #E5E7EB |
| 输入框 | 背景 | surface #1F1F1F | surfaceLight #F3F4F6 |
| 输入框 | 边框 | border #374151 | borderLight #E5E7EB |
| 输入框 (聚焦) | 边框 | primary #6366F1 | primaryLight #4F46E5 |
| 文字 (主) | 颜色 | textPrimary #FFFFFF | textPrimaryLight #111827 |
| 文字 (次) | 颜色 | textSecondary #9CA3AF | textSecondaryLight #6B7280 |
| 错误提示 | 背景 | error #EF4444 | errorLight #DC2626 |
| 成功提示 | 背景 | success #22C55E | successLight #16A34A |
| 加载骨架 | 基础色 | surface #1F1F1F | surfaceLight #F3F4F6 |
| 加载骨架 | 高亮色 | surfaceHighlight #2A2A2A | surfaceHighlightLight #E5E7EB |

---

*文档版本: v1.0*
*最后更新: 2024-03-19*
