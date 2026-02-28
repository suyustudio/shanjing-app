import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../database/prisma.service';
import { PhoneRegisterDto, WechatRegisterDto, PhoneLoginDto, WechatLoginDto, LogoutDto } from './dto';
import { AuthResponse, TokenResponse } from './interfaces/auth.interface';
export declare class AuthService {
    private readonly prisma;
    private readonly jwtService;
    private readonly configService;
    constructor(prisma: PrismaService, jwtService: JwtService, configService: ConfigService);
    registerByPhone(dto: PhoneRegisterDto): Promise<AuthResponse>;
    registerByWechat(dto: WechatRegisterDto): Promise<AuthResponse>;
    loginByPhone(dto: PhoneLoginDto): Promise<AuthResponse>;
    loginByWechat(dto: WechatLoginDto): Promise<AuthResponse>;
    refreshToken(refreshToken: string): Promise<TokenResponse>;
    logout(dto: LogoutDto): Promise<void>;
    private generateTokens;
    private verifySmsCode;
    private getWechatUserInfo;
    private sanitizeUser;
}
