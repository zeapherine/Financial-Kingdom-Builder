import 'package:flutter/material.dart';
import '../../../core/config/duolingo_theme.dart';

class OfflineIndicatorWidget extends StatefulWidget {
  const OfflineIndicatorWidget({super.key});

  @override
  State<OfflineIndicatorWidget> createState() => _OfflineIndicatorWidgetState();
}

class _OfflineIndicatorWidgetState extends State<OfflineIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isOnline = true; // This would be connected to actual connectivity

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (!_isOnline) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DuolingoTheme.spacingSm,
              vertical: DuolingoTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: DuolingoTheme.duoOrange,
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40FF9600),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off,
                  color: DuolingoTheme.white,
                  size: 16,
                ),
                const SizedBox(width: DuolingoTheme.spacingXs),
                Text(
                  'Offline',
                  style: DuolingoTheme.caption.copyWith(
                    color: DuolingoTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // This method would be called when connectivity changes
  void _updateConnectivity(bool isOnline) {
    if (_isOnline != isOnline) {
      setState(() {
        _isOnline = isOnline;
      });

      if (!_isOnline) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }
}