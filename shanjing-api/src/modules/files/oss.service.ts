import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as OSS from 'ali-oss';
import * as sharp from 'sharp';

export interface OssUploadResult {
  url: string;
  thumbnailUrl?: string;
  width: number;
  height: number;
  size: number;
}

export interface PresignedUrlResult {
  uploadUrl: string;
  accessUrl: string;
  thumbnailUrl?: string;
  key: string;
  expires: number;
}

@Injectable()
export class OssService {
  private client: OSS;
  private bucket: string;
  private region: string;
  private baseUrl: string;

  constructor(private readonly configService: ConfigService) {
    this.bucket = this.configService.get<string>('OSS_BUCKET', '');
    this.region = this.configService.get<string>('OSS_REGION', '');
    const accessKeyId = this.configService.get<string>('OSS_ACCESS_KEY_ID', '');
    const accessKeySecret = this.configService.get<string>('OSS_ACCESS_KEY_SECRET', '');
    this.baseUrl = this.configService.get<string>('OSS_BASE_URL', '');

    if (this.bucket && this.region && accessKeyId && accessKeySecret) {
      this.client = new OSS({
        region: this.region,
        accessKeyId,
        accessKeySecret,
        bucket: this.bucket,
      });
    }
  }

  /**
   * 检查 OSS 是否已配置
   */
  isConfigured(): boolean {
    return !!this.client;
  }

  /**
   * 生成照片上传凭证（预签名 URL）
   */
  async generatePhotoUploadUrl(
    userId: string,
    filename: string,
    contentType: string,
  ): Promise<PresignedUrlResult> {
    if (!this.isConfigured()) {
      throw new Error('OSS not configured');
    }

    const ext = filename.split('.').pop() || 'jpg';
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 8);
    const key = `photos/${userId}/${timestamp}_${random}.${ext}`;

    // 生成预签名上传 URL (15分钟有效)
    const uploadUrl = this.client.signatureUrl('PUT', key, {
      expires: 900,
      'Content-Type': contentType,
    });

    const accessUrl = `${this.baseUrl}/${key}`;
    const thumbnailKey = `photos/${userId}/${timestamp}_${random}_thumb.${ext}`;
    const thumbnailUrl = `${this.baseUrl}/${thumbnailKey}`;

    return {
      uploadUrl,
      accessUrl,
      thumbnailUrl,
      key,
      expires: 900,
    };
  }

  /**
   * 批量生成上传凭证
   */
  async generateBatchUploadUrls(
    userId: string,
    files: { filename: string; contentType: string }[],
  ): Promise<PresignedUrlResult[]> {
    const results = await Promise.all(
      files.map((file) =>
        this.generatePhotoUploadUrl(userId, file.filename, file.contentType),
      ),
    );
    return results;
  }

  /**
   * 删除文件
   */
  async deleteFile(fileUrl: string): Promise<void> {
    if (!this.isConfigured()) {
      return;
    }

    try {
      // 从 URL 中提取 key
      const key = fileUrl.replace(`${this.baseUrl}/`, '');
      await this.client.delete(key);

      // 同时删除缩略图
      const thumbKey = key.replace(/\.([^.]+)$/, '_thumb.$1');
      await this.client.delete(thumbKey).catch(() => {
        // 缩略图可能不存在，忽略错误
      });
    } catch (error) {
      console.error('Failed to delete OSS file:', error);
    }
  }

  /**
   * 生成缩略图（服务端处理）
   */
  async generateThumbnail(
    imageBuffer: Buffer,
    maxWidth: number = 400,
  ): Promise<Buffer> {
    return sharp(imageBuffer)
      .resize(maxWidth, null, {
        withoutEnlargement: true,
        fit: 'inside',
      })
      .jpeg({ quality: 80 })
      .toBuffer();
  }

  /**
   * 获取图片尺寸信息
   */
  async getImageMetadata(imageBuffer: Buffer): Promise<{ width: number; height: number }> {
    const metadata = await sharp(imageBuffer).metadata();
    return {
      width: metadata.width || 0,
      height: metadata.height || 0,
    };
  }
}
