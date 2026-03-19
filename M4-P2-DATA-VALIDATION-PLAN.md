# M4 P2 - 埋点数据验证计划

> **文档版本**: v1.0  
> **生成日期**: 2026-03-19  > **报告状态**: 规划中  
> **相关文档**: data-tracking-spec-v1.2.md

---

## 1. 执行摘要

本计划定义 M4 阶段埋点数据的验证流程，确保 4 个待实施事件（share_trail, sos_trigger, navigation_start, trail_complete）的数据质量和准确性。

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 数据验证检查清单 | ✅ 已完成 | 覆盖触发时机、参数完整性 |
| 数据看板需求 | ✅ 已完成 | 定义核心指标和维度 |
| 异常数据处理方案 | ✅ 已完成 | 网络失败、重试、丢弃策略 |

---

## 2. 数据验证检查清单

### 2.1 事件触发时机验证

| 事件名 | 触发时机规范 | 验证方法 | 通过标准 |
|--------|--------------|----------|----------|
| **share_trail** | 分享成功回调中 | 断点检查 + 日志确认 | 成功回调触发，取消不触发 |
| **sos_trigger** | API 成功返回后 | 断点检查 + 后端日志 | API 200后触发，失败不触发 |
| **navigation_start** | 导航初始化完成后 | 断点检查 + 状态监听 | GPS就绪+地图加载后触发 |
| **trail_complete** | 到达终点或手动确认 | 断点检查 + 距离计算 | 进入终点20m或手动确认 |

### 2.2 参数完整性检查

#### share_trail 参数检查

| 参数名 | 类型 | 必填 | 值范围 | 验证方法 |
|--------|------|------|--------|----------|
| route_id | String | ✅ | R001格式 | 正则匹配 |
| route_name | String | ✅ | 非空 | 长度>0 |
| share_channel | String | ✅ | 枚举值 | wechat_session/wechat_timeline/save_local |
| template_type | String | ✅ | 枚举值 | nature/minimal/film |
| share_time_ms | Number | ✅ | >0 | 正整数 |
| poster_size_kb | Number | ❌ | >0 | 正整数或null |
| generation_duration_ms | Number | ❌ | >0 | 正整数或null |

#### sos_trigger 参数检查

| 参数名 | 类型 | 必填 | 值范围 | 验证方法 |
|--------|------|------|--------|----------|
| trigger_type | String | ✅ | auto/manual | 枚举检查 |
| countdown_remaining_sec | Number | ✅ | 0-5 | 0-5整数 |
| location_lat | Number | ✅ | -90~90 | 范围检查 |
| location_lng | Number | ✅ | -180~180 | 范围检查 |
| location_accuracy | Number | ✅ | >0 | 正数 |
| route_id | String | ❌ | R001格式 | 正则或null |
| contact_count | Number | ✅ | >0 | 正整数 |
| send_method | String | ✅ | 枚举值 | sms/push/both/wechat |
| api_response_ms | Number | ✅ | >0 | 正整数 |
| trigger_timestamp | Number | ✅ | 13位 | 毫秒时间戳 |

#### navigation_start 参数检查

| 参数名 | 类型 | 必填 | 值范围 | 验证方法 |
|--------|------|------|--------|----------|
| route_id | String | ✅ | R001格式 | 正则匹配 |
| route_name | String | ✅ | 非空 | 长度>0 |
| route_distance_m | Number | ✅ | >0 | 正整数 |
| route_duration_min | Number | ✅ | >0 | 正整数 |
| difficulty | String | ✅ | 枚举值 | easy/medium/hard |
| start_type | String | ✅ | 枚举值 | normal/resume/reroute/quick |
| location_enabled | Boolean | ✅ | true/false | 布尔值 |
| location_accuracy_m | Number | ❌ | >0 | 正数或null |
| offline_mode | Boolean | ✅ | true/false | 布尔值 |
| voice_enabled | Boolean | ✅ | true/false | 布尔值 |
| start_timestamp | Number | ✅ | 13位 | 毫秒时间戳 |

#### trail_complete 参数检查

| 参数名 | 类型 | 必填 | 值范围 | 验证方法 |
|--------|------|------|--------|----------|
| route_id | String | ✅ | R001格式 | 正则匹配 |
| route_name | String | ✅ | 非空 | 长度>0 |
| completion_type | String | ✅ | 枚举值 | auto/manual/checkpoint |
| actual_distance_m | Number | ✅ | >0 | 正整数 |
| actual_duration_sec | Number | ✅ | >0 | 正整数 |
| planned_distance_m | Number | ✅ | >0 | 正整数 |
| planned_duration_min | Number | ✅ | >0 | 正整数 |
| deviation_count | Number | ✅ | ≥0 | 非负整数 |
| avg_speed_ms | Number | ✅ | >0 | 正数，保留2位小数 |
| pause_count | Number | ❌ | ≥0 | 非负整数或null |
| pause_duration_sec | Number | ❌ | ≥0 | 非负整数或null |
| photo_count | Number | ❌ | ≥0 | 非负整数或null |
| completion_timestamp | Number | ✅ | 13位 | 毫秒时间戳 |
| rating | Number | ❌ | 1-5 | 整数或null |

