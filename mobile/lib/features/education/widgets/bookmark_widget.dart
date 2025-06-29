import 'package:flutter/material.dart';
import '../../../core/config/duolingo_theme.dart';

class BookmarkWidget extends StatefulWidget {
  final bool isBookmarked;
  final Function(bool) onBookmarkToggled;
  final Color? activeColor;
  final Color? inactiveColor;

  const BookmarkWidget({
    super.key,
    required this.isBookmarked,
    required this.onBookmarkToggled,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<BookmarkWidget> createState() => _BookmarkWidgetState();
}

class _BookmarkWidgetState extends State<BookmarkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor ?? DuolingoTheme.white.withValues(alpha: 0.7),
      end: widget.activeColor ?? DuolingoTheme.duoYellow,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isBookmarked) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BookmarkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      if (widget.isBookmarked) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleBookmarkTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Bookmark icon
                    Icon(
                      widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: _colorAnimation.value,
                      size: 24,
                    ),
                    
                    // Sparkle effects when bookmarked
                    if (widget.isBookmarked) ...[
                      Positioned(
                        top: -2,
                        right: -2,
                        child: _buildSparkle(0.0),
                      ),
                      Positioned(
                        bottom: -2,
                        left: -2,
                        child: _buildSparkle(0.3),
                      ),
                      Positioned(
                        top: 2,
                        left: -4,
                        child: _buildSparkle(0.6),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSparkle(double animationDelay) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: (800 + animationDelay * 200).toInt()),
      tween: Tween<double>(begin: 0, end: widget.isBookmarked ? 1 : 0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: DuolingoTheme.duoYellow,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBookmarkTap() {
    final newBookmarkState = !widget.isBookmarked;
    widget.onBookmarkToggled(newBookmarkState);
    
    // Add haptic feedback
    if (newBookmarkState) {
      // Light haptic feedback for bookmarking
      _playBookmarkAnimation();
    }
  }

  void _playBookmarkAnimation() {
    _animationController.reset();
    _animationController.forward();
  }
}