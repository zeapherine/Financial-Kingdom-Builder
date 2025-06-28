import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../domain/models/leaderboard_system.dart';

class AnimatedLeaderboard extends StatefulWidget {
  final LeaderboardData leaderboardData;
  final VoidCallback? onRefresh;

  const AnimatedLeaderboard({
    super.key,
    required this.leaderboardData,
    this.onRefresh,
  });

  @override
  State<AnimatedLeaderboard> createState() => _AnimatedLeaderboardState();
}

class _AnimatedLeaderboardState extends State<AnimatedLeaderboard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _createSlideAnimations();
    _slideController.forward();
  }

  void _createSlideAnimations() {
    _slideAnimations = List.generate(
      widget.leaderboardData.entries.length,
      (index) => Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(
          index * 0.1,
          0.5 + (index * 0.1),
          curve: Curves.easeOut,
        ),
      )),
    );
  }

  @override
  void didUpdateWidget(AnimatedLeaderboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.leaderboardData.entries.length != 
        widget.leaderboardData.entries.length) {
      _createSlideAnimations();
      _slideController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      },
      color: DuolingoTheme.duoGreen,
      child: CustomScrollView(
        slivers: [
          // Header with top 3
          SliverToBoxAdapter(
            child: TopThreePodium(
              topThree: widget.leaderboardData.topThree,
            ),
          ),
          
          // Category and type selector
          SliverToBoxAdapter(
            child: LeaderboardControls(
              currentType: widget.leaderboardData.type,
              currentCategory: widget.leaderboardData.category,
              onTypeChanged: (type) {
                // Handle type change
              },
              onCategoryChanged: (category) {
                // Handle category change
              },
            ),
          ),
          
          // Rest of the leaderboard
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= _slideAnimations.length) return null;
                
                final entry = widget.leaderboardData.restOfEntries.isNotEmpty
                    ? widget.leaderboardData.restOfEntries[index]
                    : widget.leaderboardData.entries[index + 3];
                
                return SlideTransition(
                  position: _slideAnimations[index + 3],
                  child: AnimatedLeaderboardEntry(
                    entry: entry,
                    showRankChange: true,
                  ),
                );
              },
              childCount: widget.leaderboardData.restOfEntries.length,
            ),
          ),
        ],
      ),
    );
  }
}

class TopThreePodium extends StatefulWidget {
  final List<LeaderboardEntry> topThree;

  const TopThreePodium({
    super.key,
    required this.topThree,
  });

  @override
  State<TopThreePodium> createState() => _TopThreePodiumState();
}

