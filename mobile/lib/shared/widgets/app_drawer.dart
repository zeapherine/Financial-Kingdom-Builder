import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/duolingo_theme.dart';
import 'gamification_widgets.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: DuolingoTheme.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with user info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [DuolingoTheme.duoGreen, DuolingoTheme.duoGreenLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DuolingoTheme.white,
                      boxShadow: [
                        BoxShadow(
                          color: DuolingoTheme.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: DuolingoTheme.duoGreen,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  
                  // User name
                  Text(
                    'Kingdom Builder',
                    style: DuolingoTheme.h4.copyWith(
                      color: DuolingoTheme.white,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  
                  // Stats row
                  Row(
                    children: [
                      const XPBadge(xp: 150),
                      const SizedBox(width: DuolingoTheme.spacingSm),
                      const StreakCounter(streakCount: 7),
                    ],
                  ),
                ],
              ),
            ),
            
            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: DuolingoTheme.spacingSm),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.castle,
                    title: 'Kingdom',
                    subtitle: 'Build your empire',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/kingdom');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.school,
                    title: 'Education',
                    subtitle: 'Learn and grow',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/education');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.trending_up,
                    title: 'Trading',
                    subtitle: 'Practice and invest',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/trading');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.people,
                    title: 'Community',
                    subtitle: 'Connect with others',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/social');
                    },
                  ),
                  
                  const Divider(
                    height: DuolingoTheme.spacingLg,
                    thickness: 1,
                    color: DuolingoTheme.lightGray,
                    indent: DuolingoTheme.spacingMd,
                    endIndent: DuolingoTheme.spacingMd,
                  ),
                  
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'Your achievements',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/profile');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'Preferences',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/settings');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get assistance',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to help page
                    },
                  ),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              child: Column(
                children: [
                  const Divider(
                    height: 1,
                    color: DuolingoTheme.lightGray,
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    'Financial Kingdom Builder',
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  Text(
                    'Version 1.0.0',
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DuolingoTheme.lightGray,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
        ),
        child: Icon(
          icon,
          color: DuolingoTheme.duoGreen,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: DuolingoTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: DuolingoTheme.charcoal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: DuolingoTheme.bodySmall.copyWith(
          color: DuolingoTheme.darkGray,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DuolingoTheme.spacingMd,
        vertical: DuolingoTheme.spacingXs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
      ),
    );
  }
}