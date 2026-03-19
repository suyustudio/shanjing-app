# TC-ANALYTICS - 埋点事件测试用例

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **对应规范**: data-tracking-spec-v1.1.md  
> **优先级**: P0

---

## 测试概览

### 测试目标
验证 4 个核心埋点事件的触发时机、参数完整性和上报准确性。

### 测试范围

| 事件名 | 事件类型 | 触发模块 |
|--------|----------|----------|
| `sos_triggered` | 功能埋点 | 安全模块 |
| `trip_shared` | 功能埋点 | 分享模块 |
| `emergency_contact_updated` | 功能埋点 | 用户设置 |
| `navigation_interrupted` | 异常埋点 | 导航模块 |

### 测试环境

| 项目 | 配置 |
|------|------|
| App 版本 | Build #112+ |
| 网络环境 | WiFi / 4G / 无网络 |
| 测试账号 | 微信测试账号 x3 |
| 测试设备 | Android 12+ |

---

## 测试用例详情

### TC-ANALYTICS-001: SOS 触发事件 `sos_triggered`

#### 基本信息

| 属性 | 值 |
|------|-----|
| 用例 ID | TC-ANALYTICS-001 |
| 用例名称 | SOS 触发埋点验证 |
| 优先级 | P0 |
| 前置条件 | 1. 已登录 2. 已设置紧急联系人 3. 正在导航中 |

#### 事件定义

```json
{
  "event_name": "sos_triggered",
  "event_type": "function",
  "trigger_timing": "用户点击 SOS 按钮并确认后"
}
```

#### 预期参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `trigger_location` | Object | 是 | 触发位置坐标 {lat, lng} |
| `contact_count` | Number | 是 | 紧急联系人数 |
| `send_method` | String | 是 | 发送方式: sms/push/both |
| `send_success` | Boolean | 是 | 发送是否成功 |
| `trigger_time` | Number | 是 | 触发时间戳(毫秒) |
| `route_id` | String | 否 | 当前导航路线ID |

#### 测试步骤

**场景 1: 正常触发（有网络）**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 开始任意路线导航 | 导航页面正常显示 |
| 2 | 点击 SOS 按钮 | 弹出二次确认框 |
| 3 | 点击确认 | 发送 SOS，埋点上报 |
| 4 | 检查埋点数据 | 事件参数完整正确 |

**场景 2: 无网络触发**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 关闭网络，开始导航 | 离线导航正常 |
| 2 | 点击 SOS 并确认 | 本地缓存埋点 |
| 3 | 恢复网络 | 埋点补报成功 |

**场景 3: 多联系人发送**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 设置 3 位紧急联系人 | 设置成功 |
| 2 | 导航中触发 SOS | contact_count=3 |
| 3 | 检查埋点 | 参数值正确 |

#### 验收标准

- [ ] 事件在确认后 1 秒内上报
- [ ] 所有必填参数非空
- [ ] `trigger_location` 精度 < 10 米
- [ ] `trigger_time` 为实际触发时间（非发送时间）
- [ ] 无网络时缓存，恢复后补报

---

### TC-ANALYTICS-002: 行程分享事件 `trip_shared`

#### 基本信息

| 属性 | 值 |
|------|-----|
| 用例 ID | TC-ANALYTICS-002 |
| 用例名称 | 行程分享埋点验证 |
| 优先级 | P0 |
| 前置条件 | 1. 已登录 2. 正在导航或已完成导航 |

#### 事件定义

```json
{
  "event_name": "trip_shared",
  "event_type": "function",
  "trigger_timing": "用户分享行程后"
}
```

#### 预期参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `share_type` | String | 是 | 分享类型: wechat/moments/copy_link |
| `route_id` | String | 是 | 路线ID |
| `include_location` | Boolean | 否 | 是否包含实时位置 |
| `recipient_count` | Number | 否 | 接收人数 |

#### 测试步骤

**场景 1: 分享给微信好友**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 开始导航 | 导航正常 |
| 2 | 点击分享按钮 | 分享面板弹出 |
| 3 | 选择"微信好友" | 唤起微信 |
| 4 | 选择 2 位好友发送 | 分享成功 |
| 5 | 检查埋点 | share_type=wechat, recipient_count=2 |

**场景 2: 分享到朋友圈**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 完成导航 | 行程结束 |
| 2 | 点击分享 | 分享面板弹出 |
| 3 | 选择"朋友圈" | 唤起朋友圈 |
| 4 | 确认发布 | 分享成功 |
| 5 | 检查埋点 | share_type=moments |

**场景 3: 复制链接**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 在路线详情页 | 页面正常 |
| 2 | 点击分享 | 分享面板弹出 |
| 3 | 选择"复制链接" | 链接复制成功 |
| 4 | 检查埋点 | share_type=copy_link |

#### 验收标准

- [ ] 每种分享类型都触发埋点
- [ ] `share_type` 值域正确
- [ ] `include_location` 根据用户选择正确记录
- [ ] `recipient_count` 对于微信好友准确

