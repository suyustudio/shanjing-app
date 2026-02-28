/**
 * 管理员认证服务
 * 
 * 处理管理员的登录、Token生成和权限验证
 */

import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../database/prisma.service';
import { AdminLoginDto, CreateAdminDto, UpdateAdminDto } from './dto/admin-auth.dto';
import { AdminRole, AdminPermission, hasPermission } from '../admin-role.enum';
import * as crypto from 'crypto';

/**
 * Token 载荷接口
 */
interface AdminTokenPayload {
  sub: string;
  username: string;
  role: AdminRole;
  type: string;
  jti?: string;
}

/**
 * Token 响应接口
 */
interface TokenResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

@Injectable()
export class AdminAuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * 管理员登录
   */
  async login(dto: AdminLoginDto) {
    const { username, password } = dto;

    // 查找管理员
    const admin = await this.prisma.adminUser.findUnique({
      where: { username },
    });

    if (!admin) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'INVALID_CREDENTIALS',
          message: '用户名或密码错误',
        },
      });
    }

    // 检查账号状态
    if (!admin.isActive) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'ACCOUNT_DISABLED',
          message: '账号已被禁用',
        },
      });
    }

    // 验证密码
    const hashedPassword = this.hashPassword(password);
    if (hashedPassword !== admin.passwordHash) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'INVALID_CREDENTIALS',
          message: '用户名或密码错误',
        },
      });
    }

    // 更新最后登录时间
    await this.prisma.adminUser.update({
      where: { id: admin.id },
      data: { lastLoginAt: new Date() },
    });

    // 生成Token
    const tokens = await this.generateTokens(admin.id, admin.username, admin.role as AdminRole);

    return {
      success: true,
      data: {
        admin: {
          id: admin.id,
          username: admin.username,
          nickname: admin.nickname,
          role: admin.role,
        },
        tokens,
      },
    };
  }

  /**
   * 刷新 Token
   */
  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify<AdminTokenPayload>(refreshToken, {
        secret: this.configService.get<string>('ADMIN_JWT_REFRESH_SECRET'),
      });

      if (payload.type !== 'admin_refresh') {
        throw new UnauthorizedException({
          success: false,
          error: {
            code: 'TOKEN_INVALID',
            message: 'Token类型错误',
          },
        });
      }

      // 检查管理员是否存在且启用
      const admin = await this.prisma.adminUser.findUnique({
        where: { id: payload.sub },
      });

      if (!admin || !admin.isActive) {
        throw new UnauthorizedException({
          success: false,
          error: {
            code: 'ACCOUNT_INVALID',
            message: '账号不存在或已被禁用',
          },
        });
      }

      // 生成新Token
      return this.generateTokens(admin.id, admin.username, admin.role as AdminRole);
    } catch (error) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'TOKEN_EXPIRED',
          message: 'Token已过期或无效',
        },
      });
    }
  }

  /**
   * 获取当前管理员信息
   */
  async getAdminInfo(adminId: string) {
    const admin = await this.prisma.adminUser.findUnique({
      where: { id: adminId },
    });

    if (!admin) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'ADMIN_NOT_FOUND',
          message: '管理员不存在',
        },
      });
    }

    return {
      success: true,
      data: {
        id: admin.id,
        username: admin.username,
        nickname: admin.nickname,
        role: admin.role,
        isActive: admin.isActive,
        lastLoginAt: admin.lastLoginAt,
        createdAt: admin.createdAt,
      },
    };
  }

  /**
   * 创建管理员
   * 仅超级管理员可操作
   */
  async createAdmin(dto: CreateAdminDto, currentAdminRole: AdminRole) {
    // 检查权限
    if (currentAdminRole !== AdminRole.SUPER_ADMIN) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'PERMISSION_DENIED',
          message: '只有超级管理员可以创建管理员',
        },
      });
    }

    // 检查用户名是否已存在
    const existingAdmin = await this.prisma.adminUser.findUnique({
      where: { username: dto.username },
    });

    if (existingAdmin) {
      throw new ConflictException({
        success: false,
        error: {
          code: 'USERNAME_EXISTS',
          message: '用户名已存在',
        },
      });
    }

    // 创建管理员
    const admin = await this.prisma.adminUser.create({
      data: {
        username: dto.username,
        passwordHash: this.hashPassword(dto.password),
        nickname: dto.nickname || null,
        role: dto.role,
        isActive: true,
      },
    });

    return {
      success: true,
      data: {
        id: admin.id,
        username: admin.username,
        nickname: admin.nickname,
        role: admin.role,
        isActive: admin.isActive,
        createdAt: admin.createdAt,
      },
    };
  }

  /**
   * 更新管理员
   */
  async updateAdmin(
    adminId: string,
    dto: UpdateAdminDto,
    currentAdminId: string,
    currentAdminRole: AdminRole,
  ) {
    // 检查权限：只能修改自己或下级管理员
    if (currentAdminId !== adminId && currentAdminRole !== AdminRole.SUPER_ADMIN) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'PERMISSION_DENIED',
          message: '无权修改其他管理员',
        },
      });
    }

    // 不能修改自己的角色
    if (currentAdminId === adminId && dto.role) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'CANNOT_MODIFY_SELF_ROLE',
          message: '不能修改自己的角色',
        },
      });
    }

    const admin = await this.prisma.adminUser.findUnique({
      where: { id: adminId },
    });

    if (!admin) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'ADMIN_NOT_FOUND',
          message: '管理员不存在',
        },
      });
    }

    // 更新数据
    const updateData: any = {};
    if (dto.nickname !== undefined) updateData.nickname = dto.nickname;
    if (dto.password) updateData.passwordHash = this.hashPassword(dto.password);
    if (dto.role !== undefined) updateData.role = dto.role;
    if (dto.isActive !== undefined) updateData.isActive = dto.isActive;

    const updatedAdmin = await this.prisma.adminUser.update({
      where: { id: adminId },
      data: updateData,
    });

    return {
      success: true,
      data: {
        id: updatedAdmin.id,
        username: updatedAdmin.username,
        nickname: updatedAdmin.nickname,
        role: updatedAdmin.role,
        isActive: updatedAdmin.isActive,
        lastLoginAt: updatedAdmin.lastLoginAt,
        createdAt: updatedAdmin.createdAt,
      },
    };
  }

  /**
   * 删除管理员
   */
  async deleteAdmin(adminId: string, currentAdminId: string, currentAdminRole: AdminRole) {
    // 不能删除自己
    if (currentAdminId === adminId) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'CANNOT_DELETE_SELF',
          message: '不能删除自己',
        },
      });
    }

    // 仅超级管理员可删除
    if (currentAdminRole !== AdminRole.SUPER_ADMIN) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'PERMISSION_DENIED',
          message: '只有超级管理员可以删除管理员',
        },
      });
    }

    const admin = await this.prisma.adminUser.findUnique({
      where: { id: adminId },
    });

    if (!admin) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'ADMIN_NOT_FOUND',
          message: '管理员不存在',
        },
      });
    }

    await this.prisma.adminUser.delete({
      where: { id: adminId },
    });

    return {
      success: true,
      data: { message: '管理员删除成功' },
    };
  }

  /**
   * 获取管理员列表
   */
  async getAdminList(page: number = 1, limit: number = 20) {
    const skip = (page - 1) * limit;

    const [admins, total] = await Promise.all([
      this.prisma.adminUser.findMany({
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          username: true,
          nickname: true,
          role: true,
          isActive: true,
          lastLoginAt: true,
          createdAt: true,
        },
      }),
      this.prisma.adminUser.count(),
    ]);

    return {
      success: true,
      data: admins,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * 检查管理员权限
   */
  checkPermission(adminRole: AdminRole, permission: AdminPermission): boolean {
    return hasPermission(adminRole, permission);
  }

  /**
   * 生成 Token 对
   */
  private async generateTokens(
    adminId: string,
    username: string,
    role: AdminRole,
  ): Promise<TokenResponse> {
    const accessSecret = this.configService.get<string>('ADMIN_JWT_SECRET');
    const refreshSecret = this.configService.get<string>('ADMIN_JWT_REFRESH_SECRET');
    const accessExpiration = this.configService.get<string>('ADMIN_JWT_EXPIRATION', '2h');
    const refreshExpiration = this.configService.get<string>('ADMIN_JWT_REFRESH_EXPIRATION', '7d');

    const accessPayload: AdminTokenPayload = {
      sub: adminId,
      username,
      role,
      type: 'admin_access',
    };

    const refreshPayload: AdminTokenPayload = {
      sub: adminId,
      username,
      role,
      type: 'admin_refresh',
      jti: crypto.randomUUID(),
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(accessPayload, {
        secret: accessSecret,
        expiresIn: accessExpiration,
      }),
      this.jwtService.signAsync(refreshPayload, {
        secret: refreshSecret,
        expiresIn: refreshExpiration,
      }),
    ]);

    // 解析access token获取过期时间
    const decoded = this.jwtService.decode(accessToken) as { exp: number };
    const expiresIn = decoded.exp - Math.floor(Date.now() / 1000);

    return {
      accessToken,
      refreshToken,
      expiresIn,
    };
  }

  /**
   * 密码哈希
   * 使用 SHA-256 进行简单哈希（生产环境建议使用 bcrypt）
   */
  private hashPassword(password: string): string {
    return crypto.createHash('sha256').update(password).digest('hex');
  }

  /**
   * 初始化默认管理员
   * 在系统启动时调用，创建默认的超级管理员
   */
  async initializeDefaultAdmin() {
    const defaultUsername = this.configService.get<string>('DEFAULT_ADMIN_USERNAME', 'admin');
    const defaultPassword = this.configService.get<string>('DEFAULT_ADMIN_PASSWORD', 'admin123');

    const existingAdmin = await this.prisma.adminUser.findUnique({
      where: { username: defaultUsername },
    });

    if (!existingAdmin) {
      await this.prisma.adminUser.create({
        data: {
          username: defaultUsername,
          passwordHash: this.hashPassword(defaultPassword),
          nickname: '超级管理员',
          role: AdminRole.SUPER_ADMIN,
          isActive: true,
        },
      });
      console.log(`默认管理员已创建: ${defaultUsername}`);
    }
  }
}
