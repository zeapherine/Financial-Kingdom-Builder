import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exceptions/app_exceptions.dart';

/// Service for centralized error handling and logging
/// 
/// This service provides consistent error handling patterns across the app,
/// including logging, user notification, and error recovery strategies.
class ErrorHandlerService {
  static const String _loggerName = 'ErrorHandler';

  /// Handles exceptions with appropriate logging and user feedback
  static void handleException(
    Exception exception, {
    String? context,
    bool notifyUser = true,
    bool logError = true,
  }) {
    final errorInfo = _extractErrorInfo(exception);
    
    if (logError) {
      _logError(exception, context, errorInfo);
    }

    if (notifyUser) {
      _notifyUser(errorInfo);
    }
  }

  /// Safely executes a function with error handling
  static T safeExecute<T>(
    T Function() operation, {
    required T fallbackValue,
    String? context,
    bool logError = true,
  }) {
    try {
      return operation();
    } catch (e) {
      if (e is Exception) {
        handleException(
          e,
          context: context,
          notifyUser: false,
          logError: logError,
        );
      } else {
        _logError(
          Exception('Unexpected error: $e'),
          context,
          ErrorInfo('Unexpected error occurred', 'UNEXPECTED_ERROR'),
        );
      }
      return fallbackValue;
    }
  }

  /// Safely executes an async function with error handling
  static Future<T> safeExecuteAsync<T>(
    Future<T> Function() operation, {
    required T fallbackValue,
    String? context,
    bool logError = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      if (e is Exception) {
        handleException(
          e,
          context: context,
          notifyUser: false,
          logError: logError,
        );
      } else {
        _logError(
          Exception('Unexpected async error: $e'),
          context,
          ErrorInfo('Unexpected async error occurred', 'UNEXPECTED_ASYNC_ERROR'),
        );
      }
      return fallbackValue;
    }
  }

  /// Creates a standardized error message for user display
  static String createUserFriendlyMessage(Exception exception) {
    final errorInfo = _extractErrorInfo(exception);
    return errorInfo.userMessage;
  }

  /// Checks if an exception is recoverable
  static bool isRecoverable(Exception exception) {
    if (exception is AppException) {
      switch (exception.code) {
        case 'CONNECTION_FAILED':
        case 'TIMEOUT':
          return true;
        case 'DATA_CORRUPTED':
        case 'INVALID_CREDENTIALS':
          return false;
        default:
          return true;
      }
    }
    return false;
  }

  static ErrorInfo _extractErrorInfo(Exception exception) {
    if (exception is AppException) {
      return ErrorInfo(
        _getUserFriendlyMessage(exception),
        exception.code ?? 'UNKNOWN_ERROR',
      );
    }
    return ErrorInfo(
      'An unexpected error occurred. Please try again.',
      'UNEXPECTED_ERROR',
    );
  }

  static String _getUserFriendlyMessage(AppException exception) {
    if (exception is KingdomException) {
      return _getKingdomErrorMessage(exception);
    } else if (exception is EducationException) {
      return _getEducationErrorMessage(exception);
    } else if (exception is ResourceException) {
      return 'Insufficient resources. Complete more lessons to earn resources.';
    } else if (exception is XPCalculationException) {
      return 'There was an issue calculating your experience points.';
    } else if (exception is AuthException) {
      return 'Authentication failed. Please check your credentials.';
    } else if (exception is StorageException) {
      return 'There was an issue saving your progress. Please try again.';
    } else if (exception is NetworkException) {
      return 'Network connection failed. Please check your internet connection.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _getKingdomErrorMessage(AppException exception) {
    switch (exception.code) {
      case 'INVALID_TIER_PROGRESSION':
        return 'You need to complete more requirements before advancing to the next tier.';
      default:
        return 'There was an issue with your kingdom. Please try again.';
    }
  }

  static String _getEducationErrorMessage(AppException exception) {
    switch (exception.code) {
      case 'MODULE_NOT_FOUND':
        return 'The requested lesson could not be found.';
      case 'MODULE_ALREADY_COMPLETED':
        return 'You have already completed this lesson.';
      default:
        return 'There was an issue with the educational content. Please try again.';
    }
  }

  static void _logError(Exception exception, String? context, ErrorInfo errorInfo) {
    final message = 'Error${context != null ? ' in $context' : ''}: ${errorInfo.code} - ${exception.toString()}';
    
    if (kDebugMode) {
      developer.log(
        message,
        name: _loggerName,
        error: exception,
      );
    }
  }

  static void _notifyUser(ErrorInfo errorInfo) {
    // In a real implementation, this would show a snackbar, toast, or dialog
    // For now, we'll just log it in debug mode
    if (kDebugMode) {
      developer.log(
        'User notification: ${errorInfo.userMessage}',
        name: _loggerName,
      );
    }
  }
}

/// Information about an error for consistent handling
class ErrorInfo {
  final String userMessage;
  final String code;

  const ErrorInfo(this.userMessage, this.code);
}

/// Provider for the error handler service
final errorHandlerServiceProvider = Provider<ErrorHandlerService>((ref) {
  return ErrorHandlerService();
});