# M5 自动化测试套件

山径APP M5阶段自动化测试脚本集合，覆盖新手引导、成就系统、推荐算法和回归测试。

## 目录结构

```
M5-AUTOMATION-SCRIPTS/
├── onboarding/              # 新手引导测试
│   └── onboarding_test.dart
├── achievement/             # 成就系统测试
│   └── achievement_test.dart
├── recommendation/          # 推荐算法测试
│   └── recommendation_test.dart
├── regression/              # 回归测试
│   └── m4_regression_test.dart
├── utils/                   # 测试工具类
│   ├── test_helpers.dart    # 辅助函数
│   └── test_data.dart       # 测试数据
├── run_tests.sh            # 测试执行脚本
└── README.md               # 本文件
```

## 快速开始

### 1. 运行全部测试

```bash
./M5-AUTOMATION-SCRIPTS/run_tests.sh all
```

### 2. 运行指定模块测试

```bash
# 新手引导测试
./M5-AUTOMATION-SCRIPTS/run_tests.sh onboarding

# 成就系统测试
./M5-AUTOMATION-SCRIPTS/run_tests.sh achievement

# 推荐算法测试
./M5-AUTOMATION-SCRIPTS/run_tests.sh recommendation

# 回归测试
./M5-AUTOMATION-SCRIPTS/run_tests.sh regression
```

### 3. 生成覆盖率报告

```bash
./M5-AUTOMATION-SCRIPTS/run_tests.sh all --coverage
```

覆盖率报告生成在 `coverage/html/index.html`

### 4. 指定设备运行

```bash
# 查看可用设备
flutter devices

# 指定设备运行
./M5-AUTOMATION-SCRIPTS/run_tests.sh onboarding --device emulator-5554
```

## 测试模块说明

### 新手引导测试 (TC-OB-001 ~ TC-OB-020)

- 首次启动流程
- 权限申请集成
- 跳过/重置功能
- 4步引导完成率
- 场景化高亮
- 埋点完整性

**关键测试:**
```bash
flutter test M5-AUTOMATION-SCRIPTS/onboarding/onboarding_test.dart
```

### 成就系统测试 (TC-AC-001 ~ TC-AC-030)

- 5类成就触发条件
- 4级徽章升级逻辑
- 本地数据持久化
- 服务端数据同步
- 解锁动画流畅度
- 分享功能

**关键测试:**
```bash
flutter test M5-AUTOMATION-SCRIPTS/achievement/achievement_test.dart
```

### 推荐算法测试 (TC-RE-001 ~ TC-RE-020)

- 5因子排序正确性
- 地理位置匹配
- 难度/距离偏好
- 推荐结果多样性
- 冷启动处理
- API响应性能

**关键测试:**
```bash
flutter test M5-AUTOMATION-SCRIPTS/recommendation/recommendation_test.dart
```

### 回归测试 (TC-RG-001 ~ TC-RG-015)

- M4功能完整性
- 数据兼容性
- 升级流程
- 核心业务流程

**关键测试:**
```bash
flutter test M5-AUTOMATION-SCRIPTS/regression/m4_regression_test.dart
```

## 测试数据

测试数据定义在 `utils/test_data.dart`，包括：

- 测试用户画像
- 成就触发条件
- 推荐算法因子
- 性能基准阈值

## 工具函数

`utils/test_helpers.dart` 提供常用测试辅助：

```dart
// 应用状态
await TestHelpers.clearAppData();
await TestHelpers.setOnboardingCompleted();

// 成就数据
await TestHelpers.unlockMockAchievements([...]);
await TestHelpers.simulateTrailComplete(trailId, distance);

// 推荐测试
await TestHelpers.setUserLocation(lat, lng);
await TestHelpers.setUserProfile(...);
final recommendations = await TestHelpers.getRecommendations();

// 性能测试
final fps = await TestHelpers.measureFPS(duration: Duration(seconds: 3));

// 埋点验证
final events = await TestHelpers.getAnalyticsEvents();
```

## CI/CD集成

### GitHub Actions示例

```yaml
name: M5 Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Run M5 Tests
        run: |
          ./M5-AUTOMATION-SCRIPTS/run_tests.sh all --coverage
      
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

## 常见问题

### Q: 测试运行缓慢
A: 使用 `--profile` 模式运行，或在真机上测试

### Q: 设备连接失败
A: 确保设备已连接并启用调试模式：
```bash
flutter devices
adb devices
```

### Q: 覆盖率数据不准确
A: 确保使用 `--coverage` 参数，并正确配置 `lcov`

## 相关文档

- [M5测试计划](../M5-QA-TEST-PLAN.md)
- [M5测试用例](../M5-TEST-CASES.md)
- [M5性能基准](../M5-PERFORMANCE-BENCHMARK.md)

## 维护记录

| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-03-19 | v1.0 | 初始版本 |

---

> 测试团队: QA Agent  
> 最后更新: 2026-03-19
