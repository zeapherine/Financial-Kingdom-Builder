import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/config/duolingo_theme.dart';
import '../../../shared/widgets/duo_card.dart';

class PerpetualFundingWidget extends StatefulWidget {
  final double currentFundingRate;
  final String selectedPosition;
  final double positionSize;
  final List<Map<String, dynamic>> fundingHistory;

  const PerpetualFundingWidget({
    super.key,
    this.currentFundingRate = 0.01,
    this.selectedPosition = 'long',
    this.positionSize = 10000.0,
    this.fundingHistory = const [],
  });

  @override
  State<PerpetualFundingWidget> createState() => _PerpetualFundingWidgetState();
}

class _PerpetualFundingWidgetState extends State<PerpetualFundingWidget>
    with TickerProviderStateMixin {
  late AnimationController _flowController;
  late AnimationController _balanceController;
  late Animation<double> _flowAnimation;
  late Animation<double> _balanceAnimation;

  String currentPosition = 'long';
  bool showDetailedHistory = false;

  @override
  void initState() {
    super.initState();
    currentPosition = widget.selectedPosition;
    
    _flowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _balanceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _flowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flowController,
      curve: Curves.easeInOut,
    ));

    _balanceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _balanceController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  @override
  void dispose() {
    _flowController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _flowController.repeat();
    _balanceController.forward();
  }

  void _updatePosition(String position) {
    setState(() {
      currentPosition = position;
    });
    _balanceController.reset();
    _balanceController.forward();
  }

  double get _fundingPayment => widget.positionSize * (widget.currentFundingRate / 100);
  bool get _playerPays => (currentPosition == 'long' && widget.currentFundingRate > 0) ||
                          (currentPosition == 'short' && widget.currentFundingRate < 0);
  bool get _isPositiveFunding => widget.currentFundingRate > 0;

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      type: DuoCardType.lesson,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with Kingdom Theme
          Row(
            children: [
              const Icon(
                Icons.account_balance,
                color: DuolingoTheme.duoYellow,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Kingdom Tax & Reward System',
                style: DuolingoTheme.h3.copyWith(
                  color: DuolingoTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Current Funding Rate Display
          _buildFundingRateDisplay(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Position Selector
          _buildPositionSelector(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Tax Flow Visualization
          _buildTaxFlowVisualization(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Payment Calculator
          _buildPaymentCalculator(),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Funding History Toggle
          _buildHistoryToggle(),
          
          if (showDetailedHistory) ...[
            const SizedBox(height: DuolingoTheme.spacingMd),
            _buildFundingHistory(),
          ],
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Kingdom Strategy Tips
          _buildStrategyTips(),
        ],
      ),
    );
  }

  Widget _buildFundingRateDisplay() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isPositiveFunding
            ? [DuolingoTheme.duoRed.withValues(alpha: 0.1), DuolingoTheme.duoOrange.withValues(alpha: 0.1)]
            : [DuolingoTheme.duoGreen.withValues(alpha: 0.1), DuolingoTheme.duoBlue.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: _isPositiveFunding 
            ? DuolingoTheme.duoRed.withValues(alpha: 0.3)
            : DuolingoTheme.duoGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isPositiveFunding ? Icons.trending_up : Icons.trending_down,
            color: _isPositiveFunding ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen,
            size: DuolingoTheme.iconLarge,
          ),
          const SizedBox(width: DuolingoTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Kingdom Tax Rate',
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: DuolingoTheme.darkGray,
                  ),
                ),
                const SizedBox(height: DuolingoTheme.spacingXs),
                Text(
                  '${widget.currentFundingRate > 0 ? '+' : ''}${(widget.currentFundingRate).toStringAsFixed(4)}%',
                  style: DuolingoTheme.h2.copyWith(
                    color: _isPositiveFunding ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DuolingoTheme.spacingXs),
                Text(
                  _isPositiveFunding 
                    ? 'Expansion Army pays Defense Army'
                    : 'Defense Army pays Expansion Army',
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: DuolingoTheme.darkGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Army:',
          style: DuolingoTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.charcoal,
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingSm),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _updatePosition('long'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: currentPosition == 'long' 
                      ? DuolingoTheme.duoGreen 
                      : DuolingoTheme.lightGray,
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                    border: Border.all(
                      color: currentPosition == 'long' 
                        ? DuolingoTheme.duoGreen 
                        : DuolingoTheme.mediumGray,
                      width: 2,
                    ),
                    boxShadow: currentPosition == 'long' ? DuolingoTheme.cardShadow : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: currentPosition == 'long' 
                          ? DuolingoTheme.white 
                          : DuolingoTheme.duoGreen,
                        size: DuolingoTheme.iconLarge,
                      ),
                      const SizedBox(height: DuolingoTheme.spacingXs),
                      Text(
                        'Expansion Army',
                        style: DuolingoTheme.bodyMedium.copyWith(
                          color: currentPosition == 'long' 
                            ? DuolingoTheme.white 
                            : DuolingoTheme.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '(Long Position)',
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: currentPosition == 'long' 
                            ? DuolingoTheme.white.withValues(alpha: 0.8)
                            : DuolingoTheme.darkGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: DuolingoTheme.spacingMd),
            Expanded(
              child: GestureDetector(
                onTap: () => _updatePosition('short'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: currentPosition == 'short' 
                      ? DuolingoTheme.duoRed 
                      : DuolingoTheme.lightGray,
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                    border: Border.all(
                      color: currentPosition == 'short' 
                        ? DuolingoTheme.duoRed 
                        : DuolingoTheme.mediumGray,
                      width: 2,
                    ),
                    boxShadow: currentPosition == 'short' ? DuolingoTheme.cardShadow : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: currentPosition == 'short' 
                          ? DuolingoTheme.white 
                          : DuolingoTheme.duoRed,
                        size: DuolingoTheme.iconLarge,
                      ),
                      const SizedBox(height: DuolingoTheme.spacingXs),
                      Text(
                        'Defense Army',
                        style: DuolingoTheme.bodyMedium.copyWith(
                          color: currentPosition == 'short' 
                            ? DuolingoTheme.white 
                            : DuolingoTheme.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '(Short Position)',
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: currentPosition == 'short' 
                            ? DuolingoTheme.white.withValues(alpha: 0.8)
                            : DuolingoTheme.darkGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaxFlowVisualization() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.duoBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: AnimatedBuilder(
        animation: _flowAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: FundingFlowPainter(
              animation: _flowAnimation.value,
              isPositiveFunding: _isPositiveFunding,
              playerPays: _playerPays,
              currentPosition: currentPosition,
            ),
            child: Container(),
          );
        },
      ),
    );
  }

  Widget _buildPaymentCalculator() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: _playerPays 
          ? DuolingoTheme.duoRed.withValues(alpha: 0.1)
          : DuolingoTheme.duoGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: _playerPays 
            ? DuolingoTheme.duoRed.withValues(alpha: 0.3)
            : DuolingoTheme.duoGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _playerPays ? Icons.payment : Icons.monetization_on,
                color: _playerPays ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                _playerPays ? 'You Pay Kingdom Tax:' : 'You Receive Reward:',
                style: DuolingoTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Position Size:',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                  Text(
                    '\$${widget.positionSize.toStringAsFixed(0)}',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Every 8 Hours:',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _balanceAnimation,
                    builder: (context, child) {
                      return Text(
                        '${_playerPays ? '-' : '+'}\$${(_fundingPayment.abs() * _balanceAnimation.value).toStringAsFixed(2)}',
                        style: DuolingoTheme.h3.copyWith(
                          color: _playerPays ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Daily Total:',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                  Text(
                    '${_playerPays ? '-' : '+'}\$${(_fundingPayment.abs() * 3).toStringAsFixed(2)}',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _playerPays ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showDetailedHistory = !showDetailedHistory;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DuolingoTheme.spacingMd,
          vertical: DuolingoTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          border: Border.all(
            color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showDetailedHistory ? Icons.expand_less : Icons.expand_more,
              color: DuolingoTheme.duoBlue,
              size: DuolingoTheme.iconMedium,
            ),
            const SizedBox(width: DuolingoTheme.spacingSm),
            Text(
              showDetailedHistory ? 'Hide Tax History' : 'Show Tax History',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.duoBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundingHistory() {
    // Generate sample history if none provided
    final history = widget.fundingHistory.isNotEmpty 
      ? widget.fundingHistory 
      : _generateSampleHistory();
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.lightGray,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
      ),
      child: CustomPaint(
        painter: FundingHistoryPainter(history: history),
        child: Container(),
      ),
    );
  }

  Widget _buildStrategyTips() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.duoYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: DuolingoTheme.duoYellow,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Royal Strategy Tips:',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          ...(_getStrategyTips().map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingXs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.star,
                  color: DuolingoTheme.duoYellow,
                  size: DuolingoTheme.iconSmall,
                ),
                const SizedBox(width: DuolingoTheme.spacingSm),
                Expanded(
                  child: Text(
                    tip,
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                ),
              ],
            ),
          ))),
        ],
      ),
    );
  }

  List<String> _getStrategyTips() {
    if (_isPositiveFunding) {
      return [
        "Consider switching to Defense Army (short) to collect tax instead of paying",
        "If staying in Expansion Army, factor the tax cost into your profit calculations",
        "High positive funding often signals overheated expansion markets",
      ];
    } else {
      return [
        "Consider staying in Expansion Army (long) to collect rewards",
        "Negative funding suggests fear in the markets - opportunity for brave rulers",
        "Defense Army traders are paying you to maintain balance",
      ];
    }
  }

  List<Map<String, dynamic>> _generateSampleHistory() {
    return List.generate(24, (index) {
      final rate = 0.01 + (math.sin(index * 0.5) * 0.005);
      return {
        'time': DateTime.now().subtract(Duration(hours: index)),
        'rate': rate,
      };
    }).reversed.toList();
  }
}

