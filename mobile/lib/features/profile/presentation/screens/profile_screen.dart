import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';
import '../../../../shared/widgets/duo_button.dart';
import '../../../../shared/widgets/gamification_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: DuolingoTheme.h3.copyWith(
            color: DuolingoTheme.charcoal,
          ),
        ),
        backgroundColor: DuolingoTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DuolingoTheme.charcoal),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: DuolingoTheme.duoGreen),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      backgroundColor: DuolingoTheme.lightGray,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        child: Column(
          children: [
            // Profile Header
            DuoCard(
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [DuolingoTheme.duoGreen, DuolingoTheme.duoGreenLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DuolingoTheme.duoGreen.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: DuolingoTheme.white,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  
                  // Name and Title
                  Text(
                    'Kingdom Builder',
                    style: DuolingoTheme.h3.copyWith(
                      color: DuolingoTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  const LevelBadge(
                    level: 'Village Citizen',
                    subtitle: 'Level 1',
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Days Streak', '7', DuolingoTheme.duoOrange),
                      _buildStatItem('Total XP', '150', DuolingoTheme.duoYellow),
                      _buildStatItem('Lessons', '12', DuolingoTheme.duoBlue),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Achievements Section
            DuoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Achievements',
                    style: DuolingoTheme.h4.copyWith(
                      color: DuolingoTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  
                  // Achievement Badges
                  Wrap(
                    spacing: DuolingoTheme.spacingSm,
                    runSpacing: DuolingoTheme.spacingSm,
                    children: [
                      _buildAchievementBadge(
                        'First Steps',
                        Icons.celebration,
                        DuolingoTheme.duoYellow,
                      ),
                      _buildAchievementBadge(
                        'Week Warrior',
                        Icons.local_fire_department,
                        DuolingoTheme.duoOrange,
                      ),
                      _buildAchievementBadge(
                        'Scholar',
                        Icons.school,
                        DuolingoTheme.duoBlue,
                      ),
                      _buildAchievementBadge(
                        'More Achievements',
                        Icons.add,
                        DuolingoTheme.mediumGray,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Progress Section
            DuoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning Progress',
                    style: DuolingoTheme.h4.copyWith(
                      color: DuolingoTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  
                  _buildProgressItem('Financial Literacy', 0.8, DuolingoTheme.duoGreen),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  _buildProgressItem('Risk Management', 0.4, DuolingoTheme.duoBlue),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  _buildProgressItem('Trading Basics', 0.2, DuolingoTheme.duoOrange),
                ],
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Action Buttons
            Column(
              children: [
                DuoButton(
                  text: 'Share Profile',
                  onPressed: () {
                    // Share profile functionality
                  },
                  type: DuoButtonType.primary,
                ),
                const SizedBox(height: DuolingoTheme.spacingMd),
                DuoButton(
                  text: 'View Leaderboard',
                  onPressed: () {
                    context.go('/social');
                  },
                  type: DuoButtonType.outline,
                ),
              ],
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          ),
          child: Text(
            value,
            style: DuolingoTheme.h3.copyWith(
              color: color,
            ),
          ),
        ),
        const SizedBox(height: DuolingoTheme.spacingSm),
        Text(
          label,
          style: DuolingoTheme.bodySmall.copyWith(
            color: DuolingoTheme.darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DuolingoTheme.spacingMd,
        vertical: DuolingoTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.0),
          const SizedBox(width: DuolingoTheme.spacingXs),
          Text(
            title,
            style: DuolingoTheme.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: DuolingoTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: DuolingoTheme.charcoal,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: DuolingoTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: DuolingoTheme.spacingSm),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: DuolingoTheme.lightGray,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }
}