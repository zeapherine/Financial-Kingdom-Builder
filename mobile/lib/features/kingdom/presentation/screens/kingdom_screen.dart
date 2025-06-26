import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';
import '../../../../shared/widgets/gamification_widgets.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/tutorial_overlay.dart';
import '../../../../shared/widgets/tutorial_target.dart';

class KingdomScreen extends ConsumerStatefulWidget {
  const KingdomScreen({super.key});

  @override
  ConsumerState<KingdomScreen> createState() => _KingdomScreenState();
}

class _KingdomScreenState extends ConsumerState<KingdomScreen> {
  final GlobalKey _levelBadgeKey = GlobalKey();
  final GlobalKey _libraryKey = GlobalKey();
  final GlobalKey _drawerKey = GlobalKey();
  final GlobalKey _xpBadgeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      steps: [
        TutorialStep(
          targetKey: _drawerKey,
          title: 'Navigation Menu',
          description: 'Tap the menu icon to access your profile, settings, and more!',
          tooltipPosition: const Offset(20, 100),
        ),
        TutorialStep(
          targetKey: _xpBadgeKey,
          title: 'Experience Points',
          description: 'Complete lessons and trading activities to earn XP and level up!',
          tooltipPosition: const Offset(50, 100),
        ),
        TutorialStep(
          targetKey: _levelBadgeKey,
          title: 'Your Current Level',
          description: 'Start as a Village Citizen and progress to Kingdom Mastery through education!',
          tooltipPosition: const Offset(50, 200),
        ),
        TutorialStep(
          targetKey: _libraryKey,
          title: 'Library - Start Here!',
          description: 'Begin your journey with financial education. Complete modules to unlock trading features.',
          tooltipPosition: const Offset(50, 300),
        ),
      ],
      onComplete: () {
        // TODO: Mark tutorial as completed in preferences
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Your Kingdom'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
            child: Row(
              children: [
                TutorialTarget(
                  tutorialKey: _xpBadgeKey,
                  child: const XPBadge(xp: 150),
                ),
                const SizedBox(width: DuolingoTheme.spacingSm),
                const StreakCounter(streakCount: 7),
              ],
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Level Badge
            TutorialTarget(
              tutorialKey: _levelBadgeKey,
              child: const LevelBadge(
                level: 'Village Citizen',
                subtitle: 'Level 1',
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Kingdom Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DuolingoTheme.duoGreen,
                shape: BoxShape.circle,
                boxShadow: DuolingoTheme.elevatedShadow,
              ),
              child: const Icon(
                Icons.castle,
                size: DuolingoTheme.iconXlarge + 16,
                color: DuolingoTheme.white,
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Title
            Text(
              'Village Stage',
              style: DuolingoTheme.h2.copyWith(
                color: DuolingoTheme.charcoal,
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingSm),
            
            // Subtitle
            Text(
              'Complete educational modules to grow your kingdom',
              style: DuolingoTheme.bodyMedium.copyWith(
                color: DuolingoTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DuolingoTheme.spacingXl),
            
            // Buildings Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: DuolingoTheme.spacingMd,
              mainAxisSpacing: DuolingoTheme.spacingMd,
              children: [
                TutorialTarget(
                  tutorialKey: _libraryKey,
                  child: _KingdomBuilding(
                    icon: Icons.library_books,
                    label: 'Library',
                    description: 'Learn & Study',
                    isUnlocked: true,
                    onTap: () => context.go('/education'),
                  ),
                ),
                _KingdomBuilding(
                  icon: Icons.store,
                  label: 'Trading Post',
                  description: 'Practice Trading',
                  isUnlocked: false,
                ),
                _KingdomBuilding(
                  icon: Icons.account_balance,
                  label: 'Treasury',
                  description: 'Manage Portfolio',
                  isUnlocked: false,
                ),
                _KingdomBuilding(
                  icon: Icons.people,
                  label: 'Community',
                  description: 'Connect & Share',
                  isUnlocked: true,
                  onTap: () => context.go('/social'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _KingdomBuilding extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _KingdomBuilding({
    required this.icon,
    required this.label,
    required this.description,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DuoCard(
      type: DuoCardType.lesson,
      onTap: isUnlocked ? onTap : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LessonNode(
            icon: icon,
            isCompleted: false,
            isLocked: !isUnlocked,
            onTap: isUnlocked ? onTap : null,
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          Text(
            label,
            style: DuolingoTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isUnlocked ? DuolingoTheme.charcoal : DuolingoTheme.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DuolingoTheme.spacingXs),
          Text(
            description,
            style: DuolingoTheme.bodySmall.copyWith(
              color: isUnlocked ? DuolingoTheme.darkGray : DuolingoTheme.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}