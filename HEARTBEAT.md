# HEARTBEAT.md - 定期检查清单

## 检查频率
每 10 分钟检查一次

## 自动调试策略

### 当前问题
Build #12 运行中 - 纯 Debug 构建

### 已尝试修复
1. ✅ 禁用友盟SDK - 解决 pub get 失败
2. ✅ 添加 gradle-wrapper.properties  
3. ✅ 禁用高德地图SDK
4. ✅ 禁用ProGuard和代码压缩
5. ✅ 降级Flutter到3.16.0
6. ✅ Debug 构建成功 (Build #63)
7. ❌ Release 构建仍失败

### 当前状态
- ✅ Debug APK: Build #63 成功
- ❌ Release APK: 暂时禁用，需要进一步调试

### 下一步
1. 等待 Build #12 结果（纯 Debug 构建）
2. 研究 Release 构建失败原因（可能与签名/压缩有关）

## 收到 Heartbeat 后必须执行（不能只回复 HEARTBEAT_OK）

### 1. 立即检查 GitHub Actions 状态
- [ ] 执行：`curl -s "https://api.github.com/repos/suyustudio/shanjing-app/actions/runs?per_page=3"`
- [ ] 记录构建编号、状态、结论
- [ ] 如有失败，分析原因

### 2. 检查 Push 状态
- [ ] 执行：`git status | grep "ahead"`
- [ ] 如有未 push 的 commit，立即重试
- [ ] 记录 push 结果

### 3. 检查 Memory 记录
- [ ] 检查今日 memory 文件是否存在
- [ ] 如有未记录的工作内容，立即写入
- [ ] **不能只在聊天说"记住了"，必须落盘**

### 4. 主动汇报
- [ ] 构建失败 → 告知用户
- [ ] 需要操作 → 明确说明
- [ ] push 失败 → 请求协助

## 记忆锚点
- **HEARTBEAT_OK ≠ 工作完成**
- **收到 heartbeat = 开始工作**
- **不检查 = 失职**
- **聊天说记住了 ≠ 写入文件**

---

## 当前状态（2026-03-15 20:00）

### Build 状态（cron检查 #68c9f02d-7d56-4a3b-9421-4fec683b0afd）
| Build | 工作流 | 状态 | 结论 | 说明 |
|-------|--------|------|------|------|
| #23 | debug.yml | ✅ 成功 | success | Debug构建成功（仅检查） |
| #70 | build-v55.yml | ❌ 失败 | failure | APK构建失败 |
| #17 | Build APK with Debug | ❌ 失败 | failure | 简化版构建失败 |

**关键发现**: 
- ✅ Debug工作流（debug.yml）成功 - 仅执行检查，不构建APK
- ❌ build-v55.yml工作流持续失败 - 实际APK构建失败
- 失败点都是"Build Debug APK"步骤
- 问题定位：构建命令本身有问题，需要查看详细日志

**Push 状态**: 
- ✅ 所有修改已push
- 最新commit: 添加pre-build诊断检查

**需要关注的问题**:
1. APK构建步骤持续失败
2. 需要查看Build #70详细错误日志
3. Debug Build工作流和实际构建的差异

### 今日工作总结（2026-03-15）

**主要任务**: GitHub Actions构建调试
**完成情况**: 
- 尝试了9种不同的修复方案
- Debug Build检查工作流成功
- 但APK构建仍失败

**已记录**: memory/2026-03-15.md
**自动检查**: ✅ 已启用（每20分钟）

### Product Agent 任务完成（2026-03-14）

✅ **已完成的工作**:

1. **产品文档检查**
   - 检查 `shanjing-prd-v1.2.md` 完整性
   - 对比当前实现与PRD差异
   - 结论：Build #30 有条件通过M1验收

2. **埋点规范完善**
   - 检查现有埋点规范 `data-tracking-spec-v1.0.md`
   - 补充缺失埋点事件（安全功能、POI、登录等）
   - 生成 `data-tracking-spec-v1.1.md`

3. **边界场景文档**
   - 检查现有边界场景文档
   - 补充新场景（电量低、存储不足、异常退出等）
   - 生成 `boundary-cases-supplement-v1.0.md`

4. **用户体验检查**
   - 检查空状态实现：`app_empty.dart` 基础实现，需完善插画
   - 检查加载状态：`app_loading.dart` 完整实现
   - 检查错误提示：`app_error.dart` 完整实现

5. **生成产品验收报告**
   - 生成 `PRODUCT-ACCEPTANCE-REPORT-Build30.md`
   - 结论：Build #30 有条件通过 M1 验收
   - UX评分：7.7/10

### 生成的文档
| 文档 | 路径 | 说明 |
|------|------|------|
| 产品验收报告 | `PRODUCT-ACCEPTANCE-REPORT-Build30.md` | Build #30 完整验收报告 |
| 埋点规范v1.1 | `data-tracking-spec-v1.1.md` | 补充安全功能、POI等埋点 |
| 边界场景补充 | `boundary-cases-supplement-v1.0.md` | 补充电量、存储等场景 |

### M2 建议优先级
1. **P0**: 离线地图SDK接入（3-5天）
2. **P0**: 埋点实施（3天）
3. **P1**: 空状态完善（2天）
4. **P1**: 收藏功能API（1天）

### 当前阻塞问题
- 无阻塞性问题
- Build #30 可进行小范围内测

### 下一步
- 安排实地导航测试
- 完成安全功能后端联调
- M2迭代开发

---
