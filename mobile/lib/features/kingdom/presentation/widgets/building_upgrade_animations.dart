import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/kingdom_state.dart';

/// Building Upgrade Animation System
/// Implements Transform and AnimatedContainer widgets for building upgrades
/// Creates visual feedback for building level progression
/// 
/// From /mobile/styles.json:
/// - Uses animation curves from animations.curves section
/// - Applies button press effects from animations.effects section
/// - Follows elevation values from elevation section

class BuildingUpgradeAnimation extends StatefulWidget {
  final Widget child;
  final int currentLevel;
  final int targetLevel;
  final bool isUpgrading;
  final VoidCallback? onUpgradeComplete;
  final KingdomBuilding building;

  const BuildingUpgradeAnimation({
    super.key,
    required this.child,
    required this.currentLevel,
    required this.targetLevel,
    this.isUpgrading = false,
    this.onUpgradeComplete,
    required this.building,
  });

  @override
  State<BuildingUpgradeAnimation> createState() => _BuildingUpgradeAnimationState();
}

class _BuildingUpgradeAnimationState extends State<BuildingUpgradeAnimation>
    with TickerProviderStateMixin {
  late AnimationController _upgradeController;
  late AnimationController _sparkleController;
  late AnimationController _bounceController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Color?> _glowColorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main upgrade animation controller
    _upgradeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Sparkle effect controller
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Bounce effect controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation with elastic effect
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _upgradeController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // Rotation animation for upgrade effect
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _upgradeController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    // Sparkle animation for magical effect
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeOut,
    ));

    // Bounce animation for final effect
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));

    // Glow color animation
    _glowColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: DuolingoTheme.duoYellow.withValues(alpha: 0.8),
    ).animate(CurvedAnimation(
      parent: _upgradeController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));
  }

  @override
  void didUpdateWidget(BuildingUpgradeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger upgrade animation when isUpgrading changes to true
    if (!oldWidget.isUpgrading && widget.isUpgrading) {
      _startUpgradeAnimation();
    }
  }

  @override
  void dispose() {
    _upgradeController.dispose();
    _sparkleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _startUpgradeAnimation() async {
    // Start sparkle effect
    _sparkleController.forward();
    
    // Start main upgrade animation
    await _upgradeController.forward();
    
    // Start bounce effect for completion
    await _bounceController.forward();
    
    // Reset animations
    await _upgradeController.reverse();
    _sparkleController.reset();
    _bounceController.reset();
    
    // Notify completion
    if (widget.onUpgradeComplete != null) {
      widget.onUpgradeComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main building with upgrade animations
        AnimatedBuilder(
          animation: Listenable.merge([
            _upgradeController,
            _bounceController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value * (1.0 + 0.1 * _bounceAnimation.value),
              child: Transform.rotate(
                angle: _rotationAnimation.value * math.pi,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: _glowColorAnimation.value ?? Colors.transparent,
                        blurRadius: 20 * _upgradeController.value,
                        spreadRadius: 5 * _upgradeController.value,
                      ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
        
        // Sparkle effects during upgrade
        if (widget.isUpgrading)
          AnimatedBuilder(
            animation: _sparkleAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _BuildingSparklesPainter(
                    progress: _sparkleAnimation.value,
                    building: widget.building,
                  ),
                ),
              );
            },
          ),
        
        // Level indicator with animated container
        Positioned(
          top: 4,
          right: 4,
          child: _BuildingLevelIndicator(
            currentLevel: widget.currentLevel,
            targetLevel: widget.targetLevel,
            isUpgrading: widget.isUpgrading,
          ),
        ),
      ],
    );
  }
}

/// Animated level indicator for buildings
class _BuildingLevelIndicator extends StatefulWidget {
  final int currentLevel;
  final int targetLevel;
  final bool isUpgrading;

  const _BuildingLevelIndicator({
    required this.currentLevel,
    required this.targetLevel,
    required this.isUpgrading,
  });

  @override
  State<_BuildingLevelIndicator> createState() => _BuildingLevelIndicatorState();
}

class _BuildingLevelIndicatorState extends State<_BuildingLevelIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _levelController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _levelController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: DuolingoTheme.duoYellow,
      end: DuolingoTheme.duoOrange,
    ).animate(_levelController);

    if (widget.isUpgrading) {
      _levelController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_BuildingLevelIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUpgrading && !oldWidget.isUpgrading) {
      _levelController.repeat(reverse: true);
    } else if (!widget.isUpgrading && oldWidget.isUpgrading) {
      _levelController.stop();
      _levelController.reset();
    }
  }

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentLevel == 0) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _levelController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(
              horizontal: DuolingoTheme.spacingSm,
              vertical: DuolingoTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: widget.isUpgrading 
                  ? _colorAnimation.value 
                  : DuolingoTheme.duoYellow,
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
              border: Border.all(
                color: DuolingoTheme.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: DuolingoTheme.charcoal.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.isUpgrading 
                  ? '${widget.currentLevel}→${widget.targetLevel}'
                  : '${widget.currentLevel}',
              style: DuolingoTheme.caption.copyWith(
                color: DuolingoTheme.white,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Building expansion animation for territory growth
class BuildingExpansionAnimation extends StatefulWidget {
  final Widget child;
  final bool isExpanding;
  final VoidCallback? onExpansionComplete;

  const BuildingExpansionAnimation({
    super.key,
    required this.child,
    this.isExpanding = false,
    this.onExpansionComplete,
  });

  @override
  State<BuildingExpansionAnimation> createState() => _BuildingExpansionAnimationState();
}

class _BuildingExpansionAnimationState extends State<BuildingExpansionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _expansionController;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _expansionController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _heightAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _expansionController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

  }

  @override
  void didUpdateWidget(BuildingExpansionAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isExpanding && widget.isExpanding) {
      _startExpansionAnimation();
    }
  }

  @override
  void dispose() {
    _expansionController.dispose();
    super.dispose();
  }

  Future<void> _startExpansionAnimation() async {
    await _expansionController.forward();
    await _expansionController.reverse();
    
    if (widget.onExpansionComplete != null) {
      widget.onExpansionComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expansionController,
      builder: (context, child) {
        return Transform.scale(
          scaleX: _widthAnimation.value,
          scaleY: _heightAnimation.value,
          child: Opacity(
            opacity: 1.0,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Custom painter for building sparkle effects
class _BuildingSparklesPainter extends CustomPainter {
  final double progress;
  final KingdomBuilding building;

  _BuildingSparklesPainter({
    required this.progress,
    required this.building,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sparkleCount = 8;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = math.min(size.width, size.height) * 0.4;

    for (int i = 0; i < sparkleCount; i++) {
      final angle = (i / sparkleCount) * 2 * math.pi;
      final radius = progress * maxRadius;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      
      _drawSparkle(
        canvas,
        Offset(x, y),
        4.0 * (1.0 - progress) + 1.0,
        DuolingoTheme.duoYellow.withValues(alpha: 0.8 * (1.0 - progress)),
      );
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw 4-pointed star
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.3);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx + size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx - size, center.dy);
    path.lineTo(center.dx - size * 0.3, center.dy - size * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}