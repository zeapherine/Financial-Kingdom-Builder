import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/streak_system.dart';

class AnimatedStreakCounter extends StatefulWidget {
  final StreakData streakData;
  final double size;
  final bool showFlameAnimation;

  const AnimatedStreakCounter({
    super.key,
    required this.streakData,
    this.size = 80.0,
    this.showFlameAnimation = true,
  });

  @override
  State<AnimatedStreakCounter> createState() => _AnimatedStreakCounterState();
}

class _AnimatedStreakCounterState extends State<AnimatedStreakCounter>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  
  late Animation<double> _flameAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _flameController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _flameAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _flameController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    if (widget.showFlameAnimation && widget.streakData.currentStreak > 0) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _flameController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _bounceController.forward();
  }

  @override
  void didUpdateWidget(AnimatedStreakCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.streakData.currentStreak != widget.streakData.currentStreak) {
      if (widget.streakData.currentStreak > oldWidget.streakData.currentStreak) {
        _bounceController.forward(from: 0);
      }
      
      if (widget.streakData.currentStreak > 0 && widget.showFlameAnimation) {
        _startAnimations();
      } else {
        _flameController.stop();
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _flameController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Color _getStreakColor() {
    if (widget.streakData.currentStreak == 0) return DuolingoTheme.mediumGray;
    if (widget.streakData.currentStreak < 7) return DuolingoTheme.duoOrange;
    if (widget.streakData.currentStreak < 30) return DuolingoTheme.duoRed;
    return DuolingoTheme.duoYellow;
  }

  @override
  Widget build(BuildContext context) {
    final streakColor = _getStreakColor();
    final hasStreak = widget.streakData.currentStreak > 0;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value * (hasStreak ? _pulseAnimation.value : 1.0),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: hasStreak
                  ? RadialGradient(
                      colors: [
                        streakColor.withValues(alpha: 0.8),
                        streakColor,
                      ],
                    )
                  : null,
              color: hasStreak ? null : DuolingoTheme.lightGray,
              shape: BoxShape.circle,
              border: Border.all(
                color: hasStreak ? streakColor : DuolingoTheme.mediumGray,
                width: 3,
              ),
              boxShadow: hasStreak
                  ? [
                      BoxShadow(
                        color: streakColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Flame animation
                if (hasStreak && widget.showFlameAnimation)
                  AnimatedBuilder(
                    animation: _flameAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _flameAnimation.value,
                        child: CustomPaint(
                          size: Size(widget.size * 0.6, widget.size * 0.6),
                          painter: FlamePainter(
                            color: streakColor,
                            intensity: widget.streakData.currentStreak / 100,
                          ),
                        ),
                      );
                    },
                  ),
                
                // Streak number
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasStreak ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                      color: hasStreak ? DuolingoTheme.white : DuolingoTheme.darkGray,
                      size: widget.size * 0.3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.streakData.currentStreak}',
                      style: DuolingoTheme.h3.copyWith(
                        color: hasStreak ? DuolingoTheme.white : DuolingoTheme.darkGray,
                        fontWeight: FontWeight.w700,
                        fontSize: widget.size * 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StreakHealthIndicator extends StatefulWidget {
  final StreakData streakData;
  final double width;
  final double height;

  const StreakHealthIndicator({
    super.key,
    required this.streakData,
    this.width = 200.0,
    this.height = 8.0,
  });

  @override
  State<StreakHealthIndicator> createState() => _StreakHealthIndicatorState();
}

class _StreakHealthIndicatorState extends State<StreakHealthIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _healthAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    final healthPercentage = StreakCalculationService.getStreakHealthPercentage(widget.streakData);
    _healthAnimation = Tween<double>(
      begin: 0.0,
      end: healthPercentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(StreakHealthIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final newHealth = StreakCalculationService.getStreakHealthPercentage(widget.streakData);
    final oldHealth = StreakCalculationService.getStreakHealthPercentage(oldWidget.streakData);
    
    if (newHealth != oldHealth) {
      _healthAnimation = Tween<double>(
        begin: oldHealth,
        end: newHealth,
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

  Color _getHealthColor(double health) {
    if (health >= 0.8) return DuolingoTheme.duoGreen;
    if (health >= 0.5) return DuolingoTheme.duoYellow;
    if (health >= 0.2) return DuolingoTheme.duoOrange;
    return DuolingoTheme.duoRed;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _healthAnimation,
      builder: (context, child) {
        final health = _healthAnimation.value;
        final healthColor = _getHealthColor(health);
        
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: DuolingoTheme.lightGray,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: Stack(
            children: [
              // Health bar
              FractionallySizedBox(
                widthFactor: health,
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        healthColor.withValues(alpha: 0.8),
                        healthColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
              ),
              
              // Pulsing effect for low health
              if (health < 0.3 && health > 0)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: widget.width * health,
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: healthColor.withValues(
                          alpha: 0.3 * (0.5 + 0.5 * math.sin(_controller.value * 4 * math.pi)),
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class StreakCalendarWidget extends StatelessWidget {
  final StreakData streakData;
  final int daysToShow;

  const StreakCalendarWidget({
    super.key,
    required this.streakData,
    this.daysToShow = 14,
  });

  @override
  Widget build(BuildContext context) {
    final calendar = StreakCalculationService.getActivityCalendar(
      streakData, 
      days: daysToShow,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: calendar.map((date) {
        final hasActivity = StreakCalculationService.hasActivityOnDate(streakData, date);
        final isToday = _isToday(date);
        final isFuture = date.isAfter(DateTime.now());
        
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isFuture
                ? Colors.transparent
                : hasActivity
                    ? DuolingoTheme.duoGreen
                    : DuolingoTheme.lightGray,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: DuolingoTheme.duoBlue, width: 2)
                : null,
          ),
          child: hasActivity
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: DuolingoTheme.white,
                )
              : null,
        );
      }).toList(),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}

class StreakMilestoneProgress extends StatefulWidget {
  final StreakData streakData;

  const StreakMilestoneProgress({
    super.key,
    required this.streakData,
  });

  @override
  State<StreakMilestoneProgress> createState() => _StreakMilestoneProgressState();
}

class _StreakMilestoneProgressState extends State<StreakMilestoneProgress>
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
    
    _updateAnimation();
    _controller.forward();
  }

  void _updateAnimation() {
    final nextMilestone = widget.streakData.nextMilestone;
    final progress = nextMilestone != null
        ? widget.streakData.currentStreak / nextMilestone.days
        : 1.0;
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(StreakMilestoneProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.streakData.currentStreak != widget.streakData.currentStreak) {
      _updateAnimation();
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
    final currentMilestone = widget.streakData.currentMilestone;
    final nextMilestone = widget.streakData.nextMilestone;
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Streak Milestone',
                style: DuolingoTheme.h4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (currentMilestone != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DuolingoTheme.spacingSm,
                    vertical: DuolingoTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: _getMilestoneColor(currentMilestone),
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                  ),
                  child: Text(
                    currentMilestone.title,
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          if (nextMilestone != null) ...[
            const SizedBox(height: DuolingoTheme.spacingMd),
            
            Text(
              'Next: ${nextMilestone.title}',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.darkGray,
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingSm),
            
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: DuolingoTheme.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getMilestoneColor(nextMilestone),
                  ),
                  minHeight: 8,
                );
              },
            ),
            
            const SizedBox(height: DuolingoTheme.spacingSm),
            
            Text(
              '${widget.streakData.daysToNextMilestone} days to go',
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.darkGray,
              ),
            ),
          ] else ...[
            const SizedBox(height: DuolingoTheme.spacingMd),
            
            Text(
              'Legendary Status Achieved! 🏆',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.duoYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getMilestoneColor(StreakMilestone milestone) {
    switch (milestone) {
      case StreakMilestone.bronze:
        return const Color(0xFFCD7F32);
      case StreakMilestone.silver:
        return const Color(0xFFC0C0C0);
      case StreakMilestone.gold:
        return DuolingoTheme.duoYellow;
      case StreakMilestone.platinum:
        return const Color(0xFFE5E4E2);
      case StreakMilestone.diamond:
        return DuolingoTheme.duoBlue;
      case StreakMilestone.legendary:
        return DuolingoTheme.duoPurple;
    }
  }
}

class FlamePainter extends CustomPainter {
  final Color color;
  final double intensity;

  FlamePainter({
    required this.color,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    // Draw flame-like shape
    final path = Path();
    path.moveTo(center.dx, center.dy + radius);
    
    // Left side of flame
    path.quadraticBezierTo(
      center.dx - radius * 0.8, 
      center.dy + radius * 0.2,
      center.dx - radius * 0.3, 
      center.dy - radius * 0.3,
    );
    
    // Top curve
    path.quadraticBezierTo(
      center.dx, 
      center.dy - radius * 1.2 * intensity,
      center.dx + radius * 0.3, 
      center.dy - radius * 0.3,
    );
    
    // Right side of flame
    path.quadraticBezierTo(
      center.dx + radius * 0.8, 
      center.dy + radius * 0.2,
      center.dx, 
      center.dy + radius,
    );
    
    canvas.drawPath(path, paint);
    
    // Inner flame highlight
    final innerPaint = Paint()
      ..color = DuolingoTheme.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    final innerPath = Path();
    innerPath.moveTo(center.dx, center.dy + radius * 0.5);
    innerPath.quadraticBezierTo(
      center.dx - radius * 0.3, 
      center.dy,
      center.dx, 
      center.dy - radius * 0.8 * intensity,
    );
    innerPath.quadraticBezierTo(
      center.dx + radius * 0.3, 
      center.dy,
      center.dx, 
      center.dy + radius * 0.5,
    );
    
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(FlamePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.intensity != intensity;
  }
}