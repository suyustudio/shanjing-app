# 反馈系统 UI 设计规范

> M4 P2 修复 - 反馈系统完整 UX 设计

---

## 1. 反馈提交成功页面

### 1.1 页面布局
```
┌─────────────────────────────────────┐
│              StatusBar              │
├─────────────────────────────────────┤
│                                     │
│                                     │
│         ┌─────────────────┐         │
│         │   ✓ (绿色大图标)  │         │
│         └─────────────────┘         │
│                                     │
│         反馈提交成功                   │
│                                     │
│    感谢您的反馈，我们会认真处理您的    │
│    建议，持续改进产品体验              │
│                                     │
│         ┌─────────────────┐         │
│         │    返回首页      │         │
│         └─────────────────┘         │
│                                     │
│         ┌─────────────────┐         │
│         │    继续反馈      │         │
│         └─────────────────┘         │
│                                     │
│                                     │
├─────────────────────────────────────┤
│           Bottom Navigation         │
└─────────────────────────────────────┘
```

### 1.2 设计规格

| 元素 | 属性 | 值 (Dark Mode) | 值 (Light Mode) |
|------|------|----------------|-----------------|
| 背景色 | background | `background` #0F0F0F | `backgroundLight` #FFFFFF |
| 成功图标 | icon | Icons.check_circle | Icons.check_circle |
| 图标颜色 | color | `success` #22C55E | `successLight` #16A34A |
| 图标尺寸 | size | 80px | 80px |
| 标题文字 | text | "反馈提交成功" | "反馈提交成功" |
| 标题颜色 | color | `textPrimary` #FFFFFF | `textPrimaryLight` #111827 |
| 标题字号 | fontSize | 24px / headline5 | 24px / headline5 |
| 描述文字 | text | "感谢您的反馈..." | "感谢您的反馈..." |
| 描述颜色 | color | `textSecondary` #9CA3AF | `textSecondaryLight` #6B7280 |
| 描述字号 | fontSize | 14px / body2 | 14px / body2 |
| 主按钮 | text | "返回首页" | "返回首页" |
| 主按钮背景 | background | `primary` #6366F1 | `primaryLight` #4F46E5 |
| 主按钮文字 | color | white | white |
| 次按钮 | text | "继续反馈" | "继续反馈" |
| 次按钮背景 | background | transparent | transparent |
| 次按钮边框 | border | `border` #374151 | `borderLight` #E5E7EB |
| 次按钮文字 | color | `textPrimary` | `textPrimaryLight` |

### 1.3 动效设计
- **图标出现**: Scale animation (0 → 1) + Fade in
  - Duration: 400ms
  - Curve: `Curves.elasticOut` (弹性效果)
- **文字出现**: Slide up + Fade in
  - Delay: 200ms
  - Duration: 300ms
  - Curve: `Curves.easeOutCubic`
- **按钮出现**: Slide up + Fade in
  - Delay: 400ms
  - Duration: 300ms
  - Curve: `Curves.easeOutCubic`

---

## 2. 加载状态设计

### 2.1 骨架屏 (Skeleton Loading)

