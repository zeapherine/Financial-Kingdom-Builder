import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, Map<String, dynamic>> _localizedContent = {};
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;

  Future<void> loadLocalization(String locale) async {
    _currentLocale = locale;
    
    try {
      // Load educational content translations
      final String contentPath = 'assets/l10n/education_content_$locale.json';
      final String content = await rootBundle.loadString(contentPath);
      _localizedContent[locale] = json.decode(content);
    } catch (e) {
      // Fallback to English if translation doesn't exist
      if (locale != 'en') {
        final String contentPath = 'assets/l10n/education_content_en.json';
        final String content = await rootBundle.loadString(contentPath);
        _localizedContent['en'] = json.decode(content);
      }
    }
  }

  String getLocalizedContent(String key, {String? locale}) {
    final targetLocale = locale ?? _currentLocale;
    final content = _localizedContent[targetLocale] ?? _localizedContent['en'];
    
    if (content == null) {
      return key; // Return key if no content found
    }

    return _getNestedValue(content, key) ?? key;
  }

  Map<String, dynamic>? getLocalizedModule(String moduleId, {String? locale}) {
    final targetLocale = locale ?? _currentLocale;
    final content = _localizedContent[targetLocale] ?? _localizedContent['en'];
    
    if (content == null) {
      return null;
    }

    return content['modules']?[moduleId];
  }

  List<String> getSupportedLocales() {
    return ['en', 'es', 'fr'];
  }

  bool isLocaleSupported(String locale) {
    return getSupportedLocales().contains(locale);
  }

  String? _getNestedValue(Map<String, dynamic> map, String key) {
    final keys = key.split('.');
    dynamic current = map;
    
    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return null;
      }
    }
    
    return current is String ? current : null;
  }

  // Helper method to get localized lesson content with fallback
  Map<String, dynamic> getLocalizedLessonContent(String lessonId, Map<String, dynamic> defaultContent) {
    final localizedModule = getLocalizedModule(lessonId);
    
    if (localizedModule != null) {
      // Merge localized content with default structure
      return {
        'id': defaultContent['id'],
        'title': localizedModule['title'] ?? defaultContent['title'],
        'description': localizedModule['description'] ?? defaultContent['description'],
        'type': defaultContent['type'],
        'data': {
          ...defaultContent['data'],
          'content': localizedModule['content'] ?? defaultContent['data']['content'],
          // Preserve other data fields that shouldn't be translated
        },
        'estimatedMinutes': defaultContent['estimatedMinutes'],
      };
    }
    
    return defaultContent;
  }

  // Method to format text with kingdom metaphors based on locale
  String formatKingdomMetaphor(String text, {String? locale}) {
    final targetLocale = locale ?? _currentLocale;
    
    // Add locale-specific formatting or cultural adaptations
    switch (targetLocale) {
      case 'es':
        // Spanish cultural adaptations
        return text.replaceAll('kingdom', 'reino')
                  .replaceAll('castle', 'castillo')
                  .replaceAll('treasury', 'tesoro');
      case 'fr':
        // French cultural adaptations
        return text.replaceAll('kingdom', 'royaume')
                  .replaceAll('castle', 'château')
                  .replaceAll('treasury', 'trésor');
      default:
        return text;
    }
  }
}

// Extension to make localization easier to use in widgets
extension LocalizationExtension on BuildContext {
  LocalizationService get localization => LocalizationService();
  
  String localizeContent(String key) {
    return LocalizationService().getLocalizedContent(key);
  }
}