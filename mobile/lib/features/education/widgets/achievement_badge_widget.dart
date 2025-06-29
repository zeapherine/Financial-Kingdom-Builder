import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/config/duolingo_theme.dart';

class AchievementBadgeWidget extends StatefulWidget {
  final String title;
  final String description;
  final bool isUnlocked;
  final IconData icon;
  final Color? color;

  const AchievementBadgeWidget({
    super.key,
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.icon,
    this.color,
  });

  @override
  State<AchievementBadgeWidget> createState() => _AchievementBadgeWidgetState();
}

class _AchievementBadgeWidgetState extends State<AchievementBadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    if (widget.isUnlocked) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = widget.color ?? _getBadgeColor();

    return GestureDetector(
      onTap: widget.isUnlocked ? _playUnlockAnimation : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isUnlocked ? _scaleAnimation.value : 0.9,
            child: Transform.rotate(
              angle: widget.isUnlocked ? _rotationAnimation.value : 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                  boxShadow: widget.isUnlocked 
                      ? [
                          BoxShadow(
                            color: badgeColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        decoration: BoxDecoration(
                          gradient: widget.isUnlocked
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    badgeColor,
                                    badgeColor.withValues(alpha: 0.8),
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    DuolingoTheme.mediumGray,
                                    DuolingoTheme.lightGray,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Badge icon with custom painting
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: widget.isUnlocked 
                                      ? DuolingoTheme.white.withValues(alpha: 0.9)
                                      : DuolingoTheme.white.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                  boxShadow: widget.isUnlocked 
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: CustomPaint(
                                  painter: _BadgeIconPainter(
                                    icon: widget.icon,
                                    color: widget.isUnlocked ? badgeColor : DuolingoTheme.mediumGray,
                                    isUnlocked: widget.isUnlocked,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                              const SizedBox(height: DuolingoTheme.spacingSm),
                              
                              // Title
                              Text(
                                widget.title,
                                style: DuolingoTheme.bodySmall.copyWith(
                                  color: widget.isUnlocked 
                                      ? DuolingoTheme.white 
                                      : DuolingoTheme.darkGray,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: DuolingoTheme.spacingXs),
                              
                              // Description
                              Text(
                                widget.description,
                                style: DuolingoTheme.caption.copyWith(
                                  color: widget.isUnlocked 
                                      ? DuolingoTheme.white.withValues(alpha: 0.9)
                                      : DuolingoTheme.mediumGray,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Shimmer effect for unlocked badges
                      if (widget.isUnlocked)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ShimmerPainter(
                              animation: _shimmerAnimation,
                              borderRadius: DuolingoTheme.radiusLarge,
                            ),
                          ),
                        ),
                      
                      // Lock overlay for locked badges
                      if (!widget.isUnlocked)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.lock,
                                color: DuolingoTheme.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBadgeColor() {
    switch (widget.icon) {
      case Icons.play_arrow:
        return DuolingoTheme.duoGreen;
      case Icons.search:
        return DuolingoTheme.duoBlue;
      case Icons.flash_on:
        return DuolingoTheme.duoYellow;
      case Icons.school:
        return DuolingoTheme.duoPurple;
      case Icons.trending_up:
        return DuolingoTheme.duoOrange;
      case Icons.castle:
        return DuolingoTheme.duoRed;
      default:
        return DuolingoTheme.duoYellow;
    }
  }

  void _playUnlockAnimation() {
    _animationController.reset();
    _animationController.forward();
  }
}

class _BadgeIconPainter extends CustomPainter {
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  _BadgeIconPainter({
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw icon using TextPainter
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 24,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    // Add star sparkles for unlocked badges
    if (isUnlocked) {
      _drawSparkles(canvas, size, paint);
    }
  }

  void _drawSparkles(Canvas canvas, Size size, Paint paint) {
    final sparklePaint = Paint()
      ..color = DuolingoTheme.duoYellow.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Draw small sparkles around the icon
    final sparklePositions = [
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.35),
      Offset(size.width * 0.25, size.height * 0.8),
      Offset(size.width * 0.75, size.height * 0.15),
    ];

    for (final position in sparklePositions) {
      _drawStar(canvas, position, 3, sparklePaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const numPoints = 4;
    final path = Path();
    
    for (int i = 0; i < numPoints * 2; i++) {
      final angle = (i * 3.14159) / numPoints;
      final r = i.isEven ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ShimmerPainter extends CustomPainter {
  final Animation<double> animation;
  final double borderRadius;

  _ShimmerPainter({
    required this.animation,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    canvas.clipRRect(rrect);

    final shimmerRect = Rect.fromLTWH(
      animation.value * size.width - size.width * 0.3,
      0,
      size.width * 0.3,
      size.height,
    );

    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        DuolingoTheme.white.withValues(alpha: 0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(shimmerRect);

    canvas.drawRect(shimmerRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

