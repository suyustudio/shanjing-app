// ============================================
// Redis 服务 (Enhanced with Cache Tags)
// ============================================

import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

// 简化的 Redis 服务，实际项目中应该使用 ioredis 或 @nestjs/cache-manager
// 这里使用内存 Map 作为演示
@Injectable()
export class RedisService {
  private readonly logger = new Logger(RedisService.name);
  private cache: Map<string, { value: string; expires: number; tags?: string[] }> = new Map();
  private tagIndex: Map<string, Set<string>> = new Map();

  constructor(private configService: ConfigService) {
    // 定期清理过期缓存
    setInterval(() => this.cleanExpired(), 60000);
  }

  async get(key: string): Promise<string | null> {
    const item = this.cache.get(key);
    if (!item) return null;
    
    if (Date.now() > item.expires) {
      this.cache.delete(key);
      this.removeFromTagIndex(key);
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

  /**
   * 设置带标签的缓存
   * @param key 缓存键
   * @param ttlSeconds 过期时间（秒）
   * @param value 缓存值
   * @param tags 缓存标签，用于批量失效
   */
  async setexWithTags(
    key: string, 
    ttlSeconds: number, 
    value: string,
    tags: string[]
  ): Promise<void> {
    const expires = Date.now() + ttlSeconds * 1000;
    this.cache.set(key, { value, expires, tags });
    
    // 更新标签索引
    for (const tag of tags) {
      if (!this.tagIndex.has(tag)) {
        this.tagIndex.set(tag, new Set());
      }
      this.tagIndex.get(tag)!.add(key);
    }
  }

  async del(...keys: string[]): Promise<void> {
    for (const key of keys) {
      this.cache.delete(key);
      this.removeFromTagIndex(key);
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
      this.removeFromTagIndex(key);
    }
    
    return keysToDelete.length;
  }

  /**
   * 根据标签删除缓存
   * @param tag 缓存标签
   * @returns 删除的缓存数量
   */
  async invalidateByTag(tag: string): Promise<number> {
    const keys = this.tagIndex.get(tag);
    if (!keys || keys.size === 0) {
      return 0;
    }

    const keysArray = Array.from(keys);
    for (const key of keysArray) {
      this.cache.delete(key);
    }
    
    this.tagIndex.delete(tag);
    
    this.logger.debug(`Invalidated ${keysArray.length} cache entries by tag: ${tag}`);
    return keysArray.length;
  }

  /**
   * 根据多个标签删除缓存
   * @param tags 缓存标签列表
   * @returns 删除的缓存数量
   */
  async invalidateByTags(tags: string[]): Promise<number> {
    let totalDeleted = 0;
    for (const tag of tags) {
      totalDeleted += await this.invalidateByTag(tag);
    }
    return totalDeleted;
  }

  /**
   * 获取标签信息（用于调试）
   */
  async getTagInfo(tag: string): Promise<{ keyCount: number; keys: string[] }> {
    const keys = this.tagIndex.get(tag);
    return {
      keyCount: keys?.size ?? 0,
      keys: keys ? Array.from(keys) : [],
    };
  }

  private removeFromTagIndex(key: string): void {
    for (const [tag, keys] of this.tagIndex.entries()) {
      keys.delete(key);
      if (keys.size === 0) {
        this.tagIndex.delete(tag);
      }
    }
  }

  private cleanExpired(): void {
    const now = Date.now();
    const expiredKeys: string[] = [];
    
    for (const [key, item] of this.cache.entries()) {
      if (now > item.expires) {
        expiredKeys.push(key);
      }
    }
    
    for (const key of expiredKeys) {
      this.cache.delete(key);
      this.removeFromTagIndex(key);
    }
    
    if (expiredKeys.length > 0) {
      this.logger.debug(`Cleaned ${expiredKeys.length} expired cache entries`);
    }
  }
}
