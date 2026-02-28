# 山径APP - M1 开发排期详细计划

> **文档版本**: v1.0  
> **制定日期**: 2026-02-27  
> **适用周期**: Week 2-6（开发阶段）

---

## 1. 详细开发计划（每周每天）

### Week 2: 基础架构周

#### Day 1-2 (后端 - B1: 技术选型+架构设计)
| 时间 | 任务 | 产出物 | 负责人 |
|------|------|--------|--------|
| Day 1 AM | 技术选型最终确认 | 技术选型决策表 | 后端 |
| Day 1 PM | NestJS项目脚手架搭建 | 基础代码框架 | 后端 |
| Day 2 AM | 模块划分与接口设计 | 模块架构图 | 后端 |
| Day 2 PM | 开发环境配置(Docker) | docker-compose.yml | 后端 |

#### Day 3-4 (后端 - B2: 数据库设计)
| 时间 | 任务 | 产出物 | 负责人 |
|------|------|--------|--------|
| Day 3 AM | 实体关系设计 | ER图 | 后端 |
| Day 3 PM | Prisma Schema编写 | schema.prisma | 后端 |
| Day 4 AM | 索引与优化设计 | 索引设计文档 | 后端 |
| Day 4 PM | 数据库迁移脚本 | migration文件 | 后端 |

#### Day 5 (后端 - B3准备 + 移动端M1启动)
| 时间 | 任务 | 产出物 | 负责人 |
|------|------|--------|--------|
| Day 5 AM | Redis配置+工具类 | Redis服务封装 | 后端 |
| Day 5 PM | **【里程碑】架构评审会议** | 评审纪要 | 全员 |

**Week 2 移动端任务**: M1 项目搭建启动
| 时间 | 任务 | 产出物 | 负责人 |
|------|------|--------|--------|
| Day 4-5 | Flutter项目初始化 | 项目框架 | 移动端 |
| Day 5 | 目录结构设计 | 代码规范文档 | 移动端 |

---

### Week 3: 核心功能启动周

#### Day 6-8 (后端 - B3: 用户系统API)
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 6 AM | 微信登录接口 | /auth/wechat | B2 |
| Day 6 PM | Token刷新/退出 | /auth/refresh, /auth/logout | B2 |
| Day 7 AM | 用户信息接口 | /users/me | B2 |
| Day 7 PM | 手机号绑定 | /users/me/phone | B2 |
| Day 8 AM | 紧急联系人接口 | /users/me/emergency | B2 |
| Day 8 PM | 用户API单元测试 | 测试用例 | B2 |

#### Day 6-8 (后端 - B4: 路线数据API启动)
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 6 AM | 路线模型设计 | Trail实体 | B2 |
| Day 7 AM | 路线列表接口 | /trails | B2 |
| Day 7 PM | 路线详情接口 | /trails/:id | B2 |
| Day 8 AM | 附近搜索接口 | /trails/nearby | B2 |

#### Day 9-10 (后端 - B5: 文件存储服务)
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 9 AM | OSS配置与封装 | OssService | B1 |
| Day 9 PM | 预签名上传接口 | /files/presign | B1 |
| Day 10 AM | 图片处理接口 | /files/:id | B1 |
| Day 10 PM | 文件服务测试 | 测试用例 | B1 |

**Week 3 移动端任务**: M1完成 + M2启动
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 6-7 | 状态管理配置(Riverpod) | Provider架构 | - |
| Day 7 | 路由配置 | 路由表 | - |
| Day 8-10 | M2: 公共组件库启动 | 基础组件 | M1 |
| Day 8 | 网络服务封装 | HttpService | - |
| Day 9 | 存储服务封装 | StorageService | - |
| Day 10 | UI组件: Button/Input/Card | 组件库 | - |

**【Week 3 周五里程碑】**: 用户API联调准备

---

### Week 4: 功能开发加速周

#### Day 11-13 (后端 - B4完成 + B6启动)
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 11 AM | 路线筛选功能 | 筛选参数实现 | B4 |
| Day 11 PM | 收藏功能接口 | /trails/:id/favorite | B3,B4 |
| Day 12 AM | GPX数据处理 | GpxService | B4 |
| Day 12 PM | 路线搜索优化 | 全文搜索 | B4 |
| Day 13 AM | B6: 高德地图服务对接 | AMapService | B1 |
| Day 13 PM | 地理编码/逆编码 | 位置服务 | B1 |

