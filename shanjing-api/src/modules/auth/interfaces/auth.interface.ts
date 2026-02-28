export interface TokenPayload {
  sub: string;      // 用户ID
  type: 'access' | 'refresh';
  jti?: string;     // Token唯一ID（仅refresh token）
  iat?: number;     // 签发时间
  exp?: number;     // 过期时间
}

export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface UserInfo {
  id: string;
  nickname?: string;
  avatarUrl?: string;
  phone?: string;
  createdAt: Date;
}

export interface AuthResponse {
  success: boolean;
  data: {
    user: UserInfo;
    tokens: TokenResponse;
  };
}

export interface WechatUserInfo {
  openid: string;
  unionid?: string;
  nickname?: string;
  avatarUrl?: string;
}
