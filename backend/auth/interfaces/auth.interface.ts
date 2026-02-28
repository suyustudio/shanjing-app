// interfaces/auth.interface.ts - 注册相关接口定义
// 山径APP - 认证模块类型定义

/**
 * JWT Token Payload
 */
export interface TokenPayload {
  /** 用户ID */
  sub: string;
  /** Token类型: access - 访问令牌, refresh - 刷新令牌 */
  type: 'access' | 'refresh';
  /** Token唯一ID（仅refresh token） */
  jti?: string;
  /** 签发时间 */
  iat?: number;
  /** 过期时间 */
  exp?: number;
}

/**
 * Token响应
 */
export interface TokenResponse {
  /** 访问令牌 */
  accessToken: string;
  /** 刷新令牌 */
  refreshToken: string;
  /** 访问令牌有效期（秒） */
  expiresIn: number;
}

/**
 * 用户信息（脱敏）
 */
export interface UserInfo {
  /** 用户唯一ID */
  id: string;
  /** 用户昵称 */
  nickname?: string;
  /** 头像URL */
  avatarUrl?: string;
  /** 手机号 */
  phone?: string;
  /** 创建时间 */
  createdAt: Date;
}

/**
 * 认证响应
 */
export interface AuthResponse {
  success: boolean;
  data: {
    /** 用户信息 */
    user: UserInfo;
    /** Token信息 */
    tokens: TokenResponse;
  };
}

/**
 * 微信用户信息
 */
export interface WechatUserInfo {
  /** 微信OpenID（用户唯一标识） */
  openid: string;
  /** 微信UnionID（跨应用用户标识） */
  unionid?: string;
  /** 微信昵称 */
  nickname?: string;
  /** 微信头像URL */
  avatarUrl?: string;
}

/**
 * 短信验证码信息（内存存储）
 */
export interface SmsCodeInfo {
  /** 验证码 */
  code: string;
  /** 发送时间戳 */
  sentAt: number;
  /** 过期时间戳 */
  expiresAt: number;
  /** 尝试次数 */
  attemptCount: number;
}
