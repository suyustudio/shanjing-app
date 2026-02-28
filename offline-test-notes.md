# 离线功能测试准备

> Week 5 Day 5 任务输出
> 参考: gaode-offline-strategy.md

---

## 1. 高德离线地图配置检查

### SDK 依赖确认
```yaml
# pubspec.yaml
dependencies:
  amap_flutter_map: ^3.0.0      # ✅ 已配置
  amap_flutter_location: ^3.0.0  # ✅ 已配置
```

### 离线地图能力
| 层级 | 级别 | 大小 | 山径需求 |
|------|------|------|----------|
| 基础道路 | 13级 | 小 | 可选 |
| 详细道路 | 14-15级 | 中 | ✅ 必需 |
| 地形细节 | 16级 | 大 | 可选 |

### 推荐策略
- **下载范围**: 路线周边 500m
- **下载级别**: 14-15级（步道级别）
- **预估大小**: 5-20MB/路线

---

## 2. 离线地图下载按钮（地图页）

### 按钮位置
- 位置: 地图页右下角控制按钮组上方
- 图标: `Icons.download`
- 触发: 显示离线地图下载弹窗

### 代码实现
```dart
// 在 _buildMapView() 的 Positioned 控制按钮组中添加
_buildControlButton(
  icon: Icons.download,
  onTap: _showOfflineDownloadDialog,
),

void _showOfflineDownloadDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('下载离线地图'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('当前路线: 西湖环湖路线'),
          const SizedBox(height: 8),
          const Text('下载范围: 周边 500m'),
          const Text('地图级别: 14-15级'),
          const SizedBox(height: 8),
          const Text('预估大小: ~12MB'),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _downloadProgress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _startOfflineDownload,
          child: const Text('开始下载'),
        ),
      ],
    ),
  );
}
```

---

## 3. 离线功能测试要点

### 3.1 下载功能测试
| 测试项 | 预期结果 | 优先级 |
|--------|----------|--------|
| 点击下载按钮 | 弹出下载确认弹窗 | P0 |
| 开始下载 | 显示进度条，可取消 | P0 |
| 下载完成 | 提示成功，保存到本地 | P0 |
| 重复下载 | 提示"已下载"或覆盖确认 | P1 |
| 存储空间不足 | 提示清理空间 | P1 |
| 下载中断 | 支持断点续传或重新下载 | P2 |

### 3.2 离线使用测试
| 测试项 | 预期结果 | 优先级 |
|--------|----------|--------|
| 开启飞行模式 | 地图正常显示 | P0 |
| 定位功能 | GPS定位可用（无需网络） | P0 |
| 路线显示 | 已下载路线正常渲染 | P0 |
| 未下载区域 | 显示空白或提示下载 | P1 |
| 缩放操作 | 离线级别内流畅缩放 | P0 |

### 3.3 边界情况
| 场景 | 处理方式 |
|------|----------|
| 弱网环境 | 优先使用离线数据 |
| 部分下载 | 已下载区域显示，其他区域空白 |
| 数据过期 | 提示更新离线包 |

---

## 4. 测试环境准备

### 设备要求
- Android 10+ / iOS 14+
- 存储空间 > 500MB
- 支持 GPS 定位

### 测试数据
- 至少 3 条不同路线离线包
- 覆盖 easy/moderate/hard 难度

### 网络环境
- 正常网络（下载测试）
- 飞行模式（离线使用测试）
- 弱网环境（边界测试）

---

## 5. 下一步行动

1. **开发**: 实现离线下载按钮和弹窗 UI
2. **集成**: 接入高德离线地图 SDK 接口
3. **测试**: 按上述要点执行功能测试
4. **优化**: 根据测试结果调整下载策略

---

*文档生成时间: 2026-02-28*
