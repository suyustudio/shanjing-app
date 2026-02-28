// upload.interface.ts - 文件上传接口定义
// 山径APP - 上传模块类型定义

/**
 * 上传结果
 */
export interface UploadResult {
  /** 文件访问URL */
  url: string;
  /** 文件存储路径（key） */
  key: string;
  /** 文件大小（字节） */
  size: number;
  /** MIME类型 */
  mimeType: string;
  /** 原始文件名 */
  originalName: string;
}

/**
 * 批量上传结果
 */
export interface BatchUploadResult {
  /** 上传成功的文件列表 */
  urls: UploadResult[];
  /** 总文件数 */
  total: number;
  /** 成功数量 */
  successCount: number;
  /** 失败数量 */
  failCount: number;
  /** 错误详情（如果有失败） */
  errors?: Array<{
    index: number;
    message: string;
  }>;
}

/**
 * API响应格式
 */
export interface ApiResponse<T = any> {
  /** 是否成功 */
  success: boolean;
  /** 响应数据 */
  data?: T;
  /** 错误信息 */
  error?: {
    code: string;
    message: string;
    details?: any;
  };
}

/**
 * OSS配置
 */
export interface OssConfig {
  /** OSS区域 */
  region: string;
  /** AccessKey ID */
  accessKeyId: string;
  /** AccessKey Secret */
  accessKeySecret: string;
  /** Bucket名称 */
  bucket: string;
  /** 是否使用HTTPS */
  secure?: boolean;
}

/**
 * 上传配置选项
 */
export interface UploadOptions {
  /** 最大文件大小（字节） */
  maxSize?: number;
  /** 允许的文件类型 */
  allowedTypes?: string[];
  /** 存储路径前缀 */
  pathPrefix?: string;
}

/**
 * 默认上传配置
 */
export const DEFAULT_UPLOAD_OPTIONS: UploadOptions = {
  maxSize: 5 * 1024 * 1024, // 5MB
  allowedTypes: ['image/jpeg', 'image/png', 'image/webp'],
  pathPrefix: 'images',
};
