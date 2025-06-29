import 'package:flutter/material.dart';
import '../../../core/config/duolingo_theme.dart';
import '../providers/education_provider.dart';

class LibraryBookshelfWidget extends StatefulWidget {
  final List<EducationModule> modules;
  final Map<String, double> moduleProgress;
  final Function(EducationModule) onModuleTap;

  const LibraryBookshelfWidget({
    super.key,
    required this.modules,
    required this.moduleProgress,
    required this.onModuleTap,
  });

  @override
  State<LibraryBookshelfWidget> createState() => _LibraryBookshelfWidgetState();
}

class _LibraryBookshelfWidgetState extends State<LibraryBookshelfWidget>
    with TickerProviderStateMixin {
  late AnimationController _shelfAnimationController;
  late Animation<double> _shelfAnimation;

  @override
  void initState() {
    super.initState();
    _shelfAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shelfAnimation = CurvedAnimation(
      parent: _shelfAnimationController,
      curve: Curves.easeInOut,
    );
    _shelfAnimationController.forward();
  }

  @override
  void dispose() {
    _shelfAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shelfAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Knowledge Library',
              style: DuolingoTheme.h3.copyWith(
                color: DuolingoTheme.charcoal,
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingMd),
            _buildBookshelf(),
          ],
        );
      },
    );
  }

  Widget _buildBookshelf() {
    const booksPerShelf = 2;
    final numberOfShelves = (widget.modules.length / booksPerShelf).ceil();

    return Column(
      children: List.generate(numberOfShelves, (shelfIndex) {
        return _buildShelf(shelfIndex, booksPerShelf);
      }),
    );
  }

  Widget _buildShelf(int shelfIndex, int booksPerShelf) {
    final startIndex = shelfIndex * booksPerShelf;
    final endIndex = (startIndex + booksPerShelf).clamp(0, widget.modules.length);
    final shelfModules = widget.modules.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingLg),
      child: Column(
        children: [
          // Books on shelf
          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
            child: Row(
              children: [
                ...shelfModules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final module = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < shelfModules.length - 1 ? DuolingoTheme.spacingSm : 0,
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _shelfAnimation,
                          curve: Interval(
                            (startIndex + index) * 0.1,
                            ((startIndex + index) * 0.1 + 0.3).clamp(0.0, 1.0),
                            curve: Curves.easeOutBack,
                          ),
                        )),
                        child: _buildBook(module),
                      ),
                    ),
                  );
                }),
                // Fill remaining space if shelf is not full
                if (shelfModules.length < booksPerShelf) ...[
                  ...List.generate(
                    booksPerShelf - shelfModules.length,
                    (index) => Expanded(child: Container()),
                  ),
                ],
              ],
            ),
          ),
          // Wooden shelf
          Container(
            height: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF8B4513),
                  const Color(0xFF654321),
                ],
              ),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Shelf support
          Row(
            children: [
              Container(
                width: 8,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF654321),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF654321),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBook(EducationModule module) {
    final progress = widget.moduleProgress[module.id] ?? 0.0;
    final isCompleted = progress >= 1.0;
    final bookColor = _getBookColor(module.category);
    final spineColor = _getSpineColor(module.category);

    return Semantics(
      label: '${module.title}. Category: ${module.category}. ${isCompleted ? 'Completed' : 'Progress: ${(progress * 100).toInt()}%'}. ${module.isLocked ? 'Locked' : 'Available'}',
      hint: module.isLocked ? 'Complete previous modules to unlock' : 'Tap to open lesson',
      button: !module.isLocked,
      child: GestureDetector(
        onTap: () => widget.onModuleTap(module),
        child: AnimatedContainer(
        duration: DuolingoTheme.normalAnimation,
        curve: Curves.easeInOut,
        child: Stack(
          children: [
            // Book container
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: module.isLocked
                      ? [DuolingoTheme.mediumGray, DuolingoTheme.lightGray]
                      : [bookColor, bookColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                boxShadow: module.isLocked ? [] : DuolingoTheme.cardShadow,
              ),
              child: Column(
                children: [
                  // Book spine
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: module.isLocked ? DuolingoTheme.darkGray : spineColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(DuolingoTheme.radiusSmall),
                        topRight: Radius.circular(DuolingoTheme.radiusSmall),
                      ),
                    ),
                  ),
                  // Book content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(DuolingoTheme.spacingSm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Module icon
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: module.isLocked 
                                  ? DuolingoTheme.mediumGray 
                                  : DuolingoTheme.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                            ),
                            child: Icon(
                              module.isLocked ? Icons.lock : _getModuleIcon(module.category),
                              color: module.isLocked 
                                  ? DuolingoTheme.white 
                                  : bookColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: DuolingoTheme.spacingXs),
                          // Module title
                          Expanded(
                            child: Text(
                              module.title,
                              style: DuolingoTheme.bodySmall.copyWith(
                                color: module.isLocked 
                                    ? DuolingoTheme.white.withValues(alpha: 0.7)
                                    : DuolingoTheme.white,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Progress indicator
                          if (!module.isLocked) ...[
                            const SizedBox(height: DuolingoTheme.spacingXs),
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: DuolingoTheme.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: DuolingoTheme.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Completion badge
            if (isCompleted)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: DuolingoTheme.duoYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: DuolingoTheme.white,
                    size: 12,
                  ),
                ),
              ),
            // Lock overlay
            if (module.isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: DuolingoTheme.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }

  Color _getBookColor(String category) {
    switch (category) {
      case 'Financial Literacy':
        return DuolingoTheme.duoGreen;
      case 'Cryptocurrency':
        return DuolingoTheme.duoOrange;
      case 'Risk Management':
        return DuolingoTheme.duoRed;
      case 'Trading':
        return DuolingoTheme.duoBlue;
      case 'Compliance':
        return DuolingoTheme.duoPurple;
      case 'Portfolio Management':
        return DuolingoTheme.duoYellow;
      default:
        return DuolingoTheme.duoGreen;
    }
  }

  Color _getSpineColor(String category) {
    switch (category) {
      case 'Financial Literacy':
        return DuolingoTheme.duoGreenDark;
      case 'Cryptocurrency':
        return const Color(0xFFE07600);
      case 'Risk Management':
        return const Color(0xFFCC3B3B);
      case 'Trading':
        return DuolingoTheme.duoBlueDark;
      case 'Compliance':
        return const Color(0xFFB565FF);
      case 'Portfolio Management':
        return const Color(0xFFE6B800);
      default:
        return DuolingoTheme.duoGreenDark;
    }
  }

  IconData _getModuleIcon(String category) {
    switch (category) {
      case 'Financial Literacy':
        return Icons.account_balance_wallet;
      case 'Cryptocurrency':
        return Icons.currency_bitcoin;
      case 'Risk Management':
        return Icons.security;
      case 'Trading':
        return Icons.trending_up;
      case 'Compliance':
        return Icons.gavel;
      case 'Portfolio Management':
        return Icons.pie_chart;
      default:
        return Icons.school;
    }
  }
}