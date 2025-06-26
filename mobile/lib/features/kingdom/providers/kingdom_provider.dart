import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/kingdom_state.dart';

part 'kingdom_provider.g.dart';

@Riverpod(keepAlive: true)
class KingdomNotifier extends _$KingdomNotifier {
  @override
  KingdomState build() {
    return const KingdomState();
  }

  void addExperience(int xp) {
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

  void unlockBuilding(KingdomBuilding building) {
    final updatedBuildings = Map<KingdomBuilding, bool>.from(state.unlockedBuildings);
    updatedBuildings[building] = true;
    
    state = state.copyWith(unlockedBuildings: updatedBuildings);
  }

  void upgradeBuilding(KingdomBuilding building) {
    if (!state.isBuildingUnlocked(building)) return;
    
    final updatedLevels = Map<KingdomBuilding, int>.from(state.buildingLevels);
    updatedLevels[building] = (updatedLevels[building] ?? 0) + 1;
    
    state = state.copyWith(buildingLevels: updatedLevels);
  }

  void updateResources(Map<String, int> resourceChanges) {
    final updatedResources = Map<String, int>.from(state.resources);
    
    resourceChanges.forEach((resource, change) {
      updatedResources[resource] = (updatedResources[resource] ?? 0) + change;
      // Ensure resources don't go negative
      if (updatedResources[resource]! < 0) {
        updatedResources[resource] = 0;
      }
    });
    
    state = state.copyWith(resources: updatedResources);
  }

  KingdomTier _calculateTier(int experience) {
    if (experience >= 5000) return KingdomTier.kingdom;
    if (experience >= 2500) return KingdomTier.city;
    if (experience >= 1000) return KingdomTier.town;
    return KingdomTier.village;
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