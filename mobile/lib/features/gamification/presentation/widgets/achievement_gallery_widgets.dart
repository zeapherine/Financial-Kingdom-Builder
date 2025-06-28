import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/achievement_system.dart';
import 'achievement_badge_widgets.dart';

class AchievementGallery extends StatefulWidget {
  final List<Achievement> achievements;
  final Function(Achievement)? onAchievementTap;

  const AchievementGallery({
    super.key,
    required this.achievements,
    this.onAchievementTap,
  });

  @override
  State<AchievementGallery> createState() => _AchievementGalleryState();
}

class _AchievementGalleryState extends State<AchievementGallery>
    with TickerProviderStateMixin {
  late TabController _tabController;
  AchievementCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AchievementCategory.values.length + 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Achievement> _getFilteredAchievements() {
    if (_selectedCategory == null) {
      return widget.achievements;
    }
    return widget.achievements
        .where((achievement) => achievement.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gallery header with stats
        Container(
          padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DuolingoTheme.duoPurple.withValues(alpha: 0.1),
                DuolingoTheme.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AchievementGalleryHeader(achievements: widget.achievements),
        ),
        
        // Category tabs
        CategoryFilterChips(
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
        
        const SizedBox(height: DuolingoTheme.spacingMd),
        
        // Achievement grid
        Expanded(
          child: AchievementGrid(
            achievements: _getFilteredAchievements(),
            onAchievementTap: widget.onAchievementTap,
          ),
        ),
      ],
    );
  }
}

