# 山径APP E2E 测试框架

本目录包含山径APP的端到端(E2E)集成测试，使用 Flutter Integration Tests 框架。

## 📁 目录结构

```
integration_test/
├── e2e_utils.dart              # 测试工具类和辅助函数
├── e2e_all_test.dart           # 主测试入口，运行所有测试
├── core_flow_test.dart         # 核心流程测试
├── favorite_test.dart          # 收藏功能测试
├── offline_map_test.dart       # 离线地图测试
├── search_test.dart            # 搜索功能测试
└── boundary_cases_test.dart    # 边界场景测试
```

## 🚀 快速开始

### 1. 环境准备

确保已安装 Flutter SDK 和模拟器/真机：

```bash
# 检查 Flutter 环境
flutter doctor

# 获取依赖
flutter pub get
```

### 2. 运行测试

```bash
# 运行所有 E2E 测试
flutter test integration_test/e2e_all_test.dart

# 运行单个测试文件
flutter test integration_test/core_flow_test.dart
flutter test integration_test/favorite_test.dart
flutter test integration_test/offline_map_test.dart
flutter test integration_test/search_test.dart
flutter test integration_test/boundary_cases_test.dart
```

### 3. 在特定设备上运行

```bash
# 列出可用设备
flutter devices

# 在特定设备上运行
flutter test integration_test/e2e_all_test.dart -d <device_id>
```

### 4. 生成测试报告

```bash
# JSON 格式报告
flutter test integration_test/ --reporter json > test_report.json

# 带覆盖率报告
flutter test integration_test/ --coverage
```

## 📋 测试覆盖

### 核心流程测试 (core_flow_test.dart)

| 测试用例 | 描述 |
|----------|------|
| 完整导航流程测试 | 发现页 → 路线列表 → 详情 → 导航 → 返回 |
| 路线详情 Tab 切换测试 | 简介/轨迹/评价/攻略 Tab 切换 |
| 路线筛选功能测试 | 难度/距离筛选功能 |
| 不同路线导航测试 | 多条路线的导航测试 |

### 收藏功能测试 (favorite_test.dart)

| 测试用例 | 描述 |
|----------|------|
| 完整收藏流程测试 | 添加收藏 → 我的收藏 → 取消收藏 |
| 收藏状态持久化测试 | 验证收藏状态保持 |
| 批量收藏测试 | 多条路线收藏管理 |
| 收藏列表空状态测试 | 无收藏时的空状态 |

### 离线地图测试 (offline_map_test.dart)

| 测试用例 | 描述 |
|----------|------|
| 离线地图完整流程测试 | 进入下载页 → 下载城市 → 验证 |
| 离线地图下载管理测试 | 暂停/继续/删除功能 |
| 离线地图存储空间检查 | 存储空间显示和检查 |

### 搜索功能测试 (search_test.dart)

| 测试用例 | 描述 |
|----------|------|
| 搜索完整流程测试 | 输入关键词 → 查看结果 → 清空 |
| 搜索结果筛选测试 | 搜索结果筛选功能 |
| 搜索无结果场景测试 | 空关键词/不存在关键词 |
| 搜索防抖功能测试 | 快速输入处理 |
| 搜索历史功能测试 | 历史记录显示和点击 |
| 搜索结果点击进入详情测试 | 搜索结果到详情的跳转 |

### 边界场景测试 (boundary_cases_test.dart)

| 测试用例 | 描述 |
|----------|------|
| 无网络场景 - 发现页离线提示 | 离线模式下的发现页 |
| 无网络场景 - 搜索功能降级 | 无网络时的搜索处理 |
| GPS弱信号 - 导航页面提示 | GPS精度提示 |
| GPS信号丢失 - 使用最后已知位置 | GPS降级处理 |
| 存储空间不足 - 离线地图下载提示 | 存储空间检查和提示 |
| 存储空间不足 - 下载阻止 | 空间不足时阻止下载 |
| 权限拒绝 - 定位权限处理 | 权限提示和引导 |
| 权限拒绝 - 存储权限处理 | 存储权限处理 |
| 应用启动 - 多边界条件组合 | 综合边界条件测试 |
| 异常退出恢复测试 | 异常退出后的恢复 |

## 🔧 测试工具类

### E2ETestUtils

提供常用的测试辅助方法：

```dart
// 等待页面加载
await E2ETestUtils.waitForPageLoad(tester);

// 点击组件（通过 Key）
await E2ETestUtils.tapByKey(tester, 'button_key');

// 点击文本
await E2ETestUtils.tapByText(tester, '按钮文本');

// 点击图标
await E2ETestUtils.tapByIcon(tester, Icons.add);

// 输入文本
await E2ETestUtils.enterText(tester, 'input_key', '输入内容');

// 滚动直到可见
await E2ETestUtils.scrollUntilVisible(tester, 'list_key', '目标文本');

// 验证文本存在
E2ETestUtils.expectTextExists('期望文本');
```

### TestLogger

测试日志输出：

```dart
TestLogger.step('执行步骤描述');
TestLogger.success('成功信息');
TestLogger.error('错误信息');
TestLogger.warning('警告信息');
```

### TestData

测试数据常量：

```dart
TestData.searchKeywordTrail    // '九溪'
TestData.searchKeywordLocation // '西湖'
TestData.searchNoResults       // '不存在的路线名称'
TestData.shortDelay            // 500ms
TestData.mediumDelay           // 1500ms
TestData.longDelay             // 3000ms
```

## 📝 添加新测试

1. 创建新的测试文件，如 `new_feature_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hangzhou_guide/main.dart' as app;
import 'e2e_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('新功能测试', () {
    testWidgets('测试用例描述', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 测试步骤...
      TestLogger.step('步骤描述');
      
      // 验证...
      expect(find.text('期望文本'), findsOneWidget);
      
      TestLogger.success('测试通过');
    });
  });
}
```

2. 在 `e2e_all_test.dart` 中导入并运行新测试：

```dart
import 'new_feature_test.dart' as new_feature;

void main() {
  // ...
  new_feature.main();
}
```

## 🐛 常见问题

### 测试超时

如果测试超时，可以增加超时时间：

```dart
await E2ETestUtils.waitForPageLoad(tester); // 默认3秒
await tester.pumpAndSettle(const Duration(seconds: 5)); // 自定义5秒
```

### 元素找不到

- 确保元素已渲染：`await tester.pumpAndSettle()`
- 检查 Key 是否正确
- 使用 `find.byType()` 作为备选方案

### 模拟器问题

- 确保模拟器已启动
- 检查 Flutter 是否能识别设备：`flutter devices`
- 重启模拟器或尝试真机测试

## 📊 测试报告

运行测试后会生成以下信息：

```
✅ 通过 - 核心流程测试: 完整导航流程
✅ 通过 - 收藏功能测试: 完整收藏流程
✅ 通过 - 搜索功能测试: 搜索完整流程
...

测试总结:
- 总测试数: 26
- 通过: 26
- 失败: 0
```

## 🔗 相关文档

- [发布检查清单](../RELEASE-CHECKLIST.md)
- [产品验收报告](../PRODUCT-ACCEPTANCE-REPORT-Build30.md)
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)

---

*文档版本: v1.0*  
*更新日期: 2026-03-14*
