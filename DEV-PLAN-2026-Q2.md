# 山径APP 后续开发计划 (2026 Q2)

> 基于原始设计目标（shanjing-dev-plan.md）与当前项目状态制定
> 生成日期：2026-04-28

---

## 一、项目现状总览

### 1.1 核心模块完成度

| 模块 | shanjing-dev-plan 目标 | 当前完成度 | 评估 |
|------|----------------------|-----------|------|
| **路线发现** | 智能推荐、筛选、详情 | ~85% | 列表/地图视图、详情页、基础搜索完成；AI推荐未开始 |
| **离线导航** | GPS轨迹、路口指引、进度 | ~60% | 导航流程打通、GPS定位可用；路口指引、偏航提醒、离线地图不完整 |
| **社区分享** | 轨迹记录、一键生成、社交 | ~40% | 轨迹记录可用（需优化质量）、分享/社交大量 TODO |
| **安全服务** | 紧急联系、位置共享 | ~55% | SOS 前端逻辑完成、联系人管理完成；后端 API、倒计时页待完善 |

### 1.2 里程碑完成情况

| 里程碑 | 原始时间线 | 实际状态 |
|--------|-----------|---------|
| M1 MVP | 2-3月 | ✅ 基本完成（路线列表、地图、用户系统） |
| M2 导航核心 | 2-3月 | ⚠️ 部分完成（导航流程通但路口指引/偏航未完善） |
| M3 社区闭环 | 2-3月 | ⚠️ 部分完成（记录功能可用，分享/社交大量 TODO） |
| M4 设计系统 | 未在原始规划中 | ✅ 设计 Tokens、字体层级、圆角规范已定义；暗黑模式、动画等未实施 |
| M5+ | 后续阶段 | 收藏夹增强(M7)、成就系统、照片墙等功能正在推进 |

### 1.3 代码库统计

- **Dart 源文件**: 160+
- **屏幕/页面**: 30+
- **服务层**: 30+
- **测试文件**: 36 个
- **待办事项 (TODO/FIXME)**: 30+ 处
- **后端**: NestJS + Prisma + PostgreSQL（shanjing-api/，端口 3000）

---

## 二、关键问题与风险

### 🔴 P0 - 必须优先解决

| # | 问题 | 影响面 | 建议方案 |
|---|------|--------|---------|
| 1 | ~~**Android 16 地图兼容**~~ | ~~已解决~~ | ✅ 继续使用 `amap_flutter_map` 原生 SDK |
| 2 | ~~**地图渲染质量下降**~~ | ~~已解决~~ | ✅ 使用 `amap_flutter_map` 原生矢量渲染，无质量损失 |
| 3 | **后端 API 不可用**：shanjing-api 未部署，localhost:3000 不响应 | 全部后端依赖功能失效 | 部署后端或确保所有关键路径有直接 Web API fallback（步行路径已加，驾车/骑行/地理编码尚无） |

### 🟡 P1 - 重要但可次优先

| # | 问题 | 影响面 |
|---|------|--------|
| 4 | 分享到微信等社交平台均为 TODO stub | 社区闭环不完整 |
| 5 | 埋点分析框架已建但未接入真实 SDK（友盟/神策） | 无法追踪用户行为 |
| 6 | 轨迹记录质量不可靠：采集到的轨迹数据精度不保证 | 路线数据可信度低 |
| 7 | 导航缺少路口指引/偏航检测 | 导航体验不完整 |
| 8 | iOS 离线地图配置已完成但功能推迟 | iOS 用户在无网环境无法导航 |
| 9 | 暗黑模式的设计 Token 已定义但未实施 | UI 体验缺失 |
| 10 | SOS 缺少倒计时确认页面和重试机制 | 安全功能不完整 |

### 🟢 P2 - 体验增强

| # | 问题 | 影响面 |
|---|------|--------|
| 11 | 空状态插画、动画系统待实施 | 视觉体验 |
| 12 | UI 层测试覆盖率低（仅有服务层测试） | 回归测试盲区 |
| 13 | 收藏夹增强功能有 TODO（标签管理、批量操作、排序、分享） | 功能不完整 |
| 14 | 照片墙评论/收藏功能为 TODO | 社交不完整 |
| 15 | 成就系统 websocket 可能未连接 | 成就解锁体验 |

---

## 三、分阶段实施计划

### Phase 1: 基础加固（2-3 周）

**目标**：解决影响核心体验的阻塞性问题，确保基础功能可靠。

| 任务 | 优先级 | 预估工时 | 涉及文件 |
|------|--------|---------|---------|
| 1.1 ~~地图质量优化~~ | ~~P0~~ | ✅ 已完成 | 移除 AppMap wrapper，直接使用 `amap_flutter_map` 原生 SDK |
| 1.2 API 关键路径 fallback 全覆盖 | P0 | 2天 | `lib/services/map_service.dart` |
| 1.3 后端部署（Docker / 服务器） | P0 | 3-5天 | shanjing-api/ |
| 1.4 轨迹记录质量提升 | P1 | 3-4天 | `lib/screens/recording_screen.dart`、`lib/services/recording_service.dart` |
| 1.5 导航路口指引/偏航检测 | P1 | 3-5天 | `lib/screens/navigation_screen.dart` |

#### 1.1 ~~地图质量优化~~ ✅ 已完成

**方案**：直接使用 `amap_flutter_map`（v3.0.0）原生 SDK，享受原生矢量渲染。
已移除所有中间抽象层（`AppMap` wrapper、`latlong2`、`mock_navi_service`）。

#### 1.2 高德 Web API 完整覆盖

