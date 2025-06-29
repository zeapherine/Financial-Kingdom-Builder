import 'package:flutter/material.dart';
import '../../../core/config/duolingo_theme.dart';

class ReadingProgressWidget extends StatefulWidget {
  final double progress;
  final Color? progressColor;
  final Color? backgroundColor;

  const ReadingProgressWidget({
    super.key,
    required this.progress,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  State<ReadingProgressWidget> createState() => _ReadingProgressWidgetState();
}

class _ReadingProgressWidgetState extends State<ReadingProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ReadingProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = oldWidget.progress;
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4.0,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? DuolingoTheme.white.withValues(alpha: 0.3),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ReadingProgressPainter(
              progress: _progressAnimation.value,
              progressColor: widget.progressColor ?? DuolingoTheme.white,
              backgroundColor: widget.backgroundColor ?? DuolingoTheme.white.withValues(alpha: 0.3),
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ReadingProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  _ReadingProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw progress with gradient
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            progressColor,
            progressColor.withValues(alpha: 0.8),
            progressColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width * progress, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * progress, size.height),
        progressPaint,
      );

      // Add a subtle glow effect at the progress end
      if (progress < 1.0) {
        final glowPaint = Paint()
          ..color = progressColor.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

        canvas.drawCircle(
          Offset(size.width * progress, size.height / 2),
          size.height / 2,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _ReadingProgressPainter) {
      return oldDelegate.progress != progress ||
          oldDelegate.progressColor != progressColor ||
          oldDelegate.backgroundColor != backgroundColor;
    }
    return true;
  }
}