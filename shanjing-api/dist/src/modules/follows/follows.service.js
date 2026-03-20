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
Object.defineProperty(exports, "__esModule", { value: true });
exports.FollowsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
let FollowsService = class FollowsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async toggleFollow(followerId, followingId) {
        if (followerId === followingId) {
            throw new common_1.BadRequestException('不能关注自己');
        }
        const targetUser = await this.prisma.user.findUnique({
            where: { id: followingId },
        });
        if (!targetUser) {
            throw new common_1.NotFoundException('用户不存在');
        }
        const existingFollow = await this.prisma.follow.findUnique({
            where: {
                followerId_followingId: {
                    followerId,
                    followingId,
                },
            },
        });
        if (existingFollow) {
            await this.prisma.follow.delete({
                where: { id: existingFollow.id },
            });
            await this.prisma.user.update({
                where: { id: followerId },
                data: { followingCount: { decrement: 1 } },
            });
            await this.prisma.user.update({
                where: { id: followingId },
                data: { followersCount: { decrement: 1 } },
            });
            return {
                isFollowing: false,
                followersCount: targetUser.followersCount - 1,
                followingCount: (await this.prisma.user.findUnique({
                    where: { id: followerId },
                    select: { followingCount: true },
                }))?.followingCount || 0,
            };
        }
        else {
            await this.prisma.follow.create({
                data: {
                    followerId,
                    followingId,
                },
            });
            await this.prisma.user.update({
                where: { id: followerId },
                data: { followingCount: { increment: 1 } },
            });
            await this.prisma.user.update({
                where: { id: followingId },
                data: { followersCount: { increment: 1 } },
            });
            return {
                isFollowing: true,
                followersCount: targetUser.followersCount + 1,
                followingCount: (await this.prisma.user.findUnique({
                    where: { id: followerId },
                    select: { followingCount: true },
                }))?.followingCount || 0,
            };
        }
    }
    async getFollowing(userId, query, currentUserId) {
        const where = { followerId: userId };
        if (query.cursor) {
            where.createdAt = { lt: new Date(query.cursor) };
        }
        const follows = await this.prisma.follow.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            take: query.limit + 1,
            include: {
                following: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                        followersCount: true,
                        followingCount: true,
                    },
                },
            },
        });
        const hasMore = follows.length > query.limit;
        const followList = hasMore ? follows.slice(0, query.limit) : follows;
        let followingIds = [];
        if (currentUserId) {
            const currentUserFollowing = await this.prisma.follow.findMany({
                where: {
                    followerId: currentUserId,
                    followingId: {
                        in: followList.map(f => f.followingId),
                    },
                },
                select: { followingId: true },
            });
            followingIds = currentUserFollowing.map(f => f.followingId);
        }
        const nextCursor = hasMore && followList.length > 0
            ? followList[followList.length - 1].createdAt.toISOString()
            : null;
        const total = await this.prisma.follow.count({
            where: { followerId: userId },
        });
        return {
            list: followList.map(f => ({
                id: f.following.id,
                nickname: f.following.nickname,
                avatarUrl: f.following.avatarUrl,
                followersCount: f.following.followersCount,
                isFollowing: followingIds.includes(f.followingId),
            })),
            nextCursor,
            hasMore,
            total,
        };
    }
    async getFollowers(userId, query, currentUserId) {
        const where = { followingId: userId };
        if (query.cursor) {
            where.createdAt = { lt: new Date(query.cursor) };
        }
        const follows = await this.prisma.follow.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            take: query.limit + 1,
            include: {
                follower: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                        followersCount: true,
                        followingCount: true,
                    },
                },
            },
        });
        const hasMore = follows.length > query.limit;
        const followList = hasMore ? follows.slice(0, query.limit) : follows;
        let followingIds = [];
        if (currentUserId) {
            const currentUserFollowing = await this.prisma.follow.findMany({
                where: {
                    followerId: currentUserId,
                    followingId: {
                        in: followList.map(f => f.followerId),
                    },
                },
                select: { followingId: true },
            });
            followingIds = currentUserFollowing.map(f => f.followingId);
        }
        const nextCursor = hasMore && followList.length > 0
            ? followList[followList.length - 1].createdAt.toISOString()
            : null;
        const total = await this.prisma.follow.count({
            where: { followingId: userId },
        });
        return {
            list: followList.map(f => ({
                id: f.follower.id,
                nickname: f.follower.nickname,
                avatarUrl: f.follower.avatarUrl,
                followersCount: f.follower.followersCount,
                isFollowing: followingIds.includes(f.followerId),
            })),
            nextCursor,
            hasMore,
            total,
        };
    }
    async getFollowStats(userId, currentUserId) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: {
                followersCount: true,
                followingCount: true,
            },
        });
        if (!user) {
            throw new common_1.NotFoundException('用户不存在');
        }
        let isFollowing = false;
        if (currentUserId && currentUserId !== userId) {
            const follow = await this.prisma.follow.findUnique({
                where: {
                    followerId_followingId: {
                        followerId: currentUserId,
                        followingId: userId,
                    },
                },
            });
            isFollowing = !!follow;
        }
        return {
            followersCount: user.followersCount,
            followingCount: user.followingCount,
            isFollowing,
        };
    }
    async checkFollowStatus(followerId, followingId) {
        const follow = await this.prisma.follow.findUnique({
            where: {
                followerId_followingId: {
                    followerId,
                    followingId,
                },
            },
        });
        return { isFollowing: !!follow };
    }
    async getSuggestions(userId, limit = 10) {
        const userFollowing = await this.prisma.follow.findMany({
            where: { followerId: userId },
            select: { followingId: true },
        });
        const followingIds = new Set(userFollowing.map(f => f.followingId));
        followingIds.add(userId);
        const suggestedUsers = await this.prisma.user.findMany({
            where: {
                id: {
                    notIn: Array.from(followingIds),
                },
                followersCount: {
                    gt: 0,
                },
            },
            orderBy: [
                { followersCount: 'desc' },
                { createdAt: 'desc' },
            ],
            take: limit,
            select: {
                id: true,
                nickname: true,
                avatarUrl: true,
                followersCount: true,
            },
        });
        let mutualFollowCounts = new Map();
        if (userFollowing.length > 0) {
            const followingIdList = userFollowing.map(f => f.followingId);
            const mutualRelations = await this.prisma.follow.findMany({
                where: {
                    followerId: {
                        in: followingIdList,
                    },
                    followingId: {
                        in: suggestedUsers.map(u => u.id),
                    },
                },
                select: {
                    followingId: true,
                },
            });
            for (const relation of mutualRelations) {
                const count = mutualFollowCounts.get(relation.followingId) || 0;
                mutualFollowCounts.set(relation.followingId, count + 1);
            }
        }
        return {
            list: suggestedUsers.map(u => ({
                id: u.id,
                nickname: u.nickname,
                avatarUrl: u.avatarUrl,
                followersCount: u.followersCount,
                isFollowing: false,
                mutualFollows: mutualFollowCounts.get(u.id) || 0,
            })),
            nextCursor: null,
            hasMore: false,
            total: suggestedUsers.length,
        };
    }
};
exports.FollowsService = FollowsService;
exports.FollowsService = FollowsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], FollowsService);
//# sourceMappingURL=follows.service.js.map