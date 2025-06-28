import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/achievement_system.dart';

class AchievementBadge extends StatefulWidget {
  final Achievement achievement;
  final double size;
  final bool showProgress;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.size = 80.0,
    this.showProgress = false,
    this.onTap,
  });

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DuolingoTheme.normalAnimation,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.achievement.isUnlocked) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AchievementBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.achievement.isUnlocked && widget.achievement.isUnlocked) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRarityColor() {
    switch (widget.achievement.rarity) {
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

  IconData _getIconData() {
    final iconMap = {
      'school': Icons.school,
      'school_outlined': Icons.school_outlined,
      'emoji_events': Icons.emoji_events,
      'trending_up': Icons.trending_up,
      'show_chart': Icons.show_chart,
      'security': Icons.security,
      'local_fire_department': Icons.local_fire_department,
      'whatshot': Icons.whatshot,
      'celebration': Icons.celebration,
      'account_balance': Icons.account_balance,
      'domain': Icons.domain,
      'castle': Icons.castle,
      'people': Icons.people,
      'psychology': Icons.psychology,
      'leaderboard': Icons.leaderboard,
      'star': Icons.star,
      'star_rate': Icons.star_rate,
      'stars': Icons.stars,
      'wb_sunny': Icons.wb_sunny,
      'nights_stay': Icons.nights_stay,
    };
    
    return iconMap[widget.achievement.iconName] ?? Icons.star;
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();
    final isUnlocked = widget.achievement.isUnlocked;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle with rarity color
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isUnlocked ? _scaleAnimation.value : 0.9,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isUnlocked
                          ? RadialGradient(
                              colors: [
                                rarityColor.withValues(alpha: 0.8),
                                rarityColor,
                              ],
                            )
                          : null,
                      color: isUnlocked ? null : DuolingoTheme.lightGray,
                      border: Border.all(
                        color: isUnlocked ? rarityColor : DuolingoTheme.mediumGray,
                        width: 3.0,
                      ),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: rarityColor.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                  ),
                );
              },
            ),
            
            // Icon
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: isUnlocked ? _rotationAnimation.value * 0.1 : 0,
                  child: Icon(
                    isUnlocked ? _getIconData() : Icons.lock,
                    size: widget.size * 0.4,
                    color: isUnlocked ? DuolingoTheme.white : DuolingoTheme.darkGray,
                  ),
                );
              },
            ),
            
            // Progress indicator for multi-step achievements
            if (widget.showProgress && widget.achievement.totalSteps > 1 && !widget.achievement.isCompleted)
              Positioned(
                bottom: 0,
                child: Container(
                  width: widget.size * 0.8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DuolingoTheme.lightGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.achievement.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Rarity indicator
            if (isUnlocked && widget.achievement.rarity != AchievementRarity.common)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: widget.size * 0.25,
                  height: widget.size * 0.25,
                  decoration: BoxDecoration(
                    color: rarityColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: DuolingoTheme.white, width: 2),
                  ),
                  child: Icon(
                    _getRarityIcon(),
                    size: widget.size * 0.12,
                    color: DuolingoTheme.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getRarityIcon() {
    switch (widget.achievement.rarity) {
      case AchievementRarity.uncommon:
        return Icons.whatshot;
      case AchievementRarity.rare:
        return Icons.diamond;
      case AchievementRarity.epic:
        return Icons.auto_awesome;
      case AchievementRarity.legendary:
        return Icons.workspace_premium;
      default:
        return Icons.circle;
    }
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: DuolingoTheme.spacingMd,
          vertical: DuolingoTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: DuolingoTheme.white,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
          border: Border.all(
            color: isUnlocked 
                ? _getRarityColor().withValues(alpha: 0.3)
                : DuolingoTheme.lightGray,
            width: 2,
          ),
          boxShadow: isUnlocked 
              ? [
                  BoxShadow(
                    color: _getRarityColor().withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : DuolingoTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
          child: Row(
            children: [
              AchievementBadge(
                achievement: achievement,
                size: 60,
                showProgress: true,
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: DuolingoTheme.h4.copyWith(
                        color: isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.darkGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: DuolingoTheme.spacingXs),
                    Text(
                      achievement.description,
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: isUnlocked ? DuolingoTheme.darkGray : DuolingoTheme.mediumGray,
                      ),
                    ),
                    const SizedBox(height: DuolingoTheme.spacingSm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DuolingoTheme.spacingSm,
                            vertical: DuolingoTheme.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: _getRarityColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                          ),
                          child: Text(
                            achievement.rarity.name.toUpperCase(),
                            style: DuolingoTheme.caption.copyWith(
                              color: _getRarityColor(),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: DuolingoTheme.spacingSm),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: DuolingoTheme.duoYellow,
                        ),
                        const SizedBox(width: DuolingoTheme.spacingXs),
                        Text(
                          '${achievement.xpReward} XP',
                          style: DuolingoTheme.caption.copyWith(
                            color: DuolingoTheme.duoYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (achievement.totalSteps > 1) ...[
                      const SizedBox(height: DuolingoTheme.spacingSm),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: achievement.progress,
                              backgroundColor: DuolingoTheme.lightGray,
                              valueColor: AlwaysStoppedAnimation<Color>(_getRarityColor()),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(width: DuolingoTheme.spacingSm),
                          Text(
                            '${(achievement.progress * achievement.totalSteps).round()}/${achievement.totalSteps}',
                            style: DuolingoTheme.caption.copyWith(
                              color: DuolingoTheme.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor() {
    switch (achievement.rarity) {
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

class AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final Function(Achievement)? onAchievementTap;

  const AchievementGrid({
    super.key,
    required this.achievements,
    this.onAchievementTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: DuolingoTheme.spacingMd,
        mainAxisSpacing: DuolingoTheme.spacingMd,
        childAspectRatio: 0.8,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Column(
          children: [
            AchievementBadge(
              achievement: achievement,
              size: 70,
              showProgress: true,
              onTap: () => onAchievementTap?.call(achievement),
            ),
            const SizedBox(height: DuolingoTheme.spacingSm),
            Text(
              achievement.title,
              style: DuolingoTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: achievement.isUnlocked 
                    ? DuolingoTheme.charcoal 
                    : DuolingoTheme.darkGray,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}

class CategoryFilterChips extends StatelessWidget {
  final AchievementCategory? selectedCategory;
  final Function(AchievementCategory?) onCategorySelected;

  const CategoryFilterChips({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
      child: Row(
        children: [
          FilterChip(
            label: Text('All'),
            selected: selectedCategory == null,
            onSelected: (_) => onCategorySelected(null),
            selectedColor: DuolingoTheme.duoGreen.withValues(alpha: 0.2),
            checkmarkColor: DuolingoTheme.duoGreen,
          ),
          const SizedBox(width: DuolingoTheme.spacingSm),
          ...AchievementCategory.values.map((category) => Padding(
            padding: const EdgeInsets.only(right: DuolingoTheme.spacingSm),
            child: FilterChip(
              label: Text(_getCategoryDisplayName(category)),
              selected: selectedCategory == category,
              onSelected: (_) => onCategorySelected(category),
              selectedColor: DuolingoTheme.duoGreen.withValues(alpha: 0.2),
              checkmarkColor: DuolingoTheme.duoGreen,
            ),
          )),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(AchievementCategory category) {
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