#### Day 14 (后端 - B7: 后台管理系统启动)
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 14 AM | 后台React项目搭建 | 管理后台框架 | B1 |
| Day 14 PM | 后台路由与布局 | 基础布局 | B1 |

**Week 4 移动端任务**: M2完成 + M3启动
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 11-12 | M2完成: 地图组件封装 | AMapWidget | M1 |
| Day 12 | M2完成: 列表组件 | TrailList | M1 |
| Day 13 | M2完成: 加载/空状态组件 | UI组件库 | M1 |
| Day 14 AM | **【里程碑】M2组件库评审** | 评审通过 | 全员 |
| Day 14 PM | M3: 登录页UI | LoginScreen | M2,B3 |

---

### Week 5: 前后端联调周

#### Day 15-17 (后端 - B7: 后台管理系统)
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 15 AM | 路线列表管理页 | TrailListPage | B4 |
| Day 15 PM | 路线创建/编辑页 | TrailFormPage | B4 |
| Day 16 AM | POI管理功能 | PoiManager | B4 |
| Day 16 PM | 用户管理页 | UserListPage | B3 |
| Day 17 AM | 数据统计仪表盘 | Dashboard | B3,B4 |
| Day 17 PM | 后台权限控制 | RBAC实现 | B3 |

#### Day 18-19 (后端 - B8: API文档+测试)
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 18 AM | Swagger文档配置 | API文档 | B3-B7 |
| Day 18 PM | 接口集成测试 | 测试报告 | B3-B7 |
| Day 19 AM | 性能测试 | 性能报告 | B3-B7 |
| Day 19 PM | 接口优化 | 优化记录 | B3-B7 |

**Week 5 移动端任务**: M3完成 + M4启动
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 15 AM | M3: 微信登录集成 | 登录功能 | M2,B3 |
| Day 15 PM | M3: 用户信息页 | ProfileScreen | M2,B3 |
| Day 16 AM | M3: 我的收藏 | FavoritesScreen | M2,B3 |
| Day 16 PM | M3: 设置页 | SettingsScreen | M2,B3 |
| Day 17 AM | **【里程碑】M3用户模块联调** | 联调通过 | 后端+移动端 |
| Day 17 PM | M4: 发现页框架 | DiscoveryScreen | M2 |
| Day 18 AM | M4: 路线列表UI | TrailListView | M2,B4 |
| Day 18 PM | M4: 筛选组件 | FilterWidget | M2,B4 |
| Day 19 AM | M4: 搜索功能 | SearchDelegate | M2,B4 |
| Day 19 PM | M4: 列表API对接 | 数据绑定 | M2,B4 |

---

### Week 6: 地图与导航周

#### Day 20-21 (后端收尾)
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 20 AM | 后台Bug修复 | 修复记录 | B7 |
| Day 20 PM | API性能优化 | 优化报告 | B8 |
| Day 21 AM | 服务端部署脚本 | CI/CD配置 | B1 |
| Day 21 PM | **【里程碑】后端M1交付** | 交付文档 | 后端 |

**Week 6 移动端任务**: M4完成 + M5/M6启动
| 时间 | 任务 | 产出物 | 依赖 |
|------|------|--------|------|
| Day 20 AM | M4完成: 路线列表优化 | 列表完成 | M2,B4 |
| Day 20 PM | **【里程碑】M4联调** | 联调通过 | 全员 |
| Day 21 AM | M5: 路线详情页框架 | DetailScreen | M4 |
| Day 21 PM | M5: 路线信息展示 | TrailInfoWidget | M4 |
| Day 22 AM | M5: 海拔剖面图 | ElevationChart | M4 |
| Day 22 PM | M5: POI列表展示 | PoiListWidget | M4 |
| Day 23 AM | M5: 收藏/分享功能 | 交互功能 | M4 |
| Day 23 PM | M5: 离线包下载UI | DownloadUI | M4 |
| Day 24 AM | **【里程碑】M5联调** | 联调通过 | 全员 |
| Day 24 PM | M6: 地图SDK集成 | AMapService | M2 |
| Day 25 AM | M6: 地图显示组件 | MapView | M6 |
| Day 25 PM | M6: 轨迹绘制 | TrailPolyline | M6 |
| Day 26 AM | M6: POI标记显示 | PoiMarkers | M6 |
| Day 26 PM | M6: 定位功能 | LocationLayer | M6 |
| Day 27 AM | M6: 地图与详情联动 | 交互优化 | M6 |
| Day 27 PM | **【里程碑】M6联调** | 联调通过 | 全员 |
| Day 28 AM | M7: 离线地图下载 | OfflineDownload | M6 |
| Day 28 PM | M7: 离线地图存储 | OfflineStorage | M6 |

