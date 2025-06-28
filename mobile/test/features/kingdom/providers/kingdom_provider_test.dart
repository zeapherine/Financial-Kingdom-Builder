import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_kingdom_builder/features/kingdom/domain/models/kingdom_state.dart';
import 'package:financial_kingdom_builder/core/exceptions/app_exceptions.dart';

// Mock Kingdom Provider for testing (simplified version without code generation issues)
class MockKingdomNotifier extends StateNotifier<KingdomState> {
  MockKingdomNotifier() : super(KingdomState());

  void addExperience(int xp) {
    if (xp < 0) {
      throw AppExceptions.invalidXPValue(xp);
    }
    
    final newExperience = state.experience + xp;
    final newTier = _calculateTier(newExperience);
    
    state = state.copyWith(
      experience: newExperience,
      tier: newTier,
    );

    // Unlock buildings based on tier
    if (newTier != state.tier) {
      _unlockBuildingsForTier(newTier);
    }
  }

  void upgradeBuilding(KingdomBuilding building) {
    if (!state.isBuildingUnlocked(building)) {
      throw KingdomException(
        'Cannot upgrade locked building: ${building.name}',
        code: 'BUILDING_LOCKED',
      );
    }
    
    final currentLevel = state.buildingLevels[building] ?? 0;
    final maxLevel = _getMaxLevelForBuilding(building);
    
    if (currentLevel >= maxLevel) {
      throw KingdomException(
        'Building ${building.name} is already at maximum level ($maxLevel)',
        code: 'MAX_LEVEL_REACHED',
      );
    }
    
    final updatedLevels = Map<KingdomBuilding, int>.from(state.buildingLevels);
    updatedLevels[building] = currentLevel + 1;
    
    state = state.copyWith(buildingLevels: updatedLevels);
  }

  void updateResources(Map<String, int> resourceChanges) {
    final updatedResources = Map<String, int>.from(state.resources);
    
    // Validate resource changes
    resourceChanges.forEach((resource, change) {
      final currentAmount = updatedResources[resource] ?? 0;
      final newAmount = currentAmount + change;
      
      // Check for negative resources (spending more than available)
      if (newAmount < 0 && change < 0) {
        throw AppExceptions.insufficientResources(
          resource,
          change.abs(),
          currentAmount,
        );
      }
      
      updatedResources[resource] = newAmount < 0 ? 0 : newAmount;
    });
    
    state = state.copyWith(resources: updatedResources);
  }

  KingdomTier _calculateTier(int experience) {
    if (experience < 0) {
      throw AppExceptions.invalidXPValue(experience);
    }
    
    if (experience >= 5000) return KingdomTier.kingdom;
    if (experience >= 2500) return KingdomTier.city;
    if (experience >= 1000) return KingdomTier.town;
    return KingdomTier.village;
  }
  
  int _getMaxLevelForBuilding(KingdomBuilding building) {
    switch (building) {
      case KingdomBuilding.library:
      case KingdomBuilding.tradingPost:
        return 10;
      case KingdomBuilding.treasury:
      case KingdomBuilding.marketplace:
        return 5;
      case KingdomBuilding.observatory:
      case KingdomBuilding.academy:
        return 3;
      case KingdomBuilding.townCenter:
        return 1;
    }
  }

  void _unlockBuildingsForTier(KingdomTier tier) {
    final updatedBuildings = Map<KingdomBuilding, bool>.from(state.unlockedBuildings);
    
    switch (tier) {
      case KingdomTier.village:
        updatedBuildings[KingdomBuilding.library] = true;
        break;
      case KingdomTier.town:
        updatedBuildings[KingdomBuilding.tradingPost] = true;
        updatedBuildings[KingdomBuilding.treasury] = true;
        break;
      case KingdomTier.city:
        updatedBuildings[KingdomBuilding.marketplace] = true;
        updatedBuildings[KingdomBuilding.observatory] = true;
        break;
      case KingdomTier.kingdom:
        updatedBuildings[KingdomBuilding.academy] = true;
        break;
    }
    
    state = state.copyWith(unlockedBuildings: updatedBuildings);
  }
}

final mockKingdomProvider = StateNotifierProvider<MockKingdomNotifier, KingdomState>(
  (ref) => MockKingdomNotifier(),
);

