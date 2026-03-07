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

## 当前状态（2026-03-07 09:57）
| Build | 状态 | 说明 |
|-------|------|------|
| #95 | ⏸️ 暂停 | APK 仅 20MB，SDK 可能未正确打包 |
| #94 | ❌ 失败 | implementation() 方法找不到 |
| #93 | ✅ success | 无地图功能 |

## 当前阻塞问题
- Build #95 APK 仅 20MB（预期应更大），高德 SDK 可能未正确打包
- 暂停构建尝试，等待 JNI 问题深度分析结果
- 怀疑：flutter create 重新生成项目导致 SDK 未正确集成

## 下一步
- 等待用户确认今日工作安排
