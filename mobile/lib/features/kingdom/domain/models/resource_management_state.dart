import 'resource_types.dart';

class ResourceManagementState {
  final Map<ResourceType, ResourceAllocation> allocations;
  final Map<ResourceType, ResourceCapacity> capacities;
  final ResourceMetrics metrics;
  final List<ResourceTransaction> transactionHistory;
  final DateTime lastRegeneration;
  final bool autoRebalanceEnabled;
  final double riskTolerance; // 0.0 to 1.0

  const ResourceManagementState({
    required this.allocations,
    required this.capacities,
    required this.metrics,
    this.transactionHistory = const [],
    required this.lastRegeneration,
    this.autoRebalanceEnabled = false,
    this.riskTolerance = 0.5,
  });

  static ResourceManagementState get initial {
    final now = DateTime.now();
    return ResourceManagementState(
      allocations: {
        ResourceType.gold: ResourceAllocation(
          type: ResourceType.gold,
          amount: 100,
          percentage: 50.0,
          lastUpdated: now,
        ),
        ResourceType.gems: ResourceAllocation(
          type: ResourceType.gems,
          amount: 20,
          percentage: 10.0,
          lastUpdated: now,
        ),
        ResourceType.wood: ResourceAllocation(
          type: ResourceType.wood,
          amount: 80,
          percentage: 40.0,
          lastUpdated: now,
        ),
      },
      capacities: {
        ResourceType.gold: ResourceCapacity(
          type: ResourceType.gold,
          currentAmount: 100,
          maxCapacity: 1000,
          regenerationRate: 5.0,
          regenerationInterval: const Duration(hours: 1),
        ),
        ResourceType.gems: ResourceCapacity(
          type: ResourceType.gems,
          currentAmount: 20,
          maxCapacity: 200,
          regenerationRate: 2.0,
          regenerationInterval: const Duration(hours: 2),
        ),
        ResourceType.wood: ResourceCapacity(
          type: ResourceType.wood,
          currentAmount: 80,
          maxCapacity: 500,
          regenerationRate: 10.0,
          regenerationInterval: const Duration(minutes: 30),
        ),
      },
      metrics: const ResourceMetrics(
        totalValue: 200.0,
        dailyGrowth: 0.02,
        weeklyGrowth: 0.15,
        monthlyGrowth: 0.65,
        riskScore: 0.3,
        diversificationScore: 0.7,
      ),
      lastRegeneration: now,
    );
  }

  ResourceManagementState copyWith({
    Map<ResourceType, ResourceAllocation>? allocations,
    Map<ResourceType, ResourceCapacity>? capacities,
    ResourceMetrics? metrics,
    List<ResourceTransaction>? transactionHistory,
    DateTime? lastRegeneration,
    bool? autoRebalanceEnabled,
    double? riskTolerance,
  }) {
    return ResourceManagementState(
      allocations: allocations ?? this.allocations,
      capacities: capacities ?? this.capacities,
      metrics: metrics ?? this.metrics,
      transactionHistory: transactionHistory ?? this.transactionHistory,
      lastRegeneration: lastRegeneration ?? this.lastRegeneration,
      autoRebalanceEnabled: autoRebalanceEnabled ?? this.autoRebalanceEnabled,
      riskTolerance: riskTolerance ?? this.riskTolerance,
    );
  }

  // Allocation methods
  int getAllocation(ResourceType type) {
    return allocations[type]?.amount ?? 0;
  }

  double getAllocationPercentage(ResourceType type) {
    return allocations[type]?.percentage ?? 0.0;
  }

  int get totalAllocatedResources {
    return allocations.values.fold(0, (sum, allocation) => sum + allocation.amount);
  }

  // Capacity methods
  ResourceCapacity? getCapacity(ResourceType type) {
    return capacities[type];
  }

  bool isResourceAtCapacity(ResourceType type) {
    return getCapacity(type)?.isAtCapacity ?? false;
  }

  bool isResourceScarcity(ResourceType type) {
    return getCapacity(type)?.isScarcityLevel ?? false;
  }

  // Risk calculation
  double get currentRiskScore {
    double weightedRisk = 0.0;
    double totalValue = 0.0;

    for (final allocation in allocations.values) {
      final riskMultiplier = allocation.type.riskMultiplier;
      final value = allocation.amount.toDouble();
      weightedRisk += value * riskMultiplier;
      totalValue += value;
    }

    return totalValue > 0 ? weightedRisk / totalValue : 0.0;
  }

  // Diversification score (closer to 1.0 is better diversified)
  double get diversificationScore {
    if (allocations.isEmpty) return 0.0;

    final totalValue = totalAllocatedResources.toDouble();
    if (totalValue == 0) return 0.0;

    double sumOfSquares = 0.0;
    for (final allocation in allocations.values) {
      final percentage = allocation.amount / totalValue;
      sumOfSquares += percentage * percentage;
    }

    // Herfindahl-Hirschman Index (lower is more diversified)
    // Convert to score where 1.0 is perfectly diversified
    return 1.0 - sumOfSquares;
  }

