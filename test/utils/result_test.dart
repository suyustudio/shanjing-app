import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/utils/result.dart';
import 'package:hangzhou_guide/utils/error_handler.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create Success with value', () {
        final result = Success<String>('test');

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.value, 'test');
        expect(result.error, isNull);
      });

      test('should work with success helper function', () {
        final result = success<String>('test');

        expect(result.isSuccess, true);
        expect(result.value, 'test');
      });
    });

    group('Failure', () {
      test('should create Failure with error', () {
        final error = AppError(type: AppErrorType.network, message: 'Network error');
        final result = Failure<String>(error);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.value, isNull);
        expect(result.error, error);
      });

      test('should work with failure helper function', () {
        final error = AppError(type: AppErrorType.network, message: 'Network error');
        final result = failure<String>(error);

        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });

    group('getOrElse', () {
      test('should return value on Success', () {
        final result = Success<int>(42);

        expect(result.getOrElse(0), 42);
      });

      test('should return default on Failure', () {
        final error = AppError(type: AppErrorType.network, message: 'Error');
        final result = Failure<int>(error);

        expect(result.getOrElse(0), 0);
      });
    });

    group('getOrThrow', () {
      test('should return value on Success', () {
        final result = Success<int>(42);

        expect(result.getOrThrow(), 42);
      });

      test('should throw on Failure', () {
        final error = AppError(type: AppErrorType.network, message: 'Error');
        final result = Failure<int>(error);

        expect(() => result.getOrThrow(), throwsA(equals(error)));
      });
    });

    group('onSuccess', () {
      test('should execute action on Success', () {
        final result = Success<int>(42);
        int? capturedValue;

        result.onSuccess((value) => capturedValue = value);

        expect(capturedValue, 42);
      });

      test('should not execute action on Failure', () {
        final error = AppError(type: AppErrorType.network, message: 'Error');
        final result = Failure<int>(error);
        int? capturedValue;

        result.onSuccess((value) => capturedValue = value);

        expect(capturedValue, isNull);
      });

      test('should return self for chaining', () {
        final result = Success<int>(42);

        final returned = result.onSuccess((_) {});

        expect(returned, equals(result));
      });
    });

    group('onFailure', () {
      test('should execute action on Failure', () {
        final error = AppError(type: AppErrorType.network, message: 'Error');
        final result = Failure<int>(error);
        AppError? capturedError;

        result.onFailure((e) => capturedError = e);

        expect(capturedError, error);
      });

      test('should not execute action on Success', () {
        final result = Success<int>(42);
        AppError? capturedError;

        result.onFailure((e) => capturedError = e);

        expect(capturedError, isNull);
      });

      test('should return self for chaining', () {
        final error = AppError(type: AppErrorType.network, message: 'Error');
        final result = Failure<int>(error);

        final returned = result.onFailure((_) {});

        expect(returned, equals(result));
      });
    });

    group('map', () {
      test('should transform value on Success', () {
        final result = Success<int>(21);

        final mapped = result.map((v) => v * 2);

        expect(mapped.isSuccess, true);
        expect(mapped.value, 42);
      });

      test('should propagate error on Failure', () {
        final error = AppError(type: AppErrorType.network, message: 'Error');
        final result = Failure<int>(error);

        final mapped = result.map((v) => v * 2);

        expect(mapped.isFailure, true);
        expect(mapped.error, error);
      });
    });

    group('flatMap', () {
      test('should chain successful operations', () {
        final result = Success<int>(21);

        final flatMapped = result.flatMap((v) => Success<int>(v * 2));

        expect(flatMapped.isSuccess, true);
        expect(flatMapped.value, 42);
      });

      test('should propagate error through chain', () {
        final error = AppError(type: AppErrorType.network, message: 'Error');
        final result = Failure<int>(error);

        final flatMapped = result.flatMap((v) => Success<int>(v * 2));

        expect(flatMapped.isFailure, true);
        expect(flatMapped.error, error);
      });

      test('should fail if chained operation fails', () {
        final error = AppError(type: AppErrorType.server, message: 'Server error');
        final result = Success<int>(21);

        final flatMapped = result.flatMap((v) => Failure<int>(error));

        expect(flatMapped.isFailure, true);
        expect(flatMapped.error, error);
      });
    });

    group('chaining', () {
      test('should support method chaining', () {
        final result = Success<int>(42);
        int? successValue;
        AppError? failureError;

        result
            .onSuccess((v) => successValue = v)
            .onFailure((e) => failureError = e);

        expect(successValue, 42);
        expect(failureError, isNull);
      });

      test('should support chaining with failure', () {
        final error = AppError(type: AppErrorType.network, message: 'Error');
        final result = Failure<int>(error);
        int? successValue;
        AppError? failureError;

        result
            .onSuccess((v) => successValue = v)
            .onFailure((e) => failureError = e);

        expect(successValue, isNull);
        expect(failureError, error);
      });
    });

    group('toString', () {
      test('should format Success correctly', () {
        final result = Success<String>('test');

        expect(result.toString(), 'Result.success(test)');
      });

      test('should format Failure correctly', () {
        final error = AppError(type: AppErrorType.network, message: 'Error');
        final result = Failure<String>(error);

        expect(result.toString(), 'Result.failure($error)');
      });
    });

    group('generic type safety', () {
      test('should preserve type information', () {
        final stringResult = Success<String>('hello');
        final intResult = Success<int>(42);

        expect(stringResult.value, isA<String>());
        expect(intResult.value, isA<int>());
      });

      test('should work with complex types', () {
        final listResult = Success<List<int>>([1, 2, 3]);

        expect(listResult.value, isA<List<int>>());
        expect(listResult.value!.length, 3);
      });
    });
  });
}
