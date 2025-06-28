import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/duolingo_theme.dart';

class PortfolioPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> portfolioData;
  final String title;
  final double totalValue;

  const PortfolioPieChart({
    super.key,
    required this.portfolioData,
    required this.title,
    required this.totalValue,
  });

  @override
  State<PortfolioPieChart> createState() => _PortfolioPieChartState();
}

class _PortfolioPieChartState extends State<PortfolioPieChart> with TickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
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
                  Icons.pie_chart,
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
                      widget.title,
                      style: DuolingoTheme.h4.copyWith(
                        color: DuolingoTheme.charcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Total Value: \$${widget.totalValue.toStringAsFixed(0)}',
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
          
          // Chart and details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pie chart
              Expanded(
                flex: 2,
                child: _buildPieChart(),
              ),
              
              const SizedBox(width: DuolingoTheme.spacingMd),
              
              // Legend and details
              Expanded(
                flex: 3,
                child: _buildLegendAndDetails(),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Asset breakdown table
          _buildAssetBreakdown(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
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
        );
      },
    );
  }

  Widget _buildLegendAndDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Breakdown',
          style: DuolingoTheme.bodyMedium.copyWith(
            color: DuolingoTheme.charcoal,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingMd),
        ...widget.portfolioData.asMap().entries.map((entry) {
          final index = entry.key;
          final asset = entry.value;
          final isSelected = index == _touchedIndex;
          
          return _buildLegendItem(asset, isSelected, index);
        }),
      ],
    );
  }

  Widget _buildLegendItem(Map<String, dynamic> asset, bool isSelected, int index) {
    final color = Color(int.parse(asset['color'].replaceFirst('#', '0xff')));
    final percentage = asset['percentage'] as int;
    final amount = asset['amount'] as int;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingSm),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _touchedIndex = isSelected ? -1 : index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(DuolingoTheme.spacingSm),
          decoration: BoxDecoration(
            color: isSelected 
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
            border: isSelected 
                ? Border.all(color: color, width: 1)
                : null,
          ),
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
              const SizedBox(width: DuolingoTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset['category'],
                      style: DuolingoTheme.bodyMedium.copyWith(
                        color: DuolingoTheme.charcoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isSelected && asset['description'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        asset['description'],
                        style: DuolingoTheme.caption.copyWith(
                          color: DuolingoTheme.darkGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$percentage%',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetBreakdown() {
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
            'Investment Analysis',
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Diversification score
          _buildAnalysisRow(
            'Diversification Score',
            '${_calculateDiversificationScore()}/100',
            _getDiversificationColor(),
            Icons.scatter_plot,
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          // Risk level
          _buildAnalysisRow(
            'Overall Risk Level',
            _getOverallRiskLevel(),
            _getRiskLevelColor(),
            Icons.trending_up,
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          // Largest allocation
          _buildAnalysisRow(
            'Largest Position',
            _getLargestPosition(),
            DuolingoTheme.duoBlue,
            Icons.pie_chart_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color color, IconData icon) {
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _createPieChartSections() {
    return widget.portfolioData.asMap().entries.map((entry) {
      final index = entry.key;
      final asset = entry.value;
      final percentage = asset['percentage'] as int;
      final color = Color(int.parse(asset['color'].replaceFirst('#', '0xff')));
      final isTouched = index == _touchedIndex;
      
      return PieChartSectionData(
        color: color,
        value: percentage.toDouble() * _animation.value,
        title: percentage > 8 ? '$percentage%' : '',
        radius: isTouched ? 70 : 60,
        titleStyle: DuolingoTheme.caption.copyWith(
          color: DuolingoTheme.white,
          fontWeight: FontWeight.w700,
        ),
        badgeWidget: isTouched && percentage <= 8 ? Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: DuolingoTheme.white, width: 2),
          ),
          child: Text(
            '$percentage%',
            style: DuolingoTheme.caption.copyWith(
              color: DuolingoTheme.white,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ) : null,
      );
    }).toList();
  }

  int _calculateDiversificationScore() {
    // Simple diversification score based on how evenly distributed the portfolio is
    // Perfect diversification (equal weights) = 100, concentrated portfolio = lower score
    
    final totalAssets = widget.portfolioData.length;
    final idealPercentage = 100.0 / totalAssets;
    
    double variance = 0;
    for (var asset in widget.portfolioData) {
      final percentage = asset['percentage'] as int;
      variance += (percentage - idealPercentage) * (percentage - idealPercentage);
    }
    
    final avgVariance = variance / totalAssets;
    final diversificationScore = (100 - (avgVariance / 10)).clamp(0, 100);
    
    return diversificationScore.round();
  }

  Color _getDiversificationColor() {
    final score = _calculateDiversificationScore();
    if (score >= 80) return DuolingoTheme.duoGreen;
    if (score >= 60) return DuolingoTheme.duoYellow;
    return DuolingoTheme.duoRed;
  }

  String _getOverallRiskLevel() {
    // Simplified risk calculation based on asset types
    final stocksPercentage = widget.portfolioData
        .where((asset) => asset['category'] == 'Stocks')
        .fold(0, (sum, asset) => sum + (asset['percentage'] as int));
    
    if (stocksPercentage >= 70) return 'Aggressive';
    if (stocksPercentage >= 40) return 'Moderate';
    return 'Conservative';
  }

  Color _getRiskLevelColor() {
    final riskLevel = _getOverallRiskLevel();
    switch (riskLevel) {
      case 'Aggressive':
        return DuolingoTheme.duoRed;
      case 'Moderate':
        return DuolingoTheme.duoYellow;
      case 'Conservative':
        return DuolingoTheme.duoGreen;
      default:
        return DuolingoTheme.duoBlue;
    }
  }

  String _getLargestPosition() {
    int maxPercentage = 0;
    String largestAsset = '';
    
    for (var asset in widget.portfolioData) {
      final percentage = asset['percentage'] as int;
      if (percentage > maxPercentage) {
        maxPercentage = percentage;
        largestAsset = asset['category'];
      }
    }
    
    return '$largestAsset ($maxPercentage%)';
  }
}