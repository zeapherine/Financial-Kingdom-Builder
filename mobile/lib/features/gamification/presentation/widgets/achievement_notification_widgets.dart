import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/achievement_system.dart';

class AchievementUnlockedNotification extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onComplete;
  final Duration displayDuration;

  const AchievementUnlockedNotification({
    super.key,
    required this.achievement,
    this.onComplete,
    this.displayDuration = const Duration(seconds: 4),
  });

  @override
  State<AchievementUnlockedNotification> createState() => _AchievementUnlockedNotificationState();
}

class _AchievementUnlockedNotificationState extends State<AchievementUnlockedNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _sparkleController;
  late AnimationController _fadeController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
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
    // Slide in
    await _slideController.forward();
    
    // Scale animation for emphasis
    await _scaleController.forward();
    await _scaleController.reverse();
    
    // Sparkle effect
    _sparkleController.repeat();
    
    // Wait for display duration
    await Future.delayed(widget.displayDuration);
    
    // Fade out
    await _fadeController.forward();
    
    // Complete callback
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _sparkleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Color _getRarityColor() {
    switch (widget.achievement.rarity) {
      case AchievementRarity.common:
        return DuolingoTheme.mediumGray;
      case AchievementRarity.uncommon:
        return DuolingoTheme.duoGreen;
      case AchievementRarity.rare:
        return DuolingoTheme.duoBlue;
      case AchievementRarity.epic:
        return DuolingoTheme.duoPurple;
      case AchievementRarity.legendary:
        return DuolingoTheme.duoYellow;
    }
  }

  IconData _getIconData() {
    final iconMap = {
      'school': Icons.school,
      'school_outlined': Icons.school_outlined,
      'emoji_events': Icons.emoji_events,
      'trending_up': Icons.trending_up,
      'show_chart': Icons.show_chart,
      'security': Icons.security,
      'local_fire_department': Icons.local_fire_department,
      'whatshot': Icons.whatshot,
      'celebration': Icons.celebration,
      'account_balance': Icons.account_balance,
      'domain': Icons.domain,
      'castle': Icons.castle,
      'people': Icons.people,
      'psychology': Icons.psychology,
      'leaderboard': Icons.leaderboard,
      'star': Icons.star,
      'star_rate': Icons.star_rate,
      'stars': Icons.stars,
      'wb_sunny': Icons.wb_sunny,
      'nights_stay': Icons.nights_stay,
    };
    
    return iconMap[widget.achievement.iconName] ?? Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  rarityColor.withValues(alpha: 0.9),
                  rarityColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: rarityColor.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                ...DuolingoTheme.elevatedShadow,
              ],
              border: Border.all(
                color: DuolingoTheme.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Sparkle effects
                AnimatedBuilder(
                  animation: _sparkleAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(double.infinity, 120),
                      painter: SparkleEffectPainter(
                        progress: _sparkleAnimation.value,
                        color: DuolingoTheme.white,
                      ),
                    );
                  },
                ),
                
                // Main content
                Padding(
                  padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
                  child: Row(
                    children: [
                      // Achievement icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: DuolingoTheme.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DuolingoTheme.white,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          _getIconData(),
                          size: 35,
                          color: DuolingoTheme.white,
                        ),
                      ),
                      
                      const SizedBox(width: DuolingoTheme.spacingLg),
                      
                      // Achievement details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'ACHIEVEMENT UNLOCKED!',
                                  style: DuolingoTheme.bodySmall.copyWith(
                                    color: DuolingoTheme.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(width: DuolingoTheme.spacingSm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DuolingoTheme.spacingXs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DuolingoTheme.white.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                                  ),
                                  child: Text(
                                    widget.achievement.rarity.name.toUpperCase(),
                                    style: DuolingoTheme.caption.copyWith(
                                      color: DuolingoTheme.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: DuolingoTheme.spacingXs),
                            
                            Text(
                              widget.achievement.title,
                              style: DuolingoTheme.h4.copyWith(
                                color: DuolingoTheme.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            
                            const SizedBox(height: DuolingoTheme.spacingXs),
                            
                            Text(
                              widget.achievement.description,
                              style: DuolingoTheme.bodySmall.copyWith(
                                color: DuolingoTheme.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: DuolingoTheme.spacingSm),
                            
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: DuolingoTheme.white,
                                ),
                                const SizedBox(width: DuolingoTheme.spacingXs),
                                Text(
                                  '+${widget.achievement.xpReward} XP',
                                  style: DuolingoTheme.bodyMedium.copyWith(
                                    color: DuolingoTheme.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}

class MilestoneReachedNotification extends StatefulWidget {
  final String milestoneTitle;
  final String description;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback? onComplete;

  const MilestoneReachedNotification({
    super.key,
    required this.milestoneTitle,
    required this.description,
    required this.value,
    required this.icon,
    required this.color,
    this.onComplete,
  });

  @override
  State<MilestoneReachedNotification> createState() => _MilestoneReachedNotificationState();
}

class _MilestoneReachedNotificationState extends State<MilestoneReachedNotification>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _fireworksController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fireworksAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fireworksController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fireworksAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fireworksController,
      curve: Curves.easeOut,
    ));
    
    _startAnimation();
  }

  void _startAnimation() async {
    _fireworksController.forward();
    await _mainController.forward();
    _pulseController.repeat(reverse: true);
    
    await Future.delayed(const Duration(seconds: 3));
    
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _fireworksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fireworks background
          AnimatedBuilder(
            animation: _fireworksAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: FireworksPainter(
                  progress: _fireworksAnimation.value,
                  color: widget.color,
                ),
              );
            },
          ),
          
          // Main milestone card
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.all(DuolingoTheme.spacingXl),
                        padding: const EdgeInsets.all(DuolingoTheme.spacingXl),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withValues(alpha: 0.9),
                              widget.color,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.6),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Milestone icon
                            Container(
                              padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
                              decoration: BoxDecoration(
                                color: DuolingoTheme.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: DuolingoTheme.white,
                                  width: 4,
                                ),
                              ),
                              child: Icon(
                                widget.icon,
                                size: 60,
                                color: DuolingoTheme.white,
                              ),
                            ),
                            
                            const SizedBox(height: DuolingoTheme.spacingLg),
                            
                            // Milestone text
                            Text(
                              'MILESTONE REACHED!',
                              style: DuolingoTheme.bodyMedium.copyWith(
                                color: DuolingoTheme.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: DuolingoTheme.spacingSm),
                            
                            Text(
                              widget.milestoneTitle,
                              style: DuolingoTheme.h2.copyWith(
                                color: DuolingoTheme.white,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: DuolingoTheme.spacingSm),
                            
                            Text(
                              widget.description,
                              style: DuolingoTheme.bodyLarge.copyWith(
                                color: DuolingoTheme.white.withValues(alpha: 0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: DuolingoTheme.spacingLg),
                            
                            // Value display
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DuolingoTheme.spacingLg,
                                vertical: DuolingoTheme.spacingMd,
                              ),
                              decoration: BoxDecoration(
                                color: DuolingoTheme.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
                              ),
                              child: Text(
                                '${widget.value}',
                                style: DuolingoTheme.h1.copyWith(
                                  color: DuolingoTheme.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NotificationQueue extends StatefulWidget {
  final List<Widget> notifications;
  final Duration delayBetween;

  const NotificationQueue({
    super.key,
    required this.notifications,
    this.delayBetween = const Duration(milliseconds: 500),
  });

  @override
  State<NotificationQueue> createState() => _NotificationQueueState();
}

class _NotificationQueueState extends State<NotificationQueue> {
  int _currentIndex = 0;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    if (widget.notifications.isNotEmpty) {
      _showNext();
    }
  }

  void _showNext() {
    if (_currentIndex < widget.notifications.length) {
      setState(() {
        _isShowing = true;
      });
    }
  }

  void _onNotificationComplete() {
    setState(() {
      _isShowing = false;
      _currentIndex++;
    });
    
    if (_currentIndex < widget.notifications.length) {
      Future.delayed(widget.delayBetween, () {
        if (mounted) {
          _showNext();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShowing || _currentIndex >= widget.notifications.length) {
      return const SizedBox.shrink();
    }

    final currentNotification = widget.notifications[_currentIndex];
    
    // Wrap notification with completion callback
    if (currentNotification is AchievementUnlockedNotification) {
      return AchievementUnlockedNotification(
        achievement: currentNotification.achievement,
        onComplete: _onNotificationComplete,
      );
    } else if (currentNotification is MilestoneReachedNotification) {
      return MilestoneReachedNotification(
        milestoneTitle: currentNotification.milestoneTitle,
        description: currentNotification.description,
        value: currentNotification.value,
        icon: currentNotification.icon,
        color: currentNotification.color,
        onComplete: _onNotificationComplete,
      );
    }
    
    return currentNotification;
  }
}

class SparkleEffectPainter extends CustomPainter {
  final double progress;
  final Color color;

  SparkleEffectPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = size.width * (0.1 + (i % 5) * 0.2) + 
               10 * math.sin(progress * 4 * math.pi + i);
      final y = size.height * (0.2 + (i ~/ 5) * 0.3) + 
               5 * math.cos(progress * 3 * math.pi + i * 0.5);
      
      final sparkleSize = 2 + 3 * math.sin(progress * 2 * math.pi + i * 0.3);
      
      // Draw star-like sparkle
      final path = Path();
      for (int j = 0; j < 4; j++) {
        final angle = j * math.pi / 2;
        final outerX = x + sparkleSize * math.cos(angle);
        final outerY = y + sparkleSize * math.sin(angle);
        final innerX = x + (sparkleSize * 0.5) * math.cos(angle + math.pi / 4);
        final innerY = y + (sparkleSize * 0.5) * math.sin(angle + math.pi / 4);
        
        if (j == 0) {
          path.moveTo(outerX, outerY);
        } else {
          path.lineTo(outerX, outerY);
        }
        path.lineTo(innerX, innerY);
      }
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SparkleEffectPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class FireworksPainter extends CustomPainter {
  final double progress;
  final Color color;

  FireworksPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw multiple fireworks
    for (int firework = 0; firework < 3; firework++) {
      final centerX = size.width * (0.2 + firework * 0.3);
      final centerY = size.height * (0.3 + firework * 0.2);
      
      // Draw particles radiating from center
      for (int i = 0; i < 12; i++) {
        final angle = (i * 30) * (math.pi / 180);
        final distance = progress * (80 + firework * 20);
        final x = centerX + distance * math.cos(angle);
        final y = centerY + distance * math.sin(angle);
        
        paint.color = color.withValues(
          alpha: (1 - progress) * 0.8,
        );
        
        canvas.drawCircle(
          Offset(x, y),
          3 * (1 - progress),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FireworksPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}