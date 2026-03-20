// ============================================
// Redis 服务
// ============================================

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

// 简化的 Redis 服务，实际项目中应该使用 ioredis 或 @nestjs/cache-manager
// 这里使用内存 Map 作为演示
@Injectable()
export class RedisService {
  private readonly logger = new Logger(RedisService.name);
  private cache: Map<string, { value: string; expires: number }> = new Map();

  constructor(private configService: ConfigService) {
    // 定期清理过期缓存
    setInterval(() => this.cleanExpired(), 60000);
  }

  async get(key: string): Promise<string | null> {
    const item = this.cache.get(key);
    if (!item) return null;
    
    if (Date.now() > item.expires) {
      this.cache.delete(key);
      return null;
    }
    
    return item.value;
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    const expires = ttlSeconds 
      ? Date.now() + ttlSeconds * 1000 
      : Number.MAX_SAFE_INTEGER;
    this.cache.set(key, { value, expires });
  }

  /**
   * 设置带过期时间的缓存
   */
  async setex(key: string, ttlSeconds: number, value: string): Promise<void> {
    const expires = Date.now() + ttlSeconds * 1000;
    this.cache.set(key, { value, expires });
  }

  async del(...keys: string[]): Promise<void> {
    for (const key of keys) {
      this.cache.delete(key);
    }
  }

  async keys(pattern: string): Promise<string[]> {
    const regex = new RegExp(pattern.replace('*', '.*'));
    return Array.from(this.cache.keys()).filter(key => regex.test(key));
  }

  /**
   * 删除匹配模式的所有键
   */
  async delPattern(pattern: string): Promise<number> {
    const regex = new RegExp(pattern.replace(/\*/g, '.*'));
    const keysToDelete: string[] = [];
    
    for (const key of this.cache.keys()) {
      if (regex.test(key)) {
        keysToDelete.push(key);
      }
    }
    
    for (const key of keysToDelete) {
      this.cache.delete(key);
    }
    
    return keysToDelete.length;
  }

  private cleanExpired(): void {
    const now = Date.now();
    for (const [key, item] of this.cache.entries()) {
      if (now > item.expires) {
        this.cache.delete(key);
      }
    }
  }
}
