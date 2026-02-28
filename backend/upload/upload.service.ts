// upload.service.ts - 文件上传服务
// 山径APP - 图片上传业务逻辑
// 功能：OSS上传、文件命名、URL生成

import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as OSS from 'ali-oss';
import { v4 as uuidv4 } from 'uuid';
import * as path from 'path';
import {
  UploadResult,
  BatchUploadResult,
  OssConfig,
} from './interfaces/upload.interface';

/**
 * 文件上传服务
 * 
 * 功能说明：
 * 1. 处理单张图片上传到OSS
 * 2. 处理批量图片上传到OSS
 * 3. 生成唯一的文件名和存储路径
 * 4. 返回可访问的URL
 */
@Injectable()
export class UploadService {
  private readonly logger = new Logger(UploadService.name);
  private readonly ossClient: OSS;
  private readonly ossConfig: OssConfig;

  constructor(private readonly configService: ConfigService) {
    // 初始化OSS配置
    this.ossConfig = {
      region: this.configService.get<string>('OSS_REGION', 'oss-cn-hangzhou'),
      accessKeyId: this.configService.get<string>('OSS_ACCESS_KEY_ID') || '',
      accessKeySecret: this.configService.get<string>('OSS_ACCESS_KEY_SECRET') || '',
      bucket: this.configService.get<string>('OSS_BUCKET', 'shanjing-prod'),
      secure: true,
    };

    // 检查必要配置
    if (!this.ossConfig.accessKeyId || !this.ossConfig.accessKeySecret) {
      this.logger.error('OSS配置不完整，请检查环境变量');
      // 开发环境下使用模拟模式
      if (this.configService.get<string>('NODE_ENV') !== 'production') {
        this.logger.warn('当前为开发环境，上传功能将使用模拟模式');
      }
    }

    // 初始化OSS客户端
    try {
      this.ossClient = new OSS(this.ossConfig);
      this.logger.log('OSS客户端初始化成功');
    } catch (error) {
      this.logger.error('OSS客户端初始化失败:', error.message);
      // 开发环境下允许继续运行
      if (this.configService.get<string>('NODE_ENV') === 'production') {
        throw error;
      }
    }
  }

  /**
   * 单张图片上传
   * 
   * @param file - Multer文件对象
   * @param userId - 上传用户ID
   * @returns 上传结果，包含URL和文件信息
   */
  async uploadImage(file: Express.Multer.File, userId: string): Promise<UploadResult> {
    try {
      // 生成存储路径
      const key = this.generateFileKey(file.originalname, userId);
      
      // 上传到OSS
      const result = await this.uploadToOss(key, file.buffer, file.mimetype);
      
      this.logger.log(`图片上传成功: ${key}, 用户: ${userId}`);
      
      return {
        url: result.url,
        key: result.name,
        size: file.size,
        mimeType: file.mimetype,
        originalName: file.originalname,
      };
    } catch (error) {
      this.logger.error(`图片上传失败: ${error.message}`, error.stack);
      throw new BadRequestException({
        success: false,
        error: {
          code: 'UPLOAD_FAILED',
          message: '图片上传失败，请稍后重试',
        },
      });
    }
  }

