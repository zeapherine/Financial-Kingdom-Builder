import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/duolingo_theme.dart';
import '../../../../shared/widgets/duo_card.dart';
import '../../providers/education_provider.dart';
import '../../models/lesson_content.dart';
import 'lesson_content_screen.dart';

class ModuleLessonsScreen extends ConsumerWidget {
  final EducationModule module;

  const ModuleLessonsScreen({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final educationNotifier = ref.read(educationProvider.notifier);
    final lessons = educationNotifier.getLessonsForModule(module.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          module.title,
          style: DuolingoTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: DuolingoTheme.white,
          ),
        ),
        backgroundColor: DuolingoTheme.duoGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: DuolingoTheme.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Module header
            _buildModuleHeader(),
            
            const SizedBox(height: DuolingoTheme.spacingLg),
            
            // Lessons list
            if (lessons.isEmpty)
              _buildEmptyState()
            else
              ...lessons.asMap().entries.map((entry) {
                final index = entry.key;
                final lesson = entry.value;
                return _buildLessonCard(context, lesson, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DuolingoTheme.duoBlue, DuolingoTheme.duoBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DuolingoTheme.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getModuleIcon(module.category),
                  color: DuolingoTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: DuolingoTheme.h4.copyWith(
                        color: DuolingoTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.description,
                      style: DuolingoTheme.bodySmall.copyWith(
                        color: DuolingoTheme.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DuolingoTheme.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  module.category,
                  style: DuolingoTheme.caption.copyWith(
                    color: DuolingoTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        boxShadow: DuolingoTheme.cardShadow,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.construction,
            size: 64,
            color: DuolingoTheme.duoYellow,
          ),
          const SizedBox(height: DuolingoTheme.spacingMd),
          Text(
            'Coming Soon!',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            'Lessons for this module are being prepared by our royal scholars.',
            textAlign: TextAlign.center,
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonContent lesson, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
      child: DuoCard(
        type: DuoCardType.lesson,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LessonContentScreen(lesson: lesson),
            ),
          );
        },
        child: Row(
          children: [
            // Lesson number
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getLessonColor(lesson.type),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                boxShadow: DuolingoTheme.cardShadow,
              ),
              child: Center(
                child: lesson.type == LessonType.quiz
                    ? const Icon(
                        Icons.quiz,
                        color: DuolingoTheme.white,
                        size: 24,
                      )
                    : Text(
                        '${index + 1}',
                        style: DuolingoTheme.bodyLarge.copyWith(
                          color: DuolingoTheme.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: DuolingoTheme.spacingMd),
            
            // Lesson content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: DuolingoTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: DuolingoTheme.charcoal,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getLessonColor(lesson.type).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getLessonTypeLabel(lesson.type),
                          style: DuolingoTheme.caption.copyWith(
                            color: _getLessonColor(lesson.type),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DuolingoTheme.spacingXs),
                  Text(
                    lesson.description,
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: DuolingoTheme.spacingSm),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: DuolingoTheme.mediumGray,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.estimatedMinutes} min',
                        style: DuolingoTheme.caption.copyWith(
                          color: DuolingoTheme.mediumGray,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: DuolingoTheme.duoGreen,
                        size: DuolingoTheme.iconSmall,
                      ),
                    ],
                  ),
                ],
              ),
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

  Color _getLessonColor(LessonType type) {
    switch (type) {
      case LessonType.text:
        return DuolingoTheme.duoBlue;
      case LessonType.chart:
        return DuolingoTheme.duoGreen;
      case LessonType.interactive:
        return DuolingoTheme.duoPurple;
      case LessonType.quiz:
        return DuolingoTheme.duoYellow;
      case LessonType.video:
        return DuolingoTheme.duoRed;
    }
  }

  String _getLessonTypeLabel(LessonType type) {
    switch (type) {
      case LessonType.text:
        return 'Reading';
      case LessonType.chart:
        return 'Chart';
      case LessonType.interactive:
        return 'Interactive';
      case LessonType.quiz:
        return 'Quiz';
      case LessonType.video:
        return 'Video';
    }
  }
}