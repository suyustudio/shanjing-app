// ================================================================
// HTTP Exception Filter
// 全局 HTTP 异常过滤器 - 统一错误响应格式
// ================================================================

import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { AchievementError } from '../../modules/achievements/errors/achievement.errors';

/**
 * 统一错误响应格式
 */
export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
    timestamp: string;
    path: string;
  };
}

/**
 * 全局 HTTP 异常过滤器
 * 将所有异常转换为统一的响应格式
 */
@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let errorResponse: ErrorResponse;

    // 处理已知的业务错误
    if (exception instanceof AchievementError) {
      const error = exception as AchievementError;
      status = error.statusCode;
      errorResponse = {
        success: false,
        error: {
          code: error.code,
          message: error.message,
          details: error.details,
          timestamp: new Date().toISOString(),
          path: request.url,
        },
      };
    }
    // 处理 NestJS HTTP 异常
    else if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      
      let message: string;
      let code = 'HTTP_ERROR';
      
      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
      } else if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        const responseObj = exceptionResponse as Record<string, any>;
        message = responseObj.message || '请求失败';
        code = responseObj.error || code;
      } else {
        message = '请求失败';
      }

      errorResponse = {
        success: false,
        error: {
          code,
          message,
          timestamp: new Date().toISOString(),
          path: request.url,
        },
      };
    }
    // 处理其他未知错误
    else {
      const error = exception as Error;
      this.logger.error(`Unexpected error: ${error?.message}`, error?.stack);

      errorResponse = {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: '服务器内部错误',
          timestamp: new Date().toISOString(),
          path: request.url,
        },
      };
    }

    // 记录错误日志
    if (status >= 500) {
      this.logger.error(
        `[${request.method}] ${request.url} - ${status} - ${errorResponse.error.code}: ${errorResponse.error.message}`
      );
    } else {
      this.logger.warn(
        `[${request.method}] ${request.url} - ${status} - ${errorResponse.error.code}: ${errorResponse.error.message}`
      );
    }

    response.status(status).json(errorResponse);
  }
}
