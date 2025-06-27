import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/kingdom_state.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/error_handler_service.dart';

part 'kingdom_provider.g.dart';

@Riverpod(keepAlive: true)
class KingdomNotifier extends _$KingdomNotifier {
  static const String _storageKey = 'kingdom_state';

  @override
  KingdomState build() {
    _loadKingdomState();
    return const KingdomState();
  }

  void addExperience(int xp) {
    ErrorHandlerService.safeExecute(
      () {
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
        
        // Save state after changes
        _saveKingdomState();
      },
      fallbackValue: null,
      context: 'KingdomProvider.addExperience',
    );
  }

  void unlockBuilding(KingdomBuilding building) {
    final updatedBuildings = Map<KingdomBuilding, bool>.from(state.unlockedBuildings);
    updatedBuildings[building] = true;
    
    state = state.copyWith(unlockedBuildings: updatedBuildings);
  }

  void upgradeBuilding(KingdomBuilding building) {
    ErrorHandlerService.safeExecute(
      () {
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
      },
      fallbackValue: null,
      context: 'KingdomProvider.upgradeBuilding',
    );
  }

  void updateResources(Map<String, int> resourceChanges) {
    ErrorHandlerService.safeExecute(
      () {
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
      },
      fallbackValue: null,
      context: 'KingdomProvider.updateResources',
    );
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
        return 1; // Town center is unique and doesn't level up
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

  // Persistence methods
  Future<void> _loadKingdomState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_storageKey);
      
      if (stateJson != null) {
        final stateMap = json.decode(stateJson) as Map<String, dynamic>;
        state = _fromJson(stateMap);
      }
    } catch (e) {
      // If loading fails, continue with default state
      // In production, consider using a proper logging framework
    }
  }

  Future<void> _saveKingdomState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = json.encode(_toJson(state));
      await prefs.setString(_storageKey, stateJson);
    } catch (e) {
      // Silently ignore save errors
      // In production, consider using a proper logging framework
    }
  }

  Map<String, dynamic> _toJson(KingdomState state) {
    return {
      'tier': state.tier.index,
      'experience': state.experience,
      'unlockedBuildings': state.unlockedBuildings.map(
        (building, isUnlocked) => MapEntry(building.index, isUnlocked),
      ),
      'buildingLevels': state.buildingLevels.map(
        (building, level) => MapEntry(building.index, level),
      ),
      'resources': state.resources,
    };
  }

  KingdomState _fromJson(Map<String, dynamic> json) {
    final unlockedBuildings = <KingdomBuilding, bool>{};
    final buildingLevels = <KingdomBuilding, int>{};
    
    // Convert building indexes back to enums
    (json['unlockedBuildings'] as Map<String, dynamic>).forEach((key, value) {
      final buildingIndex = int.parse(key);
      if (buildingIndex < KingdomBuilding.values.length) {
        unlockedBuildings[KingdomBuilding.values[buildingIndex]] = value as bool;
      }
    });
    
    (json['buildingLevels'] as Map<String, dynamic>).forEach((key, value) {
      final buildingIndex = int.parse(key);
      if (buildingIndex < KingdomBuilding.values.length) {
        buildingLevels[KingdomBuilding.values[buildingIndex]] = value as int;
      }
    });

    return KingdomState(
      tier: KingdomTier.values[json['tier'] as int],
      experience: json['experience'] as int,
      unlockedBuildings: unlockedBuildings,
      buildingLevels: buildingLevels,
      resources: Map<String, int>.from(json['resources'] as Map),
    );
  }
}