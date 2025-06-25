enum KingdomTier {
  village,
  town,
  city,
  kingdom,
}

enum KingdomBuilding {
  townCenter,
  library,
  tradingPost,
  treasury,
  marketplace,
  observatory,
  academy,
}

class KingdomState {
  final KingdomTier tier;
  final int experience;
  final Map<KingdomBuilding, bool> unlockedBuildings;
  final Map<KingdomBuilding, int> buildingLevels;
  final Map<String, int> resources; // Gold, Gems, Wood

  const KingdomState({
    this.tier = KingdomTier.village,
    this.experience = 0,
    this.unlockedBuildings = const {
      KingdomBuilding.townCenter: true,
      KingdomBuilding.library: true,
      KingdomBuilding.tradingPost: false,
      KingdomBuilding.treasury: false,
      KingdomBuilding.marketplace: false,
      KingdomBuilding.observatory: false,
      KingdomBuilding.academy: false,
    },
    this.buildingLevels = const {
      KingdomBuilding.townCenter: 1,
      KingdomBuilding.library: 1,
      KingdomBuilding.tradingPost: 0,
      KingdomBuilding.treasury: 0,
      KingdomBuilding.marketplace: 0,
      KingdomBuilding.observatory: 0,
      KingdomBuilding.academy: 0,
    },
    this.resources = const {
      'gold': 100,
      'gems': 0,
      'wood': 50,
    },
  });

  KingdomState copyWith({
    KingdomTier? tier,
    int? experience,
    Map<KingdomBuilding, bool>? unlockedBuildings,
    Map<KingdomBuilding, int>? buildingLevels,
    Map<String, int>? resources,
  }) {
    return KingdomState(
      tier: tier ?? this.tier,
      experience: experience ?? this.experience,
      unlockedBuildings: unlockedBuildings ?? this.unlockedBuildings,
      buildingLevels: buildingLevels ?? this.buildingLevels,
      resources: resources ?? this.resources,
    );
  }

  // Helper methods
  bool isBuildingUnlocked(KingdomBuilding building) {
    return unlockedBuildings[building] ?? false;
  }

  int getBuildingLevel(KingdomBuilding building) {
    return buildingLevels[building] ?? 0;
  }

  int getResource(String resourceType) {
    return resources[resourceType] ?? 0;
  }

  String get tierDisplayName {
    switch (tier) {
      case KingdomTier.village:
        return 'Village';
      case KingdomTier.town:
        return 'Town';
      case KingdomTier.city:
        return 'City';
      case KingdomTier.kingdom:
        return 'Kingdom';
    }
  }

  int get nextTierExperience {
    switch (tier) {
      case KingdomTier.village:
        return 1000;
      case KingdomTier.town:
        return 2500;
      case KingdomTier.city:
        return 5000;
      case KingdomTier.kingdom:
        return 10000;
    }
  }

  double get progressToNextTier {
    final currentTierBase = _getTierBaseExperience(tier);
    final nextTierExperience = this.nextTierExperience;
    return (experience - currentTierBase) / (nextTierExperience - currentTierBase);
  }

  int _getTierBaseExperience(KingdomTier tier) {
    switch (tier) {
      case KingdomTier.village:
        return 0;
      case KingdomTier.town:
        return 1000;
      case KingdomTier.city:
        return 2500;
      case KingdomTier.kingdom:
        return 5000;
    }
  }
}