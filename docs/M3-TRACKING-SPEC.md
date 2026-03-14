# 山径APP - M3 埋点补充规范

> **文档版本**: v1.0  
> **制定日期**: 2026-03-14  > **文档状态**: 已完成  
> **基于版本**: data-tracking-spec-v1.1  
> **对应阶段**: M3 埋点完善

---

## 1. 埋点补充概述

### 1.1 补充目标
基于M2已完成的埋点SDK接入，在M3阶段重点补充：
1. **用户系统相关事件** - 登录、注册、账号管理
2. **分享相关事件** - 分享触发、分享内容、分享效果
3. **设置页面事件** - 用户偏好设置、系统设置
4. **用户行为漏斗** - 关键路径转化率分析

### 1.2 补充原则

| 原则 | 说明 |
|------|------|
| **事件完整性** | 覆盖所有用户关键行为节点 |
| **参数标准化** | 统一参数命名和取值规范 |
| **性能优先** | 批量上报，避免影响用户体验 |
| **隐私合规** | 不收集敏感个人信息 |

---

## 2. 用户登录相关事件补充

### 2.1 登录流程事件

| 事件名 | 触发时机 | 事件类型 | 优先级 |
|--------|----------|----------|--------|
| `login_page_view` | 进入登录页面 | 页面埋点 | P0 |
| `login_method_select` | 选择登录方式 | 点击埋点 | P0 |
| `wechat_login_start` | 开始微信登录 | 功能埋点 | P0 |
| `wechat_login_success` | 微信登录成功 | 功能埋点 | P0 |
| `wechat_login_fail` | 微信登录失败 | 功能埋点 | P0 |
| `wechat_login_cancel` | 用户取消微信登录 | 点击埋点 | P1 |
| `phone_login_start` | 开始手机号登录 | 功能埋点 | P0 |
| `phone_input_complete` | 手机号输入完成 | 功能埋点 | P1 |
| `verify_code_request` | 请求验证码 | 功能埋点 | P0 |
| `verify_code_sent` | 验证码发送成功 | 功能埋点 | P0 |
| `verify_code_input` | 验证码输入完成 | 功能埋点 | P1 |
| `phone_login_success` | 手机号登录成功 | 功能埋点 | P0 |
| `phone_login_fail` | 手机号登录失败 | 功能埋点 | P0 |
| `auto_login_success` | 自动登录成功 | 功能埋点 | P1 |
| `auto_login_fail` | 自动登录失败 | 功能埋点 | P1 |

### 2.2 登录事件参数

```typescript
// 通用登录参数
interface LoginEventParams {
  // 登录方式
  login_type: 'wechat' | 'phone' | 'auto';
  
  // 是否新用户（仅成功事件）
  is_new_user?: boolean;
  
  // 登录耗时（ms）
  duration_ms?: number;
  
  // 来源页面
  source_page: string;
  
  // 是否已设置紧急联系人
  has_emergency_contact?: boolean;
}

// 微信登录失败参数
interface WechatLoginFailParams {
  login_type: 'wechat';
  error_code: string;      // 微信错误码
  error_message: string;   // 错误描述
  stage: 'auth' | 'token_exchange' | 'api_call';
}

// 手机号登录失败参数
interface PhoneLoginFailParams {
  login_type: 'phone';
  fail_reason: 'invalid_code' | 'expired_code' | 'network_error' | 'server_error';
  retry_count: number;
}

// 验证码相关参数
interface VerifyCodeParams {
  phone_prefix: string;    // +86
  request_count: number;   // 当日请求次数
  send_success: boolean;
  error_message?: string;
}
```

### 2.3 注册相关事件

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `register_start` | 开始注册流程 | `register_type` |
| `register_complete` | 完成注册 | `register_type`, `duration_ms` |
| `bind_phone_start` | 开始绑定手机号 | `current_login_type` |
| `bind_phone_success` | 绑定手机号成功 | `source` |
| `bind_phone_fail` | 绑定手机号失败 | `reason` |

### 2.4 用户账号事件

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `profile_view` | 查看个人资料 | - |
| `profile_edit_start` | 开始编辑资料 | `edit_field` |
| `profile_edit_complete` | 完成资料编辑 | `edit_field`, `changed` |
| `avatar_change_start` | 开始更换头像 | `source` (camera/gallery) |
| `avatar_change_success` | 头像更换成功 | `upload_duration_ms` |
| `logout` | 退出登录 | `session_duration`, `logout_source` |
| `account_delete_request` | 申请注销账号 | `reason` |
| `account_delete_complete` | 完成账号注销 | `days_since_request` |

---

## 3. 分享相关事件补充

### 3.1 分享触发事件