---

### TC-ANALYTICS-003: 紧急联系人更新事件 `emergency_contact_updated`

#### 基本信息

| 属性 | 值 |
|------|-----|
| 用例 ID | TC-ANALYTICS-003 |
| 用例名称 | 紧急联系人更新埋点验证 |
| 优先级 | P0 |
| 前置条件 | 已登录 |

#### 事件定义

```json
{
  "event_name": "emergency_contact_updated",
  "event_type": "function",
  "trigger_timing": "用户添加/修改/删除紧急联系人后"
}
```

#### 预期参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `action` | String | 是 | 操作类型: add/update/delete |
| `contact_count` | Number | 是 | 设置后的联系人数量 |

#### 测试步骤

**场景 1: 添加联系人**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 进入"我的-紧急联系人" | 页面显示 |
| 2 | 点击添加 | 表单弹出 |
| 3 | 填写姓名和手机号 | 信息输入 |
| 4 | 点击保存 | 保存成功 |
| 5 | 检查埋点 | action=add, contact_count=1 |

**场景 2: 修改联系人**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 已有 2 位联系人 | 列表显示 |
| 2 | 点击编辑第一位 | 编辑表单 |
| 3 | 修改手机号 | 信息更新 |
| 4 | 保存 | 更新成功 |
| 5 | 检查埋点 | action=update, contact_count=2 |

**场景 3: 删除联系人**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 已有 3 位联系人 | 列表显示 |
| 2 | 左滑删除一位 | 确认弹窗 |
| 3 | 确认删除 | 删除成功 |
| 4 | 检查埋点 | action=delete, contact_count=2 |

#### 验收标准

- [ ] 增删改操作都触发埋点
- [ ] `action` 值域正确
- [ ] `contact_count` 为操作后的数量
- [ ] 批量操作时只触发一次埋点

---

### TC-ANALYTICS-004: 导航中断事件 `navigation_interrupted`

#### 基本信息

| 属性 | 值 |
|------|-----|
| 用例 ID | TC-ANALYTICS-004 |
| 用例名称 | 导航中断埋点验证 |
| 优先级 | P0 |
| 前置条件 | 正在导航中 |

#### 事件定义

```json
{
  "event_name": "navigation_interrupted",
  "event_type": "exception",
  "trigger_timing": "导航意外中断时"
}
```

#### 预期参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `reason` | String | 是 | 中断原因: call/app_kill/gps_lost |
| `duration` | Number | 是 | 已导航时长(秒) |
| `route_id` | String | 是 | 当前路线ID |
| `interrupt_time` | Number | 是 | 中断时间戳 |

#### 测试步骤

**场景 1: 来电中断**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 开始导航 5 分钟 | 导航正常 |
| 2 | 模拟来电 | 来电界面 |
| 3 | 挂断电话 | 返回导航 |
| 4 | 检查埋点 | reason=call, duration=300 |

**场景 2: App 被杀死**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 开始导航 10 分钟 | 导航正常 |
| 2 | 手动杀掉 App | App 关闭 |
| 3 | 重新打开 App | 提示恢复导航 |
| 4 | 检查埋点 | reason=app_kill, duration=600 |

**场景 3: GPS 信号丢失**

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 开始导航 | 导航正常 |
| 2 | 进入隧道/地下室 | GPS 信号丢失 |
| 3 | 持续 2 分钟无信号 | 提示信号弱 |
| 4 | 检查埋点 | reason=gps_lost |

#### 验收标准

- [ ] 各种中断原因都正确记录
- [ ] `duration` 精确到秒
- [ ] App 被杀后重新启动能检测到并上报
- [ ] GPS 丢失持续 60 秒才触发

---

## 自动化测试脚本

详见: [`../automation/analytics_validation.py`](../automation/analytics_validation.py)

### 脚本功能

```python
# 核心功能
1. mock_analytics_server()      # 启动 Mock 埋点服务器
2. trigger_event(event_name)    # 自动化触发事件
3. capture_event()              # 捕获上报的埋点数据
4. validate_params(schema)      # 验证参数完整性
5. generate_report()            # 生成测试报告
```

### 执行命令

```bash
# 运行全部埋点测试
python analytics_validation.py --all

# 运行单个事件测试
python analytics_validation.py --event sos_triggered

# 生成 HTML 报告
python analytics_validation.py --report html
```

---

## 测试数据

### Mock 数据

```json
{
  "test_user": {
    "user_id": "test_user_001",
    "emergency_contacts": [
      {"name": "测试联系人1", "phone": "13800138001"},
      {"name": "测试联系人2", "phone": "13800138002"}
    ]
  },
  "test_route": {
    "route_id": "R_TEST_001",
    "name": "测试路线",
    "distance": 5.2,
    "duration": 7200
  }
}
```

---

## 版本记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | 初版完成，包含 4 个核心埋点事件测试用例 |