class FundingFlowPainter extends CustomPainter {
  final double animation;
  final bool isPositiveFunding;
  final bool playerPays;
  final String currentPosition;

  FundingFlowPainter({
    required this.animation,
    required this.isPositiveFunding,
    required this.playerPays,
    required this.currentPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final coinPaint = Paint()
      ..style = PaintingStyle.fill;

    // Draw kingdom armies
    _drawArmy(canvas, size, 'expansion', Offset(size.width * 0.15, size.height * 0.5));
    _drawArmy(canvas, size, 'defense', Offset(size.width * 0.85, size.height * 0.5));
    
    // Draw money flow
    if (isPositiveFunding) {
      _drawMoneyFlow(canvas, size, 
        from: Offset(size.width * 0.25, size.height * 0.5),
        to: Offset(size.width * 0.75, size.height * 0.5),
        paint: paint,
        coinPaint: coinPaint,
      );
    } else {
      _drawMoneyFlow(canvas, size,
        from: Offset(size.width * 0.75, size.height * 0.5),
        to: Offset(size.width * 0.25, size.height * 0.5),
        paint: paint,
        coinPaint: coinPaint,
      );
    }
  }

  void _drawArmy(Canvas canvas, Size size, String type, Offset position) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = type == 'expansion' 
        ? (currentPosition == 'long' ? DuolingoTheme.duoGreen : DuolingoTheme.mediumGray)
        : (currentPosition == 'short' ? DuolingoTheme.duoRed : DuolingoTheme.mediumGray);

    // Draw shield/sword icon
    canvas.drawCircle(position, 25, paint);
    
    final iconPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = DuolingoTheme.white;
    
    if (type == 'expansion') {
      // Draw up arrow
      final path = Path();
      path.moveTo(position.dx, position.dy - 15);
      path.lineTo(position.dx - 10, position.dy - 5);
      path.lineTo(position.dx + 10, position.dy - 5);
      path.close();
      canvas.drawPath(path, iconPaint);
    } else {
      // Draw down arrow
      final path = Path();
      path.moveTo(position.dx, position.dy + 15);
      path.lineTo(position.dx - 10, position.dy + 5);
      path.lineTo(position.dx + 10, position.dy + 5);
      path.close();
      canvas.drawPath(path, iconPaint);
    }
  }

