# 山径APP - iOS 适配设计规范 v1.0

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **文档状态**: M4 阶段 - **P0** [已升级]  
> **适用范围**: 山径APP iOS 平台适配  
> **基于**: 设计系统 v1.0, iOS Human Interface Guidelines
> **优先级调整说明**: iOS 为核心平台，应提前完成，故从 P2 升级至 P0

---

## 目录

1. [设计概述](#1-设计概述)
2. [安全区适配](#2-安全区适配)
3. [状态栏适配](#3-状态栏适配)
4. [iOS 特有交互](#4-ios-特有交互)
5. [系统组件适配](#5-系统组件适配)
6. [手势与导航](#6-手势与导航)
7. [视觉适配](#7-视觉适配)
8. [技术实现](#8-技术实现)
9. [测试清单](#9-测试清单)

---

## 1. 设计概述

### 1.1 设计目标

确保山径APP在 iOS 平台上有原生般的体验：

| 目标 | 说明 | 实现方式 |
|------|------|----------|
| **原生体验** | 符合 iOS 用户习惯 | 遵循 HIG 规范 |
| **安全适配** | 适配各种屏幕尺寸 | 安全区、约束布局 |
| **系统融合** | 与 iOS 系统功能集成 | 深色模式、小组件等 |
| **性能优化** | 充分利用 iOS 特性 | 原生渲染、Metal |

### 1.2 适配范围

| 设备类型 | 屏幕尺寸 | 优先级 | 说明 |
|----------|----------|--------|------|
| iPhone 15 Pro Max | 6.7" | P0 | 最新旗舰 |
| iPhone 15 Pro | 6.1" | P0 | 主流机型 |
| iPhone 15 | 6.1" | P0 | 主流机型 |
| iPhone 14 Pro Max | 6.7" | P1 | 灵动岛 |
| iPhone 14 Pro | 6.1" | P1 | 灵动岛 |
| iPhone SE (3rd) | 4.7" | P1 | 小屏幕 |
| iPad Pro | 12.9" | P2 | 平板适配 |
| iPad Air | 10.9" | P2 | 平板适配 |

### 1.3 设计原则

**"融入 iOS，保持山径"** - 在原生体验中保留品牌特色：

- **遵循规范** - 遵循 iOS Human Interface Guidelines
- **尊重习惯** - 保持 iOS 用户熟悉的交互模式
- **系统特性** - 充分利用 iOS 系统功能
- **品牌延续** - 保持山径视觉识别

---

## 2. 安全区适配

### 2.1 安全区概念

```
iPhone 屏幕结构 (以 iPhone 15 Pro 为例):

┌─────────────────────────────────────┐
│  状态栏安全区 (Status Bar)          │  ← 44-59pt
│  Dynamic Island / 刘海              │
├─────────────────────────────────────┤
│                                     │
│                                     │
│        主要内容安全区               │  ← 全宽可用
│                                     │
│                                     │
├─────────────────────────────────────┤
│  Home Indicator 安全区              │  ← 34pt
│  (底部手势条区域)                    │
└─────────────────────────────────────┘
```

### 2.2 安全区数值

| 设备 | 顶部安全区 | 底部安全区 | 特殊说明 |
|------|------------|------------|----------|
| iPhone 15 Pro Max | 59pt | 34pt | 灵动岛 |
| iPhone 15 Pro | 59pt | 34pt | 灵动岛 |
| iPhone 15 / 15 Plus | 47pt | 34pt | 刘海 |
| iPhone 14 Pro Max | 59pt | 34pt | 灵动岛 |
| iPhone 14 / 14 Plus | 47pt | 34pt | 刘海 |
| iPhone SE (3rd) | 20pt | 0pt | 无刘海 |
| iPad Pro/Air | 24pt | 20pt | 无刘海 |

### 2.3 Flutter 安全区实现

```dart
// 使用 SafeArea 组件
Scaffold(
  body: SafeArea(
    // 保留底部安全区
    bottom: true,
    // 保留顶部安全区
    top: true,
    // 保留左右安全区
    left: true,
    right: true,
    child: YourContent(),
  ),
)

// 或手动处理安全区
class SafeAreaLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    
    return Padding(
      padding: EdgeInsets.only(
        top: padding.top,      // 顶部安全区
        bottom: padding.bottom, // 底部安全区
      ),
      child: YourContent(),
    );
  }
}
```

### 2.4 导航栏安全区

```dart
// 自定义导航栏安全区
class CustomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + 56,  // 56pt 导航栏高度
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(icon: Icon(Icons.arrow_back), onPressed: () {}),
          // 标题
          Expanded(child: Text('页面标题')),
          // 操作按钮
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }
}
```

---

## 3. 状态栏适配

### 3.1 状态栏样式

| 场景 | 样式 | 实现 |
|------|------|------|
| **浅色背景** | dark (黑色文字) | `SystemUiOverlayStyle.dark` |
| **深色背景** | light (白色文字) | `SystemUiOverlayStyle.light` |
| **图片背景** | 根据图片调整 | 动态计算 |
| **滚动变化** | 随滚动切换 | 监听滚动位置 |

### 3.2 Flutter 状态栏配置

```dart
// 设置状态栏样式
void setStatusBarStyle(bool isDark) {
  SystemChrome.setSystemUIOverlayStyle(
    isDark 
      ? SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        )
      : SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
  );
}

// 随页面变化的状态栏
class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,  // 内容延伸到状态栏
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,  // 白色文字
      ),
      body: YourContent(),
    );
  }
}
```

### 3.3 灵动岛 (Dynamic Island) 适配

#### 优化后的检测代码

```dart
// lib/utils/device_utils.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// 设备特性检测工具类
class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static String? _cachedModel;
  
  /// 带灵动岛的设备列表
  static const Set<String> _dynamicIslandDevices = {
    'iPhone15,2',   // iPhone 14 Pro
    'iPhone15,3',   // iPhone 14 Pro Max
    'iPhone15,4',   // iPhone 15
    'iPhone15,5',   // iPhone 15 Plus
    'iPhone16,1',   // iPhone 15 Pro
    'iPhone16,2',   // iPhone 15 Pro Max
    'iPhone17,1',   // iPhone 16 Pro
    'iPhone17,2',   // iPhone 16 Pro Max
  };
  
  /// 刘海屏设备列表 (非灵动岛)
  static const Set<String> _notchDevices = {
    'iPhone10,3', 'iPhone10,6',   // iPhone X
    'iPhone11,2',                 // iPhone XS
    'iPhone11,4', 'iPhone11,6',   // iPhone XS Max
    'iPhone11,8',                 // iPhone XR
    'iPhone12,1',                 // iPhone 11
    'iPhone12,3',                 // iPhone 11 Pro
    'iPhone12,5',                 // iPhone 11 Pro Max
    'iPhone13,1',                 // iPhone 12 mini
    'iPhone13,2',                 // iPhone 12
    'iPhone13,3',                 // iPhone 12 Pro
    'iPhone13,4',                 // iPhone 12 Pro Max
    'iPhone14,4',                 // iPhone 13 mini
    'iPhone14,2',                 // iPhone 13
    'iPhone14,3',                 // iPhone 13 Pro
    'iPhone14,5',                 // iPhone 13 Pro Max
    'iPhone14,6',                 // iPhone SE 3rd
    'iPhone14,7',                 // iPhone 14
    'iPhone14,8',                 // iPhone 14 Plus
  };
  
  /// 获取设备型号 (带缓存)
  static Future<String?> getDeviceModel() async {
    if (_cachedModel != null) return _cachedModel;
    
    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      _cachedModel = info.utsname.machine;
    }
    return _cachedModel;
  }
  
  /// 是否有灵动岛
  static Future<bool> hasDynamicIsland() async {
    final model = await getDeviceModel();
    return model != null && _dynamicIslandDevices.contains(model);
  }
  
  /// 是否有刘海 (包含灵动岛)
  static Future<bool> hasNotch() async {
    final model = await getDeviceModel();
    if (model == null) return false;
    return _dynamicIslandDevices.contains(model) || 
           _notchDevices.contains(model);
  }
  
  /// 快速检测 (使用 MediaQuery，无需异步)
  static bool hasDynamicIslandQuick(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    
    // 灵动岛设备特征: 高度 >= 852pt 且顶部 padding >= 59pt
    return Platform.isIOS && 
           size.height >= 852 && 
           padding.top >= 59;
  }
  
  /// 获取顶部安全区高度
  static double topSafeHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
  
  /// 获取底部安全区高度
  static double bottomSafeHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
}

/// 灵动岛避让 Widget
class DynamicIslandPadding extends StatelessWidget {
  final Widget child;
  final double extraPadding;
  
  const DynamicIslandPadding({
    Key? key,
    required this.child,
    this.extraPadding = 10,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final hasIsland = DeviceUtils.hasDynamicIslandQuick(context);
    final topPadding = DeviceUtils.topSafeHeight(context);
    
    return Padding(
      padding: EdgeInsets.only(
        top: hasIsland ? topPadding + extraPadding : topPadding,
      ),
      child: child,
    );
  }
}

/// 导航栏高度计算
class NavigationBarHeight {
  static double getHeight(BuildContext context) {
    final hasIsland = DeviceUtils.hasDynamicIslandQuick(context);
    final topPadding = DeviceUtils.topSafeHeight(context);
    
    // 基础导航栏高度 56pt + 状态栏高度
    return 56 + topPadding + (hasIsland ? 10 : 0);
  }
}
```

#### 简化使用方案

```dart
// 1. 使用 SafeArea (推荐)
SafeArea(
  top: true,
  bottom: true,
  child: YourContent(),
)

// 2. 自定义顶部区域
AppBar(
  toolbarHeight: NavigationBarHeight.getHeight(context),
  // ...
)

// 3. 检测灵动岛并调整
if (DeviceUtils.hasDynamicIslandQuick(context)) {
  // 灵动岛特有处理
}
```
```

---

## 4. iOS 特有交互

### 4.1 滑动返回

```dart
// 启用 iOS 风格滑动返回
MaterialApp(
  theme: ThemeData(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  ),
)

// 或自定义滑动返回
class CustomPageRoute<T> extends CupertinoPageRoute<T> {
  CustomPageRoute({required WidgetBuilder builder})
    : super(builder: builder);
  
  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
}
```

### 4.2 底部操作表 (Action Sheet)

```dart
// iOS 风格底部操作表
void showiOSActionSheet(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Text('分享路线'),
      message: Text('选择分享方式'),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          child: Text('分享到朋友圈'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: Text('发送给朋友'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('取消'),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
}
```

### 4.3 警告框 (Alert)

```dart
// iOS 风格警告框
void showiOSAlert(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text('退出导航'),
      content: Text('确定要退出当前导航吗？'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          child: Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: Text('确定'),
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            // 执行退出
          },
        ),
      ],
    ),
  );
}
```

### 4.4 选择器 (Picker)

```dart
// iOS 风格选择器
void showiOSPicker(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => Container(
      height: 250,
      color: CupertinoColors.systemBackground,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: CupertinoColors.separator),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: Text('取消'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: Text('确定'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              onSelectedItemChanged: (int index) {
                // 处理选择
              },
              children: [
                Text('休闲'),
                Text('轻度'),
                Text('进阶'),
                Text('挑战'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

### 4.5 分段控制器 (Segmented Control)

```dart
// iOS 风格分段控制器
CupertinoSegmentedControl<int>(
  children: {
    0: Text('推荐'),
    1: Text('附近'),
    2: Text('热门'),
  },
  onValueChanged: (int index) {
    // 处理切换
  },
  groupValue: 0,
  selectedColor: Color(0xFF2D968A),
  unselectedColor: Colors.white,
  borderColor: Color(0xFF2D968A),
  pressedColor: Color(0xFF2D968A).withOpacity(0.2),
)
```

### 4.6 开关 (Switch)

```dart
// iOS 风格开关
CupertinoSwitch(
  value: isOn,
  onChanged: (value) {
    setState(() {
      isOn = value;
    });
  },
  activeColor: Color(0xFF2D968A),
)
```

### 4.7 滑动操作 (Swipe Actions)

```dart
// iOS 风格列表滑动操作
CupertinoContextMenu(
  actions: [
    CupertinoContextMenuAction(
      child: Text('收藏'),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    CupertinoContextMenuAction(
      child: Text('分享'),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    CupertinoContextMenuAction(
      child: Text('删除'),
      isDestructiveAction: true,
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ],
  child: ListTile(
    title: Text('九溪烟树'),
    subtitle: Text('5.2公里 · 休闲'),
  ),
)
```

---

## 5. 系统组件适配

### 5.1 搜索栏

```dart
// iOS 风格搜索栏
CupertinoSearchTextField(
  placeholder: '搜索路线',
  prefixIcon: Icon(CupertinoIcons.search),
  suffixIcon: Icon(CupertinoIcons.xmark_circle_fill),
  onChanged: (value) {
    // 处理搜索
  },
  onSubmitted: (value) {
    // 提交搜索
  },
)
```

### 5.2 刷新控件

```dart
// iOS 风格下拉刷新
CustomScrollView(
  slivers: [
    CupertinoSliverRefreshControl(
      onRefresh: () async {
        // 刷新数据
        await Future.delayed(Duration(seconds: 1));
      },
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(...),
        childCount: items.length,
      ),
    ),
  ],
)
```

### 5.3 进度指示器

```dart
// iOS 风格进度条
CupertinoProgressBar(
  value: 0.5,
  trackColor: CupertinoColors.systemGrey5,
  activeColor: Color(0xFF2D968A),
)

// iOS 风格活动指示器
CupertinoActivityIndicator(
  radius: 16,
  animating: true,
)
```

---

## 6. 手势与导航

### 6.1 手势返回

```dart
// 确保手势返回可用
class iOSBackGesture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 处理返回逻辑
        return true;  // 允许返回
      },
      child: Scaffold(
        // ...
      ),
    );
  }
}
```

### 6.2 底部导航手势

```dart
// iOS 风格底部导航
CupertinoTabScaffold(
  tabBar: CupertinoTabBar(
    items: [
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.home),
        label: '首页',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.compass),
        label: '发现',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.map),
        label: '路线',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person),
        label: '我的',
      ),
    ],
    activeColor: Color(0xFF2D968A),
    inactiveColor: CupertinoColors.systemGrey,
    backgroundColor: CupertinoColors.systemBackground,
    border: Border(
      top: BorderSide(
        color: CupertinoColors.separator,
        width: 0.5,
      ),
    ),
  ),
  tabBuilder: (context, index) {
    return CupertinoTabView(
      builder: (context) {
        return pages[index];
      },
    );
  },
)
```

---

## 7. 视觉适配

### 7.1 字体适配

```dart
// iOS 系统字体
TextStyle iOSTextStyle({
  required double fontSize,
  FontWeight fontWeight = FontWeight.normal,
  Color? color,
}) {
  return TextStyle(
    fontFamily: '.SF Pro Text',  // iOS 系统字体
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: -0.2,  // iOS 默认字间距
  );
}

// 大标题字体
TextStyle iOSLargeTitle = TextStyle(
  fontFamily: '.SF Pro Display',
  fontSize: 34,
  fontWeight: FontWeight.bold,
  letterSpacing: 0.37,
);
```

### 7.2 圆角适配

| 组件 | 圆角值 | 说明 |
|------|--------|------|
| **卡片** | 10pt | iOS 标准卡片圆角 |
| **按钮** | 10pt | 标准按钮圆角 |
| **输入框** | 10pt | 标准输入框圆角 |
| **弹窗** | 14pt | 警告框圆角 |
| **底部面板** | 10pt (顶部) | 底部弹层 |

### 7.3 阴影适配

```dart
// iOS 风格阴影
BoxShadow iOSShadow = BoxShadow(
  color: Colors.black.withOpacity(0.08),
  offset: Offset(0, 4),
  blurRadius: 20,
  spreadRadius: 0,
);

// 应用阴影
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [iOSShadow],
  ),
  child: YourContent(),
);
```

---

## 8. 技术实现

### 8.1 平台判断

```dart
// 判断是否为 iOS
bool isIOS = Platform.isIOS;

// 判断是否为 iPad
bool isIPad = Platform.isIOS && 
    MediaQuery.of(context).size.shortestSide >= 600;

// 平台特定代码
Widget platformWidget = Platform.isIOS
    ? CupertinoButton(child: Text('iOS'), onPressed: () {})
    : ElevatedButton(child: Text('Android'), onPressed: () {});
```

### 8.2 Info.plist 配置

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 应用名称 -->
    <key>CFBundleDisplayName</key>
    <string>山径</string>
    
    <!-- 状态栏样式 -->
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
    
    <!-- 支持方向 -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    
    <!-- 相机权限 -->
    <key>NSCameraUsageDescription</key>
    <string>山径需要访问相机来拍摄路线照片</string>
    
    <!-- 定位权限 -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>山径需要获取您的位置来提供导航服务</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>山径需要在后台获取位置来持续导航</string>
    
    <!-- 相册权限 -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>山径需要访问相册来保存和分享照片</string>
</dict>
</plist>
```

### 8.3 深色模式适配

```dart
// iOS 系统深色模式监听
class DarkModeObserver extends StatefulWidget {
  @override
  _DarkModeObserverState createState() => _DarkModeObserverState();
}

class _DarkModeObserverState extends State<DarkModeObserver> 
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangePlatformBrightness() {
    // 系统深色模式变化
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    
    // 更新主题
    context.read<ThemeProvider>().setSystemDarkMode(isDarkMode);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

---

## 9. 测试清单

### 9.1 安全区测试

- [ ] iPhone 15 Pro Max 安全区适配
- [ ] iPhone 15 Pro 灵动岛适配
- [ ] iPhone SE 小屏幕适配
- [ ] iPad 横屏/竖屏适配
- [ ] 旋转屏幕后安全区更新

### 9.2 交互测试

- [ ] 滑动返回手势正常
- [ ] 底部导航切换流畅
- [ ] 底部操作表正常弹出
- [ ] 警告框样式正确
- [ ] 选择器正常显示

### 9.3 视觉测试

- [ ] 系统字体显示正确
- [ ] 圆角符合 iOS 规范
- [ ] 阴影效果自然
- [ ] 图标清晰度正常
- [ ] 状态栏文字可读

### 9.4 功能测试

- [ ] 下拉刷新正常
- [ ] 搜索栏功能正常
- [ ] 开关切换正常
- [ ] 分段控制器正常
- [ ] 进度指示器正常

### 9.5 系统功能测试

- [ ] 深色模式自动切换
- [ ] 系统字体大小适配
- [ ] 辅助功能 (VoiceOver)
- [ ] 动态类型支持
- [ ] 减少动画选项

---

## 附录

### A. 参考资源

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [iOS Design Guidelines](https://ivomynttinen.com/blog/ios-design-guidelines)
- [Flutter Cupertino Widgets](https://flutter.dev/docs/development/ui/widgets/cupertino)

### B. 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | M4 阶段初版，iOS 适配规范 |

### C. 设计团队

- iOS 适配设计: [待填写]
- 开发对接: [待填写]
- 测试验收: [待填写]

---

> **"融入 iOS，不失山径"** - 山径APP iOS 适配设计哲学
