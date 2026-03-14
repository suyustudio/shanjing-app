# 山径APP - M3 用户系统 PRD

> **文档版本**: v1.0  
> **制定日期**: 2026-03-14  
> **文档状态**: 已完成  
> **对应阶段**: M3 用户系统完善

---

## 1. 用户系统概述

### 1.1 目标
构建安全、便捷、合规的用户系统，支持微信一键登录和手机号绑定，确保用户数据隐私安全，提供流畅的登录体验。

### 1.2 用户旅程

```
首次使用
    │
    ▼
┌─────────────────┐
│  启动APP        │
│  展示功能介绍   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  微信一键登录   │ ←── 推荐方式，2秒完成
│  或手机号注册   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  设置紧急联系人 │ ←── 引导完成，可跳过
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  进入首页       │ ←── 开始使用
└─────────────────┘
```

### 1.3 登录方式优先级

| 登录方式 | 优先级 | 适用场景 | 转化率目标 |
|----------|--------|----------|------------|
| **微信一键登录** | P0 | 首次登录、快速登录 | >80% |
| **手机号+验证码** | P0 | 绑定手机号、找回账号 | >90% |
| **Token自动登录** | P0 | 7天内再次启动 | >95% |

---

## 2. 登录/注册流程

### 2.1 微信登录流程

```
用户点击"微信登录"
        │
        ▼
┌───────────────┐
│ 调起微信授权  │
│ 获取Auth Code │
└───────┬───────┘
        │
        ▼
┌───────────────┐     ┌─────────────────┐
│ 后端用Code换取│────▶│ 微信AccessToken │
│ 微信用户信息  │     │ 和OpenID        │
└───────┬───────┘     └─────────────────┘
        │
        ▼
┌───────────────┐     ┌─────────────────┐
│ 查询数据库    │────▶│ 新用户? ──Yes──▶│ 自动注册
│ OpenID存在?   │     │                 │
└───────┬───────┘     └────────┬────────┘
        │ No                   │
        ▼                      │
┌───────────────┐              │
│ 老用户直接登录 │◀─────────────┘
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ 下发JWT Token │
│ Access + Refresh│
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ 登录成功      │
│ 进入首页      │
└───────────────┘
```

### 2.2 手机号登录流程

```
用户输入手机号
        │
        ▼
┌───────────────┐
│ 验证手机号格式 │
│ (11位数字)    │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ 发送验证码    │
│ 60秒倒计时    │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ 用户输入验证码 │
│ (6位数字)     │
└───────┬───────┘
        │
        ▼
┌───────────────┐     ┌─────────────────┐
│ 验证验证码    │────▶│ 错误? ──Yes──▶ │ 提示重试
│               │     │ 最多5次/小时   │
└───────┬───────┘     └─────────────────┘
        │
        ▼
┌───────────────┐     ┌─────────────────┐
│ 查询手机号    │────▶│ 新用户? ──Yes──▶│ 自动注册
│ 是否已注册    │     │                 │
└───────┬───────┘     └────────┬────────┘
        │ No                   │
        ▼                      │
┌───────────────┐              │
│ 老用户直接登录 │◀─────────────┘
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ 下发JWT Token │
└───────┬───────┘
        │
        ▼
┌───────────────┐
│ 登录成功      │
└───────────────┘
```

### 2.3 登录异常处理

| 异常场景 | 处理策略 | 用户提示 |
|----------|----------|----------|
| 微信未安装 | 提示下载微信或换手机号登录 | "请先安装微信或使用手机验证码登录" |
| 微信授权取消 | 返回登录页，无提示 | - |
| 微信授权失败 | 提示重试 | "微信授权失败，请重试" |
| 验证码错误 | 剩余次数提示 | "验证码错误，还剩3次机会" |
| 验证码过期 | 提示重新获取 | "验证码已过期，请重新获取" |
| 请求频率限制 | 倒计时提示 | "操作太频繁，请60秒后重试" |
| 网络异常 | 提示检查网络 | "网络连接失败，请检查网络" |
| Token过期 | 自动刷新或跳转登录 | 静默处理 |

---

## 3. 第三方登录规范（微信登录）

### 3.1 微信开放平台配置

#### 必需信息

| 配置项 | 说明 | 获取方式 |
|--------|------|----------|
| AppID | 微信应用标识 | 微信开放平台申请 |
| AppSecret | 应用密钥 | 后台配置，不外传 |
| Universal Link | iOS深度链接 | 域名备案后配置 |
| 应用签名 | Android签名MD5 | keytool生成 |

#### 权限申请

