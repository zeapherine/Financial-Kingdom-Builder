import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/duolingo_theme.dart';

class InteractivePortfolioBuilder extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> assetTypes;
  final List<Map<String, dynamic>> presetPortfolios;
  final Function(Map<String, double>) onAllocationChanged;

  const InteractivePortfolioBuilder({
    super.key,
    required this.totalAmount,
    required this.assetTypes,
    required this.presetPortfolios,
    required this.onAllocationChanged,
  });

  @override
  State<InteractivePortfolioBuilder> createState() => _InteractivePortfolioBuilderState();
}

class _InteractivePortfolioBuilderState extends State<InteractivePortfolioBuilder> with TickerProviderStateMixin {
  final Map<String, double> _allocations = {};
  late AnimationController _pieAnimationController;
  late AnimationController _metricsAnimationController;
  late Animation<double> _pieAnimation;
  late Animation<double> _metricsAnimation;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    
    // Initialize with balanced allocation
    double equalPercent = 100.0 / widget.assetTypes.length;
    for (var asset in widget.assetTypes) {
      _allocations[asset['name']] = equalPercent;
    }
    
    _pieAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _metricsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pieAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pieAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _metricsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _metricsAnimationController,
      curve: Curves.bounceOut,
    ));
    
    _pieAnimationController.forward();
    _metricsAnimationController.forward();
  }

  @override
  void dispose() {
    _pieAnimationController.dispose();
    _metricsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Portfolio visualization and controls
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pie chart
              Expanded(
                flex: 1,
                child: _buildPortfolioPieChart(),
              ),
              
              const SizedBox(width: DuolingoTheme.spacingLg),
              
              // Metrics panel
              Expanded(
                flex: 1,
                child: _buildMetricsPanel(),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Asset allocation sliders
          _buildAllocationSliders(),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Preset portfolios
          _buildPresetPortfolios(),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Validation message
          if (_getTotalPercentage() != 100) _buildValidationMessage(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DuolingoTheme.duoPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.pie_chart,
            color: DuolingoTheme.duoPurple,
            size: 24,
          ),
        ),
        const SizedBox(width: DuolingoTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Royal Portfolio Builder',
                style: DuolingoTheme.h4.copyWith(
                  color: DuolingoTheme.charcoal,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Total Investment: \$${widget.totalAmount.toStringAsFixed(0)}',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioPieChart() {
    return AnimatedBuilder(
      animation: _pieAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Text(
              'Portfolio Allocation',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingMd),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: _createPieChartSections(),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingMd),
            // Legend
            _buildPieChartLegend(),
          ],
        );
      },
    );
  }

  Widget _buildPieChartLegend() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: widget.assetTypes.asMap().entries.map((entry) {
        final index = entry.key;
        final asset = entry.value;
        final color = Color(int.parse(asset['color'].replaceFirst('#', '0xff')));
        final percentage = _allocations[asset['name']] ?? 0.0;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: _touchedIndex == index
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${asset['name']} ${percentage.toInt()}%',
                style: DuolingoTheme.caption.copyWith(
                  color: DuolingoTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsPanel() {
    return AnimatedBuilder(
      animation: _metricsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _metricsAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: DuolingoTheme.lightGray.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Metrics',
                  style: DuolingoTheme.bodyMedium.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DuolingoTheme.spacingMd),
                
                _buildMetricItem(
                  'Expected Return',
                  '${_calculateExpectedReturn().toStringAsFixed(1)}%',
                  DuolingoTheme.duoGreen,
                  Icons.trending_up,
                ),
                
                const SizedBox(height: DuolingoTheme.spacingSm),
                
                _buildMetricItem(
                  'Risk Level',
                  '${_calculateRiskLevel().toStringAsFixed(1)}/10',
                  _getRiskColor(),
                  Icons.warning,
                ),
                
                const SizedBox(height: DuolingoTheme.spacingSm),
                
                _buildMetricItem(
                  'Sharpe Ratio',
                  _calculateSharpeRatio().toStringAsFixed(2),
                  DuolingoTheme.duoBlue,
                  Icons.analytics,
                ),
                
                const SizedBox(height: DuolingoTheme.spacingMd),
                
                // Risk level indicator
                _buildRiskIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
        ),
        Text(
          value,
          style: DuolingoTheme.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskIndicator() {
    final riskLevel = _calculateRiskLevel();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk Assessment',
          style: DuolingoTheme.caption.copyWith(
            color: DuolingoTheme.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: DuolingoTheme.lightGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: (riskLevel / 10) * 150,
              decoration: BoxDecoration(
                color: _getRiskColor(),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _getRiskLabel(riskLevel),
          style: DuolingoTheme.caption.copyWith(
            color: _getRiskColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Allocation',
          style: DuolingoTheme.bodyMedium.copyWith(
            color: DuolingoTheme.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingMd),
        ...widget.assetTypes.map((asset) => _buildAssetSlider(asset)),
      ],
    );
  }

  Widget _buildAssetSlider(Map<String, dynamic> asset) {
    final assetName = asset['name'] as String;
    final currentValue = _allocations[assetName] ?? 0.0;
    final minPercent = (asset['minPercent'] as int).toDouble();
    final maxPercent = (asset['maxPercent'] as int).toDouble();
    final color = Color(int.parse(asset['color'].replaceFirst('#', '0xff')));
    final amount = widget.totalAmount * currentValue / 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                assetName,
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.charcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentValue.toInt()}% (\$${amount.toStringAsFixed(0)})',
                  style: DuolingoTheme.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.3),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: currentValue,
              min: minPercent,
              max: maxPercent,
              divisions: ((maxPercent - minPercent) / 5).round(),
              onChanged: (value) {
                setState(() {
                  _allocations[assetName] = value;
                });
                widget.onAllocationChanged(_allocations);
                
                // Animate updates
                _pieAnimationController.reset();
                _pieAnimationController.forward();
                _metricsAnimationController.reset();
                _metricsAnimationController.forward();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetPortfolios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: DuolingoTheme.bodyMedium.copyWith(
            color: DuolingoTheme.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingMd),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.presetPortfolios.map((preset) => _buildPresetButton(preset)).toList(),
        ),
      ],
    );
  }

  Widget _buildPresetButton(Map<String, dynamic> preset) {
    return GestureDetector(
      onTap: () => _applyPreset(preset),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          preset['name'],
          style: DuolingoTheme.bodySmall.copyWith(
            color: DuolingoTheme.duoBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildValidationMessage() {
    final total = _getTotalPercentage();
    final isOver = total > 100;
    final difference = (total - 100).abs();
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: isOver 
            ? DuolingoTheme.duoRed.withValues(alpha: 0.1)
            : DuolingoTheme.duoYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
        border: Border.all(
          color: isOver ? DuolingoTheme.duoRed : DuolingoTheme.duoYellow,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOver ? Icons.warning : Icons.info,
            color: isOver ? DuolingoTheme.duoRed : DuolingoTheme.duoYellow,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOver 
                  ? 'Your allocation exceeds 100% by ${difference.toInt()}%. Reduce some assets!'
                  : 'You have ${difference.toInt()}% remaining to allocate.',
              style: DuolingoTheme.bodySmall.copyWith(
                color: isOver ? DuolingoTheme.duoRed : DuolingoTheme.duoYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections() {
    return widget.assetTypes.asMap().entries.map((entry) {
      final index = entry.key;
      final asset = entry.value;
      final assetName = asset['name'] as String;
      final percentage = _allocations[assetName] ?? 0.0;
      final color = Color(int.parse(asset['color'].replaceFirst('#', '0xff')));
      final isTouched = index == _touchedIndex;
      
      return PieChartSectionData(
        color: color,
        value: percentage * _pieAnimation.value,
        title: percentage > 5 ? '${percentage.toInt()}%' : '',
        radius: isTouched ? 65 : 55,
        titleStyle: DuolingoTheme.caption.copyWith(
          color: DuolingoTheme.white,
          fontWeight: FontWeight.w600,
        ),
      );
    }).toList();
  }

  double _getTotalPercentage() {
    return _allocations.values.fold(0.0, (sum, value) => sum + value);
  }

  double _calculateExpectedReturn() {
    double weightedReturn = 0.0;
    for (var asset in widget.assetTypes) {
      final allocation = _allocations[asset['name']] ?? 0.0;
      final expectedReturn = (asset['expectedReturn'] as int).toDouble();
      weightedReturn += (allocation / 100) * expectedReturn;
    }
    return weightedReturn;
  }

  double _calculateRiskLevel() {
    double weightedRisk = 0.0;
    for (var asset in widget.assetTypes) {
      final allocation = _allocations[asset['name']] ?? 0.0;
      final risk = (asset['risk'] as int).toDouble();
      weightedRisk += (allocation / 100) * risk;
    }
    return weightedRisk;
  }

  double _calculateSharpeRatio() {
    final expectedReturn = _calculateExpectedReturn();
    final riskLevel = _calculateRiskLevel();
    const riskFreeRate = 2.0; // Assume 2% risk-free rate
    
    if (riskLevel == 0) return 0;
    return (expectedReturn - riskFreeRate) / riskLevel;
  }

  Color _getRiskColor() {
    final riskLevel = _calculateRiskLevel();
    if (riskLevel <= 3) return DuolingoTheme.duoGreen;
    if (riskLevel <= 6) return DuolingoTheme.duoYellow;
    return DuolingoTheme.duoRed;
  }

  String _getRiskLabel(double riskLevel) {
    if (riskLevel <= 3) return 'Conservative';
    if (riskLevel <= 6) return 'Moderate';
    return 'Aggressive';
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _allocations['Stocks'] = (preset['stocks'] as int).toDouble();
      _allocations['Bonds'] = (preset['bonds'] as int).toDouble();
      _allocations['Real Estate'] = (preset['realestate'] as int).toDouble();
      _allocations['Cash'] = (preset['cash'] as int).toDouble();
      _allocations['Commodities'] = (preset['commodities'] as int).toDouble();
    });
    
    widget.onAllocationChanged(_allocations);
    
    // Animate updates
    _pieAnimationController.reset();
    _pieAnimationController.forward();
    _metricsAnimationController.reset();
    _metricsAnimationController.forward();
  }
}