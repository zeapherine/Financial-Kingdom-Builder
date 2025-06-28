import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/xp_system.dart';

class AnimatedLevelDisplay extends StatefulWidget {
  final UserLevel userLevel;
  final double size;
  final bool showLevelUpAnimation;

  const AnimatedLevelDisplay({
    super.key,
    required this.userLevel,
    this.size = 100.0,
    this.showLevelUpAnimation = true,
  });

  @override
  State<AnimatedLevelDisplay> createState() => _AnimatedLevelDisplayState();
}

class _AnimatedLevelDisplayState extends State<AnimatedLevelDisplay>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  int _previousLevel = 1;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _previousLevel = widget.userLevel.level;
  }

  @override
  void didUpdateWidget(AnimatedLevelDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.userLevel.level != widget.userLevel.level && 
        widget.userLevel.level > _previousLevel &&
        widget.showLevelUpAnimation) {
      _triggerLevelUpAnimation();
    }
    
    _previousLevel = widget.userLevel.level;
  }

  void _triggerLevelUpAnimation() {
    _rotationController.forward(from: 0);
    _scaleController.forward(from: 0).then((_) {
      _scaleController.reverse();
    });
    _glowController.repeat(reverse: true);
    
    // Stop glow animation after a few cycles
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _glowController.stop();
        _glowController.reset();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _getLevelColor() {
    final level = widget.userLevel.level;
    if (level <= 10) return DuolingoTheme.duoGreen;
    if (level <= 25) return DuolingoTheme.duoBlue;
    if (level <= 50) return DuolingoTheme.duoPurple;
    return DuolingoTheme.duoYellow;
  }

  IconData _getLevelIcon() {
    final level = widget.userLevel.level;
    if (level <= 10) return Icons.eco;
    if (level <= 25) return Icons.diamond;
    if (level <= 50) return Icons.auto_awesome;
    return Icons.workspace_premium;
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _scaleAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * math.pi,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    levelColor.withValues(alpha: 0.8),
                    levelColor,
                  ],
                ),
                border: Border.all(
                  color: levelColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: levelColor.withValues(
                      alpha: 0.6 * _glowAnimation.value,
                    ),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 10 * _glowAnimation.value,
                  ),
                  ...DuolingoTheme.elevatedShadow,
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pattern
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: LevelBackgroundPainter(
                      color: DuolingoTheme.white.withValues(alpha: 0.1),
                      level: widget.userLevel.level,
                    ),
                  ),
                  
                  // Level content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getLevelIcon(),
                        color: DuolingoTheme.white,
                        size: widget.size * 0.3,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.userLevel.level}',
                        style: DuolingoTheme.h2.copyWith(
                          color: DuolingoTheme.white,
                          fontWeight: FontWeight.w700,
                          fontSize: widget.size * 0.25,
                        ),
                      ),
                    ],
                  ),
                  
                  // Sparkle effects during level up
                  if (_glowAnimation.value > 0)
                    ...List.generate(8, (index) {
                      final angle = (index * 45) * (math.pi / 180);
                      final distance = widget.size * 0.6 * _glowAnimation.value;
                      final x = distance * math.cos(angle);
                      final y = distance * math.sin(angle);
                      
                      return Positioned(
                        left: widget.size / 2 + x - 4,
                        top: widget.size / 2 + y - 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: DuolingoTheme.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LevelProgressCard extends StatefulWidget {
  final UserLevel userLevel;
  final VoidCallback? onTap;

  const LevelProgressCard({
    super.key,
    required this.userLevel,
    this.onTap,
  });

  @override
  State<LevelProgressCard> createState() => _LevelProgressCardState();
}

class _LevelProgressCardState extends State<LevelProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.userLevel.progressToNextLevel,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(LevelProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.userLevel.progressToNextLevel != widget.userLevel.progressToNextLevel) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.userLevel.progressToNextLevel,
        end: widget.userLevel.progressToNextLevel,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DuolingoTheme.white,
              DuolingoTheme.lightGray.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
          boxShadow: DuolingoTheme.elevatedShadow,
          border: Border.all(
            color: DuolingoTheme.lightGray,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedLevelDisplay(
                  userLevel: widget.userLevel,
                  size: 80,
                ),
                const SizedBox(width: DuolingoTheme.spacingLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userLevel.title,
                        style: DuolingoTheme.h3.copyWith(
                          color: DuolingoTheme.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DuolingoTheme.spacingXs),
                      Text(
                        'Level ${widget.userLevel.level}',
                        style: DuolingoTheme.bodyLarge.copyWith(
                          color: DuolingoTheme.duoPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: DuolingoTheme.spacingXs),
                      Text(
                        '${widget.userLevel.currentXp} XP',
                        style: DuolingoTheme.bodyMedium.copyWith(
                          color: DuolingoTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Progress section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress to next level',
                  style: DuolingoTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DuolingoTheme.charcoal,
                  ),
                ),
                Text(
                  '${widget.userLevel.xpToNextLevel} XP to go',
                  style: DuolingoTheme.bodySmall.copyWith(
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
                return Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: DuolingoTheme.lightGray,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DuolingoTheme.duoGreen,
                              DuolingoTheme.duoBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: DuolingoTheme.duoGreen.withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Progress percentage text
                    if (_progressAnimation.value > 0.1)
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            '${(_progressAnimation.value * 100).round()}%',
                            style: DuolingoTheme.caption.copyWith(
                              color: DuolingoTheme.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: DuolingoTheme.spacingMd),
            
            // Unlocked features
            if (widget.userLevel.unlockedFeatures.isNotEmpty) ...[
              Text(
                'Unlocked Features:',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.charcoal,
                ),
              ),
              const SizedBox(height: DuolingoTheme.spacingSm),
              Wrap(
                spacing: DuolingoTheme.spacingSm,
                runSpacing: DuolingoTheme.spacingXs,
                children: widget.userLevel.unlockedFeatures.map((feature) =>
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DuolingoTheme.spacingSm,
                      vertical: DuolingoTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: DuolingoTheme.duoGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                      border: Border.all(
                        color: DuolingoTheme.duoGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: DuolingoTheme.duoGreen,
                        ),
                        const SizedBox(width: DuolingoTheme.spacingXs),
                        Text(
                          feature,
                          style: DuolingoTheme.caption.copyWith(
                            color: DuolingoTheme.duoGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LevelUpCelebration extends StatefulWidget {
  final int newLevel;
  final String newTitle;
  final List<String> newFeatures;
  final VoidCallback? onComplete;

  const LevelUpCelebration({
    super.key,
    required this.newLevel,
    required this.newTitle,
    required this.newFeatures,
    this.onComplete,
  });

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _confettiController;
  late AnimationController _textController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _textController = AnimationController(
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
      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.bounceOut,
    ));
    
    _startCelebration();
  }

  void _startCelebration() async {
    _confettiController.forward();
    await _mainController.forward();
    await _textController.forward();
    
    await Future.delayed(const Duration(seconds: 3));
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _confettiController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti background
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: ConfettiPainter(_confettiController.value),
              );
            },
          ),
          
          // Main celebration content
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(DuolingoTheme.spacingXl),
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
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                    boxShadow: DuolingoTheme.elevatedShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy icon
                      Container(
                        padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
                        decoration: BoxDecoration(
                          color: DuolingoTheme.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: DuolingoTheme.white,
                        ),
                      ),
                      
                      const SizedBox(height: DuolingoTheme.spacingLg),
                      
                      // Level up text
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Column(
                              children: [
                                Text(
                                  'LEVEL UP!',
                                  style: DuolingoTheme.h1.copyWith(
                                    color: DuolingoTheme.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: DuolingoTheme.spacingSm),
                                Text(
                                  'Level ${widget.newLevel}',
                                  style: DuolingoTheme.h2.copyWith(
                                    color: DuolingoTheme.white,
                                  ),
                                ),
                                const SizedBox(height: DuolingoTheme.spacingXs),
                                Text(
                                  widget.newTitle,
                                  style: DuolingoTheme.h4.copyWith(
                                    color: DuolingoTheme.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      // New features
                      if (widget.newFeatures.isNotEmpty) ...[
                        const SizedBox(height: DuolingoTheme.spacingLg),
                        
                        AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Container(
                                padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                                decoration: BoxDecoration(
                                  color: DuolingoTheme.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'New Features Unlocked:',
                                      style: DuolingoTheme.bodyLarge.copyWith(
                                        color: DuolingoTheme.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: DuolingoTheme.spacingSm),
                                    ...widget.newFeatures.map((feature) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: DuolingoTheme.spacingXs,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color: DuolingoTheme.white,
                                          ),
                                          const SizedBox(width: DuolingoTheme.spacingSm),
                                          Expanded(
                                            child: Text(
                                              feature,
                                              style: DuolingoTheme.bodyMedium.copyWith(
                                                color: DuolingoTheme.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LevelBackgroundPainter extends CustomPainter {
  final Color color;
  final int level;

  LevelBackgroundPainter({
    required this.color,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw decorative circles based on level
    final circles = math.min(level ~/ 5 + 1, 4);
    
    for (int i = 0; i < circles; i++) {
      final circleRadius = radius * (0.3 + i * 0.2);
      canvas.drawCircle(center, circleRadius, paint);
    }

    // Draw radial lines
    final lines = math.min(level * 2, 16);
    for (int i = 0; i < lines; i++) {
      final angle = (i * 360 / lines) * (math.pi / 180);
      final startRadius = radius * 0.7;
      final endRadius = radius * 0.9;
      
      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      
      final end = Offset(
        center.dx + endRadius * math.cos(angle),
        center.dy + endRadius * math.sin(angle),
      );
      
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(LevelBackgroundPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.level != level;
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      DuolingoTheme.duoYellow,
      DuolingoTheme.duoGreen,
      DuolingoTheme.duoBlue,
      DuolingoTheme.duoOrange,
      DuolingoTheme.duoPurple,
    ];

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (size.width * (i % 10) / 10) + 
               20 * math.sin(progress * 4 * math.pi + i);
      final y = size.height * progress * (1 + i * 0.02);
      
      if (y > size.height) continue;

      paint.color = colors[i % colors.length];
      
      final rect = Rect.fromLTWH(x - 3, y - 3, 6, 6);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}