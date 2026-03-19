import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/design_system.dart';
import 'onboarding_service.dart';
import 'permission_manager.dart';

/// 新手引导主页面
/// 包含4步引导流程：欢迎页 → 权限说明页 → 核心功能介绍页 → 完成页
class OnboardingScreen extends StatefulWidget {
  /// 引导完成回调
  final VoidCallback onComplete;

  /// 跳过引导回调
  final VoidCallback? onSkip;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.onSkip,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();
  final PermissionManager _permissionManager = PermissionManager();

  int _currentPage = 0;
  final int _totalPages = 4;

  // 权限状态
  final Map<PermissionType, bool> _permissionStates = {
    PermissionType.location: false,
    PermissionType.storage: false,
    PermissionType.notification: false,
  };

  // 动画控制器
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  // 欢迎页元素动画控制器列表
  late List<AnimationController> _welcomeControllers;
  late List<Animation<double>> _welcomeAnimations;
  
  // 权限卡片动画控制器列表
  late List<AnimationController> _permissionControllers;
  late List<Animation<double>> _permissionAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeService();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 初始化欢迎页元素依次入场动画（延迟150ms）
    _welcomeControllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _welcomeAnimations = _welcomeControllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );
    }).toList();

    // 初始化权限卡片动画（错开显示）
    _permissionControllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );
    });

    _permissionAnimations = _permissionControllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );
    }).toList();

    _fadeController.forward();
    _slideController.forward();
    
    // 启动欢迎页元素依次入场动画
    _startWelcomeAnimations();
  }

  void _startWelcomeAnimations() async {
    const delay = Duration(milliseconds: 150);
    for (int i = 0; i < _welcomeControllers.length; i++) {
      await Future.delayed(delay);
      if (mounted) {
        _welcomeControllers[i].forward();
      }
    }
  }

  void _startPermissionAnimations() async {
    const delay = Duration(milliseconds: 150);
    for (int i = 0; i < _permissionControllers.length; i++) {
      await Future.delayed(delay);
      if (mounted) {
        _permissionControllers[i].forward();
      }
    }
  }

  void _resetPermissionAnimations() {
    for (final controller in _permissionControllers) {
      controller.reset();
    }
  }

  Future<void> _initializeService() async {
    await _onboardingService.initialize();
    await _onboardingService.markStarted();

    // 恢复上次进度
    final savedPage = await _onboardingService.getCurrentPage();
    if (savedPage > 0 && savedPage < _totalPages) {
      _jumpToPage(savedPage);
    }

    // 检查权限状态
    await _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final states = await _permissionManager.checkPermissions([
      PermissionType.location,
      PermissionType.storage,
      PermissionType.notification,
    ]);

    setState(() {
      for (final entry in states.entries) {
        _permissionStates[entry.key] = entry.value.isGranted;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    for (final controller in _welcomeControllers) {
      controller.dispose();
    }
    for (final controller in _permissionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _jumpToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      _pageController.jumpToPage(page);
      setState(() => _currentPage = page);
      _onPageChanged(page);
    }
  }

  void _onPageChanged(int page) {
    _fadeController.forward(from: 0);
    _slideController.forward(from: 0);
    
    if (page == 1) {
      // 权限页，启动权限卡片动画
      _resetPermissionAnimations();
      _startPermissionAnimations();
    } else {
      _resetPermissionAnimations();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 调试简化版：直接跳转，跳过所有 SharedPreferences 操作
  /// 用于验证是否是存储问题导致的无法跳转
  Future<void> _completeOnboardingSimple() async {
    print('[Onboarding] 🚀 简化版完成流程（跳过存储）');
    print('[Onboarding] 当前 mounted: $mounted');
    
    if (!mounted) {
      print('[Onboarding] ⚠️ 未 mounted，但仍尝试跳转');
      widget.onComplete();
      return;
    }
    
    print('[Onboarding] 🎯 直接调用 onComplete');
    widget.onComplete();
    print('[Onboarding] ✅ 跳转已触发');
  }

  Future<void> _completeOnboarding() async {
    print('[Onboarding] 🚀 开始完成引导流程');
    print('[Onboarding] 直接调用 onComplete，跳过存储');
    widget.onComplete();
  }

  Future<void> _skipOnboarding() async {
    print('[Onboarding] 🚀 开始跳过引导流程');
    
    final confirmed = await _showSkipConfirmDialog();
    if (confirmed == true) {
      print('[Onboarding] 用户确认跳过，直接调用 onComplete');
      widget.onSkip?.call();
      widget.onComplete();
    }
  }

  Future<bool?> _showSkipConfirmDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确定跳过？'),
        content: const Text('你可以在设置中随时重新查看新手引导'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: DesignSystem.primary,
            ),
            child: const Text('确定跳过'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestAllPermissions() async {
    final results = await _permissionManager.requestAllPermissions();

    setState(() {
      for (final entry in results.entries) {
        _permissionStates[entry.key] = entry.value.isGranted;
      }
    });

    // 显示授权结果提示
    final allGranted = results.values.every((r) => r.isGranted);
    if (allGranted) {
      _showSnackBar('所有权限已授权');
    } else {
      _showSnackBar('部分权限未授权，可在设置中开启');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvoked: (didPop) {
        if (!didPop && _currentPage > 0) {
          _previousPage();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? DesignSystem.darkBackground : DesignSystem.background,
        body: SafeArea(
          child: Column(
            children: [
              // 顶部跳过按钮
              _buildSkipButton(),

              // 页面内容
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                    _onboardingService.setCurrentPage(page);
                    _onPageChanged(page);
                  },
                  children: [
                    _buildWelcomePage(isDark),
                    _buildPermissionPage(isDark),
                    _buildFeaturesPage(isDark),
                    _buildCompletePage(isDark),
                  ],
                ),
              ),

              // 底部进度指示器
              _buildPageIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          onPressed: _skipOnboarding,
          style: TextButton.styleFrom(
            foregroundColor: DesignSystem.getTextSecondary(context),
          ),
          child: const Text(
            '跳过引导',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? DesignSystem.getPrimary(context)
                  : DesignSystem.getTextTertiary(context).withOpacity(0.3),
            ),
          );
        }),
      ),
    );
  }

  // ========== Step 1: 欢迎页（带依次入场动画 + 滚动支持） ==========
  Widget _buildWelcomePage(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo 和品牌名 - 第一个元素
            FadeTransition(
              opacity: _welcomeAnimations[0],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_welcomeControllers[0]),
                child: _buildLogoSection(isDark),
              ),
            ),

            const SizedBox(height: 32),

            // 主视觉插图 - 第二个元素
            FadeTransition(
              opacity: _welcomeAnimations[1],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_welcomeControllers[1]),
                child: _buildWelcomeIllustration(),
              ),
            ),

            const SizedBox(height: 32),

            // 标题 - 第三个元素
            FadeTransition(
              opacity: _welcomeAnimations[2],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_welcomeControllers[2]),
                child: Text(
                  '发现城市中的自然',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : DesignSystem.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 副标题 - 第四个元素
            FadeTransition(
              opacity: _welcomeAnimations[3],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_welcomeControllers[3]),
                child: Text(
                  '探索身边的徒步路线，享受自然，保持安全',
                  style: TextStyle(
                    fontSize: 16,
                    color: DesignSystem.getTextSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 开始按钮 - 第五个元素
            FadeTransition(
              opacity: _welcomeAnimations[4],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_welcomeControllers[4]),
                child: _buildPrimaryButton(
                  '开始探索',
                  _nextPage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Step 2: 权限说明页（带错开显示动画 + 滚动支持） ==========
  Widget _buildPermissionPage(bool isDark) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeController,
          child: child,
        );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '为了更好体验',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : DesignSystem.textPrimary,
                ),
              ),

              const SizedBox(height: 24),

              // 权限说明插图
              SvgPicture.asset(
                'assets/onboarding/permission_location.svg',
                width: 140,
                height: 140,
              ),

              const SizedBox(height: 24),

              // 权限卡片列表（带错开动画）
              FadeTransition(
                opacity: _permissionAnimations[0],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(_permissionControllers[0]),
                  child: _buildPermissionCard(
                    PermissionType.location,
                    'assets/onboarding/permission_location.svg',
                    DesignSystem.primary.withOpacity(0.1),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeTransition(
                opacity: _permissionAnimations[1],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(_permissionControllers[1]),
                  child: _buildPermissionCard(
                    PermissionType.storage,
                    'assets/onboarding/permission_storage.svg',
                    const Color(0xFFFFF8E7),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeTransition(
                opacity: _permissionAnimations[2],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(_permissionControllers[2]),
                  child: _buildPermissionCard(
                    PermissionType.notification,
                    'assets/onboarding/permission_notification.svg',
                    const Color(0xFFEEF7FF),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 按钮组
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSecondaryButton(
                    '稍后设置',
                    _nextPage,
                  ),
                  const SizedBox(width: 16),
                  _buildPrimaryButton(
                    '允许权限',
                    _requestAllPermissions,
                    width: 160,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                '你可以在设置中随时更改权限',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignSystem.getTextTertiary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== Step 3: 核心功能介绍页 ==========
  Widget _buildFeaturesPage(bool isDark) {
    final features = [
      {
        'icon': Icons.map_outlined,
        'color': DesignSystem.primary,
        'title': '发现路线',
        'description': '探索身边的徒步路线，发现城市中的自然之美',
      },
      {
        'icon': Icons.offline_bolt_outlined,
        'color': const Color(0xFFFFB800),
        'title': '离线导航',
        'description': '没信号也能安心走，提前下载，山野无忧',
      },
      {
        'icon': Icons.emergency_outlined,
        'color': const Color(0xFFE57373),
        'title': '安全求助',
        'description': '一键求助，守护安全，让爱你的人不再担心',
      },
    ];

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeController,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 功能卡片
            for (int i = 0; i < features.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _buildFeatureCard(
                features[i]['icon'] as IconData,
                features[i]['color'] as Color,
                features[i]['title'] as String,
                features[i]['description'] as String,
                isDark,
                delay: i * 150,
              ),
            ],

            const SizedBox(height: 48),

            // 下一步按钮
            _buildPrimaryButton(
              '下一步',
              _nextPage,
            ),
          ],
        ),
      ),
    );
  }

  // ========== Step 4: 完成页（+ 滚动支持） ==========
  Widget _buildCompletePage(bool isDark) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeController,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 庆祝插图
              SvgPicture.asset(
                'assets/onboarding/celebration_illustration.svg',
                width: 140,
                height: 140,
              ),

              const SizedBox(height: 24),

              Text(
                '🎉 欢迎加入山径！',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : DesignSystem.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                '你的户外探索之旅即将开始',
                style: TextStyle(
                  fontSize: 16,
                  color: DesignSystem.getTextSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 开始使用按钮
              _buildPrimaryButton(
                '开始探索',
                _completeOnboarding,
              ),

              const SizedBox(height: 12),

              // 查看使用指南链接
              TextButton(
                onPressed: () {
                  // TODO: 跳转到使用指南页面
                  _completeOnboarding();
                },
                child: const Text('查看使用指南'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== 组件构建方法 ==========

  Widget _buildLogoSection(bool isDark) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: DesignSystem.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.terrain,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '山  径',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : DesignSystem.textPrimary,
            letterSpacing: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'SHANJING APP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: DesignSystem.getTextTertiary(context),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeIllustration() {
    return SvgPicture.asset(
      'assets/onboarding/welcome_illustration.svg',
      width: 180,
      height: 180,
    );
  }

  Widget _buildPermissionCard(
    PermissionType type,
    String iconPath,
    Color bgColor,
  ) {
    final desc = _permissionManager.getPermissionDescription(type);
    final isGranted = _permissionStates[type] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGranted
            ? DesignSystem.primary.withOpacity(0.1)
            : (Theme.of(context).brightness == Brightness.dark
                ? DesignSystem.darkSurfaceSecondary
                : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted
              ? DesignSystem.primary
              : (Theme.of(context).brightness == Brightness.dark
                  ? DesignSystem.darkBorder
                  : Colors.transparent),
          width: isGranted ? 1 : 0,
        ),
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isGranted ? Colors.white : bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isGranted
                ? Icon(
                    Icons.check_circle,
                    color: DesignSystem.primary,
                    size: 28,
                  )
                : SvgPicture.asset(
                    iconPath,
                    width: 28,
                    height: 28,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc['title'] ?? '',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc['description'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignSystem.getTextSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          if (isGranted)
            Icon(
              Icons.check_circle,
              color: DesignSystem.primary,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    Color color,
    String title,
    String description,
    bool isDark, {
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? DesignSystem.darkSurfaceSecondary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? DesignSystem.darkBorder : Colors.transparent,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : DesignSystem.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignSystem.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    String text,
    VoidCallback onPressed, {
    double width = 200,
  }) {
    return SizedBox(
      width: width,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignSystem.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 120,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignSystem.getTextSecondary(context),
          side: BorderSide(color: DesignSystem.getBorder(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}