#### 表单骨架屏
```
┌─────────────────────────────────────┐
│                                     │
│  ┌─────────────────────────────┐    │
│  │      (Shimmer 块)            │    │ ← 标题区域
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      (Shimmer 块)            │    │ ← 输入框 1
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      (Shimmer 块)            │    │ ← 输入框 2
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │                             │    │
│  │      (大 Shimmer 块)         │    │ ← 多行输入
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
│  ┌─────────────────────────────┐    │
│  │      (Shimmer 按钮)          │    │ ← 提交按钮
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

#### 骨架屏规格
| 元素 | Dark Mode | Light Mode |
|------|-----------|------------|
| 基础色 | `surface` #1F1F1F | `surfaceLight` #F3F4F6 |
| Shimmer 高亮色 | `surfaceHighlight` #2A2A2A | `surfaceHighlightLight` #E5E7EB |
| 动画周期 | 1.5s | 1.5s |
| 圆角 | 8px | 8px |

### 2.2 提交加载状态

#### 全屏加载遮罩
```dart
// 带模糊背景的加载指示器
Container(
  color: Colors.black.withOpacity(0.5), // Dark
  // color: Colors.white.withOpacity(0.7), // Light
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          color: primary, // 品牌主色
          strokeWidth: 3,
        ),
        SizedBox(height: 16),
        Text(
          '提交中...',
          style: TextStyle(
            color: textPrimary, // 根据模式切换
            fontSize: 14,
          ),
        ),
      ],
    ),
  ),
)
```

#### 按钮加载状态
```dart
// 提交按钮加载态
ElevatedButton(
  onPressed: null, // 禁用状态
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      SizedBox(width: 8),
      Text('提交中...'),
    ],
  ),
)
```

### 2.3 进度指示器

#### 线性进度条
```dart
LinearProgressIndicator(
  backgroundColor: surfaceVariant,
  valueColor: AlwaysStoppedAnimation<Color>(primary),
  minHeight: 4,
  borderRadius: BorderRadius.circular(2),
)
```

| 属性 | Dark Mode | Light Mode |
|------|-----------|------------|
| 背景色 | `surfaceVariant` #2D2D2D | `surfaceVariantLight` #E5E7EB |
| 进度色 | `primary` #6366F1 | `primaryLight` #4F46E5 |

---

## 3. 网络异常错误状态

### 3.1 网络错误页面

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│         ┌─────────────────┐         │
│         │   ⚠ (错误图标)   │         │
│         └─────────────────┘         │
│                                     │
│         网络连接失败                  │
│                                     │
│    请检查您的网络设置                 │
│    或稍后重试                        │
│                                     │
│         ┌─────────────────┐         │
│         │     重试        │         │
│         └─────────────────┘         │
│                                     │
│         ┌─────────────────┐         │
│         │   查看帮助文档    │         │
│         └─────────────────┘         │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

### 3.2 设计规格

| 元素 | 属性 | Dark Mode | Light Mode |
|------|------|-----------|------------|
| 背景色 | background | `background` #0F0F0F | `backgroundLight` #FFFFFF |
| 错误图标 | icon | Icons.wifi_off | Icons.wifi_off |
| 图标颜色 | color | `error` #EF4444 | `errorLight` #DC2626 |
| 图标尺寸 | size | 64px | 64px |
| 标题 | text | "网络连接失败" | "网络连接失败" |
| 标题颜色 | color | `textPrimary` | `textPrimaryLight` |
| 描述 | text | "请检查您的网络设置或稍后重试" | "请检查您的网络设置或稍后重试" |
| 描述颜色 | color | `textSecondary` | `textSecondaryLight` |
| 重试按钮 | style | FilledButton | FilledButton |
| 重试按钮颜色 | background | `primary` | `primaryLight` |

### 3.3 Toast/Snackbar 错误提示

#### 顶部错误提示条
```dart
// 短暂网络错误提示
SnackBar(
  behavior: SnackBarBehavior.floating,
  backgroundColor: error, // Dark: #EF4444, Light: #DC2626
  margin: EdgeInsets.all(16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  content: Row(
    children: [
      Icon(Icons.wifi_off, color: Colors.white, size: 20),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          '网络连接异常，请检查网络设置',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      TextButton(
        onPressed: () {},
        child: Text('重试', style: TextStyle(color: Colors.white)),
      ),
    ],
  ),
  duration: Duration(seconds: 5),
)
```

### 3.4 错误状态类型

| 类型 | 图标 | 标题 | 描述 | 操作按钮 |
|------|------|------|------|----------|
| 网络断开 | wifi_off | 网络连接失败 | 请检查网络设置或稍后重试 | 重试 / 设置 |
| 请求超时 | timer_off | 请求超时 | 服务器响应较慢，请稍后重试 | 重试 / 取消 |
| 服务器错误 | error_outline | 服务暂不可用 | 服务器繁忙，请稍后重试 | 重试 / 返回 |
| 提交失败 | upload_failed | 提交失败 | 反馈提交失败，请检查内容后重试 | 重试 / 返回 |

---

## 4. 首页悬浮反馈入口

### 4.1 悬浮按钮设计

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                    ┌───────────┐    │
│                    │    💬     │    │ ← 悬浮反馈按钮
│                    │  反馈     │    │
│                    └───────────┘    │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

### 4.2 设计规格

| 属性 | Dark Mode | Light Mode |
|------|-----------|------------|
| 位置 | 右下角，距离边缘 16px | 右下角，距离边缘 16px |
| 尺寸 | 56x56px | 56x56px |
| 背景色 | `primary` #6366F1 | `primaryLight` #4F46E5 |
| 图标 | Icons.feedback_rounded | Icons.feedback_rounded |
| 图标颜色 | white | white |
| 阴影 | elevation 4 | elevation 4 |
| 圆角 | 16px (方形圆角) | 16px |

### 4.3 展开状态

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│              ┌─────────────┐        │
│              │ 🐛 问题反馈  │        │
│              ├─────────────┤        │
│              │ 💡 功能建议  │        │
│              ├─────────────┤        │
│              │ ⭐ 评价我们  │        │
│              └─────────────┘        │
│                    ┌───────┐        │
│                    │  💬   │        │
│                    └───────┘        │
│                                     │
└─────────────────────────────────────┘
```

#### 展开菜单规格
| 属性 | Dark Mode | Light Mode |
|------|-----------|------------|
| 菜单背景 | `surface` #1F1F1F | `surfaceLight` #FFFFFF |
| 菜单圆角 | 12px | 12px |
| 阴影 | elevation 8 | elevation 8 |
| 选项高度 | 48px | 48px |
| 选项间距 | 0px (连续) | 0px (连续) |
| 图标尺寸 | 20px | 20px |
| 文字颜色 | `textPrimary` | `textPrimaryLight` |
| 悬停背景 | `surfaceVariant` #2D2D2D | `surfaceVariantLight` #F3F4F6 |
| 悬停圆角 | 8px | 8px |

### 4.4 交互动效

#### 按钮展开动画
```dart
// 展开菜单动画
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOutCubic,
  transform: Matrix4.identity()..scale(isOpen ? 1.0 : 0.8),
  child: AnimatedOpacity(
    duration: Duration(milliseconds: 150),
    opacity: isOpen ? 1.0 : 0.0,
    child: _buildMenu(),
  ),
)
```

| 动画 | 时长 | 曲线 | 说明 |
|------|------|------|------|
| 菜单展开 | 200ms | easeOutCubic | 缩放 + 淡入 |
| 菜单收起 | 150ms | easeInCubic | 缩放 + 淡出 |
| 按钮旋转 | 300ms | easeInOutCubic | 图标旋转 45° |
| 选项出现 | 每个延迟 50ms | easeOutBack | 依次弹出 |

---

## 5. 组件代码规范

### 5.1 反馈成功页面组件

```dart
class FeedbackSuccessPage extends StatelessWidget {
  const FeedbackSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
        ? AppColors.background 
        : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 成功图标动画
              _SuccessIcon(),
              const SizedBox(height: 24),
              // 标题
              Text(
                '反馈提交成功',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: isDark 
                    ? AppColors.textPrimary 
                    : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // 描述
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  '感谢您的反馈，我们会认真处理您的建议，持续改进产品体验',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark 
                      ? AppColors.textSecondary 
                      : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // 按钮组
              _ActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5.2 骨架屏组件

```dart
class FeedbackSkeleton extends StatelessWidget {
  const FeedbackSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface,
      highlightColor: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBlock(height: 24, width: 120),
          const SizedBox(height: 16),
          _SkeletonBlock(height: 56, width: double.infinity),
          const SizedBox(height: 16),
          _SkeletonBlock(height: 120, width: double.infinity),
        ],
      ),
    );
  }
}
```

### 5.3 悬浮反馈按钮

```dart
class FloatingFeedbackButton extends StatefulWidget {
  const FloatingFeedbackButton({Key? key}) : super(key: key);

  @override
  State<FloatingFeedbackButton> createState() => _FloatingFeedbackButtonState();
}

class _FloatingFeedbackButtonState extends State<FloatingFeedbackButton>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // 防止内存泄漏
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // 展开菜单
        _buildMenu(),
        // 主按钮
        _buildMainButton(),
      ],
    );
  }
}
```

---

## 6. 响应式适配

| 断点 | 适配策略 |
|------|----------|
| Mobile (< 600px) | 全屏显示，底部按钮固定 |
| Tablet (600-1024px) | 居中卡片，最大宽度 480px |
| Desktop (> 1024px) | 居中卡片，最大宽度 480px，增加边距 |

---

*文档版本: v1.0*
*最后更新: 2024-03-19*
