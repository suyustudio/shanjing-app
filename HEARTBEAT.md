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

## 当前状态（2026-03-20 晚上 7:57）

### ✅ Git 状态正常，无需推送

**Git 状态：**
- 本地分支：与 origin/main 同步 ✅
- 无未推送的 commit ✅
- 未跟踪文件：`shanjing-test/repo/`（测试目录，无需提交）
- 未暂存修改：无

**GitHub Actions：**
| Build | 工作流 | 状态 | 说明 |
|-------|--------|------|------|
| **#170** | Build APK | ⏳ in_progress | 主构建进行中 |
| **#169** | Build APK | ⏳ in_progress | 主构建进行中 |
| #47 | APK Pre-check | ❌ failure | 辅助工作流，非阻塞 |

**关键信息：**
- ✅ 本地无需推送（已是最新状态）
- ⏳ Build #170 和 #169 进行中
- ⚠️ APK Pre-check #47 失败（非阻塞性）

**下一步：**
- [ ] 等待 Build #170/#169 构建完成
- [ ] 关注构建结果
- [ ] 如有失败，及时分析原因

---

## 历史状态存档
- 2026-03-20 19:57: 无未推送提交，Build #170/#169 进行中
- 2026-03-20 19:52: 已推送 1 个提交，Build #168 成功
- 2026-03-20 19:42: 本地无未推送提交，Build #167 成功
- 2026-03-20 19:27: 本地无未推送提交，Build #166 成功
- 详细历史见 `memory/2026-03-20.md`