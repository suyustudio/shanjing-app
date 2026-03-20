# HEARTBEAT.md - 定期检查清单

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

## 当前状态（2026-03-20 下午 2:52）

### 🔄 Build #153 构建中！

**Git 状态：**
- 本地分支：up to date with origin/main ✅ **刚刚推送最新提交**
- 未跟踪文件：shanjing-test/repo/（无需提交）

**推送记录：**
```
[main 4ce00159] docs(heartbeat): update build status
 1 file changed, 10 insertions(+), 3 deletions(-)
To https://github.com/suyustudio/shanjing-app.git
   56451cce..4ce00159  main -> main
```

**构建状态：**
| Build | 工作流 | 状态 | 说明 |
|-------|--------|------|------|
| **#153** | - | **🔄 进行中** | 刚刚推送触发的新构建 |
| #31 | - | ❌ 失败 | 历史失败构建 |
| #23 | - | ❌ 失败 | 历史失败构建 |

**关键信息：**
- 成功推送 HEARTBEAT.md 更新（commit 4ce00159）
- Build #153 正在运行中
- Git 本地与远程同步

**下一步：**
- [ ] 等待 Build #153 完成
- [ ] 检查构建结果
- [ ] 如成功，通知用户测试

---

## 历史状态存档
- 详细历史见 `memory/2026-03-20.md`
