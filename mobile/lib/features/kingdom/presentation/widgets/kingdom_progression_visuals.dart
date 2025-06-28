import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/kingdom_state.dart';

/// Kingdom Progression Visual System
/// Creates tier-specific visual variations of buildings based on kingdom progression
/// Implements Village -> Town -> City -> Kingdom visual evolution
/// 
/// From /mobile/styles.json:
/// - Uses exact color palette from colorPalette section
/// - Follows spacing values from spacing section  
/// - Applies border radius from borderRadius section
/// - Implements gamification elements with proper colors

class KingdomProgressionBuilder extends StatefulWidget {
  final KingdomTier tier;
  final KingdomBuilding building;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final int buildingLevel;

  const KingdomProgressionBuilder({
    super.key,
    required this.tier,
    required this.building,
    required this.isUnlocked,
    this.onTap,
    this.buildingLevel = 1,
  });

  @override
  State<KingdomProgressionBuilder> createState() => _KingdomProgressionBuilderState();
}

class _KingdomProgressionBuilderState extends State<KingdomProgressionBuilder>
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
            child: Container(
              decoration: BoxDecoration(
                color: DuolingoTheme.white,
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                boxShadow: DuolingoTheme.cardShadow,
              ),
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Building visual representation with tier progression
                  Expanded(
                    flex: 3,
                    child: _getBuildingIcon(),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  
                  // Building name with tier indication
                  Flexible(
                    child: Text(
                      _getBuildingName(),
                      style: DuolingoTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.isUnlocked 
                            ? DuolingoTheme.charcoal 
                            : DuolingoTheme.mediumGray,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  
                  // Unlock status
                  Text(
                    widget.isUnlocked ? 'Unlocked' : 'Locked',
                    style: DuolingoTheme.caption.copyWith(
                      color: widget.isUnlocked 
                          ? DuolingoTheme.darkGray 
                          : DuolingoTheme.mediumGray,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Level indicator if building level > 1
                  if (widget.buildingLevel > 1) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DuolingoTheme.duoYellow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Level ${widget.buildingLevel}',
                        style: DuolingoTheme.caption.copyWith(
                          color: DuolingoTheme.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _getBuildingIcon() {
    return Container(
      decoration: BoxDecoration(
        color: _getBuildingColor(),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
      ),
      child: Center(
        child: Icon(
          _getBuildingIconData(),
          color: widget.isUnlocked ? DuolingoTheme.white : DuolingoTheme.mediumGray,
          size: _getTierSpecificIconSize(),
        ),
      ),
    );
  }

  IconData _getBuildingIconData() {
    switch (widget.building) {
      case KingdomBuilding.townCenter:
        return Icons.castle;
      case KingdomBuilding.library:
        return Icons.local_library;
      case KingdomBuilding.tradingPost:
        return Icons.store_outlined;
      case KingdomBuilding.treasury:
        return Icons.account_balance;
      case KingdomBuilding.marketplace:
        return Icons.store;
      case KingdomBuilding.observatory:
        return Icons.science;
      case KingdomBuilding.academy:
        return Icons.school;
    }
  }

  Color _getBuildingColor() {
    if (!widget.isUnlocked) {
      return DuolingoTheme.mediumGray;
    }
    
    switch (widget.building) {
      case KingdomBuilding.townCenter:
        return DuolingoTheme.duoGreen;
      case KingdomBuilding.library:
        return DuolingoTheme.duoBlue;
      case KingdomBuilding.tradingPost:
        return DuolingoTheme.duoOrange;
      case KingdomBuilding.treasury:
        return DuolingoTheme.duoYellow;
      case KingdomBuilding.marketplace:
        return DuolingoTheme.duoBlue;
      case KingdomBuilding.observatory:
        return DuolingoTheme.duoPurple;
      case KingdomBuilding.academy:
        return DuolingoTheme.duoGreen;
    }
  }

  double _getTierSpecificIconSize() {
    switch (widget.tier) {
      case KingdomTier.village:
        return 24.0;
      case KingdomTier.town:
        return 28.0;
      case KingdomTier.city:
        return 32.0;
      case KingdomTier.kingdom:
        return 36.0;
    }
  }

  String _getBuildingName() {
    switch (widget.building) {
      case KingdomBuilding.townCenter:
        return widget.tier == KingdomTier.village ? 'Village Hall' 
             : widget.tier == KingdomTier.town ? 'Town Hall'
             : widget.tier == KingdomTier.city ? 'City Hall'
             : 'Royal Palace';
      case KingdomBuilding.library:
        return widget.tier == KingdomTier.village ? 'Book Corner'
             : widget.tier == KingdomTier.town ? 'Village Library'
             : widget.tier == KingdomTier.city ? 'Grand Library'
             : 'Royal Archive';
      case KingdomBuilding.tradingPost:
        return widget.tier == KingdomTier.village ? 'Market Stall'
             : widget.tier == KingdomTier.town ? 'Trading Post'
             : widget.tier == KingdomTier.city ? 'Trade Center'
             : 'Royal Exchange';
      case KingdomBuilding.treasury:
        return widget.tier == KingdomTier.village ? 'Coin Pouch'
             : widget.tier == KingdomTier.town ? 'Town Vault'
             : widget.tier == KingdomTier.city ? 'City Treasury'
             : 'Royal Treasury';
      case KingdomBuilding.marketplace:
        return widget.tier == KingdomTier.village ? 'Village Market'
             : widget.tier == KingdomTier.town ? 'Town Bazaar'
             : widget.tier == KingdomTier.city ? 'Grand Marketplace'
             : 'Royal Market';
      case KingdomBuilding.observatory:
        return widget.tier == KingdomTier.village ? 'Lookout Post'
             : widget.tier == KingdomTier.town ? 'Watch Tower'
             : widget.tier == KingdomTier.city ? 'Observatory'
             : 'Royal Observatory';
      case KingdomBuilding.academy:
        return widget.tier == KingdomTier.village ? 'School House'
             : widget.tier == KingdomTier.town ? 'Town School'
             : widget.tier == KingdomTier.city ? 'Academy'
             : 'Royal Academy';
    }
  }

  String _getTierSpecificSubtitle() {
    switch (widget.tier) {
      case KingdomTier.village:
        return 'Simple & Humble';
      case KingdomTier.town:
        return 'Growing & Prosperous';
      case KingdomTier.city:
        return 'Advanced & Sophisticated';
      case KingdomTier.kingdom:
        return 'Majestic & Royal';
    }
  }
}

/// Village Stage (Tier 1): Simple huts and basic structures
/// Earth tones, rounded rectangles, minimal decoration
class _TownCenterProgressionPainter extends CustomPainter {
  final KingdomTier tier;
  final bool isUnlocked;
  final int level;

  _TownCenterProgressionPainter({
    required this.tier,
    required this.isUnlocked,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (tier) {
      case KingdomTier.village:
        _paintVillageHall(canvas, size);
        break;
      case KingdomTier.town:
        _paintTownHall(canvas, size);
        break;
      case KingdomTier.city:
        _paintCityHall(canvas, size);
        break;
      case KingdomTier.kingdom:
        _paintRoyalPalace(canvas, size);
        break;
    }
  }

  void _paintVillageHall(Canvas canvas, Size size) {
    // Village Hall: Simple wooden hut with thatched roof
    final hutPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B4513) : DuolingoTheme.mediumGray; // Brown

    final roofPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFDAA520) : DuolingoTheme.mediumGray; // Goldenrod

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.darkGray;

    // Draw simple hut base
    final hutRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hutRect, const Radius.circular(8)),
      hutPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hutRect, const Radius.circular(8)),
      outlinePaint,
    );

    // Draw thatched roof
    final roofPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.55)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.55)
      ..lineTo(size.width * 0.8, size.height * 0.55)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.2, size.height * 0.55)
      ..close();

    canvas.drawPath(roofPath, roofPaint);
    canvas.drawPath(roofPath, outlinePaint);

    // Simple door
    final doorPaint = Paint()
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.darkGray;

    final door = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.7,
      size.width * 0.2,
      size.height * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, const Radius.circular(4)),
      doorPaint,
    );
  }

  void _paintTownHall(Canvas canvas, Size size) {
    // Town Hall: Enhanced building with stone foundation and wooden upper
    final stonePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF696969) : DuolingoTheme.mediumGray; // DimGray

    final woodPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B4513) : DuolingoTheme.mediumGray; // Brown

    final roofPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B0000) : DuolingoTheme.mediumGray; // DarkRed

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Stone foundation
    final foundation = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.6,
      size.width * 0.7,
      size.height * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(foundation, const Radius.circular(6)),
      stonePaint,
    );

    // Wooden upper level
    final upperLevel = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.25,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(upperLevel, const Radius.circular(6)),
      woodPaint,
    );

    // Enhanced roof with chimney
    final roofPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.9, size.height * 0.45)
      ..close();

    canvas.drawPath(roofPath, roofPaint);
    canvas.drawPath(roofPath, outlinePaint);

    // Chimney
    final chimney = Rect.fromLTWH(
      size.width * 0.7,
      size.height * 0.1,
      size.width * 0.1,
      size.height * 0.2,
    );
    canvas.drawRect(chimney, stonePaint);
    canvas.drawRect(chimney, outlinePaint);

    // Multiple windows
    final windowPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoYellow : DuolingoTheme.darkGray;

    for (int i = 0; i < 2; i++) {
      final window = Rect.fromLTWH(
        size.width * (0.25 + i * 0.3),
        size.width * 0.47,
        size.width * 0.15,
        size.height * 0.1,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(window, const Radius.circular(3)),
        windowPaint,
      );
    }

    // Enhanced door
    final doorPaint = Paint()
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.darkGray;

    final door = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.7,
      size.width * 0.2,
      size.height * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, const Radius.circular(6)),
      doorPaint,
    );
  }

  void _paintCityHall(Canvas canvas, Size size) {
    // City Hall: Multi-story building with classical architecture
    final stonePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFF5F5DC) : DuolingoTheme.mediumGray; // Beige

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main building (3 stories)
    final mainBuilding = Rect.fromLTWH(
      size.width * 0.1,
      size.width * 0.2,
      size.width * 0.8,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainBuilding, const Radius.circular(8)),
      stonePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainBuilding, const Radius.circular(8)),
      outlinePaint,
    );

    // Classical columns
    final columnPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoBlueLight : DuolingoTheme.lightGray;

    for (int i = 0; i < 4; i++) {
      final column = Rect.fromLTWH(
        size.width * (0.15 + i * 0.175),
        size.height * 0.3,
        size.width * 0.06,
        size.height * 0.7,
      );
      canvas.drawRect(column, columnPaint);
    }

    // Clock tower in center
    final tower = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.05,
      size.width * 0.2,
      size.height * 0.25,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(6)),
      accentPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(6)),
      outlinePaint,
    );

    // Clock face
    final clockPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.white : DuolingoTheme.lightGray;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.15),
      size.width * 0.05,
      clockPaint,
    );

    // Flag on top
    if (isUnlocked) {
      final flagPaint = Paint()
        ..color = DuolingoTheme.duoGreen;

      final flagPath = Path()
        ..moveTo(size.width * 0.48, size.height * 0.05)
        ..lineTo(size.width * 0.65, size.height * 0.05)
        ..lineTo(size.width * 0.6, size.height * 0.08)
        ..lineTo(size.width * 0.48, size.height * 0.08)
        ..close();
      canvas.drawPath(flagPath, flagPaint);
    }
  }

  void _paintRoyalPalace(Canvas canvas, Size size) {
    // Royal Palace: Grand castle with multiple towers and ornate details
    final palacePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFFFD700) : DuolingoTheme.mediumGray; // Gold

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoPurple : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main palace structure
    final palace = Rect.fromLTWH(
      size.width * 0.15,
      size.width * 0.3,
      size.width * 0.7,
      size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(palace, const Radius.circular(12)),
      palacePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(palace, const Radius.circular(12)),
      outlinePaint,
    );

    // Multiple towers
    for (int i = 0; i < 3; i++) {
      final tower = Rect.fromLTWH(
        size.width * (0.05 + i * 0.45),
        size.height * 0.1,
        size.width * 0.15,
        size.height * 0.5,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(8)),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(8)),
        outlinePaint,
      );

      // Tower domes
      final dome = Rect.fromLTWH(
        size.width * (0.02 + i * 0.45),
        size.height * 0.05,
        size.width * 0.21,
        size.height * 0.15,
      );
      canvas.drawOval(dome, palacePaint);
      canvas.drawOval(dome, outlinePaint);

      // Flags on towers
      if (isUnlocked) {
        final flagPaint = Paint()
          ..color = DuolingoTheme.duoRed;

        final flagPath = Path()
          ..moveTo(size.width * (0.1 + i * 0.45), size.height * 0.05)
          ..lineTo(size.width * (0.18 + i * 0.45), size.height * 0.05)
          ..lineTo(size.width * (0.16 + i * 0.45), size.height * 0.08)
          ..lineTo(size.width * (0.1 + i * 0.45), size.height * 0.08)
          ..close();
        canvas.drawPath(flagPath, flagPaint);
      }
    }

    // Grand entrance
    final entrancePaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.darkGray;

    final entrance = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.6,
      size.width * 0.3,
      size.height * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(entrance, const Radius.circular(16)),
      entrancePaint,
    );

    // Ornate windows
    final windowPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoYellow : DuolingoTheme.darkGray;

    for (int floor = 0; floor < 2; floor++) {
      for (int window = 0; window < 3; window++) {
        final windowRect = Rect.fromLTWH(
          size.width * (0.2 + window * 0.2),
          size.height * (0.4 + floor * 0.15),
          size.width * 0.12,
          size.height * 0.1,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(windowRect, const Radius.circular(6)),
          windowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Library Progression Painter - Shows evolution from book corner to royal archive
class _LibraryProgressionPainter extends CustomPainter {
  final KingdomTier tier;
  final bool isUnlocked;
  final int level;

  _LibraryProgressionPainter({
    required this.tier,
    required this.isUnlocked,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (tier) {
      case KingdomTier.village:
        _paintBookCorner(canvas, size);
        break;
      case KingdomTier.town:
        _paintVillageLibrary(canvas, size);
        break;
      case KingdomTier.city:
        _paintGrandLibrary(canvas, size);
        break;
      case KingdomTier.kingdom:
        _paintRoyalArchive(canvas, size);
        break;
    }
  }

  void _paintBookCorner(Canvas canvas, Size size) {
    // Simple book shelf in a corner
    final shelfPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B4513) : DuolingoTheme.mediumGray; // Brown

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.darkGray;

    // Simple wooden shelf
    final shelf = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shelf, const Radius.circular(6)),
      shelfPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shelf, const Radius.circular(6)),
      outlinePaint,
    );

    // Few books
    if (isUnlocked) {
      final bookColors = [
        DuolingoTheme.duoRed,
        DuolingoTheme.duoBlue,
        DuolingoTheme.duoYellow,
      ];

      for (int i = 0; i < 3; i++) {
        final bookPaint = Paint()
          ..color = bookColors[i];

        final book = Rect.fromLTWH(
          size.width * (0.25 + i * 0.15),
          size.height * 0.5,
          size.width * 0.1,
          size.height * 0.4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(book, const Radius.circular(2)),
          bookPaint,
        );
      }
    }
  }

  void _paintVillageLibrary(Canvas canvas, Size size) {
    // Enhanced library with multiple shelves
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.duoBlueDark : DuolingoTheme.darkGray;

    // Library building
    final building = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.3,
      size.width * 0.7,
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

    // Multiple book shelves visible through windows
    if (isUnlocked) {
      final bookColors = [
        DuolingoTheme.duoYellow,
        DuolingoTheme.duoOrange,
        DuolingoTheme.duoRed,
        DuolingoTheme.duoPurple,
        DuolingoTheme.duoGreen,
      ];

      for (int shelf = 0; shelf < 2; shelf++) {
        for (int book = 0; book < 5; book++) {
          final bookPaint = Paint()
            ..color = bookColors[book % bookColors.length];

          final bookRect = Rect.fromLTWH(
            size.width * (0.2 + book * 0.12),
            size.height * (0.15 + shelf * 0.1),
            size.width * 0.08,
            size.height * 0.08,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(bookRect, const Radius.circular(2)),
            bookPaint,
          );
        }
      }
    }

    // Library sign
    final signPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoYellow : DuolingoTheme.mediumGray;

    final sign = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.05,
      size.width * 0.4,
      size.height * 0.15,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sign, const Radius.circular(4)),
      signPaint,
    );
  }

  void _paintGrandLibrary(Canvas canvas, Size size) {
    // Large library with classical columns and dome
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFF5F5DC) : DuolingoTheme.mediumGray; // Beige

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main library building
    final building = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.4,
      size.width * 0.8,
      size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(8)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(8)),
      outlinePaint,
    );

    // Classical columns
    final columnPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoBlueLight : DuolingoTheme.lightGray;

    for (int i = 0; i < 4; i++) {
      final column = Rect.fromLTWH(
        size.width * (0.15 + i * 0.175),
        size.height * 0.45,
        size.width * 0.05,
        size.height * 0.55,
      );
      canvas.drawRect(column, columnPaint);
    }

    // Dome on top
    final dome = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.1,
      size.width * 0.4,
      size.height * 0.35,
    );
    canvas.drawOval(dome, accentPaint);
    canvas.drawOval(dome, outlinePaint);

    // Many books visible
    if (isUnlocked) {
      final bookColors = [
        DuolingoTheme.duoYellow,
        DuolingoTheme.duoOrange,
        DuolingoTheme.duoRed,
        DuolingoTheme.duoPurple,
        DuolingoTheme.duoGreen,
        DuolingoTheme.duoBlue,
      ];

      for (int floor = 0; floor < 3; floor++) {
        for (int book = 0; book < 6; book++) {
          final bookPaint = Paint()
            ..color = bookColors[book % bookColors.length];

          final bookRect = Rect.fromLTWH(
            size.width * (0.15 + book * 0.1),
            size.height * (0.05 + floor * 0.08),
            size.width * 0.06,
            size.height * 0.06,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(bookRect, const Radius.circular(1)),
            bookPaint,
          );
        }
      }
    }
  }

  void _paintRoyalArchive(Canvas canvas, Size size) {
    // Magnificent royal archive with towers and ornate details
    final archivePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFFFD700) : DuolingoTheme.mediumGray; // Gold

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoPurple : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main archive building
    final archive = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.3,
      size.width * 0.8,
      size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(archive, const Radius.circular(12)),
      archivePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(archive, const Radius.circular(12)),
      outlinePaint,
    );

    // Book towers on sides
    for (int i = 0; i < 2; i++) {
      final tower = Rect.fromLTWH(
        size.width * (0.05 + i * 0.85),
        size.height * 0.1,
        size.width * 0.15,
        size.height * 0.6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(8)),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(8)),
        outlinePaint,
      );
    }

    // Ornate entrance
    final entrancePaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.darkGray;

    final entrance = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.55,
      size.width * 0.3,
      size.height * 0.45,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(entrance, const Radius.circular(12)),
      entrancePaint,
    );

    // Royal crest above entrance
    if (isUnlocked) {
      final crestPaint = Paint()
        ..color = DuolingoTheme.duoRed;

      final crest = Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.05,
        size.width * 0.1,
        size.height * 0.1,
      );
      canvas.drawOval(crest, crestPaint);
    }

    // Countless books in organized sections
    if (isUnlocked) {
      final bookColors = [
        DuolingoTheme.duoYellow,
        DuolingoTheme.duoOrange,
        DuolingoTheme.duoRed,
        DuolingoTheme.duoPurple,
        DuolingoTheme.duoGreen,
        DuolingoTheme.duoBlue,
      ];

      for (int section = 0; section < 4; section++) {
        for (int shelf = 0; shelf < 3; shelf++) {
          for (int book = 0; book < 4; book++) {
            final bookPaint = Paint()
              ..color = bookColors[(section * 3 + shelf + book) % bookColors.length];

            final bookRect = Rect.fromLTWH(
              size.width * (0.15 + section * 0.15 + book * 0.025),
              size.height * (0.02 + shelf * 0.06),
              size.width * 0.02,
              size.height * 0.05,
            );
            canvas.drawRRect(
              RRect.fromRectAndRadius(bookRect, const Radius.circular(1)),
              bookPaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Placeholder painters for other buildings - to be implemented similarly
class _TradingPostProgressionPainter extends CustomPainter {
  final KingdomTier tier;
  final bool isUnlocked;
  final int level;

  _TradingPostProgressionPainter({required this.tier, required this.isUnlocked, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    switch (tier) {
      case KingdomTier.village:
        _paintMarketStall(canvas, size);
        break;
      case KingdomTier.town:
        _paintTradingPost(canvas, size);
        break;
      case KingdomTier.city:
        _paintTradeCenter(canvas, size);
        break;
      case KingdomTier.kingdom:
        _paintRoyalExchange(canvas, size);
        break;
    }
  }

  void _paintMarketStall(Canvas canvas, Size size) {
    // Simple market stall with wooden tent
    final canopyPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoOrange : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Simple tent structure
    final tentPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.8)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.85, size.height * 0.8)
      ..close();

    canvas.drawPath(tentPath, canopyPaint);
    canvas.drawPath(tentPath, outlinePaint);

    // Support poles
    final polePaint = Paint()
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.darkGray
      ..strokeWidth = 3.0;

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

    // Simple goods
    if (isUnlocked) {
      final goodsPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      final goodsRect = Rect.fromLTWH(
        size.width * 0.4,
        size.height * 0.7,
        size.width * 0.2,
        size.height * 0.15,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(goodsRect, const Radius.circular(3)),
        goodsPaint,
      );
    }
  }

  void _paintTradingPost(Canvas canvas, Size size) {
    // Wooden trading post building
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B4513) : DuolingoTheme.mediumGray;

    final roofPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main building
    final building = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(6)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(6)),
      outlinePaint,
    );

    // Roof
    final roofPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.85, size.height * 0.45)
      ..close();

    canvas.drawPath(roofPath, roofPaint);
    canvas.drawPath(roofPath, outlinePaint);

    // Sign
    final signPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoYellow : DuolingoTheme.mediumGray;

    final sign = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.3,
      size.height * 0.15,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sign, const Radius.circular(4)),
      signPaint,
    );

    // Trading goods visible through window
    if (isUnlocked) {
      final windowPaint = Paint()
        ..color = DuolingoTheme.duoBlueLight;

      final window = Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.5,
        size.width * 0.4,
        size.height * 0.2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(window, const Radius.circular(3)),
        windowPaint,
      );

      // Goods in window
      final goodsColors = [DuolingoTheme.duoYellow, DuolingoTheme.duoOrange, DuolingoTheme.duoRed];
      for (int i = 0; i < 3; i++) {
        final goodsPaint = Paint()
          ..color = goodsColors[i];

        final goodsRect = Rect.fromLTWH(
          size.width * (0.32 + i * 0.12),
          size.height * 0.52,
          size.width * 0.08,
          size.height * 0.16,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(goodsRect, const Radius.circular(2)),
          goodsPaint,
        );
      }
    }
  }

  void _paintTradeCenter(Canvas canvas, Size size) {
    // Modern trade center with multiple levels
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFF5F5DC) : DuolingoTheme.mediumGray; // Beige

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main building (2 stories)
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

    // Trading floor windows
    final windowPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoBlueLight : DuolingoTheme.mediumGray;

    for (int floor = 0; floor < 2; floor++) {
      for (int window = 0; window < 3; window++) {
        final windowRect = Rect.fromLTWH(
          size.width * (0.15 + window * 0.23),
          size.height * (0.35 + floor * 0.25),
          size.width * 0.15,
          size.height * 0.15,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(windowRect, const Radius.circular(4)),
          windowPaint,
        );
      }
    }

    // Digital display sign
    final displayPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    final display = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.05,
      size.width * 0.6,
      size.height * 0.15,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(display, const Radius.circular(6)),
      displayPaint,
    );

    if (isUnlocked) {
      // Display text simulation
      final textPaint = Paint()
        ..color = DuolingoTheme.duoGreen;

      for (int i = 0; i < 3; i++) {
        final textLine = Rect.fromLTWH(
          size.width * 0.25,
          size.height * (0.08 + i * 0.03),
          size.width * 0.5,
          size.height * 0.02,
        );
        canvas.drawRect(textLine, textPaint);
      }
    }
  }

  void _paintRoyalExchange(Canvas canvas, Size size) {
    // Grand royal exchange with ornate architecture
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFFFD700) : DuolingoTheme.mediumGray; // Gold

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoPurple : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main exchange building
    final building = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.25,
      size.width * 0.9,
      size.height * 0.75,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(12)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(12)),
      outlinePaint,
    );

    // Grand columns
    final columnPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.white : DuolingoTheme.lightGray;

    for (int i = 0; i < 5; i++) {
      final column = Rect.fromLTWH(
        size.width * (0.1 + i * 0.18),
        size.height * 0.3,
        size.width * 0.08,
        size.height * 0.7,
      );
      canvas.drawRect(column, columnPaint);
    }

    // Royal dome
    final dome = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.25,
    );
    canvas.drawOval(dome, accentPaint);
    canvas.drawOval(dome, outlinePaint);

    // Royal crest
    if (isUnlocked) {
      final crestPaint = Paint()
        ..color = DuolingoTheme.duoRed;

      final crest = Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.02,
        size.width * 0.1,
        size.height * 0.08,
      );
      canvas.drawOval(crest, crestPaint);
    }

    // Trading floors visible through large windows
    if (isUnlocked) {
      final tradingPaint = Paint()
        ..color = DuolingoTheme.duoGreen;

      for (int floor = 0; floor < 2; floor++) {
        for (int screen = 0; screen < 4; screen++) {
          final screenRect = Rect.fromLTWH(
            size.width * (0.15 + screen * 0.15),
            size.height * (0.4 + floor * 0.2),
            size.width * 0.1,
            size.height * 0.1,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(screenRect, const Radius.circular(2)),
            tradingPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TreasuryProgressionPainter extends CustomPainter {
  final KingdomTier tier;
  final bool isUnlocked;
  final int level;

  _TreasuryProgressionPainter({required this.tier, required this.isUnlocked, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    switch (tier) {
      case KingdomTier.village:
        _paintCoinPouch(canvas, size);
        break;
      case KingdomTier.town:
        _paintTownVault(canvas, size);
        break;
      case KingdomTier.city:
        _paintCityTreasury(canvas, size);
        break;
      case KingdomTier.kingdom:
        _paintRoyalTreasury(canvas, size);
        break;
    }
  }

  void _paintCoinPouch(Canvas canvas, Size size) {
    // Simple coin pouch
    final pouchPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B4513) : DuolingoTheme.mediumGray; // Brown

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Pouch body
    final pouchPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.25, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width * 0.75, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.5, size.width * 0.7, size.height * 0.4)
      ..close();

    canvas.drawPath(pouchPath, pouchPaint);
    canvas.drawPath(pouchPath, outlinePaint);

    // Pouch strings
    final stringPaint = Paint()
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.darkGray
      ..strokeWidth = 2.0;

    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * (0.35 + i * 0.15), size.height * 0.4),
        Offset(size.width * (0.35 + i * 0.15), size.height * 0.2),
        stringPaint,
      );
    }

    // Few coins
    if (isUnlocked) {
      final coinPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(size.width * (0.4 + i * 0.1), size.height * (0.6 + i * 0.05)),
          size.width * 0.03,
          coinPaint,
        );
      }
    }
  }

  void _paintTownVault(Canvas canvas, Size size) {
    // Small vault building
    final vaultPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF696969) : DuolingoTheme.mediumGray; // DimGray

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Vault building
    final vault = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.6,
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

    // Vault door
    final doorPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    final door = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.45,
      size.width * 0.3,
      size.height * 0.4,
    );
    canvas.drawOval(door, doorPaint);

    // Door handle/wheel
    final handlePaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoYellow : DuolingoTheme.mediumGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.65),
      size.width * 0.08,
      handlePaint,
    );

    // Handle spokes
    if (isUnlocked) {
      for (int i = 0; i < 4; i++) {
        final angle = (i * 90) * (3.14159 / 180);
        final spokeStart = Offset(
          size.width * 0.5 + (size.width * 0.05) * cos(angle),
          size.height * 0.65 + (size.width * 0.05) * sin(angle),
        );
        final spokeEnd = Offset(
          size.width * 0.5 + (size.width * 0.08) * cos(angle),
          size.height * 0.65 + (size.width * 0.08) * sin(angle),
        );
        canvas.drawLine(spokeStart, spokeEnd, handlePaint);
      }
    }

    // Some coins around the vault
    if (isUnlocked) {
      final coinPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      final coinPositions = [
        Offset(size.width * 0.1, size.height * 0.2),
        Offset(size.width * 0.85, size.height * 0.25),
        Offset(size.width * 0.15, size.height * 0.8),
        Offset(size.width * 0.9, size.height * 0.75),
      ];

      for (final position in coinPositions) {
        canvas.drawCircle(position, size.width * 0.025, coinPaint);
      }
    }
  }

  void _paintCityTreasury(Canvas canvas, Size size) {
    // Large secure treasury building
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFF5F5DC) : DuolingoTheme.mediumGray; // Beige

    final vaultPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF2F4F4F) : DuolingoTheme.mediumGray; // DarkSlateGray

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main treasury building
    final building = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(8)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(8)),
      outlinePaint,
    );

    // Multiple vault doors
    for (int i = 0; i < 2; i++) {
      final vaultDoor = Rect.fromLTWH(
        size.width * (0.2 + i * 0.4),
        size.height * 0.4,
        size.width * 0.2,
        size.height * 0.35,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(vaultDoor, const Radius.circular(6)),
        vaultPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(vaultDoor, const Radius.circular(6)),
        outlinePaint,
      );

      // Digital locks
      if (isUnlocked) {
        final lockPaint = Paint()
          ..color = DuolingoTheme.duoRed;

        final lock = Rect.fromLTWH(
          size.width * (0.25 + i * 0.4),
          size.height * 0.5,
          size.width * 0.1,
          size.height * 0.1,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(lock, const Radius.circular(3)),
          lockPaint,
        );
      }
    }

    // Security cameras
    if (isUnlocked) {
      final cameraPaint = Paint()
        ..color = DuolingoTheme.charcoal;

      for (int i = 0; i < 2; i++) {
        final camera = Rect.fromLTWH(
          size.width * (0.15 + i * 0.7),
          size.height * 0.05,
          size.width * 0.05,
          size.height * 0.08,
        );
        canvas.drawOval(camera, cameraPaint);
      }
    }

    // Gold bars visible through reinforced windows
    if (isUnlocked) {
      final goldPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      for (int vault = 0; vault < 2; vault++) {
        for (int bar = 0; bar < 3; bar++) {
          final goldBar = Rect.fromLTWH(
            size.width * (0.22 + vault * 0.4 + bar * 0.03),
            size.height * 0.8,
            size.width * 0.025,
            size.height * 0.15,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(goldBar, const Radius.circular(1)),
            goldPaint,
          );
        }
      }
    }
  }

  void _paintRoyalTreasury(Canvas canvas, Size size) {
    // Magnificent royal treasury with ornate details
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFFFD700) : DuolingoTheme.mediumGray; // Gold

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoPurple : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main treasury building
    final building = Rect.fromLTWH(
      size.width * 0.05,
      size.height * 0.2,
      size.width * 0.9,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(12)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(building, const Radius.circular(12)),
      outlinePaint,
    );

    // Royal towers with treasure chambers
    for (int i = 0; i < 2; i++) {
      final tower = Rect.fromLTWH(
        size.width * (0.02 + i * 0.91),
        size.height * 0.05,
        size.width * 0.15,
        size.height * 0.5,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(8)),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(8)),
        outlinePaint,
      );

      // Tower domes
      final dome = Rect.fromLTWH(
        size.width * (0.01 + i * 0.91),
        size.height * 0.02,
        size.width * 0.17,
        size.height * 0.15,
      );
      canvas.drawOval(dome, buildingPaint);
      canvas.drawOval(dome, outlinePaint);
    }

    // Central vault with massive door
    final vaultPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    final vaultDoor = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.4,
      size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vaultDoor, const Radius.circular(10)),
      vaultPaint,
    );

    // Ornate door decorations
    if (isUnlocked) {
      final decorationPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      // Royal crest on door
      final crest = Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.5,
        size.width * 0.1,
        size.height * 0.15,
      );
      canvas.drawOval(crest, decorationPaint);

      // Decorative borders
      final borderPaint = Paint()
        ..color = DuolingoTheme.duoYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.32,
            size.height * 0.42,
            size.width * 0.36,
            size.height * 0.56,
          ),
          const Radius.circular(8),
        ),
        borderPaint,
      );
    }

    // Treasure spilling out (coins, gems, gold bars)
    if (isUnlocked) {
      final treasureColors = [
        DuolingoTheme.duoYellow, // Gold coins
        DuolingoTheme.duoBlue,   // Sapphires
        DuolingoTheme.duoRed,    // Rubies
        DuolingoTheme.duoPurple, // Amethysts
      ];

      for (int treasure = 0; treasure < 8; treasure++) {
        final treasurePaint = Paint()
          ..color = treasureColors[treasure % treasureColors.length];

        final treasurePosition = Offset(
          size.width * (0.1 + (treasure % 4) * 0.2),
          size.height * (0.85 + (treasure ~/ 4) * 0.1),
        );

        if (treasure % 2 == 0) {
          // Coins (circles)
          canvas.drawCircle(treasurePosition, size.width * 0.02, treasurePaint);
        } else {
          // Gems (diamonds)
          final gemPath = Path()
            ..moveTo(treasurePosition.dx, treasurePosition.dy - size.width * 0.02)
            ..lineTo(treasurePosition.dx + size.width * 0.015, treasurePosition.dy)
            ..lineTo(treasurePosition.dx, treasurePosition.dy + size.width * 0.02)
            ..lineTo(treasurePosition.dx - size.width * 0.015, treasurePosition.dy)
            ..close();
          canvas.drawPath(gemPath, treasurePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MarketplaceProgressionPainter extends CustomPainter {
  final KingdomTier tier;
  final bool isUnlocked;
  final int level;

  _MarketplaceProgressionPainter({required this.tier, required this.isUnlocked, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    switch (tier) {
      case KingdomTier.village:
        _paintVillageMarket(canvas, size);
        break;
      case KingdomTier.town:
        _paintTownBazaar(canvas, size);
        break;
      case KingdomTier.city:
        _paintGrandMarketplace(canvas, size);
        break;
      case KingdomTier.kingdom:
        _paintRoyalMarket(canvas, size);
        break;
    }
  }

  void _paintVillageMarket(Canvas canvas, Size size) {
    // Simple village market with wooden stalls
    final stallPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B4513) : DuolingoTheme.mediumGray; // Brown

    final canopyPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoOrange : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Market stalls (3 small stalls)
    for (int i = 0; i < 3; i++) {
      final stallRect = Rect.fromLTWH(
        size.width * (0.1 + i * 0.27),
        size.height * 0.6,
        size.width * 0.2,
        size.height * 0.4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(stallRect, const Radius.circular(4)),
        stallPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(stallRect, const Radius.circular(4)),
        outlinePaint,
      );

      // Canopy over each stall
      final canopyPath = Path()
        ..moveTo(size.width * (0.05 + i * 0.27), size.height * 0.65)
        ..lineTo(size.width * (0.2 + i * 0.27), size.height * 0.4)
        ..lineTo(size.width * (0.35 + i * 0.27), size.height * 0.65)
        ..close();

      canvas.drawPath(canopyPath, canopyPaint);
      canvas.drawPath(canopyPath, outlinePaint);
    }

    // Market goods on display
    if (isUnlocked) {
      final goodsColors = [
        DuolingoTheme.duoYellow,
        DuolingoTheme.duoRed,
        DuolingoTheme.duoGreen,
      ];

      for (int stall = 0; stall < 3; stall++) {
        final goodsPaint = Paint()
          ..color = goodsColors[stall];

        for (int good = 0; good < 2; good++) {
          final goodRect = Rect.fromLTWH(
            size.width * (0.12 + stall * 0.27 + good * 0.08),
            size.height * 0.75,
            size.width * 0.06,
            size.height * 0.1,
          );
          canvas.drawOval(goodRect, goodsPaint);
        }
      }
    }
  }

  void _paintTownBazaar(Canvas canvas, Size size) {
    // Enhanced bazaar with covered market area
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final roofPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B0000) : DuolingoTheme.mediumGray; // DarkRed

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main bazaar building
    final bazaar = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.3,
      size.width * 0.8,
      size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bazaar, const Radius.circular(6)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bazaar, const Radius.circular(6)),
      outlinePaint,
    );

    // Covered roof
    final roofPath = Path()
      ..moveTo(size.width * 0.05, size.height * 0.35)
      ..lineTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.95, size.height * 0.35)
      ..close();

    canvas.drawPath(roofPath, roofPaint);
    canvas.drawPath(roofPath, outlinePaint);

    // Multiple vendor stalls inside
    if (isUnlocked) {
      final stallColors = [
        DuolingoTheme.duoYellow,
        DuolingoTheme.duoOrange,
        DuolingoTheme.duoRed,
        DuolingoTheme.duoGreen,
      ];

      for (int row = 0; row < 2; row++) {
        for (int col = 0; col < 2; col++) {
          final stallPaint = Paint()
            ..color = stallColors[row * 2 + col];

          final stallRect = Rect.fromLTWH(
            size.width * (0.2 + col * 0.3),
            size.height * (0.4 + row * 0.25),
            size.width * 0.2,
            size.height * 0.2,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(stallRect, const Radius.circular(3)),
            stallPaint,
          );
        }
      }
    }

    // Bazaar entrance
    final entrancePaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoYellow : DuolingoTheme.darkGray;

    final entrance = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.8,
      size.width * 0.2,
      size.height * 0.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(entrance, const Radius.circular(8)),
      entrancePaint,
    );
  }

  void _paintGrandMarketplace(Canvas canvas, Size size) {
    // Large marketplace with multiple buildings and central plaza
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFF5F5DC) : DuolingoTheme.mediumGray; // Beige

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Central marketplace building
    final marketplace = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(marketplace, const Radius.circular(8)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(marketplace, const Radius.circular(8)),
      outlinePaint,
    );

    // Side buildings
    for (int i = 0; i < 2; i++) {
      final sideBuilding = Rect.fromLTWH(
        size.width * (0.05 + i * 0.8),
        size.height * 0.3,
        size.width * 0.15,
        size.height * 0.7,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(sideBuilding, const Radius.circular(6)),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(sideBuilding, const Radius.circular(6)),
        outlinePaint,
      );
    }

    // Clock tower
    final tower = Rect.fromLTWH(
      size.width * 0.45,
      size.height * 0.05,
      size.width * 0.1,
      size.height * 0.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(4)),
      accentPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(4)),
      outlinePaint,
    );

    // Clock face
    final clockPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.white : DuolingoTheme.lightGray;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.12),
      size.width * 0.03,
      clockPaint,
    );

    // Many merchant stalls around plaza
    if (isUnlocked) {
      final stallColors = [
        DuolingoTheme.duoYellow,
        DuolingoTheme.duoOrange,
        DuolingoTheme.duoRed,
        DuolingoTheme.duoGreen,
        DuolingoTheme.duoPurple,
        DuolingoTheme.duoBlue,
      ];

      for (int i = 0; i < 6; i++) {
        final stallPaint = Paint()
          ..color = stallColors[i];

        final angle = (i * 60) * (pi / 180);
        final stallX = size.width * 0.5 + size.width * 0.15 * cos(angle);
        final stallY = size.height * 0.5 + size.height * 0.15 * sin(angle);

        final stallRect = Rect.fromLTWH(
          stallX - size.width * 0.04,
          stallY - size.height * 0.04,
          size.width * 0.08,
          size.height * 0.08,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(stallRect, const Radius.circular(2)),
          stallPaint,
        );
      }
    }
  }

  void _paintRoyalMarket(Canvas canvas, Size size) {
    // Magnificent royal market with ornate architecture and luxury goods
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFFFD700) : DuolingoTheme.mediumGray; // Gold

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoPurple : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main royal market building
    final market = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(market, const Radius.circular(12)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(market, const Radius.circular(12)),
      outlinePaint,
    );

    // Royal towers with luxury shops
    for (int i = 0; i < 2; i++) {
      final tower = Rect.fromLTWH(
        size.width * (0.05 + i * 0.85),
        size.height * 0.05,
        size.width * 0.15,
        size.height * 0.5,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(8)),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(8)),
        outlinePaint,
      );

      // Tower domes
      final dome = Rect.fromLTWH(
        size.width * (0.02 + i * 0.85),
        size.height * 0.02,
        size.width * 0.21,
        size.height * 0.15,
      );
      canvas.drawOval(dome, buildingPaint);
      canvas.drawOval(dome, outlinePaint);
    }

    // Grand entrance with royal crest
    final entrancePaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.darkGray;

    final entrance = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.6,
      size.width * 0.3,
      size.height * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(entrance, const Radius.circular(16)),
      entrancePaint,
    );

    // Royal crest above entrance
    if (isUnlocked) {
      final crestPaint = Paint()
        ..color = DuolingoTheme.duoRed;

      final crest = Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.05,
        size.width * 0.1,
        size.height * 0.1,
      );
      canvas.drawOval(crest, crestPaint);
    }

    // Luxury goods displays
    if (isUnlocked) {
      final luxuryColors = [
        DuolingoTheme.duoYellow, // Gold items
        DuolingoTheme.duoBlue,   // Sapphire goods
        DuolingoTheme.duoRed,    // Ruby items
        DuolingoTheme.duoPurple, // Amethyst goods
      ];

      for (int floor = 0; floor < 2; floor++) {
        for (int shop = 0; shop < 4; shop++) {
          final shopPaint = Paint()
            ..color = luxuryColors[shop];

          final shopWindow = Rect.fromLTWH(
            size.width * (0.15 + shop * 0.15),
            size.height * (0.3 + floor * 0.2),
            size.width * 0.1,
            size.height * 0.15,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(shopWindow, const Radius.circular(4)),
            shopPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ObservatoryProgressionPainter extends CustomPainter {
  final KingdomTier tier;
  final bool isUnlocked;
  final int level;

  _ObservatoryProgressionPainter({required this.tier, required this.isUnlocked, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    switch (tier) {
      case KingdomTier.village:
        _paintLookoutPost(canvas, size);
        break;
      case KingdomTier.town:
        _paintWatchTower(canvas, size);
        break;
      case KingdomTier.city:
        _paintObservatory(canvas, size);
        break;
      case KingdomTier.kingdom:
        _paintRoyalObservatory(canvas, size);
        break;
    }
  }

  void _paintLookoutPost(Canvas canvas, Size size) {
    // Simple wooden lookout post with platform
    final postPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B4513) : DuolingoTheme.mediumGray; // Brown

    final platformPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.mediumGray; // DarkBrown

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Support posts
    final post1 = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.08,
      size.height * 0.6,
    );
    final post2 = Rect.fromLTWH(
      size.width * 0.72,
      size.height * 0.4,
      size.width * 0.08,
      size.height * 0.6,
    );

    canvas.drawRect(post1, postPaint);
    canvas.drawRect(post1, outlinePaint);
    canvas.drawRect(post2, postPaint);
    canvas.drawRect(post2, outlinePaint);

    // Observation platform
    final platform = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.3,
      size.width * 0.7,
      size.height * 0.15,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(platform, const Radius.circular(4)),
      platformPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(platform, const Radius.circular(4)),
      outlinePaint,
    );

    // Simple ladder
    final ladderPaint = Paint()
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.darkGray
      ..strokeWidth = 2.0;

    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * 0.1, size.height * (0.5 + i * 0.1)),
        Offset(size.width * 0.18, size.height * (0.5 + i * 0.1)),
        ladderPaint,
      );
    }

    // Ladder rails
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.1, size.height * 0.9),
      ladderPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.5),
      Offset(size.width * 0.18, size.height * 0.9),
      ladderPaint,
    );

    // Simple telescope
    if (isUnlocked) {
      final telescopePaint = Paint()
        ..color = DuolingoTheme.charcoal
        ..strokeWidth = 3.0;

      canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.25),
        Offset(size.width * 0.65, size.height * 0.1),
        telescopePaint,
      );
    }
  }

  void _paintWatchTower(Canvas canvas, Size size) {
    // Stone watch tower with enhanced viewing capability
    final stonePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF696969) : DuolingoTheme.mediumGray; // DimGray

    final roofPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B0000) : DuolingoTheme.mediumGray; // DarkRed

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Tower base
    final tower = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.3,
      size.width * 0.4,
      size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(6)),
      stonePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(6)),
      outlinePaint,
    );

    // Observation room
    final obsRoom = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(obsRoom, const Radius.circular(6)),
      stonePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(obsRoom, const Radius.circular(6)),
      outlinePaint,
    );

    // Conical roof
    final roofPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.18)
      ..lineTo(size.width * 0.5, size.height * 0.05)
      ..lineTo(size.width * 0.8, size.height * 0.18)
      ..close();

    canvas.drawPath(roofPath, roofPaint);
    canvas.drawPath(roofPath, outlinePaint);

    // Windows for observation
    if (isUnlocked) {
      final windowPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      for (int i = 0; i < 4; i++) {
        final windowRect = Rect.fromLTWH(
          size.width * (0.28 + i * 0.11),
          size.height * 0.2,
          size.width * 0.08,
          size.height * 0.1,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(windowRect, const Radius.circular(3)),
          windowPaint,
        );
      }
    }

    // Enhanced telescope
    if (isUnlocked) {
      final telescopePaint = Paint()
        ..color = DuolingoTheme.charcoal;

      final telescope = Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.08,
        size.width * 0.1,
        size.height * 0.12,
      );
      canvas.drawOval(telescope, telescopePaint);

      // Telescope lens
      final lensPaint = Paint()
        ..color = DuolingoTheme.duoBlueLight;

      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.1),
        size.width * 0.03,
        lensPaint,
      );
    }
  }

  void _paintObservatory(Canvas canvas, Size size) {
    // Modern observatory with dome and advanced equipment
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFF5F5DC) : DuolingoTheme.mediumGray; // Beige

    final domePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Observatory base building
    final base = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, const Radius.circular(8)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, const Radius.circular(8)),
      outlinePaint,
    );

    // Observatory dome
    final dome = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.4,
    );
    canvas.drawOval(dome, domePaint);
    canvas.drawOval(dome, outlinePaint);

    // Dome opening for telescope
    final openingPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    final opening = Rect.fromLTWH(
      size.width * 0.45,
      size.height * 0.15,
      size.width * 0.1,
      size.height * 0.2,
    );
    canvas.drawRect(opening, openingPaint);

    // Large telescope visible through opening
    if (isUnlocked) {
      final telescopePaint = Paint()
        ..color = DuolingoTheme.charcoal;

      final telescopeBody = Rect.fromLTWH(
        size.width * 0.46,
        size.height * 0.17,
        size.width * 0.08,
        size.height * 0.15,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(telescopeBody, const Radius.circular(2)),
        telescopePaint,
      );

      // Telescope lens
      final lensPaint = Paint()
        ..color = DuolingoTheme.duoBlueLight;

      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.18),
        size.width * 0.025,
        lensPaint,
      );
    }

    // Control room windows
    if (isUnlocked) {
      final windowPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      for (int i = 0; i < 3; i++) {
        final windowRect = Rect.fromLTWH(
          size.width * (0.25 + i * 0.17),
          size.height * 0.55,
          size.width * 0.12,
          size.height * 0.15,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(windowRect, const Radius.circular(4)),
          windowPaint,
        );
      }
    }

    // Satellite dish
    if (isUnlocked) {
      final dishPaint = Paint()
        ..color = DuolingoTheme.lightGray
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.75,
          size.height * 0.2,
          size.width * 0.15,
          size.height * 0.1,
        ),
        dishPaint,
      );
    }
  }

  void _paintRoyalObservatory(Canvas canvas, Size size) {
    // Grand royal observatory with multiple domes and advanced instruments
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFFFD700) : DuolingoTheme.mediumGray; // Gold

    final domePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoPurple : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main observatory building
    final mainBuilding = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.4,
      size.width * 0.8,
      size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainBuilding, const Radius.circular(12)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainBuilding, const Radius.circular(12)),
      outlinePaint,
    );

    // Multiple observatory domes
    final domePositions = [
      Offset(size.width * 0.3, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.7, size.height * 0.2),
    ];

    for (int i = 0; i < domePositions.length; i++) {
      final domeSize = i == 1 ? 0.25 : 0.2; // Center dome is larger
      final dome = Rect.fromCenter(
        center: domePositions[i],
        width: size.width * domeSize,
        height: size.height * domeSize,
      );
      canvas.drawOval(dome, domePaint);
      canvas.drawOval(dome, outlinePaint);

      // Dome openings
      final openingPaint = Paint()
        ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

      final opening = Rect.fromCenter(
        center: Offset(domePositions[i].dx, domePositions[i].dy + size.height * 0.05),
        width: size.width * 0.05,
        height: size.height * 0.12,
      );
      canvas.drawRect(opening, openingPaint);
    }

    // Advanced telescopes in each dome
    if (isUnlocked) {
      final telescopePaint = Paint()
        ..color = DuolingoTheme.charcoal;

      for (int i = 0; i < domePositions.length; i++) {
        final telescope = Rect.fromCenter(
          center: Offset(domePositions[i].dx, domePositions[i].dy + size.height * 0.04),
          width: size.width * 0.04,
          height: size.height * 0.08,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(telescope, const Radius.circular(1)),
          telescopePaint,
        );

        // High-tech lens with special coating
        final lensPaint = Paint()
          ..color = i == 1 ? DuolingoTheme.duoYellow : DuolingoTheme.duoBlueLight;

        canvas.drawCircle(
          Offset(domePositions[i].dx, domePositions[i].dy),
          size.width * 0.015,
          lensPaint,
        );
      }
    }

    // Royal crest above main entrance
    if (isUnlocked) {
      final crestPaint = Paint()
        ..color = DuolingoTheme.duoRed;

      final crest = Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.02,
        size.width * 0.1,
        size.height * 0.08,
      );
      canvas.drawOval(crest, crestPaint);
    }

    // Advanced control room with multiple monitoring stations
    if (isUnlocked) {
      final stationColors = [
        DuolingoTheme.duoGreen,  // Navigation
        DuolingoTheme.duoBlue,   // Deep space
        DuolingoTheme.duoRed,    // Solar
        DuolingoTheme.duoPurple, // Stellar
      ];

      for (int floor = 0; floor < 2; floor++) {
        for (int station = 0; station < 4; station++) {
          final stationPaint = Paint()
            ..color = stationColors[station];

          final stationWindow = Rect.fromLTWH(
            size.width * (0.15 + station * 0.15),
            size.height * (0.5 + floor * 0.2),
            size.width * 0.1,
            size.height * 0.12,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(stationWindow, const Radius.circular(3)),
            stationPaint,
          );
        }
      }
    }

    // Multiple satellite dishes and radio telescopes
    if (isUnlocked) {
      final dishPaint = Paint()
        ..color = DuolingoTheme.lightGray
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Large satellite dish
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.02,
          size.height * 0.15,
          size.width * 0.2,
          size.height * 0.15,
        ),
        dishPaint,
      );

      // Medium satellite dish
      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.82,
          size.height * 0.25,
          size.width * 0.15,
          size.height * 0.1,
        ),
        dishPaint,
      );

      // Radio telescope array
      final arrayPaint = Paint()
        ..color = DuolingoTheme.charcoal
        ..strokeWidth = 1.5;

      for (int i = 0; i < 3; i++) {
        canvas.drawLine(
          Offset(size.width * (0.85 + i * 0.03), size.height * 0.4),
          Offset(size.width * (0.85 + i * 0.03), size.height * 0.5),
          arrayPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AcademyProgressionPainter extends CustomPainter {
  final KingdomTier tier;
  final bool isUnlocked;
  final int level;

  _AcademyProgressionPainter({required this.tier, required this.isUnlocked, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    switch (tier) {
      case KingdomTier.village:
        _paintSchoolHouse(canvas, size);
        break;
      case KingdomTier.town:
        _paintTownSchool(canvas, size);
        break;
      case KingdomTier.city:
        _paintAcademy(canvas, size);
        break;
      case KingdomTier.kingdom:
        _paintRoyalAcademy(canvas, size);
        break;
    }
  }

  void _paintSchoolHouse(Canvas canvas, Size size) {
    // Simple one-room schoolhouse
    final housePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B4513) : DuolingoTheme.mediumGray; // Brown

    final roofPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B0000) : DuolingoTheme.mediumGray; // DarkRed

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main schoolhouse building
    final house = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(house, const Radius.circular(6)),
      housePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(house, const Radius.circular(6)),
      outlinePaint,
    );

    // Simple peaked roof
    final roofPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.85, size.height * 0.45)
      ..close();

    canvas.drawPath(roofPath, roofPaint);
    canvas.drawPath(roofPath, outlinePaint);

    // Bell tower
    final bellTower = Rect.fromLTWH(
      size.width * 0.45,
      size.height * 0.05,
      size.width * 0.1,
      size.height * 0.2,
    );
    canvas.drawRect(bellTower, housePaint);
    canvas.drawRect(bellTower, outlinePaint);

    // Bell
    if (isUnlocked) {
      final bellPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      canvas.drawOval(
        Rect.fromLTWH(
          size.width * 0.47,
          size.height * 0.08,
          size.width * 0.06,
          size.height * 0.08,
        ),
        bellPaint,
      );
    }

    // Windows
    if (isUnlocked) {
      final windowPaint = Paint()
        ..color = DuolingoTheme.duoBlueLight;

      for (int i = 0; i < 2; i++) {
        final window = Rect.fromLTWH(
          size.width * (0.25 + i * 0.3),
          size.height * 0.5,
          size.width * 0.15,
          size.height * 0.2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(window, const Radius.circular(3)),
          windowPaint,
        );
      }
    }

    // Door
    final doorPaint = Paint()
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.darkGray;

    final door = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.7,
      size.width * 0.2,
      size.height * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, const Radius.circular(4)),
      doorPaint,
    );

    // Sign
    if (isUnlocked) {
      final signPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      final sign = Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.15,
        size.width * 0.25,
        size.height * 0.1,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(sign, const Radius.circular(3)),
        signPaint,
      );
    }
  }

  void _paintTownSchool(Canvas canvas, Size size) {
    // Larger two-story school building
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFF8B0000) : DuolingoTheme.mediumGray; // DarkRed

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main school building
    final school = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.3,
      size.width * 0.7,
      size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(school, const Radius.circular(8)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(school, const Radius.circular(8)),
      outlinePaint,
    );

    // Pitched roof
    final roofPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.35)
      ..lineTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.9, size.height * 0.35)
      ..close();

    canvas.drawPath(roofPath, accentPaint);
    canvas.drawPath(roofPath, outlinePaint);

    // Clock tower
    final clockTower = Rect.fromLTWH(
      size.width * 0.45,
      size.height * 0.05,
      size.width * 0.1,
      size.height * 0.15,
    );
    canvas.drawRect(clockTower, buildingPaint);
    canvas.drawRect(clockTower, outlinePaint);

    // Clock face
    if (isUnlocked) {
      final clockPaint = Paint()
        ..color = DuolingoTheme.white;

      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.1),
        size.width * 0.03,
        clockPaint,
      );
    }

    // Multiple classroom windows
    if (isUnlocked) {
      final windowPaint = Paint()
        ..color = DuolingoTheme.duoYellow;

      for (int floor = 0; floor < 2; floor++) {
        for (int room = 0; room < 3; room++) {
          final window = Rect.fromLTWH(
            size.width * (0.2 + room * 0.2),
            size.height * (0.4 + floor * 0.2),
            size.width * 0.15,
            size.height * 0.15,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(window, const Radius.circular(3)),
            windowPaint,
          );
        }
      }
    }

    // Main entrance
    final entrancePaint = Paint()
      ..color = isUnlocked ? const Color(0xFF654321) : DuolingoTheme.darkGray;

    final entrance = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.75,
      size.width * 0.2,
      size.height * 0.25,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(entrance, const Radius.circular(6)),
      entrancePaint,
    );

    // School sign
    if (isUnlocked) {
      final signPaint = Paint()
        ..color = DuolingoTheme.duoGreen;

      final sign = Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.02,
        size.width * 0.4,
        size.height * 0.08,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(sign, const Radius.circular(4)),
        signPaint,
      );
    }
  }

  void _paintAcademy(Canvas canvas, Size size) {
    // Modern academy with multiple buildings and courtyard
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFF5F5DC) : DuolingoTheme.mediumGray; // Beige

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main academy building
    final academy = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(academy, const Radius.circular(8)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(academy, const Radius.circular(8)),
      outlinePaint,
    );

    // Side wings
    for (int i = 0; i < 2; i++) {
      final wing = Rect.fromLTWH(
        size.width * (0.05 + i * 0.8),
        size.height * 0.3,
        size.width * 0.15,
        size.height * 0.7,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(wing, const Radius.circular(6)),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(wing, const Radius.circular(6)),
        outlinePaint,
      );
    }

    // Central tower with dome
    final tower = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.05,
      size.width * 0.2,
      size.height * 0.25,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(6)),
      accentPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tower, const Radius.circular(6)),
      outlinePaint,
    );

    // Dome
    final dome = Rect.fromLTWH(
      size.width * 0.38,
      size.height * 0.02,
      size.width * 0.24,
      size.height * 0.15,
    );
    canvas.drawOval(dome, buildingPaint);
    canvas.drawOval(dome, outlinePaint);

    // Many academic department windows
    if (isUnlocked) {
      final departmentColors = [
        DuolingoTheme.duoYellow,  // Mathematics
        DuolingoTheme.duoGreen,   // Sciences  
        DuolingoTheme.duoRed,     // Literature
        DuolingoTheme.duoPurple,  // Arts
      ];

      for (int floor = 0; floor < 3; floor++) {
        for (int dept = 0; dept < 4; dept++) {
          final windowPaint = Paint()
            ..color = departmentColors[dept];

          final window = Rect.fromLTWH(
            size.width * (0.25 + dept * 0.125),
            size.height * (0.25 + floor * 0.15),
            size.width * 0.1,
            size.height * 0.12,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(window, const Radius.circular(3)),
            windowPaint,
          );
        }
      }
    }

    // Grand entrance with columns
    final columnPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.white : DuolingoTheme.lightGray;

    for (int i = 0; i < 4; i++) {
      final column = Rect.fromLTWH(
        size.width * (0.3 + i * 0.1),
        size.height * 0.7,
        size.width * 0.04,
        size.height * 0.3,
      );
      canvas.drawRect(column, columnPaint);
    }
  }

  void _paintRoyalAcademy(Canvas canvas, Size size) {
    // Grand royal academy with multiple campuses and advanced facilities
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? const Color(0xFFFFD700) : DuolingoTheme.mediumGray; // Gold

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isUnlocked ? DuolingoTheme.duoPurple : DuolingoTheme.mediumGray;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray;

    // Main royal academy building
    final academy = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.2,
      size.width * 0.8,
      size.height * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(academy, const Radius.circular(12)),
      buildingPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(academy, const Radius.circular(12)),
      outlinePaint,
    );

    // Multiple specialized wings
    final wingPositions = [
      Rect.fromLTWH(size.width * 0.02, size.height * 0.3, size.width * 0.15, size.height * 0.7),
      Rect.fromLTWH(size.width * 0.83, size.height * 0.3, size.width * 0.15, size.height * 0.7),
    ];

    for (final wing in wingPositions) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(wing, const Radius.circular(8)),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(wing, const Radius.circular(8)),
        outlinePaint,
      );
    }

    // Central spire with royal insignia
    final spire = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.02,
      size.width * 0.2,
      size.height * 0.3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(spire, const Radius.circular(8)),
      accentPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(spire, const Radius.circular(8)),
      outlinePaint,
    );

    // Royal crest at top
    if (isUnlocked) {
      final crestPaint = Paint()
        ..color = DuolingoTheme.duoRed;

      final crest = Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.01,
        size.width * 0.1,
        size.height * 0.08,
      );
      canvas.drawOval(crest, crestPaint);
    }

    // Advanced academic departments with specialized colors
    if (isUnlocked) {
      final facultyColors = [
        DuolingoTheme.duoYellow,  // Finance & Economics
        DuolingoTheme.duoGreen,   // Natural Sciences
        DuolingoTheme.duoBlue,    // Engineering & Technology
        DuolingoTheme.duoRed,     // Arts & Literature
        DuolingoTheme.duoPurple,  // Philosophy & Logic
        DuolingoTheme.duoOrange,  // Historical Studies
      ];

      for (int floor = 0; floor < 3; floor++) {
        for (int faculty = 0; faculty < 6; faculty++) {
          final facultyPaint = Paint()
            ..color = facultyColors[faculty];

          final facultyWindow = Rect.fromLTWH(
            size.width * (0.15 + faculty * 0.1),
            size.height * (0.25 + floor * 0.15),
            size.width * 0.08,
            size.height * 0.12,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(facultyWindow, const Radius.circular(4)),
            facultyPaint,
          );
        }
      }
    }

    // Grand colonnade entrance
    final columnPaint = Paint()
      ..color = isUnlocked ? DuolingoTheme.white : DuolingoTheme.lightGray;

    for (int i = 0; i < 6; i++) {
      final column = Rect.fromLTWH(
        size.width * (0.2 + i * 0.1),
        size.height * 0.75,
        size.width * 0.05,
        size.height * 0.25,
      );
      canvas.drawRect(column, columnPaint);
    }

    // Research facilities and libraries
    if (isUnlocked) {
      // Advanced laboratory indicators (glowing windows)
      final labPaint = Paint()
        ..color = DuolingoTheme.duoGreen
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2.0);

      for (int i = 0; i < 2; i++) {
        final lab = Rect.fromLTWH(
          size.width * (0.05 + i * 0.88),
          size.height * 0.4,
          size.width * 0.1,
          size.height * 0.15,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(lab, const Radius.circular(3)),
          labPaint,
        );
      }

      // Library wing with special archives
      final libraryPaint = Paint()
        ..color = DuolingoTheme.duoBlue;

      final library = Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.85,
        size.width * 0.3,
        size.height * 0.12,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(library, const Radius.circular(6)),
        libraryPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}