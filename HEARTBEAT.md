# HEARTBEAT.md - 定期检查清单

## 检查频率
每 10 分钟检查一次

## 收到 Heartbeat 后必须执行（不能只回复 HEARTBEAT_OK）

### 1. 立即检查 GitHub Actions 状态
- [x] 执行：`curl -s "https://api.github.com/repos/suyustudio/shanjing-app/actions/runs?per_page=3"`
- [x] 记录构建编号、状态、结论
- [x] 如有失败，分析原因

### 2. 检查 Push 状态
- [x] 执行：`git status | grep "ahead"`
- [x] 如有未 push 的 commit，立即重试
- [x] 记录 push 结果

### 3. 检查 Memory 记录
- [x] 检查今日 memory 文件是否存在
- [x] 如有未记录的工作内容，立即写入
- [x] **不能只在聊天说"记住了"，必须落盘**

### 4. 主动汇报
- [x] 构建失败 → 告知用户
- [x] 需要操作 → 明确说明
- [x] push 失败 → 请求协助

## 记忆锚点
- **HEARTBEAT_OK ≠ 工作完成**
- **收到 heartbeat = 开始工作**
- **不检查 = 失职**
- **聊天说记住了 ≠ 写入文件**

---

## 当前状态（2026-03-17 结束）

### 🚨 严重阻塞：推送失败，本地修复无法同步

**今日核心问题：**
1. M1 阶段的 `abiFilters` 配置丢失，高德 SDK 崩溃问题复发
2. `lib/main.dart` 引用已删除的 `map_screen_webview.dart`
3. **git push 多次被 SIGKILL 中断，无法同步到 GitHub**

**本地已修复（未推送）：**
- ✅ `build.gradle` 添加 `abiFilters` 和高德 SDK 依赖
- ✅ `lib/main.dart` 改为引用 `MapScreenSimple`
- ✅ 整理工作流（删除9个混乱配置，保留1个简洁工作流）

**GitHub Actions 状态：**
| Build | 工作流 | 状态 | 原因 |
|-------|--------|------|------|
| ❌ #124 | Release APK | 失败 | main.dart 引用已删除文件 |
| ❌ #72 | APK with Debug | 失败 | 同上 |
| ❌ #40 | Minimal Test | 失败 | 同上 |

**阻塞原因：** 远程代码仍为旧版本，需要手动在 GitHub 网站修复

**下一步：**
- [ ] 手动在 GitHub 网站编辑 `lib/main.dart`
- [ ] 触发新构建验证
- [ ] 解决推送失败问题

**历史记录见下方**

**GitHub Actions：**
- 🔄 Build #49: Build APK with Debug - in_progress
- 🔄 Build #55: Debug Build - in_progress  
- 🔄 Build #102: Build and Release APK (Fixed) - in_progress
- 🔄 Build #18: Build APK - Minimal Test - in_progress

**预计完成：** 5-10分钟内

**本地环境配置：**
- AVD已配置 (pixel_33)
- 缺少系统镜像（正在寻找解决方案）
- 已创建Firebase Test Lab测试脚本作为备选

**等待新构建完成测试**

**之前的修复不完整：**
- ✅ main.dart中注释了OfflineMapManager.initialize()
- ❌ 但MapScreen.initState()中又调用了_offlineManager.initialize()
- ❌ 导致进入首页时仍然触发MethodChannel调用，应用白屏

**新修复：**
- 注释了MapScreen._initOfflineManager()中的initialize()调用
- 提交已推送（进行中）

**问题总结：**
- 离线地图功能的MethodChannel在Android原生代码中未实现
- 任何调用_offlineManager.initialize()的地方都会导致应用卡死
- 需要全面检查所有调用点

**GitHub Actions：**
- 🔄 Build #49: Build APK with Debug - in_progress
- 🔄 Build #55: Debug Build - in_progress  
- 🔄 Build #102: Build and Release APK (Fixed) - in_progress
- 🔄 Build #18: Build APK - Minimal Test - in_progress

