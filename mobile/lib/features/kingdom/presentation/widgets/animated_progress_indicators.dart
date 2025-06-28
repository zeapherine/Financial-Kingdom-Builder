import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/kingdom_state.dart';

/// Animated Progress Indicators with Particle Effects
/// Creates engaging progress bars with particle animations and visual feedback
/// Implements various progress indicator styles for different contexts
/// 
/// From /mobile/styles.json:
/// - Uses progressBars styling from components section
/// - Applies gamification colors from gamificationElements section
/// - Follows animation curves and durations from animations section

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final String label;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final bool showParticles;
  final bool showPercentage;
  final Duration animationDuration;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.label = '',
    this.progressColor,
    this.backgroundColor,
    this.height = 12.0,
    this.showParticles = true,
    this.showPercentage = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _particleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));

    _progressController.forward();
    
    if (widget.showParticles && widget.progress > 0) {
      _particleController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
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
      
      if (widget.showParticles && widget.progress > 0) {
        _particleController.repeat();
      } else {
        _particleController.stop();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label and percentage
        if (widget.label.isNotEmpty || widget.showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.label.isNotEmpty)
                  Text(
                    widget.label,
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DuolingoTheme.charcoal,
                    ),
                  ),
                if (widget.showPercentage)
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Text(
                        '${(_progressAnimation.value * 100).toInt()}%',
                        style: DuolingoTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DuolingoTheme.darkGray,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        
        // Progress bar with particles
        Stack(
          children: [
            // Background bar
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? DuolingoTheme.lightGray,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
            
            // Progress bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return SizedBox(
                  height: widget.height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.progressColor ?? DuolingoTheme.duoGreen,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Particle effects
            if (widget.showParticles)
              AnimatedBuilder(
                animation: Listenable.merge([_progressAnimation, _particleAnimation]),
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.fromHeight(widget.height),
                    painter: _ProgressParticlesPainter(
                      progress: _progressAnimation.value,
                      particleProgress: _particleAnimation.value,
                      color: widget.progressColor ?? DuolingoTheme.duoGreen,
                      height: widget.height,
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// Circular progress indicator with particle effects
class AnimatedCircularProgress extends StatefulWidget {
  final double progress;
  final String centerText;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showParticles;

  const AnimatedCircularProgress({
    super.key,
    required this.progress,
    this.centerText = '',
    this.size = 120.0,
    this.strokeWidth = 8.0,
    this.progressColor,
    this.backgroundColor,
    this.showParticles = true,
  });

  @override
  State<AnimatedCircularProgress> createState() => _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _particleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _progressController.forward();
    
    if (widget.showParticles && widget.progress > 0) {
      _particleController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          // Circular progress indicator
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: _progressAnimation.value,
                strokeWidth: widget.strokeWidth,
                backgroundColor: widget.backgroundColor ?? DuolingoTheme.lightGray,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.progressColor ?? DuolingoTheme.duoGreen,
                ),
              );
            },
          ),
          
          // Center text
          if (widget.centerText.isNotEmpty)
            Center(
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Text(
                    widget.centerText.isNotEmpty 
                        ? widget.centerText 
                        : '${(_progressAnimation.value * 100).toInt()}%',
                    style: DuolingoTheme.h4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: DuolingoTheme.charcoal,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          
          // Particle effects
          if (widget.showParticles)
            AnimatedBuilder(
              animation: Listenable.merge([_progressAnimation, _particleAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _CircularProgressParticlesPainter(
                    progress: _progressAnimation.value,
                    particleProgress: _particleAnimation.value,
                    color: widget.progressColor ?? DuolingoTheme.duoGreen,
                    strokeWidth: widget.strokeWidth,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// XP Progress bar with celebration effects
class XPProgressIndicator extends StatefulWidget {
  final int currentXP;
  final int nextLevelXP;
  final int level;
  final bool showLevelUp;
  final VoidCallback? onLevelUpComplete;

  const XPProgressIndicator({
    super.key,
    required this.currentXP,
    required this.nextLevelXP,
    required this.level,
    this.showLevelUp = false,
    this.onLevelUpComplete,
  });

  @override
  State<XPProgressIndicator> createState() => _XPProgressIndicatorState();
}

class _XPProgressIndicatorState extends State<XPProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _xpController;
  late AnimationController _levelUpController;
  late Animation<double> _xpAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _xpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _levelUpController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final progress = widget.currentXP / widget.nextLevelXP;
    _xpAnimation = Tween<double>(
      begin: 0.0,
      end: progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _xpController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _levelUpController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _levelUpController,
      curve: Curves.easeInOut,
    ));

    _xpController.forward();
  }

  @override
  void didUpdateWidget(XPProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.showLevelUp && !oldWidget.showLevelUp) {
      _triggerLevelUp();
    }
    
    if (oldWidget.currentXP != widget.currentXP || 
        oldWidget.nextLevelXP != widget.nextLevelXP) {
      final progress = widget.currentXP / widget.nextLevelXP;
      _xpAnimation = Tween<double>(
        begin: _xpAnimation.value,
        end: progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _xpController,
        curve: Curves.easeOut,
      ));
      
      _xpController.reset();
      _xpController.forward();
    }
  }

  @override
  void dispose() {
    _xpController.dispose();
    _levelUpController.dispose();
    super.dispose();
  }

  Future<void> _triggerLevelUp() async {
    await _levelUpController.forward();
    _levelUpController.reset();
    
    if (widget.onLevelUpComplete != null) {
      widget.onLevelUpComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: DuolingoTheme.duoYellow.withValues(alpha: 0.6 * _glowAnimation.value),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
            ),
            child: Column(
              children: [
                // Level indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level ${widget.level}',
                      style: DuolingoTheme.h3.copyWith(
                        fontWeight: FontWeight.w800,
                        color: DuolingoTheme.charcoal,
                      ),
                    ),
                    Text(
                      '${widget.currentXP} / ${widget.nextLevelXP} XP',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.darkGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DuolingoTheme.spacingMd),
                
                // XP Progress bar
                AnimatedProgressBar(
                  progress: _xpAnimation.value,
                  height: 16,
                  progressColor: DuolingoTheme.duoYellow,
                  showPercentage: false,
                  showParticles: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Kingdom tier progress with milestone indicators
class KingdomTierProgress extends StatefulWidget {
  final KingdomTier currentTier;
  final double progressToNext;
  final List<String> milestones;
  final int completedMilestones;

  const KingdomTierProgress({
    super.key,
    required this.currentTier,
    required this.progressToNext,
    this.milestones = const [],
    this.completedMilestones = 0,
  });

  @override
  State<KingdomTierProgress> createState() => _KingdomTierProgressState();
}

class _KingdomTierProgressState extends State<KingdomTierProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _milestoneController;
  late Animation<double> _milestoneAnimation;

  @override
  void initState() {
    super.initState();
    _milestoneController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _milestoneAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _milestoneController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void didUpdateWidget(KingdomTierProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.completedMilestones > oldWidget.completedMilestones) {
      _milestoneController.forward().then((_) {
        _milestoneController.reset();
      });
    }
  }

  @override
  void dispose() {
    _milestoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: DuolingoTheme.charcoal.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DuolingoTheme.spacingMd,
                  vertical: DuolingoTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: _getTierColor(widget.currentTier),
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                ),
                child: Text(
                  widget.currentTier.name.toUpperCase(),
                  style: DuolingoTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: DuolingoTheme.white,
                  ),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Text(
                  'Progress to ${_getNextTier(widget.currentTier).name}',
                  style: DuolingoTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DuolingoTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Progress bar
          AnimatedProgressBar(
            progress: widget.progressToNext,
            height: 14,
            progressColor: _getTierColor(widget.currentTier),
            showPercentage: true,
            showParticles: true,
          ),
          
          // Milestones
          if (widget.milestones.isNotEmpty) ...[
            const SizedBox(height: DuolingoTheme.spacingLg),
            Text(
              'Milestones',
              style: DuolingoTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: DuolingoTheme.charcoal,
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingMd),
            ...widget.milestones.asMap().entries.map((entry) {
              final index = entry.key;
              final milestone = entry.value;
              final isCompleted = index < widget.completedMilestones;
              
              return AnimatedBuilder(
                animation: _milestoneAnimation,
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: DuolingoTheme.spacingSm),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: isCompleted && index == widget.completedMilestones - 1 
                              ? _milestoneAnimation.value * 0.3 + 1.0 
                              : 1.0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isCompleted 
                                  ? DuolingoTheme.duoGreen 
                                  : DuolingoTheme.lightGray,
                              shape: BoxShape.circle,
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: DuolingoTheme.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: DuolingoTheme.spacingMd),
                        Expanded(
                          child: Text(
                            milestone,
                            style: DuolingoTheme.bodySmall.copyWith(
                              color: isCompleted 
                                  ? DuolingoTheme.charcoal 
                                  : DuolingoTheme.mediumGray,
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
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
        return KingdomTier.kingdom;
    }
  }
}

/// Custom painter for linear progress particle effects
class _ProgressParticlesPainter extends CustomPainter {
  final double progress;
  final double particleProgress;
  final Color color;
  final double height;

  _ProgressParticlesPainter({
    required this.progress,
    required this.particleProgress,
    required this.color,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final progressWidth = size.width * progress;
    final particleCount = 6;
    
    for (int i = 0; i < particleCount; i++) {
      final particleX = (progressWidth * 0.8) + 
          (math.sin(particleProgress * 2 * math.pi + i) * 10);
      final particleY = height / 2 + 
          (math.cos(particleProgress * 2 * math.pi + i * 0.5) * height * 0.3);
      
      final particleSize = 2.0 + math.sin(particleProgress * 2 * math.pi + i) * 1.0;
      final particleOpacity = 0.6 + math.sin(particleProgress * 4 * math.pi + i) * 0.4;
      
      final paint = Paint()
        ..color = color.withValues(alpha: particleOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particleX, particleY),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for circular progress particle effects
class _CircularProgressParticlesPainter extends CustomPainter {
  final double progress;
  final double particleProgress;
  final Color color;
  final double strokeWidth;

  _CircularProgressParticlesPainter({
    required this.progress,
    required this.particleProgress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final progressAngle = progress * 2 * math.pi;
    final particleCount = 8;
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (progressAngle * 0.9) + 
          (math.sin(particleProgress * 2 * math.pi + i) * 0.2);
      final particleRadius = radius + 
          (math.cos(particleProgress * 3 * math.pi + i) * strokeWidth * 0.5);
      
      final x = center.dx + particleRadius * math.cos(angle - math.pi / 2);
      final y = center.dy + particleRadius * math.sin(angle - math.pi / 2);
      
      final particleSize = 2.0 + math.sin(particleProgress * 2 * math.pi + i) * 1.0;
      final particleOpacity = 0.5 + math.sin(particleProgress * 4 * math.pi + i) * 0.3;
      
      final paint = Paint()
        ..color = color.withValues(alpha: particleOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}