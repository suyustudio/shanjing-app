# M3 埋点事件检查清单

| 事件名 | 状态 | 位置 |
|--------|------|------|
| navigation_start | ✅ 已实施 | `trail_detail_screen.dart:182` |
| offline_map_download_complete | ✅ 已实施 | `offline_map_screen.dart:163` |
| login_success | ⏳ 待实施 | `user_events.dart:19` 定义，未调用 |
| login_fail | ⏳ 待实施 | `user_events.dart:20` 定义，未调用 |
| share_trail | ⏳ 待实施 | `trail_events.dart:8` 定义，未调用 |
| sos_trigger | ⏳ 待实施 | `navigation_events.dart:10` 定义，未调用 |

## 汇总

- **已实施事件数**: 2
- **待实施事件数**: 4

## 备注

1. `navigation_start` 在 `TrailEvents` 和 `NavigationEvents` 中均有定义
2. `offline_map_download` 使用 `MapEvents.offlineMapDownload`
3. 登录事件需补充 `trackEvent` 调用（在登录逻辑完成后）
4. 分享和SOS事件需在实际交互点补充埋点
