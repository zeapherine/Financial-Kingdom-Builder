# Localization Guide for Financial Kingdom Builder

## Overview

The Financial Kingdom Builder app now supports multi-language content with cultural adaptations. This guide explains how the localization system works and how to use it.

## Supported Languages

- **English (en)** - Original language with complete content
- **Spanish (es)** - Culturally adapted content with kingdom metaphors
- **French (fr)** - Culturally adapted content with kingdom metaphors

## Architecture

### 1. Flutter Localization (UI Text)
- **Files**: `lib/l10n/app_*.arb`
- **Purpose**: Localizes UI text, buttons, labels, and common messages
- **Generated Code**: `lib/l10n/app_localizations.dart` (auto-generated)

### 2. Educational Content Localization
- **Files**: `assets/l10n/education_content_*.json`
- **Purpose**: Localizes educational module content, lessons, and explanations
- **Service**: `LocalizationService` and `LocalizedLessonService`

## Usage Examples

### 1. Using UI Localization in Widgets

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return ElevatedButton(
      onPressed: () {},
      child: Text(localizations.continueButton),
    );
  }
}
```

### 2. Using Educational Content Localization

```dart
import '../services/localized_lesson_service.dart';

class LessonWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);
    final lessonService = LocalizedLessonService();
    
    return FutureBuilder<LessonContent?>(
      future: lessonService.getLocalizedModuleById('risk-001', locale: currentLocale),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final lesson = snapshot.data!;
          return Column(
            children: [
              Text(lesson.title), // Automatically localized
              Text(lesson.description), // Automatically localized
              Text(lesson.data['content']), // Localized content
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### 3. Language Selection

```dart
import '../../settings/widgets/language_selector_widget.dart';

// Simple language picker button
LanguagePickerButton()

// Full language selector widget
LanguageSelectorWidget(
  onLanguageChanged: (locale) {
    print('Language changed to: $locale');
  },
)
```

## Key Services

### LocalizationService
- Loads and manages educational content translations
- Provides fallback to English if translation missing
- Handles cultural adaptations (kingdom metaphors)

### LocalizedLessonService
- Integrates with existing lesson system
- Provides localized versions of all educational modules
- Maintains compatibility with existing code

## File Structure

```
mobile/
├── lib/
│   ├── l10n/                          # UI localizations
│   │   ├── app_en.arb                 # English UI text
│   │   ├── app_es.arb                 # Spanish UI text
│   │   └── app_fr.arb                 # French UI text
│   ├── core/
│   │   └── services/
│   │       └── localization_service.dart
│   └── features/
│       ├── education/
│       │   └── services/
│       │       └── localized_lesson_service.dart
│       └── settings/
│           └── widgets/
│               └── language_selector_widget.dart
├── assets/
│   └── l10n/                          # Educational content
│       ├── education_content_en.json  # English content
│       ├── education_content_es.json  # Spanish content
│       └── education_content_fr.json  # French content
└── l10n.yaml                          # Localization config
```

## Adding New Translations

### 1. UI Text
1. Add new entries to all `.arb` files in `lib/l10n/`
2. Run `flutter pub get` to regenerate localization code
3. Use `AppLocalizations.of(context)!.yourNewKey` in widgets

### 2. Educational Content
1. Add new modules to `assets/l10n/education_content_*.json`
2. Follow the existing JSON structure
3. Include cultural adaptations where appropriate
4. Content will be automatically available through `LocalizedLessonService`

## Cultural Adaptations

The system includes cultural adaptations for kingdom metaphors:

- **English**: Castle, kingdom, treasury
- **Spanish**: Castillo, reino, tesoro  
- **French**: Château, royaume, trésor

These are automatically applied when content is loaded.

## Integration with Existing Code

The localization system is designed to work seamlessly with existing code:

1. **Backward Compatibility**: All existing lesson modules work without changes
2. **Progressive Enhancement**: Add localization where needed without breaking existing functionality
3. **Fallback System**: Missing translations automatically fall back to English

## Performance Considerations

- Educational content is loaded on-demand per locale
- UI localizations are generated at compile time
- Localization service uses singleton pattern for efficiency
- Cultural adaptations are applied during content loading

## Testing Localization

1. Use the `LanguagePickerButton` or `LanguageSelectorWidget` to switch languages
2. Verify that both UI text and educational content update
3. Test fallback behavior with incomplete translations
4. Ensure cultural adaptations are applied correctly

## Future Enhancements

- Add more languages (German, Italian, Portuguese, etc.)
- Implement region-specific variations (en-US vs en-GB)
- Add right-to-left language support (Arabic, Hebrew)
- Include locale-specific number and date formatting
- Add voice narration in multiple languages

## Troubleshooting

### Common Issues

1. **"continue" keyword error**: Use `continueButton` instead of `continue` in .arb files
2. **Missing translations**: Check that all .arb files have the same keys
3. **Content not updating**: Ensure `LocalizationService.loadLocalization()` is called
4. **Generated files not found**: Run `flutter pub get` to regenerate localizations

### Debug Tips

```dart
// Check current locale
print(LocalizationService().currentLocale);

// Check if locale is supported
print(LocalizationService().isLocaleSupported('es'));

// Get localized content directly
print(LocalizationService().getLocalizedContent('modules.risk-001.title'));
```

This localization system provides a solid foundation for multi-language support while maintaining the engaging kingdom metaphor across all supported languages.