| 事件名 | 触发时机 | 优先级 |
|--------|----------|--------|
| `share_button_click` | 点击分享按钮 | P0 |
| `share_panel_open` | 分享面板打开 | P0 |
| `share_panel_close` | 分享面板关闭 | P1 |
| `share_method_select` | 选择分享方式 | P0 |
| `share_target_select` | 选择分享目标平台 | P0 |

### 3.2 分享内容事件

| 事件名 | 触发时机 | 优先级 |
|--------|----------|--------|
| `poster_generate_start` | 开始生成海报 | P0 |
| `poster_generate_complete` | 海报生成完成 | P0 |
| `poster_generate_fail` | 海报生成失败 | P0 |
| `link_copy_success` | 链接复制成功 | P1 |
| `link_copy_fail` | 链接复制失败 | P1 |
| `mini_program_share_start` | 开始分享小程序 | P0 |
| `mini_program_share_complete` | 小程序分享完成 | P0 |

### 3.3 分享结果事件

| 事件名 | 触发时机 | 优先级 |
|--------|----------|--------|
| `share_success` | 分享成功（调起成功） | P0 |
| `share_cancel` | 用户取消分享 | P1 |
| `share_fail` | 分享失败 | P0 |
| `share_received` | 接收到分享（被分享方） | P1 |
| `share_link_open` | 分享链接被打开 | P0 |
| `share_link_install` | 通过分享安装APP | P0 |
| `share_link_register` | 通过分享注册账号 | P0 |

### 3.4 分享事件参数

```typescript
interface ShareEventParams {
  // 内容类型
  content_type: 'route' | 'achievement' | 'trip' | 'post' | 'milestone' | 'app';
  
  // 内容ID
  content_id: string;
  
  // 分享方式
  method: 'poster' | 'link' | 'mini_program' | 'text';
  
  // 目标平台
  platform: 'wechat_chat' | 'wechat_moments' | 'weibo' | 'xiaohongshu' | 'copy' | 'other';
  
  // 来源页面
  source_page: string;
  
  // 海报模板（如果是海报）
  poster_template?: string;
  
  // 生成耗时（ms）
  generation_duration_ms?: number;
  
  // 文件大小（bytes）
  file_size?: number;
  
  // 短链接
  short_link?: string;
  
  // 分享者ID（接收方事件）
  sharer_id?: string;
}

// 分享失败参数
interface ShareFailParams extends ShareEventParams {
  error_code: string;
  error_message: string;
  stage: 'generate' | 'prepare' | 'invoke';
}

// 分享链接追踪参数（UTM）
interface ShareLinkParams {
  utm_source: string;    // 分享平台
  utm_medium: string;    // 分享方式
  utm_campaign: string;  // 活动标识
  referrer_id: string;   // 分享者ID
}
```

### 3.5 行程分享特殊事件

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `trip_share_start` | 开始分享行程 | `route_id`, `progress` |
| `trip_share_location_update` | 行程位置更新 | `update_count`, `interval_minutes` |
| `trip_share_end` | 结束行程分享 | `share_duration_minutes`, `view_count` |
| `trip_location_view` | 查看实时位置 | `viewer_type` |

---

## 4. 设置页面事件补充

### 4.1 设置访问事件

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `settings_page_view` | 进入设置页面 | - |
| `settings_category_click` | 点击设置分类 | `category` |
| `settings_item_click` | 点击设置项 | `item_name` |

### 4.2 设置修改事件

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `setting_changed` | 设置项被修改 | `setting_name`, `old_value`, `new_value` |
| `notification_setting_changed` | 通知设置修改 | `notification_type`, `enabled` |
| `privacy_setting_changed` | 隐私设置修改 | `privacy_type`, `enabled` |
| `display_setting_changed` | 显示设置修改 | `setting_name`, `value` |
| `language_changed` | 语言切换 | `old_language`, `new_language` |

### 4.3 具体设置项埋点

| 设置项 | 事件名 | 参数值 |
|--------|--------|--------|
| 推送通知 | `notification_setting_changed` | `push_enabled: true/false` |
| 声音提醒 | `notification_setting_changed` | `sound_enabled: true/false` |
| 语音播报 | `navigation_setting_changed` | `voice_enabled: true/false` |
| 自动下载离线包 | `offline_setting_changed` | `auto_download: true/false` |
| 自动上传轨迹 | `privacy_setting_changed` | `auto_upload: true/false` |
| 位置精度 | `location_setting_changed` | `accuracy: high/balanced/low` |
| 省流量模式 | `data_setting_changed` | `data_saver: true/false` |
| 清除缓存 | `cache_cleared` | `cache_size_mb` |

### 4.4 紧急联系人设置事件

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `emergency_contact_page_view` | 进入紧急联系人页面 | `contact_count` |
| `emergency_contact_add_start` | 开始添加联系人 | - |
| `emergency_contact_add_complete` | 添加联系人完成 | `contact_count` |
| `emergency_contact_edit` | 编辑联系人 | `action: update/delete` |
| `emergency_contact_test` | 测试发送求救 | `send_method`, `success` |

