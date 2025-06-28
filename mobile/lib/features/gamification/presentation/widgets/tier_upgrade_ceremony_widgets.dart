import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../kingdom/domain/models/kingdom_state.dart';

/// Tier upgrade ceremony widget with Duolingo-inspired celebrations
class TierUpgradeCeremonyWidget extends StatefulWidget {
  final KingdomTier fromTier;
  final KingdomTier toTier;
  final int xpEarned;
  final List<String> unlockedFeatures;
  final VoidCallback onContinue;

  const TierUpgradeCeremonyWidget({
    super.key,
    required this.fromTier,
    required this.toTier,
    required this.xpEarned,
    required this.unlockedFeatures,
    required this.onContinue,
  });

  @override
  State<TierUpgradeCeremonyWidget> createState() => _TierUpgradeCeremonyWidgetState();
}

class _TierUpgradeCeremonyWidgetState extends State<TierUpgradeCeremonyWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _confettiController;
  late AnimationController _crownController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _crownRotation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCeremony();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _crownController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _crownRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _crownController,
      curve: Curves.elasticOut,
    ));
  }

  void _startCeremony() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _mainController.forward();
      _confettiController.forward();
      _crownController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _confettiController.dispose();
    _crownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // Confetti background
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) => CustomPaint(
              painter: ConfettiPainter(_confettiController.value),
              size: Size.infinite,
            ),
          ),
          
          // Main ceremony content
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: DuolingoTheme.white,
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Crown animation
                      AnimatedBuilder(
                        animation: _crownController,
                        builder: (context, child) => Transform.rotate(
                          angle: _crownRotation.value * 0.1,
                          child: TierCrownWidget(
                            tier: widget.toTier,
                            size: 120,
                            animate: true,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Congratulations text
                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: Text(
                          'Congratulations!',
                          style: DuolingoTheme.h1.copyWith(
                            color: DuolingoTheme.duoGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tier advancement text
                      Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                'You\'ve advanced to',
                                style: DuolingoTheme.bodyLarge.copyWith(
                                  color: DuolingoTheme.darkGray,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getTierDisplayName(widget.toTier),
                                style: DuolingoTheme.h2.copyWith(
                                  color: DuolingoTheme.duoGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // XP earned
                      if (widget.xpEarned > 0)
                        Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: DuolingoTheme.duoYellow,
                              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: DuolingoTheme.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+${widget.xpEarned} XP',
                                  style: DuolingoTheme.bodyMedium.copyWith(
                                    color: DuolingoTheme.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Unlocked features
                      if (widget.unlockedFeatures.isNotEmpty)
                        Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                'New Features Unlocked:',
                                style: DuolingoTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...widget.unlockedFeatures.map((feature) => 
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: DuolingoTheme.duoGreen,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _formatFeatureName(feature),
                                          style: DuolingoTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Continue button
                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DuolingoTheme.duoGreen,
                              foregroundColor: DuolingoTheme.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Continue',
                              style: DuolingoTheme.button.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTierDisplayName(KingdomTier tier) {
    switch (tier) {
      case KingdomTier.village:
        return 'Village Foundations';
      case KingdomTier.town:
        return 'Town Development';
      case KingdomTier.city:
        return 'City Expansion';
      case KingdomTier.kingdom:
        return 'Kingdom Mastery';
    }
  }

  String _formatFeatureName(String feature) {
    return feature
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

/// Tier-specific crown widget with animations
class TierCrownWidget extends StatelessWidget {
  final KingdomTier tier;
  final double size;
  final bool animate;

  const TierCrownWidget({
    super.key,
    required this.tier,
    this.size = 80,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CrownPainter(tier, animate),
      size: Size(size, size * 0.8),
    );
  }
}

/// Custom painter for tier-specific crowns
class CrownPainter extends CustomPainter {
  final KingdomTier tier;
  final bool animate;

  CrownPainter(this.tier, this.animate);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Crown base color based on tier
    final Color crownColor = _getTierColor(tier);
    paint.color = crownColor;

    // Draw crown shape
    final Path crownPath = Path();
    final double width = size.width;
    final double height = size.height;
    
    // Crown base
    crownPath.moveTo(width * 0.1, height * 0.8);
    crownPath.lineTo(width * 0.9, height * 0.8);
    crownPath.lineTo(width * 0.85, height);
    crownPath.lineTo(width * 0.15, height);
    crownPath.close();
    
    // Crown peaks based on tier
    switch (tier) {
      case KingdomTier.village:
        // Simple 3-peak crown
        crownPath.moveTo(width * 0.1, height * 0.8);
        crownPath.lineTo(width * 0.2, height * 0.4);
        crownPath.lineTo(width * 0.35, height * 0.6);
        crownPath.lineTo(width * 0.5, height * 0.2);
        crownPath.lineTo(width * 0.65, height * 0.6);
        crownPath.lineTo(width * 0.8, height * 0.4);
        crownPath.lineTo(width * 0.9, height * 0.8);
        break;
      
      case KingdomTier.town:
        // 5-peak crown with decorations
        crownPath.moveTo(width * 0.1, height * 0.8);
        crownPath.lineTo(width * 0.15, height * 0.5);
        crownPath.lineTo(width * 0.25, height * 0.6);
        crownPath.lineTo(width * 0.35, height * 0.3);
        crownPath.lineTo(width * 0.45, height * 0.5);
        crownPath.lineTo(width * 0.5, height * 0.1);
        crownPath.lineTo(width * 0.55, height * 0.5);
        crownPath.lineTo(width * 0.65, height * 0.3);
        crownPath.lineTo(width * 0.75, height * 0.6);
        crownPath.lineTo(width * 0.85, height * 0.5);
        crownPath.lineTo(width * 0.9, height * 0.8);
        break;
      
      case KingdomTier.city:
        // Ornate crown with curved elements
        crownPath.moveTo(width * 0.1, height * 0.8);
        crownPath.quadraticBezierTo(width * 0.2, height * 0.3, width * 0.3, height * 0.5);
        crownPath.quadraticBezierTo(width * 0.4, height * 0.1, width * 0.5, height * 0.05);
        crownPath.quadraticBezierTo(width * 0.6, height * 0.1, width * 0.7, height * 0.5);
        crownPath.quadraticBezierTo(width * 0.8, height * 0.3, width * 0.9, height * 0.8);
        break;
      
      case KingdomTier.kingdom:
        // Royal crown with gems
        crownPath.moveTo(width * 0.1, height * 0.8);
        crownPath.lineTo(width * 0.12, height * 0.4);
        crownPath.quadraticBezierTo(width * 0.25, height * 0.1, width * 0.35, height * 0.4);
        crownPath.lineTo(width * 0.4, height * 0.15);
        crownPath.lineTo(width * 0.5, height * 0.05);
        crownPath.lineTo(width * 0.6, height * 0.15);
        crownPath.lineTo(width * 0.65, height * 0.4);
        crownPath.quadraticBezierTo(width * 0.75, height * 0.1, width * 0.88, height * 0.4);
        crownPath.lineTo(width * 0.9, height * 0.8);
        break;
    }
    
    canvas.drawPath(crownPath, paint);
    
    // Add gems/decorations based on tier
    _drawDecorations(canvas, size, tier);
  }

  void _drawDecorations(Canvas canvas, Size size, KingdomTier tier) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    switch (tier) {
      case KingdomTier.village:
        // Simple dots
        paint.color = DuolingoTheme.duoYellow;
        canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), 3, paint);
        break;
      
      case KingdomTier.town:
        // Multiple gems
        paint.color = DuolingoTheme.duoYellow;
        canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.45), 4, paint);
        canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.25), 5, paint);
        canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.45), 4, paint);
        break;
      
      case KingdomTier.city:
        // Ornate gems
        paint.color = DuolingoTheme.duoBlue;
        canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.5), 5, paint);
        paint.color = DuolingoTheme.duoYellow;
        canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), 6, paint);
        paint.color = DuolingoTheme.duoBlue;
        canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.5), 5, paint);
        break;
      
      case KingdomTier.kingdom:
        // Royal gems with sparkles
        paint.color = DuolingoTheme.duoPurple;
        canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.4), 6, paint);
        paint.color = DuolingoTheme.duoYellow;
        canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), 8, paint);
        paint.color = DuolingoTheme.duoPurple;
        canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.4), 6, paint);
        
        // Add sparkles
        _drawSparkles(canvas, size);
        break;
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DuolingoTheme.white
      ..style = PaintingStyle.fill;
    
    final sparklePositions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.1),
      Offset(size.width * 0.6, size.height * 0.1),
    ];
    
    for (final position in sparklePositions) {
      _drawSparkle(canvas, position, 4, paint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
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

  Color _getTierColor(KingdomTier tier) {
    switch (tier) {
      case KingdomTier.village:
        return DuolingoTheme.duoYellow;
      case KingdomTier.town:
        return DuolingoTheme.duoOrange;
      case KingdomTier.city:
        return DuolingoTheme.duoBlue;
      case KingdomTier.kingdom:
        return DuolingoTheme.duoPurple;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// Confetti painter for celebration background
class ConfettiPainter extends CustomPainter {
  final double animationValue;
  
  ConfettiPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Generate confetti pieces
    final colors = [
      DuolingoTheme.duoGreen,
      DuolingoTheme.duoBlue,
      DuolingoTheme.duoYellow,
      DuolingoTheme.duoOrange,
      DuolingoTheme.duoPurple,
    ];
    
    for (int i = 0; i < 50; i++) {
      final x = (i * 37.0) % size.width;
      final y = (animationValue * size.height * 1.5 + (i * 23.0) % 200) % size.height;
      final colorIndex = i % colors.length;
      
      paint.color = colors[colorIndex];
      
      // Different shapes for variety
      if (i % 3 == 0) {
        // Rectangle confetti
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 8, height: 4),
          paint,
        );
      } else if (i % 3 == 1) {
        // Circle confetti
        canvas.drawCircle(Offset(x, y), 3, paint);
      } else {
        // Triangle confetti
        final path = Path();
        path.moveTo(x, y - 4);
        path.lineTo(x + 4, y + 2);
        path.lineTo(x - 4, y + 2);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// Tier progress celebration widget for smaller milestones
class TierProgressCelebrationWidget extends StatefulWidget {
  final String milestone;
  final int xpEarned;
  final VoidCallback onDismiss;

  const TierProgressCelebrationWidget({
    super.key,
    required this.milestone,
    required this.xpEarned,
    required this.onDismiss,
  });

  @override
  State<TierProgressCelebrationWidget> createState() => _TierProgressCelebrationWidgetState();
}

class _TierProgressCelebrationWidgetState extends State<TierProgressCelebrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => SlideTransition(
        position: _slideAnimation,
        child: Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DuolingoTheme.duoGreen,
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.celebration,
                  color: DuolingoTheme.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Milestone Completed!',
                        style: DuolingoTheme.bodyMedium.copyWith(
                          color: DuolingoTheme.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.milestone,
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DuolingoTheme.duoYellow,
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                  ),
                  child: Text(
                    '+${widget.xpEarned} XP',
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Icon(
                    Icons.close,
                    color: DuolingoTheme.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}