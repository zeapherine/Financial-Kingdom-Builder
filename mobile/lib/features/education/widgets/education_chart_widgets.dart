import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/config/duolingo_theme.dart';

class EducationBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> incomeData;
  final List<Map<String, dynamic>> expenseData;
  final String title;

  const EducationBarChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
    required this.title,
  });

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
          Text(
            title,
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Income vs Expenses Comparison
          Row(
            children: [
              // Income Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: DuolingoTheme.duoGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: DuolingoTheme.spacingSm),
                        Text(
                          'Income',
                          style: DuolingoTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: DuolingoTheme.charcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DuolingoTheme.spacingSm),
                    Text(
                      '\$${_calculateTotal(incomeData).toStringAsFixed(0)}',
                      style: DuolingoTheme.h3.copyWith(
                        color: DuolingoTheme.duoGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Expenses Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: DuolingoTheme.duoRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: DuolingoTheme.spacingSm),
                        Text(
                          'Expenses',
                          style: DuolingoTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: DuolingoTheme.charcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DuolingoTheme.spacingSm),
                    Text(
                      '\$${_calculateTotal(expenseData).toStringAsFixed(0)}',
                      style: DuolingoTheme.h3.copyWith(
                        color: DuolingoTheme.duoRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Chart
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue() * 1.2,
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() < incomeData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              incomeData[value.toInt()]['category'],
                              style: DuolingoTheme.caption.copyWith(
                                color: DuolingoTheme.darkGray,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 42,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: DuolingoTheme.caption.copyWith(
                            color: DuolingoTheme.darkGray,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _createBarGroups(),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: DuolingoTheme.lightGray,
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Net Result
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: _getNetResult() > 0 ? DuolingoTheme.duoGreenLight.withValues(alpha: 0.1) : DuolingoTheme.duoRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Result:',
                  style: DuolingoTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DuolingoTheme.charcoal,
                  ),
                ),
                Text(
                  '\$${_getNetResult().toStringAsFixed(0)}',
                  style: DuolingoTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _getNetResult() > 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal(List<Map<String, dynamic>> data) {
    return data.fold(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
  }

  double _getMaxValue() {
    final incomeMax = incomeData.isNotEmpty 
        ? incomeData.map((e) => e['amount'] as num).reduce((a, b) => a > b ? a : b).toDouble()
        : 0.0;
    final expenseMax = expenseData.isNotEmpty
        ? expenseData.map((e) => e['amount'] as num).reduce((a, b) => a > b ? a : b).toDouble()
        : 0.0;
    return incomeMax > expenseMax ? incomeMax : expenseMax;
  }

  double _getNetResult() {
    return _calculateTotal(incomeData) - _calculateTotal(expenseData);
  }

  List<BarChartGroupData> _createBarGroups() {
    List<BarChartGroupData> groups = [];
    
    for (int i = 0; i < incomeData.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (incomeData[i]['amount'] as num).toDouble(),
              color: Color(int.parse(incomeData[i]['color'].replaceFirst('#', '0xff'))),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    
    return groups;
  }
}

class RiskMeterWidget extends StatelessWidget {
  final double riskLevel;
  final String title;
  final String description;

  const RiskMeterWidget({
    super.key,
    required this.riskLevel,
    required this.title,
    required this.description,
  });

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
          Text(
            title,
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            description,
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Risk Meter
          SizedBox(
            height: 200,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      backgroundColor: DuolingoTheme.lightGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(DuolingoTheme.lightGray),
                    ),
                  ),
                  // Risk level circle
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: riskLevel / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(_getRiskColor()),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${riskLevel.toInt()}%',
                        style: DuolingoTheme.h2.copyWith(
                          color: _getRiskColor(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _getRiskLabel(),
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.darkGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Risk level indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRiskIndicator('Low', DuolingoTheme.duoGreen, riskLevel <= 33),
              _buildRiskIndicator('Medium', DuolingoTheme.duoYellow, riskLevel > 33 && riskLevel <= 66),
              _buildRiskIndicator('High', DuolingoTheme.duoRed, riskLevel > 66),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(String label, Color color, bool isActive) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? color : DuolingoTheme.lightGray,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: DuolingoTheme.caption.copyWith(
            color: isActive ? color : DuolingoTheme.mediumGray,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Color _getRiskColor() {
    if (riskLevel <= 33) return DuolingoTheme.duoGreen;
    if (riskLevel <= 66) return DuolingoTheme.duoYellow;
    return DuolingoTheme.duoRed;
  }

  String _getRiskLabel() {
    if (riskLevel <= 33) return 'Low Risk';
    if (riskLevel <= 66) return 'Medium Risk';
    return 'High Risk';
  }
}

class EmergencyFundChart extends StatelessWidget {
  final List<Map<String, dynamic>> progressData;
  final double targetAmount;

  const EmergencyFundChart({
    super.key,
    required this.progressData,
    required this.targetAmount,
  });

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
          Text(
            'Emergency Fund Progress',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            'Building your financial safety net over time',
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Progress chart
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: DuolingoTheme.lightGray,
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          'M${value.toInt()}',
                          style: DuolingoTheme.caption.copyWith(
                            color: DuolingoTheme.darkGray,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '\$${(value / 1000).toInt()}K',
                          style: DuolingoTheme.caption.copyWith(
                            color: DuolingoTheme.darkGray,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: progressData.length.toDouble() - 1,
                minY: 0,
                maxY: targetAmount * 1.1,
                lineBarsData: [
                  // Actual progress line
                  LineChartBarData(
                    spots: progressData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value['amount'] as num).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [DuolingoTheme.duoBlue, DuolingoTheme.duoBlueLight],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          DuolingoTheme.duoBlue.withValues(alpha: 0.3),
                          DuolingoTheme.duoBlue.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Target line
                  LineChartBarData(
                    spots: List.generate(
                      progressData.length,
                      (index) => FlSpot(index.toDouble(), targetAmount),
                    ),
                    isCurved: false,
                    color: DuolingoTheme.duoGreen,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Your Progress', DuolingoTheme.duoBlue, false),
              _buildLegendItem('Target Goal', DuolingoTheme.duoGreen, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDashed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: isDashed
              ? CustomPaint(
                  painter: DashedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: DuolingoTheme.caption.copyWith(
            color: DuolingoTheme.darkGray,
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}