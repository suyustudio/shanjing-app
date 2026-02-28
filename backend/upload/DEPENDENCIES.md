# 上传模块依赖安装说明

## 需要安装的依赖

在 `shanjing-api` 目录下执行以下命令：

```bash
# 安装 OSS SDK
npm install ali-oss

# 安装 UUID 生成器
npm install uuid
npm install --save-dev @types/uuid

# 安装 multer 类型（如果尚未安装）
npm install --save-dev @types/multer
```

## 依赖说明

| 包名 | 版本 | 用途 |
|------|------|------|
| ali-oss | ^6.x | 阿里云 OSS SDK |
| uuid | ^9.x | UUID 生成 |
| @types/uuid | ^9.x | UUID 类型定义 |
| @types/multer | ^1.4.x | Multer 类型定义 |

## 完整依赖列表（添加到 package.json）

```json
{
  "dependencies": {
    "ali-oss": "^6.18.1",
    "uuid": "^9.0.0"
  },
  "devDependencies": {
    "@types/uuid": "^9.0.0"
  }
}
```

## 安装命令

```bash
cd /root/.openclaw/workspace/shanjing-api
npm install ali-oss uuid
npm install --save-dev @types/uuid
```
