library;

/// Custom exceptions for the Financial Kingdom Builder app
/// 
/// This file defines domain-specific exceptions that can occur during
/// state management operations, providing clear error types and messages.

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when kingdom state operations fail
class KingdomException extends AppException {
  const KingdomException(super.message, {super.code, super.originalError});
}

/// Exception thrown when educational operations fail
class EducationException extends AppException {
  const EducationException(super.message, {super.code, super.originalError});
}

/// Exception thrown when XP calculations fail
class XPCalculationException extends AppException {
  const XPCalculationException(super.message, {super.code, super.originalError});
}

/// Exception thrown when tier progression fails
class TierProgressionException extends AppException {
  const TierProgressionException(super.message, {super.code, super.originalError});
}

/// Exception thrown when resource operations fail
class ResourceException extends AppException {
  const ResourceException(super.message, {super.code, super.originalError});
}

/// Exception thrown when authentication operations fail
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
}

/// Exception thrown when data persistence operations fail
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.originalError});
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

/// Utility class for common exception creation
class AppExceptions {
  static KingdomException invalidTierProgression(String details) {
    return KingdomException(
      'Invalid tier progression: $details',
      code: 'INVALID_TIER_PROGRESSION',
    );
  }

  static ResourceException insufficientResources(String resource, int required, int available) {
    return ResourceException(
      'Insufficient $resource: required $required, available $available',
      code: 'INSUFFICIENT_RESOURCES',
    );
  }

  static XPCalculationException invalidXPValue(int xp) {
    return XPCalculationException(
      'Invalid XP value: $xp. XP cannot be negative.',
      code: 'INVALID_XP_VALUE',
    );
  }

  static EducationException moduleNotFound(String moduleId) {
    return EducationException(
      'Education module not found: $moduleId',
      code: 'MODULE_NOT_FOUND',
    );
  }

  static EducationException moduleAlreadyCompleted(String moduleId) {
    return EducationException(
      'Module already completed: $moduleId',
      code: 'MODULE_ALREADY_COMPLETED',
    );
  }

  static StorageException dataCorrupted(String details) {
    return StorageException(
      'Data corruption detected: $details',
      code: 'DATA_CORRUPTED',
    );
  }

  static NetworkException connectionFailed(String endpoint) {
    return NetworkException(
      'Failed to connect to $endpoint',
      code: 'CONNECTION_FAILED',
    );
  }

  static AuthException invalidCredentials() {
    return const AuthException(
      'Invalid credentials provided',
      code: 'INVALID_CREDENTIALS',
    );
  }
}