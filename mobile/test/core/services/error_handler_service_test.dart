import 'package:flutter_test/flutter_test.dart';
import 'package:financial_kingdom_builder/core/services/error_handler_service.dart';
import 'package:financial_kingdom_builder/core/exceptions/app_exceptions.dart';

void main() {
  group('ErrorHandlerService', () {
    group('safeExecute', () {
      test('should return operation result when no exception occurs', () {
        final result = ErrorHandlerService.safeExecute(
          () => 42,
          fallbackValue: 0,
        );
        expect(result, equals(42));
      });

      test('should return fallback value when exception occurs', () {
        final result = ErrorHandlerService.safeExecute(
          () => throw const KingdomException('Test error'),
          fallbackValue: 0,
        );
        expect(result, equals(0));
      });

      test('should handle non-Exception errors', () {
        final result = ErrorHandlerService.safeExecute(
          () => throw 'String error',
          fallbackValue: 0,
        );
        expect(result, equals(0));
      });
    });

    group('safeExecuteAsync', () {
      test('should return operation result when no exception occurs', () async {
        final result = await ErrorHandlerService.safeExecuteAsync(
          () async => 42,
          fallbackValue: 0,
        );
        expect(result, equals(42));
      });

      test('should return fallback value when exception occurs', () async {
        final result = await ErrorHandlerService.safeExecuteAsync(
          () async => throw const KingdomException('Test error'),
          fallbackValue: 0,
        );
        expect(result, equals(0));
      });

      test('should handle async non-Exception errors', () async {
        final result = await ErrorHandlerService.safeExecuteAsync(
          () async => throw 'Async string error',
          fallbackValue: 0,
        );
        expect(result, equals(0));
      });

      test('should handle delayed async operations', () async {
        final result = await ErrorHandlerService.safeExecuteAsync(
          () async {
            await Future.delayed(const Duration(milliseconds: 10));
            return 'success';
          },
          fallbackValue: 'failed',
        );
        expect(result, equals('success'));
      });
    });

    group('createUserFriendlyMessage', () {
      test('should return user-friendly message for KingdomException', () {
        const exception = KingdomException(
          'Invalid tier progression: Not enough XP',
          code: 'INVALID_TIER_PROGRESSION',
        );
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('You need to complete more requirements before advancing to the next tier.'),
        );
      });

      test('should return user-friendly message for EducationException', () {
        const exception = EducationException(
          'Module not found',
          code: 'MODULE_NOT_FOUND',
        );
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('The requested lesson could not be found.'),
        );
      });

      test('should return user-friendly message for ResourceException', () {
        const exception = ResourceException('Insufficient gold');
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('Insufficient resources. Complete more lessons to earn resources.'),
        );
      });

      test('should return user-friendly message for XPCalculationException', () {
        const exception = XPCalculationException('Invalid XP value');
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('There was an issue calculating your experience points.'),
        );
      });

      test('should return user-friendly message for AuthException', () {
        const exception = AuthException('Invalid credentials');
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('Authentication failed. Please check your credentials.'),
        );
      });

      test('should return user-friendly message for StorageException', () {
        const exception = StorageException('Data corruption');
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('There was an issue saving your progress. Please try again.'),
        );
      });

      test('should return user-friendly message for NetworkException', () {
        const exception = NetworkException('Connection failed');
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('Network connection failed. Please check your internet connection.'),
        );
      });

      test('should return generic message for unknown AppException', () {
        const exception = TierProgressionException('Unknown error');
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('An unexpected error occurred. Please try again.'),
        );
      });

      test('should return generic message for non-AppException', () {
        final exception = Exception('Regular exception');
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('An unexpected error occurred. Please try again.'),
        );
      });
    });

    group('isRecoverable', () {
      test('should return true for recoverable exceptions', () {
        const connectionException = NetworkException(
          'Connection failed',
          code: 'CONNECTION_FAILED',
        );
        expect(ErrorHandlerService.isRecoverable(connectionException), isTrue);

        const timeoutException = NetworkException(
          'Timeout',
          code: 'TIMEOUT',
        );
        expect(ErrorHandlerService.isRecoverable(timeoutException), isTrue);
      });

      test('should return false for non-recoverable exceptions', () {
        const dataException = StorageException(
          'Data corrupted',
          code: 'DATA_CORRUPTED',
        );
        expect(ErrorHandlerService.isRecoverable(dataException), isFalse);

        const authException = AuthException(
          'Invalid credentials',
          code: 'INVALID_CREDENTIALS',
        );
        expect(ErrorHandlerService.isRecoverable(authException), isFalse);
      });

      test('should return true for unknown AppException codes', () {
        const unknownException = KingdomException(
          'Unknown error',
          code: 'UNKNOWN_CODE',
        );
        expect(ErrorHandlerService.isRecoverable(unknownException), isTrue);
      });

      test('should return true for AppException without code', () {
        const noCodeException = KingdomException('Error without code');
        expect(ErrorHandlerService.isRecoverable(noCodeException), isTrue);
      });

      test('should return false for non-AppException', () {
        final regularException = Exception('Regular exception');
        expect(ErrorHandlerService.isRecoverable(regularException), isFalse);
      });
    });

    group('Education-specific error messages', () {
      test('should handle MODULE_ALREADY_COMPLETED error', () {
        const exception = EducationException(
          'Module already completed',
          code: 'MODULE_ALREADY_COMPLETED',
        );
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('You have already completed this lesson.'),
        );
      });

      test('should handle unknown education error codes', () {
        const exception = EducationException(
          'Unknown education error',
          code: 'UNKNOWN_EDUCATION_ERROR',
        );
        final message = ErrorHandlerService.createUserFriendlyMessage(exception);
        expect(
          message,
          equals('There was an issue with the educational content. Please try again.'),
        );
      });
    });

    group('Context and logging', () {
      test('should handle context parameter in safeExecute', () {
        final result = ErrorHandlerService.safeExecute(
          () => throw const KingdomException('Test error'),
          fallbackValue: 'fallback',
          context: 'Test Context',
        );
        expect(result, equals('fallback'));
      });

      test('should handle context parameter in safeExecuteAsync', () async {
        final result = await ErrorHandlerService.safeExecuteAsync(
          () async => throw const KingdomException('Test error'),
          fallbackValue: 'fallback',
          context: 'Test Async Context',
        );
        expect(result, equals('fallback'));
      });

      test('should disable logging when logError is false', () {
        final result = ErrorHandlerService.safeExecute(
          () => throw const KingdomException('Test error'),
          fallbackValue: 'fallback',
          logError: false,
        );
        expect(result, equals('fallback'));
      });
    });
  });

  group('ErrorInfo', () {
    test('should create ErrorInfo with message and code', () {
      const errorInfo = ErrorInfo('Test message', 'TEST_CODE');
      expect(errorInfo.userMessage, equals('Test message'));
      expect(errorInfo.code, equals('TEST_CODE'));
    });
  });
}