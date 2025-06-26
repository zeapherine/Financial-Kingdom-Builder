import 'package:flutter/material.dart';
import '../../core/config/duolingo_theme.dart';

enum DuoButtonType { primary, secondary, outline, text }

class DuoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final DuoButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const DuoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = DuoButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DuolingoTheme.buttonPressAnimation,
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
    _animationController.forward();
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
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.width,
              height: 56.0, // From practiceButton style in JSON
              child: _buildButton(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton() {
    switch (widget.type) {
      case DuoButtonType.primary:
        return ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: DuolingoTheme.primaryButton,
          child: _buildButtonContent(),
        );
      case DuoButtonType.secondary:
        return ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: DuolingoTheme.secondaryButton,
          child: _buildButtonContent(),
        );
      case DuoButtonType.outline:
        return OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: DuolingoTheme.outlineButton,
          child: _buildButtonContent(),
        );
      case DuoButtonType.text:
        return TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: DuolingoTheme.duoGreen,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
            ),
          ),
          child: _buildButtonContent(),
        );
    }
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(DuolingoTheme.white),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: DuolingoTheme.iconMedium),
          const SizedBox(width: DuolingoTheme.spacingSm),
          Text(widget.text),
        ],
      );
    }

    return Text(widget.text);
  }
}