"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var RedisService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RedisService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
let RedisService = RedisService_1 = class RedisService {
    constructor(configService) {
        this.configService = configService;
        this.logger = new common_1.Logger(RedisService_1.name);
        this.cache = new Map();
        this.tagIndex = new Map();
        setInterval(() => this.cleanExpired(), 60000);
    }
    async get(key) {
        const item = this.cache.get(key);
        if (!item)
            return null;
        if (Date.now() > item.expires) {
            this.cache.delete(key);
            this.removeFromTagIndex(key);
            return null;
        }
        return item.value;
    }
    async set(key, value, ttlSeconds) {
        const expires = ttlSeconds
            ? Date.now() + ttlSeconds * 1000
            : Number.MAX_SAFE_INTEGER;
        this.cache.set(key, { value, expires });
    }
    async setex(key, ttlSeconds, value) {
        const expires = Date.now() + ttlSeconds * 1000;
        this.cache.set(key, { value, expires });
    }
    async setexWithTags(key, ttlSeconds, value, tags) {
        const expires = Date.now() + ttlSeconds * 1000;
        this.cache.set(key, { value, expires, tags });
        for (const tag of tags) {
            if (!this.tagIndex.has(tag)) {
                this.tagIndex.set(tag, new Set());
            }
            this.tagIndex.get(tag).add(key);
        }
    }
    async del(...keys) {
        for (const key of keys) {
            this.cache.delete(key);
            this.removeFromTagIndex(key);
        }
    }
    async keys(pattern) {
        const regex = new RegExp(pattern.replace('*', '.*'));
        return Array.from(this.cache.keys()).filter(key => regex.test(key));
    }
    async delPattern(pattern) {
        const regex = new RegExp(pattern.replace(/\*/g, '.*'));
        const keysToDelete = [];
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
    async invalidateByTag(tag) {
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
    async invalidateByTags(tags) {
        let totalDeleted = 0;
        for (const tag of tags) {
            totalDeleted += await this.invalidateByTag(tag);
        }
        return totalDeleted;
    }
    async getTagInfo(tag) {
        const keys = this.tagIndex.get(tag);
        return {
            keyCount: keys?.size ?? 0,
            keys: keys ? Array.from(keys) : [],
        };
    }
    removeFromTagIndex(key) {
        for (const [tag, keys] of this.tagIndex.entries()) {
            keys.delete(key);
            if (keys.size === 0) {
                this.tagIndex.delete(tag);
            }
        }
    }
    cleanExpired() {
        const now = Date.now();
        const expiredKeys = [];
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
};
exports.RedisService = RedisService;
exports.RedisService = RedisService = RedisService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], RedisService);
//# sourceMappingURL=redis.service.js.map