---

### Week 7-8: 测试上线（详见原任务拆分文档）

---

## 2. 技术依赖和接口约定

### 2.1 前后端接口依赖矩阵

```
┌──────────────┬─────────────────────────────────────────────────────────────┐
│ 移动端任务   │ 依赖的后端接口                                               │
├──────────────┼─────────────────────────────────────────────────────────────┤
│ M3 用户模块  │ B3: /auth/*, /users/*                                       │
│ M4 发现列表  │ B4: /trails, /trails/nearby                                 │
│ M5 路线详情  │ B4: /trails/:id, /trails/:id/pois, /trails/:id/favorite    │
│ M6 地图集成  │ B6: 地图配置接口, B4: 轨迹数据                               │
│ M7 离线地图  │ B4: /trails/:id/offline                                     │
│ M8 导航基础  │ B4: GPX数据, M7: 离线地图                                   │
│ M9 导航跟随  │ 客户端算法, M8: 基础导航                                    │
└──────────────┴─────────────────────────────────────────────────────────────┘
```

### 2.2 关键接口约定

#### 2.2.1 路线列表接口 (M4依赖)
```
GET /api/v1/trails

请求参数:
- lat/lng: 当前位置坐标（可选，用于附近排序）
- distance: 搜索半径km（可选，默认50）
- difficulty: 难度筛选，逗号分隔（可选）
- tags: 标签筛选（可选）
- sort: 排序方式，默认distance（可选值: distance, popularity, difficulty）
- page/limit: 分页参数

响应字段:
{
  "success": true,
  "data": [{
    "id": "string",
    "name": "string",
    "coverImage": "string",
    "distanceKm": number,
    "durationMin": number,
    "difficulty": "easy|moderate|hard",
    "tags": ["string"],
    "location": { "city": "string", "district": "string" },
    "isFavorite": boolean,
    "offlineStatus": "none|downloaded|expired"
  }],
  "meta": { "page", "limit", "total", "totalPages" }
}

交付时间: Week 4 Day 11
```

#### 2.2.2 路线详情接口 (M5依赖)
```
GET /api/v1/trails/:id

响应字段:
{
  "success": true,
  "data": {
    "id": "string",
    "name": "string",
    "description": "string",
    "distanceKm": number,
    "durationMin": number,
    "elevationGainM": number,
    "difficulty": "string",
    "tags": ["string"],
    "coverImages": ["string"],
    "safetyInfo": { "femaleFriendly": boolean, "signalCoverage": "string" },
    "location": { "startPoint": { "lat", "lng", "address" } },
    "pois": [{ "id", "name", "type", "lat", "lng", "sequence" }],
    "trackPreview": { "elevationProfile": [], "bounds": {} },
    "offlinePackage": { "sizeMb", "minZoom", "maxZoom", "expiresAt" }
  }
}

交付时间: Week 4 Day 12
```

#### 2.2.3 离线包下载接口 (M7依赖)
```
GET /api/v1/trails/:id/offline

响应字段:
{
  "success": true,
  "data": {
    "trailId": "string",
    "version": "string",
    "files": {
      "mapData": { "url": "string", "sizeBytes": number, "checksum": "string" },
      "trailData": { "url": "string", "sizeBytes": number },
      "poiData": { "url": "string", "sizeBytes": number },
      "images": [{ "url": "string", "sizeBytes": number }]
    },
    "mapConfig": {
      "bounds": { "north", "south", "east", "west" },
      "minZoom": number,
      "maxZoom": number,
      "center": { "lat", "lng" }
    },
    "expiresAt": "ISO8601"
  }
}

交付时间: Week 5 Day 17
```

#### 2.2.4 微信登录接口 (M3依赖)
```
POST /api/v1/auth/wechat

请求体:
{ "code": "string" }

响应字段:
{
  "success": true,
  "data": {
    "user": { "id", "nickname", "avatarUrl", "phone" },
    "tokens": { "accessToken": "string", "refreshToken": "string" },
    "isNewUser": boolean
  }
}

交付时间: Week 3 Day 6
```

### 2.3 数据模型约定