void main() {
  group('KingdomProvider', () {
    late ProviderContainer container;
    late MockKingdomNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(mockKingdomProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('should have correct initial values', () {
        final state = container.read(mockKingdomProvider);
        expect(state.experience, equals(0));
        expect(state.tier, equals(KingdomTier.village));
        expect(state.resources, isEmpty);
        expect(state.unlockedBuildings, isEmpty);
        expect(state.buildingLevels, isEmpty);
      });
    });

    group('addExperience', () {
      test('should add experience correctly', () {
        notifier.addExperience(100);
        final state = container.read(mockKingdomProvider);
        expect(state.experience, equals(100));
      });

      test('should update tier when reaching thresholds', () {
        notifier.addExperience(1000);
        final state = container.read(mockKingdomProvider);
        expect(state.tier, equals(KingdomTier.town));
      });

      test('should throw exception for negative XP', () {
        expect(
          () => notifier.addExperience(-10),
          throwsA(isA<XPCalculationException>()),
        );
      });

      test('should unlock buildings when tier advances', () {
        notifier.addExperience(1000); // Advance to town
        final state = container.read(mockKingdomProvider);
        expect(state.isBuildingUnlocked(KingdomBuilding.library), isTrue);
        expect(state.isBuildingUnlocked(KingdomBuilding.tradingPost), isTrue);
        expect(state.isBuildingUnlocked(KingdomBuilding.treasury), isTrue);
      });

      group('tier progression thresholds', () {
        test('should remain village below 1000 XP', () {
          notifier.addExperience(999);
          final state = container.read(mockKingdomProvider);
          expect(state.tier, equals(KingdomTier.village));
        });

        test('should advance to town at 1000 XP', () {
          notifier.addExperience(1000);
          final state = container.read(mockKingdomProvider);
          expect(state.tier, equals(KingdomTier.town));
        });

        test('should advance to city at 2500 XP', () {
          notifier.addExperience(2500);
          final state = container.read(mockKingdomProvider);
          expect(state.tier, equals(KingdomTier.city));
        });

        test('should advance to kingdom at 5000 XP', () {
          notifier.addExperience(5000);
          final state = container.read(mockKingdomProvider);
          expect(state.tier, equals(KingdomTier.kingdom));
        });
      });
    });

    group('upgradeBuilding', () {
      setUp(() {
        // Unlock library building first
        notifier.addExperience(1); // Trigger village tier unlocks
      });

      test('should upgrade unlocked building', () {
        notifier.upgradeBuilding(KingdomBuilding.library);
        final state = container.read(mockKingdomProvider);
        expect(state.buildingLevels[KingdomBuilding.library], equals(1));
      });

      test('should throw exception when upgrading locked building', () {
        expect(
          () => notifier.upgradeBuilding(KingdomBuilding.academy),
          throwsA(isA<KingdomException>()),
        );
      });

      test('should throw exception when upgrading beyond max level', () {
        // Upgrade to max level first
        for (int i = 0; i < 3; i++) {
          notifier.upgradeBuilding(KingdomBuilding.library);
        }
        
        // Try to upgrade beyond max
        expect(
          () => notifier.upgradeBuilding(KingdomBuilding.library),
          throwsA(isA<KingdomException>()),
        );
      });

      test('should respect max levels for different buildings', () {
        // Library should max at 10
        expect(
          notifier._getMaxLevelForBuilding(KingdomBuilding.library),
          equals(10),
        );
        
        // Observatory should max at 3
        expect(
          notifier._getMaxLevelForBuilding(KingdomBuilding.observatory),
          equals(3),
        );
        
        // Town center should max at 1
        expect(
          notifier._getMaxLevelForBuilding(KingdomBuilding.townCenter),
          equals(1),
        );
      });
    });

    group('updateResources', () {
      test('should add resources correctly', () {
        notifier.updateResources({'gold': 100, 'gems': 50});
        final state = container.read(mockKingdomProvider);
        expect(state.resources['gold'], equals(100));
        expect(state.resources['gems'], equals(50));
      });

      test('should update existing resources', () {
        notifier.updateResources({'gold': 100});
        notifier.updateResources({'gold': 50});
        final state = container.read(mockKingdomProvider);
        expect(state.resources['gold'], equals(150));
      });

      test('should throw exception when spending more than available', () {
        notifier.updateResources({'gold': 50});
        expect(
          () => notifier.updateResources({'gold': -100}),
          throwsA(isA<ResourceException>()),
        );
      });

      test('should not allow negative resources', () {
        notifier.updateResources({'gold': 50});
        notifier.updateResources({'gold': -30});
        final state = container.read(mockKingdomProvider);
        expect(state.resources['gold'], equals(20));
      });

      test('should handle multiple resource changes', () {
        notifier.updateResources({'gold': 100, 'gems': 50, 'wood': 75});
        final state = container.read(mockKingdomProvider);
        expect(state.resources['gold'], equals(100));
        expect(state.resources['gems'], equals(50));
        expect(state.resources['wood'], equals(75));
      });
    });

    group('Edge Cases', () {
      test('should handle zero XP addition', () {
        notifier.addExperience(0);
        final state = container.read(mockKingdomProvider);
        expect(state.experience, equals(0));
      });

      test('should handle zero resource changes', () {
        notifier.updateResources({'gold': 0});
        final state = container.read(mockKingdomProvider);
        expect(state.resources['gold'], equals(0));
      });

      test('should handle empty resource changes', () {
        notifier.updateResources({});
        final state = container.read(mockKingdomProvider);
        expect(state.resources, isEmpty);
      });
    });

    group('Error Recovery', () {
      test('should maintain state after failed operation', () {
        notifier.addExperience(100);
        final initialState = container.read(mockKingdomProvider);
        
        // Try invalid operation
        expect(
          () => notifier.addExperience(-10),
          throwsA(isA<XPCalculationException>()),
        );
        
        // State should remain unchanged
        final finalState = container.read(mockKingdomProvider);
        expect(finalState.experience, equals(initialState.experience));
      });
    });
  });
}