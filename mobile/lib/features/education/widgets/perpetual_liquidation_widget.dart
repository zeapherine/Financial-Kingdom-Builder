import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/config/duolingo_theme.dart';
import '../../../shared/widgets/duo_card.dart';

class PerpetualLiquidationWidget extends StatefulWidget {
  final double entryPrice;
  final double currentPrice;
  final int leverage;
  final String position;
  final double positionSize;

  const PerpetualLiquidationWidget({
    super.key,
    this.entryPrice = 40000.0,
    this.currentPrice = 39000.0,
    this.leverage = 10,
    this.position = 'long',
    this.positionSize = 1000.0,
  });

  @override
  State<PerpetualLiquidationWidget> createState() => _PerpetualLiquidationWidgetState();
}

class _PerpetualLiquidationWidgetState extends State<PerpetualLiquidationWidget>
    with TickerProviderStateMixin {
  late AnimationController _dangerController;
  late AnimationController _castleController;
  late Animation<double> _dangerAnimation;
  late Animation<double> _castleAnimation;
  late Animation<Color?> _dangerColorAnimation;

  double simulatedPrice = 40000.0;
  bool isSimulating = false;

  @override
  void initState() {
    super.initState();
    simulatedPrice = widget.currentPrice;
    
    _dangerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _castleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _dangerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dangerController,
      curve: Curves.easeInOut,
    ));

    _castleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _castleController,
      curve: Curves.elasticOut,
    ));

    _dangerColorAnimation = ColorTween(
      begin: DuolingoTheme.duoGreen,
      end: DuolingoTheme.duoRed,
    ).animate(_dangerController);

    _updateAnimations();
    _castleController.forward();
  }

  @override
  void dispose() {
    _dangerController.dispose();
    _castleController.dispose();
    super.dispose();
  }

  void _updateAnimations() {
    final riskLevel = _calculateRiskLevel();
    _dangerController.animateTo(riskLevel);
  }

  void _startPriceSimulation() {
    setState(() {
      isSimulating = !isSimulating;
    });
    
    if (isSimulating) {
      _simulatePrice();
    }
  }

  void _simulatePrice() {
    if (!isSimulating) return;
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && isSimulating) {
        setState(() {
          // Simulate price movement towards liquidation
          final liquidationPrice = _calculateLiquidationPrice();
          final direction = widget.position == 'long' ? -1 : 1;
          final volatility = 50 + math.Random().nextDouble() * 100;
          simulatedPrice += direction * volatility;
          
          // Add some random noise
          simulatedPrice += (math.Random().nextDouble() - 0.5) * 200;
          
          // Prevent going too far past liquidation
          if (widget.position == 'long' && simulatedPrice < liquidationPrice - 500) {
            simulatedPrice = liquidationPrice - 500;
          } else if (widget.position == 'short' && simulatedPrice > liquidationPrice + 500) {
            simulatedPrice = liquidationPrice + 500;
          }
        });
        
        _updateAnimations();
        _simulatePrice();
      }
    });
  }

  double _calculateLiquidationPrice() {
    if (widget.position == 'long') {
      return widget.entryPrice * (1 - 0.9 / widget.leverage);
    } else {
      return widget.entryPrice * (1 + 0.9 / widget.leverage);
    }
  }

  double _calculateRiskLevel() {
    final liquidationPrice = _calculateLiquidationPrice();
    final priceToUse = isSimulating ? simulatedPrice : widget.currentPrice;
    
    double riskLevel;
    if (widget.position == 'long') {
      final distanceToLiquidation = priceToUse - liquidationPrice;
      final totalDistance = widget.entryPrice - liquidationPrice;
      riskLevel = 1.0 - (distanceToLiquidation / totalDistance);
    } else {
      final distanceToLiquidation = liquidationPrice - priceToUse;
      final totalDistance = liquidationPrice - widget.entryPrice;
      riskLevel = 1.0 - (distanceToLiquidation / totalDistance);
    }
    
    return math.max(0.0, math.min(1.0, riskLevel));
  }

  double get _unrealizedPnL {
    final priceToUse = isSimulating ? simulatedPrice : widget.currentPrice;
    final priceDiff = widget.position == 'long' 
      ? priceToUse - widget.entryPrice
      : widget.entryPrice - priceToUse;
    return (priceDiff / widget.entryPrice) * widget.positionSize * widget.leverage;
  }

  bool get _isLiquidated {
    final riskLevel = _calculateRiskLevel();
    return riskLevel >= 0.99;
  }

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
                Icons.warning_amber,
                color: DuolingoTheme.duoOrange,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Kingdom Defense System',
                style: DuolingoTheme.h3.copyWith(
                  color: DuolingoTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Position Info
          _buildPositionInfo(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Castle Under Siege Visualization
          _buildCastleVisualization(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Risk Meter
          _buildRiskMeter(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Liquidation Calculator
          _buildLiquidationCalculator(),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Simulation Controls
          _buildSimulationControls(),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Kingdom Survival Tips
          _buildSurvivalTips(),
        ],
      ),
    );
  }

  Widget _buildPositionInfo() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DuolingoTheme.duoBlue.withValues(alpha: 0.1),
            DuolingoTheme.duoPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                widget.position == 'long' ? Icons.trending_up : Icons.trending_down,
                color: widget.position == 'long' ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Your ${widget.position == 'long' ? 'Expansion' : 'Defense'} Army',
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
              _buildInfoCard('Entry Price', '\$${widget.entryPrice.toStringAsFixed(0)}'),
              _buildInfoCard('Current Price', '\$${(isSimulating ? simulatedPrice : widget.currentPrice).toStringAsFixed(0)}'),
              _buildInfoCard('Leverage', '${widget.leverage}x'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: DuolingoTheme.bodySmall.copyWith(
            color: DuolingoTheme.darkGray,
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingXs),
        Text(
          value,
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildCastleVisualization() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            DuolingoTheme.duoBlue.withValues(alpha: 0.1),
            DuolingoTheme.lightGray.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_dangerAnimation, _castleAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: CastleSiegePainter(
              dangerLevel: _dangerAnimation.value,
              castleAnimation: _castleAnimation.value,
              isLiquidated: _isLiquidated,
            ),
            child: Container(),
          );
        },
      ),
    );
  }

  Widget _buildRiskMeter() {
    final riskLevel = _calculateRiskLevel();
    final riskPercentage = (riskLevel * 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.lightGray,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.mediumGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kingdom Under Siege:',
                style: DuolingoTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.charcoal,
                ),
              ),
              AnimatedBuilder(
                animation: _dangerColorAnimation,
                builder: (context, child) {
                  return Text(
                    '$riskPercentage%',
                    style: DuolingoTheme.h3.copyWith(
                      color: _dangerColorAnimation.value,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Risk Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
            child: Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: DuolingoTheme.mediumGray.withValues(alpha: 0.3),
              ),
              child: AnimatedBuilder(
                animation: _dangerAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _dangerAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DuolingoTheme.duoGreen,
                            DuolingoTheme.duoYellow,
                            DuolingoTheme.duoOrange,
                            DuolingoTheme.duoRed,
                          ],
                          stops: const [0.0, 0.5, 0.8, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          // Risk Level Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Safe',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.duoGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Danger',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.duoOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Liquidation',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.duoRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidationCalculator() {
    final liquidationPrice = _calculateLiquidationPrice();
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: _isLiquidated 
          ? DuolingoTheme.duoRed.withValues(alpha: 0.1)
          : DuolingoTheme.duoYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: _isLiquidated 
            ? DuolingoTheme.duoRed.withValues(alpha: 0.3)
            : DuolingoTheme.duoYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isLiquidated ? Icons.dangerous : Icons.calculate,
                color: _isLiquidated ? DuolingoTheme.duoRed : DuolingoTheme.duoYellow,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                _isLiquidated ? 'Kingdom Fallen!' : 'Battle Analysis',
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
                    'Liquidation Price:',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                  Text(
                    '\$${liquidationPrice.toStringAsFixed(0)}',
                    style: DuolingoTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: DuolingoTheme.duoRed,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Current P&L:',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                  Text(
                    '${_unrealizedPnL >= 0 ? '+' : ''}\$${_unrealizedPnL.toStringAsFixed(2)}',
                    style: DuolingoTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _unrealizedPnL >= 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (_isLiquidated) ...[
            const SizedBox(height: DuolingoTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(DuolingoTheme.spacingSm),
              decoration: BoxDecoration(
                color: DuolingoTheme.duoRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: DuolingoTheme.duoRed,
                    size: DuolingoTheme.iconSmall,
                  ),
                  const SizedBox(width: DuolingoTheme.spacingSm),
                  Expanded(
                    child: Text(
                      'Your position has been liquidated. The kingdom has fallen to protect remaining forces.',
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.duoRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimulationControls() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _startPriceSimulation,
        icon: Icon(
          isSimulating ? Icons.pause : Icons.play_arrow,
          color: DuolingoTheme.white,
        ),
        label: Text(
          isSimulating ? 'Stop Siege' : 'Simulate Siege',
          style: DuolingoTheme.bodyMedium.copyWith(
            color: DuolingoTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSimulating ? DuolingoTheme.duoRed : DuolingoTheme.duoBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: DuolingoTheme.spacingLg,
            vertical: DuolingoTheme.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildSurvivalTips() {
    final tips = _getSurvivalTips();
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.duoGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield,
                color: DuolingoTheme.duoGreen,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Kingdom Defense Tips:',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingXs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.star,
                  color: DuolingoTheme.duoGreen,
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
          )),
        ],
      ),
    );
  }

  List<String> _getSurvivalTips() {
    final riskLevel = _calculateRiskLevel();
    
    if (riskLevel < 0.3) {
      return [
        "Your kingdom is safe. Current defenses are strong.",
        "Monitor price movements and be ready to add reinforcements if needed.",
        "Consider taking partial profits to secure your gains.",
      ];
    } else if (riskLevel < 0.7) {
      return [
        "Your kingdom is under moderate threat. Stay vigilant.",
        "Consider reducing position size or adding margin to strengthen defenses.",
        "Set up alerts for price movements approaching liquidation zones.",
      ];
    } else {
      return [
        "URGENT: Your kingdom is in immediate danger!",
        "Add margin immediately or close the position to prevent total loss.",
        "Never risk more than you can afford to lose completely.",
        "Learn from this experience - use lower leverage in future battles.",
      ];
    }
  }
}

class CastleSiegePainter extends CustomPainter {
  final double dangerLevel;
  final double castleAnimation;
  final bool isLiquidated;

  CastleSiegePainter({
    required this.dangerLevel,
    required this.castleAnimation,
    required this.isLiquidated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw ground
    paint.color = DuolingoTheme.mediumGray.withValues(alpha: 0.3);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2),
      paint,
    );

    // Draw castle
    _drawCastle(canvas, size, paint);
    
    // Draw threats/attacks based on danger level
    if (dangerLevel > 0.1) {
      _drawThreats(canvas, size, paint);
    }
    
    // Draw explosion if liquidated
    if (isLiquidated) {
      _drawExplosion(canvas, size, paint);
    }
  }

  void _drawCastle(Canvas canvas, Size size, Paint paint) {
    final castleSize = castleAnimation;
    final centerX = size.width * 0.5;
    final groundY = size.height * 0.8;
    
    // Castle color based on danger level
    final castleColor = Color.lerp(
      DuolingoTheme.duoBlue,
      DuolingoTheme.duoRed,
      dangerLevel,
    )!;
    
    if (isLiquidated) {
      // Draw ruins
      paint.color = DuolingoTheme.darkGray;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(centerX, groundY - 20 * castleSize),
          width: 60 * castleSize,
          height: 20 * castleSize,
        ),
        paint,
      );
      return;
    }
    
    // Main castle wall
    paint.color = castleColor;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, groundY - 40 * castleSize),
        width: 80 * castleSize,
        height: 60 * castleSize,
      ),
      paint,
    );
    
    // Castle towers
    for (int i = 0; i < 3; i++) {
      final towerX = centerX + (i - 1) * 30 * castleSize;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(towerX, groundY - 55 * castleSize),
          width: 15 * castleSize,
          height: 30 * castleSize,
        ),
        paint,
      );
      
      // Tower flags
      paint.color = DuolingoTheme.duoYellow;
      canvas.drawCircle(
        Offset(towerX, groundY - 70 * castleSize),
        3 * castleSize,
        paint,
      );
    }
    
    // Castle gate
    paint.color = DuolingoTheme.darkGray;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, groundY - 25 * castleSize),
        width: 20 * castleSize,
        height: 30 * castleSize,
      ),
      paint,
    );
  }

  void _drawThreats(Canvas canvas, Size size, Paint paint) {
    final numThreats = (dangerLevel * 5).ceil();
    
    for (int i = 0; i < numThreats; i++) {
      final x = size.width * 0.1 + i * (size.width * 0.15);
      final y = size.height * 0.6 + math.sin(i.toDouble()) * 20;
      
      // Draw attacking arrows/projectiles
      paint.color = DuolingoTheme.duoRed;
      canvas.drawCircle(Offset(x, y), 4, paint);
      
      // Draw trajectory line
      paint.strokeWidth = 2;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(x - 20, y + 10),
        Offset(x, y),
        paint,
      );
      paint.style = PaintingStyle.fill;
    }
  }

  void _drawExplosion(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width * 0.5;
    final groundY = size.height * 0.8;
    
    // Draw explosion particles
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final radius = 30 + math.sin(angle * 3) * 10;
      final x = centerX + math.cos(angle) * radius;
      final y = groundY - 40 + math.sin(angle) * radius;
      
      paint.color = i % 2 == 0 ? DuolingoTheme.duoOrange : DuolingoTheme.duoYellow;
      canvas.drawCircle(Offset(x, y), 8, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}