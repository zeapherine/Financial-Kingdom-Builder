import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';
import '../../../../shared/widgets/gamification_widgets.dart';

class KingdomScreen extends ConsumerWidget {
  const KingdomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Kingdom'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DuolingoTheme.spacingMd),
            child: Row(
              children: [
                const XPBadge(xp: 150),
                const SizedBox(width: DuolingoTheme.spacingSm),
                const StreakCounter(streakCount: 7),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Level Badge
            const LevelBadge(
              level: 'Village Citizen',
              subtitle: 'Level 1',
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
                _KingdomBuilding(
                  icon: Icons.library_books,
                  label: 'Library',
                  description: 'Learn & Study',
                  isUnlocked: true,
                  onTap: () => context.go('/education'),
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