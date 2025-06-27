import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';

/// Custom kingdom building widgets with programmatic visual design
/// These components create visually appealing buildings using Flutter widgets
/// and custom painting, following the Duolingo-inspired design system

class TownCenterBuilding extends StatefulWidget {
  final bool isUnlocked;
  final VoidCallback? onTap;

  const TownCenterBuilding({
    super.key,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<TownCenterBuilding> createState() => _TownCenterBuildingState();
}

class _TownCenterBuildingState extends State<TownCenterBuilding>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isUnlocked ? (_) => _animationController.forward() : null,
      onTapUp: (_) {
        _animationController.reverse();
        if (widget.isUnlocked && widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: DuoCard(
              type: DuoCardType.lesson,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Castle visual representation
                  SizedBox(
                    width: 100,
                    height: 80,
                    child: CustomPaint(
                      painter: _CastlePainter(
                        isUnlocked: widget.isUnlocked,
                      ),
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Town Center',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.isUnlocked 
                          ? DuolingoTheme.charcoal 
                          : DuolingoTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  Text(
                    'Kingdom Management',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: widget.isUnlocked 
                          ? DuolingoTheme.darkGray 
                          : DuolingoTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LibraryBuilding extends StatefulWidget {
  final bool isUnlocked;
  final VoidCallback? onTap;

  const LibraryBuilding({
    super.key,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<LibraryBuilding> createState() => _LibraryBuildingState();
}

class _LibraryBuildingState extends State<LibraryBuilding>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isUnlocked ? (_) => _animationController.forward() : null,
      onTapUp: (_) {
        _animationController.reverse();
        if (widget.isUnlocked && widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: DuoCard(
              type: DuoCardType.lesson,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Library visual representation
                  SizedBox(
                    width: 100,
                    height: 80,
                    child: CustomPaint(
                      painter: _LibraryPainter(
                        isUnlocked: widget.isUnlocked,
                      ),
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Library',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.isUnlocked 
                          ? DuolingoTheme.charcoal 
                          : DuolingoTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  Text(
                    'Learn & Study',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: widget.isUnlocked 
                          ? DuolingoTheme.darkGray 
                          : DuolingoTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TradingPostBuilding extends StatefulWidget {
  final bool isUnlocked;
  final VoidCallback? onTap;

  const TradingPostBuilding({
    super.key,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<TradingPostBuilding> createState() => _TradingPostBuildingState();
}

class _TradingPostBuildingState extends State<TradingPostBuilding>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isUnlocked ? (_) => _animationController.forward() : null,
      onTapUp: (_) {
        _animationController.reverse();
        if (widget.isUnlocked && widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: DuoCard(
              type: DuoCardType.lesson,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trading post visual representation
                  SizedBox(
                    width: 100,
                    height: 80,
                    child: CustomPaint(
                      painter: _TradingPostPainter(
                        isUnlocked: widget.isUnlocked,
                      ),
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Trading Post',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.isUnlocked 
                          ? DuolingoTheme.charcoal 
                          : DuolingoTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  Text(
                    'Practice Trading',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: widget.isUnlocked 
                          ? DuolingoTheme.darkGray 
                          : DuolingoTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TreasuryBuilding extends StatefulWidget {
  final bool isUnlocked;
  final VoidCallback? onTap;

  const TreasuryBuilding({
    super.key,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<TreasuryBuilding> createState() => _TreasuryBuildingState();
}

class _TreasuryBuildingState extends State<TreasuryBuilding>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isUnlocked ? (_) => _animationController.forward() : null,
      onTapUp: (_) {
        _animationController.reverse();
        if (widget.isUnlocked && widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: DuoCard(
              type: DuoCardType.lesson,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Treasury visual representation
                  SizedBox(
                    width: 100,
                    height: 80,
                    child: CustomPaint(
                      painter: _TreasuryPainter(
                        isUnlocked: widget.isUnlocked,
                      ),
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Treasury',
                    style: DuolingoTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.isUnlocked 
                          ? DuolingoTheme.charcoal 
                          : DuolingoTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  Text(
                    'Manage Portfolio',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: widget.isUnlocked 
                          ? DuolingoTheme.darkGray 
                          : DuolingoTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for castle/town center design
class _CastlePainter extends CustomPainter {
  final bool isUnlocked;

  _CastlePainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoGreen : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.duoGreenDark : DuolingoTheme.darkGray;

    // Draw main castle structure
    final mainRect = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainRect, const Radius.circular(4)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainRect, const Radius.circular(4)),
      outlinePaint,
    );

    // Draw left tower
    final leftTower = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.2,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftTower, const Radius.circular(4)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftTower, const Radius.circular(4)),
      outlinePaint,
    );

    // Draw right tower
    final rightTower = Rect.fromLTWH(
      size.width * 0.7,
      size.height * 0.2,
      size.width * 0.2,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightTower, const Radius.circular(4)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightTower, const Radius.circular(4)),
      outlinePaint,
    );

    // Draw flags on towers
    if (isUnlocked) {
      final flagPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      // Left flag
      final leftFlag = Path()
        ..moveTo(size.width * 0.15, size.height * 0.15)
        ..lineTo(size.width * 0.25, size.height * 0.15)
        ..lineTo(size.width * 0.22, size.height * 0.2)
        ..lineTo(size.width * 0.15, size.height * 0.2)
        ..close();
      canvas.drawPath(leftFlag, flagPaint);

      // Right flag
      final rightFlag = Path()
        ..moveTo(size.width * 0.75, size.height * 0.15)
        ..lineTo(size.width * 0.85, size.height * 0.15)
        ..lineTo(size.width * 0.82, size.height * 0.2)
        ..lineTo(size.width * 0.75, size.height * 0.2)
        ..close();
      canvas.drawPath(rightFlag, flagPaint);
    }

    // Draw castle gate
    final gatePaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoGreenDark : DuolingoTheme.darkGray;

    final gate = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.65,
      size.width * 0.3,
      size.height * 0.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gate, const Radius.circular(8)),
      gatePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for library design with book/scroll elements
class _LibraryPainter extends CustomPainter {
  final bool isUnlocked;

  _LibraryPainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.duoBlueDark : DuolingoTheme.darkGray;

    // Draw main library building
    final building = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.3,
      size.width * 0.7,
      size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(6)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(6)),
      outlinePaint,
    );

    // Draw columns
    final columnPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoBlueLight : DuolingoTheme.lightGray;

    for (int i = 0; i < 3; i++) {
      final column = Rect.fromLTWH(
        size.width * (0.25 + i * 0.2),
        size.height * 0.4,
        size.width * 0.08,
        size.height * 0.6,
      );
      canvas.drawRect(column, columnPaint);
    }

    // Draw books on shelves
    if (isUnlocked) {
      final bookColors = [
        DuolingoTheme.duoYellow,
        DuolingoTheme.duoOrange,
        DuolingoTheme.duoRed,
        DuolingoTheme.duoPurple,
      ];

      for (int shelf = 0; shelf < 2; shelf++) {
        for (int book = 0; book < 4; book++) {
          final bookPaint = Paint()
            ..color = bookColors[book % bookColors.length];

          final bookRect = Rect.fromLTWH(
            size.width * (0.2 + book * 0.15),
            size.height * (0.15 + shelf * 0.1),
            size.width * 0.12,
            size.height * 0.08,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(bookRect, const Radius.circular(2)),
            bookPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for trading post with market stall design
class _TradingPostPainter extends CustomPainter {
  final bool isUnlocked;

  _TradingPostPainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final tentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoOrange : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.duoOrange : DuolingoTheme.darkGray;

    // Draw tent/stall structure
    final tentPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.8)
      ..close();

    canvas.drawPath(tentPath, tentPaint);
    canvas.drawPath(tentPath, outlinePaint);

    // Draw support poles
    final polePaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray
      ..strokeWidth = 4.0;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 1.0),
      polePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 1.0),
      polePaint,
    );

    // Draw trading goods
    if (isUnlocked) {
      final goodsPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      // Draw crates/boxes
      for (int i = 0; i < 3; i++) {
        final box = Rect.fromLTWH(
          size.width * (0.25 + i * 0.2),
          size.height * 0.65,
          size.width * 0.15,
          size.width * 0.15,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(box, const Radius.circular(3)),
          goodsPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for treasury with vault/treasure chest design
class _TreasuryPainter extends CustomPainter {
  final bool isUnlocked;

  _TreasuryPainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final vaultPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoYellow : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.duoOrange : DuolingoTheme.darkGray;

    // Draw main vault building
    final vault = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.3,
      size.width * 0.8,
      size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vault, const Radius.circular(8)),
      vaultPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vault, const Radius.circular(8)),
      outlinePaint,
    );

    // Draw vault door
    final doorPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    final door = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.45,
      size.width * 0.3,
      size.height * 0.4,
    );
    canvas.drawOval(door, doorPaint);

    // Draw door handle
    final handlePaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoOrange : DuolingoTheme.mediumGray;

    final handle = Rect.fromLTWH(
      size.width * 0.6,
      size.height * 0.6,
      size.width * 0.05,
      size.height * 0.1,
    );
    canvas.drawOval(handle, handlePaint);

    // Draw treasure coins scattered around
    if (isUnlocked) {
      final coinPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      final coinPositions = [
        Offset(size.width * 0.15, size.height * 0.2),
        Offset(size.width * 0.25, size.height * 0.15),
        Offset(size.width * 0.75, size.height * 0.2),
        Offset(size.width * 0.85, size.height * 0.15),
      ];

      for (final position in coinPositions) {
        canvas.drawCircle(position, size.width * 0.04, coinPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}