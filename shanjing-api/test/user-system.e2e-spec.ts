import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/database/prisma.service';

describe('User System API (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let authToken: string;
  let userId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }));
    
    prisma = app.get(PrismaService);
    await app.init();
  });

  afterAll(async () => {
    // 清理测试数据
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
        // 先登录获取 refresh token
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
    let testAuthToken: string;
    let testUserId: string;

    beforeAll(async () => {
      // 创建测试用户并获取 token
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
            nickname: 'a', // 太短
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
        // 先创建一个没有手机号的用户
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
            phone: '13800138000', // 已被其他用户绑定
            code: '123456',
          })
          .expect(409);

        expect(response.body.success).toBe(false);
        expect(response.body.error.code).toBe('PHONE_ALREADY_EXISTS');
      });
    });
  });
});
