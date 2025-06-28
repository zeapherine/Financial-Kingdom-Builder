import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/collection_system.dart';

class CollectionInventoryGrid extends StatefulWidget {
  final CollectionData collectionData;
  final CollectionCategory? selectedCategory;
  final Function(CollectionItem)? onItemTap;

  const CollectionInventoryGrid({
    super.key,
    required this.collectionData,
    this.selectedCategory,
    this.onItemTap,
  });

  @override
  State<CollectionInventoryGrid> createState() => _CollectionInventoryGridState();
}

class _CollectionInventoryGridState extends State<CollectionInventoryGrid>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  List<Animation<double>> _itemAnimations = [];

  @override
  void initState() {
    super.initState();
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _createStaggeredAnimations();
    _staggerController.forward();
  }

  void _createStaggeredAnimations() {
    final items = _getFilteredItems();
    _itemAnimations = List.generate(
      items.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          index * 0.05,
          0.5 + (index * 0.05),
          curve: Curves.easeOut,
        ),
      )),
    );
  }

  @override
  void didUpdateWidget(CollectionInventoryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _createStaggeredAnimations();
      _staggerController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  List<CollectionItem> _getFilteredItems() {
    if (widget.selectedCategory == null) {
      return widget.collectionData.items;
    }
    return widget.collectionData.items
        .where((item) => item.category == widget.selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _getFilteredItems();
    
    return GridView.builder(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: DuolingoTheme.spacingSm,
        mainAxisSpacing: DuolingoTheme.spacingSm,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (index >= _itemAnimations.length) {
          return const SizedBox.shrink();
        }
        
        return AnimatedBuilder(
          animation: _itemAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _itemAnimations[index].value,
              child: CollectionItemCard(
                item: items[index],
                onTap: () => widget.onItemTap?.call(items[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class CollectionItemCard extends StatefulWidget {
  final CollectionItem item;
  final VoidCallback? onTap;
  final bool showDetails;

  const CollectionItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.showDetails = false,
  });

  @override
  State<CollectionItemCard> createState() => _CollectionItemCardState();
}

class _CollectionItemCardState extends State<CollectionItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _hoverController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _hoverController.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _hoverController.reverse();
  }

  Color _getRarityColor() {
    switch (widget.item.rarity) {
      case CollectionRarity.common:
        return DuolingoTheme.mediumGray;
      case CollectionRarity.uncommon:
        return DuolingoTheme.duoGreen;
      case CollectionRarity.rare:
        return DuolingoTheme.duoBlue;
      case CollectionRarity.epic:
        return DuolingoTheme.duoPurple;
      case CollectionRarity.legendary:
        return DuolingoTheme.duoYellow;
      case CollectionRarity.mythic:
        return DuolingoTheme.duoRed;
    }
  }

  IconData _getIconData() {
    final iconMap = {
      'directions_walk': Icons.directions_walk,
      'flash_on': Icons.flash_on,
      'school': Icons.school,
      'emoji_events': Icons.emoji_events,
      'whatshot': Icons.whatshot,
      'trending_up': Icons.trending_up,
      'diamond': Icons.diamond,
      'assessment': Icons.assessment,
      'security': Icons.security,
      'auto_awesome': Icons.auto_awesome,
      'show_chart': Icons.show_chart,
    };
    
    return iconMap[widget.item.iconName] ?? Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();
    final isUnlocked = widget.item.isUnlocked;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [
                          rarityColor.withValues(alpha: 0.2),
                          rarityColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUnlocked ? null : DuolingoTheme.lightGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                border: Border.all(
                  color: isUnlocked ? rarityColor : DuolingoTheme.mediumGray,
                  width: 2,
                ),
                boxShadow: [
                  if (isUnlocked)
                    BoxShadow(
                      color: rarityColor.withValues(alpha: 0.3 * _glowAnimation.value),
                      blurRadius: 12 * _glowAnimation.value,
                      spreadRadius: 2 * _glowAnimation.value,
                    ),
                  ...DuolingoTheme.cardShadow,
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern for unlocked items
                  if (isUnlocked)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CollectionCardPatternPainter(
                          color: rarityColor.withValues(alpha: 0.1),
                          rarity: widget.item.rarity,
                        ),
                      ),
                    ),
                  
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(DuolingoTheme.spacingSm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? rarityColor.withValues(alpha: 0.2)
                                : DuolingoTheme.mediumGray.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isUnlocked ? rarityColor : DuolingoTheme.mediumGray,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isUnlocked ? _getIconData() : Icons.lock,
                            size: 24,
                            color: isUnlocked ? rarityColor : DuolingoTheme.darkGray,
                          ),
                        ),
                        
                        const SizedBox(height: DuolingoTheme.spacingSm),
                        
                        // Name
                        Text(
                          widget.item.name,
                          style: DuolingoTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        if (widget.showDetails) ...[
                          const SizedBox(height: DuolingoTheme.spacingXs),
                          
                          // Rarity indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DuolingoTheme.spacingXs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: rarityColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                            ),
                            child: Text(
                              widget.item.rarity.name.toUpperCase(),
                              style: DuolingoTheme.caption.copyWith(
                                color: rarityColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Rarity border effect
                  if (isUnlocked && widget.item.rarity.index >= CollectionRarity.epic.index)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                              border: Border.all(
                                color: rarityColor.withValues(
                                  alpha: 0.6 * (0.5 + 0.5 * _glowAnimation.value),
                                ),
                                width: 1,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Lock overlay
                  if (!isUnlocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                        ),
                      ),
                    ),
                  
                  // Time-limited indicator
                  if (widget.item.isTimeLimited && isUnlocked)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: DuolingoTheme.duoRed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.schedule,
                          size: 10,
                          color: DuolingoTheme.white,
                        ),
                      ),
                    ),
                  
                  // New item indicator
                  if (isUnlocked && _isNewItem())
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: DuolingoTheme.duoGreen,
                          borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                        ),
                        child: Text(
                          'NEW',
                          style: DuolingoTheme.caption.copyWith(
                            color: DuolingoTheme.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isNewItem() {
    if (widget.item.unlockedAt == null) return false;
    final daysSinceUnlock = DateTime.now().difference(widget.item.unlockedAt!).inDays;
    return daysSinceUnlock <= 3;
  }
}

class CollectionSetCard extends StatefulWidget {
  final CollectionSet set;
  final List<CollectionItem> userItems;
  final VoidCallback? onTap;

  const CollectionSetCard({
    super.key,
    required this.set,
    required this.userItems,
    this.onTap,
  });

  @override
  State<CollectionSetCard> createState() => _CollectionSetCardState();
}

class _CollectionSetCardState extends State<CollectionSetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    final progress = widget.set.getCompletionPercentage(widget.userItems);
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));
    
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Color _getRarityColor() {
    switch (widget.set.rarity) {
      case CollectionRarity.common:
        return DuolingoTheme.mediumGray;
      case CollectionRarity.uncommon:
        return DuolingoTheme.duoGreen;
      case CollectionRarity.rare:
        return DuolingoTheme.duoBlue;
      case CollectionRarity.epic:
        return DuolingoTheme.duoPurple;
      case CollectionRarity.legendary:
        return DuolingoTheme.duoYellow;
      case CollectionRarity.mythic:
        return DuolingoTheme.duoRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();
    final isCompleted = widget.set.isCompleted(widget.userItems);
    final progress = widget.set.getCompletionPercentage(widget.userItems);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: DuolingoTheme.spacingMd,
          vertical: DuolingoTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    rarityColor.withValues(alpha: 0.2),
                    rarityColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isCompleted ? null : DuolingoTheme.white,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
          border: Border.all(
            color: isCompleted ? rarityColor : DuolingoTheme.lightGray,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : DuolingoTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.set.name,
                          style: DuolingoTheme.h4.copyWith(
                            color: isCompleted ? rarityColor : DuolingoTheme.charcoal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: DuolingoTheme.spacingXs),
                        
                        Text(
                          widget.set.description,
                          style: DuolingoTheme.bodySmall.copyWith(
                            color: DuolingoTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Completion status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DuolingoTheme.spacingSm,
                      vertical: DuolingoTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? rarityColor.withValues(alpha: 0.2)
                          : DuolingoTheme.lightGray,
                      borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
                    ),
                    child: Text(
                      isCompleted ? 'COMPLETE' : '${(progress * 100).round()}%',
                      style: DuolingoTheme.caption.copyWith(
                        color: isCompleted ? rarityColor : DuolingoTheme.darkGray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: DuolingoTheme.spacingMd),
              
              // Progress bar
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: DuolingoTheme.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                    minHeight: 6,
                  );
                },
              ),
              
              const SizedBox(height: DuolingoTheme.spacingSm),
              
              // Items count
              Text(
                '${widget.set.itemIds.where((id) => widget.userItems.any((item) => item.id == id && item.isUnlocked)).length}/${widget.set.itemIds.length} items collected',
                style: DuolingoTheme.bodySmall.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
              
              // Bonus description
              if (widget.set.bonusDescription != null && isCompleted) ...[
                const SizedBox(height: DuolingoTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.all(DuolingoTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: rarityColor,
                      ),
                      const SizedBox(width: DuolingoTheme.spacingXs),
                      Expanded(
                        child: Text(
                          widget.set.bonusDescription!,
                          style: DuolingoTheme.bodySmall.copyWith(
                            color: rarityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CollectionCategoryFilter extends StatelessWidget {
  final CollectionCategory? selectedCategory;
  final Function(CollectionCategory?) onCategoryChanged;
  final Map<CollectionCategory, int> categoryProgress;

  const CollectionCategoryFilter({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    required this.categoryProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
      child: Row(
        children: [
          // All categories
          _buildFilterChip(null, 'All', _getTotalProgress()),
          
          const SizedBox(width: DuolingoTheme.spacingSm),
          
          // Individual categories
          ...CollectionCategory.values.map((category) {
            final count = categoryProgress[category] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(right: DuolingoTheme.spacingSm),
              child: _buildFilterChip(category, _getCategoryName(category), count),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(CollectionCategory? category, String label, int count) {
    final isSelected = selectedCategory == category;
    
    return GestureDetector(
      onTap: () => onCategoryChanged(category),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DuolingoTheme.spacingMd,
          vertical: DuolingoTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DuolingoTheme.duoGreen : DuolingoTheme.lightGray,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
          border: isSelected
              ? Border.all(color: DuolingoTheme.duoGreen, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: DuolingoTheme.bodySmall.copyWith(
                color: isSelected ? DuolingoTheme.white : DuolingoTheme.darkGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: DuolingoTheme.spacingXs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? DuolingoTheme.white.withValues(alpha: 0.3)
                      : DuolingoTheme.darkGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: DuolingoTheme.caption.copyWith(
                    color: isSelected ? DuolingoTheme.white : DuolingoTheme.darkGray,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryName(CollectionCategory category) {
    switch (category) {
      case CollectionCategory.badges:
        return 'Badges';
      case CollectionCategory.cards:
        return 'Cards';
      case CollectionCategory.trophies:
        return 'Trophies';
      case CollectionCategory.artifacts:
        return 'Artifacts';
      case CollectionCategory.skills:
        return 'Skills';
      case CollectionCategory.titles:
        return 'Titles';
    }
  }

  int _getTotalProgress() {
    return categoryProgress.values.fold(0, (sum, count) => sum + count);
  }
}

class CollectionCardPatternPainter extends CustomPainter {
  final Color color;
  final CollectionRarity rarity;

  CollectionCardPatternPainter({
    required this.color,
    required this.rarity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    switch (rarity) {
      case CollectionRarity.common:
        _drawSimplePattern(canvas, size, paint);
        break;
      case CollectionRarity.uncommon:
        _drawDotPattern(canvas, size, paint);
        break;
      case CollectionRarity.rare:
        _drawLinePattern(canvas, size, paint);
        break;
      case CollectionRarity.epic:
        _drawGeometricPattern(canvas, size, paint);
        break;
      case CollectionRarity.legendary:
        _drawStarPattern(canvas, size, paint);
        break;
      case CollectionRarity.mythic:
        _drawComplexPattern(canvas, size, paint);
        break;
    }
  }

  void _drawSimplePattern(Canvas canvas, Size size, Paint paint) {
    // Simple corner decorations
    for (int i = 0; i < 4; i++) {
      final x = i % 2 == 0 ? 8.0 : size.width - 8.0;
      final y = i < 2 ? 8.0 : size.height - 8.0;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  void _drawDotPattern(Canvas canvas, Size size, Paint paint) {
    final spacing = 20.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  void _drawLinePattern(Canvas canvas, Size size, Paint paint) {
    final spacing = 15.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 10, size.height),
        paint,
      );
    }
  }

  void _drawGeometricPattern(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (int i = 0; i < 3; i++) {
      final radius = 15.0 + (i * 10);
      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }
    
    // Diamond shape
    final path = Path();
    path.moveTo(centerX, centerY - 20);
    path.lineTo(centerX + 15, centerY);
    path.lineTo(centerX, centerY + 20);
    path.lineTo(centerX - 15, centerY);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStarPattern(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * (math.pi / 180);
      final x1 = centerX + 20 * math.cos(angle);
      final y1 = centerY + 20 * math.sin(angle);
      
      canvas.drawLine(Offset(centerX, centerY), Offset(x1, y1), paint);
    }
  }

  void _drawComplexPattern(Canvas canvas, Size size, Paint paint) {
    // Combination of multiple patterns
    _drawGeometricPattern(canvas, size, paint);
    _drawStarPattern(canvas, size, paint);
    
    // Additional spiral
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final path = Path();
    
    for (double t = 0; t < 4 * math.pi; t += 0.1) {
      final radius = t * 2;
      final x = centerX + radius * math.cos(t);
      final y = centerY + radius * math.sin(t);
      
      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CollectionCardPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.rarity != rarity;
  }
}