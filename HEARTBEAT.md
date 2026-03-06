# HEARTBEAT.md - 定期检查清单

## 检查频率
每 20 分钟检查一次

## 收到 Heartbeat 后必须执行（不能只回复 HEARTBEAT_OK）

### 1. 立即检查 GitHub Actions 状态
- [ ] 执行：`curl -s "https://api.github.com/repos/suyustudio/shanjing-app/actions/runs?per_page=3"`
- [ ] 记录构建编号、状态、结论
- [ ] 如有失败，分析原因

### 2. 检查 Push 状态
- [ ] 执行：`git status | grep "ahead"`
- [ ] 如有未 push 的 commit，立即重试
- [ ] 记录 push 结果

### 3. 检查 Memory 记录
- [ ] 检查今日 memory 文件是否存在
- [ ] 如有未记录的工作内容，立即写入
- [ ] **不能只在聊天说"记住了"，必须落盘**

### 4. 主动汇报
- [ ] 构建失败 → 告知用户
- [ ] 需要操作 → 明确说明
- [ ] push 失败 → 请求协助

## 记忆锚点
- **HEARTBEAT_OK ≠ 工作完成**
- **收到 heartbeat = 开始工作**
- **不检查 = 失职**
- **聊天说记住了 ≠ 写入文件**

## 当前状态（2026-03-06 10:20）
| Build | 状态 | 说明 |
|-------|------|------|
| #81 | ✅ success | 构建成功 |
| #80 | ✅ success | 构建成功 |
| #79 | ✅ success | 构建成功 |

## 当前阻塞问题
- Memory 记录机制已修复（2026-03-06）
- 等待用户确认下一步工作

## 下一步
- 补充 3月5日 工作内容 或
- 开始今天的工作
