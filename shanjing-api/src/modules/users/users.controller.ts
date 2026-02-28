import {
  Controller,
  Get,
  Put,
  Body,
  UseGuards,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import {
  UpdateUserDto,
  UpdateEmergencyContactsDto,
  BindPhoneDto,
} from './dto';
import { UserResponse, EmergencyContactsResponse, PhoneResponse } from './interfaces/user.interface';

@ApiTags('用户')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: '获取当前用户信息' })
  @ApiResponse({ status: 200, description: '获取成功' })
  @ApiResponse({ status: 401, description: '未授权' })
  async getCurrentUser(
    @CurrentUser('userId') userId: string,
  ): Promise<UserResponse> {
    return this.usersService.getUserById(userId);
  }

  @Put('me')
  @ApiOperation({ summary: '更新用户信息' })
  @ApiResponse({ status: 200, description: '更新成功' })
  @ApiResponse({ status: 400, description: '参数错误' })
  @ApiResponse({ status: 401, description: '未授权' })
  async updateUser(
    @CurrentUser('userId') userId: string,
    @Body() dto: UpdateUserDto,
  ): Promise<UserResponse> {
    return this.usersService.updateUser(userId, dto);
  }

  @Put('me/avatar')
  @ApiOperation({ summary: '上传头像' })
  @ApiConsumes('multipart/form-data')
  @ApiResponse({ status: 200, description: '上传成功' })
  @ApiResponse({ status: 400, description: '文件格式错误或文件过大' })
  @ApiResponse({ status: 401, description: '未授权' })
  @UseInterceptors(FileInterceptor('avatar', {
    limits: {
      fileSize: 2 * 1024 * 1024, // 2MB
    },
    fileFilter: (req, file, callback) => {
      const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png'];
      if (allowedMimes.includes(file.mimetype)) {
        callback(null, true);
      } else {
        callback(new Error('仅支持jpg、jpeg、png格式的图片'), false);
      }
    },
  }))
  async uploadAvatar(
    @CurrentUser('userId') userId: string,
    @UploadedFile() file: Express.Multer.File,
  ): Promise<{ success: boolean; data: { avatarUrl: string; updatedAt: Date } }> {
    return this.usersService.uploadAvatar(userId, file);
  }

  @Put('me/emergency')
  @ApiOperation({ summary: '更新紧急联系人' })
  @ApiResponse({ status: 200, description: '更新成功' })
  @ApiResponse({ status: 400, description: '参数错误' })
  @ApiResponse({ status: 401, description: '未授权' })
  async updateEmergencyContacts(
    @CurrentUser('userId') userId: string,
    @Body() dto: UpdateEmergencyContactsDto,
  ): Promise<EmergencyContactsResponse> {
    return this.usersService.updateEmergencyContacts(userId, dto);
  }

  @Put('me/phone')
  @ApiOperation({ summary: '绑定手机号' })
  @ApiResponse({ status: 200, description: '绑定成功' })
  @ApiResponse({ status: 400, description: '验证码错误或手机号格式错误' })
  @ApiResponse({ status: 409, description: '手机号已被其他账号绑定' })
  @ApiResponse({ status: 401, description: '未授权' })
  async bindPhone(
    @CurrentUser('userId') userId: string,
    @Body() dto: BindPhoneDto,
  ): Promise<PhoneResponse> {
    return this.usersService.bindPhone(userId, dto);
  }
}