| 权限 | 用途 | 必要性 |
|------|------|--------|
| snsapi_userinfo | 获取用户昵称、头像 | 必需 |
| snsapi_base | 静默获取OpenID | 可选 |

### 3.2 微信登录技术规范

#### 客户端集成

**iOS配置**
```xml
<!-- Info.plist -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>weixin</string>
    <string>weixinULAPI</string>
</array>

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>weixin</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>wx{YOUR_APP_ID}</string>
    </array>
  </dict>
</array>
```

**Android配置**
```xml
<!-- AndroidManifest.xml -->
<activity
    android:name=".wxapi.WXEntryActivity"
    android:exported="true"
    android:launchMode="singleTask"
    android:taskAffinity="com.shanjing.app" />
```

#### 推荐插件

| 插件 | 版本 | 理由 |
|------|------|------|
| fluwx | ^4.5.5 | 社区活跃，支持鸿蒙，功能全面 |

#### 登录流程代码示例

```dart
// 初始化
final fluwx = Fluwx();
await fluwx.registerApi(
  appId: "wx{APP_ID}",
  universalLink: "https://shanjing.app/link/",
);

// 发起登录
Future<void> loginWithWechat() async {
  Analytics.trackEvent('login_start', {'type': 'wechat'});
  
  try {
    await fluwx.authBy(which: NormalAuth);
  } catch (e) {
    Analytics.trackEvent('login_fail', {
      'type': 'wechat',
      'reason': 'auth_exception',
    });
    showToast('微信授权失败');
  }
}

// 监听回调
fluwx.addSubscriber((response) {
  if (response is WeChatAuthResponse) {
    if (response.errCode == 0) {
      // 成功，获取code传给后端
      _handleWechatAuthSuccess(response.code!);
    } else if (response.errCode == -4) {
      // 用户取消
      Analytics.trackEvent('login_cancel', {'type': 'wechat'});
    } else {
      // 其他错误
      Analytics.trackEvent('login_fail', {
        'type': 'wechat',
        'code': response.errCode,
      });
    }
  }
});

// 后端换取Token
Future<void> _handleWechatAuthSuccess(String code) async {
  final result = await apiService.post('/auth/login/wechat', {
    'code': code,
  });
  
  if (result.success) {
    await _saveTokens(result.data['tokens']);
    Analytics.trackEvent('login_success', {
      'type': 'wechat',
      'is_new': result.data['is_new_user'],
    });
    navigator.pushReplacementNamed('/home');
  }
}
```

### 3.3 微信登录安全规范

| 安全措施 | 说明 |
|----------|------|
| Code一次性使用 | 每个Code只能换取一次Token |
| Code 5分钟过期 | 超时需重新授权 |
| 服务器端换取 | AppSecret不可存储在客户端 |
| 绑定验证 | 新设备登录需验证（可选） |

---

## 4. 用户隐私政策条款

### 4.1 隐私政策结构

```
隐私政策
├── 1. 引言
├── 2. 我们收集的信息
│   ├── 2.1 您提供的信息
│   ├── 2.2 我们自动收集的信息
│   └── 2.3 第三方SDK信息
├── 3. 我们如何使用信息
├── 4. 信息共享与披露
├── 5. 您的权利
├── 6. 数据安全
├── 7. 数据保留
├── 8. 未成年人保护
├── 9. 联系我们
└── 10. 政策更新
```

### 4.2 关键条款

#### 2.1 收集的信息清单

| 信息类型 | 具体字段 | 用途 | 是否必需 |
|----------|----------|------|----------|
| **账号信息** | 微信OpenID、UnionID | 身份识别 | 是 |
| **联系信息** | 手机号 | 安全联系、找回账号 | 否 |
| **个人资料** | 昵称、头像 | 社区展示 | 否 |
| **紧急联系人** | 姓名、手机号 | SOS功能 | 否 |
| **位置信息** | GPS坐标 | 导航、轨迹记录 | 是 |
| **设备信息** | 设备型号、系统版本 | 兼容性优化 | 是 |
| **使用数据** | 点击、浏览、功能使用 | 产品优化 | 是 |

#### 2.2 权限说明

| 权限 | 用途 | 触发时机 |
|------|------|----------|
| **位置权限** | 导航、轨迹记录 | 首次使用导航时 |
| **存储权限** | 保存分享图片、离线包 | 下载离线包时 |
| **相机权限** | 拍照标记、上传头像 | 使用相机时 |
| **麦克风权限** | 语音播报TTS | 不需要 |

#### 3. 信息使用目的

我们使用您的信息用于：
1. **核心功能**: 提供导航、路线查询、轨迹记录服务
2. **安全保障**: 紧急联系人通知、行程分享
3. **服务优化**: 改进产品功能、修复问题
4. **法律合规**: 响应法律要求、保护权益

