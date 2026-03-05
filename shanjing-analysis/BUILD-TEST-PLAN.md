# 逐步构建测试计划

## 阶段 1: 最简 Debug 构建 ✅
文件: `.github/workflows/build-test-minimal.yml`
- 基础环境 (Java 17, Flutter 3.19.0)
- 创建 Android 平台
- Debug 构建 (无签名)
- 验证 APK 生成

## 阶段 2: 添加签名配置
- 添加 keystore 生成
- 添加 key.properties
- Release 构建

## 阶段 3: 添加本地新代码
- 离线地图功能
- 性能优化代码
- 图片缓存优化

## 阶段 4: 完整功能构建
- 所有功能集成
- 完整测试

## 当前状态
- 本地代码已提交 (d410e2c9)
- 最简构建配置已创建
- 等待触发构建测试
