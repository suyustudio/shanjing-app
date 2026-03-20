import { LoggerService } from '@nestjs/common';
export interface LogContext {
    userId?: string;
    trailId?: string;
    achievementId?: string;
    requestId?: string;
    [key: string]: any;
}
export interface PerformanceLog {
    operation: string;
    durationMs: number;
    success: boolean;
    metadata?: Record<string, any>;
}
export declare class StructuredLogger {
    private readonly logger;
    private readonly defaultContext;
    constructor(logger: LoggerService, defaultContext: string);
    info(message: string, context?: LogContext): void;
    debug(message: string, context?: LogContext): void;
    warn(message: string, error?: Error | unknown, context?: LogContext): void;
    error(message: string, error?: Error | unknown, context?: LogContext): void;
    performance(logData: PerformanceLog, context?: LogContext): void;
    startTimer(operation: string, context?: LogContext): PerformanceTimer;
    private formatMessage;
}
export declare class PerformanceTimer {
    private readonly logger;
    private readonly operation;
    private readonly context?;
    private readonly startTime;
    constructor(logger: StructuredLogger, operation: string, context?: LogContext);
    end(metadata?: Record<string, any>, success?: boolean): number;
    fail(error?: Error, metadata?: Record<string, any>): number;
}
export declare function createStructuredLogger(logger: LoggerService, context: string): StructuredLogger;
