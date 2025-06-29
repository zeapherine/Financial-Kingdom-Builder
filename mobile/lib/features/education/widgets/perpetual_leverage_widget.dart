import 'package:flutter/material.dart';
import '../../../core/config/duolingo_theme.dart';
import '../../../shared/widgets/duo_card.dart';

class PerpetualLeverageWidget extends StatefulWidget {
  final int selectedLeverage;
  final double positionSize;
  final double priceChange;
  final VoidCallback? onLeverageChanged;

  const PerpetualLeverageWidget({
    super.key,
    this.selectedLeverage = 1,
    this.positionSize = 1000.0,
    this.priceChange = 10.0,
    this.onLeverageChanged,
  });

  @override
  State<PerpetualLeverageWidget> createState() => _PerpetualLeverageWidgetState();
}

class _PerpetualLeverageWidgetState extends State<PerpetualLeverageWidget>
    with TickerProviderStateMixin {
  late AnimationController _armyController;
  late AnimationController _goldController;
  late Animation<double> _armyAnimation;
  late Animation<double> _goldAnimation;

  final List<int> leverageOptions = [1, 2, 5, 10, 20];
  late int currentLeverage;

  @override
  void initState() {
    super.initState();
    currentLeverage = widget.selectedLeverage;
    
    _armyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _goldController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _armyAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _armyController,
      curve: Curves.elasticOut,
    ));

    _goldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _goldController,
      curve: Curves.bounceOut,
    ));

    _armyController.forward();
  }

  @override
  void dispose() {
    _armyController.dispose();
    _goldController.dispose();
    super.dispose();
  }

  void _updateLeverage(int newLeverage) {
    setState(() {
      currentLeverage = newLeverage;
    });
    
    _armyController.reset();
    _goldController.reset();
    _armyController.forward();
    
    // Trigger gold animation after army animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _goldController.forward();
      }
    });
    
    widget.onLeverageChanged?.call();
  }

  double get _controlledValue => widget.positionSize * currentLeverage;
  double get _profitLoss => (_controlledValue * widget.priceChange / 100);
  bool get _isProfit => _profitLoss > 0;

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
                Icons.military_tech,
                color: DuolingoTheme.duoYellow,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Army Amplification System',
                style: DuolingoTheme.h3.copyWith(
                  color: DuolingoTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Leverage Selector
          _buildLeverageSelector(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Army Visualization
          _buildArmyVisualization(),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Impact Calculator
          _buildImpactCalculator(),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Kingdom Wisdom
          _buildKingdomWisdom(),
        ],
      ),
    );
  }

  Widget _buildLeverageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Army Multiplier:',
          style: DuolingoTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.charcoal,
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingSm),
        Wrap(
          spacing: DuolingoTheme.spacingSm,
          children: leverageOptions.map((leverage) {
            final isSelected = leverage == currentLeverage;
            return GestureDetector(
              onTap: () => _updateLeverage(leverage),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: DuolingoTheme.spacingMd,
                  vertical: DuolingoTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? DuolingoTheme.duoGreen : DuolingoTheme.lightGray,
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  border: Border.all(
                    color: isSelected ? DuolingoTheme.duoGreen : DuolingoTheme.mediumGray,
                    width: 2,
                  ),
                  boxShadow: isSelected ? DuolingoTheme.cardShadow : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${leverage}x',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        color: isSelected ? DuolingoTheme.white : DuolingoTheme.charcoal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: DuolingoTheme.spacingXs),
                    Icon(
                      _getLeverageIcon(leverage),
                      color: isSelected ? DuolingoTheme.white : DuolingoTheme.duoGreen,
                      size: DuolingoTheme.iconSmall,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildArmyVisualization() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DuolingoTheme.duoBlue.withValues(alpha: 0.1),
            DuolingoTheme.duoGreen.withValues(alpha: 0.1),
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
          Text(
            'Your Kingdom Army',
            style: DuolingoTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: DuolingoTheme.charcoal,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Original Army (1x)
          Row(
            children: [
              const Icon(
                Icons.person,
                color: DuolingoTheme.duoYellow,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Your Gold: \$${widget.positionSize.toStringAsFixed(0)}',
                style: DuolingoTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          // Amplified Army
          AnimatedBuilder(
            animation: _armyAnimation,
            builder: (context, child) {
              return Row(
                children: [
                  ...List.generate(
                    (currentLeverage * _armyAnimation.value).ceil(),
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Transform.scale(
                        scale: _armyAnimation.value,
                        child: const Icon(
                          Icons.shield,
                          color: DuolingoTheme.duoGreen,
                          size: DuolingoTheme.iconMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DuolingoTheme.spacingSm),
                  Text(
                    'Army Controls: \$${(_controlledValue * _armyAnimation.value).toStringAsFixed(0)}',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DuolingoTheme.duoGreen,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCalculator() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: _isProfit 
          ? DuolingoTheme.duoGreen.withValues(alpha: 0.1)
          : DuolingoTheme.duoRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: _isProfit 
            ? DuolingoTheme.duoGreen.withValues(alpha: 0.3)
            : DuolingoTheme.duoRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isProfit ? Icons.trending_up : Icons.trending_down,
                color: _isProfit ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                size: DuolingoTheme.iconMedium,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Battle Outcome: ${widget.priceChange > 0 ? '+' : ''}${widget.priceChange.toStringAsFixed(1)}%',
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
                    'Without Leverage (1x):',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                  Text(
                    '\$${(widget.positionSize * widget.priceChange / 100).toStringAsFixed(2)}',
                    style: DuolingoTheme.bodyMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'With ${currentLeverage}x Leverage:',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _goldController,
                    builder: (context, child) {
                      return Text(
                        '\$${(_profitLoss * _goldAnimation.value).toStringAsFixed(2)}',
                        style: DuolingoTheme.h3.copyWith(
                          color: _isProfit ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKingdomWisdom() {
    final wisdom = _getKingdomWisdom(currentLeverage);
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
      child: Row(
        children: [
          const Icon(
            Icons.auto_stories,
            color: DuolingoTheme.duoYellow,
            size: DuolingoTheme.iconMedium,
          ),
          const SizedBox(width: DuolingoTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kingdom Wisdom:',
                  style: DuolingoTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DuolingoTheme.charcoal,
                  ),
                ),
                const SizedBox(height: DuolingoTheme.spacingXs),
                Text(
                  wisdom,
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: DuolingoTheme.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLeverageIcon(int leverage) {
    switch (leverage) {
      case 1:
        return Icons.security;
      case 2:
        return Icons.trending_up;
      case 5:
        return Icons.rocket_launch;
      case 10:
        return Icons.flash_on;
      case 20:
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getKingdomWisdom(int leverage) {
    switch (leverage) {
      case 1:
        return "The conservative path - your army fights with its own strength. Slow but steady wins many battles.";
      case 2:
        return "A balanced approach - doubling your army's impact while keeping risk manageable. Perfect for growing kingdoms.";
      case 5:
        return "Bold expansion strategy - 5x the impact means 5x the rewards and risks. Use wisely in favorable conditions.";
      case 10:
        return "High-risk, high-reward warfare - 10x leverage can bring great victories or crushing defeats. Only for experienced generals.";
      case 20:
        return "Extreme battlefield tactics - maximum amplification with maximum danger. One wrong move can devastate your kingdom.";
      default:
        return "Every lever has its place in a ruler's arsenal. Choose based on your kingdom's strength and the battle ahead.";
    }
  }
}