# M4 Product 修复报告

> **报告版本**: v1.0  
> **生成日期**: 2026-03-19  
> **报告类型**: QA Review 问题修复汇总  
> **相关阶段**: M4 内测准备

---

## 1. 执行摘要

本次修复针对 QA Review 发现的关键缺失场景进行了系统性补充，涵盖以下四个核心领域：

| 修复领域 | 优先级 | 涉及文档 | 状态 |
|---------|--------|---------|------|
| 验收标准量化 | P0 | M4-ACCEPTANCE-CHECKLIST.md | ✅ 已更新 |
| 埋点失败场景 | P0 | data-tracking-spec-v1.2.md | ✅ 已补充 |
| SOS压力测试 | P0 | M4-QA-TEST-PLAN.md, M4-FIELD-TEST-PLAN.md | ✅ 已补充 |
| 分享失败场景 | P1 | M4-QA-TEST-PLAN.md | ✅ 已补充 |

---

## 2. 验收标准改进详情

### 2.1 修改文件: M4-ACCEPTANCE-CHECKLIST.md

#### Q-005 内存泄漏标准（改进）

| 维度 | 原标准 | 改进后标准 |
|------|--------|-----------|
| **检查方法** | 导航页进出10次 | 导航页进出10次<br>分享页进出10次<br>SOS触发3次 |
| **目标值** | 内存稳定 | **内存增长 < 10MB** |

**改进理由**: 
- 原标准"内存稳定"过于主观，难以量化评估
- 增加分享页和SOS场景的内存检查，覆盖更多功能模块
- 10MB阈值基于同类App行业标准设定

#### Q-004 导航稳定性标准（改进）

| 维度 | 原标准 | 改进后标准 |
|------|--------|-----------|
| **检查方法** | 30分钟连续导航 | 30分钟连续导航<br>步速 4-6km/h<br>路线长度 ≥5km<br>后台切换 ≥5次 |
| **目标值** | 无崩溃 | 无崩溃<br>定位不丢失<br>语音正常 |

**改进理由**:
- 增加步速和路线长度要求，模拟真实徒步场景
- 增加后台切换测试，验证APP在后台/前台切换时的稳定性
- 明确"定位不丢失"和"语音正常"作为验收标准

#### FT-002 定位精度标准（改进）

| 维度 | 原标准 | 改进后标准 |
|------|--------|-----------|
| **检查方法** | 偏差 < 20米 | 偏差 < 20米<br>至少8个检查点<br>连续记录 ≥30分钟 |
| **样本要求** | 无明确要求 | 至少8个检查点 |

**改进理由**:
- 8个检查点确保样本数量足够，提高统计可信度
- 30分钟连续记录验证长时间使用下的定位稳定性
- 避免单次偶然达标的情况

---

## 3. 缺失场景补充详情

### 3.1 P0 - 埋点失败场景测试

#### 新增测试用例文件规划
- **文件**: `qa/m4/test_cases/TC-ANALYTICS-FAILURE.md`
- **优先级**: P0
- **预计完成**: 03/25

#### 覆盖场景

| 失败场景 | 测试内容 | 预期行为 | 验收标准 |
|---------|---------|---------|---------|
| 网络失败 | 弱网/断网时的埋点行为 | 本地队列缓存，网络恢复后批量上报 | 网络断开时埋点不丢失 |
| 用户取消分享 | 分享面板中点击取消 | 不上报share_trail，上报share_cancel | 取消操作不上报成功事件 |
| 用户取消SOS | SOS倒计时期间点击取消 | 不上报sos_trigger，上报sos_cancel | 失败事件有独立的事件名 |
| API失败 | 后端返回4xx/5xx | 本地保留，按指数退避重试（最多5次） | 重试机制有效（最多5次） |
| 超时失败 | 请求超过10秒 | 标记为失败，计入重试队列 | 超时设置合理 |
| 批量上报失败 | 本地缓存超过50条 | 自动触发批量上报，失败则保留 | 缓存上限合理 |

### 3.2 P0 - SOS压力测试场景

#### 新增测试用例文件规划
- **文件**: `qa/m4/test_cases/TC-SOS-STRESS.md`
- **优先级**: P0
- **预计完成**: 03/26

#### 覆盖场景

| 压力场景 | 测试内容 | 验收标准 |
|---------|---------|---------|
| 连续多次触发 | 5分钟内连续触发3次SOS | 每次都能正常发送，不丢数据 |
| 弱网环境 | 2G网络下触发SOS | 请求超时后降级为本地存储，提示用户 |
| 无信号场景 | 飞行模式下触发SOS | 本地保存求救信息，恢复信号后自动发送 |
| 电量极低 | 电量<5%时触发SOS | 优先保证SOS功能，其他功能降级 |
| 后台触发 | APP在后台时触发SOS | 能唤醒APP并执行SOS流程 |
| 多联系人压力 | 10个紧急联系人同时发送 | 不阻塞UI，异步发送，记录每个结果 |

