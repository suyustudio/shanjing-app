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

### 3. 更新记录
- [ ] 更新本文件（HEARTBEAT.md）
- [ ] 记录当前构建状态
- [ ] 记录阻塞问题

### 4. 主动汇报
- [ ] 构建失败 → 告知用户
- [ ] 需要操作 → 明确说明
- [ ] push 失败 → 请求协助

## 记忆锚点
- **HEARTBEAT_OK ≠ 工作完成**
- **收到 heartbeat = 开始工作**
- **不检查 = 失职**

## 当前状态（2026-03-05 21:55）
| Build | 状态 | 说明 |
|-------|------|------|
| #81 | 🟡 in_progress | 测试 Firebase Test Lab |
| #80 | ❌ failure | Cloud Tool Results API 未启用 |
| #79 | ❌ failure | 权限问题 |

## 当前阻塞问题
等待 Build #81 结果，Cloud Testing API 已启用

## 下一步
- 等待 Build #81 完成
- 检查 Firebase Test Lab 是否成功运行