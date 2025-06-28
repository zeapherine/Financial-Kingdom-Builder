import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/config/duolingo_theme.dart';

class EnhancedProgressWidget extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final String title;
  final String subtitle;
  final int currentXP;
  final int targetXP;
  final List<Achievement> achievements;
  final Function(Achievement)? onAchievementUnlocked;

  const EnhancedProgressWidget({
    super.key,
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.currentXP,
    required this.targetXP,
    required this.achievements,
    this.onAchievementUnlocked,
  });

  @override
  State<EnhancedProgressWidget> createState() => _EnhancedProgressWidgetState();
}

class _EnhancedProgressWidgetState extends State<EnhancedProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _achievementController;
  late AnimationController _xpController;
  late Animation<double> _progressAnimation;
  late Animation<double> _achievementAnimation;
  late Animation<double> _xpAnimation;
  late Animation<double> _xpCountAnimation;
  
  double _lastProgress = 0.0;
  int _lastXP = 0;
  Achievement? _currentUnlockedAchievement;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _achievementController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _xpController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    _achievementAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _achievementController,
      curve: Curves.elasticOut,
    ));
    
    _xpAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _xpController,
      curve: Curves.bounceOut,
    ));
    
    _xpCountAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentXP.toDouble(),
    ).animate(CurvedAnimation(
      parent: _xpController,
      curve: Curves.easeOut,
    ));
    
    _lastProgress = widget.progress;
    _lastXP = widget.currentXP;
    
    // Start initial animations
    _progressController.forward();
    _xpController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _achievementController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EnhancedProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate progress changes
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _lastProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _lastProgress = widget.progress;
      _progressController.reset();
      _progressController.forward();
    }
    
    // Animate XP changes
    if (oldWidget.currentXP != widget.currentXP) {
      _xpCountAnimation = Tween<double>(
        begin: _lastXP.toDouble(),
        end: widget.currentXP.toDouble(),
      ).animate(CurvedAnimation(
        parent: _xpController,
        curve: Curves.easeOut,
      ));
      _lastXP = widget.currentXP;
      _xpController.reset();
      _xpController.forward();
    }
    
    // Check for new achievements
    final newAchievements = widget.achievements
        .where((a) => a.isUnlocked && !oldWidget.achievements.any((old) => old.id == a.id && old.isUnlocked))
        .toList();
    
    if (newAchievements.isNotEmpty) {
      _showAchievementUnlock(newAchievements.first);
    }
  }

  void _showAchievementUnlock(Achievement achievement) {
    setState(() {
      _currentUnlockedAchievement = achievement;
    });
    
    _achievementController.reset();
    _achievementController.forward();
    
    if (widget.onAchievementUnlocked != null) {
      widget.onAchievementUnlocked!(achievement);
    }
    
    // Hide achievement notification after delay
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _currentUnlockedAchievement = null;
        });
      }
    });
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.auto_graph,
                color: DuolingoTheme.duoGreen,
                size: 28,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: DuolingoTheme.h3.copyWith(
                        color: DuolingoTheme.charcoal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.subtitle,
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
          
          // Main Progress Bar
          _buildMainProgressBar(),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // XP Progress
          _buildXPProgress(),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Achievement Grid
          _buildAchievementGrid(),
          
          // Achievement Unlock Notification
          if (_currentUnlockedAchievement != null) ...[
            const SizedBox(height: DuolingoTheme.spacingMd),
            _buildAchievementNotification(),
          ],
        ],
      ),
    );
  }

  Widget _buildMainProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: DuolingoTheme.bodyLarge.copyWith(
                color: DuolingoTheme.charcoal,
                fontWeight: FontWeight.w600,
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Text(
                  '${(_progressAnimation.value * 100).toInt()}%',
                  style: DuolingoTheme.bodyLarge.copyWith(
                    color: DuolingoTheme.duoGreen,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: DuolingoTheme.spacingSm),
        
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: DuolingoTheme.lightGray,
            borderRadius: BorderRadius.circular(6),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: DuolingoTheme.lightGray,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  
                  // Progress fill
                  FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DuolingoTheme.duoGreen,
                            DuolingoTheme.duoGreenLight,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
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
                  
                  // Shimmer effect
                  if (_progressAnimation.value > 0) ...[
                    _buildShimmerEffect(),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + (_progressController.value * 2), 0.0),
              end: Alignment(1.0 + (_progressController.value * 2), 0.0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildXPProgress() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DuolingoTheme.duoYellow.withValues(alpha: 0.1),
            DuolingoTheme.duoOrange.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.duoYellow.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: DuolingoTheme.duoYellow,
                    size: 20,
                  ),
                  const SizedBox(width: DuolingoTheme.spacingXs),
                  Text(
                    'Experience Points',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.charcoal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _xpCountAnimation,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _xpAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (0.2 * _xpAnimation.value * math.sin(_xpAnimation.value * math.pi * 4)),
                        child: Text(
                          '${_xpCountAnimation.value.toInt()} / ${widget.targetXP} XP',
                          style: DuolingoTheme.bodyLarge.copyWith(
                            color: DuolingoTheme.duoYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          // XP Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: DuolingoTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedBuilder(
              animation: _xpCountAnimation,
              builder: (context, child) {
                final xpProgress = widget.targetXP > 0 ? _xpCountAnimation.value / widget.targetXP : 0.0;
                return FractionallySizedBox(
                  widthFactor: math.min(1.0, xpProgress),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DuolingoTheme.duoYellow,
                          DuolingoTheme.duoOrange,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: DuolingoTheme.h4.copyWith(
            color: DuolingoTheme.charcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: DuolingoTheme.spacingMd),
        
        Wrap(
          spacing: DuolingoTheme.spacingSm,
          runSpacing: DuolingoTheme.spacingSm,
          children: widget.achievements.map((achievement) {
            return _buildAchievementBadge(achievement);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(Achievement achievement) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? DuolingoTheme.duoPurple
            : DuolingoTheme.lightGray,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: achievement.isUnlocked
              ? DuolingoTheme.duoPurple
              : DuolingoTheme.mediumGray,
          width: 2,
        ),
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: DuolingoTheme.duoPurple.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            color: achievement.isUnlocked ? Colors.white : DuolingoTheme.mediumGray,
            size: 24,
          ),
          const SizedBox(height: DuolingoTheme.spacingXs),
          Text(
            achievement.name,
            style: DuolingoTheme.bodySmall.copyWith(
              color: achievement.isUnlocked ? Colors.white : DuolingoTheme.mediumGray,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementNotification() {
    return AnimatedBuilder(
      animation: _achievementAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _achievementAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DuolingoTheme.duoPurple,
                  DuolingoTheme.duoPurple.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: DuolingoTheme.duoPurple.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _currentUnlockedAchievement!.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: DuolingoTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievement Unlocked!',
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _currentUnlockedAchievement!.name,
                        style: DuolingoTheme.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentUnlockedAchievement!.description,
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.celebration,
                  color: DuolingoTheme.duoYellow,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final int requiredXP;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.requiredXP,
  });
}

// Milestone Progress Widget for learning paths
class MilestoneProgressWidget extends StatefulWidget {
  final List<LearningMilestone> milestones;
  final int currentMilestone;
  final double currentProgress;

  const MilestoneProgressWidget({
    super.key,
    required this.milestones,
    required this.currentMilestone,
    required this.currentProgress,
  });

  @override
  State<MilestoneProgressWidget> createState() => _MilestoneProgressWidgetState();
}

class _MilestoneProgressWidgetState extends State<MilestoneProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _pathController;
  late Animation<double> _pathAnimation;

  @override
  void initState() {
    super.initState();
    
    _pathController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pathAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pathController,
      curve: Curves.easeInOut,
    ));
    
    _pathController.forward();
  }

  @override
  void dispose() {
    _pathController.dispose();
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Path',
            style: DuolingoTheme.h3.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _pathAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: MilestonePathPainter(
                    milestones: widget.milestones,
                    currentMilestone: widget.currentMilestone,
                    currentProgress: widget.currentProgress,
                    animationProgress: _pathAnimation.value,
                  ),
                  size: const Size(double.infinity, 200),
                );
              },
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Current milestone info
          if (widget.currentMilestone < widget.milestones.length) ...[
            Container(
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              decoration: BoxDecoration(
                color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                border: Border.all(
                  color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Milestone',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.duoBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  Text(
                    widget.milestones[widget.currentMilestone].title,
                    style: DuolingoTheme.bodyLarge.copyWith(
                      color: DuolingoTheme.charcoal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.milestones[widget.currentMilestone].description,
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LearningMilestone {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;

  const LearningMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
  });
}

class MilestonePathPainter extends CustomPainter {
  final List<LearningMilestone> milestones;
  final int currentMilestone;
  final double currentProgress;
  final double animationProgress;

  MilestonePathPainter({
    required this.milestones,
    required this.currentMilestone,
    required this.currentProgress,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Calculate positions
    final spacing = size.width / (milestones.length - 1);
    final pathY = size.height / 2;

    // Draw path line
    strokePaint.color = DuolingoTheme.lightGray;
    canvas.drawLine(
      Offset(30, pathY),
      Offset(size.width - 30, pathY),
      strokePaint,
    );

    // Draw progress line
    final progressWidth = (currentMilestone + currentProgress) * spacing;
    final animatedWidth = progressWidth * animationProgress;
    
    strokePaint.color = DuolingoTheme.duoGreen;
    canvas.drawLine(
      Offset(30, pathY),
      Offset(30 + animatedWidth, pathY),
      strokePaint,
    );

    // Draw milestones
    for (int i = 0; i < milestones.length; i++) {
      final x = 30 + i * spacing;
      final milestone = milestones[i];
      
      // Determine milestone state
      Color milestoneColor;
      if (i < currentMilestone) {
        milestoneColor = DuolingoTheme.duoGreen; // Completed
      } else if (i == currentMilestone) {
        milestoneColor = DuolingoTheme.duoBlue; // Current
      } else {
        milestoneColor = DuolingoTheme.lightGray; // Future
      }

      // Draw milestone circle
      paint.color = milestoneColor;
      canvas.drawCircle(Offset(x, pathY), 20, paint);

      // Draw milestone icon
      if (i <= currentMilestone * animationProgress) {
        // Note: In a real implementation, you'd use proper icon drawing
        // For now, we'll draw a simple shape
        paint.color = Colors.white;
        canvas.drawCircle(Offset(x, pathY), 12, paint);
      }

      // Draw milestone label
      final textPainter = TextPainter(
        text: TextSpan(
          text: milestone.title,
          style: TextStyle(
            color: DuolingoTheme.charcoal,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, pathY + 35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is MilestonePathPainter &&
        (oldDelegate.currentMilestone != currentMilestone ||
         oldDelegate.currentProgress != currentProgress ||
         oldDelegate.animationProgress != animationProgress);
  }
}