**我们承诺不：**
- 出售您的个人信息
- 将位置数据用于广告推送
- 向第三方分享可识别个人身份的信息

#### 4. 第三方SDK

| SDK名称 | 用途 | 收集信息 | 隐私政策 |
|---------|------|----------|----------|
| 微信SDK | 登录、分享 | OpenID、设备信息 | 微信隐私政策 |
| 高德SDK | 地图、定位 | GPS位置、设备信息 | 高德隐私政策 |
| 极光推送 | 消息推送 | 设备标识 | 极光隐私政策 |

#### 5. 用户权利

您拥有以下权利：
- **查看**: 查看您的个人数据
- **更正**: 修改不准确的信息
- **删除**: 删除账号及关联数据
- **导出**: 导出您的轨迹数据（GPX格式）
- **撤回同意**: 撤回隐私政策同意（将导致账号注销）

### 4.3 用户同意流程

```
首次启动APP
      │
      ▼
┌─────────────────┐
│ 功能介绍页      │
│ (可跳过)        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 隐私政策弹窗    │ ←── 必须同意
│ - 核心条款摘要  │
│ - 查看完整政策  │
│ - 同意/不同意   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐ ┌───────────┐
│ 同意   │ │ 不同意    │
│        │ │           │
│ 继续   │ │ 退出APP   │
└───────┘ └───────────┘
         │
         ▼
┌─────────────────┐
│ 登录页          │
└─────────────────┘
```

---

## 5. Token管理策略

### 5.1 Token体系设计

```
┌─────────────────────────────────────────────────────┐
│                   Token 体系                         │
├─────────────────────────────────────────────────────┤
│                                                     │
│   ┌─────────────┐         ┌─────────────┐          │
│   │ Access Token │         │ Refresh Token│          │
│   │  (访问令牌)  │         │  (刷新令牌)  │          │
│   ├─────────────┤         ├─────────────┤          │
│   │ 有效期: 2小时│         │ 有效期: 7天 │          │
│   │ 用途: API访问│         │ 用途: 刷新  │          │
│   │ 存储: 内存   │         │ 存储: 安全存储│         │
│   │ 携带: 每次请求│        │ 携带: 仅刷新 │          │
│   └─────────────┘         └─────────────┘          │
│          │                        │                │
│          └────────┬───────────────┘                │
│                   │                                │
│                   ▼                                │
│          ┌─────────────┐                          │
│          │  双Token机制 │                          │
│          │  安全 + 便捷 │                          │
│          └─────────────┘                          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 5.2 Token生成规范

#### Access Token

```typescript
interface AccessTokenPayload {
  sub: string;        // 用户ID
  type: 'access';     // Token类型
  iat: number;        // 签发时间
  exp: number;        // 过期时间 (iat + 2小时)
  jti: string;        // Token唯一标识
}

// Header
{
  "alg": "HS256",
  "typ": "JWT"
}

// Payload示例
{
  "sub": "clu1234567890abcdef",
  "type": "access",
  "iat": 1709059200,
  "exp": 1709066400,
  "jti": "token_abc123"
}
```

#### Refresh Token

```typescript
interface RefreshTokenPayload {
  sub: string;        // 用户ID
  type: 'refresh';    // Token类型
  iat: number;        // 签发时间
  exp: number;        // 过期时间 (iat + 7天)
  jti: string;        // Token唯一标识
  device_id?: string; // 设备标识（可选）
}
```

### 5.3 Token生命周期管理

```
用户登录成功
      │
      ▼
┌─────────────────┐
│ 下发双Token     │
│ Access + Refresh│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Access存储内存  │
│ Refresh存储本地 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 正常使用期间    │
│ 每次请求携带    │
│ Authorization   │
│ Bearer <token>  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│ Access过期?     │────▶│ 使用Refresh换取 │
│ (401响应)       │     │ 新的双Token     │
└────────┬────────┘     └─────────────────┘
         │ No
         ▼
┌─────────────────┐
│ Refresh过期?    │────▶ 跳转登录页
│                 │
└────────┬────────┘
         │ No
         ▼
┌─────────────────┐
│ 继续正常使用    │
└─────────────────┘
```

### 5.4 Token安全策略

| 安全措施 | 实现方式 |
|----------|----------|
| **传输加密** | 所有Token通过HTTPS传输 |
| **存储安全** | Refresh Token使用Keychain(iOS)/Keystore(Android) |
| **Token绑定** | Refresh Token可绑定设备ID |
| **黑名单机制** | 登出时将Token加入黑名单 |
| **过期刷新** | Access Token 2小时过期，Refresh Token 7天过期 |
| **并发控制** | 同一时间最多5个有效Refresh Token |

### 5.5 Token刷新代码示例

```dart
class TokenManager {
  String? _accessToken;
  String? _refreshToken;
  
