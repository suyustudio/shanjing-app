# 山径APP - M3 分享功能规范

> **文档版本**: v1.0  
> **制定日期**: 2026-03-14  
> **文档状态**: 已完成  
> **对应阶段**: M3 分享功能完善

---

## 1. 分享功能概述

### 1.1 目标
提供一键生成精美分享内容的能力，让用户能够轻松将徒步体验分享到各社交平台，同时实现品牌传播和新用户引流。

### 1.2 分享场景定义

```
山径APP分享场景
├── 📍 路线分享
│   ├── 路线详情页分享
│   ├── 路线海报分享
│   └── 路线链接分享
├── 🏆 成就分享
│   ├── 徒步完成分享
│   ├── 里程碑分享
│   └── 个人数据分享
├── 📤 实时分享
│   ├── 行程分享（导航中）
│   └── 位置共享
└── 📱 内容分享
    ├── 社区动态分享
    └── 用户生成内容分享
```

### 1.3 分享场景优先级

| 场景 | 优先级 | 适用阶段 | 转化率目标 |
|------|--------|----------|------------|
| **路线海报分享** | P0 | M1 | >30% 用户分享 |
| **徒步完成分享** | P0 | M2 | >50% 完成用户分享 |
| **行程实时分享** | P1 | M1 | >20% 导航用户使用 |
| **社区动态分享** | P1 | M2 | >40% 发布用户分享 |
| **里程碑分享** | P2 | M2 | >10% 用户触发 |

---

## 2. 分享场景定义

### 2.1 路线分享

#### 2.1.1 路线详情页分享

**触发位置**: 路线详情页右上角分享按钮

**分享内容选项**:

| 选项 | 说明 | 适用平台 |
|------|------|----------|
| **生成海报** | 自动生成精美路线卡片 | 朋友圈、小红书 |
| **分享链接** | 小程序/H5链接 | 微信聊天、群聊 |
| **复制链接** | 复制URL | 任意平台 |

**海报内容结构**:

```
┌─────────────────────────────┐
│  [路线封面图]                 │
│  九溪十八涧 · 杭州            │
│                             │
│  📏 5.2km  ⏱ 2h  ⛰ 150m    │
│  难度: ⭐⭐  风景: ⭐⭐⭐⭐⭐  │
│                             │
│  "溪水潺潺，绿意盎然"         │
│                             │
│  [二维码] 扫码查看完整路线    │
│  山径APP · 发现身边的徒步路线 │
└─────────────────────────────┘
```

#### 2.1.2 路线分享流程

```
用户点击分享按钮
        │
        ▼
┌─────────────────┐
│ 弹出分享选项    │
│ - 生成海报      │
│ - 分享链接      │
│ - 复制链接      │
└────────┬────────┘
         │
    ┌────┼────┐
    │    │    │
    ▼    ▼    ▼
┌─────┐┌─────┐┌─────┐
│海报 ││链接 ││复制 │
│生成 ││分享 ││链接 │
└──┬──┘└──┬──┘└──┬──┘
   │      │      │
   ▼      ▼      ▼
┌─────┐┌─────┐┌─────┐
│调起 ││调起 ││提示 │
│分享 ││分享 ││复制 │
│面板 ││面板 ││成功 │
└─────┘└─────┘└─────┘
```

### 2.2 成就分享

#### 2.2.1 徒步完成分享

**触发时机**: 用户结束导航并保存记录后

**分享内容**:

```
┌─────────────────────────────┐
│                             │
│      🎉 完成徒步！           │
│                             │
│  [轨迹地图缩略图]             │
│                             │
│  ┌─────────────────────┐   │
│  │  5.2km              │   │
│  │  距离               │   │
│  ├─────────────────────┤   │
│  │  2:15:30            │   │
│  │  用时               │   │
│  ├─────────────────────┤   │
│  │  156m               │   │
│  │  爬升               │   │
│  ├─────────────────────┤   │
│  │  8,520              │   │
│  │  步数               │   │
│  └─────────────────────┘   │
│                             │
│  "又是被大自然治愈的一天"    │
│                             │
│  [二维码]                   │
│  山径APP                    │
└─────────────────────────────┘
```