#### 实地测试新增阶段
在 `M4-FIELD-TEST-PLAN.md` 中新增**阶段五：SOS压力测试**，包含7个详细测试步骤和数据采集要求。

### 3.3 P1 - 分享失败场景

#### 新增测试用例文件规划
- **文件**: `qa/m4/test_cases/TC-SHARE-FAILURE.md`
- **优先级**: P1
- **预计完成**: 03/27

#### 覆盖场景

| 失败场景 | 测试内容 | 预期行为 |
|---------|---------|---------|
| 微信未安装 | 设备无微信APP时点击分享 | 提示"未安装微信"，引导下载或选择其他方式 |
| 分享取消 | 海报生成后点击取消 | 关闭分享面板，上报share_cancel事件 |
| 网络中断恢复 | 分享过程中断网 | 保存海报到本地，提示用户稍后手动分享 |
| 存储空间不足 | 保存海报时空间不足 | 提示清理空间，不上报save_local事件 |
| 海报生成失败 | 内存不足导致生成失败 | 提示重试，上报poster_generation_failed |
| 权限拒绝 | 存储权限被拒绝 | 引导用户开启权限，不上报失败事件 |

---

## 4. 埋点规范更新详情

### 4.1 修改文件: data-tracking-spec-v1.2.md

#### 新增章节: 2.5 失败场景埋点处理规范 (v1.2.1)

##### 2.5.1 网络失败时的埋点行为

**核心机制**:
```dart
// 关键实现要点
1. 网络失败时缓存到本地队列
2. 队列上限50条，满时移除最旧数据
3. 网络恢复后批量上报
4. 最多重试5次，超过则丢弃并记录
5. 超时时间设置为10秒
```

**新增事件**:
| 事件名 | 用途 |
|--------|------|
| `analytics_cache_stored` | 监控网络失败率 |
| `analytics_batch_sent` | 监控恢复上报效率 |
| `analytics_event_dropped` | 监控数据丢失率 |

##### 2.5.2 用户取消分享/SOS时的埋点

**share_cancel 事件参数**:
| 参数 | 说明 |
|------|------|
| `cancel_stage` | 取消阶段：template_select/channel_select/generation/confirm |
| `cancel_reason` | 取消原因：user_cancel/back_pressed/outside_tap |
| `time_spent_ms` | 分享面板打开时长 |
| `template_previewed` | 预览过的模板数量 |

**sos_cancel 事件参数**:
| 参数 | 说明 |
|------|------|
| `trigger_stage` | 取消阶段：button_click/countdown/confirm_dialog |
| `countdown_remaining_sec` | 倒计时剩余秒数 |
| `time_since_open_ms` | SOS页面打开时长 |

##### 2.5.3 API失败时的埋点处理

**api_request_failed 事件参数**:
| 参数 | 说明 |
|------|------|
| `api_name` | API名称 |
| `error_type` | timeout/network_error/server_error/client_error |
| `http_status` | HTTP状态码，0表示无响应 |
| `network_type` | wifi/4g/3g/2g/none |

**指数退避重试策略**:
```dart
static const List<int> RETRY_DELAYS = [1000, 2000, 4000, 8000, 16000];
// 最大重试5次，间隔指数增长
```

### 4.2 事件索引更新

新增以下事件到完整事件索引表：
- `share_cancel` (P0)
- `sos_cancel` (P0)
- `analytics_cache_stored` (P1)
- `analytics_batch_sent` (P1)
- `analytics_event_dropped` (P1)
- `api_request_failed` (P1)
- `api_request_success` (P1)
- `api_request_final_failed` (P1)

---

## 5. 任务进度更新

### 5.1 新增任务项 (M4-QA-TEST-PLAN.md)

| 任务 ID | 任务名称 | 优先级 | 负责人 | 状态 | 预计完成 |
|---------|----------|--------|--------|------|----------|
| M4-TC-05 | 埋点失败场景测试 | P0 | QA | ⬜ 未开始 | 03/25 |
| M4-TC-06 | SOS压力测试场景 | P0 | QA | ⬜ 未开始 | 03/26 |
| M4-TC-07 | 分享失败场景测试 | P1 | QA | ⬜ 未开始 | 03/27 |

### 5.2 依赖关系

