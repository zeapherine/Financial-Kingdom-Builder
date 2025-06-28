import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/resource_types.dart';
import '../../domain/models/resource_management_state.dart';
import '../../providers/resource_management_provider.dart';
import '../widgets/resource_allocation_interface.dart';
import '../widgets/resource_distribution_chart.dart';
import '../../../../core/config/duolingo_theme.dart';

class ResourceManagementScreen extends ConsumerStatefulWidget {
  const ResourceManagementScreen({super.key});

  @override
  ConsumerState<ResourceManagementScreen> createState() => _ResourceManagementScreenState();
}

class _ResourceManagementScreenState extends ConsumerState<ResourceManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resourceState = ref.watch(resourceManagementProvider);
    final resourceNotifier = ref.read(resourceManagementProvider.notifier);

    return Scaffold(
      backgroundColor: DuolingoTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Kingdom Resources',
          style: DuolingoTheme.h3.copyWith(color: DuolingoTheme.white),
        ),
        backgroundColor: DuolingoTheme.duoGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              resourceState.autoRebalanceEnabled 
                  ? Icons.auto_awesome 
                  : Icons.auto_awesome_outlined,
              color: DuolingoTheme.white,
            ),
            onPressed: () => resourceNotifier.toggleAutoRebalance(),
            tooltip: 'Toggle Auto-Rebalance',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: DuolingoTheme.white),
            onPressed: () => resourceNotifier.regenerateResources(),
            tooltip: 'Regenerate Resources',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: DuolingoTheme.white,
          unselectedLabelColor: DuolingoTheme.white.withOpacity(0.7),
          indicatorColor: DuolingoTheme.duoYellow,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Allocate', icon: Icon(Icons.tune)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(resourceState, resourceNotifier),
            _buildAllocationTab(resourceState, resourceNotifier),
            _buildAnalyticsTab(resourceState),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ResourceManagementState resourceState, ResourceManagementNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Value',
                  '${resourceState.totalAllocatedResources}',
                  Icons.account_balance_wallet,
                  DuolingoTheme.duoGreen,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: _buildSummaryCard(
                  'Risk Score',
                  '${(resourceState.currentRiskScore * 100).toStringAsFixed(1)}%',
                  Icons.warning,
                  _getRiskColor(resourceState.currentRiskScore),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Diversification',
                  '${(resourceState.diversificationScore * 100).toStringAsFixed(1)}%',
                  Icons.donut_large,
                  resourceState.diversificationScore > 0.6 
                      ? DuolingoTheme.duoGreen 
                      : DuolingoTheme.duoOrange,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: _buildSummaryCard(
                  'Monthly Growth',
                  '${(resourceState.metrics.monthlyGrowth * 100).toStringAsFixed(2)}%',
                  Icons.trending_up,
                  DuolingoTheme.duoBlue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Resource distribution chart
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
            decoration: BoxDecoration(
              color: DuolingoTheme.white,
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
              boxShadow: DuolingoTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resource Distribution',
                  style: DuolingoTheme.h4.copyWith(color: DuolingoTheme.charcoal),
                ),
                const SizedBox(height: DuolingoTheme.spacingMd),
                Center(
                  child: ResourceDistributionChart(
                    resourceState: resourceState,
                    size: 250,
                    onResourceTap: (type) => _showResourceDetails(type, resourceState),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Resource capacity indicators
          _buildCapacityIndicators(resourceState),
        ],
      ),
    );
  }

  Widget _buildAllocationTab(ResourceManagementState resourceState, ResourceManagementNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        children: [
          // Risk tolerance slider
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
            decoration: BoxDecoration(
              color: DuolingoTheme.white,
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
              boxShadow: DuolingoTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Tolerance',
                  style: DuolingoTheme.h4.copyWith(color: DuolingoTheme.charcoal),
                ),
                const SizedBox(height: DuolingoTheme.spacingMd),
                Slider(
                  value: resourceState.riskTolerance,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  activeColor: DuolingoTheme.duoGreen,
                  inactiveColor: DuolingoTheme.mediumGray,
                  onChanged: (value) => notifier.setRiskTolerance(value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Conservative', style: DuolingoTheme.caption),
                    Text('Aggressive', style: DuolingoTheme.caption),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Resource allocation interface
          ResourceAllocationInterface(
            resourceState: resourceState,
            onAllocationChanged: (allocations) => notifier.updateAllocation(allocations),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(ResourceManagementState resourceState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance metrics
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
            decoration: BoxDecoration(
              color: DuolingoTheme.white,
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
              boxShadow: DuolingoTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Metrics',
                  style: DuolingoTheme.h4.copyWith(color: DuolingoTheme.charcoal),
                ),
                const SizedBox(height: DuolingoTheme.spacingLg),
                
                _buildMetricRow('Daily Growth', resourceState.metrics.dailyGrowth),
                _buildMetricRow('Weekly Growth', resourceState.metrics.weeklyGrowth),
                _buildMetricRow('Monthly Growth', resourceState.metrics.monthlyGrowth),
                
                const Divider(height: DuolingoTheme.spacingLg),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rebalancing Needed',
                      style: DuolingoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Icon(
                      resourceState.needsRebalancing ? Icons.warning : Icons.check_circle,
                      color: resourceState.needsRebalancing 
                          ? DuolingoTheme.duoOrange 
                          : DuolingoTheme.duoGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Transaction history
          if (resourceState.transactionHistory.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
              decoration: BoxDecoration(
                color: DuolingoTheme.white,
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                boxShadow: DuolingoTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Transactions',
                    style: DuolingoTheme.h4.copyWith(color: DuolingoTheme.charcoal),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  
                  ...resourceState.transactionHistory.take(5).map((transaction) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: DuolingoTheme.spacingSm),
                      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: DuolingoTheme.lightGray,
                        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            color: DuolingoTheme.duoBlue,
                            size: 20,
                          ),
                          const SizedBox(width: DuolingoTheme.spacingSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${transaction.fromResource.displayName} → ${transaction.toResource.displayName}',
                                  style: DuolingoTheme.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${transaction.amount} units',
                                  style: DuolingoTheme.caption.copyWith(
                                    color: DuolingoTheme.darkGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatDateTime(transaction.timestamp),
                            style: DuolingoTheme.caption.copyWith(
                              color: DuolingoTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            value,
            style: DuolingoTheme.h3.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityIndicators(ResourceManagementState resourceState) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resource Capacity',
            style: DuolingoTheme.h4.copyWith(color: DuolingoTheme.charcoal),
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          ...ResourceType.values.map((type) {
            final capacity = resourceState.getCapacity(type);
            if (capacity == null) return const SizedBox.shrink();
            
            return Container(
              margin: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type.displayName,
                        style: DuolingoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${capacity.currentAmount}/${capacity.maxCapacity}',
                        style: DuolingoTheme.bodySmall.copyWith(color: DuolingoTheme.darkGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  LinearProgressIndicator(
                    value: capacity.capacityUsed,
                    backgroundColor: DuolingoTheme.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      capacity.isScarcityLevel 
                          ? DuolingoTheme.duoRed 
                          : _getResourceColor(type),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DuolingoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '${(value * 100).toStringAsFixed(2)}%',
            style: DuolingoTheme.bodyMedium.copyWith(
              color: value >= 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
              fontWeight: FontWeight.w600,
            ),
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

  void _showResourceDetails(ResourceType type, ResourceManagementState resourceState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type.description),
            const SizedBox(height: 16),
            Text('Risk Level: ${type.riskLevel}'),
            Text('Expected Return: ${(type.baseReturnRate * 100).toStringAsFixed(1)}%'),
            Text('Current Amount: ${resourceState.getAllocation(type)}'),
            Text('Allocation: ${resourceState.getAllocationPercentage(type).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}