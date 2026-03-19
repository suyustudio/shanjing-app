import { CanActivate, ExecutionContext } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';
import { AdminRole, AdminPermission } from '../admin-role.enum';
export interface AdminRequest extends Request {
    admin?: {
        id: string;
        username: string;
        role: AdminRole;
    };
}
export declare class AdminJwtAuthGuard implements CanActivate {
    private readonly jwtService;
    private readonly configService;
    constructor(jwtService: JwtService, configService: ConfigService);
    canActivate(context: ExecutionContext): Promise<boolean>;
    private extractTokenFromHeader;
}
export declare class AdminPermissionGuard implements CanActivate {
    private readonly requiredPermission;
    constructor(requiredPermission: AdminPermission);
    canActivate(context: ExecutionContext): boolean;
}
export declare class SuperAdminGuard implements CanActivate {
    canActivate(context: ExecutionContext): boolean;
}
