import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/kingdom_state.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/error_handler_service.dart';

class KingdomNotifier extends StateNotifier<KingdomState> {
  static const String _storageKey = 'kingdom_state';

  KingdomNotifier() : super(const KingdomState()) {
    _loadKingdomState();
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
    _saveKingdomState();
  }

  void upgradeBuilding(KingdomBuilding building) {
    final currentLevel = state.buildingLevels[building] ?? 0;
    final maxLevel = building.maxLevel;
    
    if (currentLevel >= maxLevel) return;
    
    final upgradeCost = building.getUpgradeCost(currentLevel + 1);
    if (state.currency < upgradeCost) return;
    
    final updatedLevels = Map<KingdomBuilding, int>.from(state.buildingLevels);
    final updatedCurrency = state.currency - upgradeCost;
    
    updatedLevels[building] = currentLevel + 1;
    
    state = state.copyWith(
      buildingLevels: updatedLevels,
      currency: updatedCurrency,
    );
    
    _saveKingdomState();
  }

  void addCurrency(int amount) {
    state = state.copyWith(currency: state.currency + amount);
    _saveKingdomState();
  }

  KingdomTier _calculateTier(int experience) {
    if (experience >= 2000) return KingdomTier.kingdom;
    if (experience >= 1000) return KingdomTier.city;
    if (experience >= 500) return KingdomTier.town;
    return KingdomTier.village;
  }

  void _unlockBuildingsForTier(KingdomTier tier) {
    final buildingsToUnlock = KingdomBuilding.values
        .where((building) => building.requiredTier.index <= tier.index)
        .toList();
    
    final updatedBuildings = Map<KingdomBuilding, bool>.from(state.unlockedBuildings);
    
    for (final building in buildingsToUnlock) {
      updatedBuildings[building] = true;
    }
    
    state = state.copyWith(unlockedBuildings: updatedBuildings);
  }

  Future<void> _loadKingdomState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_storageKey);
      
      if (stateJson != null) {
        final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
        final loadedState = KingdomState.fromJson(stateMap);
        state = loadedState;
      }
    } catch (e) {
      // If loading fails, start with default state
      state = const KingdomState();
    }
  }

  Future<void> _saveKingdomState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, stateJson);
    } catch (e) {
      // Handle save error silently for now
    }
  }

  void resetKingdom() {
    state = const KingdomState();
    _saveKingdomState();
  }
}

// Provider definition
final kingdomProvider = StateNotifierProvider<KingdomNotifier, KingdomState>((ref) {
  return KingdomNotifier();
});

// Computed providers
final currentTierProvider = Provider<KingdomTier>((ref) {
  return ref.watch(kingdomProvider).tier;
});

final availableBuildingsProvider = Provider<List<KingdomBuilding>>((ref) {
  final kingdomState = ref.watch(kingdomProvider);
  return KingdomBuilding.values
      .where((building) => kingdomState.unlockedBuildings[building] == true)
      .toList();
});

final totalKingdomValueProvider = Provider<double>((ref) {
  final kingdomState = ref.watch(kingdomProvider);
  double totalValue = 0;
  
  for (final building in KingdomBuilding.values) {
    final level = kingdomState.buildingLevels[building] ?? 0;
    totalValue += building.baseValue * level;
  }
  
  return totalValue;
});