import { AdminAuthService } from './admin-auth.service';
import { AdminInfo } from './decorators/current-admin.decorator';
import { AdminLoginDto, CreateAdminDto, UpdateAdminDto, AdminLoginResponseDto, AdminInfoResponseDto, AdminListResponseDto } from './dto/admin-auth.dto';
export declare class AdminAuthController {
    private readonly adminAuthService;
    constructor(adminAuthService: AdminAuthService);
    login(dto: AdminLoginDto): Promise<AdminLoginResponseDto>;
    refreshToken(refreshToken: string): Promise<{
        accessToken: string;
        refreshToken: string;
        expiresIn: number;
    }>;
    getProfile(adminId: string): Promise<AdminInfoResponseDto>;
    createAdmin(dto: CreateAdminDto, admin: AdminInfo): Promise<{
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
    getAdminList(page?: string, limit?: string): Promise<AdminListResponseDto>;
    updateAdmin(dto: UpdateAdminDto, admin: AdminInfo): Promise<{
        success: boolean;
        message: string;
    }>;
}