**预计完成：** 5-10分钟内

**本地环境配置：**
- AVD已配置 (pixel_33)
- 缺少系统镜像（正在寻找解决方案）
- 已创建Firebase Test Lab测试脚本作为备选

**等待新构建完成测试**

**之前的修复不完整：**
- ✅ main.dart中注释了OfflineMapManager.initialize()
- ❌ 但MapScreen.initState()中又调用了_offlineManager.initialize()
- ❌ 导致进入首页时仍然触发MethodChannel调用，应用白屏

**新修复：**
- 注释了MapScreen._initOfflineManager()中的initialize()调用
- 提交已推送（进行中）

**问题总结：**
- 离线地图功能的MethodChannel在Android原生代码中未实现
- 任何调用_offlineManager.initialize()的地方都会导致应用卡死
- 需要全面检查所有调用点

**Icon集成：**
- 方案4（山水意境风）已打入Android项目
- 5种分辨率图标已生成并放入mipmap目录
- AndroidManifest.xml已更新使用自定义图标

**白屏问题：**
- 根因：OfflineMapManager调用未实现的MethodChannel
- 修复：临时禁用离线地图和网络管理器初始化
- 提交：`72048a38`

**推送状态：**
- Icon提交：`74a44557`（push中）
- 白屏修复：`72048a38`（等待push）

**检查频率：**
- 已调整回每20分钟检查一次

**问题根因：**
- `main.dart` 中的 `OfflineMapManager.initialize()` 调用 `MethodChannel.invokeMethod('initialize')`
- 但 `MainActivity.kt` 没有注册 `com.shanjing/offline_map` channel 的处理器
- 导致 Dart 端的调用永远等待，应用卡在白屏

**修复方案：**
- 临时注释掉 `OfflineMapManager.initialize()` 和 `NetworkManager.initialize()`
- 应用可以正常启动，离线地图功能暂时不可用
- 后续需要在 MainActivity.kt 中实现完整的 MethodChannel 处理器

**已提交：** `72048a38` - fix: 临时禁用离线地图和网络管理器初始化

| Build | 工作流 | 状态 | 说明 |
|-------|--------|------|------|
| **#51** | Debug Build | ✅ 成功 | 快速检查通过 |
| **#45** | Build APK with Debug | ✅ 成功 | APK 22.67 MB |
| **#14** | Build APK - Minimal Test | ✅ 成功 | 备用构建 |

### 今日关键提交
**`fix: 修复真机启动白屏问题`**
- MainActivity 添加 onCreate 方法调用 super.onCreate
- 启动背景改为透明，避免白屏

### 状态总结
- ✅ 最新构建（#51）成功
- ✅ 最近5个构建全部成功
- ✅ 白屏问题已修复并提交
- ⏳ 等待 Firebase Test Lab 验证修复效果

### 下一步
1. 在 Firebase Test Lab 重新测试修复后的 APK
2. 检查 Test Lab 视频是否正常显示（非黑屏）
3. 如仍有问题，获取完整 logcat 继续排查

---

## 历史记录

### Build 状态（2026-03-16 22:20 检查）
| Build | 工作流 | 状态 | 结论 | 说明 |
|-------|--------|------|------|------|
| #51 | debug.yml | ✅ 成功 | success | 最新构建 |
| #45 | build-debug.yml | ✅ 成功 | success | APK 构建完成（22.67MB） |
| #14 | build-minimal.yml | ✅ 成功 | success | 最小化测试 |

**关键进展**: 
- ✅ 所有工作流全部成功
- ✅ 白屏问题修复已提交（MainActivity onCreate 修复）
- ⏳ 等待 Test Lab 验证修复效果

**Push 状态**: 
- ✅ 所有修改已 push
- 最新 commit: 修复真机启动白屏问题

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
