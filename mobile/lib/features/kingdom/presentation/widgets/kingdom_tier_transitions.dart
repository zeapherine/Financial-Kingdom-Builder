import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/kingdom_state.dart';

/// Kingdom Tier Transition System
/// Handles smooth transitions between kingdom progression stages
/// Implements hero animations and tier upgrade effects
/// 
/// From /mobile/styles.json:
/// - Uses animation duration from animations.duration section
/// - Applies effects from animations.effects section
/// - Follows gamification elements styling

class KingdomTierTransition extends StatefulWidget {
  final KingdomTier currentTier;
  final KingdomTier? targetTier;
  final Widget child;
  final bool isTransitioning;
  final VoidCallback? onTransitionComplete;

  const KingdomTierTransition({
    super.key,
    required this.currentTier,
    this.targetTier,
    required this.child,
    this.isTransitioning = false,
    this.onTransitionComplete,
  });

  @override
  State<KingdomTierTransition> createState() => _KingdomTierTransitionState();
}

class _KingdomTierTransitionState extends State<KingdomTierTransition>
    with TickerProviderStateMixin {
  late AnimationController _tierUpgradeController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Tier upgrade animation controller
    _tierUpgradeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Glow effect controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Particle effect controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Scale animation for tier upgrade
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _tierUpgradeController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    // Fade animation for smooth transition
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _tierUpgradeController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
    ));

    // Glow animation for tier upgrade effect
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Particle animation for celebration effect
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(KingdomTierTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger transition when isTransitioning changes to true
    if (!oldWidget.isTransitioning && widget.isTransitioning) {
      _startTierTransition();
    }
  }

  @override
  void dispose() {
    _tierUpgradeController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _startTierTransition() async {
    // Start glow effect
    _glowController.forward();
    
    // Start particle effect
    _particleController.forward();
    
    // Start main tier upgrade animation
    await _tierUpgradeController.forward();
    
    // Reset animations
    await _tierUpgradeController.reverse();
    _glowController.reset();
    _particleController.reset();
    
    // Notify completion
    if (widget.onTransitionComplete != null) {
      widget.onTransitionComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main child widget
        AnimatedBuilder(
          animation: _tierUpgradeController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: 1.0 - _fadeAnimation.value,
                child: widget.child,
              ),
            );
          },
        ),
        
        // Glow effect during transition
        if (widget.isTransitioning)
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: _getTierColor(widget.targetTier ?? widget.currentTier)
                            .withValues(alpha: 0.6 * _glowAnimation.value),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 10 * _glowAnimation.value,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        
        // Particle effects during transition
        if (widget.isTransitioning)
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _TierUpgradeParticlePainter(
                    progress: _particleAnimation.value,
                    tierColor: _getTierColor(widget.targetTier ?? widget.currentTier),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Color _getTierColor(KingdomTier tier) {
    switch (tier) {
      case KingdomTier.village:
        return DuolingoTheme.duoGreen;
      case KingdomTier.town:
        return DuolingoTheme.duoBlue;
      case KingdomTier.city:
        return DuolingoTheme.duoPurple;
      case KingdomTier.kingdom:
        return DuolingoTheme.duoYellow;
    }
  }
}

/// Hero transition widget for building upgrades
class BuildingHeroTransition extends StatelessWidget {
  final String heroTag;
  final Widget child;
  final KingdomBuilding building;
  final KingdomTier tier;

  const BuildingHeroTransition({
    super.key,
    required this.heroTag,
    required this.child,
    required this.building,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: '${heroTag}_${building.name}_${tier.name}',
      flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (0.3 * animation.value),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: DuolingoTheme.duoYellow.withValues(alpha: 0.8 * animation.value),
                      blurRadius: 20 * animation.value,
                      spreadRadius: 5 * animation.value,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: toContext.widget,
        );
      },
      child: child,
    );
  }
}

/// Smooth transition between tier progression stages
class TierProgressionIndicator extends StatefulWidget {
  final KingdomTier currentTier;
  final double progress;
  final bool isUpgrading;

  const TierProgressionIndicator({
    super.key,
    required this.currentTier,
    required this.progress,
    this.isUpgrading = false,
  });

  @override
  State<TierProgressionIndicator> createState() => _TierProgressionIndicatorState();
}

class _TierProgressionIndicatorState extends State<TierProgressionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));
    _progressController.forward();
  }

  @override
  void didUpdateWidget(TierProgressionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOut,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        children: [
          // Tier name and progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.currentTier.name.toUpperCase()} STAGE',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: DuolingoTheme.charcoal,
                ),
              ),
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: DuolingoTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          // Animated progress bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 12,
                decoration: BoxDecoration(
                  color: DuolingoTheme.lightGray,
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTierColor(widget.currentTier),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Next tier indicator
          if (widget.progress < 1.0) ...[
            const SizedBox(height: DuolingoTheme.spacingXs),
            Text(
              'Next: ${_getNextTier(widget.currentTier).name.toUpperCase()}',
              style: DuolingoTheme.caption.copyWith(
                color: DuolingoTheme.mediumGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTierColor(KingdomTier tier) {
    switch (tier) {
      case KingdomTier.village:
        return DuolingoTheme.duoGreen;
      case KingdomTier.town:
        return DuolingoTheme.duoBlue;
      case KingdomTier.city:
        return DuolingoTheme.duoPurple;
      case KingdomTier.kingdom:
        return DuolingoTheme.duoYellow;
    }
  }

  KingdomTier _getNextTier(KingdomTier tier) {
    switch (tier) {
      case KingdomTier.village:
        return KingdomTier.town;
      case KingdomTier.town:
        return KingdomTier.city;
      case KingdomTier.city:
        return KingdomTier.kingdom;
      case KingdomTier.kingdom:
        return KingdomTier.kingdom; // Max tier
    }
  }
}

/// Custom painter for tier upgrade particle effects
class _TierUpgradeParticlePainter extends CustomPainter {
  final double progress;
  final Color tierColor;

  _TierUpgradeParticlePainter({
    required this.progress,
    required this.tierColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tierColor.withValues(alpha: 0.8 * (1.0 - progress))
      ..style = PaintingStyle.fill;

    final particleCount = 12;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = size.width * 0.6;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * 3.14159;
      final radius = progress * maxRadius;
      final x = centerX + radius * 0.8 * math.cos(angle) * (progress * 2 - 1);
      final y = centerY + radius * 0.8 * math.sin(angle) * (progress * 2 - 1);
      
      final particleRadius = (4.0 * (1.0 - progress)) + (2.0 * progress);
      
      canvas.drawCircle(
        Offset(x, y),
        particleRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}