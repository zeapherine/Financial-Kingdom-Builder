import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/duolingo_theme.dart';
import '../../../shared/widgets/kingdom_card.dart';

class AdvancedTradingChart extends StatefulWidget {
  final List<PriceData> priceData;
  final List<TechnicalIndicator> indicators;
  final Function(String timeframe) onTimeframeChanged;
  final Function(String symbol) onSymbolChanged;
  final VoidCallback? onAddIndicator;

  const AdvancedTradingChart({
    super.key,
    required this.priceData,
    required this.indicators,
    required this.onTimeframeChanged,
    required this.onSymbolChanged,
    this.onAddIndicator,
  });

  @override
  State<AdvancedTradingChart> createState() => _AdvancedTradingChartState();
}

class _AdvancedTradingChartState extends State<AdvancedTradingChart>
    with TickerProviderStateMixin {
  String _selectedTimeframe = '1H';
  String _selectedSymbol = 'BTC-USD';
  bool _showVolume = true;
  bool _showIndicators = true;
  
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;

  final List<String> _timeframes = ['1M', '5M', '15M', '1H', '4H', '1D', '1W'];
  final List<String> _symbols = ['BTC-USD', 'ETH-USD', 'SOL-USD', 'AVAX-USD'];

  @override
  void initState() {
    super.initState();
    
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOut,
    ));

    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KingdomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartHeader(),
          const SizedBox(height: 16),
          _buildChartControls(),
          const SizedBox(height: 16),
          _buildMainChart(),
          if (_showVolume) ...[
            const SizedBox(height: 8),
            _buildVolumeChart(),
          ],
          const SizedBox(height: 16),
          _buildIndicatorControls(),
        ],
      ),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: DuolingoTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedSymbol,
                style: DuolingoTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Last: \$${_getCurrentPrice().toStringAsFixed(2)}',
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildPriceChangeIndicator(),
      ],
    );
  }

  Widget _buildPriceChangeIndicator() {
    final change = _getPriceChange();
    final isPositive = change >= 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPositive 
            ? DuolingoTheme.duoGreen.withValues(alpha: 0.1)
            : DuolingoTheme.duoRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPositive ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
            style: DuolingoTheme.bodySmall.copyWith(
              color: isPositive ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartControls() {
    return Row(
      children: [
        Expanded(
          child: _buildSymbolSelector(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildTimeframeSelector(),
        ),
        const SizedBox(width: 16),
        _buildChartOptionsMenu(),
      ],
    );
  }

  Widget _buildSymbolSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: DuolingoTheme.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSymbol,
          isExpanded: true,
          items: _symbols.map((symbol) => DropdownMenuItem(
            value: symbol,
            child: Text(
              symbol,
              style: DuolingoTheme.bodyMedium,
            ),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSymbol = value;
              });
              widget.onSymbolChanged(value);
              _chartAnimationController.reset();
              _chartAnimationController.forward();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _timeframes.map((timeframe) => 
          _buildTimeframeChip(timeframe)
        ).toList(),
      ),
    );
  }

  Widget _buildTimeframeChip(String timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = timeframe;
        });
        widget.onTimeframeChanged(timeframe);
        _chartAnimationController.reset();
        _chartAnimationController.forward();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? DuolingoTheme.duoBlue 
              : DuolingoTheme.surfaceLight,
          border: Border.all(
            color: isSelected 
                ? DuolingoTheme.duoBlue 
                : DuolingoTheme.borderLight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          timeframe,
          style: DuolingoTheme.bodySmall.copyWith(
            color: isSelected 
                ? Colors.white 
                : DuolingoTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChartOptionsMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'volume',
          child: Row(
            children: [
              Icon(
                _showVolume ? Icons.check_box : Icons.check_box_outline_blank,
                color: DuolingoTheme.duoBlue,
              ),
              const SizedBox(width: 8),
              const Text('Show Volume'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'indicators',
          child: Row(
            children: [
              Icon(
                _showIndicators ? Icons.check_box : Icons.check_box_outline_blank,
                color: DuolingoTheme.duoBlue,
              ),
              const SizedBox(width: 8),
              const Text('Show Indicators'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'add_indicator',
          child: Row(
            children: [
              Icon(Icons.add, color: DuolingoTheme.duoGreen),
              SizedBox(width: 8),
              Text('Add Indicator'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'fullscreen',
          child: Row(
            children: [
              Icon(Icons.fullscreen),
              SizedBox(width: 8),
              Text('Fullscreen'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'volume':
            setState(() {
              _showVolume = !_showVolume;
            });
            break;
          case 'indicators':
            setState(() {
              _showIndicators = !_showIndicators;
            });
            break;
          case 'add_indicator':
            widget.onAddIndicator?.call();
            break;
          case 'fullscreen':
            _showFullscreenChart();
            break;
        }
      },
    );
  }

  Widget _buildMainChart() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: DuolingoTheme.borderLight,
                    strokeWidth: 0.5,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: DuolingoTheme.borderLight,
                    strokeWidth: 0.5,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return _buildBottomTitle(value);
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1000,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '\$${(value.toInt() / 1000).toStringAsFixed(0)}k',
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.textSecondary,
                        ),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: DuolingoTheme.borderLight,
                  width: 1,
                ),
              ),
              minX: 0,
              maxX: widget.priceData.length.toDouble() - 1,
              minY: _getMinPrice(),
              maxY: _getMaxPrice(),
              lineBarsData: [
                _buildPriceLineData(),
                if (_showIndicators) ..._buildIndicatorLines(),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      return LineTooltipItem(
                        '\$${touchedSpot.y.toStringAsFixed(2)}',
                        DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVolumeChart() {
    return SizedBox(
      height: 80,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxVolume(),
          barGroups: _buildVolumeBarGroups(),
          titlesData: FlTitlesData(
            show: false,
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildIndicatorControls() {
    if (!_showIndicators || widget.indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Indicators',
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.indicators.map((indicator) => 
            _buildIndicatorChip(indicator)
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildIndicatorChip(TechnicalIndicator indicator) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: indicator.color.withValues(alpha: 0.1),
        border: Border.all(color: indicator.color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: indicator.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            indicator.name,
            style: DuolingoTheme.bodySmall.copyWith(
              color: indicator.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              // Remove indicator
            },
            child: Icon(
              Icons.close,
              size: 14,
              color: indicator.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTitle(double value) {
    if (value < 0 || value >= widget.priceData.length) {
      return const SizedBox.shrink();
    }

    final index = value.toInt();
    if (index % 6 != 0) return const SizedBox.shrink(); // Show every 6th label

    final timestamp = widget.priceData[index].timestamp;
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        style: DuolingoTheme.bodySmall.copyWith(
          color: DuolingoTheme.textSecondary,
        ),
      ),
    );
  }

  LineChartBarData _buildPriceLineData() {
    final spots = widget.priceData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.close);
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      gradient: const LinearGradient(
        colors: [DuolingoTheme.duoBlue, DuolingoTheme.duoGreen],
      ),
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            DuolingoTheme.duoBlue.withValues(alpha: 0.3),
            DuolingoTheme.duoGreen.withValues(alpha: 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  List<LineChartBarData> _buildIndicatorLines() {
    return widget.indicators.map((indicator) {
      final spots = indicator.values.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value);
      }).toList();

      return LineChartBarData(
        spots: spots,
        isCurved: false,
        color: indicator.color,
        barWidth: 1.5,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildVolumeBarGroups() {
    return widget.priceData.asMap().entries.map((entry) {
      final isPositive = entry.value.close > entry.value.open;
      
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.volume,
            color: isPositive 
                ? DuolingoTheme.duoGreen.withValues(alpha: 0.6)
                : DuolingoTheme.duoRed.withValues(alpha: 0.6),
            width: 2,
          ),
        ],
      );
    }).toList();
  }

  double _getCurrentPrice() {
    return widget.priceData.isNotEmpty ? widget.priceData.last.close : 0.0;
  }

  double _getPriceChange() {
    if (widget.priceData.length < 2) return 0.0;
    
    final current = widget.priceData.last.close;
    final previous = widget.priceData[widget.priceData.length - 2].close;
    
    return ((current - previous) / previous) * 100;
  }

  double _getMinPrice() {
    if (widget.priceData.isEmpty) return 0.0;
    return widget.priceData.map((e) => e.low).reduce((a, b) => a < b ? a : b) * 0.99;
  }

  double _getMaxPrice() {
    if (widget.priceData.isEmpty) return 100.0;
    return widget.priceData.map((e) => e.high).reduce((a, b) => a > b ? a : b) * 1.01;
  }

  double _getMaxVolume() {
    if (widget.priceData.isEmpty) return 100.0;
    return widget.priceData.map((e) => e.volume).reduce((a, b) => a > b ? a : b) * 1.1;
  }

  void _showFullscreenChart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(_selectedSymbol),
            backgroundColor: DuolingoTheme.surfaceLight,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AdvancedTradingChart(
              priceData: widget.priceData,
              indicators: widget.indicators,
              onTimeframeChanged: widget.onTimeframeChanged,
              onSymbolChanged: widget.onSymbolChanged,
              onAddIndicator: widget.onAddIndicator,
            ),
          ),
        ),
      ),
    );
  }
}

// Data models
class PriceData {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const PriceData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      timestamp: json['timestamp'] as int,
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }
}

class TechnicalIndicator {
  final String name;
  final String type;
  final List<double> values;
  final Color color;
  final Map<String, dynamic> parameters;

  const TechnicalIndicator({
    required this.name,
    required this.type,
    required this.values,
    required this.color,
    required this.parameters,
  });

  factory TechnicalIndicator.fromJson(Map<String, dynamic> json) {
    return TechnicalIndicator(
      name: json['name'] as String,
      type: json['type'] as String,
      values: List<double>.from(json['values'] as List),
      color: Color(json['color'] as int),
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
    );
  }
}