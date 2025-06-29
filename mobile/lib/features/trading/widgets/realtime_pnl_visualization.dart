import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../shared/theme/duolingo_theme.dart';
import '../../../shared/widgets/kingdom_card.dart';

class RealtimePnLVisualization extends StatefulWidget {
  final List<Position> positions;
  final double portfolioValue;
  final List<PnLDataPoint> pnlHistory;
  final Stream<PnLUpdate>? pnlStream;
  final VoidCallback? onTapPosition;

  const RealtimePnLVisualization({
    super.key,
    required this.positions,
    required this.portfolioValue,
    required this.pnlHistory,
    this.pnlStream,
    this.onTapPosition,
  });

  @override
  State<RealtimePnLVisualization> createState() => _RealtimePnLVisualizationState();
}

class _RealtimePnLVisualizationState extends State<RealtimePnLVisualization>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _countUpController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _countUpAnimation;
  
  double _currentPnL = 0.0;
  double _previousPnL = 0.0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _countUpController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
    
    _countUpAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _countUpController,
      curve: Curves.easeOutCubic,
    ));

    _calculateCurrentPnL();
    _waveController.repeat();
    
    // Listen to PnL updates
    widget.pnlStream?.listen(_handlePnLUpdate);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _countUpController.dispose();
    super.dispose();
  }

  void _calculateCurrentPnL() {
    _currentPnL = widget.positions.fold(0.0, (sum, pos) => sum + pos.unrealizedPnl);
  }

  void _handlePnLUpdate(PnLUpdate update) {
    if (!mounted) return;
    
    setState(() {
      _previousPnL = _currentPnL;
      _currentPnL = update.totalPnL;
      _isAnimating = true;
    });
    
    // Trigger animations based on change magnitude
    final change = (_currentPnL - _previousPnL).abs();
    if (change > 10) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
    
    _countUpController.reset();
    _countUpController.forward().then((_) {
      setState(() {
        _isAnimating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return KingdomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildMainPnLDisplay(),
          const SizedBox(height: 20),
          _buildPortfolioSummary(),
          const SizedBox(height: 20),
          _buildPositionsList(),
          const SizedBox(height: 16),
          _buildPnLChart(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: _currentPnL >= 0 
                ? DuolingoTheme.successGradient 
                : DuolingoTheme.errorGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _currentPnL >= 0 ? Icons.trending_up : Icons.trending_down,
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
                'Portfolio P&L',
                style: DuolingoTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Real-time performance tracking',
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildLiveIndicator(),
      ],
    );
  }

  Widget _buildLiveIndicator() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DuolingoTheme.duoGreen),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: DuolingoTheme.duoGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DuolingoTheme.duoGreen.withValues(alpha: 0.6),
                      blurRadius: 4 + (math.sin(_waveAnimation.value) * 2),
                      spreadRadius: 1 + (math.sin(_waveAnimation.value) * 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.duoGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainPnLDisplay() {
    return AnimatedBuilder(
      animation: _isAnimating ? _countUpAnimation : kAlwaysCompleteAnimation,
      builder: (context, child) {
        final displayPnL = _isAnimating 
            ? _previousPnL + ((_currentPnL - _previousPnL) * _countUpAnimation.value)
            : _currentPnL;
            
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: displayPnL >= 0 
                        ? [
                            DuolingoTheme.duoGreen.withValues(alpha: 0.1),
                            DuolingoTheme.duoGreen.withValues(alpha: 0.05),
                          ]
                        : [
                            DuolingoTheme.duoRed.withValues(alpha: 0.1),
                            DuolingoTheme.duoRed.withValues(alpha: 0.05),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: displayPnL >= 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Unrealized P&L',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        color: DuolingoTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          displayPnL >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          color: displayPnL >= 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${displayPnL >= 0 ? '+' : ''}\$${displayPnL.toStringAsFixed(2)}',
                          style: DuolingoTheme.headingLarge.copyWith(
                            color: displayPnL >= 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${((displayPnL / widget.portfolioValue) * 100).toStringAsFixed(2)}% of portfolio',
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPortfolioSummary() {
    final totalValue = widget.portfolioValue + _currentPnL;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuolingoTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DuolingoTheme.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Portfolio Value', '\$${widget.portfolioValue.toStringAsFixed(2)}'),
          _buildSummaryItem('Total Value', '\$${totalValue.toStringAsFixed(2)}'),
          _buildSummaryItem('Positions', '${widget.positions.length}'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: DuolingoTheme.bodySmall.copyWith(
            color: DuolingoTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPositionsList() {
    if (widget.positions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DuolingoTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DuolingoTheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(
              Icons.trending_flat,
              size: 48,
              color: DuolingoTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No Open Positions',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Open Positions',
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.positions.map((position) => _buildPositionItem(position)),
      ],
    );
  }

  Widget _buildPositionItem(Position position) {
    final pnlColor = position.unrealizedPnl >= 0 
        ? DuolingoTheme.duoGreen 
        : DuolingoTheme.duoRed;

    return GestureDetector(
      onTap: widget.onTapPosition,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: pnlColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: pnlColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: position.isLong 
                    ? DuolingoTheme.duoGreen.withValues(alpha: 0.2)
                    : DuolingoTheme.duoRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                position.isLong ? Icons.north_east : Icons.south_east,
                color: position.isLong ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${position.symbol} ${position.isLong ? 'Long' : 'Short'}',
                        style: DuolingoTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${position.unrealizedPnl >= 0 ? '+' : ''}\$${position.unrealizedPnl.toStringAsFixed(2)}',
                        style: DuolingoTheme.bodyMedium.copyWith(
                          color: pnlColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${position.size.toStringAsFixed(4)} @ \$${position.entryPrice.toStringAsFixed(2)}',
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${position.leverage}x leverage',
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPnLChart() {
    if (widget.pnlHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'P&L History (24h)',
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: CustomPaint(
            painter: PnLChartPainter(
              dataPoints: widget.pnlHistory,
              currentPnL: _currentPnL,
            ),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}

// Custom painter for P&L chart
class PnLChartPainter extends CustomPainter {
  final List<PnLDataPoint> dataPoints;
  final double currentPnL;

  PnLChartPainter({
    required this.dataPoints,
    required this.currentPnL,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final gradientPaint = Paint()
      ..style = PaintingStyle.fill;

    // Calculate bounds
    final minPnL = dataPoints.map((p) => p.pnl).reduce(math.min);
    final maxPnL = dataPoints.map((p) => p.pnl).reduce(math.max);
    final range = maxPnL - minPnL;
    
    if (range == 0) return;

    // Create path for line
    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final y = size.height - ((dataPoints[i].pnl - minPnL) / range) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    // Close fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Determine colors based on overall trend
    final isPositive = currentPnL >= 0;
    final lineColor = isPositive ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed;
    
    // Draw gradient fill
    gradientPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.3),
        lineColor.withValues(alpha: 0.1),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(fillPath, gradientPaint);

    // Draw line
    paint.color = lineColor;
    canvas.drawPath(path, paint);

    // Draw zero line if needed
    if (minPnL < 0 && maxPnL > 0) {
      final zeroY = size.height - ((-minPnL) / range) * size.height;
      paint.color = DuolingoTheme.textSecondary.withValues(alpha: 0.5);
      paint.strokeWidth = 1;
      canvas.drawLine(
        Offset(0, zeroY),
        Offset(size.width, zeroY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Data models
class PnLDataPoint {
  final DateTime timestamp;
  final double pnl;
  final double portfolioValue;

  const PnLDataPoint({
    required this.timestamp,
    required this.pnl,
    required this.portfolioValue,
  });

  factory PnLDataPoint.fromJson(Map<String, dynamic> json) {
    return PnLDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      pnl: (json['pnl'] as num).toDouble(),
      portfolioValue: (json['portfolioValue'] as num).toDouble(),
    );
  }
}

class PnLUpdate {
  final double totalPnL;
  final Map<String, double> positionPnLs;
  final DateTime timestamp;

  const PnLUpdate({
    required this.totalPnL,
    required this.positionPnLs,
    required this.timestamp,
  });

  factory PnLUpdate.fromJson(Map<String, dynamic> json) {
    return PnLUpdate(
      totalPnL: (json['totalPnL'] as num).toDouble(),
      positionPnLs: Map<String, double>.from(
        (json['positionPnLs'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

// Re-export Position class for convenience
class Position {
  final String id;
  final String symbol;
  final double size;
  final double entryPrice;
  final double markPrice;
  final double leverage;
  final bool isLong;
  final double unrealizedPnl;
  final double? liquidationPrice;
  final double? stopLossPrice;
  final double? takeProfitPrice;
  final DateTime openedAt;

  const Position({
    required this.id,
    required this.symbol,
    required this.size,
    required this.entryPrice,
    required this.markPrice,
    required this.leverage,
    required this.isLong,
    required this.unrealizedPnl,
    this.liquidationPrice,
    this.stopLossPrice,
    this.takeProfitPrice,
    required this.openedAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      size: (json['size'] as num).toDouble(),
      entryPrice: (json['entryPrice'] as num).toDouble(),
      markPrice: (json['markPrice'] as num).toDouble(),
      leverage: (json['leverage'] as num).toDouble(),
      isLong: json['isLong'] as bool,
      unrealizedPnl: (json['unrealizedPnl'] as num).toDouble(),
      liquidationPrice: json['liquidationPrice'] != null 
          ? (json['liquidationPrice'] as num).toDouble() 
          : null,
      stopLossPrice: json['stopLossPrice'] != null 
          ? (json['stopLossPrice'] as num).toDouble() 
          : null,
      takeProfitPrice: json['takeProfitPrice'] != null 
          ? (json['takeProfitPrice'] as num).toDouble() 
          : null,
      openedAt: DateTime.parse(json['openedAt'] as String),
    );
  }
}