import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/duolingo_theme.dart';

class InteractiveBudgetPlanner extends StatefulWidget {
  final double monthlyIncome;
  final List<Map<String, dynamic>> categories;
  final Function(Map<String, double>) onBudgetChanged;

  const InteractiveBudgetPlanner({
    super.key,
    required this.monthlyIncome,
    required this.categories,
    required this.onBudgetChanged,
  });

  @override
  State<InteractiveBudgetPlanner> createState() => _InteractiveBudgetPlannerState();
}

class _InteractiveBudgetPlannerState extends State<InteractiveBudgetPlanner> with TickerProviderStateMixin {
  final Map<String, double> _allocations = {};
  late AnimationController _animationController;
  late Animation<double> _pieAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize allocations with default percentages
    for (var category in widget.categories) {
      _allocations[category['name']] = (category['percentage'] as int).toDouble();
    }
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pieAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: DuolingoTheme.duoGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Royal Budget Planner',
                      style: DuolingoTheme.h4.copyWith(
                        color: DuolingoTheme.charcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Monthly Income: \$${widget.monthlyIncome.toStringAsFixed(0)}',
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
          
          // Budget allocation pie chart
          SizedBox(
            height: 250,
            child: AnimatedBuilder(
              animation: _pieAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: _createPieChartSections(),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            if (event is FlTapUpEvent && pieTouchResponse != null) {
                              final touchedSection = pieTouchResponse.touchedSection;
                              if (touchedSection != null) {
                                _showCategoryDetails(touchedSection.touchedSectionIndex);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    
                    // Center content
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: DuolingoTheme.caption.copyWith(
                              color: DuolingoTheme.darkGray,
                            ),
                          ),
                          Text(
                            '${_getTotalPercentage().toInt()}%',
                            style: DuolingoTheme.h3.copyWith(
                              color: _getTotalPercentage() == 100 
                                  ? DuolingoTheme.duoGreen 
                                  : DuolingoTheme.duoRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Category sliders
          ...widget.categories.map((category) => _buildCategorySlider(category)),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Summary
          _buildBudgetSummary(),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Validation message
          if (_getTotalPercentage() != 100) _buildValidationMessage(),
        ],
      ),
    );
  }

  Widget _buildCategorySlider(Map<String, dynamic> category) {
    final categoryName = category['name'] as String;
    final currentValue = _allocations[categoryName] ?? 0.0;
    final minValue = (category['min'] as int).toDouble();
    final maxValue = (category['max'] as int).toDouble();
    final color = Color(int.parse(category['color'].replaceFirst('#', '0xff')));

    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  style: DuolingoTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DuolingoTheme.charcoal,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentValue.toInt()}% (\$${(widget.monthlyIncome * currentValue / 100).toStringAsFixed(0)})',
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
              min: minValue,
              max: maxValue,
              divisions: ((maxValue - minValue) / 5).round(),
              onChanged: (value) {
                setState(() {
                  _allocations[categoryName] = value;
                });
                widget.onBudgetChanged(_allocations);
                
                // Animate pie chart update
                _animationController.reset();
                _animationController.forward();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.lightGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Breakdown',
            style: DuolingoTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: DuolingoTheme.charcoal,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          ...widget.categories.map((category) {
            final categoryName = category['name'] as String;
            final percentage = _allocations[categoryName] ?? 0.0;
            final amount = widget.monthlyIncome * percentage / 100;
            final color = Color(int.parse(category['color'].replaceFirst('#', '0xff')));
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      categoryName,
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.darkGray,
                      ),
                    ),
                  ),
                  Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style: DuolingoTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DuolingoTheme.charcoal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
                  ? 'Your budget exceeds 100% by ${difference.toInt()}%. Reduce some categories!'
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
    return widget.categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final categoryName = category['name'] as String;
      final percentage = _allocations[categoryName] ?? 0.0;
      final color = Color(int.parse(category['color'].replaceFirst('#', '0xff')));
      
      return PieChartSectionData(
        color: color,
        value: percentage * _pieAnimation.value,
        title: '${percentage.toInt()}%',
        radius: 60 + (index * 5),
        titleStyle: DuolingoTheme.caption.copyWith(
          color: DuolingoTheme.white,
          fontWeight: FontWeight.w600,
        ),
        badgeWidget: percentage > 15 ? null : Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${percentage.toInt()}%',
            style: DuolingoTheme.caption.copyWith(
              color: DuolingoTheme.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      );
    }).toList();
  }

  double _getTotalPercentage() {
    return _allocations.values.fold(0.0, (sum, value) => sum + value);
  }

  void _showCategoryDetails(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= widget.categories.length) return;
    
    final category = widget.categories[sectionIndex];
    final categoryName = category['name'] as String;
    final percentage = _allocations[categoryName] ?? 0.0;
    final amount = widget.monthlyIncome * percentage / 100;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        ),
        title: Text(
          categoryName,
          style: DuolingoTheme.h4.copyWith(
            color: DuolingoTheme.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allocation: ${percentage.toInt()}%',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monthly Amount: \$${amount.toStringAsFixed(0)}',
              style: DuolingoTheme.bodyLarge.copyWith(
                color: DuolingoTheme.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.duoGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}