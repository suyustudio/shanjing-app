:HEARTBEAT.md - 定期检查清单

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

## 当前状态（2026-03-21 凌晨 01:21）

### ✅ 推送成功，新构建进行中

**Git 状态：**
- 本地分支：与 origin/main 同步 ✅
- 工作树：干净，无需提交
- 推送状态：✅ 已推送（commit 96b1e41f）

**GitHub Actions：**
| Build | 工作流 | 状态 | 说明 |
|-------|--------|------|------|
| #198 | Build APK | 🔄 in_progress | 内存更新推送后触发 |
| #197 | Build APK | ❌ failure | 历史失败 |
| #196 | Build APK | ❌ failure | recording_service.dart 修复 |

**本次提交内容（commit 96b1e41f）：**
- 更新 memory 和 HEARTBEAT 状态记录

**⚠️ 注意：**
- Build #198 正在运行，等待结果
- Build #196/#197 失败原因待排查

---

## 历史状态存档
- 2026-03-21 01:21: 推送 memory 更新（96b1e41f），Build #198 进行中
- 2026-03-21 01:17: Git正常，Build #196/#197 失败，待排查
- 2026-03-21 01:02: 推送 recording_service.dart 修复（c1589b77），Build #196/#39 进行中
- 详细历史见 `memory/2026-03-21.md`
