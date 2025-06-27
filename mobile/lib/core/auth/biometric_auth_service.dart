import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Types of biometric authentication available
enum BiometricType {
  fingerprint,
  face,
  iris,
  weak,
  strong,
}

/// Biometric authentication result
enum BiometricAuthResult {
  success,
  failure,
  cancelled,
  notAvailable,
  notEnrolled,
  lockedOut,
  temporaryLockout,
  permissionDenied,
  unknown,
}

/// Biometric authentication configuration
class BiometricAuthConfig {
  final String localizedFallbackTitle;
  final String signInTitle;
  final String cancelButtonText;
  final bool biometricOnly;
  final bool stickyAuth;
  final bool sensitiveTransaction;
  final Duration lockoutDuration;

  const BiometricAuthConfig({
    this.localizedFallbackTitle = 'Use PIN/Password',
    this.signInTitle = 'Sign in to Financial Kingdom Builder',
    this.cancelButtonText = 'Cancel',
    this.biometricOnly = false,
    this.stickyAuth = true,
    this.sensitiveTransaction = false,
    this.lockoutDuration = const Duration(minutes: 30),
  });
}

/// Secure storage for biometric authentication data
class BiometricSecureStorage {
  static const String _keyPrefix = 'fkb_biometric_';
  static const String _enabledKey = '${_keyPrefix}enabled';
  static const String _typeKey = '${_keyPrefix}type';
  static const String _userIdKey = '${_keyPrefix}user_id';
  static const String _challengeKey = '${_keyPrefix}challenge';
  static const String _lockoutKey = '${_keyPrefix}lockout';
  static const String _failureCountKey = '${_keyPrefix}failure_count';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_enabledKey, enabled);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> setBiometricType(BiometricType type) async {
    final prefs = await _prefs;
    await prefs.setString(_typeKey, type.toString());
  }

  static Future<BiometricType?> getBiometricType() async {
    final prefs = await _prefs;
    final typeString = prefs.getString(_typeKey);
    if (typeString == null) return null;
    
    return BiometricType.values.firstWhere(
      (type) => type.toString() == typeString,
      orElse: () => BiometricType.fingerprint,
    );
  }

  static Future<void> setUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  static Future<void> setChallenge(String challenge) async {
    final prefs = await _prefs;
    await prefs.setString(_challengeKey, challenge);
  }

  static Future<String?> getChallenge() async {
    final prefs = await _prefs;
    return prefs.getString(_challengeKey);
  }

  static Future<void> setLockoutTime(DateTime lockoutTime) async {
    final prefs = await _prefs;
    await prefs.setInt(_lockoutKey, lockoutTime.millisecondsSinceEpoch);
  }

  static Future<DateTime?> getLockoutTime() async {
    final prefs = await _prefs;
    final timestamp = prefs.getInt(_lockoutKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  static Future<void> clearLockout() async {
    final prefs = await _prefs;
    await prefs.remove(_lockoutKey);
    await prefs.remove(_failureCountKey);
  }

  static Future<void> incrementFailureCount() async {
    final prefs = await _prefs;
    final currentCount = prefs.getInt(_failureCountKey) ?? 0;
    await prefs.setInt(_failureCountKey, currentCount + 1);
  }

  static Future<int> getFailureCount() async {
    final prefs = await _prefs;
    return prefs.getInt(_failureCountKey) ?? 0;
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

/// Biometric authentication service for Financial Kingdom Builder
class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final BiometricAuthConfig _config;
  static const int _maxFailureAttempts = 3;

  BiometricAuthService({
    LocalAuthentication? localAuth,
    BiometricAuthConfig config = const BiometricAuthConfig(),
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _config = config;

  /// Check if biometric authentication is available on device
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if biometrics are enrolled on device
  Future<bool> isEnrolled() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking biometric enrollment: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final platformBiometrics = await _localAuth.getAvailableBiometrics();
      return platformBiometrics.map((platformType) {
        switch (platformType.toString()) {
          case 'BiometricType.fingerprint':
            return BiometricType.fingerprint;
          case 'BiometricType.face':
            return BiometricType.face;
          case 'BiometricType.iris':
            return BiometricType.iris;
          case 'BiometricType.weak':
            return BiometricType.weak;
          case 'BiometricType.strong':
            return BiometricType.strong;
          default:
            return BiometricType.fingerprint;
        }
      }).toList();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if biometric authentication is currently locked out
  Future<bool> isLockedOut() async {
    final lockoutTime = await BiometricSecureStorage.getLockoutTime();
    if (lockoutTime == null) return false;
    
    final now = DateTime.now();
    final isStillLockedOut = now.isBefore(lockoutTime.add(_config.lockoutDuration));
    
    if (!isStillLockedOut) {
      await BiometricSecureStorage.clearLockout();
    }
    
    return isStillLockedOut;
  }

  /// Get remaining lockout time
  Future<Duration?> getRemainingLockoutTime() async {
    final lockoutTime = await BiometricSecureStorage.getLockoutTime();
    if (lockoutTime == null) return null;
    
    final unlockTime = lockoutTime.add(_config.lockoutDuration);
    final now = DateTime.now();
    
    if (now.isBefore(unlockTime)) {
      return unlockTime.difference(now);
    }
    
    return null;
  }

  /// Enable biometric authentication for user
  Future<BiometricAuthResult> enableBiometricAuth(String userId) async {
    try {
      // Check if biometrics are available and enrolled
      if (!await isAvailable()) {
        return BiometricAuthResult.notAvailable;
      }
      
      if (!await isEnrolled()) {
        return BiometricAuthResult.notEnrolled;
      }

      // Check if already locked out
      if (await isLockedOut()) {
        return BiometricAuthResult.lockedOut;
      }

      // Generate a challenge for the user
      final challenge = _generateChallenge(userId);
      
      // Authenticate to enable biometric
      final authResult = await _performAuthentication(
        reason: 'Enable biometric authentication for secure access',
        challenge: challenge,
      );

      if (authResult == BiometricAuthResult.success) {
        // Store biometric settings
        await BiometricSecureStorage.setBiometricEnabled(true);
        await BiometricSecureStorage.setUserId(userId);
        await BiometricSecureStorage.setChallenge(challenge);
        
        // Set the primary biometric type
        final availableBiometrics = await getAvailableBiometrics();
        if (availableBiometrics.isNotEmpty) {
          await BiometricSecureStorage.setBiometricType(availableBiometrics.first);
        }

        debugPrint('Biometric authentication enabled for user: $userId');
      }

      return authResult;
    } catch (e) {
      debugPrint('Error enabling biometric auth: $e');
      return BiometricAuthResult.unknown;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuth() async {
    try {
      await BiometricSecureStorage.clearAll();
      debugPrint('Biometric authentication disabled');
    } catch (e) {
      debugPrint('Error disabling biometric auth: $e');
    }
  }

  /// Authenticate user with biometrics
  Future<BiometricAuthResult> authenticate({
    String? reason,
    bool forSensitiveOperation = false,
  }) async {
    try {
      // Check if biometric auth is enabled
      if (!await BiometricSecureStorage.isBiometricEnabled()) {
        return BiometricAuthResult.notAvailable;
      }

      // Check if currently locked out
      if (await isLockedOut()) {
        return BiometricAuthResult.lockedOut;
      }

      // Get stored challenge
      final storedChallenge = await BiometricSecureStorage.getChallenge();
      if (storedChallenge == null) {
        return BiometricAuthResult.notAvailable;
      }

      // Perform authentication
      final authReason = reason ?? 
          (forSensitiveOperation 
              ? 'Authenticate for secure trading operation'
              : 'Authenticate to access Financial Kingdom Builder');

      final result = await _performAuthentication(
        reason: authReason,
        challenge: storedChallenge,
        sensitiveTransaction: forSensitiveOperation,
      );

      // Handle authentication result
      if (result == BiometricAuthResult.success) {
        await BiometricSecureStorage.clearLockout();
      } else if (result == BiometricAuthResult.failure) {
        await _handleAuthenticationFailure();
      }

      return result;
    } catch (e) {
      debugPrint('Error during biometric authentication: $e');
      return BiometricAuthResult.unknown;
    }
  }

  /// Authenticate for trading operations with additional security
  Future<BiometricAuthResult> authenticateForTrading({
    required String operationType,
    String? amount,
    String? symbol,
  }) async {
    final reason = amount != null && symbol != null
        ? 'Confirm $operationType of $amount $symbol'
        : 'Confirm trading operation: $operationType';

    return authenticate(
      reason: reason,
      forSensitiveOperation: true,
    );
  }

  /// Re-authenticate user (for settings changes, etc.)
  Future<BiometricAuthResult> reAuthenticate() async {
    final userId = await BiometricSecureStorage.getUserId();
    if (userId == null) {
      return BiometricAuthResult.notAvailable;
    }

    // Generate new challenge for re-authentication
    final challenge = _generateChallenge(userId);
    
    final result = await _performAuthentication(
      reason: 'Re-authenticate to modify security settings',
      challenge: challenge,
      sensitiveTransaction: true,
    );

    if (result == BiometricAuthResult.success) {
      // Update challenge after successful re-authentication
      await BiometricSecureStorage.setChallenge(challenge);
    }

    return result;
  }

  /// Check if biometric authentication is currently enabled
  Future<bool> isEnabled() async {
    return await BiometricSecureStorage.isBiometricEnabled();
  }

  /// Get the current biometric type being used
  Future<BiometricType?> getCurrentBiometricType() async {
    return await BiometricSecureStorage.getBiometricType();
  }

  /// Update biometric type (if multiple are available)
  Future<BiometricAuthResult> updateBiometricType(BiometricType newType) async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      if (!availableBiometrics.contains(newType)) {
        return BiometricAuthResult.notAvailable;
      }

      // Re-authenticate before changing type
      final reAuthResult = await reAuthenticate();
      if (reAuthResult != BiometricAuthResult.success) {
        return reAuthResult;
      }

      await BiometricSecureStorage.setBiometricType(newType);
      return BiometricAuthResult.success;
    } catch (e) {
      debugPrint('Error updating biometric type: $e');
      return BiometricAuthResult.unknown;
    }
  }

  /// Perform the actual biometric authentication
  Future<BiometricAuthResult> _performAuthentication({
    required String reason,
    required String challenge,
    bool sensitiveTransaction = false,
  }) async {
    try {
      final authOptions = AuthenticationOptions(
        biometricOnly: _config.biometricOnly,
        stickyAuth: _config.stickyAuth,
        sensitiveTransaction: sensitiveTransaction || _config.sensitiveTransaction,
      );

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: authOptions,
      );

      if (result) {
        return BiometricAuthResult.success;
      } else {
        return BiometricAuthResult.failure;
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication platform exception: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'NotAvailable':
          return BiometricAuthResult.notAvailable;
        case 'NotEnrolled':
          return BiometricAuthResult.notEnrolled;
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          return BiometricAuthResult.lockedOut;
        case 'UserCancel':
          return BiometricAuthResult.cancelled;
        case 'UserFallback':
          return BiometricAuthResult.cancelled;
        case 'BiometricOnlyNotSupported':
          return BiometricAuthResult.notAvailable;
        case 'DeviceNotSupported':
          return BiometricAuthResult.notAvailable;
        case 'PasscodeNotSet':
          return BiometricAuthResult.notEnrolled;
        case 'AuthenticationFailed':
          return BiometricAuthResult.failure;
        default:
          return BiometricAuthResult.unknown;
      }
    } catch (e) {
      debugPrint('Unexpected biometric authentication error: $e');
      return BiometricAuthResult.unknown;
    }
  }

  /// Handle authentication failure
  Future<void> _handleAuthenticationFailure() async {
    await BiometricSecureStorage.incrementFailureCount();
    final failureCount = await BiometricSecureStorage.getFailureCount();
    
    if (failureCount >= _maxFailureAttempts) {
      // Lock out biometric authentication
      await BiometricSecureStorage.setLockoutTime(DateTime.now());
      debugPrint('Biometric authentication locked out due to too many failures');
    }
  }

  /// Generate a cryptographic challenge for the user
  String _generateChallenge(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$userId:$timestamp:${Platform.operatingSystem}';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get biometric authentication status summary
  Future<Map<String, dynamic>> getStatus() async {
    return {
      'isAvailable': await isAvailable(),
      'isEnrolled': await isEnrolled(),
      'isEnabled': await isEnabled(),
      'isLockedOut': await isLockedOut(),
      'availableBiometrics': (await getAvailableBiometrics())
          .map((type) => type.toString())
          .toList(),
      'currentType': (await getCurrentBiometricType())?.toString(),
      'failureCount': await BiometricSecureStorage.getFailureCount(),
      'remainingLockoutTime': (await getRemainingLockoutTime())?.inMinutes,
    };
  }

  /// Reset biometric authentication state (for testing/debugging)
  Future<void> reset() async {
    await BiometricSecureStorage.clearAll();
    debugPrint('Biometric authentication state reset');
  }
}

/// Singleton instance for global access
class BiometricAuth {
  static BiometricAuthService? _instance;
  
  static BiometricAuthService get instance {
    _instance ??= BiometricAuthService();
    return _instance!;
  }

  static void setInstance(BiometricAuthService service) {
    _instance = service;
  }
}

/// Extension to convert BiometricAuthResult to user-friendly strings
extension BiometricAuthResultExtension on BiometricAuthResult {
  String get message {
    switch (this) {
      case BiometricAuthResult.success:
        return 'Authentication successful';
      case BiometricAuthResult.failure:
        return 'Authentication failed. Please try again.';
      case BiometricAuthResult.cancelled:
        return 'Authentication cancelled by user';
      case BiometricAuthResult.notAvailable:
        return 'Biometric authentication not available on this device';
      case BiometricAuthResult.notEnrolled:
        return 'No biometrics enrolled. Please set up biometric authentication in device settings.';
      case BiometricAuthResult.lockedOut:
        return 'Biometric authentication temporarily locked due to too many failed attempts';
      case BiometricAuthResult.temporaryLockout:
        return 'Biometric authentication temporarily unavailable. Please try again later.';
      case BiometricAuthResult.permissionDenied:
        return 'Permission denied for biometric authentication';
      case BiometricAuthResult.unknown:
        return 'An unknown error occurred during authentication';
    }
  }

  bool get isSuccess => this == BiometricAuthResult.success;
  bool get isFailure => this != BiometricAuthResult.success;
}