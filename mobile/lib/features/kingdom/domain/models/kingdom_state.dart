import 'resource_management_state.dart';

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

extension KingdomBuildingExtension on KingdomBuilding {
  int get maxLevel {
    switch (this) {
      case KingdomBuilding.townCenter:
        return 10;
      case KingdomBuilding.library:
        return 5;
      case KingdomBuilding.tradingPost:
        return 8;
      case KingdomBuilding.treasury:
        return 6;
      case KingdomBuilding.marketplace:
        return 7;
      case KingdomBuilding.observatory:
        return 4;
      case KingdomBuilding.academy:
        return 5;
    }
  }

  KingdomTier get requiredTier {
    switch (this) {
      case KingdomBuilding.townCenter:
      case KingdomBuilding.library:
        return KingdomTier.village;
      case KingdomBuilding.tradingPost:
      case KingdomBuilding.treasury:
        return KingdomTier.town;
      case KingdomBuilding.marketplace:
      case KingdomBuilding.observatory:
        return KingdomTier.city;
      case KingdomBuilding.academy:
        return KingdomTier.kingdom;
    }
  }

  double get baseValue {
    switch (this) {
      case KingdomBuilding.townCenter:
        return 1000.0;
      case KingdomBuilding.library:
        return 500.0;
      case KingdomBuilding.tradingPost:
        return 750.0;
      case KingdomBuilding.treasury:
        return 800.0;
      case KingdomBuilding.marketplace:
        return 1200.0;
      case KingdomBuilding.observatory:
        return 600.0;
      case KingdomBuilding.academy:
        return 1500.0;
    }
  }

  int getUpgradeCost(int level) {
    final baseCost = {
      KingdomBuilding.townCenter: 100,
      KingdomBuilding.library: 75,
      KingdomBuilding.tradingPost: 150,
      KingdomBuilding.treasury: 200,
      KingdomBuilding.marketplace: 300,
      KingdomBuilding.observatory: 400,
      KingdomBuilding.academy: 500,
    };
    
    return (baseCost[this] ?? 100) * level;
  }
}

class KingdomState {
  final KingdomTier tier;
  final int experience;
  final Map<KingdomBuilding, bool> unlockedBuildings;
  final Map<KingdomBuilding, int> buildingLevels;
  final Map<String, int> resources; // Legacy resources for compatibility
  final int currency; // Primary currency for upgrades
  final ResourceManagementState resourceManagement;

  KingdomState({
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
    this.currency = 100,
    ResourceManagementState? resourceManagement,
  }) : resourceManagement = resourceManagement ?? ResourceManagementState.initial;

  KingdomState copyWith({
    KingdomTier? tier,
    int? experience,
    Map<KingdomBuilding, bool>? unlockedBuildings,
    Map<KingdomBuilding, int>? buildingLevels,
    Map<String, int>? resources,
    int? currency,
    ResourceManagementState? resourceManagement,
  }) {
    return KingdomState(
      tier: tier ?? this.tier,
      experience: experience ?? this.experience,
      unlockedBuildings: unlockedBuildings ?? this.unlockedBuildings,
      buildingLevels: buildingLevels ?? this.buildingLevels,
      resources: resources ?? this.resources,
      currency: currency ?? this.currency,
      resourceManagement: resourceManagement ?? this.resourceManagement,
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

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'tier': tier.name,
      'experience': experience,
      'currency': currency,
      'unlockedBuildings': unlockedBuildings.map(
        (building, unlocked) => MapEntry(building.name, unlocked),
      ),
      'buildingLevels': buildingLevels.map(
        (building, level) => MapEntry(building.name, level),
      ),
      'resources': resources,
      'resourceManagement': resourceManagement.toJson(),
    };
  }

  static KingdomState fromJson(Map<String, dynamic> json) {
    final tierName = json['tier'] as String? ?? 'village';
    final tier = KingdomTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => KingdomTier.village,
    );

    final unlockedBuildingsMap = (json['unlockedBuildings'] as Map<String, dynamic>? ?? {})
        .map<KingdomBuilding, bool>((key, value) {
      final building = KingdomBuilding.values.firstWhere(
        (b) => b.name == key,
        orElse: () => KingdomBuilding.townCenter,
      );
      return MapEntry(building, value as bool? ?? false);
    });

    final buildingLevelsMap = (json['buildingLevels'] as Map<String, dynamic>? ?? {})
        .map<KingdomBuilding, int>((key, value) {
      final building = KingdomBuilding.values.firstWhere(
        (b) => b.name == key,
        orElse: () => KingdomBuilding.townCenter,
      );
      return MapEntry(building, value as int? ?? 0);
    });

    final resourceManagement = json['resourceManagement'] != null
        ? ResourceManagementState.fromJson(json['resourceManagement'])
        : ResourceManagementState.initial;

    return KingdomState(
      tier: tier,
      experience: json['experience'] as int? ?? 0,
      currency: json['currency'] as int? ?? 100,
      unlockedBuildings: unlockedBuildingsMap.isNotEmpty 
          ? unlockedBuildingsMap 
          : const {
              KingdomBuilding.townCenter: true,
              KingdomBuilding.library: true,
              KingdomBuilding.tradingPost: false,
              KingdomBuilding.treasury: false,
              KingdomBuilding.marketplace: false,
              KingdomBuilding.observatory: false,
              KingdomBuilding.academy: false,
            },
      buildingLevels: buildingLevelsMap.isNotEmpty 
          ? buildingLevelsMap 
          : const {
              KingdomBuilding.townCenter: 1,
              KingdomBuilding.library: 1,
              KingdomBuilding.tradingPost: 0,
              KingdomBuilding.treasury: 0,
              KingdomBuilding.marketplace: 0,
              KingdomBuilding.observatory: 0,
              KingdomBuilding.academy: 0,
            },
      resources: Map<String, int>.from(json['resources'] as Map<String, dynamic>? ?? {
        'gold': 100,
        'gems': 0,
        'wood': 50,
      }),
      resourceManagement: resourceManagement,
    );
  }
}