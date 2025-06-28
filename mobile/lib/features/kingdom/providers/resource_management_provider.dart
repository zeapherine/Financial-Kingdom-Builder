import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/resource_types.dart';
import '../domain/models/resource_management_state.dart';

class ResourceManagementNotifier extends StateNotifier<ResourceManagementState> {
  ResourceManagementNotifier() : super(ResourceManagementState.initial);

  void updateAllocation(Map<ResourceType, double> newAllocations) {
    final totalValue = state.totalAllocatedResources.toDouble();
    final updatedAllocations = <ResourceType, ResourceAllocation>{};
    
    for (final entry in newAllocations.entries) {
      final type = entry.key;
      final percentage = entry.value;
      final amount = (totalValue * percentage / 100.0).round();
      
      updatedAllocations[type] = ResourceAllocation(
        type: type,
        amount: amount,
        percentage: percentage,
        lastUpdated: DateTime.now(),
      );
    }
    
    // Recalculate metrics based on new allocations
    final newMetrics = _calculateMetrics(updatedAllocations);
    
    state = state.copyWith(
      allocations: updatedAllocations,
      metrics: newMetrics,
    );
  }

  void convertResource(ResourceType from, ResourceType to, int amount) {
    final fromAllocation = state.allocations[from];
    final toAllocation = state.allocations[to];
    
    if (fromAllocation == null || toAllocation == null) return;
    if (fromAllocation.amount < amount) return;
    
    // Calculate conversion rate based on risk levels
    final conversionRate = _getConversionRate(from, to);
    final convertedAmount = (amount * conversionRate).round();
    
    // Create transaction record
    final transaction = ResourceTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromResource: from,
      toResource: to,
      amount: amount,
      conversionRate: conversionRate,
      timestamp: DateTime.now(),
      reason: 'User rebalancing',
    );
    
    // Update allocations
    final updatedFromAllocation = fromAllocation.copyWith(
      amount: fromAllocation.amount - amount,
      lastUpdated: DateTime.now(),
    );
    
    final updatedToAllocation = toAllocation.copyWith(
      amount: toAllocation.amount + convertedAmount,
      lastUpdated: DateTime.now(),
    );
    
    final updatedAllocations = Map<ResourceType, ResourceAllocation>.from(state.allocations);
    updatedAllocations[from] = updatedFromAllocation;
    updatedAllocations[to] = updatedToAllocation;
    
    // Recalculate percentages
    final totalValue = updatedAllocations.values.fold<int>(0, (sum, alloc) => sum + alloc.amount).toDouble();
    for (final type in ResourceType.values) {
      final allocation = updatedAllocations[type]!;
      updatedAllocations[type] = allocation.copyWith(
        percentage: totalValue > 0 ? (allocation.amount / totalValue) * 100 : 0.0,
      );
    }
    
    final newMetrics = _calculateMetrics(updatedAllocations);
    
