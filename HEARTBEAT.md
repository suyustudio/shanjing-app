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

## 当前状态（2026-03-20 晚上 10:47）

### ✅ 已推送 API 响应格式更新

**Git 状态：**
- 本地分支：与 origin/main 同步 ✅
- 提交：`82656bee` - fix(api): 统一关注系统响应格式为标准包装 ✅
- 推送状态：成功推送到 origin/main ✅
- 修改内容：添加 wrapResponse 统一响应包装，关注系统接口返回格式统一

**GitHub Actions：**
| Build | 工作流 | 状态 | 说明 |
|-------|--------|------|------|
| **#184** | Build APK | 🔄 in_progress | 新提交触发构建中 |
| #183 | Build APK | ✅ success | 成功 |
| #62 | APK Pre-check | ❌ failure | 失败（辅助工作流）|

**关键信息：**
- ✅ 已推送 API 响应格式更新（commit 82656bee）
- ✅ 关注系统所有接口返回统一为 {success, data, meta} 格式
- 🔄 Build #184 构建中（由本次提交触发）

---

## 历史状态存档
- 2026-03-20 22:47: 已推送关注系统响应格式更新，Build #184 触发
- 2026-03-20 22:07: 已推送 M6-FIX-SUMMARY.md，Build #176 成功
- 2026-03-20 21:07: 已推送 HEARTBEAT 更新，Build #173 成功
- 2026-03-20 20:57: 无未推送提交，Build #173 成功，#52 进行中
- 详细历史见 `memory/2026-03-20.md`
