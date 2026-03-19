import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../database/prisma.service';
import { AdminLoginDto, CreateAdminDto, UpdateAdminDto } from './dto/admin-auth.dto';
import { AdminRole, AdminPermission } from '../admin-role.enum';
interface TokenResponse {
    accessToken: string;
    refreshToken: string;
    expiresIn: number;
}
export declare class AdminAuthService {
    private readonly prisma;
    private readonly jwtService;
    private readonly configService;
    constructor(prisma: PrismaService, jwtService: JwtService, configService: ConfigService);
    login(dto: AdminLoginDto): Promise<{
        success: boolean;
        data: {
            admin: {
                id: any;
                username: any;
                nickname: any;
                role: any;
            };
            tokens: TokenResponse;
        };
    }>;
    refreshToken(refreshToken: string): Promise<TokenResponse>;
    getAdminInfo(adminId: string): Promise<{
        success: boolean;
        data: {
            id: any;
            username: any;
            nickname: any;
            role: any;
            isActive: any;
            lastLoginAt: any;
            createdAt: any;
        };
    }>;
    createAdmin(dto: CreateAdminDto, currentAdminRole: AdminRole): Promise<{
        success: boolean;
        data: {
            id: any;
            username: any;
            nickname: any;
            role: any;
            isActive: any;
            createdAt: any;
        };
    }>;
    updateAdmin(adminId: string, dto: UpdateAdminDto, currentAdminId: string, currentAdminRole: AdminRole): Promise<{
        success: boolean;
        data: {
            id: any;
            username: any;
            nickname: any;
            role: any;
            isActive: any;
            lastLoginAt: any;
            createdAt: any;
        };
    }>;
    deleteAdmin(adminId: string, currentAdminId: string, currentAdminRole: AdminRole): Promise<{
        success: boolean;
        data: {
            message: string;
        };
    }>;
    getAdminList(page?: number, limit?: number): Promise<{
        success: boolean;
        data: any;
        meta: {
            page: number;
            limit: number;
            total: any;
            totalPages: number;
        };
    }>;
    checkPermission(adminRole: AdminRole, permission: AdminPermission): boolean;
    private generateTokens;
    private hashPassword;
    initializeDefaultAdmin(): Promise<void>;
}
export {};
