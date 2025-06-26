import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';
import '../../../../shared/widgets/duo_progress_bar.dart';

class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Education'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            DuoCard(
              type: DuoCardType.streak,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        color: DuolingoTheme.white,
                        size: DuolingoTheme.iconLarge,
                      ),
                      const SizedBox(width: DuolingoTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Village Foundations',
                              style: DuolingoTheme.h3.copyWith(
                                color: DuolingoTheme.white,
                              ),
                            ),
                            const SizedBox(height: DuolingoTheme.spacingXs),
                            Text(
                              'Complete these modules to unlock trading features',
                              style: DuolingoTheme.bodySmall.copyWith(
                                color: DuolingoTheme.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  const DuoProgressBar(
                    progress: 0.25,
                    type: DuoProgressType.lesson,
                    height: 10,
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  Text(
                    '1 of 4 modules completed',
                    style: DuolingoTheme.caption.copyWith(
                      color: DuolingoTheme.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Modules List
            ...[
              _EducationModule(
                title: 'Financial Literacy Basics',
                description: 'Learn the fundamentals of personal finance',
                icon: Icons.account_balance_wallet,
                progress: 0.8,
                isLocked: false,
                xpReward: 50,
              ),
              _EducationModule(
                title: 'Understanding Risk',
                description: 'Learn about investment risk and reward',
                icon: Icons.trending_up,
                progress: 0.0,
                isLocked: true,
                xpReward: 75,
              ),
              _EducationModule(
                title: 'Portfolio Basics',
                description: 'Introduction to diversification',
                icon: Icons.pie_chart,
                progress: 0.0,
                isLocked: true,
                xpReward: 100,
              ),
              _EducationModule(
                title: 'Cryptocurrency 101',
                description: 'Understanding digital assets',
                icon: Icons.currency_bitcoin,
                progress: 0.0,
                isLocked: true,
                xpReward: 125,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EducationModule extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double progress;
  final bool isLocked;
  final int xpReward;

  const _EducationModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    required this.isLocked,
    required this.xpReward,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
      child: DuoCard(
        type: DuoCardType.lesson,
        onTap: isLocked ? null : () {
          // TODO: Navigate to module content
        },
        child: Row(
          children: [
            // Module Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isLocked 
                    ? DuolingoTheme.mediumGray 
                    : (progress > 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoBlue),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                boxShadow: isLocked ? null : DuolingoTheme.cardShadow,
              ),
              child: Icon(
                isLocked ? Icons.lock : icon,
                color: DuolingoTheme.white,
                size: DuolingoTheme.iconLarge,
              ),
            ),
            const SizedBox(width: DuolingoTheme.spacingMd),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: DuolingoTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isLocked 
                                ? DuolingoTheme.mediumGray 
                                : DuolingoTheme.charcoal,
                          ),
                        ),
                      ),
                      if (!isLocked) ...[
                        Icon(
                          Icons.star,
                          color: DuolingoTheme.duoYellow,
                          size: DuolingoTheme.iconSmall,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+$xpReward XP',
                          style: DuolingoTheme.caption.copyWith(
                            color: DuolingoTheme.duoYellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  Text(
                    description,
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: isLocked 
                          ? DuolingoTheme.mediumGray 
                          : DuolingoTheme.darkGray,
                    ),
                  ),
                  if (!isLocked) ...[
                    const SizedBox(height: DuolingoTheme.spacingMd),
                    DuoProgressBar(
                      progress: progress,
                      type: DuoProgressType.lesson,
                    ),
                    const SizedBox(height: DuolingoTheme.spacingXs),
                    Text(
                      '${(progress * 100).toInt()}% complete',
                      style: DuolingoTheme.caption.copyWith(
                        color: DuolingoTheme.darkGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: isLocked 
                  ? DuolingoTheme.mediumGray 
                  : DuolingoTheme.duoGreen,
              size: DuolingoTheme.iconSmall,
            ),
          ],
        ),
      ),
    );
  }
}