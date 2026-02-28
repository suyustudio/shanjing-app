import { ConfigService } from '@nestjs/config';
import { Strategy } from 'passport-jwt';
import { PrismaService } from '../../../database/prisma.service';
import { TokenPayload } from '../interfaces/auth.interface';
declare const JwtStrategy_base: new (...args: any[]) => Strategy;
export declare class JwtStrategy extends JwtStrategy_base {
    private readonly configService;
    private readonly prisma;
    constructor(configService: ConfigService, prisma: PrismaService);
    validate(payload: TokenPayload): Promise<{
        userId: any;
        phone: any;
        wxOpenid: any;
    }>;
}
export {};
