// upload.module.ts - 文件上传模块
// 山径APP - 图片上传服务
// 功能：单张/批量图片上传、文件类型校验、大小限制

import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { UploadController } from './upload.controller';
import { UploadService } from './upload.service';

@Module({
  imports: [ConfigModule],
  controllers: [UploadController],
  providers: [UploadService],
  exports: [UploadService],
})
export class UploadModule {}
