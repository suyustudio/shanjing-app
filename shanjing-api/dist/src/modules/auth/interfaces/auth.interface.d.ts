export interface TokenPayload {
    sub: string;
    type: 'access' | 'refresh';
    jti?: string;
    iat?: number;
    exp?: number;
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
