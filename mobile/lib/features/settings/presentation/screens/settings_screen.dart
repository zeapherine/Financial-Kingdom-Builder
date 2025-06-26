import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';
import '../../../../shared/widgets/duo_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
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
      ),
      backgroundColor: DuolingoTheme.lightGray,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionTitle('Account'),
            const SizedBox(height: DuolingoTheme.spacingSm),
            DuoCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'Manage your profile information',
                    onTap: () => context.push('/profile'),
                  ),
                  const Divider(height: 1),
                  _buildSettingItem(
                    icon: Icons.security,
                    title: 'Security',
                    subtitle: 'Password and biometric settings',
                    onTap: () {
                      // Navigate to security settings
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingItem(
                    icon: Icons.privacy_tip,
                    title: 'Privacy',
                    subtitle: 'Control your data and privacy',
                    onTap: () {
                      // Navigate to privacy settings
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Learning Section
            _buildSectionTitle('Learning'),
            const SizedBox(height: DuolingoTheme.spacingSm),
            DuoCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Reminders and alerts',
                    onTap: () {
                      // Navigate to notification settings
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingItem(
                    icon: Icons.schedule,
                    title: 'Daily Goal',
                    subtitle: 'Set your learning target',
                    onTap: () {
                      // Navigate to goal settings
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingItem(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'App language preferences',
                    onTap: () {
                      // Navigate to language settings
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Support Section
            _buildSectionTitle('Support'),
            const SizedBox(height: DuolingoTheme.spacingSm),
            DuoCard(
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'Get help and support',
                    onTap: () {
                      // Navigate to help center
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingItem(
                    icon: Icons.bug_report,
                    title: 'Report a Problem',
                    subtitle: 'Send feedback or report issues',
                    onTap: () {
                      // Navigate to feedback form
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      // Navigate to about page
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingXl),
            
            // Sign Out Button
            Center(
              child: DuoButton(
                text: 'Sign Out',
                onPressed: () {
                  _showSignOutDialog(context);
                },
                type: DuoButtonType.outline,
              ),
            ),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DuolingoTheme.h4.copyWith(
        color: DuolingoTheme.charcoal,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(DuolingoTheme.spacingSm),
        decoration: BoxDecoration(
          color: DuolingoTheme.lightGray,
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
        ),
        child: Icon(
          icon,
          color: DuolingoTheme.duoGreen,
          size: 24.0,
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
      trailing: const Icon(
        Icons.chevron_right,
        color: DuolingoTheme.mediumGray,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DuolingoTheme.spacingMd,
        vertical: DuolingoTheme.spacingSm,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
          ),
          title: Text(
            'Sign Out',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DuolingoTheme.duoRed,
                foregroundColor: DuolingoTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                ),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}