class AchievementGalleryHeader extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementGalleryHeader({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final completionPercentage = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    
    // Rarity breakdown
    final rarityBreakdown = <AchievementRarity, int>{};
    for (final rarity in AchievementRarity.values) {
      rarityBreakdown[rarity] = achievements
          .where((a) => a.isUnlocked && a.rarity == rarity)
          .length;
    }

    return Column(
      children: [
        Text(
          'Achievement Gallery',
          style: DuolingoTheme.h2.copyWith(
            color: DuolingoTheme.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        
        const SizedBox(height: DuolingoTheme.spacingMd),
        
        // Progress overview
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                decoration: BoxDecoration(
                  color: DuolingoTheme.white,
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  border: Border.all(color: DuolingoTheme.lightGray),
                ),
                child: Column(
                  children: [
                    Text(
                      '$unlockedCount / $totalCount',
                      style: DuolingoTheme.h3.copyWith(
                        color: DuolingoTheme.duoPurple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                    Text(
                      'Achievements',
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.darkGray,
                      ),
                    ),
                    
                    const SizedBox(height: DuolingoTheme.spacingSm),
                    
                    LinearProgressIndicator(
                      value: completionPercentage,
                      backgroundColor: DuolingoTheme.lightGray,
                      valueColor: AlwaysStoppedAnimation<Color>(DuolingoTheme.duoPurple),
                      minHeight: 6,
                    ),
                    
                    const SizedBox(height: DuolingoTheme.spacingXs),
                    
                    Text(
                      '${(completionPercentage * 100).round()}% Complete',
                      style: DuolingoTheme.caption.copyWith(
                        color: DuolingoTheme.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: DuolingoTheme.spacingMd),
            
            // Rarity showcase
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                decoration: BoxDecoration(
                  color: DuolingoTheme.white,
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                  border: Border.all(color: DuolingoTheme.lightGray),
                ),
                child: Column(
                  children: [
                    Text(
                      'Rarest Achievement',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DuolingoTheme.charcoal,
                      ),
                    ),
                    
                    const SizedBox(height: DuolingoTheme.spacingSm),
                    
                    _buildRarestAchievement(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRarestAchievement() {
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();
    
    if (unlockedAchievements.isEmpty) {
      return Text(
        'None yet',
        style: DuolingoTheme.bodySmall.copyWith(
          color: DuolingoTheme.mediumGray,
        ),
      );
    }
    
    // Find the rarest unlocked achievement
    unlockedAchievements.sort((a, b) => b.rarity.index.compareTo(a.rarity.index));
    final rarest = unlockedAchievements.first;
    
    return Column(
      children: [
        AchievementBadge(
          achievement: rarest,
          size: 40,
        ),
        
        const SizedBox(height: DuolingoTheme.spacingXs),
        
        Text(
          rarest.title,
          style: DuolingoTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.charcoal,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        Text(
          rarest.rarity.name.toUpperCase(),
          style: DuolingoTheme.caption.copyWith(
            color: _getRarityColor(rarest.rarity),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return DuolingoTheme.mediumGray;
      case AchievementRarity.uncommon:
        return DuolingoTheme.duoGreen;
      case AchievementRarity.rare:
        return DuolingoTheme.duoBlue;
      case AchievementRarity.epic:
        return DuolingoTheme.duoPurple;
      case AchievementRarity.legendary:
        return DuolingoTheme.duoYellow;
    }
  }
}

class AchievementDetailModal extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailModal({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingXl),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DuolingoTheme.radiusLarge),
          topRight: Radius.circular(DuolingoTheme.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DuolingoTheme.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Achievement display
          AchievementBadge(
            achievement: achievement,
            size: 100,
            showProgress: true,
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Achievement details
          Text(
            achievement.title,
            style: DuolingoTheme.h3.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          Text(
            achievement.description,
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Achievement info
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: DuolingoTheme.lightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
            ),
            child: Column(
              children: [
                _buildInfoRow('Category', _getCategoryName(achievement.category)),
                _buildInfoRow('Rarity', achievement.rarity.name.toUpperCase()),
                _buildInfoRow('XP Reward', '${achievement.xpReward} XP'),
                
                if (achievement.isUnlocked && achievement.unlockedAt != null)
                  _buildInfoRow(
                    'Unlocked',
                    '${achievement.unlockedAt!.day}/${achievement.unlockedAt!.month}/${achievement.unlockedAt!.year}',
                  ),
                
                if (!achievement.isUnlocked && achievement.totalSteps > 1)
                  _buildInfoRow(
                    'Progress',
                    '${(achievement.progress * achievement.totalSteps).round()}/${achievement.totalSteps}',
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Requirements
          if (achievement.requirements.isNotEmpty) ...[
            Text(
              'Requirements:',
              style: DuolingoTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: DuolingoTheme.charcoal,
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingSm),
            
            ...achievement.requirements.map((requirement) =>
              Padding(
                padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingXs),
                child: Row(
                  children: [
                    Icon(
                      achievement.isUnlocked ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16,
                      color: achievement.isUnlocked ? DuolingoTheme.duoGreen : DuolingoTheme.mediumGray,
                    ),
                    
                    const SizedBox(width: DuolingoTheme.spacingSm),
                    
                    Expanded(
                      child: Text(
                        requirement,
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.darkGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: DuolingoTheme.spacingXl),
          
          // Close button
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: DuolingoTheme.primaryButton,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DuolingoTheme.bodySmall.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          
          Text(
            value,
            style: DuolingoTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: DuolingoTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.education:
        return 'Education';
      case AchievementCategory.trading:
        return 'Trading';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.kingdom:
        return 'Kingdom';
      case AchievementCategory.milestones:
        return 'Milestones';
    }
  }
}

class CategoryFilterChips extends StatelessWidget {
  final AchievementCategory? selectedCategory;
  final Function(AchievementCategory?) onCategorySelected;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
      child: Row(
        children: [
          // All categories
          _buildFilterChip(null, 'All'),
          
          const SizedBox(width: DuolingoTheme.spacingSm),
          
          // Individual categories
          ...AchievementCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: DuolingoTheme.spacingSm),
              child: _buildFilterChip(category, _getCategoryName(category)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(AchievementCategory? category, String label) {
    final isSelected = selectedCategory == category;
    
    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DuolingoTheme.spacingMd,
          vertical: DuolingoTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DuolingoTheme.duoPurple : DuolingoTheme.lightGray,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
          border: isSelected
              ? Border.all(color: DuolingoTheme.duoPurple, width: 2)
              : null,
        ),
        child: Text(
          label,
          style: DuolingoTheme.bodySmall.copyWith(
            color: isSelected ? DuolingoTheme.white : DuolingoTheme.darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.education:
        return 'Education';
      case AchievementCategory.trading:
        return 'Trading';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.kingdom:
        return 'Kingdom';
      case AchievementCategory.milestones:
        return 'Milestones';
    }
  }
}

class AchievementGrid extends StatefulWidget {
  final List<Achievement> achievements;
  final Function(Achievement)? onAchievementTap;

  const AchievementGrid({
    super.key,
    required this.achievements,
    this.onAchievementTap,
  });

  @override
  State<AchievementGrid> createState() => _AchievementGridState();
}

class _AchievementGridState extends State<AchievementGrid>
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
    _itemAnimations = List.generate(
      widget.achievements.length,
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
  void didUpdateWidget(AchievementGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.achievements.length != widget.achievements.length) {
      _createStaggeredAnimations();
      _staggerController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: DuolingoTheme.mediumGray,
            ),
            const SizedBox(height: DuolingoTheme.spacingMd),
            Text(
              'No achievements to display',
              style: DuolingoTheme.h4.copyWith(
                color: DuolingoTheme.mediumGray,
              ),
            ),
            Text(
              'Complete lessons to unlock achievements!',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: DuolingoTheme.spacingMd,
        mainAxisSpacing: DuolingoTheme.spacingMd,
        childAspectRatio: 0.9,
      ),
      itemCount: widget.achievements.length,
      itemBuilder: (context, index) {
        if (index >= _itemAnimations.length) {
          return const SizedBox.shrink();
        }
        
        return AnimatedBuilder(
          animation: _itemAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _itemAnimations[index].value,
              child: AchievementBadge(
                achievement: widget.achievements[index],
                size: 120,
                showProgress: true,
                onTap: () => widget.onAchievementTap?.call(widget.achievements[index]),
              ),
            );
          },
        );
      },
    );
  }
}