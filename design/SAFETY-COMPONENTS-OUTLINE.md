# 安全中心组件实现大纲

本文件作为 `SAFETY-CENTER-DESIGN-v1.0.md` 的补充，提供Flutter组件实现的技术细节。

---

## 组件目录结构

```
lib/
├── screens/
│   ├── safety_center_screen.dart          # 重构后的安全中心
│   └── safety/
│       ├── lifeline_setup_screen.dart     # 出发前设置
│       ├── contact_picker_screen.dart     # 联系人选择
│       └── overtime_alert_screen.dart     # 超时提醒
├── widgets/
│   └── safety/
│       ├── safety_status_card.dart        # 安全状态卡
│       ├── sos_button.dart                # SOS按钮组件
│       ├── sos_countdown_overlay.dart     # 倒计时覆盖层
│       ├── lifeline_card.dart             # Lifeline卡片
│       ├── contact_list_item.dart         # 联系人列表项
│       └── safety_tip_card.dart           # 安全提示卡片
└── constants/
    └── safety_colors.dart                 # 安全功能专用颜色
```

---

## 1. 颜色扩展 (lib/constants/safety_colors.dart)

```dart
import 'package:flutter/material.dart';

/// 安全功能专用颜色
class SafetyColors {
  SafetyColors._();

  // ========== SOS专用颜色 ==========
  
  /// SOS按钮渐变起始色
  static const Color sosGradientStart = Color(0xFFFF5722);
  
  /// SOS按钮渐变结束色
  static const Color sosGradientEnd = Color(0xFFD32F2F);
  
  /// SOS倒计时脉冲颜色
  static const Color sosPulse = Color(0xFFF44336);
  
  /// SOS按钮阴影
  static Color get sosShadow => const Color(0xFFF44336).withOpacity(0.4);
  
  // ========== 状态颜色 ==========
  
  /// 安全状态 - 正常
  static const Color statusSafe = Color(0xFF4CAF50);
  
  /// 安全状态 - 活跃（分享中）
  static const Color statusActive = Color(0xFF2D968A);
  
  /// 安全状态 - 预警（即将超时）
  static const Color statusWarning = Color(0xFFFF9800);
  
  /// 安全状态 - 紧急
  static const Color statusEmergency = Color(0xFFD32F2F);
  
  // ========== Lifeline颜色 ==========
  
  /// 分享中脉冲
  static Color get sharingPulse => const Color(0xFF4CAF50).withOpacity(0.3);
  
  /// 分享中圆环
  static const Color sharingRing = Color(0xFF4CAF50);
}

/// SOS渐变色扩展
extension SOSGradient on BuildContext {
  LinearGradient get sosButtonGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SafetyColors.sosGradientStart, SafetyColors.sosGradientEnd],
  );
}
```

---

## 2. 安全状态卡 (SafetyStatusCard)

```dart
/// 安全状态类型
enum SafetyStatus {
  /// 正常运行
  normal,
  /// Lifeline分享中
  sharing,
  /// 即将超时
  warning,
  /// SOS已发送
  emergency,
}

class SafetyStatusCard extends StatelessWidget {
  final SafetyStatus status;
  final String? message;
  final String? subMessage;
  final VoidCallback? onAction;
  final String? actionLabel;
  
  const SafetyStatusCard({
    super.key,
    required this.status,
    this.message,
    this.subMessage,
    this.onAction,
    this.actionLabel,
  });
  
  // 根据状态返回对应颜色和图标...
}
```

**状态对应表：**

| 状态 | 图标 | 主色 | 背景色 |
|------|------|------|--------|
| normal | 🛡️ | `#4CAF50` | `#E8F5E9` |
| sharing | 📍 | `#2D968A` | `#E0F2F1` |
| warning | ⏰ | `#FF9800` | `#FFF3E0` |
| emergency | 🚨 | `#D32F2F` | `#FFEBEE` |

---

## 3. SOS按钮 (SOSButton)

```dart
class SOSButton extends StatefulWidget {
  /// 长按触发时长
  final Duration triggerDuration;
  
  /// 触发回调
  final VoidCallback onTrigger;
  
  /// 取消回调
  final VoidCallback? onCancel;
  
  const SOSButton({
    super.key,
    this.triggerDuration = const Duration(seconds: 3),
    required this.onTrigger,
    this.onCancel,
  });
}

class _SOSButtonState extends State<SOSButton> with TickerProviderStateMixin {
  // AnimationController 用于进度环
  // Timer 用于倒计时
  // 震动反馈
}
```

**状态流转：**

```
idle → pressing → counting → confirming → sending → success
        ↓            ↓           ↓           ↓
      cancel      cancel      cancel       retry
```

---

## 4. SOS倒计时覆盖层 (SOSCountdownOverlay)

```dart
class SOSCountdownOverlay extends StatelessWidget {
  final int remainingSeconds;
  final double progress; // 0.0 - 1.0
  final VoidCallback onCancel;
  
  const SOSCountdownOverlay({
    super.key,
    required this.remainingSeconds,
    required this.progress,
    required this.onCancel,
  });
}
```

**视觉层级：**

