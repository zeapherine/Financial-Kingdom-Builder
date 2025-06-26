import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/error_handler_service.dart';
import '../exceptions/app_exceptions.dart';

part 'async_providers.g.dart';

/// Example async provider demonstrating AsyncValue patterns
/// This serves as a template for future API integrations
@riverpod
Future<UserProfile> userProfile(Ref ref, String userId) async {
  return await ErrorHandlerService.safeExecuteAsync(
    () async {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate potential network failure
      if (userId.isEmpty) {
        throw const AuthException(
          'User ID cannot be empty',
          code: 'EMPTY_USER_ID',
        );
      }
      
      // Simulate API response
      return UserProfile(
        id: userId,
        username: 'Kingdom Builder',
        email: 'user@example.com',
        totalXP: 150,
        currentTier: 'Village Citizen',
        achievements: ['First Steps', 'Week Warrior'],
      );
    },
    fallbackValue: UserProfile.empty(),
    context: 'AsyncProviders.userProfile',
  );
}

/// Async provider for loading educational content
@riverpod
Future<List<EducationContent>> educationContent(Ref ref) async {
  return await ErrorHandlerService.safeExecuteAsync(
    () async {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      return [
        EducationContent(
          id: 'content-1',
          title: 'Introduction to Trading',
          description: 'Learn the basics of financial trading',
          content: 'Trading involves buying and selling financial instruments...',
          category: 'Trading Basics',
        ),
        EducationContent(
          id: 'content-2',
          title: 'Risk Management',
          description: 'Understanding and managing investment risk',
          content: 'Risk management is crucial for successful trading...',
          category: 'Risk Management',
        ),
      ];
    },
    fallbackValue: <EducationContent>[],
    context: 'AsyncProviders.educationContent',
  );
}

/// Async provider for market data (for future trading features)
@riverpod
Future<MarketData> marketData(Ref ref, String symbol) async {
  return await ErrorHandlerService.safeExecuteAsync(
    () async {
      // Simulate API call to market data provider
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (symbol.isEmpty) {
        throw const NetworkException(
          'Symbol parameter is required',
          code: 'MISSING_SYMBOL',
        );
      }
      
      // Simulate market data response
      return MarketData(
        symbol: symbol,
        price: 42000.50,
        change: 2.5,
        changePercent: 0.006,
        volume: 1234567,
        lastUpdate: DateTime.now(),
      );
    },
    fallbackValue: MarketData.empty(),
    context: 'AsyncProviders.marketData',
  );
}

/// Async provider for saving user progress (demonstrates error handling)
@riverpod
Future<bool> saveUserProgress(Ref ref, UserProgressData data) async {
  return await ErrorHandlerService.safeExecuteAsync(
    () async {
      // Simulate save operation
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Validate data before saving
      if (data.userId.isEmpty) {
        throw const StorageException(
          'User ID is required for saving progress',
          code: 'MISSING_USER_ID',
        );
      }
      
      if (data.xp < 0) {
        throw AppExceptions.invalidXPValue(data.xp);
      }
      
      // Simulate potential storage failure
      if (data.userId == 'error_user') {
        throw AppExceptions.dataCorrupted('Simulated storage error');
      }
      
      // Success
      return true;
    },
    fallbackValue: false,
    context: 'AsyncProviders.saveUserProgress',
  );
}

/// Model classes for async provider examples

class UserProfile {
  final String id;
  final String username;
  final String email;
  final int totalXP;
  final String currentTier;
  final List<String> achievements;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.totalXP,
    required this.currentTier,
    required this.achievements,
  });

  factory UserProfile.empty() {
    return const UserProfile(
      id: '',
      username: 'Guest',
      email: '',
      totalXP: 0,
      currentTier: 'Village Citizen',
      achievements: [],
    );
  }
}

class EducationContent {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category;

  const EducationContent({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.category,
  });
}

class MarketData {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final int volume;
  final DateTime lastUpdate;

  const MarketData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.lastUpdate,
  });

  factory MarketData.empty() {
    return MarketData(
      symbol: '',
      price: 0.0,
      change: 0.0,
      changePercent: 0.0,
      volume: 0,
      lastUpdate: DateTime.now(),
    );
  }
}

class UserProgressData {
  final String userId;
  final int xp;
  final String tier;
  final Map<String, dynamic> achievements;

  const UserProgressData({
    required this.userId,
    required this.xp,
    required this.tier,
    required this.achievements,
  });
}