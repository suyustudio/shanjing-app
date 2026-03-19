import { AdminRole } from '../admin-role.enum';
export declare class AdminLoginDto {
    username: string;
    password: string;
}
export declare class CreateAdminDto {
    username: string;
    password: string;
    nickname?: string;
    role: AdminRole;
}
export declare class UpdateAdminDto {
    nickname?: string;
    password?: string;
    role?: AdminRole;
    isActive?: boolean;
}
export declare class AdminLoginResponseDto {
    success: boolean;
    errorMessage?: string;
    data: {
        admin: {
            id: string;
            username: string;
            nickname: string | null;
            role: AdminRole;
        };
        tokens: {
            accessToken: string;
            refreshToken: string;
            expiresIn: number;
        };
    };
}
export declare class AdminInfoResponseDto {
    success: boolean;
    data: {
        id: string;
        username: string;
        nickname: string | null;
        role: AdminRole;
        isActive: boolean;
        lastLoginAt: Date | null;
        createdAt: Date;
    };
}
export declare class AdminListResponseDto {
    success: boolean;
    data: Array<{
        id: string;
        username: string;
        nickname: string | null;
        role: AdminRole;
        isActive: boolean;
        lastLoginAt: Date | null;
        createdAt: Date;
    }>;
    meta: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
}
