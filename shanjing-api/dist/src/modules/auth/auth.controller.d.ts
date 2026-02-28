import { AuthService } from './auth.service';
import { PhoneRegisterDto, WechatRegisterDto, PhoneLoginDto, WechatLoginDto, RefreshTokenDto, LogoutDto } from './dto';
import { AuthResponse, TokenResponse } from './interfaces/auth.interface';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    registerByPhone(dto: PhoneRegisterDto): Promise<AuthResponse>;
    registerByWechat(dto: WechatRegisterDto): Promise<AuthResponse>;
    loginByPhone(dto: PhoneLoginDto): Promise<AuthResponse>;
    loginByWechat(dto: WechatLoginDto): Promise<AuthResponse>;
    refreshToken(dto: RefreshTokenDto): Promise<TokenResponse>;
    logout(dto: LogoutDto): Promise<{
        success: boolean;
        data: {
            message: string;
        };
    }>;
}
