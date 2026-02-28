// upload.controller.ts - 文件上传控制器
// 山径APP - 图片上传API
// 接口：POST /upload/image (单张) / POST /upload/images (批量)

import {
  Controller,
  Post,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  UploadedFiles,
  BadRequestException,
  ParseFilePipe,
  FileTypeValidator,
  MaxFileSizeValidator,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { UploadService } from './upload.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser, UserPayload } from '../common/decorators/current-user.decorator';
import { ApiResponse } from './interfaces/upload.interface';

/**
 * 文件上传控制器
 * 
 * 功能说明：
 * 1. 单张图片上传 - POST /upload/image
 * 2. 批量图片上传 - POST /upload/images (最多9张)
 * 
 * 认证要求：
 * - 需要JWT认证
 * - 通过Authorization: Bearer <token>头部传递
 * 
 * 限制说明：
 * - 支持格式：JPG、PNG、WebP
 * - 单文件最大：5MB
 * - 批量上传：最多9张
 */
@Controller('upload')
@UseGuards(JwtAuthGuard)
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  /**
   * 单张图片上传
   * 
   * 请求方式：POST /upload/image
   * Content-Type: multipart/form-data
   * 
   * 请求参数：
   * - file: 图片文件 (必填)
   * 
   * 响应示例：
   * {
   *   "success": true,
   *   "data": {
   *     "url": "https://shanjing-oss.oss-cn-hangzhou.aliyuncs.com/images/xxx.jpg",
   *     "key": "images/xxx.jpg",
   *     "size": 1024567,
   *     "mimeType": "image/jpeg",
   *     "originalName": "photo.jpg"
   *   }
   * }
   * 
   * 错误码：
   * - FILE_TOO_LARGE: 文件超过5MB
   * - INVALID_FILE_TYPE: 不支持的文件格式
   * - UPLOAD_FAILED: 上传失败
   */
  @Post('image')
  @UseInterceptors(FileInterceptor('file'))
  async uploadSingleImage(
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          // 最大5MB
          new MaxFileSizeValidator({ maxSize: 5 * 1024 * 1024 }),
          // 只允许JPG、PNG、WebP
          new FileTypeValidator({ fileType: /^(image\/(jpeg|png|webp))$/ }),
        ],
        exceptionFactory: (error) => {
          if (error.message.includes('size')) {
            return new BadRequestException({
              success: false,
              error: {
                code: 'FILE_TOO_LARGE',
                message: '图片大小不能超过5MB',
              },
            });
          }
          if (error.message.includes('type')) {
            return new BadRequestException({
              success: false,
              error: {
                code: 'INVALID_FILE_TYPE',
                message: '仅支持 JPG、PNG、WebP 格式的图片',
              },
            });
          }
          return new BadRequestException({
            success: false,
            error: {
              code: 'FILE_VALIDATION_FAILED',
              message: '文件验证失败',
            },
          });
        },
      }),
    )
    file: Express.Multer.File,
    @CurrentUser() user: UserPayload,
  ): Promise<ApiResponse> {
    const result = await this.uploadService.uploadImage(file, user.userId);
    return {
      success: true,
      data: result,
    };
  }

  /**
   * 批量图片上传
   * 
   * 请求方式：POST /upload/images
   * Content-Type: multipart/form-data
   * 
   * 请求参数：
   * - files: 图片文件数组 (必填，最多9张)
   * 
   * 响应示例：
   * {
   *   "success": true,
   *   "data": {
   *     "urls": [
   *       {
   *         "url": "https://shanjing-oss.oss-cn-hangzhou.aliyuncs.com/images/xxx1.jpg",
   *         "key": "images/xxx1.jpg",
   *         "size": 1024567,
   *         "mimeType": "image/jpeg",
   *         "originalName": "photo1.jpg"
   *       },
   *       {
   *         "url": "https://shanjing-oss.oss-cn-hangzhou.aliyuncs.com/images/xxx2.jpg",
   *         "key": "images/xxx2.jpg",
   *         "size": 2048567,
   *         "mimeType": "image/png",
   *         "originalName": "photo2.png"
   *       }
   *     ],
   *     "total": 2,
   *     "successCount": 2,
   *     "failCount": 0
   *   }
   * }
   * 
   * 错误码：
   * - TOO_MANY_FILES: 超过9张图片
   * - FILE_TOO_LARGE: 某张图片超过5MB
   * - INVALID_FILE_TYPE: 不支持的文件格式
   * - PARTIAL_UPLOAD_FAILED: 部分上传失败
   */
  @Post('images')
  @UseInterceptors(FilesInterceptor('files', 9))
  async uploadMultipleImages(
    @UploadedFiles()
    files: Express.Multer.File[],
    @CurrentUser() user: UserPayload,
  ): Promise<ApiResponse> {
    // 检查是否有文件
    if (!files || files.length === 0) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'NO_FILES',
          message: '请选择要上传的图片',
        },
      });
    }

    // 检查文件数量
    if (files.length > 9) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'TOO_MANY_FILES',
          message: '一次最多只能上传9张图片',
        },
      });
    }

    // 验证每个文件
    const validationErrors: Array<{ index: number; message: string }> = [];
    
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      
      // 检查文件大小
      if (file.size > 5 * 1024 * 1024) {
        validationErrors.push({
          index: i,
          message: `第${i + 1}张图片超过5MB限制`,
        });
        continue;
      }
      
      // 检查文件类型
      const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
      if (!allowedTypes.includes(file.mimetype)) {
        validationErrors.push({
          index: i,
          message: `第${i + 1}张图片格式不支持，仅支持JPG、PNG、WebP`,
        });
      }
    }

    // 如果有验证错误，返回错误信息
    if (validationErrors.length > 0) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'FILE_VALIDATION_FAILED',
          message: '部分文件验证失败',
          details: validationErrors,
        },
      });
    }

    // 批量上传
    const results = await this.uploadService.uploadMultipleImages(files, user.userId);
    
    return {
      success: true,
      data: results,
    };
  }
}
