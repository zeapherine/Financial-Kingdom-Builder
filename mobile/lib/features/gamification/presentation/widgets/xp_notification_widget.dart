import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/xp_system.dart';

class XPNotificationWidget extends StatefulWidget {
  final XPGainEvent xpEvent;
  final VoidCallback? onComplete;

  const XPNotificationWidget({
    super.key,
    required this.xpEvent,
    this.onComplete,
  });

  @override
  State<XPNotificationWidget> createState() => _XPNotificationWidgetState();
}

class _XPNotificationWidgetState extends State<XPNotificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: DuolingoTheme.normalAnimation,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: DuolingoTheme.fastAnimation,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: DuolingoTheme.normalAnimation,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.bounceOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _startAnimation();
  }

  void _startAnimation() async {
    await _slideController.forward();
    await _scaleController.forward();
    await Future.delayed(const Duration(seconds: 2));
    await _scaleController.reverse();
    await _fadeController.forward();
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: DuolingoTheme.spacingMd,
              vertical: DuolingoTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DuolingoTheme.duoYellow,
                  DuolingoTheme.duoOrange,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
              boxShadow: DuolingoTheme.elevatedShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(DuolingoTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: DuolingoTheme.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      color: DuolingoTheme.white,
                      size: DuolingoTheme.iconLarge,
                    ),
                  ),
                  const SizedBox(width: DuolingoTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+${widget.xpEvent.xpGained} XP',
                          style: DuolingoTheme.h4.copyWith(
                            color: DuolingoTheme.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.xpEvent.description != null)
                          Text(
                            widget.xpEvent.description!,
                            style: DuolingoTheme.bodySmall.copyWith(
                              color: DuolingoTheme.white.withValues(alpha: 0.9),
                            ),
                          ),
                        if (widget.xpEvent.multiplier > 1.0)
                          Text(
                            '${widget.xpEvent.multiplier}x multiplier!',
                            style: DuolingoTheme.bodySmall.copyWith(
                              color: DuolingoTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedXPGainText extends StatefulWidget {
  final int oldXp;
  final int newXp;
  final Duration duration;

  const AnimatedXPGainText({
    super.key,
    required this.oldXp,
    required this.newXp,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedXPGainText> createState() => _AnimatedXPGainTextState();
}

class _AnimatedXPGainTextState extends State<AnimatedXPGainText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _xpAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _xpAnimation = IntTween(
      begin: widget.oldXp,
      end: widget.newXp,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _xpAnimation,
      builder: (context, child) {
        return Text(
          '${_xpAnimation.value} XP',
          style: DuolingoTheme.bodyMedium.copyWith(
            color: DuolingoTheme.duoYellow,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}

class LevelUpNotification extends StatefulWidget {
  final int oldLevel;
  final int newLevel;
  final List<String> newFeatures;
  final VoidCallback? onComplete;

  const LevelUpNotification({
    super.key,
    required this.oldLevel,
    required this.newLevel,
    required this.newFeatures,
    this.onComplete,
  });

  @override
  State<LevelUpNotification> createState() => _LevelUpNotificationState();
}

class _LevelUpNotificationState extends State<LevelUpNotification>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.bounceOut),
    ));
    
    _startAnimation();
  }

  void _startAnimation() async {
    _particleController.forward();
    await _mainController.forward();
    await Future.delayed(const Duration(seconds: 3));
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated particles
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(200, 200),
              painter: ParticlePainter(_particleController.value),
            );
          },
        ),
        
        // Main level up content
        ScaleTransition(
          scale: _scaleAnimation,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: Container(
              padding: const EdgeInsets.all(DuolingoTheme.spacingXl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DuolingoTheme.duoPurple,
                    DuolingoTheme.duoBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: DuolingoTheme.elevatedShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: DuolingoTheme.white,
                    size: DuolingoTheme.iconXlarge,
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  Text(
                    'LEVEL UP!',
                    style: DuolingoTheme.h3.copyWith(
                      color: DuolingoTheme.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Level ${widget.newLevel}',
                    style: DuolingoTheme.h4.copyWith(
                      color: DuolingoTheme.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // New features slide-in
        Positioned(
          bottom: 50,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              decoration: BoxDecoration(
                color: DuolingoTheme.white,
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                boxShadow: DuolingoTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Text(
                    'New Features Unlocked:',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  ...widget.newFeatures.map((feature) => Text(
                    '• $feature',
                    style: DuolingoTheme.bodySmall,
                  )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  
  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DuolingoTheme.duoYellow.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (3.14159 / 180);
      final distance = progress * 80;
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      canvas.drawCircle(
        Offset(x, y),
        4 * (1 - progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}