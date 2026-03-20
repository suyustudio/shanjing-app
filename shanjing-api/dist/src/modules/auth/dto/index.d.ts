export declare class PhoneRegisterDto {
    phone: string;
    code: string;
    nickname?: string;
}
export declare class WechatRegisterDto {
    code: string;
    nickname?: string;
}
export declare class PhoneLoginDto {
    phone: string;
    code: string;
}
export declare class WechatLoginDto {
    code: string;
}
export declare class RefreshTokenDto {
    refreshToken: string;
}
export declare class LogoutDto {
    refreshToken?: string;
    allDevices?: boolean;
}
export declare class PhonePasswordRegisterDto {
    phone: string;
    password: string;
    nickname?: string;
}
export declare class PhonePasswordLoginDto {
    phone: string;
    password: string;
}
