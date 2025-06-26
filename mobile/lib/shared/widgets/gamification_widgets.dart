import 'package:flutter/material.dart';
import '../../core/config/duolingo_theme.dart';

class StreakCounter extends StatelessWidget {
  final int streakCount;

  const StreakCounter({
    super.key,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DuolingoTheme.streakCounter,
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: DuolingoTheme.white,
            size: DuolingoTheme.iconMedium,
          ),
          const SizedBox(width: DuolingoTheme.spacingSm),
          Text(
            '$streakCount',
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class XPBadge extends StatelessWidget {
  final int xp;

  const XPBadge({
    super.key,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DuolingoTheme.xpBadge,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: DuolingoTheme.white,
            size: DuolingoTheme.iconSmall,
          ),
          const SizedBox(width: DuolingoTheme.spacingSm),
          Text(
            '$xp XP',
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class HeartCounter extends StatelessWidget {
  final int hearts;
  final int maxHearts;

  const HeartCounter({
    super.key,
    required this.hearts,
    this.maxHearts = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxHearts, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            index < hearts ? Icons.favorite : Icons.favorite_border,
            color: DuolingoTheme.duoRed,
            size: 24.0, // From styles.json
          ),
        );
      }),
    );
  }
}

class GemCounter extends StatelessWidget {
  final int gems;

  const GemCounter({
    super.key,
    required this.gems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.diamond,
          color: DuolingoTheme.duoBlue,
          size: 24.0, // From styles.json
        ),
        const SizedBox(width: DuolingoTheme.spacingSm),
        Text(
          '$gems',
          style: DuolingoTheme.bodyMedium.copyWith(
            color: DuolingoTheme.duoBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class LevelBadge extends StatelessWidget {
  final String level;
  final String? subtitle;

  const LevelBadge({
    super.key,
    required this.level,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DuolingoTheme.levelBadge,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            level,
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2.0),
            Text(
              subtitle!,
              style: DuolingoTheme.caption.copyWith(
                color: DuolingoTheme.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LessonNode extends StatelessWidget {
  final IconData icon;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback? onTap;

  const LessonNode({
    super.key,
    required this.icon,
    this.isCompleted = false,
    this.isLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    Color borderColor;

    if (isLocked) {
      backgroundColor = DuolingoTheme.mediumGray;
      iconColor = DuolingoTheme.darkGray;
      borderColor = DuolingoTheme.darkGray;
    } else if (isCompleted) {
      backgroundColor = DuolingoTheme.duoGreen;
      iconColor = DuolingoTheme.white;
      borderColor = DuolingoTheme.duoGreenDark;
    } else {
      backgroundColor = DuolingoTheme.duoBlue;
      iconColor = DuolingoTheme.white;
      borderColor = DuolingoTheme.duoBlueDark;
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        width: 64.0, // From commonPatterns.lessonTile in styles.json
        height: 64.0,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 3.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isLocked ? Icons.lock : icon,
          color: iconColor,
          size: DuolingoTheme.iconLarge,
        ),
      ),
    );
  }
}