// ================================================================
// 日志工具模块
// 提供统一的日志格式和性能追踪功能
// ================================================================

import { LoggerService } from '@nestjs/common';

/**
 * 日志上下文接口
 */
export interface LogContext {
  /** 用户ID */
  userId?: string;
  /** 路线ID */
  trailId?: string;
  /** 成就ID */
  achievementId?: string;
  /** 请求ID */
  requestId?: string;
  /** 其他上下文 */
  [key: string]: any;
}

/**
 * 性能日志数据接口
 */
export interface PerformanceLog {
  /** 操作名称 */
  operation: string;
  /** 耗时 (毫秒) */
  durationMs: number;
  /** 是否成功 */
  success: boolean;
  /** 额外数据 */
  metadata?: Record<string, any>;
}

/**
 * 结构化日志工具类
 */
export class StructuredLogger {
  constructor(
    private readonly logger: LoggerService,
    private readonly defaultContext: string,
  ) {}

  /**
   * 记录信息日志
   */
  info(message: string, context?: LogContext): void {
    this.logger.log(this.formatMessage(message, context), this.defaultContext);
  }

  /**
   * 记录调试日志
   */
  debug(message: string, context?: LogContext): void {
    this.logger.debug(this.formatMessage(message, context), this.defaultContext);
  }

  /**
   * 记录警告日志
   */
  warn(message: string, error?: Error | unknown, context?: LogContext): void {
    const errorDetails = error instanceof Error ? ` | error: ${error.message}` : '';
    this.logger.warn(this.formatMessage(message, context) + errorDetails, this.defaultContext);
  }

  /**
   * 记录错误日志
   */
  error(message: string, error?: Error | unknown, context?: LogContext): void {
    const formattedMessage = this.formatMessage(message, context);
    if (error instanceof Error) {
      this.logger.error(formattedMessage, error.stack, this.defaultContext);
    } else {
      this.logger.error(formattedMessage, undefined, this.defaultContext);
    }
  }

  /**
   * 记录性能日志
   */
  performance(logData: PerformanceLog, context?: LogContext): void {
    const { operation, durationMs, success, metadata } = logData;
    const status = success ? 'SUCCESS' : 'FAILED';
    const perfMessage = `[PERF] operation=${operation} duration=${durationMs}ms status=${status}`;
    
    // 慢操作警告 (>500ms)
    if (durationMs > 500) {
      this.logger.warn(
        this.formatMessage(`${perfMessage} [SLOW]`, { ...context, ...metadata }),
        this.defaultContext,
      );
    } else {
      this.logger.debug(
        this.formatMessage(perfMessage, { ...context, ...metadata }),
        this.defaultContext,
      );
    }
  }

  /**
   * 创建性能追踪器
   */
  startTimer(operation: string, context?: LogContext): PerformanceTimer {
    return new PerformanceTimer(this, operation, context);
  }

  /**
   * 格式化日志消息
   */
  private formatMessage(message: string, context?: LogContext): string {
    if (!context || Object.keys(context).length === 0) {
      return message;
    }

    const contextStr = Object.entries(context)
      .filter(([, value]) => value !== undefined)
      .map(([key, value]) => `${key}=${value}`)
      .join(' ');

    return `[${contextStr}] ${message}`;
  }
}

/**
 * 性能计时器
 */
export class PerformanceTimer {
  private readonly startTime: number;

  constructor(
    private readonly logger: StructuredLogger,
    private readonly operation: string,
    private readonly context?: LogContext,
  ) {
    this.startTime = performance.now();
  }

  /**
   * 结束计时并记录日志
   */
  end(metadata?: Record<string, any>, success: boolean = true): number {
    const durationMs = Math.round(performance.now() - this.startTime);
    this.logger.performance(
      {
        operation: this.operation,
        durationMs,
        success,
        metadata,
      },
      this.context,
    );
    return durationMs;
  }

  /**
   * 结束计时（失败状态）
   */
  fail(error?: Error, metadata?: Record<string, any>): number {
    return this.end({ ...metadata, error: error?.message }, false);
  }
}

/**
 * 创建结构化日志记录器工厂函数
 */
export function createStructuredLogger(
  logger: LoggerService,
  context: string,
): StructuredLogger {
  return new StructuredLogger(logger, context);
}