---

## 5. 用户行为漏斗分析

### 5.1 核心转化漏斗

#### 漏斗1: 新用户注册转化

```
事件序列:
1. app_launch (首次启动)
2. onboarding_view (引导页浏览)
3. login_page_view (进入登录页)
4. login_method_select (选择登录方式)
5. login_success (登录成功)
6. emergency_contact_setup (设置紧急联系人)
7. first_route_view (浏览第一条路线)
8. first_download (下载首个离线包)
9. first_navigation_start (首次开始导航)
10. first_navigation_complete (首次完成导航)

漏斗计算:
- 注册转化率 = login_success / app_launch
- 核心功能激活 = first_navigation_complete / login_success
```

#### 漏斗2: 路线到导航转化

```
事件序列:
1. route_list_view (浏览路线列表)
2. route_detail_view (查看路线详情)
3. route_download_start (开始下载)
4. route_download_complete (下载完成)
5. navigation_start (开始导航)
6. navigation_complete (完成导航)
7. achievement_share (分享成就)

漏斗计算:
- 详情页转化 = route_detail_view / route_list_view
- 下载转化率 = route_download_complete / route_detail_view
- 导航完成率 = navigation_complete / navigation_start
- 分享转化率 = achievement_share / navigation_complete
```

#### 漏斗3: 分享传播漏斗

```
事件序列:
1. share_button_click (点击分享)
2. share_panel_open (打开分享面板)
3. share_method_select (选择分享方式)
4. poster_generate_complete (生成海报/链接)
5. share_success (调起分享成功)
6. share_link_open (链接被打开)
7. share_link_install (安装APP)
8. share_link_register (注册账号)

漏斗计算:
- 分享意愿 = share_panel_open / share_button_click
- 内容生成率 = poster_generate_complete / share_method_select
- 分享成功率 = share_success / poster_generate_complete
- 链接打开率 = share_link_open / share_success
- 安装转化率 = share_link_install / share_link_open
- 注册转化率 = share_link_register / share_link_install
```

### 5.2 漏斗分析参数

```typescript
// 漏斗事件通用参数
interface FunnelEventParams {
  // 漏斗名称
  funnel_name: string;
  
  // 步骤序号
  step_number: number;
  
  // 步骤名称
  step_name: string;
  
  // 会话ID（用于关联同一用户会话）
  session_id: string;
  
  // 距上一步时间（ms）
  time_since_last_step_ms?: number;
  
  // 距第一步时间（ms）
  time_since_first_step_ms?: number;
  
  // 是否完成整个漏斗
  is_completed?: boolean;
}

// 用户分群参数
interface UserSegmentParams {
  // 用户类型
  user_type: 'new' | 'returning' | 'churned_return';
  
  // 注册渠道
  register_channel: 'wechat' | 'phone' | 'share' | 'organic';
  
  // 用户标签
  user_tags: string[];
}
```

### 5.3 留存分析事件

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `app_launch` | 启动APP | `launch_type: cold/warm/hot` |
| `app_foreground` | APP进入前台 | `background_duration_ms` |
| `app_background` | APP进入后台 | `session_duration_ms` |
| `app_terminate` | APP终止 | `session_duration_ms` |
| `day_n_retention` | 第N日启动 | `retention_day` |

### 5.4 用户分群属性

| 属性名 | 说明 | 取值 |
|--------|------|------|
| `user_type` | 用户类型 | new/returning/churned_return |
| `register_date` | 注册日期 | YYYY-MM-DD |
| `register_channel` | 注册渠道 | wechat/phone/share/organic |
| `last_active_date` | 最后活跃日期 | YYYY-MM-DD |
| `total_navigation_count` | 累计导航次数 | number |
| `total_distance_km` | 累计距离 | number |
| `has_emergency_contact` | 是否有紧急联系人 | true/false |
| `has_shared` | 是否分享过 | true/false |

---

## 6. 埋点实施规范

### 6.1 事件命名规范

```
格式: {action}_{object}_{result?}

示例:
- login_success (登录成功)
- share_poster_generate_start (开始生成分享海报)
- setting_notification_changed (通知设置修改)

规则:
1. 全部小写
2. 单词间用下划线分隔
3. 动词在前，名词在后
4. 结果状态在后（success/fail/cancel）
```

### 6.2 参数命名规范

```
格式: {object}_{attribute}

示例:
- login_type (登录类型)
- share_platform (分享平台)
- content_id (内容ID)

规则:
1. 全部小写
2. 单词间用下划线分隔
3. 布尔值用 is_/has_ 前缀
4. 时间用 _at 后缀，ms用 _ms 后缀
```

### 6.3 埋点代码示例

