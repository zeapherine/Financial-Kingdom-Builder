import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/xp_system.dart';

class AnimatedXPMultiplierDisplay extends StatefulWidget {
  final List<XPMultiplier> activeMultipliers;
  final double currentMultiplier;
  final bool showGlowEffect;

  const AnimatedXPMultiplierDisplay({
    super.key,
    required this.activeMultipliers,
    required this.currentMultiplier,
    this.showGlowEffect = true,
  });

  @override
  State<AnimatedXPMultiplierDisplay> createState() => _AnimatedXPMultiplierDisplayState();
}

class _AnimatedXPMultiplierDisplayState extends State<AnimatedXPMultiplierDisplay>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    if (widget.showGlowEffect && widget.currentMultiplier > 1.0) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void didUpdateWidget(AnimatedXPMultiplierDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentMultiplier != widget.currentMultiplier) {
      if (widget.currentMultiplier > 1.0 && widget.showGlowEffect) {
        _startAnimations();
      } else {
        _glowController.stop();
        _pulseController.stop();
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Color _getMultiplierColor() {
    if (widget.currentMultiplier <= 1.0) return DuolingoTheme.mediumGray;
    if (widget.currentMultiplier <= 1.5) return DuolingoTheme.duoGreen;
    if (widget.currentMultiplier <= 2.0) return DuolingoTheme.duoBlue;
    if (widget.currentMultiplier <= 3.0) return DuolingoTheme.duoPurple;
    return DuolingoTheme.duoYellow;
  }

  @override
  Widget build(BuildContext context) {
    final multiplierColor = _getMultiplierColor();
    final hasMultiplier = widget.currentMultiplier > 1.0;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: hasMultiplier ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: hasMultiplier
                  ? RadialGradient(
                      colors: [
                        multiplierColor.withValues(alpha: 0.3 * _glowAnimation.value),
                        multiplierColor.withValues(alpha: 0.1 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    )
                  : null,
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
              border: hasMultiplier
                  ? Border.all(
                      color: multiplierColor.withValues(alpha: 0.5 * _glowAnimation.value),
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main multiplier display
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: hasMultiplier
                        ? LinearGradient(
                            colors: [
                              multiplierColor.withValues(alpha: 0.8),
                              multiplierColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: hasMultiplier ? null : DuolingoTheme.lightGray,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasMultiplier ? multiplierColor : DuolingoTheme.mediumGray,
                      width: 3,
                    ),
                    boxShadow: hasMultiplier
                        ? [
                            BoxShadow(
                              color: multiplierColor.withValues(
                                alpha: 0.6 * _glowAnimation.value,
                              ),
                              blurRadius: 20 * _glowAnimation.value,
                              spreadRadius: 5 * _glowAnimation.value,
                            ),
                          ]
                        : [],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating background effect
                      if (hasMultiplier)
                        Transform.rotate(
                          angle: _rotationAnimation.value * 2 * math.pi,
                          child: CustomPaint(
                            size: const Size(80, 80),
                            painter: MultiplierBackgroundPainter(
                              color: DuolingoTheme.white.withValues(alpha: 0.2),
                              progress: _rotationAnimation.value,
                            ),
                          ),
                        ),
                      
                      // Multiplier text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.currentMultiplier.toStringAsFixed(1)}x',
                            style: DuolingoTheme.h3.copyWith(
                              color: hasMultiplier ? DuolingoTheme.white : DuolingoTheme.darkGray,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          
                          Text(
                            'XP',
                            style: DuolingoTheme.bodySmall.copyWith(
                              color: hasMultiplier 
                                  ? DuolingoTheme.white.withValues(alpha: 0.8)
                                  : DuolingoTheme.darkGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      // Sparkle effects for high multipliers
                      if (hasMultiplier && widget.currentMultiplier >= 2.0)
                        ...List.generate(6, (index) {
                          final angle = (index * 60) * (math.pi / 180);
                          final distance = 35 + (5 * math.sin(_glowAnimation.value * 2 * math.pi));
                          final x = distance * math.cos(angle + _rotationAnimation.value * 2 * math.pi);
                          final y = distance * math.sin(angle + _rotationAnimation.value * 2 * math.pi);
                          
                          return Positioned(
                            left: 40 + x - 3,
                            top: 40 + y - 3,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: DuolingoTheme.white.withValues(alpha: _glowAnimation.value),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                
                const SizedBox(height: DuolingoTheme.spacingMd),
                
                // Active multipliers list
                if (widget.activeMultipliers.isNotEmpty)
                  Column(
                    children: widget.activeMultipliers.map((multiplier) =>
                      MultiplierChip(
                        multiplier: multiplier,
                        glowIntensity: _glowAnimation.value,
                      ),
                    ).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MultiplierChip extends StatelessWidget {
  final XPMultiplier multiplier;
  final double glowIntensity;

  const MultiplierChip({
    super.key,
    required this.multiplier,
    this.glowIntensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getMultiplierTypeColor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: DuolingoTheme.spacingXs),
      padding: const EdgeInsets.symmetric(
        horizontal: DuolingoTheme.spacingSm,
        vertical: DuolingoTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2 * glowIntensity),
            color.withValues(alpha: 0.1 * glowIntensity),
          ],
        ),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
        border: Border.all(
          color: color.withValues(alpha: 0.4 * glowIntensity),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getMultiplierIcon(),
            size: 14,
            color: color,
          ),
          
          const SizedBox(width: DuolingoTheme.spacingXs),
          
          Text(
            '${multiplier.value}x',
            style: DuolingoTheme.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(width: DuolingoTheme.spacingXs),
          
          Flexible(
            child: Text(
              multiplier.description,
              style: DuolingoTheme.caption.copyWith(
                color: DuolingoTheme.darkGray,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          if (multiplier.expiresAt != null) ...[
            const SizedBox(width: DuolingoTheme.spacingXs),
            
            Icon(
              Icons.schedule,
              size: 12,
              color: DuolingoTheme.duoRed,
            ),
          ],
        ],
      ),
    );
  }

  Color _getMultiplierTypeColor() {
    switch (multiplier.type) {
      case 'streak_hot':
      case 'streak_fire':
      case 'streak_legendary':
        return DuolingoTheme.duoOrange;
      case 'weekend_bonus':
      case 'early_bird':
        return DuolingoTheme.duoBlue;
      case 'achievement':
      case 'level_up':
        return DuolingoTheme.duoPurple;
      case 'premium':
      case 'special_event':
        return DuolingoTheme.duoYellow;
      default:
        return DuolingoTheme.duoGreen;
    }
  }

  IconData _getMultiplierIcon() {
    switch (multiplier.type) {
      case 'streak_hot':
      case 'streak_fire':
      case 'streak_legendary':
        return Icons.local_fire_department;
      case 'weekend_bonus':
        return Icons.weekend;
      case 'early_bird':
        return Icons.wb_sunny;
      case 'achievement':
        return Icons.emoji_events;
      case 'level_up':
        return Icons.trending_up;
      case 'premium':
        return Icons.workspace_premium;
      case 'special_event':
        return Icons.celebration;
      default:
        return Icons.star;
    }
  }
}

class XPMultiplierCard extends StatefulWidget {
  final List<XPMultiplier> activeMultipliers;
  final double currentMultiplier;
  final VoidCallback? onTap;

  const XPMultiplierCard({
    super.key,
    required this.activeMultipliers,
    required this.currentMultiplier,
    this.onTap,
  });

  @override
  State<XPMultiplierCard> createState() => _XPMultiplierCardState();
}

class _XPMultiplierCardState extends State<XPMultiplierCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.currentMultiplier > 1.0) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(XPMultiplierCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentMultiplier != widget.currentMultiplier) {
      if (widget.currentMultiplier > 1.0) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiplier = widget.currentMultiplier > 1.0;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: hasMultiplier
              ? LinearGradient(
                  colors: [
                    DuolingoTheme.duoYellow.withValues(alpha: 0.1),
                    DuolingoTheme.duoOrange.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasMultiplier ? null : DuolingoTheme.white,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
          border: Border.all(
            color: hasMultiplier 
                ? DuolingoTheme.duoYellow.withValues(alpha: 0.3)
                : DuolingoTheme.lightGray,
            width: hasMultiplier ? 2 : 1,
          ),
          boxShadow: hasMultiplier
              ? [
                  BoxShadow(
                    color: DuolingoTheme.duoYellow.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : DuolingoTheme.cardShadow,
        ),
        child: Stack(
          children: [
            // Shimmer effect
            if (hasMultiplier)
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge - 2),
                      child: Transform.translate(
                        offset: Offset(_shimmerAnimation.value * 200, 0),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                DuolingoTheme.white.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: hasMultiplier ? DuolingoTheme.duoYellow : DuolingoTheme.darkGray,
                      size: DuolingoTheme.iconLarge,
                    ),
                    
                    const SizedBox(width: DuolingoTheme.spacingMd),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'XP Multiplier',
                            style: DuolingoTheme.h4.copyWith(
                              color: hasMultiplier ? DuolingoTheme.duoYellow : DuolingoTheme.charcoal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          
                          Text(
                            hasMultiplier 
                                ? 'Active bonuses boosting your XP!'
                                : 'No active multipliers',
                            style: DuolingoTheme.bodySmall.copyWith(
                              color: DuolingoTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Current multiplier badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DuolingoTheme.spacingMd,
                        vertical: DuolingoTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: hasMultiplier 
                            ? DuolingoTheme.duoYellow
                            : DuolingoTheme.lightGray,
                        borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
                      ),
                      child: Text(
                        '${widget.currentMultiplier.toStringAsFixed(1)}x',
                        style: DuolingoTheme.h4.copyWith(
                          color: hasMultiplier ? DuolingoTheme.white : DuolingoTheme.darkGray,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (widget.activeMultipliers.isNotEmpty) ...[
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  
                  Text(
                    'Active Bonuses:',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DuolingoTheme.charcoal,
                    ),
                  ),
                  
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  
                  ...widget.activeMultipliers.map((multiplier) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingXs),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: DuolingoTheme.duoYellow,
                          ),
                          
                          const SizedBox(width: DuolingoTheme.spacingSm),
                          
                          Expanded(
                            child: Text(
                              multiplier.description,
                              style: DuolingoTheme.bodySmall.copyWith(
                                color: DuolingoTheme.darkGray,
                              ),
                            ),
                          ),
                          
                          Text(
                            '+${((multiplier.value - 1) * 100).round()}%',
                            style: DuolingoTheme.bodySmall.copyWith(
                              color: DuolingoTheme.duoGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MultiplierBackgroundPainter extends CustomPainter {
  final Color color;
  final double progress;

  MultiplierBackgroundPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw rotating spokes
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 + progress * 360) * (math.pi / 180);
      final startRadius = radius * 0.5;
      final endRadius = radius * 0.8;
      
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

    // Draw outer ring
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.7, paint);
  }

  @override
  bool shouldRepaint(MultiplierBackgroundPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}