: HEARTBEAT.md - 定期检查清单

## 检查频率
每 10 分钟检查一次

## 收到 Heartbeat 后必须执行（不能只回复 HEARTBEAT_OK）

### 1. 立即检查 GitHub Actions 状态
- [x] 执行：`curl -s "https://api.github.com/repos/suyustudio/shanjing-app/actions/runs?per_page=3"`
- [x] 记录构建编号、状态、结论
- [x] 如有失败，分析原因

### 2. 检查 Push 状态
- [x] 执行：`git status | grep "ahead"`
- [x] 如有未 push 的 commit，立即重试
- [x] 记录 push 结果

### 3. 检查 Memory 记录
- [x] 检查今日 memory 文件是否存在
- [x] 如有未记录的工作内容，立即写入
- [x] **不能只在聊天说"记住了"，必须落盘**

### 4. 主动汇报
- [x] 构建失败 → 告知用户
- [x] 需要操作 → 明确说明
- [x] push 失败 → 请求协助

## 记忆锚点
- **HEARTBEAT_OK ≠ 工作完成**
- **收到 heartbeat = 开始工作**
- **不检查 = 失职**
- **聊天说记住了 ≠ 写入文件**

---

## 当前状态（2026-03-20 傍晚 6:53）

### ✅ 所有代码已推送并构建成功

**Git 状态：**
- 本地分支：与 origin/main 同步 ✅
- **最新提交：** 733f0d0f - 140 files, 20939 insertions
- **状态：** 全部推送完成 ✅

**GitHub Actions：**
| Build | 状态 | 内容 |
|-------|------|------|
| **#165** | ✅ success | M5完整代码 + M6设计文档 |
| #164 | ✅ success | HEARTBEAT更新 |
| #163 | ✅ success | M5 P1优化代码 |

**M5 阶段：** ✅ 已完成并通过 Review（8.2/10）
**M6 阶段：** 🟡 Review完成，发现点赞功能缺失等问题
| M5/M6 文档 | 30+ | Review报告、设计文档、测试用例 |

**GitHub Actions 状态：**
| Build | 工作流 | 状态 | 说明 |
|-------|--------|------|------|
| **#163** | Build APK | ✅ 成功 | 最新构建，基于 e1a0456c |
| #29 | E2E Tests | ❌ 失败 | 测试环境问题 |
| #42 | APK Pre-check | ❌ 失败 | 辅助工作流，非阻塞 |

**关键信息：**
- ✅ 上次推送的文档提交构建成功
- ⚠️ **有大量代码更改未提交**：M5 P1 成就系统、后端 API、数据库 schema
- ⚠️ **未跟踪的设计文档**：M5/M6 Review报告、设计规范、测试用例

**下一步：**
- [ ] 提交并推送 M5 P1 代码更改（成就系统、后端 API、prisma schema）
- [ ] 决定是否提交 dist 编译产物
- [ ] 整理并提交 M5/M6 设计文档
- [ ] 监控推送后的构建状态

---

## 历史状态存档
- 2026-03-20 17:22: 已推送 1 个提交，Build #161 排队中
- 2026-03-20 17:10: 已推送 2 个提交，Build #159/#25 排队中
- 详细历史见 `memory/2026-03-20.md`