  // 获取Access Token（自动刷新）
  Future<String> getAccessToken() async {
    // 检查内存中的token
    if (_accessToken != null && !_isExpired(_accessToken!)) {
      return _accessToken!;
    }
    
    // 需要刷新
    return await _refreshTokens();
  }
  
  // 刷新Token
  Future<String> _refreshTokens() async {
    final refreshToken = await _getStoredRefreshToken();
    if (refreshToken == null) {
      throw AuthException('No refresh token');
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        body: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['accessToken'];
        _refreshToken = data['refreshToken'];
        await _storeRefreshToken(_refreshToken!);
        return _accessToken!;
      } else if (response.statusCode == 401) {
        // Refresh token过期，需要重新登录
        await logout();
        throw AuthException('Session expired');
      }
    } catch (e) {
      throw AuthException('Token refresh failed: $e');
    }
    
    throw AuthException('Unknown error');
  }
  
  // 登出
  Future<void> logout() async {
    try {
      // 通知后端登出
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
    } finally {
      // 清除本地存储
      _accessToken = null;
      _refreshToken = null;
      await _clearStoredTokens();
    }
  }
}
```

### 5.6 Token相关错误处理

| 错误码 | HTTP状态 | 说明 | 客户端处理 |
|--------|----------|------|------------|
| TOKEN_EXPIRED | 401 | Access Token过期 | 自动刷新 |
| TOKEN_INVALID | 401 | Token格式错误 | 跳转登录 |
| TOKEN_BLACKLISTED | 401 | Token已登出 | 跳转登录 |
| REFRESH_EXPIRED | 401 | Refresh Token过期 | 跳转登录 |
| REFRESH_INVALID | 401 | Refresh Token无效 | 跳转登录 |

---

## 6. 用户界面规范

### 6.1 登录页面

#### 页面结构

```
┌─────────────────────────────────┐
│                                 │
│      ┌─────────────────┐       │
│      │                 │       │
│      │    APP Logo     │       │
│      │                 │       │
│      └─────────────────┘       │
│                                 │
│      "发现身边的徒步路线"        │
│                                 │
│      ┌─────────────────┐       │
│      │  📱 手机号登录   │       │
│      └─────────────────┘       │
│                                 │
│      ┌─────────────────┐       │
│      │  💬 微信一键登录 │       │ ← 主按钮
│      └─────────────────┘       │
│                                 │
│      登录即表示同意《用户协议》  │
│      和《隐私政策》             │
│                                 │
└─────────────────────────────────┘
```

#### 交互规范

| 元素 | 交互 | 反馈 |
|------|------|------|
| 微信登录按钮 | 点击 | 调起微信授权页 |
| 手机号登录 | 点击 | 进入手机号输入页 |
| 用户协议/隐私政策 | 点击 | 打开对应文档页 |
| 返回 | 点击 | 退出APP（首次） |

### 6.2 手机号输入页面

```
┌─────────────────────────────────┐
│  ← 返回                         │
│                                 │
│      请输入手机号               │
│                                 │
│      ┌─────────────────┐       │
│      │ +86 │ 138xxxx   │       │
│      └─────────────────┘       │
│                                 │
│      ┌─────────────────┐       │
│      │  获取验证码     │       │ ← 60秒倒计时
│      └─────────────────┘       │
│                                 │
│      验证码已发送至 138****8888 │
│                                 │
│      ┌─────────────────┐       │
│      │  □ □ □ □ □ □   │       │ ← 验证码输入
│      └─────────────────┘       │
│                                 │
└─────────────────────────────────┘
```

---

## 7. 附录

### 7.1 API端点清单

| 方法 | 端点 | 说明 | 认证 |
|------|------|------|------|
| POST | /auth/login/wechat | 微信登录 | 否 |
| POST | /auth/login/phone | 手机号登录 | 否 |
| POST | /auth/register/phone | 手机号注册 | 否 |
| POST | /auth/refresh | 刷新Token | 否 |
| POST | /auth/logout | 退出登录 | 是 |
| GET | /users/me | 获取用户信息 | 是 |
| PUT | /users/me | 更新用户信息 | 是 |
| PUT | /users/me/avatar | 上传头像 | 是 |
| PUT | /users/me/phone | 绑定手机号 | 是 |

### 7.2 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-14 | M3用户系统PRD初版 |

---

> **"安全第一，体验优先"** - 山径APP用户系统设计理念
