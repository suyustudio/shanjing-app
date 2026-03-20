import { ConfigService } from '@nestjs/config';
export declare class RedisService {
    private configService;
    private readonly logger;
    private cache;
    private tagIndex;
    constructor(configService: ConfigService);
    get(key: string): Promise<string | null>;
    set(key: string, value: string, ttlSeconds?: number): Promise<void>;
    setex(key: string, ttlSeconds: number, value: string): Promise<void>;
    setexWithTags(key: string, ttlSeconds: number, value: string, tags: string[]): Promise<void>;
    del(...keys: string[]): Promise<void>;
    keys(pattern: string): Promise<string[]>;
    delPattern(pattern: string): Promise<number>;
    invalidateByTag(tag: string): Promise<number>;
    invalidateByTags(tags: string[]): Promise<number>;
    getTagInfo(tag: string): Promise<{
        keyCount: number;
        keys: string[];
    }>;
    private removeFromTagIndex;
    private cleanExpired;
}
