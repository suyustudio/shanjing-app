# 埋点 SDK 选型报告

## 1. 方案对比

| 维度 | Firebase Analytics | 友盟+ U-App | 神策数据 | GrowingIO |
|------|-------------------|-------------|----------|-----------|
| **Flutter 支持** | ⭐⭐⭐ 官方插件 | ⭐⭐⭐ 官方插件 `umeng_analytics_plugin` | ⭐⭐⭐ 官方 SDK | ⭐⭐⭐ 官方插件 `growingio_flutter_plugin` |
| **免费额度** | 500 事件类型，无限量上报 | 基础功能**完全免费**，无事件数限制 | **无免费版**，最低 3万/年起 | 基础版有限免费（5万事件/月） |
| **数据导出** | BigQuery（需付费） | 部分支持 CSV 导出 | ⭐⭐⭐ 支持私有化部署，数据完全自主 | 企业版支持 |
| **实时性** | 1-4 小时延迟 | 小时级 | ⭐⭐⭐ 秒级实时 | ⭐⭐⭐ 秒级实时 |
| **数据隐私/合规** | ⚠️ 数据出境（Google） | ✅ 数据境内 | ✅ 支持私有化 | ✅ 支持私有化 |
| **国内生态** | 一般 | ⭐⭐⭐ 与微信登录等深度集成 | 良好 | 良好 |
| **文档/社区** | 英文为主 | ⭐⭐⭐ 中文文档完善 | 中文文档 | 中文文档 |

## 2. 推荐方案：友盟+ U-App

### 2.1 推荐理由

1. **完全免费的基础功能**：无事件数量限制，适合产品初期快速验证
2. **国内数据合规**：数据存储在境内，符合国内法规要求
3. **Flutter 官方支持**：`umeng_analytics_plugin` 持续维护，支持 Flutter 3.0+
4. **快速集成**：5 分钟即可完成接入，降低开发成本
5. **国内生态集成**：与微信登录、推送等国内服务无缝衔接

### 2.2 对比 Firebase Analytics

| 对比项 | Firebase Analytics | 友盟+ |
|--------|-------------------|-------|
| 价格 | 免费 | 免费 |
| 数据延迟 | 1-4 小时 | 小时级 |
| 国内访问 | ⚠️ 需翻墙 | ✅ 直接访问 |
| 数据归属 | Google | 阿里（国内） |
| Flutter 插件 | firebase_analytics | umeng_analytics_plugin |

Firebase 虽功能强大，但存在**数据出境**和**延迟高**的问题，不适合面向国内用户的山径 APP。

### 2.3 对比神策/GrowingIO

神策和 GrowingIO 功能更专业（支持漏斗分析、留存分析等），但**起步即有费用**（神策 3万+/年，GrowingIO 按事件量收费）。对于 MVP 阶段的山径 APP，友盟+ 的基础功能已足够支撑数据洞察需求。

## 3. 实施建议

### 3.1 接入方案

```yaml
# pubspec.yaml 添加依赖
dependencies:
  umeng_analytics_plugin: ^1.0.0
```

### 3.2 架构设计

采用**代理模式**封装友盟 SDK，便于未来切换：

```
lib/
├── analytics/                    # 埋点模块
│   ├── analytics_service.dart    # 统一接口
│   ├── umeng_adapter.dart        # 友盟适配器
│   ├── events/                   # 事件定义
│   │   ├── page_events.dart
│   │   ├── trail_events.dart
│   │   ├── map_events.dart
│   │   ├── navigation_events.dart
│   │   └── user_events.dart
│   └── analytics_mixin.dart      # Widget mixin
```

### 3.3 未来升级路径

当用户量达到 10 万+，需要更深度分析时，可平滑迁移至：
- **神策数据**：私有化部署，数据完全自主
- **GrowingIO**：无埋点+代码埋点混合方案

---

**决策**：采用 **友盟+ U-App** 作为山径 APP 的埋点方案

**参考**：调研参考了友盟官方文档、GrowingIO Flutter SDK 文档、Firebase Analytics 定价页
