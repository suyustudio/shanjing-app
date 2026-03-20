// recording_onboarding_screen.dart
// 山径APP - 录制功能首次使用引导

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/design_system.dart';

/// 录制功能引导页
class RecordingOnboardingScreen extends StatefulWidget {
  const RecordingOnboardingScreen({super.key});

  @override
  State<RecordingOnboardingScreen> createState() => _RecordingOnboardingScreenState();
}

class _RecordingOnboardingScreenState extends State<RecordingOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  static const String _onboardingKey = 'recording_onboarding_shown';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 标记引导已完成
  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  /// 检查是否已显示引导
  static Future<bool> hasShownOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// 跳转到下一页
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  /// 完成引导
  void _finishOnboarding() {
    HapticFeedback.mediumImpact();
    _markOnboardingComplete();
    Navigator.of(context).pop(true);
  }

  /// 跳过引导
  void _skipOnboarding() {
    _markOnboardingComplete();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    '跳过',
                    style: DesignSystem.getBodyMedium(context)?.copyWith(
                      color: DesignSystem.getTextSecondary(context),
                    ),
                  ),
                ),
              ),
            ),

            // 页面内容
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  _OnboardingPage1(),
                  _OnboardingPage2(),
                  _OnboardingPage3(),
                ],
              ),
            ),

            // 底部指示器和按钮
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 页面指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalPages, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? DesignSystem.getPrimary(context)
                              : DesignSystem.getTextTertiary(context).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // 下一步/开始按钮
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.getPrimary(context),
                        foregroundColor: DesignSystem.textInverse,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _totalPages - 1 ? '开始采集' : '下一步',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

/// 第1页：功能介绍
class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: DesignSystem.getPrimary(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam,
              size: 80,
              color: DesignSystem.getPrimary(context),
            ),
          ),
          const SizedBox(height: 48),

          // 标题
          Text(
            '路线采集',
            style: DesignSystem.getHeadlineMedium(context)?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 描述
          Text(
            '使用GPS录制你的徒步路线，\n记录轨迹、海拔变化和运动数据',
            style: DesignSystem.getBodyLarge(context)?.copyWith(
              color: DesignSystem.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 功能点
          _buildFeatureItem(context, Icons.gps_fixed, '精准GPS定位'),
          const SizedBox(height: 16),
          _buildFeatureItem(context, Icons.show_chart, '实时海拔统计'),
          const SizedBox(height: 16),
          _buildFeatureItem(context, Icons.timer, '运动时长记录'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: DesignSystem.getPrimary(context)),
        const SizedBox(width: 8),
        Text(
          text,
          style: DesignSystem.getBodyMedium(context),
        ),
      ],
    );
  }
}

/// 第2页：POI标记说明
class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: DesignSystem.getInfo(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_location_alt,
              size: 80,
              color: DesignSystem.getInfo(context),
            ),
          ),
          const SizedBox(height: 48),

          // 标题
          Text(
            '标记精彩地点',
            style: DesignSystem.getHeadlineMedium(context)?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 描述
          Text(
            '在路途中标记观景点、危险点、补给点等，\n并添加照片和描述',
            style: DesignSystem.getBodyLarge(context)?.copyWith(
              color: DesignSystem.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 标记类型
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildPoiChip(context, Icons.photo_camera, '观景点'),
              _buildPoiChip(context, Icons.local_drink, '补给点'),
              _buildPoiChip(context, Icons.wc, '卫生间'),
              _buildPoiChip(context, Icons.warning, '危险点'),
              _buildPoiChip(context, Icons.chair, '休息点'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoiChip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18, color: DesignSystem.getTextPrimary(context)),
      label: Text(label),
      backgroundColor: DesignSystem.getBackgroundSecondary(context),
    );
  }
}

/// 第3页：审核流程说明
class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: DesignSystem.getSuccess(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified,
              size: 80,
              color: DesignSystem.getSuccess(context),
            ),
          ),
          const SizedBox(height: 48),

          // 标题
          Text(
            '提交审核',
            style: DesignSystem.getHeadlineMedium(context)?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 描述
          Text(
            '录制完成后，提交路线进行审核，\n审核通过后会正式发布到发现页',
            style: DesignSystem.getBodyLarge(context)?.copyWith(
              color: DesignSystem.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 审核流程
          _buildStepItem(
            context,
            step: '1',
            title: '提交审核',
            description: '完善路线信息后提交',
            isActive: true,
          ),
          _buildStepConnector(context),
          _buildStepItem(
            context,
            step: '2',
            title: '等待审核',
            description: '工作人员会在3个工作日内完成审核',
            isActive: false,
          ),
          _buildStepConnector(context),
          _buildStepItem(
            context,
            step: '3',
            title: '正式发布',
            description: '审核通过后路线上线',
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context, {
    required String step,
    required String title,
    required String description,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? DesignSystem.getPrimary(context)
                : DesignSystem.getBackgroundTertiary(context),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                color: isActive ? DesignSystem.textInverse : DesignSystem.getTextSecondary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DesignSystem.getBodyLarge(context)?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: DesignSystem.getBodySmall(context)?.copyWith(
                  color: DesignSystem.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Container(
        width: 2,
        height: 24,
        color: DesignSystem.getDivider(context),
      ),
    );
  }
}