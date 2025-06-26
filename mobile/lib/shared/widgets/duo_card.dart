import 'package:flutter/material.dart';
import '../../core/config/duolingo_theme.dart';

enum DuoCardType { lesson, achievement, streak, basic }

class DuoCard extends StatelessWidget {
  final Widget child;
  final DuoCardType type;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const DuoCard({
    super.key,
    required this.child,
    this.type = DuoCardType.basic,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(DuolingoTheme.spacingSm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: Container(
            decoration: _getDecoration(),
            padding: padding ?? _getDefaultPadding(),
            child: child,
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (type) {
      case DuoCardType.lesson:
        return DuolingoTheme.lessonCard;
      case DuoCardType.achievement:
        return DuolingoTheme.achievementCard;
      case DuoCardType.streak:
        return DuolingoTheme.streakCard;
      case DuoCardType.basic:
        return BoxDecoration(
          color: DuolingoTheme.white,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          boxShadow: DuolingoTheme.cardShadow,
        );
    }
  }

  double _getBorderRadius() {
    switch (type) {
      case DuoCardType.lesson:
        return DuolingoTheme.radiusLarge;
      case DuoCardType.achievement:
      case DuoCardType.streak:
      case DuoCardType.basic:
        return DuolingoTheme.radiusMedium;
    }
  }

  EdgeInsets _getDefaultPadding() {
    switch (type) {
      case DuoCardType.lesson:
        return const EdgeInsets.all(20.0);
      case DuoCardType.achievement:
      case DuoCardType.streak:
        return const EdgeInsets.all(DuolingoTheme.spacingMd);
      case DuoCardType.basic:
        return const EdgeInsets.all(DuolingoTheme.spacingMd);
    }
  }
}