**自动文案模板**:

| 场景 | 文案 |
|------|------|
| 首次完成 | "第一次徒步，就遇见了这么美的风景 🌲" |
| 突破记录 | "刷新个人记录！每一步都算数 💪" |
| 休闲路线 | "又是被大自然治愈的一天 ✨" |
| 挑战路线 | "登顶成功！所有的坚持都值得 ⛰️" |
| 晨间徒步 | "早起的人，先看世界 🌅" |
| 夜间徒步 | "星空下的徒步，别样浪漫 🌌" |

#### 2.2.2 里程碑分享

**触发条件**:

| 里程碑 | 条件 | 分享内容 |
|--------|------|----------|
| 首徒纪念 | 完成第1次徒步 | "开启徒步之旅 🎉" |
| 十徒纪念 | 完成第10次徒步 | "10次徒步达成 🏆" |
| 百公里 | 累计100km | "累计徒步100km 🚶‍♀️" |
| 年度目标 | 完成年度目标 | "年度目标达成 ✨" |

### 2.3 实时分享（行程分享）

#### 2.3.1 导航中行程分享

**触发位置**: 导航页面SOS按钮旁边

**分享内容**:

```
┌─────────────────────────────┐
│  📍 我正在徒步中              │
│                             │
│  [实时位置地图]               │
│  当前位置: 九溪烟树           │
│  已走: 3.2km / 剩余: 2.0km   │
│  预计到达: 16:30             │
│                             │
│  [二维码] 实时查看我的位置    │
│  （需安装山径APP）            │
└─────────────────────────────┘
```

**分享选项**:

| 选项 | 说明 |
|------|------|
| 分享实时位置 | 对方可查看实时位置（需APP） |
| 分享预计到达 | 发送ETA给联系人 |
| 分享行程卡片 | 静态卡片，包含路线信息 |

#### 2.3.2 位置上报策略

| 场景 | 上报频率 | 精度要求 | 备注 |
|------|----------|----------|------|
| 实时分享中 | 30秒 | 10米 | 持续上报直到关闭 |
| SOS触发 | 立即+5分钟间隔 | 5米 | 直到用户取消 |
| 行程结束 | 停止上报 | - | 清除分享状态 |

---

## 3. 分享内容规范

### 3.1 海报生成规范

#### 3.1.1 海报规格

| 平台 | 尺寸 | 比例 | 格式 | 文件大小 |
|------|------|------|------|----------|
| 朋友圈 | 1080x1920 | 9:16 | PNG | < 2MB |
| 小红书 | 1080x1440 | 3:4 | PNG | < 2MB |
| 微信聊天 | 1080x1080 | 1:1 | PNG | < 1MB |
| 微博 | 1080x1920 | 9:16 | PNG | < 2MB |

#### 3.1.2 海报设计系统

**色彩规范**:

| 用途 | 颜色 | 色值 |
|------|------|------|
| 背景色 | 森林绿 | `#2D5A3D` |
| 主文字 | 纯白 | `#FFFFFF` |
| 次要文字 | 浅灰 | `#CCCCCC` |
| 强调色 | 落日橙 | `#E8913A` |
| 数据高亮 | 薄荷绿 | `#7CB342` |

**字体规范**:

| 用途 | 字体 | 字号 | 字重 |
|------|------|------|------|
| 大标题 | 思源宋体 | 72px | Bold |
| 副标题 | 苹方 | 36px | Medium |
| 数据数字 | DIN Alternate | 48px | Bold |
| 标签文字 | 苹方 | 28px | Regular |
| 品牌文案 | 苹方 | 24px | Regular |

#### 3.1.3 海报模板类型

| 模板 | 适用场景 | 设计特点 |
|------|----------|----------|
| **简约数据** | 完成分享 | 突出数据，简洁大气 |
| **风景图文** | 路线分享 | 大图为主，文字点缀 |
| **心情记录** | 社区动态 | 情绪化文案，标签化 |
| **里程碑** | 成就分享 | 勋章元素，庆祝感 |

