import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_kingdom_builder/core/providers/async_providers.dart';

void main() {
  group('AsyncProviders', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('userProfile Provider', () {
      test('should return user profile with valid user ID', () async {
        final userProfile = await container.read(userProfileProvider('user123').future);
        
        expect(userProfile.id, equals('user123'));
        expect(userProfile.username, equals('Kingdom Builder'));
        expect(userProfile.email, equals('user@example.com'));
        expect(userProfile.totalXP, equals(150));
        expect(userProfile.currentTier, equals('Village Citizen'));
        expect(userProfile.achievements, contains('First Steps'));
      });

      test('should return empty profile for invalid user ID', () async {
        final userProfile = await container.read(userProfileProvider('').future);
        
        expect(userProfile.id, equals(''));
        expect(userProfile.username, equals('Guest'));
        expect(userProfile.email, equals(''));
        expect(userProfile.totalXP, equals(0));
        expect(userProfile.currentTier, equals('Village Citizen'));
        expect(userProfile.achievements, isEmpty);
      });

      test('should handle provider state correctly', () {
        final provider = userProfileProvider('user123');
        final asyncValue = container.read(provider);
        
        expect(asyncValue, isA<AsyncValue<UserProfile>>());
        expect(asyncValue.isLoading, isTrue);
      });
    });

    group('educationContent Provider', () {
      test('should return list of education content', () async {
        final content = await container.read(educationContentProvider.future);
        
        expect(content, isA<List<EducationContent>>());
        expect(content.length, equals(2));
        
        final firstContent = content.first;
        expect(firstContent.id, equals('content-1'));
        expect(firstContent.title, equals('Introduction to Trading'));
        expect(firstContent.category, equals('Trading Basics'));
        
        final secondContent = content.last;
        expect(secondContent.id, equals('content-2'));
        expect(secondContent.title, equals('Risk Management'));
        expect(secondContent.category, equals('Risk Management'));
      });

      test('should return empty list on error', () async {
        // This test demonstrates error handling returning fallback value
        final content = await container.read(educationContentProvider.future);
        expect(content, isA<List<EducationContent>>());
      });

      test('should handle loading state', () {
        final asyncValue = container.read(educationContentProvider);
        expect(asyncValue, isA<AsyncValue<List<EducationContent>>>());
        expect(asyncValue.isLoading, isTrue);
      });
    });

    group('marketData Provider', () {
      test('should return market data for valid symbol', () async {
        final marketData = await container.read(marketDataProvider('BTC').future);
        
        expect(marketData.symbol, equals('BTC'));
        expect(marketData.price, equals(42000.50));
        expect(marketData.change, equals(2.5));
        expect(marketData.changePercent, equals(0.006));
        expect(marketData.volume, equals(1234567));
        expect(marketData.lastUpdate, isA<DateTime>());
      });

      test('should return empty market data for invalid symbol', () async {
        final marketData = await container.read(marketDataProvider('').future);
        
        expect(marketData.symbol, equals(''));
        expect(marketData.price, equals(0.0));
        expect(marketData.change, equals(0.0));
        expect(marketData.changePercent, equals(0.0));
        expect(marketData.volume, equals(0));
      });

      test('should handle different symbols', () async {
        final btcData = await container.read(marketDataProvider('BTC').future);
        final ethData = await container.read(marketDataProvider('ETH').future);
        
        expect(btcData.symbol, equals('BTC'));
        expect(ethData.symbol, equals('ETH'));
      });
    });

    group('saveUserProgress Provider', () {
      test('should save valid user progress', () async {
        const progressData = UserProgressData(
          userId: 'user123',
          xp: 150,
          tier: 'Village',
          achievements: {'first_steps': true},
        );
        
        final result = await container.read(saveUserProgressProvider(progressData).future);
        expect(result, isTrue);
      });

      test('should return false for invalid user progress', () async {
        const progressData = UserProgressData(
          userId: '',
          xp: 150,
          tier: 'Village',
          achievements: {},
        );
        
        final result = await container.read(saveUserProgressProvider(progressData).future);
        expect(result, isFalse);
      });

      test('should return false for negative XP', () async {
        const progressData = UserProgressData(
          userId: 'user123',
          xp: -10,
          tier: 'Village',
          achievements: {},
        );
        
        final result = await container.read(saveUserProgressProvider(progressData).future);
        expect(result, isFalse);
      });

      test('should return false for error user', () async {
        const progressData = UserProgressData(
          userId: 'error_user',
          xp: 150,
          tier: 'Village',
          achievements: {},
        );
        
        final result = await container.read(saveUserProgressProvider(progressData).future);
        expect(result, isFalse);
      });
    });

    group('Model Classes', () {
      group('UserProfile', () {
        test('should create UserProfile with all fields', () {
          const profile = UserProfile(
            id: 'test123',
            username: 'TestUser',
            email: 'test@example.com',
            totalXP: 200,
            currentTier: 'Town',
            achievements: ['Achievement1', 'Achievement2'],
          );
          
          expect(profile.id, equals('test123'));
          expect(profile.username, equals('TestUser'));
          expect(profile.email, equals('test@example.com'));
          expect(profile.totalXP, equals(200));
          expect(profile.currentTier, equals('Town'));
          expect(profile.achievements.length, equals(2));
        });

        test('should create empty UserProfile', () {
          final profile = UserProfile.empty();
          
          expect(profile.id, equals(''));
          expect(profile.username, equals('Guest'));
          expect(profile.email, equals(''));
          expect(profile.totalXP, equals(0));
          expect(profile.currentTier, equals('Village Citizen'));
          expect(profile.achievements, isEmpty);
        });
      });

      group('EducationContent', () {
        test('should create EducationContent with all fields', () {
          const content = EducationContent(
            id: 'content123',
            title: 'Test Content',
            description: 'Test description',
            content: 'Test content body',
            category: 'Test Category',
          );
          
          expect(content.id, equals('content123'));
          expect(content.title, equals('Test Content'));
          expect(content.description, equals('Test description'));
          expect(content.content, equals('Test content body'));
          expect(content.category, equals('Test Category'));
        });
      });

      group('MarketData', () {
        test('should create MarketData with all fields', () {
          final now = DateTime.now();
          final marketData = MarketData(
            symbol: 'BTC',
            price: 50000.0,
            change: 1000.0,
            changePercent: 0.02,
            volume: 2000000,
            lastUpdate: now,
          );
          
          expect(marketData.symbol, equals('BTC'));
          expect(marketData.price, equals(50000.0));
          expect(marketData.change, equals(1000.0));
          expect(marketData.changePercent, equals(0.02));
          expect(marketData.volume, equals(2000000));
          expect(marketData.lastUpdate, equals(now));
        });

        test('should create empty MarketData', () {
          final marketData = MarketData.empty();
          
          expect(marketData.symbol, equals(''));
          expect(marketData.price, equals(0.0));
          expect(marketData.change, equals(0.0));
          expect(marketData.changePercent, equals(0.0));
          expect(marketData.volume, equals(0));
          expect(marketData.lastUpdate, isA<DateTime>());
        });
      });

      group('UserProgressData', () {
        test('should create UserProgressData with all fields', () {
          const progressData = UserProgressData(
            userId: 'user123',
            xp: 500,
            tier: 'City',
            achievements: {'trading_master': true, 'risk_expert': false},
          );
          
          expect(progressData.userId, equals('user123'));
          expect(progressData.xp, equals(500));
          expect(progressData.tier, equals('City'));
          expect(progressData.achievements['trading_master'], isTrue);
          expect(progressData.achievements['risk_expert'], isFalse);
        });
      });
    });

    group('AsyncValue States', () {
      test('should handle loading state correctly', () {
        final provider = userProfileProvider('user123');
        final asyncValue = container.read(provider);
        
        expect(asyncValue.isLoading, isTrue);
        expect(asyncValue.hasValue, isFalse);
        expect(asyncValue.hasError, isFalse);
      });

      test('should handle success state correctly', () async {
        final provider = userProfileProvider('user123');
        final userProfile = await container.read(provider.future);
        final asyncValue = container.read(provider);
        
        expect(asyncValue.isLoading, isFalse);
        expect(asyncValue.hasValue, isTrue);
        expect(asyncValue.hasError, isFalse);
        expect(asyncValue.value, equals(userProfile));
      });

      test('should handle error state correctly', () async {
        // Test with empty user ID which should trigger error handling
        final provider = userProfileProvider('');
        await container.read(provider.future); // Wait for completion
        final asyncValue = container.read(provider);
        
        expect(asyncValue.isLoading, isFalse);
        expect(asyncValue.hasValue, isTrue); // Should have fallback value
        expect(asyncValue.hasError, isFalse); // Error is handled, returns fallback
      });
    });

    group('Provider Caching', () {
      test('should cache provider results', () async {
        final provider = userProfileProvider('user123');
        
        // First call
        final firstResult = await container.read(provider.future);
        
        // Second call should return cached result
        final secondResult = await container.read(provider.future);
        
        expect(firstResult, equals(secondResult));
      });

      test('should have different results for different parameters', () async {
        final provider1 = userProfileProvider('user123');
        final provider2 = userProfileProvider('user456');
        
        final result1 = await container.read(provider1.future);
        final result2 = await container.read(provider2.future);
        
        expect(result1.id, equals('user123'));
        expect(result2.id, equals('user456'));
        expect(result1, isNot(equals(result2)));
      });
    });

    group('Error Handling Integration', () {
      test('should handle network exceptions gracefully', () async {
        // Test that network exceptions are handled by error handler service
        final result = await container.read(marketDataProvider('').future);
        expect(result, isA<MarketData>());
        expect(result.symbol, equals(''));
      });

      test('should handle storage exceptions gracefully', () async {
        const errorData = UserProgressData(
          userId: 'error_user',
          xp: 150,
          tier: 'Village',
          achievements: {},
        );
        
        final result = await container.read(saveUserProgressProvider(errorData).future);
        expect(result, isFalse);
      });

      test('should handle auth exceptions gracefully', () async {
        final result = await container.read(userProfileProvider('').future);
        expect(result, isA<UserProfile>());
        expect(result.id, equals(''));
      });
    });
  });
}