import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/kingdom_state.dart';

/// Territory Expansion Visual Effects
/// Implements particle-like animations for territory growth
/// Creates expanding circles, particle bursts, and boundary effects
/// 
/// From /mobile/styles.json:
/// - Uses gamification colors from gamificationElements section
/// - Applies animation curves from animations.curves section
/// - Follows spacing values for particle positioning

class TerritoryExpansionEffect extends StatefulWidget {
  final Widget child;
  final bool isExpanding;
  final KingdomTier tier;
  final VoidCallback? onExpansionComplete;
  final double expansionRadius;

  const TerritoryExpansionEffect({
    super.key,
    required this.child,
    this.isExpanding = false,
    required this.tier,
    this.onExpansionComplete,
    this.expansionRadius = 100.0,
  });

  @override
  State<TerritoryExpansionEffect> createState() => _TerritoryExpansionEffectState();
}

class _TerritoryExpansionEffectState extends State<TerritoryExpansionEffect>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _particleController;
  late AnimationController _boundaryController;
  
  late Animation<double> _radiusAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _boundaryAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main expansion animation
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Particle burst animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Boundary pulse animation
    _boundaryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Radius expansion animation
    _radiusAnimation = Tween<double>(
      begin: 0.0,
      end: widget.expansionRadius,
    ).animate(CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeOut,
    ));

    // Particle burst animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));

    // Boundary pulse animation
    _boundaryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _boundaryController,
      curve: Curves.elasticOut,
    ));

    // Opacity fade animation
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _expansionController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    ));
  }

  @override
  void didUpdateWidget(TerritoryExpansionEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isExpanding && widget.isExpanding) {
      _startExpansionEffect();
    }
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _particleController.dispose();
    _boundaryController.dispose();
    super.dispose();
  }

  Future<void> _startExpansionEffect() async {
    // Start all animations simultaneously
    _expansionController.forward();
    _particleController.forward();
    _boundaryController.repeat(reverse: true);
    
    // Wait for main animation to complete
    await _expansionController.forward();
    
    // Stop boundary animation
    _boundaryController.stop();
    
    // Reset all animations
    _expansionController.reset();
    _particleController.reset();
    _boundaryController.reset();
    
    // Notify completion
    if (widget.onExpansionComplete != null) {
      widget.onExpansionComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Territory expansion rings
        if (widget.isExpanding)
          AnimatedBuilder(
            animation: _expansionController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _TerritoryRingsPainter(
                    radius: _radiusAnimation.value,
                    opacity: 1.0 - _opacityAnimation.value,
                    tier: widget.tier,
                  ),
                ),
              );
            },
          ),
        
        // Main child widget
        widget.child,
        
        // Particle effects
        if (widget.isExpanding)
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _TerritoryParticlesPainter(
                    progress: _particleAnimation.value,
                    tier: widget.tier,
                    maxRadius: widget.expansionRadius,
                  ),
                ),
              );
            },
          ),
        
        // Boundary pulse effects
        if (widget.isExpanding)
          AnimatedBuilder(
            animation: _boundaryController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _BoundaryPulsePainter(
                    pulse: _boundaryAnimation.value,
                    tier: widget.tier,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Territory expansion indicator with animated boundaries
class TerritoryBoundaryIndicator extends StatefulWidget {
  final KingdomTier tier;
  final double size;
  final bool isActive;

  const TerritoryBoundaryIndicator({
    super.key,
    required this.tier,
    this.size = 200.0,
    this.isActive = false,
  });

  @override
  State<TerritoryBoundaryIndicator> createState() => _TerritoryBoundaryIndicatorState();
}

class _TerritoryBoundaryIndicatorState extends State<TerritoryBoundaryIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TerritoryBoundaryIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getTierColor(widget.tier).withValues(alpha: 0.6),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getTierColor(widget.tier).withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
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

/// Particle burst effect for territory expansion moments
class TerritoryExpansionBurst extends StatefulWidget {
  final bool shouldTrigger;
  final KingdomTier tier;
  final VoidCallback? onComplete;

  const TerritoryExpansionBurst({
    super.key,
    this.shouldTrigger = false,
    required this.tier,
    this.onComplete,
  });

  @override
  State<TerritoryExpansionBurst> createState() => _TerritoryExpansionBurstState();
}

class _TerritoryExpansionBurstState extends State<TerritoryExpansionBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _burstController;
  late Animation<double> _burstAnimation;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _burstAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _burstController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(TerritoryExpansionBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldTrigger && !oldWidget.shouldTrigger) {
      _triggerBurst();
    }
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  Future<void> _triggerBurst() async {
    await _burstController.forward();
    _burstController.reset();
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _burstAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: _ExpansionBurstPainter(
            progress: _burstAnimation.value,
            tier: widget.tier,
          ),
        );
      },
    );
  }
}

