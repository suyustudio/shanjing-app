/**
 * Result 类型类
 * 
 * 用于处理可能成功或失败的操作，替代 nullable 返回值
 * 
 * @author 山径开发团队
 * @since M4 P2
 */

import 'error_handler.dart';

/// 结果类型，封装成功或失败的状态
/// 
/// 使用示例:
/// ```dart
/// Result<String> result = await safeAsync(() => fetchData());
/// 
/// if (result.isSuccess) {
///   print(result.value);
/// } else {
///   print(result.error.message);
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// 是否成功
  bool get isSuccess;

  /// 是否失败
  bool get isFailure;

  /// 成功时的值（失败时为 null）
  T? get value;

  /// 失败时的错误（成功时为 null）
  AppError? get error;

  /// 获取值或默认值
  T getOrElse(T defaultValue) => isSuccess ? value! : defaultValue;

  /// 获取值或抛出异常
  T getOrThrow() {
    if (isFailure) throw error!;
    return value!;
  }

  /// 成功时执行操作
  Result<T> onSuccess(void Function(T value) action) {
    if (isSuccess) action(value as T);
    return this;
  }

  /// 失败时执行操作
  Result<T> onFailure(void Function(AppError error) action) {
    if (isFailure) action(error!);
    return this;
  }

  /// 映射成功值
  Result<R> map<R>(R Function(T value) transform) {
    if (isSuccess) {
      return Success(transform(value as T));
    }
    return Failure(error!);
  }

  /// 链式调用另一个可能失败的操作
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    if (isSuccess) {
      return transform(value as T);
    }
    return Failure(error!);
  }

  @override
  String toString() {
    if (isSuccess) return 'Result.success($value)';
    return 'Result.failure($error)';
  }
}

/// 成功结果
class Success<T> extends Result<T> {
  final T _value;

  const Success(this._value);

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  T get value => _value;

  @override
  AppError? get error => null;
}

/// 失败结果
class Failure<T> extends Result<T> {
  final AppError _error;

  const Failure(this._error);

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  T? get value => null;

  @override
  AppError get error => _error;
}

/// 便捷构造函数
Result<T> success<T>(T value) => Success(value);
Result<T> failure<T>(AppError error) => Failure(error);
