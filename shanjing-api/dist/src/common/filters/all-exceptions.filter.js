"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var AllExceptionsFilter_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AllExceptionsFilter = void 0;
const common_1 = require("@nestjs/common");
let AllExceptionsFilter = AllExceptionsFilter_1 = class AllExceptionsFilter {
    constructor() {
        this.logger = new common_1.Logger(AllExceptionsFilter_1.name);
    }
    catch(exception, host) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse();
        const request = ctx.getRequest();
        let status = common_1.HttpStatus.INTERNAL_SERVER_ERROR;
        let errorResponse = {
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: '服务器内部错误',
            },
        };
        if (exception instanceof common_1.HttpException) {
            status = exception.getStatus();
            const exceptionResponse = exception.getResponse();
            if (typeof exceptionResponse === 'object' &&
                exceptionResponse !== null &&
                'success' in exceptionResponse) {
                errorResponse = exceptionResponse;
            }
            else {
                const message = typeof exceptionResponse === 'string'
                    ? exceptionResponse
                    : exceptionResponse.message || '请求错误';
                errorResponse = {
                    success: false,
                    error: {
                        code: this.getErrorCode(status),
                        message,
                    },
                };
            }
        }
        this.logger.error(`${request.method} ${request.url} - ${status}`, exception instanceof Error ? exception.stack : 'Unknown error');
        response.status(status).json(errorResponse);
    }
    getErrorCode(status) {
        const codeMap = {
            [common_1.HttpStatus.BAD_REQUEST]: 'BAD_REQUEST',
            [common_1.HttpStatus.UNAUTHORIZED]: 'UNAUTHORIZED',
            [common_1.HttpStatus.FORBIDDEN]: 'FORBIDDEN',
            [common_1.HttpStatus.NOT_FOUND]: 'NOT_FOUND',
            [common_1.HttpStatus.CONFLICT]: 'CONFLICT',
            [common_1.HttpStatus.UNPROCESSABLE_ENTITY]: 'VALIDATION_ERROR',
            [common_1.HttpStatus.TOO_MANY_REQUESTS]: 'RATE_LIMITED',
            [common_1.HttpStatus.INTERNAL_SERVER_ERROR]: 'INTERNAL_ERROR',
        };
        return codeMap[status] || 'UNKNOWN_ERROR';
    }
};
exports.AllExceptionsFilter = AllExceptionsFilter;
exports.AllExceptionsFilter = AllExceptionsFilter = AllExceptionsFilter_1 = __decorate([
    (0, common_1.Catch)()
], AllExceptionsFilter);
//# sourceMappingURL=all-exceptions.filter.js.map