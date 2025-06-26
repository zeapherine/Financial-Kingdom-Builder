import 'package:flutter/material.dart';
import '../../core/config/duolingo_theme.dart';

enum DuoProgressType { lesson, xp }

class DuoProgressBar extends StatefulWidget {
  final double progress;
  final DuoProgressType type;
  final double? height;
  final bool animated;

  const DuoProgressBar({
    super.key,
    required this.progress,
    this.type = DuoProgressType.lesson,
    this.height,
    this.animated = true,
  });

  @override
  State<DuoProgressBar> createState() => _DuoProgressBarState();
}

class _DuoProgressBarState extends State<DuoProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DuolingoTheme.slowAnimation,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.animated) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(DuoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress.clamp(0.0, 1.0),
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.reset();
      if (widget.animated) {
        _animationController.forward();
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
    return AnimatedBuilder(
      animation: widget.animated ? _progressAnimation : AlwaysStoppedAnimation(widget.progress),
      builder: (context, child) {
        final animatedProgress = widget.animated 
            ? _progressAnimation.value 
            : widget.progress.clamp(0.0, 1.0);
            
        return Container(
          height: _getHeight(),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(_getBorderRadius()),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            child: LinearProgressIndicator(
              value: animatedProgress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
          ),
        );
      },
    );
  }

  double _getHeight() {
    if (widget.height != null) return widget.height!;
    
    switch (widget.type) {
      case DuoProgressType.lesson:
        return 8.0; // From styles.json
      case DuoProgressType.xp:
        return 12.0; // From styles.json
    }
  }

  double _getBorderRadius() {
    switch (widget.type) {
      case DuoProgressType.lesson:
        return 4.0; // From styles.json
      case DuoProgressType.xp:
        return 6.0; // From styles.json
    }
  }

  Color _getBackgroundColor() {
    return const Color(0xFFF0F0F0); // From styles.json
  }

  Color _getProgressColor() {
    switch (widget.type) {
      case DuoProgressType.lesson:
        return DuolingoTheme.duoGreen; // From styles.json
      case DuoProgressType.xp:
        return DuolingoTheme.duoYellow; // From styles.json
    }
  }
}