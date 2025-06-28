import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/duolingo_theme.dart';
import '../../../core/services/localization_service.dart';
import '../../education/services/localized_lesson_service.dart';

// Provider for current locale
final currentLocaleProvider = StateProvider<String>((ref) => 'en');

class LanguageSelectorWidget extends ConsumerWidget {
  final Function(String)? onLanguageChanged;

  const LanguageSelectorWidget({
    super.key,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);
    final localizationService = LocalizationService();
    final supportedLocales = localizationService.getSupportedLocales();

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
          // Header
          Row(
            children: [
              Icon(
                Icons.language,
                color: DuolingoTheme.duoBlue,
                size: 28,
              ),
              const SizedBox(width: DuolingoTheme.spacingSm),
              Text(
                'Language / Idioma / Langue',
                style: DuolingoTheme.h3.copyWith(
                  color: DuolingoTheme.charcoal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          Text(
            'Choose your preferred language for the app interface and educational content.',
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Language options
          ...supportedLocales.map((locale) {
            final isSelected = currentLocale == locale;
            final languageInfo = _getLanguageInfo(locale);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
              child: GestureDetector(
                onTap: () => _selectLanguage(ref, locale),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DuolingoTheme.duoBlue.withValues(alpha: 0.1)
                        : DuolingoTheme.lightGray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                    border: Border.all(
                      color: isSelected ? DuolingoTheme.duoBlue : DuolingoTheme.mediumGray,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: DuolingoTheme.duoBlue.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Flag emoji
                      Text(
                        languageInfo['flag']!,
                        style: const TextStyle(fontSize: 32),
                      ),
                      
                      const SizedBox(width: DuolingoTheme.spacingMd),
                      
                      // Language info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languageInfo['name']!,
                              style: DuolingoTheme.h4.copyWith(
                                color: isSelected ? DuolingoTheme.duoBlue : DuolingoTheme.charcoal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              languageInfo['nativeName']!,
                              style: DuolingoTheme.bodyMedium.copyWith(
                                color: DuolingoTheme.darkGray,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: DuolingoTheme.spacingXs),
                            Text(
                              languageInfo['description']!,
                              style: DuolingoTheme.bodySmall.copyWith(
                                color: DuolingoTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Selection indicator
                      if (isSelected) ...[ 
                        const SizedBox(width: DuolingoTheme.spacingSm),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: DuolingoTheme.duoBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Additional info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: DuolingoTheme.duoYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              border: Border.all(
                color: DuolingoTheme.duoYellow.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: DuolingoTheme.duoYellow,
                      size: 16,
                    ),
                    const SizedBox(width: DuolingoTheme.spacingXs),
                    Text(
                      'Language Change Info',
                      style: DuolingoTheme.bodyMedium.copyWith(
                        color: DuolingoTheme.duoYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DuolingoTheme.spacingSm),
                Text(
                  'Changing the language will update both the app interface and educational content. The kingdom metaphors will be adapted for cultural relevance.',
                  style: DuolingoTheme.bodySmall.copyWith(
                    color: DuolingoTheme.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(WidgetRef ref, String locale) async {
    // Update the provider
    ref.read(currentLocaleProvider.notifier).state = locale;
    
    // Initialize localization services
    await LocalizationService().loadLocalization(locale);
    await LocalizedLessonService().initializeLocalization(locale);
    
    // Callback if provided
    if (onLanguageChanged != null) {
      onLanguageChanged!(locale);
    }
  }

  Map<String, String> _getLanguageInfo(String locale) {
    switch (locale) {
      case 'en':
        return {
          'flag': '🇺🇸',
          'name': 'English',
          'nativeName': 'English',
          'description': 'Original language with complete content',
        };
      case 'es':
        return {
          'flag': '🇪🇸',
          'name': 'Spanish',
          'nativeName': 'Español',
          'description': 'Contenido adaptado culturalmente',
        };
      case 'fr':
        return {
          'flag': '🇫🇷',
          'name': 'French',
          'nativeName': 'Français',
          'description': 'Contenu adapté culturellement',
        };
      default:
        return {
          'flag': '🏳️',
          'name': 'Unknown',
          'nativeName': 'Unknown',
          'description': 'Unknown language',
        };
    }
  }
}

// Simple language picker button
class LanguagePickerButton extends ConsumerWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);
    final languageInfo = _getLanguageInfo(currentLocale);

    return ElevatedButton.icon(
      onPressed: () => _showLanguagePicker(context),
      icon: Text(languageInfo['flag']!, style: const TextStyle(fontSize: 20)),
      label: Text(languageInfo['name']!),
      style: ElevatedButton.styleFrom(
        backgroundColor: DuolingoTheme.duoBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DuolingoTheme.radiusLarge),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(DuolingoTheme.spacingLg),
          child: LanguageSelectorWidget(),
        ),
      ),
    );
  }

  Map<String, String> _getLanguageInfo(String locale) {
    switch (locale) {
      case 'en':
        return {'flag': '🇺🇸', 'name': 'English'};
      case 'es':
        return {'flag': '🇪🇸', 'name': 'Español'};
      case 'fr':
        return {'flag': '🇫🇷', 'name': 'Français'};
      default:
        return {'flag': '🏳️', 'name': 'Unknown'};
    }
  }
}