```dart
// 登录埋点
class LoginAnalytics {
  static void trackLoginSuccess(String loginType, bool isNewUser, int durationMs) {
    Analytics.trackEvent('login_success', {
      'login_type': loginType,
      'is_new_user': isNewUser,
      'duration_ms': durationMs,
      'has_emergency_contact': UserManager.currentUser?.emergencyContacts.isNotEmpty ?? false,
    });
  }
  
  static void trackLoginFail(String loginType, String reason, String errorCode) {
    Analytics.trackEvent('login_fail', {
      'login_type': loginType,
      'fail_reason': reason,
      'error_code': errorCode,
    });
  }
}

// 分享埋点
class ShareAnalytics {
  static void trackShareSuccess(ShareParams params) {
    Analytics.trackEvent('share_success', {
      'content_type': params.contentType,
      'content_id': params.contentId,
      'method': params.method,
      'platform': params.platform,
      'poster_template': params.templateId,
      'generation_duration_ms': params.generationDuration,
    });
  }
}

// 设置埋点
class SettingsAnalytics {
  static void trackSettingChanged(String settingName, dynamic oldValue, dynamic newValue) {
    Analytics.trackEvent('setting_changed', {
      'setting_name': settingName,
      'old_value': oldValue.toString(),
      'new_value': newValue.toString(),
    });
  }
}

// 漏斗埋点
class FunnelAnalytics {
  static void trackFunnelStep(String funnelName, int stepNumber, String stepName) {
    Analytics.trackEvent('funnel_step', {
      'funnel_name': funnelName,
      'step_number': stepNumber,
      'step_name': stepName,
      'session_id': Analytics.sessionId,
    });
  }
}
```

### 6.4 埋点验证清单

| 验证项 | 检查内容 | 通过标准 |
|--------|----------|----------|
| **事件触发** | 所有定义的事件是否正常触发 | 100%触发 |
| **参数完整** | 必传参数是否都有值 | 无缺省 |
| **参数正确** | 参数值是否符合预期 | 无异常值 |
| **时机正确** | 事件触发时机是否正确 | 无提前/延迟 |
| **性能影响** | 埋点对性能的影响 | < 10ms |
| **网络影响** | 弱网情况下的表现 | 正常缓存补报 |

---

## 7. 数据报表规划

### 7.1 核心指标看板

| 指标 | 说明 | 计算方式 |
|------|------|----------|
| **DAU** | 日活跃用户 | 当日启动APP的去重用户数 |
| **新增用户** | 新注册用户 | 当日首次登录的用户数 |
| **登录成功率** | 登录成功比例 | login_success / login_start |
| **导航完成率** | 导航完成比例 | navigation_complete / navigation_start |
| **分享率** | 用户分享比例 | share_success / navigation_complete |
| **次日留存** | 次日留存率 | 次日启动的新用户 / 当日新用户 |
| **7日留存** | 7日留存率 | 7日后启动的新用户 / 当日新用户 |

### 7.2 用户行为看板

| 报表 | 维度 | 指标 |
|------|------|------|
| 登录分析 | 登录方式、是否新用户、来源 | 转化率、失败率、耗时 |
| 分享分析 | 内容类型、分享方式、平台 | 分享次数、生成成功率、传播效果 |
| 设置分析 | 设置项、修改次数 | 用户偏好分布 |
| 漏斗分析 | 各步骤转化 | 转化率、流失点 |
| 留存分析 | 注册日期、用户分群 | 次日/7日/30日留存 |

---

## 8. 附录

### 8.1 完整事件清单（M3）

#### 用户系统事件（新增）
- login_page_view, login_method_select
- wechat_login_start, wechat_login_success, wechat_login_fail, wechat_login_cancel
- phone_login_start, phone_login_success, phone_login_fail
- verify_code_request, verify_code_sent
- auto_login_success, auto_login_fail
- register_start, register_complete
- bind_phone_start, bind_phone_success, bind_phone_fail
- profile_view, profile_edit_start, profile_edit_complete
- avatar_change_start, avatar_change_success
- logout

#### 分享事件（新增）
- share_button_click, share_panel_open, share_panel_close
- share_method_select, share_target_select
- poster_generate_start, poster_generate_complete, poster_generate_fail
- link_copy_success, link_copy_fail
- share_success, share_cancel, share_fail
- share_received, share_link_open, share_link_install, share_link_register

#### 设置事件（新增）
- settings_page_view, settings_category_click, settings_item_click
- setting_changed
- notification_setting_changed, privacy_setting_changed
- emergency_contact_page_view, emergency_contact_add_start
- emergency_contact_add_complete, emergency_contact_edit

### 8.2 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-14 | M3埋点补充规范初版 |

---

> **"数据驱动产品优化，埋点连接用户行为"** - 山径APP数据理念
