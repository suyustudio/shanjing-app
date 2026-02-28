import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as path from 'path';
import * as fs from 'fs/promises';

@Injectable()
export class FilesService {
  private readonly uploadDir: string;
  private readonly baseUrl: string;

  constructor(private readonly configService: ConfigService) {
    this.uploadDir = this.configService.get<string>('UPLOAD_DIR', './uploads');
    this.baseUrl = this.configService.get<string>('BASE_URL', 'http://localhost:3000');
  }

  /**
   * 上传头像
   */
  async uploadAvatar(file: Express.Multer.File, userId: string): Promise<string> {
    if (!file) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'FILE_REQUIRED',
          message: '请上传文件',
        },
      });
    }

    // 验证文件类型
    const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png'];
    if (!allowedMimes.includes(file.mimetype)) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'INVALID_FILE_TYPE',
          message: '仅支持jpg、jpeg、png格式的图片',
        },
      });
    }

    // 验证文件大小（2MB）
    const maxSize = 2 * 1024 * 1024;
    if (file.size > maxSize) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'FILE_TOO_LARGE',
          message: '文件大小不能超过2MB',
        },
      });
    }

    // 生成文件名
    const ext = path.extname(file.originalname) || '.jpg';
    const filename = `avatar_${userId}_${Date.now()}${ext}`;
    const relativePath = path.join('avatars', filename);
    const fullPath = path.join(this.uploadDir, relativePath);

    // 确保目录存在
    const dir = path.dirname(fullPath);
    await fs.mkdir(dir, { recursive: true });

    // 保存文件
    await fs.writeFile(fullPath, file.buffer);

    // 返回文件URL
    // TODO: 接入真实的OSS服务（如阿里云OSS、MinIO等）
    return `${this.baseUrl}/uploads/${relativePath}`;
  }

  /**
   * 删除文件
   */
  async deleteFile(fileUrl: string): Promise<void> {
    try {
      // 从URL中提取相对路径
      const relativePath = fileUrl.replace(`${this.baseUrl}/uploads/`, '');
      const fullPath = path.join(this.uploadDir, relativePath);
      await fs.unlink(fullPath);
    } catch (error) {
      // 文件不存在或删除失败，忽略错误
    }
  }
}