/// Custom painter for territory expansion rings
class _TerritoryRingsPainter extends CustomPainter {
  final double radius;
  final double opacity;
  final KingdomTier tier;

  _TerritoryRingsPainter({
    required this.radius,
    required this.opacity,
    required this.tier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tierColor = _getTierColor(tier);
    
    // Draw multiple expanding rings
    for (int i = 0; i < 3; i++) {
      final ringRadius = radius * (0.3 + i * 0.35);
      final ringOpacity = opacity * (1.0 - i * 0.3);
      
      final paint = Paint()
        ..color = tierColor.withValues(alpha: ringOpacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(center, ringRadius, paint);
    }
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for territory particle effects
class _TerritoryParticlesPainter extends CustomPainter {
  final double progress;
  final KingdomTier tier;
  final double maxRadius;

  _TerritoryParticlesPainter({
    required this.progress,
    required this.tier,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tierColor = _getTierColor(tier);
    final particleCount = 16;
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = progress * maxRadius * 0.8;
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      final particleSize = 4.0 * (1.0 - progress) + 1.0;
      final particleOpacity = (1.0 - progress) * 0.8;
      
      final paint = Paint()
        ..color = tierColor.withValues(alpha: particleOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), particleSize, paint);
      
      // Add trailing effect
      if (progress > 0.3) {
        final trailLength = 10.0 * progress;
        final trailStart = Offset(
          x - trailLength * math.cos(angle),
          y - trailLength * math.sin(angle),
        );
        
        final trailPaint = Paint()
          ..color = tierColor.withValues(alpha: particleOpacity * 0.5)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(trailStart, Offset(x, y), trailPaint);
      }
    }
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for boundary pulse effects
class _BoundaryPulsePainter extends CustomPainter {
  final double pulse;
  final KingdomTier tier;

  _BoundaryPulsePainter({
    required this.pulse,
    required this.tier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tierColor = _getTierColor(tier);
    final baseRadius = math.min(size.width, size.height) * 0.4;
    final pulseRadius = baseRadius * (1.0 + pulse * 0.2);
    
    final paint = Paint()
      ..color = tierColor.withValues(alpha: 0.3 * (1.0 - pulse))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawCircle(center, pulseRadius, paint);
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for expansion burst effects
class _ExpansionBurstPainter extends CustomPainter {
  final double progress;
  final KingdomTier tier;

  _ExpansionBurstPainter({
    required this.progress,
    required this.tier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tierColor = _getTierColor(tier);
    final rayCount = 12;
    
    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * math.pi;
      final rayLength = progress * size.width * 0.4;
      final rayWidth = 4.0 * (1.0 - progress);
      
      final startPoint = Offset(
        center.dx + (rayLength * 0.2) * math.cos(angle),
        center.dy + (rayLength * 0.2) * math.sin(angle),
      );
      
      final endPoint = Offset(
        center.dx + rayLength * math.cos(angle),
        center.dy + rayLength * math.sin(angle),
      );
      
      final paint = Paint()
        ..color = tierColor.withValues(alpha: 0.8 * (1.0 - progress))
        ..strokeWidth = rayWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(startPoint, endPoint, paint);
    }
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}