class _TopThreePodiumState extends State<TopThreePodium>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotationAnimations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(3, (index) =>
      AnimationController(
        duration: Duration(milliseconds: 800 + (index * 200)),
        vsync: this,
      )
    );
    
    _scaleAnimations = _controllers.map((controller) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      )
    ).toList();
    
    _rotationAnimations = _controllers.map((controller) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      )
    ).toList();
    
    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 150));
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getPodiumColor(int rank) {
    switch (rank) {
      case 1:
        return DuolingoTheme.duoYellow; // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return DuolingoTheme.mediumGray;
    }
  }

  double _getPodiumHeight(int rank) {
    switch (rank) {
      case 1:
        return 120.0;
      case 2:
        return 100.0;
      case 3:
        return 80.0;
      default:
        return 60.0;
    }
  }

  IconData _getCrownIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.workspace_premium;
      case 2:
        return Icons.emoji_events;
      case 3:
        return Icons.military_tech;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.topThree.isEmpty) {
      return const SizedBox.shrink();
    }

    // Arrange entries: 2nd, 1st, 3rd for podium effect
    final arranged = <LeaderboardEntry?>[ 
      widget.topThree.length > 1 ? widget.topThree[1] : null, // 2nd place
      widget.topThree[0], // 1st place
      widget.topThree.length > 2 ? widget.topThree[2] : null, // 3rd place
    ];

    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DuolingoTheme.duoYellow.withValues(alpha: 0.1),
            DuolingoTheme.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Top Performers',
            style: DuolingoTheme.h2.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingXl),
          
          // Podium
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (index) {
              final entry = arranged[index];
              if (entry == null) return const SizedBox(width: 100);
              
              final animIndex = entry.rank - 1;
              if (animIndex >= _scaleAnimations.length) {
                return const SizedBox(width: 100);
              }
              
              return AnimatedBuilder(
                animation: _scaleAnimations[animIndex],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimations[animIndex].value,
                    child: PodiumEntry(
                      entry: entry,
                      podiumHeight: _getPodiumHeight(entry.rank),
                      podiumColor: _getPodiumColor(entry.rank),
                      crownIcon: _getCrownIcon(entry.rank),
                      rotationAnimation: _rotationAnimations[animIndex],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class PodiumEntry extends StatelessWidget {
  final LeaderboardEntry entry;
  final double podiumHeight;
  final Color podiumColor;
  final IconData crownIcon;
  final Animation<double> rotationAnimation;

  const PodiumEntry({
    super.key,
    required this.entry,
    required this.podiumHeight,
    required this.podiumColor,
    required this.crownIcon,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Crown and avatar
        Stack(
          alignment: Alignment.center,
          children: [
            // Crown
            AnimatedBuilder(
              animation: rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: rotationAnimation.value * 0.1 * math.sin(rotationAnimation.value * 4 * math.pi),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Icon(
                      crownIcon,
                      size: 40,
                      color: podiumColor,
                    ),
                  ),
                );
              },
            ),
            
            // Avatar
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: UserAvatar(
                username: entry.username,
                size: 60,
                isCurrentUser: entry.isCurrentUser,
                level: entry.level,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: DuolingoTheme.spacingSm),
        
        // Username
        Text(
          entry.username,
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: DuolingoTheme.charcoal,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Score
        Text(
          '${entry.score} XP',
          style: DuolingoTheme.bodySmall.copyWith(
            color: DuolingoTheme.darkGray,
          ),
        ),
        
        const SizedBox(height: DuolingoTheme.spacingSm),
        
        // Podium
        Container(
          width: 80,
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                podiumColor.withValues(alpha: 0.8),
                podiumColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(DuolingoTheme.radiusSmall),
              topRight: Radius.circular(DuolingoTheme.radiusSmall),
            ),
            border: Border.all(
              color: podiumColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${entry.rank}',
              style: DuolingoTheme.h2.copyWith(
                color: DuolingoTheme.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedLeaderboardEntry extends StatefulWidget {
  final LeaderboardEntry entry;
  final bool showRankChange;

  const AnimatedLeaderboardEntry({
    super.key,
    required this.entry,
    this.showRankChange = true,
  });

  @override
  State<AnimatedLeaderboardEntry> createState() => _AnimatedLeaderboardEntryState();
}

class _AnimatedLeaderboardEntryState extends State<AnimatedLeaderboardEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: DuolingoTheme.spacingMd,
                vertical: DuolingoTheme.spacingXs,
              ),
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              decoration: BoxDecoration(
                color: widget.entry.isCurrentUser
                    ? DuolingoTheme.duoGreen.withValues(alpha: 0.1)
                    : DuolingoTheme.white,
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                border: Border.all(
                  color: widget.entry.isCurrentUser
                      ? DuolingoTheme.duoGreen
                      : DuolingoTheme.lightGray,
                  width: widget.entry.isCurrentUser ? 2 : 1,
                ),
                boxShadow: widget.entry.isCurrentUser
                    ? [
                        BoxShadow(
                          color: DuolingoTheme.duoGreen.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : DuolingoTheme.cardShadow,
              ),
              child: Row(
                children: [
                  // Rank with rank change indicator
                  SizedBox(
                    width: 50,
                    child: Column(
                      children: [
                        Text(
                          '${widget.entry.rank}',
                          style: DuolingoTheme.h4.copyWith(
                            fontWeight: FontWeight.w700,
                            color: widget.entry.isCurrentUser
                                ? DuolingoTheme.duoGreen
                                : DuolingoTheme.charcoal,
                          ),
                        ),
                        
                        if (widget.showRankChange && widget.entry.rankChange != 0)
                          RankChangeIndicator(
                            change: widget.entry.rankChange,
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: DuolingoTheme.spacingMd),
                  
                  // Avatar
                  UserAvatar(
                    username: widget.entry.username,
                    size: 50,
                    isCurrentUser: widget.entry.isCurrentUser,
                    level: widget.entry.level,
                  ),
                  
                  const SizedBox(width: DuolingoTheme.spacingMd),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.entry.username,
                                style: DuolingoTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: widget.entry.isCurrentUser
                                      ? DuolingoTheme.duoGreen
                                      : DuolingoTheme.charcoal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            if (widget.entry.isCurrentUser)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DuolingoTheme.spacingXs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: DuolingoTheme.duoGreen,
                                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                                ),
                                child: Text(
                                  'YOU',
                                  style: DuolingoTheme.caption.copyWith(
                                    color: DuolingoTheme.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: DuolingoTheme.spacingXs),
                        
                        Text(
                          widget.entry.title,
                          style: DuolingoTheme.bodySmall.copyWith(
                            color: DuolingoTheme.darkGray,
                          ),
                        ),
                        
                        if (widget.entry.badges.isNotEmpty) ...[
                          const SizedBox(height: DuolingoTheme.spacingXs),
                          
                          Row(
                            children: widget.entry.badges.take(3).map((badge) =>
                              Container(
                                margin: const EdgeInsets.only(right: DuolingoTheme.spacingXs),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: DuolingoTheme.duoYellow.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.star,
                                  size: 12,
                                  color: DuolingoTheme.duoYellow,
                                ),
                              ),
                            ).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.entry.score}',
                        style: DuolingoTheme.h4.copyWith(
                          fontWeight: FontWeight.w700,
                          color: DuolingoTheme.duoBlue,
                        ),
                      ),
                      
                      Text(
                        'XP',
                        style: DuolingoTheme.bodySmall.copyWith(
                          color: DuolingoTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RankChangeIndicator extends StatefulWidget {
  final int change;

  const RankChangeIndicator({
    super.key,
    required this.change,
  });

  @override
  State<RankChangeIndicator> createState() => _RankChangeIndicatorState();
}

class _RankChangeIndicatorState extends State<RankChangeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isImprovement = widget.change > 0;
    final color = isImprovement ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed;
    final icon = isImprovement ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down;
    
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: color,
                ),
                Text(
                  '${widget.change.abs()}',
                  style: DuolingoTheme.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String username;
  final double size;
  final bool isCurrentUser;
  final int level;
  final String? avatarUrl;

  const UserAvatar({
    super.key,
    required this.username,
    this.size = 40.0,
    this.isCurrentUser = false,
    this.level = 1,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrentUser ? DuolingoTheme.duoGreen : DuolingoTheme.lightGray,
          width: isCurrentUser ? 3 : 2,
        ),
        gradient: avatarUrl == null
            ? LinearGradient(
                colors: [
                  _getAvatarColor(username),
                  _getAvatarColor(username).withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitials(),
              ),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: DuolingoTheme.bodyLarge.copyWith(
          color: DuolingoTheme.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );
  }

  Color _getAvatarColor(String username) {
    final colors = [
      DuolingoTheme.duoGreen,
      DuolingoTheme.duoBlue,
      DuolingoTheme.duoPurple,
      DuolingoTheme.duoOrange,
      DuolingoTheme.duoYellow,
    ];
    
    final hash = username.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

class LeaderboardControls extends StatelessWidget {
  final LeaderboardType currentType;
  final LeaderboardCategory currentCategory;
  final Function(LeaderboardType) onTypeChanged;
  final Function(LeaderboardCategory) onCategoryChanged;

  const LeaderboardControls({
    super.key,
    required this.currentType,
    required this.currentCategory,
    required this.onTypeChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      child: Column(
        children: [
          // Time period selector
          Row(
            children: [
              Text(
                'Period:',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LeaderboardType.values.map((type) {
                      final isSelected = type == currentType;
                      return Padding(
                        padding: const EdgeInsets.only(right: DuolingoTheme.spacingSm),
                        child: GestureDetector(
                          onTap: () => onTypeChanged(type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DuolingoTheme.spacingMd,
                              vertical: DuolingoTheme.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? DuolingoTheme.duoGreen
                                  : DuolingoTheme.lightGray,
                              borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
                            ),
                            child: Text(
                              _getTypeDisplayName(type),
                              style: DuolingoTheme.bodySmall.copyWith(
                                color: isSelected
                                    ? DuolingoTheme.white
                                    : DuolingoTheme.darkGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Category selector
          Row(
            children: [
              Text(
                'Category:',
                style: DuolingoTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LeaderboardCategory.values.map((category) {
                      final isSelected = category == currentCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: DuolingoTheme.spacingSm),
                        child: GestureDetector(
                          onTap: () => onCategoryChanged(category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DuolingoTheme.spacingMd,
                              vertical: DuolingoTheme.spacingSm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? DuolingoTheme.duoBlue
                                  : DuolingoTheme.lightGray,
                              borderRadius: BorderRadius.circular(DuolingoTheme.radiusPill),
                            ),
                            child: Text(
                              _getCategoryDisplayName(category),
                              style: DuolingoTheme.bodySmall.copyWith(
                                color: isSelected
                                    ? DuolingoTheme.white
                                    : DuolingoTheme.darkGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.weekly:
        return 'Weekly';
      case LeaderboardType.monthly:
        return 'Monthly';
      case LeaderboardType.allTime:
        return 'All Time';
      case LeaderboardType.friends:
        return 'Friends';
    }
  }

  String _getCategoryDisplayName(LeaderboardCategory category) {
    switch (category) {
      case LeaderboardCategory.totalXp:
        return 'Total XP';
      case LeaderboardCategory.streaks:
        return 'Streaks';
      case LeaderboardCategory.achievements:
        return 'Achievements';
      case LeaderboardCategory.tradingPerformance:
        return 'Trading';
      case LeaderboardCategory.socialContribution:
        return 'Social';
    }
  }
}