### 3.2 链接分享规范

#### 3.2.1 链接结构

```
https://shanjing.app/s/{short_code}

示例:
https://shanjing.app/s/a3x9k2
```

#### 3.2.2 链接类型

| 类型 | 路径 | 说明 |
|------|------|------|
| 路线分享 | /r/{route_id} | 路线详情页 |
| 动态分享 | /p/{post_id} | 社区动态页 |
| 活动分享 | /e/{event_id} | 活动详情页 |
| 邀请链接 | /i/{invite_code} | 邀请注册页 |

#### 3.2.3 H5落地页规范

**页面结构**:

```
┌─────────────────────────────┐
│  [封面大图]                   │
│                             │
│  路线名称                     │
│  📍 地点  ·  ⭐ 难度          │
│                             │
│  ┌─────────────────────┐   │
│  │ 基础信息卡片         │   │
│  │ - 距离/时长/爬升     │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 轨迹预览图           │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 📲 下载山径APP       │   │
│  │    查看完整路线      │   │ ← CTA按钮
│  └─────────────────────┘   │
│                             │
└─────────────────────────────┘
```

### 3.3 小程序分享规范

#### 3.3.1 小程序分享卡片

**微信分享卡片结构**:

```json
{
  "title": "九溪十八涧 · 杭州轻徒步路线",
  "desc": "5.2km · 约2小时 · 难度⭐⭐",
  "imageUrl": "https://cdn.shanjing.app/share/r001.jpg",
  "path": "/pages/route/detail?id=R001"
}
```

**卡片尺寸**:
- 缩略图: 500x400px
- 标题: 最多两行，超过省略
- 描述: 单行，超过省略

---

## 4. 分享埋点事件补充

### 4.1 分享事件定义

#### 4.1.1 分享触发事件

| 事件名 | 触发时机 | 事件参数 |
|--------|----------|----------|
| `share_panel_open` | 打开分享面板 | `source_page`, `content_type` |
| `share_method_select` | 选择分享方式 | `method` (poster/link/copy) |
| `share_target_select` | 选择分享目标 | `target` (wechat/moments/copy) |

#### 4.1.2 分享内容事件

| 事件名 | 触发时机 | 事件参数 |
|--------|----------|----------|
| `share_content_generated` | 分享内容生成完成 | `content_type`, `template_id`, `generation_time` |
| `share_poster_generated` | 海报生成完成 | `poster_type`, `size`, `generation_time` |
| `share_link_copied` | 链接复制成功 | `link_type`, `short_code` |

#### 4.1.3 分享结果事件

| 事件名 | 触发时机 | 事件参数 |
|--------|----------|----------|
| `share_success` | 分享成功（调起成功） | `platform`, `content_type`, `share_target` |
| `share_cancel` | 用户取消分享 | `platform`, `content_type`, `stage` |
| `share_fail` | 分享失败 | `platform`, `content_type`, `error_code` |
| `share_received` | 接收到分享（被分享方） | `platform`, `content_type`, `referrer` |

### 4.2 分享效果追踪

| 事件名 | 触发时机 | 事件参数 |
|--------|----------|----------|
| `share_link_opened` | 分享链接被打开 | `short_code`, `source`, `utm_params` |
| `share_link_install` | 通过分享链接安装 | `short_code`, `referrer_id`, `install_source` |
| `share_link_register` | 通过分享链接注册 | `short_code`, `referrer_id`, `conversion_type` |

### 4.3 埋点参数规范

```typescript
interface ShareEventParams {
  // 内容类型
  content_type: 'route' | 'achievement' | 'trip' | 'post' | 'milestone';
  
  // 内容ID
  content_id: string;
  
  // 分享平台
  platform: 'wechat_chat' | 'wechat_moments' | 'weibo' | 'xiaohongshu' | 'copy';
  
  // 分享方式
  method: 'poster' | 'link' | 'mini_program' | 'text';
  
  // 来源页面
  source_page: string;
  
  // 海报模板（如果是海报分享）
  template_id?: string;
  
  // 生成耗时（ms）
  generation_time?: number;
}
```

### 4.4 埋点实施代码示例