### 2.3 数据一致性验证

| 验证项 | 验证逻辑 | 告警阈值 |
|--------|----------|----------|
| 路线ID存在性 | route_id 需在路线表中存在 | 错误率 < 1% |
| 时间戳合理性 | 事件时间需在合理范围内（±1天） | 错误率 < 0.1% |
| 坐标合理性 | 经纬度需在中国范围内 | 错误率 < 0.1% |
| 数值范围 | 距离、时长等需为正数 | 错误率 < 0.1% |
| 完成率合理性 | trail_complete ≤ navigation_start | 差异 < 5% |

---

## 3. 数据看板需求

### 3.1 核心指标看板

#### 指标卡片

| 指标名 | 计算公式 | 维度 | 刷新频率 |
|--------|----------|------|----------|
| 日活用户数 | COUNT(DISTINCT user_id) | 日期 | 每小时 |
| 导航启动次数 | COUNT(navigation_start) | 日期/路线 | 实时 |
| 导航完成率 | trail_complete / navigation_start | 日期/路线 | 每小时 |
| 平均完成偏差 | AVG(actual_distance / planned_distance) | 路线 | 每日 |
| 分享转化率 | share_trail / 详情页浏览 | 日期/路线 | 每小时 |
| SOS 触发率 | sos_trigger / navigation_start | 日期 | 每日 |

#### 趋势图表

| 图表名 | 类型 | 维度 | 时间范围 |
|--------|------|------|----------|
| 导航启动趋势 | 折线图 | 日期 | 最近30天 |
| 完成率趋势 | 折线图 | 日期 | 最近30天 |
| 分享渠道分布 | 饼图 | share_channel | 最近7天 |
| 问题类型分布 | 柱状图 | 失败事件类型 | 最近7天 |
| 路线热度排行 | 表格 | route_name + navigation_count | 最近7天 |

### 3.2 实时监控告警

| 告警项 | 触发条件 | 通知方式 | 响应时效 |
|--------|----------|----------|----------|
| 数据上报延迟 | 最近5分钟无数据 | 飞书告警 | 15分钟 |
| 事件丢失率 | 完成率 < 50% | 飞书告警 | 1小时 |
| 参数错误率 | 无效参数 > 5% | 飞书通知 | 4小时 |
| 异常峰值 | 事件量突增/突降 50% | 飞书通知 | 4小时 |

### 3.3 漏斗分析

| 漏斗名 | 步骤 | 计算转化率 |
|--------|------|------------|
| 分享漏斗 | 打开分享 → 选择模板 → 确认分享 | 每步转化率 |
| SOS漏斗 | 点击SOS → 倒计时 → 确认发送 | 每步转化率 |
| 导航漏斗 | 查看详情 → 开始导航 → 完成导航 | 每步转化率 |

### 3.4 用户分群

| 分群名 | 定义 | 用途 |
|--------|------|------|
| 高频用户 | 7天内 navigation_start ≥ 3 | 核心用户分析 |
| 低频用户 | 7天内 navigation_start = 1 | 留存分析 |
| 分享达人 | 7天内 share_trail ≥ 2 | 传播分析 |
| 流失预警 | 14天无 navigation_start | 召回策略 |

---

## 4. 异常数据处理方案

### 4.1 网络失败处理

#### 缓存策略

```dart
class AnalyticsCache {
  static const int MAX_CACHE_SIZE = 50;      // 最大缓存事件数
  static const int MAX_RETRY_COUNT = 5;      // 最大重试次数
  static const int FLUSH_INTERVAL_SEC = 60;  // 定时上报间隔
  
  // 网络失败时缓存事件
  static void cacheEvent(Map<String, dynamic> event) {
    if (_pendingEvents.length >= MAX_CACHE_SIZE) {
      _pendingEvents.removeAt(0);  // FIFO移除最旧
      _reportDroppedEvent(event);   // 上报丢弃
    }
    _pendingEvents.add(event);
    _saveToLocal();  // 持久化
  }
  
  // 网络恢复后批量上报
  static Future<void> flush() async {
    final failed = <Map>[];
    for (var event in _pendingEvents) {
      try {
        await _send(event);
      } catch (e) {
        event['retry_count'] = (event['retry_count'] ?? 0) + 1;
        if (event['retry_count'] < MAX_RETRY_COUNT) {
          failed.add(event);
        } else {
          _reportDroppedEvent(event);
        }
      }
    }
    _pendingEvents = failed;
    _saveToLocal();
  }
}
```

