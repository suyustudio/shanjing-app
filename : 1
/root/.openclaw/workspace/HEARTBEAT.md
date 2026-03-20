:\nHEARTBEAT.md - 定期检查清单

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

## 当前状态（2026-03-21 凌晨 00:17）

### ✅ 已推送轨迹采集功能，构建进行中

**Git 状态：**
- 本地分支：与 origin/main 同步 ✅
- 提交：**8fea5786** - feat: 轨迹采集功能实现
- 推送状态：✅ 已推送
- 变更：9 files, 3175 insertions(+)

**本次提交内容：**
- 录制前准备页面 (`RecordingPreparationScreen`)
- 权限服务 (`PermissionService`)
- 录制模型更新
- POI标记弹窗优化
- 三方 Review 报告（Product/Design/Dev）

**GitHub Actions：**
| Build | 工作流 | 状态 | 说明 |
|-------|--------|------|------|
| **#189** | Build APK | 🔄 in_progress | 轨迹采集功能构建 |
| **#34** | Debug Build | 🔄 in_progress | 同上 |
| #188 | Build APK | ❌ failure | 旧构建（轨迹采集 MVP）|
| #33 | Debug Build | ❌ failure | 旧构建（已修复）|

**关键信息：**
- ✅ 提交 8fea5786 已推送至 origin/main
- 🔄 Build #189/34 构建中（轨迹采集功能）
- ⚠️ Build #188 失败（旧提交，已修复）

---

## 历史状态存档
- 2026-03-21 00:17: 推送轨迹采集功能，Build #189/34 进行中
- 2026-03-20 23:19: Build #186 进行中，#185 成功
- 2026-03-20 23:12: 无未推送提交，Build #185 成功
- 详细历史见 `memory/2026-03-20.md`