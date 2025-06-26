import 'package:flutter/material.dart';
import '../../core/config/duolingo_theme.dart';

class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;

  const TutorialOverlay({
    super.key,
    required this.child,
    required this.steps,
    this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentStep = 0;
  bool _showTutorial = true;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Start tutorial after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.steps.isNotEmpty) {
        _showTutorialStep();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showTutorialStep() {
    if (_currentStep >= widget.steps.length) {
      _completeTutorial();
      return;
    }

    _removeOverlay();
    _animationController.reset();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildTutorialOverlay(),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _nextStep() {
    _currentStep++;
    _showTutorialStep();
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _completeTutorial() {
    _removeOverlay();
    setState(() {
      _showTutorial = false;
    });
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Widget _buildTutorialOverlay() {
    final step = widget.steps[_currentStep];
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Material(
            color: DuolingoTheme.black.withValues(alpha: 0.7),
            child: Stack(
              children: [
                // Highlight area (punch hole effect)
                if (step.targetKey.currentContext != null)
                  _buildHighlightHole(step.targetKey),
                
                // Tutorial tooltip
                Positioned(
                  left: step.tooltipPosition.dx,
                  top: step.tooltipPosition.dy,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildTooltip(step),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighlightHole(GlobalKey targetKey) {
    final RenderBox? renderBox = 
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (renderBox == null) return const SizedBox.shrink();
    
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    return Positioned(
      left: offset.dx - 8,
      top: offset.dy - 8,
      width: size.width + 16,
      height: size.height + 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          border: Border.all(
            color: DuolingoTheme.duoYellow,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: DuolingoTheme.duoYellow.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(TutorialStep step) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: DuolingoTheme.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: _skipTutorial,
              child: Container(
                padding: const EdgeInsets.all(DuolingoTheme.spacingXs),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ),
          ),
          
          // Content
          Text(
            step.title,
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            step.description,
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Step indicator
              Text(
                '${_currentStep + 1} of ${widget.steps.length}',
                style: DuolingoTheme.caption.copyWith(
                  color: DuolingoTheme.mediumGray,
                ),
              ),
              
              // Next button
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DuolingoTheme.duoGreen,
                  foregroundColor: DuolingoTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DuolingoTheme.spacingMd,
                    vertical: DuolingoTheme.spacingSm,
                  ),
                ),
                child: Text(
                  _currentStep == widget.steps.length - 1 ? 'Got it!' : 'Next',
                  style: DuolingoTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TutorialStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final Offset tooltipPosition;

  TutorialStep({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.tooltipPosition,
  });
}

