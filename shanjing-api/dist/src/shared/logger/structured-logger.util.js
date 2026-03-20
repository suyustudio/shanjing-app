"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PerformanceTimer = exports.StructuredLogger = void 0;
exports.createStructuredLogger = createStructuredLogger;
class StructuredLogger {
    constructor(logger, defaultContext) {
        this.logger = logger;
        this.defaultContext = defaultContext;
    }
    info(message, context) {
        this.logger.log(this.formatMessage(message, context), this.defaultContext);
    }
    debug(message, context) {
        this.logger.debug(this.formatMessage(message, context), this.defaultContext);
    }
    warn(message, error, context) {
        const errorDetails = error instanceof Error ? ` | error: ${error.message}` : '';
        this.logger.warn(this.formatMessage(message, context) + errorDetails, this.defaultContext);
    }
    error(message, error, context) {
        const formattedMessage = this.formatMessage(message, context);
        if (error instanceof Error) {
            this.logger.error(formattedMessage, error.stack, this.defaultContext);
        }
        else {
            this.logger.error(formattedMessage, undefined, this.defaultContext);
        }
    }
    performance(logData, context) {
        const { operation, durationMs, success, metadata } = logData;
        const status = success ? 'SUCCESS' : 'FAILED';
        const perfMessage = `[PERF] operation=${operation} duration=${durationMs}ms status=${status}`;
        if (durationMs > 500) {
            this.logger.warn(this.formatMessage(`${perfMessage} [SLOW]`, { ...context, ...metadata }), this.defaultContext);
        }
        else {
            this.logger.debug(this.formatMessage(perfMessage, { ...context, ...metadata }), this.defaultContext);
        }
    }
    startTimer(operation, context) {
        return new PerformanceTimer(this, operation, context);
    }
    formatMessage(message, context) {
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
exports.StructuredLogger = StructuredLogger;
class PerformanceTimer {
    constructor(logger, operation, context) {
        this.logger = logger;
        this.operation = operation;
        this.context = context;
        this.startTime = performance.now();
    }
    end(metadata, success = true) {
        const durationMs = Math.round(performance.now() - this.startTime);
        this.logger.performance({
            operation: this.operation,
            durationMs,
            success,
            metadata,
        }, this.context);
        return durationMs;
    }
    fail(error, metadata) {
        return this.end({ ...metadata, error: error?.message }, false);
    }
}
exports.PerformanceTimer = PerformanceTimer;
function createStructuredLogger(logger, context) {
    return new StructuredLogger(logger, context);
}
//# sourceMappingURL=structured-logger.util.js.map