当前 `planWalkingRoute()` 已直连高德 Web API，驾车/骑行/地理编码仍需扩展：
- `planDrivingRoute()` → `restapi.amap.com/v3/direction/driving`
- `planBicyclingRoute()` → `restapi.amap.com/v4/direction/bicycling`
- `geocode()` → `restapi.amap.com/v3/geocode/geo`
- `reverseGeocode()` → `restapi.amap.com/v3/geocode/regeo`

#### 1.4 轨迹记录质量提升

参考计划缓存文件 `recording_screen/` 中的整改方案：
- 使用 `GpsAccuracyFilter` 过滤低精度点（已完成部分）
- 导入 Douglas-Peucker 轨迹简化算法（track_simplifier.dart 已创建）
- 修复数据保存前丢失问题
- 增加 GPS 精度状态显示

---

### Phase 2: 功能闭环（3-4 周）

**目标**：补齐社区分享、安全服务等核心模块的缺失功能。

| 任务 | 优先级 | 预估工时 | 说明 |
|------|--------|---------|------|
| 2.1 社交分享集成 | P1 | 3-5天 | 微信分享（好友/朋友圈）、海报生成 |
| 2.2 埋点 SDK 接入 | P1 | 2-3天 | 友盟或神策 SDK 接入，事件对齐规范 |
| 2.3 SOS 倒计时页 + 重试 | P1 | 2-3天 | 补充倒计时确认页面、错误重试 |
| 2.4 收藏夹完整功能 | P1 | 4-5天 | 标签管理、批量操作、排序、分享 |
| 2.5 iOS 离线地图 | P1 | 3-5天 | 从配置接口到功能实现 |

---

### Phase 3: 体验提升（3-4 周）

**目标**：UI/UX 精细化，测试覆盖。

| 任务 | 优先级 | 预估工时 | 说明 |
|------|--------|---------|------|
| 3.1 暗黑模式 | P1 | 3-5天 | 从 Design Token 到全局适配 |
| 3.2 空状态插画 + 动画 | P2 | 3-5天 | SVG 空状态、Lottie 加载、页面转场 |
| 3.3 UI 层测试 | P2 | 3-5天 | Widget 测试 + 集成测试 |
| 3.4 清理 TODO 债务 | P2 | 2-3天 | 扫描并解决 30+ 个 TODO |
| 3.5 新用户引导（Onboarding） | P2 | 2-3天 | 场景化权限申请、引导流程完善 |

---

## 四、架构决策记录

### ADR-001: 地图方案（2026-04-29 更新）

- **上下文**：项目依赖高德 Flutter SDK 三件套
- **决策**：全面使用高德原生 SDK
  - `amap_flutter_map`（v3.0.0）—— 地图显示，原生矢量渲染
  - `amap_flutter_location`（v3.0.0）—— GPS 定位
  - 高德 Web API（`restapi.amap.com`）—— 路径规划/地理编码
- **原则**：不引入中间抽象层（Wrapper），不引入非高德替代方案（flutter_map/MapLibre）

### ADR-002: 状态管理

- **现有方案**：Provider（有 Provider 层文件）
- **决策**：保持 Provider，不引入 Bloc/Riverpod 避免架构碎片化

### ADR-003: 后端通信

- **现有方案**：ApiClient + NestJS REST API
- **决策**：路网依赖高德 Web API（`restapi.amap.com`），业务数据走后端 API。
  路径规划/地理编码优先通过后端代理，不可用时直连高德 Web API

---

## 五、测试策略

| 层级 | 当前覆盖 | 目标覆盖 |
|------|---------|---------|
| **单元测试** | 核心服务层（SOS、分享、性能优化工具） | 全部服务层 > 80% |
| **Widget 测试** | 少量（button、search_bar 等） | 核心页面 + 通用组件 |
| **集成测试** | 无 | 导航 + 记录 + SOS 关键流程 |
| **Golden 测试** | 无 | 暗黑模式 UI 一致性 |

---

## 六、清理清单（已知 TODO 分布）

| 文件 | TODO 数量 | 性质 |
|------|-----------|------|
| `lib/screens/collections/collection_detail_screen.dart` | 6 | 分享、排序、标签管理、导航跳转 |
| `lib/services/collection_enhanced_service.dart` | 3 | 标签 API 支持、路线名称、频率统计 |
| `lib/widgets/share_poster.dart` | 3 | 微信分享/朋友圈/保存图片 |
| `lib/analytics/analytics_service.dart` | 4 | 友盟 SDK 恢复 |
| `lib/widgets/photo_viewer.dart` | 3 | 评论、收藏、下载 |
| `lib/screens/recording_edit_screen.dart` | 1 | POI 编辑对话框 |
| `lib/screens/map_screen_simple.dart` | 1 | SOS API 调用 |
| `lib/services/error_monitor_service.dart` | 1 | 错误上报到服务器 |
| `lib/main.dart` | 1 | 首次启动检查恢复 |
| `lib/analytics_service.dart` | 3 | 埋点 SDK 接入 |
| **合计** | **30+** | |

---

## 七、附录

### 参考文档
- [shanjing-dev-plan.md](./shanjing-dev-plan.md) — 原始产品规划
- [DEV-DESIGN-REVIEW.md](./DEV-DESIGN-REVIEW.md) — 设计系统 Review
- [PRODUCT-DEV-REVIEW.md](./PRODUCT-DEV-REVIEW.md) — M4 埋点+分享 Review
- [PRODUCT-DEV-P2-REVIEW.md](./PRODUCT-DEV-P2-REVIEW.md) — M4 P2 测试+优化 Review
- [UX-OPTIMIZATION-PLAN.md](./UX-OPTIMIZATION-PLAN.md) — UX 优化计划
- [m7-p1-collections-design-assets.md](./m7-p1-collections-design-assets.md) — 收藏夹增强设计
