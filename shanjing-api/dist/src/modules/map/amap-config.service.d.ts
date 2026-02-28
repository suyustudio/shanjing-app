import { ConfigService } from '@nestjs/config';
export interface AmapConfig {
    apiKey: string;
    securityConfig?: string;
    baseUrl: string;
    timeout: number;
    enableLog: boolean;
}
export declare class AmapConfigService {
    private readonly configService;
    private readonly logger;
    private readonly config;
    constructor(configService: ConfigService);
    private loadConfig;
    private validateConfig;
    getConfig(): AmapConfig;
    getApiKey(): string;
    getBaseUrl(): string;
    getTimeout(): number;
    isLogEnabled(): boolean;
}
