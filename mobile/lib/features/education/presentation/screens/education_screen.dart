import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';
import '../../../../shared/widgets/duo_progress_bar.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../providers/education_provider.dart';
import 'module_lessons_screen.dart';

class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final educationState = ref.watch(educationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Education'),
      ),
      drawer: const AppDrawer(),
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
            ...educationState.modules.map((module) => _EducationModule(
              module: module,
              progress: educationState.moduleProgress[module.id] ?? 0.0,
              onTap: () {
                if (!module.isLocked) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ModuleLessonsScreen(module: module),
                    ),
                  );
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _EducationModule extends StatelessWidget {
  final EducationModule module;
  final double progress;
  final VoidCallback? onTap;

  const _EducationModule({
    required this.module,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
      child: DuoCard(
        type: DuoCardType.lesson,
        onTap: module.isLocked ? null : onTap,
        child: Row(
          children: [
            // Module Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: module.isLocked 
                    ? DuolingoTheme.mediumGray 
                    : (progress > 0 ? DuolingoTheme.duoGreen : DuolingoTheme.duoBlue),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                boxShadow: module.isLocked ? null : DuolingoTheme.cardShadow,
              ),
              child: Icon(
                module.isLocked ? Icons.lock : _getModuleIcon(module.category),
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
                          module.title,
                          style: DuolingoTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: module.isLocked 
                                ? DuolingoTheme.mediumGray 
                                : DuolingoTheme.charcoal,
                          ),
                        ),
                      ),
                      if (!module.isLocked) ...[
                        Icon(
                          Icons.star,
                          color: DuolingoTheme.duoYellow,
                          size: DuolingoTheme.iconSmall,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+${_getXpReward(module.category)} XP',
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
                    module.description,
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: module.isLocked 
                          ? DuolingoTheme.mediumGray 
                          : DuolingoTheme.darkGray,
                    ),
                  ),
                  if (!module.isLocked) ...[
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
              color: module.isLocked 
                  ? DuolingoTheme.mediumGray 
                  : DuolingoTheme.duoGreen,
              size: DuolingoTheme.iconSmall,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModuleIcon(String category) {
    switch (category) {
      case 'Financial Literacy':
        return Icons.account_balance_wallet;
      case 'Risk Management':
        return Icons.trending_up;
      case 'Trading':
        return Icons.candlestick_chart;
      case 'Portfolio Management':
        return Icons.pie_chart;
      default:
        return Icons.school;
    }
  }

  int _getXpReward(String category) {
    switch (category) {
      case 'Financial Literacy':
        return 50;
      case 'Risk Management':
        return 75;
      case 'Trading':
        return 100;
      case 'Portfolio Management':
        return 125;
      default:
        return 25;
    }
  }
}