#### 2.3.1 路线数据模型
```dart
// 移动端 Trail Model (与后端对齐)
class Trail {
  final String id;
  final String name;
  final String? description;
  final double distanceKm;
  final int durationMin;
  final double elevationGainM;
  final TrailDifficulty difficulty;
  final List<String> tags;
  final List<String> coverImages;
  final SafetyInfo safetyInfo;
  final LocationInfo location;
  final List<Poi> pois;
  final TrackPreview trackPreview;
  final OfflinePackageInfo? offlinePackage;
  final bool isFavorite;
  final OfflineStatus offlineStatus;
}
```

#### 2.3.2 导航状态模型
```dart
// 导航状态 (M8/M9)
class NavigationState {
  final NavigationStatus status; // idle, navigating, paused, completed
  final Trail? trail;
  final LatLng? currentPosition;
  final LatLng? matchedPosition;
  final double progress; // 0-1
  final double? remainingDistance;
  final DateTime? eta;
  final double? deviation; // 偏航距离
  final List<VoiceInstruction> pendingInstructions;
}
```

### 2.4 错误码约定

```
┌──────────┬────────────────────────────────────────────┐
│ 错误码   │ 说明                                       │
├──────────┼────────────────────────────────────────────┤
│ 400001   │ 参数错误                                   │
│ 400002   │ 路线不存在                                 │
│ 401001   │ Token过期                                  │
│ 401002   │ Token无效                                  │
│ 403001   │ 无权限访问                                 │
│ 404001   │ 资源不存在                                 │
│ 429001   │ 请求过于频繁                               │
│ 500001   │ 服务器内部错误                             │
│ 500002   │ 第三方服务错误(微信/高德)                   │
└──────────┴────────────────────────────────────────────┘
```

---

## 3. 关键路径和风险点

### 3.1 关键路径分析

```
关键路径 1 (用户功能): B1 → B2 → B3 → M3
时间: 2+2+3+4 = 11天 (Week 2-3)
风险: 低

关键路径 2 (发现功能): B1 → B2 → B4 → M4 → M5
时间: 2+2+4+4+4 = 16天 (Week 2-5)
风险: 中

关键路径 3 (地图导航): B1 → B6 → M6 → M7 → M8 → M9
时间: 2+3+5+5+4+5 = 24天 (Week 2-6)
风险: 高 ⚠️

关键路径 4 (整体交付): B1 → B2 → B4 → B7 → B8 + M1 → M6 → M10
时间: 后端23天 + 移动端27天 = 6周
风险: 中
```

### 3.2 风险点识别与应对

#### 高风险项

| 风险ID | 风险描述 | 概率 | 影响 | 应对措施 |
|--------|----------|------|------|----------|
| R1 | **高德SDK离线地图功能不稳定** | 中 | 高 | 1. Week 2 完成技术预研验证 2. 准备Mapbox备选方案 3. 降低离线地图精度要求 |
| R2 | **GPX轨迹匹配算法精度不足** | 中 | 高 | 1. 提前测试多种匹配算法 2. 设置容错阈值(30m内算正常) 3. 人工标注关键轨迹点 |
| R3 | **数据采集进度延迟** | 中 | 高 | 1. 提前启动D1路线筛选 2. 优先完成杭州本地路线 3. 外包部分城市采集 |
| R4 | **微信登录审核延迟** | 低 | 中 | 1. 提前申请微信开放平台账号 2. 准备测试号先行开发 3. 准备手机号登录备选 |

#### 中风险项

| 风险ID | 风险描述 | 概率 | 影响 | 应对措施 |
|--------|----------|------|------|----------|
| R5 | 后端API性能不达标 | 中 | 中 | 1. Week 5 预留优化时间 2. 提前设计缓存策略 3. 数据库索引优化 |
| R6 | 移动端地图渲染卡顿 | 中 | 中 | 1. 轨迹点简化算法 2. 分级加载策略 3. 内存管理优化 |
| R7 | 离线包体积过大 | 中 | 中 | 1. 限制下载区域(路线周边500m) 2. 限制缩放级别(14-16级) 3. 压缩图片资源 |
| R8 | 人员生病/请假 | 低 | 高 | 1. 关键任务双人backup 2. 文档完善 3. 预留缓冲时间 |

### 3.3 缓冲时间分配

```
总缓冲: 6天 (Week 6 Day 22-27)

分配策略:
- Day 22-23: 后端Bug修复缓冲 (2天)
- Day 24-25: 移动端Bug修复缓冲 (2天)
- Day 26-27: 联调问题缓冲 (2天)

如果前期进度正常，缓冲时间可用于:
- M9 导航跟随功能增强
- 性能优化
- 用户体验优化
```

