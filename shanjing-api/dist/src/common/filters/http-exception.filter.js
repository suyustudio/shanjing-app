"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var HttpExceptionFilter_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.HttpExceptionFilter = void 0;
const common_1 = require("@nestjs/common");
const achievement_errors_1 = require("../../modules/achievements/errors/achievement.errors");
let HttpExceptionFilter = HttpExceptionFilter_1 = class HttpExceptionFilter {
    constructor() {
        this.logger = new common_1.Logger(HttpExceptionFilter_1.name);
    }
    catch(exception, host) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse();
        const request = ctx.getRequest();
        let status = common_1.HttpStatus.INTERNAL_SERVER_ERROR;
        let errorResponse;
        if (exception instanceof achievement_errors_1.AchievementError) {
            const error = exception;
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
        else if (exception instanceof common_1.HttpException) {
            status = exception.getStatus();
            const exceptionResponse = exception.getResponse();
            let message;
            let code = 'HTTP_ERROR';
            if (typeof exceptionResponse === 'string') {
                message = exceptionResponse;
            }
            else if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
                const responseObj = exceptionResponse;
                message = responseObj.message || '请求失败';
                code = responseObj.error || code;
            }
            else {
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
        else {
            const error = exception;
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
        if (status >= 500) {
            this.logger.error(`[${request.method}] ${request.url} - ${status} - ${errorResponse.error.code}: ${errorResponse.error.message}`);
        }
        else {
            this.logger.warn(`[${request.method}] ${request.url} - ${status} - ${errorResponse.error.code}: ${errorResponse.error.message}`);
        }
        response.status(status).json(errorResponse);
    }
};
exports.HttpExceptionFilter = HttpExceptionFilter;
exports.HttpExceptionFilter = HttpExceptionFilter = HttpExceptionFilter_1 = __decorate([
    (0, common_1.Catch)()
], HttpExceptionFilter);
//# sourceMappingURL=http-exception.filter.js.map