```
M4-TC-05 (埋点失败场景)
├── 依赖: data-tracking-spec-v1.2.md v1.2.1 实施完成
└── 阻塞: M4-AUTO-01 (自动化脚本需覆盖失败场景)

M4-TC-06 (SOS压力测试)
├── 依赖: M4-TC-03 (SOS基础功能E2E)
└── 阻塞: 实地测试执行

M4-TC-07 (分享失败场景)
├── 依赖: M4-TC-02 (分享基础功能E2E)
└── 阻塞: 无
```

---

## 6. 验收检查清单

### 6.1 文档更新验证

| 检查项 | 验证内容 | 状态 |
|--------|---------|------|
| ✅ M4-ACCEPTANCE-CHECKLIST.md | Q-005内存标准已量化为<10MB | 已验证 |
| ✅ M4-ACCEPTANCE-CHECKLIST.md | Q-004导航稳定性增加步速/后台切换要求 | 已验证 |
| ✅ M4-ACCEPTANCE-CHECKLIST.md | FT-002定位精度增加8个检查点要求 | 已验证 |
| ✅ M4-QA-TEST-PLAN.md | 2.5节埋点失败场景测试已添加 | 已验证 |
| ✅ M4-QA-TEST-PLAN.md | 2.6节SOS压力测试场景已添加 | 已验证 |
| ✅ M4-QA-TEST-PLAN.md | 2.7节分享失败场景已添加 | 已验证 |
| ✅ M4-QA-TEST-PLAN.md | 7.1节任务分解表已更新 | 已验证 |
| ✅ M4-FIELD-TEST-PLAN.md | 3.5节SOS压力测试阶段已添加 | 已验证 |
| ✅ M4-FIELD-TEST-PLAN.md | 4.2节功能验证记录表已更新 | 已验证 |
| ✅ data-tracking-spec-v1.2.md | 2.5节失败场景埋点处理规范已添加 | 已验证 |
| ✅ data-tracking-spec-v1.2.md | 5.1节事件索引表已更新 | 已验证 |
| ✅ data-tracking-spec-v1.2.md | 版本号已更新为v1.2.1 | 已验证 |

### 6.2 待办事项

| 序号 | 事项 | 负责人 | 截止时间 |
|------|------|--------|---------|
| 1 | 创建 `TC-ANALYTICS-FAILURE.md` 测试用例文档 | QA | 03/21 |
| 2 | 创建 `TC-SOS-STRESS.md` 测试用例文档 | QA | 03/22 |
| 3 | 创建 `TC-SHARE-FAILURE.md` 测试用例文档 | QA | 03/23 |
| 4 | Dev实施埋点失败处理代码 | Dev | 03/28 |
| 5 | QA验证埋点失败场景 | QA | 04/01 |

---

## 7. 附录

### 7.1 修改文件清单

| 文件路径 | 修改类型 | 变更章节 |
|---------|---------|---------|
| `/root/.openclaw/workspace/M4-ACCEPTANCE-CHECKLIST.md` | 编辑 | 3.1稳定性检查表 |
| `/root/.openclaw/workspace/M4-ACCEPTANCE-CHECKLIST.md` | 编辑 | 7.实地测试要求 |
| `/root/.openclaw/workspace/qa/m4/M4-QA-TEST-PLAN.md` | 编辑 | 2.P0测试用例补充 |
| `/root/.openclaw/workspace/qa/m4/M4-QA-TEST-PLAN.md` | 编辑 | 7.测试进度跟踪 |
| `/root/.openclaw/workspace/M4-FIELD-TEST-PLAN.md` | 编辑 | 3.测试步骤 |
| `/root/.openclaw/workspace/M4-FIELD-TEST-PLAN.md` | 编辑 | 4.2功能验证记录表 |
| `/root/.openclaw/workspace/data-tracking-spec-v1.2.md` | 编辑 | 1.1版本变更 |
| `/root/.openclaw/workspace/data-tracking-spec-v1.2.md` | 新增 | 2.5失败场景埋点处理规范 |
| `/root/.openclaw/workspace/data-tracking-spec-v1.2.md` | 编辑 | 5.1完整事件索引 |
| `/root/.openclaw/workspace/data-tracking-spec-v1.2.md` | 编辑 | 5.3变更记录 |
| `/root/.openclaw/workspace/PRODUCT-FIX-REPORT.md` | 创建 | 全文 |

### 7.2 相关文档链接

| 文档 | 路径 |
|------|------|
| 验收检查清单 | M4-ACCEPTANCE-CHECKLIST.md |
| QA测试计划 | qa/m4/M4-QA-TEST-PLAN.md |
| 实地测试计划 | M4-FIELD-TEST-PLAN.md |
| 埋点规范 | data-tracking-spec-v1.2.md |
| 本报告 | PRODUCT-FIX-REPORT.md |

---

> **报告生成**: Product Agent  
> **审核待办**: Dev Lead、QA Lead  
> **下次更新**: 所有测试用例文档创建完成后
