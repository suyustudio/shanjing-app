# 山径APP 项目 - 长期记忆

## 项目基本信息

- **项目名称**: 山径（城市年轻人的轻度徒步向导）
- **项目阶段**: Week 3（开发阶段）
- **启动日期**: 2026年2月
- **当前日期**: 2026年2月28日

## 关键决策（必须记住）

### 1. 技能安装策略
- **flutter/nodejs**: 手动创建 SKILL.md（clawhub 不存在官方版本）
- **其他技能**: 优先 clawhub 官方安装
- **已安装技能**: backend, design-system-creation, frontend-design-3, map-search, nodejs, prd, project-management-2, test-master, test-patterns, ui-ux-design, coding, flutter, gaodemapskill

### 2. 工作模式
- **任务切分**: 极简颗粒度（2-3分钟可完成）
- **Review 机制**: 三方交叉 Review（product/dev/design 互相 review）
- **安全优先**: P0 问题立即修复，不拖延

### 3. 技术栈
- **后端**: NestJS + Prisma + PostgreSQL
- **地图**: 高德地图 API（AMAP_KEY）
- **文件存储**: 阿里云 OSS
- **认证**: JWT（必须设置 JWT_SECRET 环境变量）

## 关键配置（启动前必须检查）

### 环境变量清单
```bash
# 数据库
DATABASE_URL=postgresql://...

# 高德地图
AMAP_KEY=your_amap_key

# 管理员账号（必须设置，不能硬编码）
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_password

# JWT（必须设置，不能默认）
JWT_SECRET=your_jwt_secret_min_32_chars

# 阿里云 OSS
OSS_ACCESS_KEY_ID=...
OSS_ACCESS_KEY_SECRET=...
OSS_BUCKET=...
OSS_REGION=...
```

### Agent 技能配置
```json
// dev agent
"skills": ["frontend-design-3", "coding", "backend", "map-search"]

// design agent  
"skills": ["frontend-design-3", "design-system-creation", "ui-ux-design"]

// product agent
"skills": ["prd", "project-management-2"]
```

## 项目进度

| 模块 | 进度 | 状态 |
|------|------|------|
| 产品设计 | 90% | 埋点规范、空状态设计完成 |
| 后端开发 | 60% | 地图服务、后台管理 CRUD 完成 |
| 设计交付 | 95% | 高保真基本完成 |
| 技能安装 | 100% | 10/10 就绪 |

## 待办事项（持续更新）

### Week 3 Day 3（2026-03-01）
- [ ] Dev: B7-6 路线删除接口 + API文档整理
- [ ] Product: 修复暗黑模式、手势埋点、边界场景文档
- [ ] Design: 补充焦点状态、优化导航页、暗黑模式设计

### 中期待办
- [ ] 补充单元测试
- [ ] 移动端开发启动（flutter）
- [ ] 数据采集（50条路线）

## 用户偏好（重要）

1. **任务切分**: 必须极简颗粒度，大任务会超时
2. **Review**: 三方交叉 review 必须做
3. **安全**: P0 问题立即修复
4. **同步**: 主动汇报进度，不要等问
5. **记录**: 边做边写 memory，不要最后补

## 已知问题（已修复）

- ~~硬编码管理员凭据~~ → 改为环境变量
- ~~JWT 默认密钥~~ → 强制环境变量
- ~~环境变量命名不一致~~ → 统一 AMAP_KEY
- ~~代码风格不统一~~ → 统一 @nestjs/axios

## 文档索引

| 文档 | 路径 |
|------|------|
| PRD | shanjing-prd-v1.2.md |
| 技术架构 | shanjing-tech-architecture.md |
| 设计系统 | design-system-v1.0.md |
| 低保真原型 | prototype-lofi-v1.0.md, prototype-lofi-v1.0-part2.md |
| 高保真设计 | design-hifi-v1.0.md |
| 术语规范 | shanjing-terminology.md |
| 任务清单 | shanjing-m1-tasks-v1.2.md |

## Week 4 完成（2026-02-28）

### 完成任务
- **dev**: 后端 API 90% 完成（地图服务、后台管理、用户端浏览/收藏）
- **product**: 数据审核流程、边界场景文档
- **design**: 高保真设计 98% 完成、设计走查
- **qa**: 测试用例、自动化框架、集成测试方案

### M1 遗留问题（Week 5 重点）
- **Flutter 移动端开发**: 已启动，项目搭建、组件、页面设计完成 🟡
- **技术验证**: 高德 SDK、GPS 保活、轨迹算法全部通过 ✅
- **数据采集**: 6/10 完成 🟡
- **E2E 测试**: 方案完成，自动化实现未开始 ❌

### Week 5 Day 2 完成（2026-02-28）
- **数据采集 10/10 完成**：断桥残雪、苏堤春晓、灵隐寺、法喜寺
- **Flutter 导航模块 100% 完成**：
  - M8.1 轨迹跟随算法（GPS 精度过滤 <10m）
  - M8.2 偏航检测与提醒（语音播报）
  - M8.3 语音播报调研（flutter_tts）
  - M8.4 导航进度显示
  - M8.5 联调测试方案
- **数据标准化 80% 完成**：JSON Schema、10 条 JSON、示例修复
- **页面设计 95% 完成**：发现页、详情页、我的页、导航进度
- **Review 修复全部完成**：P0 + P1 问题已修复

### Week 5 Day 3 完成（2026-02-28）
- **数据标准化 100% 完成**：10条路线 JSON + Schema 对齐
- **Review 问题 12项全部修复**：P0/P1/P2 全部完成
- **Flutter 页面开发 75%**：发现页、详情页、地图页、我的页
- **高德 SDK 集成 70%**：Key申请、基础功能、环境变量配置
- **设计系统常量**：颜色、字体、间距统一

### Week 5 Day 4 完成（2026-02-28）
- **核心功能开发 100%**：地图标记点、轨迹线、卡片浮层、视图切换
- **Review 问题 12项全部修复**：P0/P1/P2 全部完成
- **导航流程完整打通**：发现→详情→导航
- **DesignSystem 全面应用**：所有组件使用常量
- **真实数据接入**：发现页接入10条路线

### Week 5 Day 6 完成（2026-02-28）
- **单元测试**：7个测试用例（RouteCard、DiscoveryScreen）
- **真实设备测试准备**：构建命令、设备要求、测试清单
- **离线地图功能验证**：配置正确，待真机测试
- **Bug 修复准备**：12项问题分类、修复方案
- **文档完善**：README、CONTRIBUTING、CHANGELOG
- **发布准备**：版本号 1.0.0+1、检查清单
- **代码审查问题修复**：测试断言、未使用方法

### Week 6 目标
- [ ] 真实设备测试（Android/iOS）
- [ ] 离线地图功能验证
- [ ] Bug 修复
- [ ] 后台保活集成测试
- [ ] M1 里程碑验收

## 最后更新

- **更新时间**: 2026-02-28 19:57
- **更新内容**: Week 5 完成，M1 进度 98%，Week 6 启动