```
Z-Index:
┌─────────────────────────┐
│  背景遮罩 (半透明黑色)    │  ← opacity: 0.8
├─────────────────────────┤
│  脉冲动画层              │  ← 扩散圆圈
├─────────────────────────┤
│  进度环                  │  ← CustomPainter
├─────────────────────────┤
│  倒计时数字              │  ← 48pt Bold
├─────────────────────────┤
│  取消提示                │  ← 13pt Regular
└─────────────────────────┘
```

---

## 5. Lifeline卡片 (LifelineCard)

```dart
/// Lifeline状态
enum LifelineState {
  /// 未设置联系人
  unset,
  /// 已设置但未开始
  ready,
  /// 分享中
  sharing,
  /// 已超时
  overtime,
}

class LifelineCard extends StatelessWidget {
  final LifelineState state;
  final List<EmergencyContact> contacts;
  final DateTime? expectedReturnTime;
  final VoidCallback? onStartSharing;
  final VoidCallback? onStopSharing;
  final VoidCallback? onManageContacts;
  final VoidCallback? onExtendTime;
  
  const LifelineCard({
    super.key,
    required this.state,
    this.contacts = const [],
    this.expectedReturnTime,
    this.onStartSharing,
    this.onStopSharing,
    this.onManageContacts,
    this.onExtendTime,
  });
}
```

---

## 6. 联系人列表项 (ContactListItem)

```dart
class ContactListItem extends StatelessWidget {
  final String name;
  final String phone;
  final bool isPrimary;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const ContactListItem({
    super.key,
    required this.name,
    required this.phone,
    this.isPrimary = false,
    this.onEdit,
    this.onDelete,
  });
}
```

---

## 7. 主页面重构大纲 (SafetyCenterScreen)

```dart
class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  // 状态
  SafetyStatus _safetyStatus = SafetyStatus.normal;
  LifelineState _lifelineState = LifelineState.ready;
  List<EmergencyContact> _contacts = [];
  bool _isSOSExpanded = false;
  
  // SOS相关
  bool _isSOSCounting = false;
  bool _isSOSSending = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: '安全中心'),
      body: ListView(
        padding: const EdgeInsets.all(DesignSystem.spacingLarge),
        children: [
          // 1. 安全状态卡 (顶部固定)
          SafetyStatusCard(
            status: _safetyStatus,
            // ...
          ),
          
          const SizedBox(height: DesignSystem.spacingLarge),
          
          // 2. Lifeline卡片 (主功能)
          LifelineCard(
            state: _lifelineState,
            contacts: _contacts,
            // ...
          ),
          
          const SizedBox(height: DesignSystem.spacingLarge),
          
          // 3. SOS区域 (折叠式)
          _buildSOSSection(),
          
          const SizedBox(height: DesignSystem.spacingLarge),
          
          // 4. 安全提示
          SafetyTipCard(),
        ],
      ),
    );
  }
  
  Widget _buildSOSSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      child: _isSOSExpanded 
        ? _buildSOSExpanded() 
        : _buildSOSCollapsed(),
    );
  }
}
```

---

## 8. 无障碍实现清单

```dart
// 1. SOS按钮无障碍
Semantics(
  label: 'SOS紧急求助按钮',
  hint: '长按3秒触发紧急求助，松开取消',
  button: true,
  onTapHint: '开始长按倒计时',
  child: GestureDetector(
    onLongPressStart: _handleLongPressStart,
    onLongPressEnd: _handleLongPressEnd,
    child: Container(/* ... */),
  ),
)

// 2. 倒计时实时播报
Semantics(
  label: 'SOS倒计时',
  value: '剩余$_remaining秒，松开手指取消',
  liveRegion: true,
  child: /* ... */,
)

// 3. 状态更新播报
Semantics(
  label: '位置分享状态',
  value: _isSharing ? '分享中，预计返回$_returnTime' : '未开启',
  liveRegion: _statusChanged, // 仅在变化时播报
  child: /* ... */,
)
```

---

## 9. 震动反馈代码

```dart
import 'package:flutter/services.dart';

class SafetyHaptics {
  static void light() {
    HapticFeedback.lightImpact();
  }
  
  static void medium() {
    HapticFeedback.mediumImpact();
  }
  
  static void heavy() {
    HapticFeedback.heavyImpact();
  }
  
  static void countdownTick() {
    HapticFeedback.selectionClick();
  }
  
  static void sosTriggered() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), heavy);
  }
  
  static void success() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.lightImpact();
    });
  }
  
  static void error() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), heavy);
    Future.delayed(const Duration(milliseconds: 200), heavy);
  }
}
```

---

## 10. 关键尺寸速查

| 元素 | 尺寸 | 备注 |
|------|------|------|
| SOS按钮 | 120x120px | 圆形，<375px屏幕缩至100px |
| SOS按钮（按下）| 110x110px | 缩小动画 |
| 倒计时进度环 | 140px直径 | 外圈 |
| Lifeline脉冲 | 160px直径 | 扩散动画 |
| 主按钮高度 | 52px | 全宽或min 200px |
| 卡片内边距 | 20px | 标准 |
| 小屏内边距 | 16px | <375px |
| 联系人头像 | 40px | 圆形 |
| 状态图标 | 24px | 状态卡左侧 |
| 倒计时数字 | 48pt | Bold |

---

**文档结束**