```dart
class ShareAnalytics {
  // 分享面板打开
  static void trackSharePanelOpen(String contentType, String contentId) {
    Analytics.trackEvent('share_panel_open', {
      'content_type': contentType,
      'content_id': contentId,
      'source_page': Analytics.currentPage,
    });
  }
  
  // 选择分享方式
  static void trackShareMethodSelect(String method) {
    Analytics.trackEvent('share_method_select', {
      'method': method,
    });
  }
  
  // 海报生成完成
  static void trackPosterGenerated(String posterType, int generationTimeMs) {
    Analytics.trackEvent('share_poster_generated', {
      'poster_type': posterType,
      'generation_time': generationTimeMs,
    });
  }
  
  // 分享成功
  static void trackShareSuccess(String platform, String contentType, String contentId) {
    Analytics.trackEvent('share_success', {
      'platform': platform,
      'content_type': contentType,
      'content_id': contentId,
    });
  }
  
  // 分享失败
  static void trackShareFail(String platform, String errorCode, String errorMsg) {
    Analytics.trackEvent('share_fail', {
      'platform': platform,
      'error_code': errorCode,
      'error_message': errorMsg,
    });
  }
}

// 使用示例
void onShareButtonPressed(Route route) {
  ShareAnalytics.trackSharePanelOpen('route', route.id);
  
  showShareBottomSheet(
    onPosterSelected: () async {
      ShareAnalytics.trackShareMethodSelect('poster');
      
      final startTime = DateTime.now();
      final poster = await generatePoster(route);
      final generationTime = DateTime.now().difference(startTime).inMilliseconds;
      
      ShareAnalytics.trackPosterGenerated('route_detail', generationTime);
      
      await shareToWechat(poster);
      ShareAnalytics.trackShareSuccess('wechat_chat', 'route', route.id);
    },
    onLinkSelected: () async {
      ShareAnalytics.trackShareMethodSelect('link');
      
      final link = await generateShareLink(route);
      await Clipboard.setData(ClipboardData(text: link));
      
      ShareAnalytics.trackShareSuccess('copy', 'route', route.id);
    },
  );
}
```

---

## 5. 分享功能验收标准

### 5.1 功能验收

| 验收项 | 标准 | 优先级 |
|--------|------|--------|
| 海报生成 | 生成时间 < 3秒，图片清晰 | P0 |
| 分享调起 | 100% 调起目标平台 | P0 |
| 链接可用 | 短链接 100% 可访问 | P0 |
| H5落地页 | 3秒内完成首屏渲染 | P0 |
| 小程序卡片 | 卡片显示完整，点击可跳转 | P0 |

### 5.2 性能验收

| 指标 | 目标值 | 测试方法 |
|------|--------|----------|
| 海报生成时间 | < 3秒 | 10次平均 |
| 图片压缩后大小 | < 2MB | 文件检查 |
| 分享面板打开 | < 300ms | 计时测试 |
| 链接跳转延迟 | < 1秒 | 网络测试 |

### 5.3 数据验收

| 指标 | 目标值 | 统计周期 |
|------|--------|----------|
| 分享成功率 | > 95% | 每日 |
| 海报生成成功率 | > 99% | 每日 |
| 链接打开率 | > 30% | 每周 |
| 分享带来安装率 | > 5% | 每月 |

---

## 6. 附录

### 6.1 分享文案库

#### 路线分享文案

```
标题: {route_name} · {city}
描述: {distance}km · 约{duration}小时 · 难度{difficulty}

备选描述:
- "这条路线太美了，推荐给你 🌲"
- "周末去这里徒步，不会错 👣"
- " hidden gem，私藏的徒步路线 ✨"
```

#### 完成分享文案

```
标题: 完成{route_name}徒步 🎉
描述: 走了{distance}km，用时{duration}

备选描述:
- "又是被大自然治愈的一天"
- "每一步都是风景"
- "徒步的快乐，只有走过才懂"
```

### 6.2 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-14 | M3分享功能规范初版 |

---

> **"让每一次徒步，都值得被分享"** - 山径APP分享功能理念
