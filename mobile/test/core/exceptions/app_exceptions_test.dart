import 'package:flutter_test/flutter_test.dart';
import 'package:financial_kingdom_builder/core/exceptions/app_exceptions.dart';

void main() {
  group('AppException', () {
    test('should create exception with message', () {
      const exception = KingdomException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.code, isNull);
      expect(exception.originalError, isNull);
    });

    test('should create exception with message and code', () {
      const exception = KingdomException(
        'Test error',
        code: 'TEST_ERROR',
      );
      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('TEST_ERROR'));
    });

    test('should create exception with all parameters', () {
      const originalError = 'Original error';
      const exception = KingdomException(
        'Test error',
        code: 'TEST_ERROR',
        originalError: originalError,
      );
      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('TEST_ERROR'));
      expect(exception.originalError, equals(originalError));
    });

    test('toString should format correctly', () {
      const exception = KingdomException(
        'Test error',
        code: 'TEST_ERROR',
      );
      expect(
        exception.toString(),
        equals('AppException: Test error (Code: TEST_ERROR)'),
      );
    });

    test('toString should format correctly without code', () {
      const exception = KingdomException('Test error');
      expect(
        exception.toString(),
        equals('AppException: Test error'),
      );
    });
  });

  group('AppExceptions utility methods', () {
    test('invalidTierProgression should create correct exception', () {
      final exception = AppExceptions.invalidTierProgression('Not enough XP');
      expect(exception, isA<KingdomException>());
      expect(exception.message, equals('Invalid tier progression: Not enough XP'));
      expect(exception.code, equals('INVALID_TIER_PROGRESSION'));
    });

    test('insufficientResources should create correct exception', () {
      final exception = AppExceptions.insufficientResources('gold', 100, 50);
      expect(exception, isA<ResourceException>());
      expect(
        exception.message,
        equals('Insufficient gold: required 100, available 50'),
      );
      expect(exception.code, equals('INSUFFICIENT_RESOURCES'));
    });

    test('invalidXPValue should create correct exception', () {
      final exception = AppExceptions.invalidXPValue(-10);
      expect(exception, isA<XPCalculationException>());
      expect(
        exception.message,
        equals('Invalid XP value: -10. XP cannot be negative.'),
      );
      expect(exception.code, equals('INVALID_XP_VALUE'));
    });

    test('moduleNotFound should create correct exception', () {
      final exception = AppExceptions.moduleNotFound('module-123');
      expect(exception, isA<EducationException>());
      expect(
        exception.message,
        equals('Education module not found: module-123'),
      );
      expect(exception.code, equals('MODULE_NOT_FOUND'));
    });

    test('moduleAlreadyCompleted should create correct exception', () {
      final exception = AppExceptions.moduleAlreadyCompleted('module-123');
      expect(exception, isA<EducationException>());
      expect(
        exception.message,
        equals('Module already completed: module-123'),
      );
      expect(exception.code, equals('MODULE_ALREADY_COMPLETED'));
    });

    test('dataCorrupted should create correct exception', () {
      final exception = AppExceptions.dataCorrupted('Invalid format');
      expect(exception, isA<StorageException>());
      expect(
        exception.message,
        equals('Data corruption detected: Invalid format'),
      );
      expect(exception.code, equals('DATA_CORRUPTED'));
    });

    test('connectionFailed should create correct exception', () {
      final exception = AppExceptions.connectionFailed('/api/user');
      expect(exception, isA<NetworkException>());
      expect(
        exception.message,
        equals('Failed to connect to /api/user'),
      );
      expect(exception.code, equals('CONNECTION_FAILED'));
    });

    test('invalidCredentials should create correct exception', () {
      final exception = AppExceptions.invalidCredentials();
      expect(exception, isA<AuthException>());
      expect(
        exception.message,
        equals('Invalid credentials provided'),
      );
      expect(exception.code, equals('INVALID_CREDENTIALS'));
    });
  });

  group('Exception Types', () {
    test('should create different exception types', () {
      expect(
        const KingdomException('test'),
        isA<KingdomException>(),
      );
      expect(
        const EducationException('test'),
        isA<EducationException>(),
      );
      expect(
        const XPCalculationException('test'),
        isA<XPCalculationException>(),
      );
      expect(
        const TierProgressionException('test'),
        isA<TierProgressionException>(),
      );
      expect(
        const ResourceException('test'),
        isA<ResourceException>(),
      );
      expect(
        const AuthException('test'),
        isA<AuthException>(),
      );
      expect(
        const StorageException('test'),
        isA<StorageException>(),
      );
      expect(
        const NetworkException('test'),
        isA<NetworkException>(),
      );
    });

    test('all exceptions should inherit from AppException', () {
      expect(const KingdomException('test'), isA<AppException>());
      expect(const EducationException('test'), isA<AppException>());
      expect(const XPCalculationException('test'), isA<AppException>());
      expect(const TierProgressionException('test'), isA<AppException>());
      expect(const ResourceException('test'), isA<AppException>());
      expect(const AuthException('test'), isA<AppException>());
      expect(const StorageException('test'), isA<AppException>());
      expect(const NetworkException('test'), isA<AppException>());
    });
  });
}