### 3.4 降级方案

#### 场景1: 离线地图功能受阻
```
Plan A: 完整离线地图 (M7完整实现)
Plan B: 简化离线地图 (仅缓存路线数据和图片，地图在线加载)
Plan C: 仅在线模式 (MVP核心功能仍可用)

切换条件: Week 4结束时M6进度<50%
```

#### 场景2: 导航跟随功能受阻
```
Plan A: 完整导航 (轨迹跟随+偏航检测+语音播报)
Plan B: 简化导航 (仅轨迹显示+当前位置)
Plan C: 仅地图查看 (MVP核心功能仍可用)

切换条件: Week 5结束时M8进度<70%
```

#### 场景3: 数据采集不足50条
```
Plan A: 50条精品路线
Plan B: 30条核心城市路线
Plan C: 20条杭州本地路线 + 虚拟数据

切换条件: Week 5结束时D4进度<60%
```

---

## 4. 与 Product 团队的协作节点

### 4.1 固定协作会议

| 会议 | 时间 | 参与方 | 议题 |
|------|------|--------|------|
| 周会 | 每周五 16:00 | 全员 | 进度同步、问题对齐、下周计划 |
| 站会 | 每日 10:00 | 开发团队 | 昨日完成、今日计划、阻塞问题 |
| 设计评审 | 按需 | PM+设计+开发 | UI/UX评审、交互确认 |

### 4.2 关键协作节点

```
Week 2 Day 5: 【架构评审】
- 参与: 全员
- 产出: 技术架构确认、接口规范确认
- 阻塞风险: 高

Week 3 Day 17: 【M3用户模块验收】
- 参与: PM + 后端 + 移动端
- 产出: 登录/注册/个人中心验收通过
- 阻塞风险: 中

Week 4 Day 14: 【M2组件库评审】
- 参与: 设计 + 移动端
- 产出: UI组件规范确认
- 阻塞风险: 低

Week 5 Day 20: 【M4/M5发现模块验收】
- 参与: PM + 全员
- 产出: 路线列表/详情功能验收
- 阻塞风险: 中

Week 6 Day 24: 【M6地图模块验收】
- 参与: PM + 全员
- 产出: 地图显示/定位功能验收
- 阻塞风险: 高

Week 6 Day 27: 【M1开发交付】
- 参与: 全员
- 产出: 开发阶段交付、进入测试阶段
- 阻塞风险: 高
```

### 4.3 需求变更流程

```
1. 变更申请: PM 提交变更申请单
2. 影响评估: 开发团队评估时间和风险
3. 决策会议: 全员评估是否接受变更
4. 计划调整: 更新排期文档
5. 执行变更: 按新计划执行

变更冻结点: Week 5结束 (进入测试阶段后原则上不接受功能变更)
```

### 4.4 交付物检查清单

#### 后端交付物 (Week 6 Day 21)
- [ ] API服务部署文档
- [ ] Swagger API文档
- [ ] 数据库迁移脚本
- [ ] 后台管理系统
- [ ] 单元测试报告
- [ ] 接口性能测试报告

#### 移动端交付物 (Week 6 Day 27)
- [ ] iOS/Android安装包
- [ ] 代码仓库
- [ ] 组件库文档
- [ ] 集成测试报告
- [ ] 性能测试报告
- [ ] 用户操作手册

#### 协作文档
- [ ] 接口变更日志 (实时更新)
- [ ] 每日站会纪要
- [ ] 问题跟踪表
- [ ] 风险登记册

---

## 5. 附录

### 5.1 开发环境配置

```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  postgres:
    image: postgis/postgis:15-3.3
    ports: ["5432:5432"]
    environment:
      POSTGRES_DB: shanjing_dev
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev123
  
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
  
  minio:
    image: minio/minio
    ports: ["9000:9000", "9001:9001"]
    command: server /data --console-address ":9001"
```

### 5.2 分支管理策略

```
main: 生产分支
  ↓
staging: 预发布分支
  ↓
develop: 开发主分支
  ↓
feature/B1: 功能分支
feature/M3: 功能分支
hotfix/*: 热修复分支
```

### 5.3 代码审查规范

- 所有代码必须通过PR合并
- 至少1人审查通过
- CI检查通过(单元测试、代码规范)
- 关联Issue/Ticket

---

**文档维护**: 本文档每周五更新，记录实际进度与计划偏差
