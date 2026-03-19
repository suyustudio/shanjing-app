import { AdminRole } from '../admin-role.enum';
export interface AdminInfo {
    id: string;
    username: string;
    role: AdminRole;
}
export declare const CurrentAdmin: (...dataOrPipes: (import("@nestjs/common").PipeTransform<any, any> | import("@nestjs/common").Type<import("@nestjs/common").PipeTransform<any, any>> | keyof AdminInfo)[]) => ParameterDecorator;
