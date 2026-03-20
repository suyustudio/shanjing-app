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

## 当前状态（2026-03-20 下午 2:47）

### ✅ Build #151 构建成功！

**Git 状态：**
- 本地分支：up to date with origin/main ✅ **刚刚推送2个提交**
- 未跟踪文件：shanjing-test/repo/（无需提交）

**推送记录：**
```
To https://github.com/suyustudio/shanjing-app.git
   954c3b16..56451cce  main -> main
```

**构建状态：**
| Build | 工作流 | 状态 | 提交信息 |
|-------|--------|------|----------|
| **#151** | **Build APK** | **✅ 成功** | docs(heartbeat): update build status |
| #30 | APK Pre-check | ❌ 失败 | docs(heartbeat): update build status |
| #29 | APK Pre-check | ❌ 失败 | fix(navigation): 移除 Polyline 不支持的 dashed 参数 |

**关键信息：**
- Build #151 是最新的成功构建
- Git 本地与远程同步，无需推送
- 今日 memory 文件已存在（2026-03-20.md）
- 刚刚推送的2个提交将触发新的构建

**下一步：**
- [ ] 等待新构建完成
- [ ] 等待用户测试 Build #151 生成的 APK
- [ ] 如测试通过，继续修复其他导航问题

---

## 历史状态存档
- 详细历史见 `memory/2026-03-20.md`
