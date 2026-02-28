/**
 * 后台管理模块
 * 
 * 提供后台管理系统的核心功能：
 * - 管理员认证与权限控制
 * - 路线管理（CRUD）
 * - 用户管理
 * - 数据统计
 */

import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AdminAuthController } from './admin-auth.controller';
import { AdminAuthService } from './admin-auth.service';
import { AdminTrailsModule } from './trails/admin-trails.module';

@Module({
  imports: [
    ConfigModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('ADMIN_JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<string>('ADMIN_JWT_EXPIRATION', '2h'),
        },
      }),
      inject: [ConfigService],
    }),
    AdminTrailsModule,
  ],
  controllers: [AdminAuthController],
  providers: [AdminAuthService],
  exports: [AdminAuthService],
})
export class AdminModule {}
