# M4 P1 QA 测试脚本套件

## 目录结构

```
p1_testing/
├── analytics/                    # 埋点专项测试
│   ├── analytics_network_test.dart      # 网络失败场景测试
│   ├── analytics_cancel_test.dart       # 取消操作埋点测试
│   └── analytics_api_failure_test.dart  # API失败埋点测试
├── sos/                          # SOS压力测试
│   ├── sos_stress_test.dart             # 连续触发测试
│   ├── sos_network_simulation_test.dart # 弱网/无信号测试
│   └── sos_battery_test.dart            # 低电量场景测试
├── performance/                  # 性能基准测试
│   ├── cold_start_test.dart             # 冷启动时间测试
│   ├── memory_monitor_test.dart         # 内存占用监控
│   └── apk_size_check.dart              # APK大小检查
└── utils/                        # 测试工具
    ├── network_simulator.dart           # 网络模拟器
    ├── battery_simulator.dart           # 电量模拟器
    └── analytics_verifier.dart          # 埋点验证器
```

## 运行说明

### 1. 埋点专项测试
```bash
# 运行所有埋点测试
flutter test qa/m4/p1_testing/analytics/

# 单独运行网络失败测试
flutter test qa/m4/p1_testing/analytics/analytics_network_test.dart

# 单独运行取消操作测试
flutter test qa/m4/p1_testing/analytics/analytics_cancel_test.dart

# 单独运行API失败测试
flutter test qa/m4/p1_testing/analytics/analytics_api_failure_test.dart
```

### 2. SOS压力测试
```bash
# 运行所有SOS压力测试
flutter test qa/m4/p1_testing/sos/

# 连续触发测试（危险操作，仅在测试环境运行）
flutter test qa/m4/p1_testing/sos/sos_stress_test.dart --tags=stress

# 弱网环境测试
flutter test qa/m4/p1_testing/sos/sos_network_simulation_test.dart

# 低电量测试
flutter test qa/m4/p1_testing/sos/sos_battery_test.dart
```

### 3. 性能基准测试
```bash
# 运行所有性能测试
flutter test qa/m4/p1_testing/performance/

# 冷启动测试（需要物理设备）
flutter test qa/m4/p1_testing/performance/cold_start_test.dart --device-id=<device_id>

# 内存监控测试
flutter test qa/m4/p1_testing/performance/memory_monitor_test.dart

# APK大小检查
flutter test qa/m4/p1_testing/performance/apk_size_check.dart
```

## 环境要求

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0
- Android SDK: >=API 21
- iOS: >=12.0
- 测试设备：物理设备（部分测试需要）

## 注意事项

1. **SOS压力测试** 包含高风险操作，请确保在隔离测试环境运行
2. **网络模拟测试** 需要 root/模拟器权限
3. **性能测试** 建议在发布模式下运行：`--release`
4. 所有测试前请清理应用数据以确保结果准确
