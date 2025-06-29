import 'package:flutter/material.dart';
import '../theme/duolingo_theme.dart';

class KingdomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final double? width;

  const KingdomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
  });

  @override
  State<KingdomButton> createState() => _KingdomButtonState();
}

class _KingdomButtonState extends State<KingdomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
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
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed != null && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              padding: widget.padding ?? const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: _getButtonDecoration(),
              child: _buildButtonContent(),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _getButtonDecoration() {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    if (widget.isSecondary) {
      return BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        border: Border.all(
          color: widget.foregroundColor ?? DuolingoTheme.duoGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      );
    }

    return BoxDecoration(
      gradient: isEnabled
          ? LinearGradient(
              colors: [
                widget.backgroundColor ?? DuolingoTheme.duoGreen,
                (widget.backgroundColor ?? DuolingoTheme.duoGreen).withValues(alpha: 0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : null,
      color: isEnabled ? null : DuolingoTheme.textSecondary,
      borderRadius: BorderRadius.circular(12),
      boxShadow: isEnabled
          ? [
              BoxShadow(
                color: (widget.backgroundColor ?? DuolingoTheme.duoGreen)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  Widget _buildButtonContent() {
    final textColor = widget.isSecondary
        ? (widget.foregroundColor ?? DuolingoTheme.duoGreen)
        : (widget.foregroundColor ?? DuolingoTheme.textOnPrimary);

    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.text,
              style: DuolingoTheme.button.copyWith(color: textColor),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        widget.text,
        style: DuolingoTheme.button.copyWith(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Specialized button variants
class KingdomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const KingdomPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      width: width,
    );
  }
}

class KingdomSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const KingdomSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isSecondary: true,
      icon: icon,
      width: width,
    );
  }
}

class KingdomSuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const KingdomSuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: DuolingoTheme.success,
      icon: icon,
      width: width,
    );
  }
}

class KingdomWarningButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const KingdomWarningButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: DuolingoTheme.warning,
      foregroundColor: DuolingoTheme.textPrimary,
      icon: icon,
      width: width,
    );
  }
}

class KingdomDangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const KingdomDangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return KingdomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: DuolingoTheme.error,
      icon: icon,
      width: width,
    );
  }
}