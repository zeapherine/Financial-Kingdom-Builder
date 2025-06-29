import 'package:flutter/material.dart';
import '../theme/duolingo_theme.dart';

class KingdomCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final bool isInteractive;
  final List<BoxShadow>? boxShadow;

  const KingdomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
    this.isInteractive = false,
    this.boxShadow,
  });

  @override
  State<KingdomCard> createState() => _KingdomCardState();
}

class _KingdomCardState extends State<KingdomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) + 4.0,
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.isInteractive || widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? DuolingoTheme.surfaceLight,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              border: widget.border,
              boxShadow: widget.boxShadow ?? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );

    if (widget.onTap != null || widget.isInteractive) {
      return GestureDetector(
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: card,
      );
    }

    return card;
  }
}

// Specialized card variants
class KingdomInfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const KingdomInfoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      isInteractive: onTap != null,
      border: Border.all(
        color: DuolingoTheme.info.withValues(alpha: 0.3),
        width: 1,
      ),
      backgroundColor: DuolingoTheme.info.withValues(alpha: 0.05),
      child: child,
    );
  }
}

class KingdomSuccessCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const KingdomSuccessCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      isInteractive: onTap != null,
      border: Border.all(
        color: DuolingoTheme.success.withValues(alpha: 0.3),
        width: 1,
      ),
      backgroundColor: DuolingoTheme.success.withValues(alpha: 0.05),
      child: child,
    );
  }
}

class KingdomWarningCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const KingdomWarningCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      isInteractive: onTap != null,
      border: Border.all(
        color: DuolingoTheme.warning.withValues(alpha: 0.3),
        width: 1,
      ),
      backgroundColor: DuolingoTheme.warning.withValues(alpha: 0.05),
      child: child,
    );
  }
}

class KingdomErrorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const KingdomErrorCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      isInteractive: onTap != null,
      border: Border.all(
        color: DuolingoTheme.error.withValues(alpha: 0.3),
        width: 1,
      ),
      backgroundColor: DuolingoTheme.error.withValues(alpha: 0.05),
      child: child,
    );
  }
}

class KingdomTierCard extends StatelessWidget {
  final Widget child;
  final String tier;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const KingdomTierCard({
    super.key,
    required this.child,
    required this.tier,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      isInteractive: onTap != null,
      backgroundColor: _getTierColor().withValues(alpha: 0.05),
      border: Border.all(
        color: _getTierColor().withValues(alpha: 0.3),
        width: 1,
      ),
      child: child,
    );
  }

  Color _getTierColor() {
    switch (tier.toLowerCase()) {
      case 'village':
        return DuolingoTheme.villageColor;
      case 'town':
        return DuolingoTheme.townColor;
      case 'city':
        return DuolingoTheme.cityColor;
      case 'kingdom':
        return DuolingoTheme.kingdomColor;
      case 'empire':
        return DuolingoTheme.empireColor;
      default:
        return DuolingoTheme.duoGreen;
    }
  }
}

class KingdomGradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const KingdomGradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}