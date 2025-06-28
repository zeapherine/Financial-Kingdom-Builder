import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/resource_types.dart';
import '../../domain/models/resource_management_state.dart';
import '../../../../core/config/duolingo_theme.dart';

class ResourceAllocationInterface extends ConsumerStatefulWidget {
  final ResourceManagementState resourceState;
  final Function(Map<ResourceType, double>) onAllocationChanged;

  const ResourceAllocationInterface({
    super.key,
    required this.resourceState,
    required this.onAllocationChanged,
  });

  @override
  ConsumerState<ResourceAllocationInterface> createState() =>
      _ResourceAllocationInterfaceState();
}

class _ResourceAllocationInterfaceState
    extends ConsumerState<ResourceAllocationInterface>
    with TickerProviderStateMixin {
  late Map<ResourceType, double> currentAllocations;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize current allocations from resource state
    currentAllocations = {};
    for (final type in ResourceType.values) {
      currentAllocations[type] = widget.resourceState.getAllocationPercentage(type);
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAllocation(ResourceType type, double newPercentage) {
    setState(() {
      currentAllocations[type] = newPercentage;
      
      // Adjust other allocations proportionally to maintain 100% total
      final otherTypes = ResourceType.values.where((t) => t != type).toList();
      final totalOthers = otherTypes.fold<double>(
        0.0, 
        (sum, t) => sum + (currentAllocations[t] ?? 0.0),
      );
      
      if (totalOthers > 0) {
        final adjustmentFactor = (100.0 - newPercentage) / totalOthers;
        for (final otherType in otherTypes) {
          currentAllocations[otherType] = 
              (currentAllocations[otherType] ?? 0.0) * adjustmentFactor;
        }
      } else {
        // If all others are 0, distribute equally
        final remainingPercentage = 100.0 - newPercentage;
        final equalShare = remainingPercentage / otherTypes.length;
        for (final otherType in otherTypes) {
          currentAllocations[otherType] = equalShare;
        }
      }
    });
    
    widget.onAllocationChanged(currentAllocations);
    _animationController.forward().then((_) => _animationController.reverse());
  }

  Color _getResourceColor(ResourceType type) {
    switch (type) {
      case ResourceType.gold:
        return const Color(0xFFFFD700);
      case ResourceType.gems:
        return DuolingoTheme.duoBlue;
      case ResourceType.wood:
        return const Color(0xFF8B4513);
    }
  }

  IconData _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.gold:
        return Icons.attach_money;
      case ResourceType.gems:
        return Icons.diamond;
      case ResourceType.wood:
        return Icons.park;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DuolingoTheme.duoGreen,
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: DuolingoTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resource Allocation',
                      style: DuolingoTheme.h3.copyWith(
                        color: DuolingoTheme.charcoal,
                      ),
                    ),
                    Text(
                      'Manage your kingdom\'s resources',
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Risk tolerance indicator
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: DuolingoTheme.lightGray,
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: _getRiskColor(widget.resourceState.currentRiskScore),
                  size: 20,
                ),
                const SizedBox(width: DuolingoTheme.spacingSm),
                Text(
                  'Current Risk: ${_getRiskDescription(widget.resourceState.currentRiskScore)}',
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(widget.resourceState.currentRiskScore * 100).toStringAsFixed(1)}%',
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: _getRiskColor(widget.resourceState.currentRiskScore),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Resource allocation sliders
          ...ResourceType.values.map((type) => _buildResourceSlider(type)),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Summary card
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DuolingoTheme.duoGreen.withOpacity(0.1),
                  DuolingoTheme.duoBlue.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              border: Border.all(
                color: DuolingoTheme.duoGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Allocation',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${currentAllocations.values.fold<double>(0, (sum, value) => sum + value).toStringAsFixed(1)}%',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: DuolingoTheme.duoGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DuolingoTheme.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Diversification Score',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(widget.resourceState.diversificationScore * 100).toStringAsFixed(1)}%',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.resourceState.diversificationScore > 0.6 
                            ? DuolingoTheme.duoGreen 
                            : DuolingoTheme.duoOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceSlider(ResourceType type) {
    final currentValue = currentAllocations[type] ?? 0.0;
    final capacity = widget.resourceState.getCapacity(type);
    final isScarcity = capacity?.isScarcityLevel ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resource header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getResourceColor(type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getResourceIcon(type),
                  color: _getResourceColor(type),
                  size: 20,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          type.displayName,
                          style: DuolingoTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: DuolingoTheme.charcoal,
                          ),
                        ),
                        if (isScarcity) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.warning,
                            color: DuolingoTheme.duoOrange,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      type.description,
                      style: DuolingoTheme.caption.copyWith(
                        color: DuolingoTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${currentValue.toStringAsFixed(1)}%',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _getResourceColor(type),
                    ),
                  ),
                  Text(
                    '${widget.resourceState.getAllocation(type)} units',
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          // Slider
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _getResourceColor(type),
                    inactiveTrackColor: _getResourceColor(type).withOpacity(0.3),
                    thumbColor: _getResourceColor(type),
                    overlayColor: _getResourceColor(type).withOpacity(0.2),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: currentValue,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (value) => _updateAllocation(type, value),
                  ),
                ),
              );
            },
          ),
          
          // Risk indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getRiskColor(type.riskMultiplier).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${type.riskLevel} Risk',
                  style: DuolingoTheme.caption.copyWith(
                    color: _getRiskColor(type.riskMultiplier),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                '${(type.baseReturnRate * 100).toStringAsFixed(1)}% expected return',
                style: DuolingoTheme.caption.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(double riskLevel) {
    if (riskLevel < 0.3) return DuolingoTheme.duoGreen;
    if (riskLevel < 0.7) return DuolingoTheme.duoOrange;
    return DuolingoTheme.duoRed;
  }

  String _getRiskDescription(double riskScore) {
    if (riskScore < 0.3) return 'Conservative';
    if (riskScore < 0.7) return 'Moderate';
    return 'Aggressive';
  }
}