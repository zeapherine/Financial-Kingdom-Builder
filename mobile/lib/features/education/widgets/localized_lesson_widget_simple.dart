import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/duolingo_theme.dart';
import '../models/lesson_content.dart';
import '../services/localized_lesson_service.dart';
import '../../settings/widgets/language_selector_widget.dart';

/// Simplified version of LocalizedLessonWidget that doesn't depend on AppLocalizations
/// This can be used until the localization files are generated
class LocalizedLessonWidgetSimple extends ConsumerWidget {
  final String lessonId;
  final Function(LessonContent)? onLessonSelected;

  const LocalizedLessonWidgetSimple({
    super.key,
    required this.lessonId,
    this.onLessonSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);
    final localizedLessonService = LocalizedLessonService();

    return FutureBuilder<LessonContent?>(
      future: _getLocalizedLesson(localizedLessonService, currentLocale),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorWidget();
        }

        final lesson = snapshot.data!;
        return _buildLessonCard(context, lesson);
      },
    );
  }

  Future<LessonContent?> _getLocalizedLesson(
    LocalizedLessonService service,
    String locale,
  ) async {
    await service.initializeLocalization(locale);
    return service.getLocalizedModuleById(lessonId, locale: locale);
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(DuolingoTheme.duoBlue),
            ),
            SizedBox(height: DuolingoTheme.spacingMd),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        border: Border.all(
          color: DuolingoTheme.duoRed.withValues(alpha: 0.3),
        ),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: DuolingoTheme.duoRed,
            size: 32,
          ),
          SizedBox(height: DuolingoTheme.spacingMd),
          Text(
            'Error',
            style: TextStyle(
              color: DuolingoTheme.duoRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: DuolingoTheme.spacingSm),
          Text(
            'Failed to load lesson content',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonContent lesson) {
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with language picker
          Row(
            children: [
              Expanded(
                child: Text(
                  lesson.title,
                  style: DuolingoTheme.h2.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const LanguagePickerButton(),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          // Description
          Text(
            lesson.description,
            style: DuolingoTheme.bodyLarge.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Lesson type and duration
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DuolingoTheme.spacingSm,
                  vertical: DuolingoTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: _getLessonTypeColor(lesson.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusSmall),
                  border: Border.all(
                    color: _getLessonTypeColor(lesson.type).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getLessonTypeLabel(lesson.type),
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: _getLessonTypeColor(lesson.type),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const Spacer(),
              
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: DuolingoTheme.mediumGray,
                    size: 16,
                  ),
                  const SizedBox(width: DuolingoTheme.spacingXs),
                  Text(
                    '${lesson.estimatedMinutes} minutes',
                    style: DuolingoTheme.bodySmall.copyWith(
                      color: DuolingoTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Content preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: DuolingoTheme.lightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Content Preview',
                  style: DuolingoTheme.bodyMedium.copyWith(
                    color: DuolingoTheme.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DuolingoTheme.spacingSm),
                Text(
                  _getContentPreview(lesson.data['content'] as String? ?? ''),
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: DuolingoTheme.darkGray,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (onLessonSelected != null) {
                  onLessonSelected!(lesson);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DuolingoTheme.duoGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: DuolingoTheme.spacingMd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                ),
              ),
              child: Text(
                'Continue',
                style: DuolingoTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.text:
        return DuolingoTheme.duoBlue;
      case LessonType.interactive:
        return DuolingoTheme.duoGreen;
      case LessonType.quiz:
        return DuolingoTheme.duoPurple;
      case LessonType.video:
        return DuolingoTheme.duoRed;
      case LessonType.chart:
        return DuolingoTheme.duoOrange;
    }
  }

  String _getLessonTypeLabel(LessonType type) {
    switch (type) {
      case LessonType.text:
        return 'Reading';
      case LessonType.interactive:
        return 'Interactive';
      case LessonType.quiz:
        return 'Quiz';
      case LessonType.video:
        return 'Video';
      case LessonType.chart:
        return 'Chart';
    }
  }

  String _getContentPreview(String content) {
    // Remove markdown formatting for preview
    String preview = content
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // Bold
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1') // Italic
        .replaceAll(RegExp(r'#{1,6}\s'), '') // Headers
        .replaceAll(RegExp(r'•\s'), '• ') // Bullet points
        .replaceAll(RegExp(r'\n\n+'), ' ') // Multiple newlines
        .replaceAll('\n', ' '); // Single newlines

    if (preview.length > 150) {
      preview = '${preview.substring(0, 150)}...';
    }

    return preview;
  }
}