  /**
   * 批量图片上传
   * 
   * @param files - Multer文件对象数组
   * @param userId - 上传用户ID
   * @returns 批量上传结果
   */
  async uploadMultipleImages(
    files: Express.Multer.File[],
    userId: string,
  ): Promise<BatchUploadResult> {
    const results: UploadResult[] = [];
    const errors: Array<{ index: number; message: string }> = [];

    // 串行上传，避免并发问题
    for (let i = 0; i < files.length; i++) {
      try {
        const result = await this.uploadImage(files[i], userId);
        results.push(result);
      } catch (error) {
        this.logger.error(`批量上传第${i + 1}张图片失败: ${error.message}`);
        errors.push({
          index: i,
          message: error.message || '上传失败',
        });
      }
    }

    // 如果全部失败，抛出异常
    if (results.length === 0 && errors.length > 0) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'UPLOAD_FAILED',
          message: '所有图片上传失败',
          details: errors,
        },
      });
    }

    return {
      urls: results,
      total: files.length,
      successCount: results.length,
      failCount: errors.length,
      errors: errors.length > 0 ? errors : undefined,
    };
  }

  /**
   * 生成文件存储路径
   * 
   * 路径格式：images/{userId}/{date}/{uuid}.{ext}
   * 示例：images/ou_xxx/20250227/a1b2c3d4.jpg
   * 
   * @param originalName - 原始文件名
   * @param userId - 用户ID
   * @returns 生成的文件路径
   */
  private generateFileKey(originalName: string, userId: string): string {
    const date = new Date();
    const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');
    const uuid = uuidv4().replace(/-/g, '').slice(0, 16);
    const ext = path.extname(originalName).toLowerCase() || '.jpg';
    
    // 统一转换为标准扩展名
    const normalizedExt = this.normalizeExtension(ext);
    
    return `images/${userId}/${dateStr}/${uuid}${normalizedExt}`;
  }

  /**
   * 标准化文件扩展名
   * 
   * @param ext - 原始扩展名
   * @returns 标准化后的扩展名
   */
  private normalizeExtension(ext: string): string {
    const extMap: Record<string, string> = {
      '.jpeg': '.jpg',
      '.jpg': '.jpg',
      '.png': '.png',
      '.webp': '.webp',
    };
    
    return extMap[ext.toLowerCase()] || '.jpg';
  }

  /**
   * 上传文件到OSS
   * 
   * @param key - 文件存储路径
   * @param buffer - 文件内容
   * @param mimeType - 文件MIME类型
   * @returns OSS上传结果
   */
  private async uploadToOss(
    key: string,
    buffer: Buffer,
    mimeType: string,
  ): Promise<{ name: string; url: string }> {
    // 开发环境模拟模式
    if (this.configService.get<string>('NODE_ENV') !== 'production' && !this.ossClient) {
      this.logger.warn('开发环境模拟上传，返回模拟URL');
      return {
        name: key,
        url: `https://mock-oss.example.com/${key}`,
      };
    }

    const result = await this.ossClient.put(key, buffer, {
      mime: mimeType,
      headers: {
        // 设置缓存控制
        'Cache-Control': 'public, max-age=31536000', // 1年
        // 设置内容处置（浏览器直接显示）
        'Content-Disposition': 'inline',
      },
    });

    // 构建访问URL
    const url = `https://${this.ossConfig.bucket}.${this.ossConfig.region}.aliyuncs.com/${result.name}`;

    return {
      name: result.name,
      url,
    };
  }

  /**
   * 删除OSS文件
   * 
   * @param key - 文件路径
   */
  async deleteFile(key: string): Promise<void> {
    // 开发环境模拟模式
    if (this.configService.get<string>('NODE_ENV') !== 'production' && !this.ossClient) {
      this.logger.warn(`开发环境模拟删除: ${key}`);
      return;
    }

    try {
      await this.ossClient.delete(key);
      this.logger.log(`文件删除成功: ${key}`);
    } catch (error) {
      this.logger.error(`文件删除失败: ${key}, ${error.message}`);
      throw error;
    }
  }

  /**
   * 获取文件访问URL
   * 
   * @param key - 文件路径
   * @param expires - URL过期时间（秒），默认3600秒
   * @returns 预签名URL
   */
  async getSignedUrl(key: string, expires = 3600): Promise<string> {
    // 开发环境模拟模式
    if (this.configService.get<string>('NODE_ENV') !== 'production' && !this.ossClient) {
      return `https://mock-oss.example.com/${key}`;
    }

    return this.ossClient.signatureUrl(key, {
      expires,
      method: 'GET',
    });
  }
}
