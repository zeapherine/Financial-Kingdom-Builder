import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/config/duolingo_theme.dart';
import '../models/perpetual_position.dart';
import '../models/market_data.dart';

class SwipeTradingWidget extends StatefulWidget {
  final MarketData marketData;
  final double availableBalance;
  final Function(PositionSide side, double leverage, double size) onPositionOpen;
  final VoidCallback? onEducationTap;

  const SwipeTradingWidget({
    super.key,
    required this.marketData,
    required this.availableBalance,
    required this.onPositionOpen,
    this.onEducationTap,
  });

  @override
  State<SwipeTradingWidget> createState() => _SwipeTradingWidgetState();
}

class _SwipeTradingWidgetState extends State<SwipeTradingWidget>
    with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late AnimationController _pulseController;
  late Animation<double> _swipeAnimation;
  late Animation<double> _pulseAnimation;
  
  double _dragOffset = 0.0;
  bool _isDragging = false;
  double _selectedLeverage = 2.0;
  double _positionSize = 100.0;
  
  final double _swipeThreshold = 80.0;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _swipeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    HapticFeedback.lightImpact();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      _dragOffset = _dragOffset.clamp(-150.0, 150.0);
    });
    
    // Haptic feedback when approaching threshold
    if (_dragOffset.abs() > _swipeThreshold * 0.8) {
      HapticFeedback.selectionClick();
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_dragOffset.abs() > _swipeThreshold) {
      final side = _dragOffset < 0 ? PositionSide.long : PositionSide.short;
      _executePosition(side);
    } else {
      _resetSwipe();
    }
  }

  void _executePosition(PositionSide side) {
    HapticFeedback.heavyImpact();
    _swipeController.forward().then((_) {
      widget.onPositionOpen(side, _selectedLeverage, _positionSize);
      _resetSwipe();
    });
  }

  void _resetSwipe() {
    setState(() {
      _isDragging = false;
      _dragOffset = 0.0;
    });
    _swipeController.reset();
  }

  Color _getSwipeColor() {
    if (_dragOffset.abs() < _swipeThreshold) {
      return DuolingoTheme.mediumGray;
    }
    return _dragOffset < 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed;
  }

  String _getSwipeText() {
    if (_dragOffset.abs() < _swipeThreshold) {
      if (_dragOffset < -20) {
        return 'EXPAND TERRITORY (LONG)';
      } else if (_dragOffset > 20) {
        return 'DEFEND KINGDOM (SHORT)';
      }
      return 'SWIPE TO TRADE';
    }
    return _dragOffset < 0 ? 'RELEASE TO EXPAND!' : 'RELEASE TO DEFEND!';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(DuolingoTheme.spacingMd),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DuolingoTheme.lightGray,
              DuolingoTheme.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
          child: Column(
            children: [
              _buildMarketHeader(),
              const SizedBox(height: DuolingoTheme.spacingMd),
              _buildLeverageSelector(),
              const SizedBox(height: DuolingoTheme.spacingMd),
              _buildPositionSizeSelector(),
              const SizedBox(height: DuolingoTheme.spacingLg),
              _buildSwipeArea(),
              const SizedBox(height: DuolingoTheme.spacingMd),
              _buildEducationPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketHeader() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.marketData.kingdomPriceDescription,
            style: DuolingoTheme.h3.copyWith(
              color: DuolingoTheme.charcoal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Trend', widget.marketData.trendDirection),
              _buildStatCard('24h Change', '${widget.marketData.changePercent24h.toStringAsFixed(2)}%'),
              _buildStatCard('Funding', widget.marketData.fundingDescription.split(':')[1]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: DuolingoTheme.caption.copyWith(
            color: DuolingoTheme.darkGray,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: DuolingoTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildLeverageSelector() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.lightGray,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kingdom Force Multiplier: ${_selectedLeverage.toInt()}x',
            style: DuolingoTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Row(
            children: [2.0, 5.0, 10.0, 20.0].map((leverage) {
              final isSelected = _selectedLeverage == leverage;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLeverage = leverage;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? DuolingoTheme.duoGreen 
                          : DuolingoTheme.white,
                      borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                      border: Border.all(
                        color: isSelected 
                            ? DuolingoTheme.duoGreen 
                            : DuolingoTheme.mediumGray,
                      ),
                    ),
                    child: Text(
                      '${leverage.toInt()}x',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        color: isSelected 
                            ? DuolingoTheme.white 
                            : DuolingoTheme.charcoal,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionSizeSelector() {
    final maxSize = (widget.availableBalance * 0.1).clamp(10.0, 1000.0);
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.lightGray,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Army Size: \$${_positionSize.toStringAsFixed(0)}',
            style: DuolingoTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Slider(
            value: _positionSize,
            min: 10.0,
            max: maxSize,
            divisions: 20,
            activeColor: DuolingoTheme.duoGreen,
            onChanged: (value) {
              setState(() {
                _positionSize = value;
              });
            },
            onChangeEnd: (value) {
              HapticFeedback.selectionClick();
            },
          ),
          Text(
            'Risk: \$${(_positionSize / _selectedLeverage).toStringAsFixed(2)} • Max: \$${maxSize.toStringAsFixed(0)}',
            style: DuolingoTheme.caption.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeArea() {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_swipeAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _dragOffset),
            child: Transform.scale(
              scale: _isDragging ? 1.05 : _pulseAnimation.value,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getSwipeColor(),
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: _getSwipeColor().withValues(alpha: 0.3),
                      blurRadius: _isDragging ? 20 : 10,
                      spreadRadius: _isDragging ? 2 : 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _dragOffset < -20 
                          ? Icons.arrow_upward 
                          : _dragOffset > 20 
                          ? Icons.arrow_downward 
                          : Icons.swap_vert,
                      color: DuolingoTheme.white,
                      size: 32,
                    ),
                    const SizedBox(height: DuolingoTheme.spacingSm),
                    Text(
                      _getSwipeText(),
                      style: DuolingoTheme.bodyLarge.copyWith(
                        color: DuolingoTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_dragOffset.abs() < _swipeThreshold) ...[
                      const SizedBox(height: DuolingoTheme.spacingXs),
                      Text(
                        'Up: Long • Down: Short',
                        style: DuolingoTheme.caption.copyWith(
                          color: DuolingoTheme.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEducationPrompt() {
    return GestureDetector(
      onTap: widget.onEducationTap,
      child: Container(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        decoration: BoxDecoration(
          color: DuolingoTheme.duoYellow.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          border: Border.all(
            color: DuolingoTheme.duoYellow.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.school,
              color: DuolingoTheme.duoYellow,
              size: DuolingoTheme.iconMedium,
            ),
            const SizedBox(width: DuolingoTheme.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New to perpetual trading?',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DuolingoTheme.charcoal,
                    ),
                  ),
                  Text(
                    'Learn the kingdom way with our interactive courses',
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: DuolingoTheme.duoYellow,
              size: DuolingoTheme.iconSmall,
            ),
          ],
        ),
      ),
    );
  }
}