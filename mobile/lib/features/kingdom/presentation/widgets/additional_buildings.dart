import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';

/// Additional kingdom building widgets - Marketplace, Observatory, Academy
/// These extend the kingdom with more advanced features unlocked at higher tiers

class MarketplaceBuilding extends StatefulWidget {
  final bool isUnlocked;
  final VoidCallback? onTap;

  const MarketplaceBuilding({
    super.key,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<MarketplaceBuilding> createState() => _MarketplaceBuildingState();
}

class _MarketplaceBuildingState extends State<MarketplaceBuilding>
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
                  // Marketplace visual representation
                  SizedBox(
                    width: 100,
                    height: 80,
                    child: CustomPaint(
                      painter: _MarketplacePainter(
                        isUnlocked: widget.isUnlocked,
                      ),
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Marketplace',
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
                    'Social Trading',
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

class ObservatoryBuilding extends StatefulWidget {
  final bool isUnlocked;
  final VoidCallback? onTap;

  const ObservatoryBuilding({
    super.key,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<ObservatoryBuilding> createState() => _ObservatoryBuildingState();
}

class _ObservatoryBuildingState extends State<ObservatoryBuilding>
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
                  // Observatory visual representation
                  SizedBox(
                    width: 100,
                    height: 80,
                    child: CustomPaint(
                      painter: _ObservatoryPainter(
                        isUnlocked: widget.isUnlocked,
                      ),
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Observatory',
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
                    'Market Analysis',
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

class AcademyBuilding extends StatefulWidget {
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AcademyBuilding({
    super.key,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  State<AcademyBuilding> createState() => _AcademyBuildingState();
}

class _AcademyBuildingState extends State<AcademyBuilding>
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
                  // Academy visual representation
                  SizedBox(
                    width: 100,
                    height: 80,
                    child: CustomPaint(
                      painter: _AcademyPainter(
                        isUnlocked: widget.isUnlocked,
                      ),
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Academy',
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
                    'Advanced Learning',
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

/// Custom painter for marketplace with bazaar design
class _MarketplacePainter extends CustomPainter {
  final bool isUnlocked;

  _MarketplacePainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw multiple market stalls
    final stallPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoPurple : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Draw three market stalls
    for (int i = 0; i < 3; i++) {
      final stallRect = Rect.fromLTWH(
        size.width * (0.1 + i * 0.25),
        size.height * 0.4,
        size.width * 0.2,
        size.height * 0.6,
      );
      
      // Stall roof (triangular)
      final roofPath = Path()
        ..moveTo(stallRect.left, stallRect.top)
        ..lineTo(stallRect.center.dx, stallRect.top - size.height * 0.15)
        ..lineTo(stallRect.right, stallRect.top)
        ..close();
      
      canvas.drawPath(roofPath, stallPaint);
      canvas.drawPath(roofPath, outlinePaint);
      
      // Stall base
      canvas.drawRect(stallRect, stallPaint);
      canvas.drawRect(stallRect, outlinePaint);
    }

    // Draw goods/products if unlocked
    if (isUnlocked) {
      final goodsPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      // Draw small product boxes
      for (int stall = 0; stall < 3; stall++) {
        for (int item = 0; item < 2; item++) {
          final itemRect = Rect.fromLTWH(
            size.width * (0.12 + stall * 0.25 + item * 0.06),
            size.height * (0.7 + item * 0.05),
            size.width * 0.05,
            size.height * 0.05,
          );
          canvas.drawRect(itemRect, goodsPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for observatory with telescope/tower design
class _ObservatoryPainter extends CustomPainter {
  final bool isUnlocked;

  _ObservatoryPainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final towerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.duoBlueDark : DuolingoTheme.darkGray;

    // Draw main tower
    final tower = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(6)),
      towerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(6)),
      outlinePaint,
    );

    // Draw dome on top
    final dome = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.25,
    );
    canvas.drawOval(dome, towerPaint);
    canvas.drawOval(dome, outlinePaint);

    // Draw telescope if unlocked
    if (isUnlocked) {
      final telescopePaint = Paint()
        ..color = DuolingoTheme.charcoal
        ..strokeWidth = 3.0;

      // Telescope tube
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.15),
        Offset(size.width * 0.75, size.height * 0.05),
        telescopePaint,
      );

      // Telescope lens
      final lensPaint = Paint()
        ..color = DuolingoTheme.duoBlueLight;

      canvas.drawCircle(
        Offset(size.width * 0.75, size.height * 0.05),
        size.width * 0.03,
        lensPaint,
      );
    }

    // Draw windows
    final windowPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoYellow : DuolingoTheme.darkGray;

    for (int i = 0; i < 3; i++) {
      final window = Rect.fromLTWH(
        size.width * 0.35,
        size.height * (0.3 + i * 0.15),
        size.width * 0.3,
        size.height * 0.1,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(window, const Radius.circular(3)),
        windowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for academy with school building design
class _AcademyPainter extends CustomPainter {
  final bool isUnlocked;

  _AcademyPainter({required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoRed : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Draw main building
    final building = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.3,
      size.width * 0.8,
      size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(8)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(8)),
      outlinePaint,
    );

    // Draw roof
    final roofPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    final roofPath = Path()
      ..moveTo(size.width * 0.05, size.height * 0.35)
      ..lineTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.95, size.height * 0.35)
      ..lineTo(size.width * 0.85, size.height * 0.35)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.15, size.height * 0.35)
      ..close();

    canvas.drawPath(roofPath, roofPaint);

    // Draw entrance door
    final doorPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoYellow : DuolingoTheme.darkGray;

    final door = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.6,
      size.width * 0.2,
      size.height * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, const Radius.circular(4)),
      doorPaint,
    );

    // Draw windows on both sides
    final windowPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoBlueLight : DuolingoTheme.mediumGray;

    // Left windows
    for (int i = 0; i < 2; i++) {
      final leftWindow = Rect.fromLTWH(
        size.width * 0.15,
        size.height * (0.4 + i * 0.2),
        size.width * 0.15,
        size.height * 0.15,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(leftWindow, const Radius.circular(3)),
        windowPaint,
      );
    }

    // Right windows
    for (int i = 0; i < 2; i++) {
      final rightWindow = Rect.fromLTWH(
        size.width * 0.7,
        size.height * (0.4 + i * 0.2),
        size.width * 0.15,
        size.height * 0.15,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rightWindow, const Radius.circular(3)),
        windowPaint,
      );
    }

    // Draw bell tower if unlocked
    if (isUnlocked) {
      final towerPaint = Paint()
        ..color = DuolingoTheme.duoOrange;

      final towerRect = Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.05,
        size.width * 0.1,
        size.height * 0.15,
      );
      canvas.drawRect(towerRect, towerPaint);

      // Draw bell
      final bellPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.12),
        size.width * 0.02,
        bellPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}