  // Check if rebalancing is needed
  bool get needsRebalancing {
    const threshold = 0.15; // 15% deviation threshold
    final idealPercentage = 100.0 / allocations.length;

    return allocations.values.any((allocation) =>
        (allocation.percentage - idealPercentage).abs() > threshold * 100);
  }

  // Performance tracking
  double calculateReturn(Duration period) {
    double totalReturn = 0.0;
    double totalValue = 0.0;

    for (final allocation in allocations.values) {
      final baseReturn = allocation.type.baseReturnRate;
      final periodMultiplier = period.inDays / 365.0;
      final expectedReturn = baseReturn * periodMultiplier;
      
      final value = allocation.amount.toDouble();
      totalReturn += value * expectedReturn;
      totalValue += value;
    }

    return totalValue > 0 ? totalReturn / totalValue : 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'allocations': allocations.map(
        (type, allocation) => MapEntry(type.name, allocation.toJson()),
      ),
      'capacities': capacities.map(
        (type, capacity) => MapEntry(type.name, {
          'type': capacity.type.name,
          'currentAmount': capacity.currentAmount,
          'maxCapacity': capacity.maxCapacity,
          'regenerationRate': capacity.regenerationRate,
          'regenerationInterval': capacity.regenerationInterval.inMilliseconds,
        }),
      ),
      'metrics': metrics.toJson(),
      'transactionHistory': transactionHistory.map((t) => t.toJson()).toList(),
      'lastRegeneration': lastRegeneration.toIso8601String(),
      'autoRebalanceEnabled': autoRebalanceEnabled,
      'riskTolerance': riskTolerance,
    };
  }

  static ResourceManagementState fromJson(Map<String, dynamic> json) {
    final allocationsMap = (json['allocations'] as Map<String, dynamic>? ?? {})
        .map<ResourceType, ResourceAllocation>((key, value) {
      final type = ResourceType.values.firstWhere(
        (t) => t.name == key,
        orElse: () => ResourceType.gold,
      );
      return MapEntry(type, ResourceAllocation.fromJson(value));
    });

    final capacitiesMap = (json['capacities'] as Map<String, dynamic>? ?? {})
        .map<ResourceType, ResourceCapacity>((key, value) {
      final type = ResourceType.values.firstWhere(
        (t) => t.name == key,
        orElse: () => ResourceType.gold,
      );
      return MapEntry(
        type,
        ResourceCapacity(
          type: type,
          currentAmount: value['currentAmount'] as int? ?? 0,
          maxCapacity: value['maxCapacity'] as int? ?? 100,
          regenerationRate: (value['regenerationRate'] as num?)?.toDouble() ?? 1.0,
          regenerationInterval: Duration(
            milliseconds: value['regenerationInterval'] as int? ?? 3600000,
          ),
        ),
      );
    });

    final transactionsList = (json['transactionHistory'] as List? ?? [])
        .map<ResourceTransaction>((t) => ResourceTransaction.fromJson(t))
        .toList();

    return ResourceManagementState(
      allocations: allocationsMap.isNotEmpty ? allocationsMap : initial.allocations,
      capacities: capacitiesMap.isNotEmpty ? capacitiesMap : initial.capacities,
      metrics: json['metrics'] != null 
          ? ResourceMetrics.fromJson(json['metrics']) 
          : initial.metrics,
      transactionHistory: transactionsList,
      lastRegeneration: DateTime.tryParse(json['lastRegeneration'] as String? ?? '') 
          ?? DateTime.now(),
      autoRebalanceEnabled: json['autoRebalanceEnabled'] as bool? ?? false,
      riskTolerance: (json['riskTolerance'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

class ResourceTransaction {
  final String id;
  final ResourceType fromResource;
  final ResourceType toResource;
  final int amount;
  final double conversionRate;
  final DateTime timestamp;
  final String reason;

  const ResourceTransaction({
    required this.id,
    required this.fromResource,
    required this.toResource,
    required this.amount,
    required this.conversionRate,
    required this.timestamp,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromResource': fromResource.name,
      'toResource': toResource.name,
      'amount': amount,
      'conversionRate': conversionRate,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
    };
  }

  static ResourceTransaction fromJson(Map<String, dynamic> json) {
    return ResourceTransaction(
      id: json['id'] as String? ?? '',
      fromResource: ResourceType.values.firstWhere(
        (t) => t.name == json['fromResource'],
        orElse: () => ResourceType.gold,
      ),
      toResource: ResourceType.values.firstWhere(
        (t) => t.name == json['toResource'],
        orElse: () => ResourceType.gold,
      ),
      amount: json['amount'] as int? ?? 0,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 1.0,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      reason: json['reason'] as String? ?? '',
    );
  }
}