  void _drawMoneyFlow(Canvas canvas, Size size, {
    required Offset from,
    required Offset to,
    required Paint paint,
    required Paint coinPaint,
  }) {
    paint.color = DuolingoTheme.duoYellow;
    
    // Draw flowing line
    final path = Path();
    path.moveTo(from.dx, from.dy);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.3,
      to.dx, to.dy,
    );
    canvas.drawPath(path, paint);

    // Draw moving coins
    final numCoins = 3;
    for (int i = 0; i < numCoins; i++) {
      final progress = (animation + i * 0.3) % 1.0;
      final coinPosition = _getPointOnPath(path, progress);
      
      coinPaint.color = DuolingoTheme.duoYellow;
      canvas.drawCircle(coinPosition, 6, coinPaint);
      
      // Draw dollar sign
      final textPainter = TextPainter(
        text: TextSpan(
          text: '\$',
          style: TextStyle(
            color: DuolingoTheme.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(
        coinPosition.dx - textPainter.width / 2,
        coinPosition.dy - textPainter.height / 2,
      ));
    }
  }

  Offset _getPointOnPath(Path path, double progress) {
    final pathMetrics = path.computeMetrics();
    final pathMetric = pathMetrics.first;
    final tangent = pathMetric.getTangentForOffset(pathMetric.length * progress);
    return tangent?.position ?? Offset.zero;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class FundingHistoryPainter extends CustomPainter {
  final List<Map<String, dynamic>> history;

  FundingHistoryPainter({required this.history});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    // Draw axes
    paint.color = DuolingoTheme.mediumGray;
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );

    // Draw history line
    final path = Path();
    final maxRate = history.map((h) => (h['rate'] as double).abs()).reduce(math.max);
    
    for (int i = 0; i < history.length; i++) {
      final x = i * size.width / (history.length - 1);
      final rate = history[i]['rate'] as double;
      final y = size.height * 0.5 - (rate / maxRate) * size.height * 0.3;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Draw rate point
      fillPaint.color = rate > 0 ? DuolingoTheme.duoRed : DuolingoTheme.duoGreen;
      canvas.drawCircle(Offset(x, y), 3, fillPaint);
    }

    paint.color = DuolingoTheme.duoBlue;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}