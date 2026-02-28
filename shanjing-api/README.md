# 山径APP - 用户系统 API

基于 NestJS + Prisma + PostgreSQL 的用户系统 API。

## 功能特性

- ✅ 手机号注册/登录
- ✅ 微信 OAuth 注册/登录
- ✅ JWT 认证中间件
- ✅ 用户信息管理
- ✅ 头像上传
- ✅ 紧急联系人管理
- ✅ 手机号绑定

## 技术栈

- **框架**: NestJS 10.x
- **语言**: TypeScript 5.x
- **数据库**: PostgreSQL 15+ with PostGIS
- **ORM**: Prisma 5.x
- **认证**: JWT + Passport
- **文档**: Swagger/OpenAPI

## 快速开始

### 1. 安装依赖

```bash
cd shanjing-api
npm install
```

### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，配置数据库连接等信息
```

### 3. 初始化数据库

```bash
# 生成Prisma Client
npm run prisma:generate

# 执行数据库迁移
npm run prisma:migrate
```

### 4. 启动服务

```bash
# 开发模式
npm run start:dev

# 生产模式
npm run build
npm run start:prod
```

### 5. 访问 API 文档

启动后访问: http://localhost:3000/api/docs

## API 接口

### 认证模块

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/v1/auth/register/phone | 手机号注册 |
| POST | /api/v1/auth/register/wechat | 微信注册 |
| POST | /api/v1/auth/login/phone | 手机号登录 |
| POST | /api/v1/auth/login/wechat | 微信登录 |
| POST | /api/v1/auth/refresh | 刷新Token |
| POST | /api/v1/auth/logout | 退出登录 |

### 用户模块

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/v1/users/me | 获取当前用户信息 |
| PUT | /api/v1/users/me | 更新用户信息 |
| PUT | /api/v1/users/me/avatar | 上传头像 |
| PUT | /api/v1/users/me/emergency | 更新紧急联系人 |
| PUT | /api/v1/users/me/phone | 绑定手机号 |

## 项目结构

```
src/
├── modules/
│   ├── auth/              # 认证模块
│   │   ├── dto/           # 数据传输对象
│   │   ├── interfaces/    # 接口定义
│   │   ├── strategies/    # JWT策略
│   │   ├── auth.controller.ts
│   │   ├── auth.module.ts
│   │   └── auth.service.ts
│   ├── users/             # 用户模块
│   │   ├── dto/
│   │   ├── interfaces/
│   │   ├── users.controller.ts
│   │   ├── users.module.ts
│   │   └── users.service.ts
│   └── files/             # 文件模块
│       ├── files.module.ts
│       └── files.service.ts
├── common/                # 公共模块
│   ├── decorators/        # 装饰器
│   ├── filters/           # 异常过滤器
│   ├── guards/            # 守卫
│   ├── interceptors/      # 拦截器
│   └── utils/             # 工具函数
├── database/              # 数据库
│   ├── prisma.module.ts
│   └── prisma.service.ts
├── app.module.ts          # 根模块
└── main.ts                # 入口文件
```

## 测试

```bash
# 单元测试
npm run test

# 测试覆盖率
npm run test:cov

# E2E测试
npm run test:e2e
```

## 环境要求

- Node.js 18+
- PostgreSQL 15+ with PostGIS
- Redis (可选，用于Token黑名单)

## 部署

### Docker 部署

```bash
# 构建镜像
docker build -t shanjing-api .

# 运行容器
docker run -p 3000:3000 --env-file .env shanjing-api
```

### Docker Compose

```bash
docker-compose up -d
```

## 注意事项

1. 生产环境请修改 JWT 密钥
2. 微信登录需要配置真实的微信开放平台应用
3. 短信验证码服务需要接入真实的短信服务商
4. 文件上传建议接入 OSS 服务（阿里云、MinIO 等）

## License

MIT
