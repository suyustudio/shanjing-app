import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';

/**
 * 高德地图配置接口
 */
export interface AmapConfig {
  /** 高德地图 API Key */
  apiKey: string;
  /** 安全密钥（可选，用于数字签名） */
  securityConfig?: string;
  /** API 基础 URL */
  baseUrl: string;
  /** 请求超时时间（毫秒） */
  timeout: number;
  /** 是否启用日志 */
  enableLog: boolean;
}

/**
 * 高德地图配置服务
 * 
 * 负责加载和管理高德地图 API 的配置信息
 * 支持从环境变量读取配置
 */
@Injectable()
export class AmapConfigService {
  private readonly logger = new Logger(AmapConfigService.name);
  private readonly config: AmapConfig;

  constructor(private readonly configService: ConfigService) {
    this.config = this.loadConfig();
    this.validateConfig();
    
    if (this.config.enableLog) {
      this.logger.log('高德地图配置已加载');
    }
  }

  /**
   * 从环境变量加载配置
   */
  private loadConfig(): AmapConfig {
    return {
      apiKey: this.configService.get<string>('AMAP_API_KEY', ''),
      securityConfig: this.configService.get<string>('AMAP_SECURITY_CONFIG', ''),
      baseUrl: this.configService.get<string>('AMAP_BASE_URL', 'https://restapi.amap.com/v3'),
      timeout: this.configService.get<number>('AMAP_TIMEOUT', 10000),
      enableLog: this.configService.get<boolean>('AMAP_ENABLE_LOG', false),
    };
  }

  /**
   * 验证配置有效性
   */
  private validateConfig(): void {
    if (!this.config.apiKey) {
      this.logger.error('高德地图 API Key 未配置，请在环境变量中设置 AMAP_API_KEY');
      throw new Error('AMAP_API_KEY is required');
    }

    if (this.config.enableLog) {
      this.logger.log(`高德地图 API 基础地址: ${this.config.baseUrl}`);
    }
  }

  /**
   * 获取完整配置
   */
  getConfig(): AmapConfig {
    return { ...this.config };
  }

  /**
   * 获取 API Key
   */
  getApiKey(): string {
    return this.config.apiKey;
  }

  /**
   * 获取 API 基础 URL
   */
  getBaseUrl(): string {
    return this.config.baseUrl;
  }

  /**
   * 获取请求超时时间
   */
  getTimeout(): number {
    return this.config.timeout;
  }

  /**
   * 是否启用日志
   */
  isLogEnabled(): boolean {
    return this.config.enableLog;
  }
}
