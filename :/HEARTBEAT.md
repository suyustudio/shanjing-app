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

## 当前状态（2026-03-20 17:52）

### ✅ 本地与远程同步，无需推送

**Git 状态：**
- 本地分支：与 origin/main 同步 ✅
- 状态：`Your branch is up to date with 'origin/main'`
- 检查时间：2026-03-20 17:52

**未跟踪文件（暂不处理）：**
- M5 成就系统相关文档（M5-ACHIEVEMENT-*.md）
- Dart 服务层代码（achievement_*.dart, analytics_service.dart 等）
- API 编译输出文件（dist/）
- shanjing-test/repo/ 目录

**构建状态：**
| Build | 工作流 | 状态 | 结论 | 说明 |
|-------|--------|------|------|------|
| **#162** | 未知 | 🔄 in_progress | - | 当前进行中 |
| #28 | 未知 | ✅ completed | ❌ failure | 失败 |
| #40 | 未知 | ✅ completed | ❌ failure | 失败 |
| #39 | 未知 | ✅ completed | ❌ failure | 失败 |

**关键信息：**
- ✅ 本地已是最新，无需推送
- 🔄 Build #162 正在执行中
- ⚠️ Build #28, #40, #39 失败（需关注）

**下一步：**
- [ ] 监控 Build #162 执行结果
- [ ] 如 Build #162 失败，立即分析原因
- [ ] 关注历史失败构建的原因

---

## 历史状态存档
- 2026-03-20 17:52: 本地同步，Build #162 进行中
- 2026-03-20 17:10: 已推送 2 个提交，构建 #159/#25 排队中
- 详细历史见 `memory/2026-03-20.md`