    state = state.copyWith(
      allocations: updatedAllocations,
      metrics: newMetrics,
      transactionHistory: [...state.transactionHistory, transaction],
    );
  }

  void regenerateResources() {
    final now = DateTime.now();
    final timeSinceLastRegen = now.difference(state.lastRegeneration);
    
    final updatedCapacities = <ResourceType, ResourceCapacity>{};
    bool hasChanges = false;
    
    for (final entry in state.capacities.entries) {
      final type = entry.key;
      final capacity = entry.value;
      
      // Calculate regeneration based on time elapsed
      final intervals = timeSinceLastRegen.inMilliseconds / capacity.regenerationInterval.inMilliseconds;
      final regenAmount = (intervals * capacity.regenerationRate).floor();
      
      if (regenAmount > 0 && !capacity.isAtCapacity) {
        final newAmount = (capacity.currentAmount + regenAmount).clamp(0, capacity.maxCapacity);
        updatedCapacities[type] = capacity.copyWith(currentAmount: newAmount);
        hasChanges = true;
      } else {
        updatedCapacities[type] = capacity;
      }
    }
    
    if (hasChanges) {
      state = state.copyWith(
        capacities: updatedCapacities,
        lastRegeneration: now,
      );
    }
  }

  void setRiskTolerance(double riskTolerance) {
    state = state.copyWith(riskTolerance: riskTolerance.clamp(0.0, 1.0));
    
    // If auto-rebalance is enabled, trigger rebalancing
    if (state.autoRebalanceEnabled) {
      _autoRebalance();
    }
  }

  void toggleAutoRebalance() {
    final newValue = !state.autoRebalanceEnabled;
    state = state.copyWith(autoRebalanceEnabled: newValue);
    
    if (newValue) {
      _autoRebalance();
    }
  }

  void addResources(ResourceType type, int amount) {
    final allocation = state.allocations[type];
    if (allocation == null) return;
    
    final updatedAllocation = allocation.copyWith(
      amount: allocation.amount + amount,
      lastUpdated: DateTime.now(),
    );
    
    final updatedAllocations = Map<ResourceType, ResourceAllocation>.from(state.allocations);
    updatedAllocations[type] = updatedAllocation;
    
    // Recalculate percentages
    final totalValue = updatedAllocations.values.fold<int>(0, (sum, alloc) => sum + alloc.amount).toDouble();
    for (final resourceType in ResourceType.values) {
      final alloc = updatedAllocations[resourceType]!;
      updatedAllocations[resourceType] = alloc.copyWith(
        percentage: totalValue > 0 ? (alloc.amount / totalValue) * 100 : 0.0,
      );
    }
    
    final newMetrics = _calculateMetrics(updatedAllocations);
    
    state = state.copyWith(
      allocations: updatedAllocations,
      metrics: newMetrics,
    );
  }

  void spendResources(ResourceType type, int amount) {
    final allocation = state.allocations[type];
    if (allocation == null || allocation.amount < amount) return;
    
    final updatedAllocation = allocation.copyWith(
      amount: allocation.amount - amount,
      lastUpdated: DateTime.now(),
    );
    
    final updatedAllocations = Map<ResourceType, ResourceAllocation>.from(state.allocations);
    updatedAllocations[type] = updatedAllocation;
    
    // Recalculate percentages
    final totalValue = updatedAllocations.values.fold<int>(0, (sum, alloc) => sum + alloc.amount).toDouble();
    for (final resourceType in ResourceType.values) {
      final alloc = updatedAllocations[resourceType]!;
      updatedAllocations[resourceType] = alloc.copyWith(
        percentage: totalValue > 0 ? (alloc.amount / totalValue) * 100 : 0.0,
      );
    }
    
    final newMetrics = _calculateMetrics(updatedAllocations);
    
    state = state.copyWith(
      allocations: updatedAllocations,
      metrics: newMetrics,
    );
  }

  ResourceMetrics _calculateMetrics(Map<ResourceType, ResourceAllocation> allocations) {
    final totalValue = allocations.values.fold<double>(0, (sum, alloc) => sum + alloc.amount);
    
    // Calculate risk score
    double weightedRisk = 0.0;
    for (final allocation in allocations.values) {
      final riskMultiplier = allocation.type.riskMultiplier;
      final weight = totalValue > 0 ? allocation.amount / totalValue : 0.0;
      weightedRisk += weight * riskMultiplier;
    }
    
    // Calculate diversification score (Herfindahl-Hirschman Index)
    double sumOfSquares = 0.0;
    for (final allocation in allocations.values) {
      final weight = totalValue > 0 ? allocation.amount / totalValue : 0.0;
      sumOfSquares += weight * weight;
    }
    final diversificationScore = allocations.isEmpty ? 0.0 : 1.0 - sumOfSquares;
    
    // Calculate returns (simplified)
    final dailyGrowth = _calculateReturn(allocations, const Duration(days: 1));
    final weeklyGrowth = _calculateReturn(allocations, const Duration(days: 7));
    final monthlyGrowth = _calculateReturn(allocations, const Duration(days: 30));
    
    return ResourceMetrics(
      totalValue: totalValue,
      dailyGrowth: dailyGrowth,
      weeklyGrowth: weeklyGrowth,
      monthlyGrowth: monthlyGrowth,
      riskScore: weightedRisk,
      diversificationScore: diversificationScore,
    );
  }

  double _calculateReturn(Map<ResourceType, ResourceAllocation> allocations, Duration period) {
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

  double _getConversionRate(ResourceType from, ResourceType to) {
    // Conversion rates based on risk levels
    final fromRisk = from.riskMultiplier;
    final toRisk = to.riskMultiplier;
    
    // Higher risk to lower risk: favorable rate
    // Lower risk to higher risk: less favorable rate
    if (fromRisk > toRisk) {
      return 0.95; // Small conversion fee
    } else if (fromRisk < toRisk) {
      return 1.1; // Bonus for taking on more risk
    } else {
      return 1.0; // Same risk level
    }
  }

  void _autoRebalance() {
    if (!state.autoRebalanceEnabled) return;
    
    // Simple auto-rebalancing based on risk tolerance
    final targetPercentages = _calculateTargetPercentages(state.riskTolerance);
    updateAllocation(targetPercentages);
  }

  Map<ResourceType, double> _calculateTargetPercentages(double riskTolerance) {
    // Conservative allocation (low risk tolerance)
    if (riskTolerance < 0.3) {
      return {
        ResourceType.gold: 40.0,
        ResourceType.gems: 10.0,
        ResourceType.wood: 50.0,
      };
    }
    // Moderate allocation
    else if (riskTolerance < 0.7) {
      return {
        ResourceType.gold: 50.0,
        ResourceType.gems: 25.0,
        ResourceType.wood: 25.0,
      };
    }
    // Aggressive allocation (high risk tolerance)
    else {
      return {
        ResourceType.gold: 40.0,
        ResourceType.gems: 45.0,
        ResourceType.wood: 15.0,
      };
    }
  }
}

final resourceManagementProvider = StateNotifierProvider<ResourceManagementNotifier, ResourceManagementState>((ref) {
  return ResourceManagementNotifier();
});