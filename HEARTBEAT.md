:
HEARTBEAT.md - 定期检查清单

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

## 当前状态（2026-03-21 凌晨 00:47）

### ✅ 推送成功，构建排队中

**Git 状态：**
- 本地分支：与 origin/main 同步 ✅
- 工作树：干净，无需提交
- 推送状态：✅ 已推送（commit e9c4525）

**GitHub Actions：**
| Build | 工作流 | 状态 | 说明 |
|-------|--------|------|------|
| #193 | Build APK | 🟡 queued | 导航修复 #4，排队中 |
| #37 | APK Pre-check | 🟡 queued | 排队中 |
| #71 | APK Pre-check | ⚪ skipped | 旧构建 |

**本次提交内容：**
- 修复 `hightAccuracy` → `highAccuracy` 拼写错误
- 添加 `app_settings` 依赖（版本 5.1.1）
- `recording_model.dart` 添加 material 导入

**⚠️ 历史问题：**
- Build #192 失败（导航修复 #3）
- 等待 #193 构建结果验证修复效果

---

## 历史状态存档
- 2026-03-21 00:47: 推送成功（nav-fix4），Build #193/#37 排队中
- 2026-03-21 00:32: Git状态正常，无需推送；Build #36/#191 失败需排查
- 2026-03-21 00:22: 提交推送成功，Build #190/#35 排队中
- 2026-03-20 23:19: Build #186 进行中，#185 成功
- 详细历史见 `memory/2026-03-20.md` 和 `memory/2026-03-21.md`
