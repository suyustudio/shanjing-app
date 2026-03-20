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
exports.ReviewsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
const review_dto_1 = require("./dto/review.dto");
let ReviewsService = class ReviewsService {
    constructor(prisma) {
        this.prisma = prisma;
        this.EDIT_TIME_LIMIT_HOURS = 24;
    }
    async createReview(userId, trailId, dto) {
        const trail = await this.prisma.trail.findUnique({
            where: { id: trailId },
        });
        if (!trail) {
            throw new common_1.NotFoundException('路线不存在');
        }
        const existingReview = await this.prisma.review.findUnique({
            where: {
                userId_trailId: {
                    userId,
                    trailId,
                },
            },
        });
        if (existingReview) {
            throw new common_1.BadRequestException('您已经评论过这条路线了');
        }
        if (dto.tags) {
            const invalidTags = dto.tags.filter(tag => !review_dto_1.PREDEFINED_TAGS.includes(tag));
            if (invalidTags.length > 0) {
                throw new common_1.BadRequestException(`无效的标签: ${invalidTags.join(', ')}`);
            }
        }
        const isVerified = await this.checkUserCompletedTrail(userId, trailId);
        const review = await this.prisma.review.create({
            data: {
                userId,
                trailId,
                rating: dto.rating,
                content: dto.content,
                isVerified,
                tags: {
                    create: dto.tags?.map(tag => ({ tag })) || [],
                },
                photos: {
                    create: dto.photos?.map((url, index) => ({
                        url,
                        sortOrder: index,
                    })) || [],
                },
            },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
                tags: true,
                photos: {
                    orderBy: { sortOrder: 'asc' },
                },
                _count: {
                    select: { likes: true }
                }
            },
        });
        await this.updateTrailRatingStats(trailId);
        return this.mapToReviewDto(review);
    }
    async getReviews(trailId, query, currentUserId) {
        let orderBy = {};
        switch (query.sort) {
            case 'highest':
                orderBy = { rating: 'desc' };
                break;
            case 'lowest':
                orderBy = { rating: 'asc' };
                break;
            case 'hot':
                orderBy = [
                    { likeCount: 'desc' },
                    { replyCount: 'desc' },
                    { createdAt: 'desc' }
                ];
                break;
            case 'newest':
            default:
                orderBy = { createdAt: 'desc' };
        }
        const where = { trailId };
        if (query.rating) {
            where.rating = query.rating;
        }
        const [reviews, total] = await Promise.all([
            this.prisma.review.findMany({
                where,
                orderBy,
                skip: (query.page - 1) * query.limit,
                take: query.limit,
                include: {
                    user: {
                        select: {
                            id: true,
                            nickname: true,
                            avatarUrl: true,
                        },
                    },
                    tags: true,
                    photos: {
                        orderBy: { sortOrder: 'asc' },
                    },
                    likes: currentUserId ? {
                        where: { userId: currentUserId },
                        take: 1,
                    } : false,
                    _count: {
                        select: { likes: true }
                    }
                },
            }),
            this.prisma.review.count({ where }),
        ]);
        const stats = await this.getReviewStats(trailId);
        return {
            list: reviews.map(r => this.mapToReviewDto(r, currentUserId)),
            total,
            page: query.page,
            limit: query.limit,
            stats,
        };
    }
    async getReviewDetail(reviewId, currentUserId) {
        const review = await this.prisma.review.findUnique({
            where: { id: reviewId },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
                tags: true,
                photos: {
                    orderBy: { sortOrder: 'asc' },
                },
                replies: {
                    include: {
                        user: {
                            select: {
                                id: true,
                                nickname: true,
                                avatarUrl: true,
                            },
                        },
                    },
                    orderBy: { createdAt: 'asc' },
                },
                likes: currentUserId ? {
                    where: { userId: currentUserId },
                    take: 1,
                } : false,
                _count: {
                    select: { likes: true }
                }
            },
        });
        if (!review) {
            throw new common_1.NotFoundException('评论不存在');
        }
        return this.mapToReviewDetailDto(review, currentUserId);
    }
    async updateReview(userId, reviewId, dto) {
        const review = await this.prisma.review.findUnique({
            where: { id: reviewId },
        });
        if (!review) {
            throw new common_1.NotFoundException('评论不存在');
        }
        if (review.userId !== userId) {
            throw new common_1.ForbiddenException('无权修改此评论');
        }
        const hoursSinceCreated = (Date.now() - review.createdAt.getTime()) / (1000 * 60 * 60);
        if (hoursSinceCreated > this.EDIT_TIME_LIMIT_HOURS) {
            throw new common_1.ForbiddenException(`评论超过${this.EDIT_TIME_LIMIT_HOURS}小时，无法编辑`);
        }
        if (dto.tags) {
            const invalidTags = dto.tags.filter(tag => !review_dto_1.PREDEFINED_TAGS.includes(tag));
            if (invalidTags.length > 0) {
                throw new common_1.BadRequestException(`无效的标签: ${invalidTags.join(', ')}`);
            }
        }
        const updateData = {
            rating: dto.rating,
            content: dto.content,
            isEdited: true,
        };
        if (dto.tags) {
            updateData.tags = {
                deleteMany: {},
                create: dto.tags.map(tag => ({ tag })),
            };
        }
        if (dto.photos !== undefined) {
            updateData.photos = {
                deleteMany: {},
                create: dto.photos?.map((url, index) => ({
                    url,
                    sortOrder: index,
                })) || [],
            };
        }
        const updated = await this.prisma.review.update({
            where: { id: reviewId },
            data: updateData,
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
                tags: true,
                photos: {
                    orderBy: { sortOrder: 'asc' },
                },
                _count: {
                    select: { likes: true }
                }
            },
        });
        await this.updateTrailRatingStats(review.trailId);
        return this.mapToReviewDto(updated);
    }
    async deleteReview(userId, reviewId) {
        const review = await this.prisma.review.findUnique({
            where: { id: reviewId },
        });
        if (!review) {
            throw new common_1.NotFoundException('评论不存在');
        }
        if (review.userId !== userId) {
            throw new common_1.ForbiddenException('无权删除此评论');
        }
        const trailId = review.trailId;
        await this.prisma.review.delete({
            where: { id: reviewId },
        });
        await this.updateTrailRatingStats(trailId);
    }
    async createReply(userId, reviewId, dto) {
        const review = await this.prisma.review.findUnique({
            where: { id: reviewId },
        });
        if (!review) {
            throw new common_1.NotFoundException('评论不存在');
        }
        if (dto.parentId) {
            const parentReply = await this.prisma.reviewReply.findUnique({
                where: { id: dto.parentId },
            });
            if (!parentReply || parentReply.reviewId !== reviewId) {
                throw new common_1.BadRequestException('父回复不存在');
            }
        }
        const reply = await this.prisma.reviewReply.create({
            data: {
                reviewId,
                userId,
                parentId: dto.parentId || null,
                content: dto.content,
            },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
            },
        });
        await this.prisma.review.update({
            where: { id: reviewId },
            data: {
                replyCount: {
                    increment: 1,
                },
            },
        });
        return this.mapToReplyDto(reply);
    }
    async getReplies(reviewId) {
        const replies = await this.prisma.reviewReply.findMany({
            where: { reviewId },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
            },
            orderBy: { createdAt: 'asc' },
        });
        return replies.map(r => this.mapToReplyDto(r));
    }
    async likeReview(userId, reviewId) {
        const review = await this.prisma.review.findUnique({
            where: { id: reviewId },
        });
        if (!review) {
            throw new common_1.NotFoundException('评论不存在');
        }
        const existingLike = await this.prisma.reviewLike.findUnique({
            where: {
                reviewId_userId: {
                    reviewId,
                    userId,
                },
            },
        });
        if (existingLike) {
            await this.prisma.reviewLike.delete({
                where: { id: existingLike.id },
            });
            await this.prisma.review.update({
                where: { id: reviewId },
                data: { likeCount: { decrement: 1 } },
            });
            const updatedReview = await this.prisma.review.findUnique({
                where: { id: reviewId },
                select: { likeCount: true },
            });
            return { isLiked: false, likeCount: updatedReview?.likeCount || 0 };
        }
        else {
            await this.prisma.reviewLike.create({
                data: {
                    reviewId,
                    userId,
                },
            });
            await this.prisma.review.update({
                where: { id: reviewId },
                data: { likeCount: { increment: 1 } },
            });
            const updatedReview = await this.prisma.review.findUnique({
                where: { id: reviewId },
                select: { likeCount: true },
            });
            return { isLiked: true, likeCount: updatedReview?.likeCount || 0 };
        }
    }
    async checkUserLikedReview(userId, reviewId) {
        const like = await this.prisma.reviewLike.findUnique({
            where: {
                reviewId_userId: {
                    reviewId,
                    userId,
                },
            },
        });
        return !!like;
    }
    async getReviewStats(trailId) {
        const stats = await this.prisma.trail.findUnique({
            where: { id: trailId },
            select: {
                id: true,
                avgRating: true,
                reviewCount: true,
                rating5Count: true,
                rating4Count: true,
                rating3Count: true,
                rating2Count: true,
                rating1Count: true,
            },
        });
        if (!stats) {
            throw new common_1.NotFoundException('路线不存在');
        }
        return {
            trailId: stats.id,
            avgRating: stats.avgRating || 0,
            totalCount: stats.reviewCount,
            rating5Count: stats.rating5Count,
            rating4Count: stats.rating4Count,
            rating3Count: stats.rating3Count,
            rating2Count: stats.rating2Count,
            rating1Count: stats.rating1Count,
        };
    }
    async updateTrailRatingStats(trailId) {
        const reviews = await this.prisma.review.findMany({
            where: { trailId },
            select: { rating: true, createdAt: true },
        });
        const totalCount = reviews.length;
        if (totalCount === 0) {
            await this.prisma.trail.update({
                where: { id: trailId },
                data: {
                    avgRating: null,
                    reviewCount: 0,
                    rating5Count: 0,
                    rating4Count: 0,
                    rating3Count: 0,
                    rating2Count: 0,
                    rating1Count: 0,
                },
            });
            return;
        }
        const weightedRating = this.calculateWeightedRating(reviews);
        const counts = {
            rating5Count: reviews.filter(r => r.rating === 5).length,
            rating4Count: reviews.filter(r => r.rating === 4).length,
            rating3Count: reviews.filter(r => r.rating === 3).length,
            rating2Count: reviews.filter(r => r.rating === 2).length,
            rating1Count: reviews.filter(r => r.rating === 1).length,
        };
        await this.prisma.trail.update({
            where: { id: trailId },
            data: {
                avgRating: weightedRating,
                reviewCount: totalCount,
                ...counts,
            },
        });
    }
    calculateWeightedRating(reviews) {
        if (reviews.length === 0)
            return 0;
        if (reviews.length <= 2) {
            return Number((reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length).toFixed(1));
        }
        const sorted = [...reviews].sort((a, b) => a.rating - b.rating);
        const trimCount = Math.max(1, Math.ceil(sorted.length * 0.05));
        const trimmed = sorted.slice(trimCount, sorted.length - trimCount);
        const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
        let weightedSum = 0;
        let totalWeight = 0;
        for (const review of trimmed) {
            const isRecent = review.createdAt > thirtyDaysAgo;
            const weight = isRecent ? 1.2 : 1.0;
            weightedSum += review.rating * weight;
            totalWeight += weight;
        }
        return Number((weightedSum / totalWeight).toFixed(1));
    }
    async checkUserCompletedTrail(userId, trailId) {
        const userStats = await this.prisma.userStats.findUnique({
            where: { userId },
            select: { completedTrailIds: true },
        });
        return userStats?.completedTrailIds?.includes(trailId) || false;
    }
    async reportReview(userId, reviewId, reason) {
        const review = await this.prisma.review.findUnique({
            where: { id: reviewId },
        });
        if (!review) {
            throw new common_1.NotFoundException('评论不存在');
        }
        if (review.userId === userId) {
            throw new common_1.BadRequestException('不能举报自己的评论');
        }
        await this.prisma.review.update({
            where: { id: reviewId },
            data: {
                isReported: true,
                reportReason: reason,
            },
        });
    }
    mapToReviewDto(review, currentUserId) {
        let isLiked = false;
        if (currentUserId && review.likes) {
            isLiked = review.likes.length > 0;
        }
        return {
            id: review.id,
            rating: review.rating,
            content: review.content,
            tags: review.tags?.map((t) => t.tag) || [],
            photos: review.photos?.map((p) => p.url) || [],
            likeCount: review.likeCount,
            replyCount: review.replyCount,
            isEdited: review.isEdited,
            isVerified: review.isVerified,
            isLiked,
            user: {
                id: review.user.id,
                nickname: review.user.nickname,
                avatarUrl: review.user.avatarUrl,
            },
            createdAt: review.createdAt,
            updatedAt: review.updatedAt,
        };
    }
    mapToReviewDetailDto(review, currentUserId) {
        return {
            ...this.mapToReviewDto(review, currentUserId),
            replies: review.replies?.map((r) => this.mapToReplyDto(r)) || [],
        };
    }
    mapToReplyDto(reply) {
        return {
            id: reply.id,
            content: reply.content,
            user: {
                id: reply.user.id,
                nickname: reply.user.nickname,
                avatarUrl: reply.user.avatarUrl,
            },
            parentId: reply.parentId,
            createdAt: reply.createdAt,
        };
    }
};
exports.ReviewsService = ReviewsService;
exports.ReviewsService = ReviewsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ReviewsService);
//# sourceMappingURL=reviews.service.js.map