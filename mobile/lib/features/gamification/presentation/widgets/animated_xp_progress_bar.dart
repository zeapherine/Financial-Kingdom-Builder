import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/xp_system.dart';

class AnimatedXPProgressBar extends StatefulWidget {
  final UserLevel userLevel;
  final double height;
  final bool showDetails;
  final Duration animationDuration;

  const AnimatedXPProgressBar({
    super.key,
    required this.userLevel,
    this.height = 12.0,
    this.showDetails = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedXPProgressBar> createState() => _AnimatedXPProgressBarState();
}

class _AnimatedXPProgressBarState extends State<AnimatedXPProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.userLevel.progressToNextLevel,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedXPProgressBar oldWidget) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showDetails) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${widget.userLevel.level}',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DuolingoTheme.duoPurple,
                ),
              ),
              Text(
                '${widget.userLevel.xpToNextLevel} XP to next level',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
        ],
        
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.height / 2),
                boxShadow: [
                  BoxShadow(
                    color: DuolingoTheme.duoYellow.withValues(
                      alpha: 0.3 * _glowAnimation.value,
                    ),
                    blurRadius: 8 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background
                  Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: DuolingoTheme.lightGray,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                  ),
                  
                  // Progress fill
                  FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DuolingoTheme.duoYellow,
                            DuolingoTheme.duoOrange,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: DuolingoTheme.duoYellow.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Shine effect
                  if (_progressAnimation.value > 0)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width * _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(widget.height / 2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        
        if (widget.showDetails) ...[
          const SizedBox(height: DuolingoTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.userLevel.currentXp - widget.userLevel.xpForCurrentLevel} XP',
                style: DuolingoTheme.caption.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
              Text(
                '${widget.userLevel.xpForNextLevel - widget.userLevel.xpForCurrentLevel} XP',
                style: DuolingoTheme.caption.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class CircularXPProgress extends StatefulWidget {
  final UserLevel userLevel;
  final double size;
  final double strokeWidth;
  final Duration animationDuration;

  const CircularXPProgress({
    super.key,
    required this.userLevel,
    this.size = 80.0,
    this.strokeWidth = 8.0,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<CircularXPProgress> createState() => _CircularXPProgressState();
}

class _CircularXPProgressState extends State<CircularXPProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: widget.strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                DuolingoTheme.lightGray,
              ),
            ),
          ),
          
          // Progress circle
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DuolingoTheme.duoYellow,
                  ),
                ),
              );
            },
          ),
          
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.userLevel.level}',
                style: DuolingoTheme.h3.copyWith(
                  color: DuolingoTheme.duoPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Level',
                style: DuolingoTheme.caption.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class XPProgressCard extends StatelessWidget {
  final UserLevel userLevel;
  final VoidCallback? onTap;

  const XPProgressCard({
    super.key,
    required this.userLevel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        decoration: BoxDecoration(
          color: DuolingoTheme.white,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
          boxShadow: DuolingoTheme.cardShadow,
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
                CircularXPProgress(
                  userLevel: userLevel,
                  size: 60,
                  strokeWidth: 6,
                ),
                const SizedBox(width: DuolingoTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userLevel.title,
                        style: DuolingoTheme.h4.copyWith(
                          color: DuolingoTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: DuolingoTheme.spacingXs),
                      Text(
                        '${userLevel.currentXp} XP',
                        style: DuolingoTheme.bodyMedium.copyWith(
                          color: DuolingoTheme.duoYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DuolingoTheme.spacingMd),
            AnimatedXPProgressBar(
              userLevel: userLevel,
              height: 8,
              showDetails: false,
            ),
            const SizedBox(height: DuolingoTheme.spacingSm),
            Text(
              '${userLevel.xpToNextLevel} XP to next level',
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}