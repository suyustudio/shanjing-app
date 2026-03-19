# M4-P2-DEV-REVIEW-ISSUES.md

> **Review 类型**: Dev 交叉 Review  
> **Review 日期**: 2026-03-19  
> **状态**: 待修复

---

## Review 产出

1. ✅ [DEV-DESIGN-P2-REVIEW.md](./DEV-DESIGN-P2-REVIEW.md) - Design P2 Review
2. ✅ [DEV-QA-P2-REVIEW.md](./DEV-QA-P2-REVIEW.md) - QA P2 Review
3. ✅ [M4-P2-DEV-REVIEW-ISSUES.md](./M4-P2-DEV-REVIEW-ISSUES.md) - 本文件

---

## 关键问题汇总

### 🔴 阻塞性问题 (必须修复)

| # | 模块 | 问题 | 严重程度 |
|---|------|------|----------|
| 1 | QA/CI | E2E 测试命令错误 | 🔴 阻塞 |
| 2 | QA/测试脚本 | Mock 类定义冲突 | 🔴 阻塞 |
| 3 | QA/性能测试 | 性能数据采集函数未实现 | 🔴 阻塞 |

### 🟠 高优先级问题

| # | 模块 | 问题 | 严重程度 |
|---|------|------|----------|
| 4 | QA/CI | 测试失败被 `|| true` 忽略 | 🟠 高 |
| 5 | QA/CI | iOS 模拟器未启动 | 🟠 高 |
| 6 | QA/CI | 缺少依赖缓存 | 🟠 高 |
| 7 | Design | 导航栏毛玻璃效果性能风险 | 🟠 高 |

### 🟡 中优先级问题

| # | 模块 | 问题 | 严重程度 |
|---|------|------|----------|
| 8 | Design | 缺少 FAB 圆角定义 | 🟡 中 |
| 9 | Design | 缺少 Toast/Snackbar 圆角定义 | 🟡 中 |
| 10 | QA/测试脚本 | 测试依赖的 Key 未文档化 | 🟡 中 |

### 🟢 低优先级建议

| # | 模块 | 建议 | 严重程度 |
|---|------|------|----------|
| 11 | Design | 缺少 Tooltip 圆角定义 | 🟢 低 |
| 12 | Design | 中文字体 fallback 策略 | 🟢 低 |
| 13 | QA/CI | 增加测试重试机制 | 🟢 低 |

---

## Design P2 Review 结论

### 总体评分

| 维度 | 评分 | 状态 |
|------|------|------|
| 技术可行性 | ⭐⭐⭐⭐⭐ (5/5) | ✅ 通过 |
| 性能影响 | ⭐⭐⭐⭐☆ (4/5) | ⚠️ 需关注 |
| 实现复杂度 | ⭐⭐⭐☆☆ (3/5) | ✅ 可接受 |
| 文档完整性 | ⭐⭐⭐⭐☆ (4/5) | ⚠️ 部分缺失 |

### 结论

**✅ Design P2 产出通过 Dev Review**

需要 Design 团队关注：
1. 导航栏滚动效果的 BackdropFilter 性能风险
2. 补充 FAB、Toast 等边界组件的圆角定义

---

## QA P2 Review 结论

### 总体评分

| 维度 | 评分 | 状态 |
|------|------|------|
| CI/CD 配置 | ⭐⭐⭐☆☆ (3/5) | ❌ 有误 |
| E2E 脚本质量 | ⭐⭐☆☆☆ (2/5) | ❌ 缺失 |
| 测试设计 | ⭐⭐⭐⭐☆ (4/5) | ✅ 良好 |
| 可运行性 | ⭐⭐☆☆☆ (2/5) | ❌ 不可运行 |

### 结论

**⚠️ QA P2 产出需要修复后重新 Review**

QA 团队需要修复：
1. CI/CD 工作流配置 (e2e_test.yml)
2. 测试脚本中的 Mock 类和未实现函数
3. 性能数据采集逻辑

---

## 修复任务分配建议

### QA 团队

- [ ] 修复 e2e_test.yml 中的测试命令
- [ ] 移除测试文件中的 Mock 类定义
- [ ] 实现性能数据采集函数（或添加 TODO 注释说明实现方案）
- [ ] 添加 CI 缓存配置
- [ ] 添加 iOS 模拟器启动步骤

### Design 团队

- [ ] 评估导航栏毛玻璃效果的性能影响
- [ ] 补充 FAB 圆角定义 (建议 999px 或 16px)
- [ ] 补充 Toast/Snackbar 圆角定义 (建议 8px)

### Dev 团队 (支持)

- [ ] 协助实现性能数据采集的 platform channel
- [ ] 提供实际项目中使用的 Widget Key 列表
- [ ] 验证导航栏滚动效果在低端设备上的表现

---

## 详细问题说明

### 问题 1: E2E 测试命令错误

**位置**: `.github/workflows/e2e_test.yml`

**问题**:
```yaml
# 错误的命令
flutter test qa/m4/p2_testing/automation/e2e/ \
  --device-id emulator-5554 \
  --reporter expanded 2>&1 || true
```

**原因**:
- `flutter test` 不能直接用于 integration_test
- `--device-id` 参数无效
- `|| true` 会掩盖所有失败

**修复**:
```yaml
# 正确的命令
flutter test qa/m4/p2_testing/automation/e2e/ \
  --reporter expanded
```

---

### 问题 2: Mock 类定义冲突

**位置**: `qa/m4/p2_testing/automation/e2e/flows/navigation_flow_test.dart`

**问题**:
```dart
class TrailCard {
  const TrailCard();
}
```

**原因**:
- Mock 类定义不完整
- 可能与实际项目中的类冲突

**修复**:
- 移除 Mock 类，使用实际项目中的类
- 或使用 `mockito` 正确 mock

---

### 问题 3: 性能数据采集未实现

**位置**: `qa/m4/p2_testing/performance/long_navigation_test.dart`

**问题**:
```dart
Future<int> getMemoryUsageMB() async {
  // TODO: 实现内存获取
  return 150; // 模拟值
}
```

**修复方案**:
1. 使用 platform channel 调用原生 API
2. 或使用 `device_info_plus` + `battery_plus` 等插件

---

### 问题 7: 导航栏毛玻璃效果性能风险

**位置**: `design-system-dark-mode-v1.0.md` 3.6节

**问题**:
```dart
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
  child: Container(...),
)
```

**风险**:
- BackdropFilter 触发 GPU 离屏渲染
- 低端设备可能掉帧

**建议**:
- 延迟启用 BackdropFilter（滚动超过 50% 后）
- 使用 AnimatedBuilder 优化

---

## 后续行动

1. **QA 团队** 根据 Review 结果修复 CI/CD 和测试脚本
2. **Design 团队** 评估并补充边界 Token 定义
3. **Dev 团队** 准备 platform channel 支持（如需要）
4. **重新 Review** 修复完成后进行第二轮 Review

---

> **Review 完成时间**: 2026-03-19  
> **Reviewer**: Dev Agent  
> **下次 Review**: 待修复完成后