#### 监控指标

| 指标名 | 计算方式 | 告警阈值 |
|--------|----------|----------|
| 缓存事件数 | pendingEvents.length | > 20 告警 |
| 缓存失败率 | cache_stored / total_events | > 10% 告警 |
| 数据丢弃率 | dropped / total_events | > 1% 告警 |
| 平均恢复时间 | 从断网到 flush 成功 | > 5分钟 告警 |

### 4.2 用户取消操作处理

#### 取消事件设计

| 取消事件 | 触发时机 | 关键参数 |
|----------|----------|----------|
| share_cancel | 分享流程取消 | cancel_stage, cancel_reason, time_spent_ms |
| sos_cancel | SOS流程取消 | trigger_stage, countdown_remaining_sec |

#### 漏斗流失分析

```sql
-- 分享取消分析
SELECT 
  cancel_stage,
  COUNT(*) as cancel_count,
  AVG(time_spent_ms) as avg_time,
  cancel_reason
FROM share_cancel
WHERE timestamp > NOW() - INTERVAL 7 DAY
GROUP BY cancel_stage, cancel_reason
ORDER BY cancel_count DESC;
```

### 4.3 API 失败处理

#### 错误分类

| 错误类型 | HTTP状态 | 处理策略 | 重试延迟 |
|----------|----------|----------|----------|
| 网络超时 | 0 | 立即重试 | 1s, 2s, 4s... |
| 服务器错误 | 5xx | 指数退避重试 | 1s, 2s, 4s... |
| 客户端错误 | 4xx | 不重试，记录日志 | - |
| 限流 | 429 | 延迟后重试 | 5s, 10s, 20s... |

#### 指数退避实现

```dart
class RetryPolicy {
  static const List<int> DELAYS = [1000, 2000, 4000, 8000, 16000];
  
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    required String apiName,
  }) async {
    for (int i = 0; i < DELAYS.length; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == DELAYS.length - 1) {
          Analytics.track('api_request_final_failed', {
            'api_name': apiName,
            'error': e.toString(),
          });
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: DELAYS[i]));
      }
    }
    throw Exception('Max retries exceeded');
  }
}
```

### 4.4 数据质量监控

#### 每日数据质量报告

| 检查项 | 检查逻辑 | 合格标准 | 不合格处理 |
|--------|----------|----------|------------|
| 事件丢失检查 | navigation_start - trail_complete | 差异 < 5% | 排查原因 |
| 参数完整性 | 必填参数空值率 | < 1% | 修复代码 |
| 时间戳异常 | 未来时间或过去时间 | = 0 | 检查时区 |
| 坐标异常 | 经纬度超出中国范围 | < 0.1% | 检查定位 |
| 重复事件 | 相同参数相同时间 | < 0.1% | 去重逻辑 |

---

## 5. 验证执行计划

### 5.1 验证阶段

| 阶段 | 时间 | 任务 | 负责人 |
|------|------|------|--------|
| 开发自测 | M4 Week 1 | 事件触发、参数检查 | Dev |
| 集成测试 | M4 Week 2 | 完整流程、网络异常 | QA |
| 数据验证 | M4 Week 2 | 看板数据准确性 | Product |
| 灰度验证 | M4 Week 3 | 生产环境数据质量 | Product + Dev |

### 5.2 验证工具

| 工具 | 用途 | 使用阶段 |
|------|------|----------|
| 日志输出 | 本地调试 | 开发自测 |
| 抓包工具 | 验证上报内容 | 集成测试 |
| SQL查询 | 数据质量检查 | 数据验证 |
| 看板系统 | 实时监控 | 灰度验证 |

### 5.3 验收标准

| 检查项 | 通过标准 |
|--------|----------|
| 事件触发准确率 | 100% |
| 参数完整率 | > 99% |
| 数据上报成功率 | > 99.5% |
| 看板数据延迟 | < 5分钟 |
| 异常告警准确率 | > 90% |

---

## 6. 附录

### 6.1 相关文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 埋点规范 v1.2 | data-tracking-spec-v1.2.md | 完整事件定义 |
| QA 测试计划 | M4-QA-TEST-PLAN.md | 测试用例 |
| 数据看板 PRD | 待补充 | 可视化需求 |

### 6.2 变更记录

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | 初版完成，定义验证清单和异常处理方案 |

---

> **文档编写**: Product Agent  
> **下次更新**: Dev 完成埋点实施后验证  
> **阻塞项**: 待 4 个事件开发完成
