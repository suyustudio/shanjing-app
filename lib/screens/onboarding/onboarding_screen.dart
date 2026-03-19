import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    _fadeController.forward();
    _slideController.forward();
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
    super.dispose();
  }

  void _jumpToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      _pageController.jumpToPage(page);
      setState(() => _currentPage = page);
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

  Future<void> _completeOnboarding() async {
    await _onboardingService.setCompletedAt();
    await _onboardingService.markCompleted();
    widget.onComplete();
  }

  Future<void> _skipOnboarding() async {
    final confirmed = await _showSkipConfirmDialog();
    if (confirmed == true) {
      await _onboardingService.markSkipped();
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

    return WillPopScope(
      onWillPop: () async {
        if (_currentPage > 0) {
          _previousPage();
          return false;
        }
        return true;
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
                    _fadeController.forward(from: 0);
                    _slideController.forward(from: 0);
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

  // ========== Step 1: 欢迎页 ==========
  Widget _buildWelcomePage(bool isDark) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_slideController),
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
              // Logo 和品牌名
              _buildLogoSection(isDark),

              const SizedBox(height: 32),

              // 主视觉插图区域（使用渐变占位）
              _buildIllustrationPlaceholder(
                isDark,
                Icons.landscape_outlined,
                DesignSystem.primary,
              ),

              const SizedBox(height: 32),

              // 标题和副标题
              Text(
                '发现城市中的自然',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : DesignSystem.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                '探索身边的徒步路线，享受自然，保持安全',
                style: TextStyle(
                  fontSize: 16,
                  color: DesignSystem.getTextSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 开始按钮
              _buildPrimaryButton(
                '开始探索',
                _nextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== Step 2: 权限说明页 ==========
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
              _buildIllustrationPlaceholder(
                isDark,
                Icons.security_outlined,
                const Color(0xFF3B9EFF),
                size: 160,
              ),

              const SizedBox(height: 24),

              // 权限卡片列表
              _buildPermissionCard(
                PermissionType.location,
                Icons.location_on_outlined,
                const Color(0xFFE8F5F3),
                DesignSystem.primary,
              ),

              const SizedBox(height: 12),

              _buildPermissionCard(
                PermissionType.storage,
                Icons.storage_outlined,
                const Color(0xFFFFF8E7),
                const Color(0xFFFFB800),
              ),

              const SizedBox(height: 12),

              _buildPermissionCard(
                PermissionType.notification,
                Icons.notifications_outlined,
                const Color(0xFFEEF7FF),
                const Color(0xFF3B9EFF),
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

  // ========== Step 4: 完成页 ==========
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
              // 庆祝图标
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignSystem.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.celebration_outlined,
                  size: 64,
                  color: DesignSystem.primary,
                ),
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

  Widget _buildIllustrationPlaceholder(
    bool isDark,
    IconData icon,
    Color color, {
    double size = 200,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        icon,
        size: size * 0.4,
        color: color,
      ),
    );
  }

  Widget _buildPermissionCard(
    PermissionType type,
    IconData icon,
    Color bgColor,
    Color iconColor,
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
            child: Icon(
              isGranted ? Icons.check_circle : icon,
              color: isGranted ? DesignSystem.primary : iconColor,
              size: 24,
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
