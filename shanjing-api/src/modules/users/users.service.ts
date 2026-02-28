import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { FilesService } from '../files/files.service';
import {
  UpdateUserDto,
  UpdateEmergencyContactsDto,
  BindPhoneDto,
} from './dto';
import { UserResponse, EmergencyContactsResponse, PhoneResponse } from './interfaces/user.interface';

@Injectable()
export class UsersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly filesService: FilesService,
  ) {}

  /**
   * 根据ID获取用户信息
   */
  async getUserById(userId: string): Promise<UserResponse> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: '用户不存在',
        },
      });
    }

    return {
      success: true,
      data: this.sanitizeUser(user),
    };
  }

  /**
   * 更新用户信息
   */
  async updateUser(userId: string, dto: UpdateUserDto): Promise<UserResponse> {
    const { nickname, settings } = dto;

    // 检查用户是否存在
    const existingUser = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!existingUser) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: '用户不存在',
        },
      });
    }

    // 更新用户
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        ...(nickname !== undefined && { nickname }),
        ...(settings !== undefined && { settings }),
      },
    });

    return {
      success: true,
      data: this.sanitizeUser(user),
    };
  }

  /**
   * 上传头像
   */
  async uploadAvatar(
    userId: string,
    file: Express.Multer.File,
  ): Promise<{ success: boolean; data: { avatarUrl: string; updatedAt: Date } }> {
    // 检查用户是否存在
    const existingUser = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!existingUser) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: '用户不存在',
        },
      });
    }

    // 上传文件
    const avatarUrl = await this.filesService.uploadAvatar(file, userId);

    // 更新用户头像
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { avatarUrl },
    });

    return {
      success: true,
      data: {
        avatarUrl,
        updatedAt: user.updatedAt,
      },
    };
  }

  /**
   * 更新紧急联系人
   */
  async updateEmergencyContacts(
    userId: string,
    dto: UpdateEmergencyContactsDto,
  ): Promise<EmergencyContactsResponse> {
    const { contacts } = dto;

    // 检查用户是否存在
    const existingUser = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!existingUser) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: '用户不存在',
        },
      });
    }

    // 验证联系人数据
    if (contacts.length > 3) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'TOO_MANY_CONTACTS',
          message: '紧急联系人最多只能添加3个',
        },
      });
    }

    // 验证手机号格式
    const phoneRegex = /^1[3-9]\d{9}$/;
    for (const contact of contacts) {
      if (!phoneRegex.test(contact.phone)) {
        throw new BadRequestException({
          success: false,
          error: {
            code: 'INVALID_PHONE_FORMAT',
            message: `联系人 ${contact.name} 的手机号格式错误`,
          },
        });
      }
    }

    // 更新紧急联系人
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: {
        emergencyContacts: contacts,
      },
    });

    return {
      success: true,
      data: {
        emergencyContacts: user.emergencyContacts as any[],
        updatedAt: user.updatedAt,
      },
    };
  }

  /**
   * 绑定手机号
   */
  async bindPhone(userId: string, dto: BindPhoneDto): Promise<PhoneResponse> {
    const { phone, code } = dto;

    // 验证验证码
    await this.verifySmsCode(phone, code);

    // 检查手机号是否已被其他用户绑定
    const existingUser = await this.prisma.user.findUnique({
      where: { phone },
    });

    if (existingUser && existingUser.id !== userId) {
      throw new ConflictException({
        success: false,
        error: {
          code: 'PHONE_ALREADY_EXISTS',
          message: '该手机号已被其他账号绑定',
        },
      });
    }

    // 更新手机号
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { phone },
    });

    return {
      success: true,
      data: {
        phone: user.phone,
        updatedAt: user.updatedAt,
      },
    };
  }

  /**
   * 验证短信验证码
   * TODO: 接入真实的短信服务
   */
  private async verifySmsCode(phone: string, code: string): Promise<void> {
    // 测试环境验证码
    const testCode = '123456';
    
    if (code !== testCode) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'INVALID_VERIFICATION_CODE',
          message: '验证码错误或已过期',
        },
      });
    }
  }

  /**
   * 清理用户敏感信息
   */
  private sanitizeUser(user: any) {
    const { wxOpenid, wxUnionid, ...safeUser } = user;
    return safeUser;
  }
}
