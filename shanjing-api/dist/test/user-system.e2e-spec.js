"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const common_1 = require("@nestjs/common");
const request = require("supertest");
const app_module_1 = require("../src/app.module");
const prisma_service_1 = require("../src/database/prisma.service");
describe('User System API (e2e)', () => {
    let app;
    let prisma;
    let authToken;
    let userId;
    beforeAll(async () => {
        const moduleFixture = await testing_1.Test.createTestingModule({
            imports: [app_module_1.AppModule],
        }).compile();
        app = moduleFixture.createNestApplication();
        app.useGlobalPipes(new common_1.ValidationPipe({
            whitelist: true,
            transform: true,
            forbidNonWhitelisted: true,
        }));
        prisma = app.get(prisma_service_1.PrismaService);
        await app.init();
    });
    afterAll(async () => {
        await prisma.tokenBlacklist.deleteMany();
        await prisma.user.deleteMany();
        await app.close();
    });
    describe('Auth Module', () => {
        describe('POST /auth/register/phone', () => {
            it('should register a new user with phone', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/register/phone')
                    .send({
                    phone: '13800138000',
                    code: '123456',
                    nickname: '测试用户',
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.user).toBeDefined();
                expect(response.body.data.user.phone).toBe('13800138000');
                expect(response.body.data.tokens).toBeDefined();
                expect(response.body.data.tokens.accessToken).toBeDefined();
                authToken = response.body.data.tokens.accessToken;
                userId = response.body.data.user.id;
            });
            it('should fail with duplicate phone', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/register/phone')
                    .send({
                    phone: '13800138000',
                    code: '123456',
                    nickname: '测试用户2',
                })
                    .expect(409);
                expect(response.body.success).toBe(false);
                expect(response.body.error.code).toBe('PHONE_ALREADY_EXISTS');
            });
            it('should fail with invalid verification code', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/register/phone')
                    .send({
                    phone: '13800138001',
                    code: '999999',
                    nickname: '测试用户',
                })
                    .expect(400);
                expect(response.body.success).toBe(false);
                expect(response.body.error.code).toBe('INVALID_VERIFICATION_CODE');
            });
            it('should fail with invalid phone format', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/register/phone')
                    .send({
                    phone: 'invalid-phone',
                    code: '123456',
                    nickname: '测试用户',
                })
                    .expect(400);
                expect(response.body.success).toBe(false);
            });
        });
        describe('POST /auth/login/phone', () => {
            it('should login existing user', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/login/phone')
                    .send({
                    phone: '13800138000',
                    code: '123456',
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.user).toBeDefined();
                expect(response.body.data.tokens).toBeDefined();
            });
            it('should auto-register new user on login', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/login/phone')
                    .send({
                    phone: '13900139000',
                    code: '123456',
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.user.phone).toBe('13900139000');
                expect(response.body.data.tokens).toBeDefined();
            });
            it('should fail with invalid verification code', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/login/phone')
                    .send({
                    phone: '13800138000',
                    code: '000000',
                })
                    .expect(400);
                expect(response.body.success).toBe(false);
            });
        });
        describe('POST /auth/register/wechat', () => {
            it('should register a new user with wechat', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/register/wechat')
                    .send({
                    code: 'wechat_auth_code_123',
                    nickname: '微信用户',
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.user).toBeDefined();
                expect(response.body.data.user.nickname).toBe('微信用户');
                expect(response.body.data.tokens).toBeDefined();
            });
        });
        describe('POST /auth/login/wechat', () => {
            it('should login with wechat', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/login/wechat')
                    .send({
                    code: 'wechat_auth_code_456',
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.user).toBeDefined();
                expect(response.body.data.tokens).toBeDefined();
            });
        });
        describe('POST /auth/refresh', () => {
            it('should refresh token', async () => {
                const loginResponse = await request(app.getHttpServer())
                    .post('/auth/login/phone')
                    .send({
                    phone: '13800138000',
                    code: '123456',
                });
                const refreshToken = loginResponse.body.data.tokens.refreshToken;
                const response = await request(app.getHttpServer())
                    .post('/auth/refresh')
                    .send({
                    refreshToken,
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.accessToken).toBeDefined();
                expect(response.body.data.refreshToken).toBeDefined();
            });
            it('should fail with invalid refresh token', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/refresh')
                    .send({
                    refreshToken: 'invalid-token',
                })
                    .expect(401);
                expect(response.body.success).toBe(false);
            });
        });
        describe('POST /auth/logout', () => {
            it('should logout successfully', async () => {
                const response = await request(app.getHttpServer())
                    .post('/auth/logout')
                    .set('Authorization', `Bearer ${authToken}`)
                    .send({
                    allDevices: false,
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.message).toBe('退出登录成功');
            });
        });
    });
    describe('Users Module', () => {
        let testAuthToken;
        let testUserId;
        beforeAll(async () => {
            const response = await request(app.getHttpServer())
                .post('/auth/login/phone')
                .send({
                phone: '13700137000',
                code: '123456',
            });
            testAuthToken = response.body.data.tokens.accessToken;
            testUserId = response.body.data.user.id;
        });
        describe('GET /users/me', () => {
            it('should get current user info', async () => {
                const response = await request(app.getHttpServer())
                    .get('/users/me')
                    .set('Authorization', `Bearer ${testAuthToken}`)
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.id).toBe(testUserId);
                expect(response.body.data.phone).toBe('13700137000');
            });
            it('should fail without auth token', async () => {
                const response = await request(app.getHttpServer())
                    .get('/users/me')
                    .expect(401);
                expect(response.body.success).toBe(false);
            });
            it('should fail with invalid auth token', async () => {
                const response = await request(app.getHttpServer())
                    .get('/users/me')
                    .set('Authorization', 'Bearer invalid-token')
                    .expect(401);
                expect(response.body.success).toBe(false);
            });
        });
        describe('PUT /users/me', () => {
            it('should update user info', async () => {
                const response = await request(app.getHttpServer())
                    .put('/users/me')
                    .set('Authorization', `Bearer ${testAuthToken}`)
                    .send({
                    nickname: '更新的昵称',
                    settings: { notificationEnabled: true },
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.nickname).toBe('更新的昵称');
                expect(response.body.data.settings).toEqual({ notificationEnabled: true });
            });
            it('should fail with invalid nickname length', async () => {
                const response = await request(app.getHttpServer())
                    .put('/users/me')
                    .set('Authorization', `Bearer ${testAuthToken}`)
                    .send({
                    nickname: 'a',
                })
                    .expect(400);
                expect(response.body.success).toBe(false);
            });
        });
        describe('PUT /users/me/emergency', () => {
            it('should update emergency contacts', async () => {
                const response = await request(app.getHttpServer())
                    .put('/users/me/emergency')
                    .set('Authorization', `Bearer ${testAuthToken}`)
                    .send({
                    contacts: [
                        {
                            name: '张三',
                            phone: '13900139000',
                            relation: '配偶',
                        },
                    ],
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.emergencyContacts).toHaveLength(1);
                expect(response.body.data.emergencyContacts[0].name).toBe('张三');
            });
            it('should fail with too many contacts', async () => {
                const response = await request(app.getHttpServer())
                    .put('/users/me/emergency')
                    .set('Authorization', `Bearer ${testAuthToken}`)
                    .send({
                    contacts: [
                        { name: '张三', phone: '13900139000', relation: '配偶' },
                        { name: '李四', phone: '13900139001', relation: '朋友' },
                        { name: '王五', phone: '13900139002', relation: '同事' },
                        { name: '赵六', phone: '13900139003', relation: '亲戚' },
                    ],
                })
                    .expect(400);
                expect(response.body.success).toBe(false);
                expect(response.body.error.code).toBe('TOO_MANY_CONTACTS');
            });
            it('should fail with invalid phone format', async () => {
                const response = await request(app.getHttpServer())
                    .put('/users/me/emergency')
                    .set('Authorization', `Bearer ${testAuthToken}`)
                    .send({
                    contacts: [
                        {
                            name: '张三',
                            phone: 'invalid-phone',
                            relation: '配偶',
                        },
                    ],
                })
                    .expect(400);
                expect(response.body.success).toBe(false);
            });
        });
        describe('PUT /users/me/phone', () => {
            it('should bind phone successfully', async () => {
                const wechatResponse = await request(app.getHttpServer())
                    .post('/auth/login/wechat')
                    .send({ code: 'wechat_for_phone_bind' });
                const wechatToken = wechatResponse.body.data.tokens.accessToken;
                const response = await request(app.getHttpServer())
                    .put('/users/me/phone')
                    .set('Authorization', `Bearer ${wechatToken}`)
                    .send({
                    phone: '13600136000',
                    code: '123456',
                })
                    .expect(200);
                expect(response.body.success).toBe(true);
                expect(response.body.data.phone).toBe('13600136000');
            });
            it('should fail if phone already bound to another user', async () => {
                const response = await request(app.getHttpServer())
                    .put('/users/me/phone')
                    .set('Authorization', `Bearer ${testAuthToken}`)
                    .send({
                    phone: '13800138000',
                    code: '123456',
                })
                    .expect(409);
                expect(response.body.success).toBe(false);
                expect(response.body.error.code).toBe('PHONE_ALREADY_EXISTS');
            });
        });
    });
});
//# sourceMappingURL=user-system.e2e-spec.js.map