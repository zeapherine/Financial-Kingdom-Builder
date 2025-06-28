enum ResourceType {
  gold,
  gems,
  wood,
}

extension ResourceTypeExtension on ResourceType {
  String get displayName {
    switch (this) {
      case ResourceType.gold:
        return 'Gold';
      case ResourceType.gems:
        return 'Gems';
      case ResourceType.wood:
        return 'Wood';
    }
  }

  String get description {
    switch (this) {
      case ResourceType.gold:
        return 'Capital - Your primary trading funds and liquid assets';
      case ResourceType.gems:
        return 'High Risk - Volatile investments and leveraged positions';
      case ResourceType.wood:
        return 'Stable Assets - Conservative investments and savings';
    }
  }

  String get riskLevel {
    switch (this) {
      case ResourceType.gold:
        return 'Medium';
      case ResourceType.gems:
        return 'High';
      case ResourceType.wood:
        return 'Low';
    }
  }

  double get riskMultiplier {
    switch (this) {
      case ResourceType.gold:
        return 1.0; // Baseline risk
      case ResourceType.gems:
        return 2.5; // Higher risk, higher reward potential
      case ResourceType.wood:
        return 0.5; // Lower risk, lower reward potential
    }
  }

  double get baseReturnRate {
    switch (this) {
      case ResourceType.gold:
        return 0.05; // 5% annual return
      case ResourceType.gems:
        return 0.15; // 15% annual return (with higher volatility)
      case ResourceType.wood:
        return 0.02; // 2% annual return (stable)
    }
  }

  String get iconName {
    switch (this) {
      case ResourceType.gold:
        return 'coins';
      case ResourceType.gems:
        return 'diamond';
      case ResourceType.wood:
        return 'tree';
    }
  }

  String get colorHex {
    switch (this) {
      case ResourceType.gold:
        return '#FFD700'; // Gold color
      case ResourceType.gems:
        return '#1CB0F6'; // Duolingo blue for gems
      case ResourceType.wood:
        return '#8B4513'; // Brown for wood
    }
  }
}

class ResourceAllocation {
  final ResourceType type;
  final int amount;
  final double percentage;
  final DateTime lastUpdated;

  const ResourceAllocation({
    required this.type,
    required this.amount,
    required this.percentage,
    required this.lastUpdated,
  });

  ResourceAllocation copyWith({
    ResourceType? type,
    int? amount,
    double? percentage,
    DateTime? lastUpdated,
  }) {
    return ResourceAllocation(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'amount': amount,
      'percentage': percentage,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static ResourceAllocation fromJson(Map<String, dynamic> json) {
    return ResourceAllocation(
      type: ResourceType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ResourceType.gold,
      ),
      amount: json['amount'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ResourceMetrics {
  final double totalValue;
  final double dailyGrowth;
  final double weeklyGrowth;
  final double monthlyGrowth;
  final double riskScore;
  final double diversificationScore;

  const ResourceMetrics({
    required this.totalValue,
    required this.dailyGrowth,
    required this.weeklyGrowth,
    required this.monthlyGrowth,
    required this.riskScore,
    required this.diversificationScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalValue': totalValue,
      'dailyGrowth': dailyGrowth,
      'weeklyGrowth': weeklyGrowth,
      'monthlyGrowth': monthlyGrowth,
      'riskScore': riskScore,
      'diversificationScore': diversificationScore,
    };
  }

  static ResourceMetrics fromJson(Map<String, dynamic> json) {
    return ResourceMetrics(
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      dailyGrowth: (json['dailyGrowth'] as num?)?.toDouble() ?? 0.0,
      weeklyGrowth: (json['weeklyGrowth'] as num?)?.toDouble() ?? 0.0,
      monthlyGrowth: (json['monthlyGrowth'] as num?)?.toDouble() ?? 0.0,
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0.0,
      diversificationScore: (json['diversificationScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ResourceCapacity {
  final ResourceType type;
  final int currentAmount;
  final int maxCapacity;
  final double regenerationRate;
  final Duration regenerationInterval;

  const ResourceCapacity({
    required this.type,
    required this.currentAmount,
    required this.maxCapacity,
    required this.regenerationRate,
    required this.regenerationInterval,
  });

  double get capacityUsed => currentAmount / maxCapacity;
  
  bool get isAtCapacity => currentAmount >= maxCapacity;
  
  bool get isScarcityLevel => capacityUsed > 0.8;

  ResourceCapacity copyWith({
    ResourceType? type,
    int? currentAmount,
    int? maxCapacity,
    double? regenerationRate,
    Duration? regenerationInterval,
  }) {
    return ResourceCapacity(
      type: type ?? this.type,
      currentAmount: currentAmount ?? this.currentAmount,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      regenerationRate: regenerationRate ?? this.regenerationRate,
      regenerationInterval: regenerationInterval ?? this.regenerationInterval,
    );
  }
}