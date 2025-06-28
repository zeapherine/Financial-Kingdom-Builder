import 'package:flutter/material.dart';
import '../models/lesson_content.dart';
import '../../../core/services/localization_service.dart';

// Import all existing module files
import '../data/financial_literacy_modules.dart';
import '../data/portfolio_concepts_modules.dart';
import '../data/risk_management_modules.dart';
import '../data/trading_terminology_modules.dart';
import '../data/cryptocurrency_modules.dart';
import '../data/building_permit_modules.dart';

class LocalizedLessonService {
  static final LocalizedLessonService _instance = LocalizedLessonService._internal();
  factory LocalizedLessonService() => _instance;
  LocalizedLessonService._internal();

  final LocalizationService _localizationService = LocalizationService();

  /// Get all modules with localized content
  List<LessonContent> getAllLocalizedModules({String? locale}) {
    final allModules = <LessonContent>[
      ...FinancialLiteracyModules.getFinancialLiteracyLessons(),
      ...PortfolioConceptsModules.getPortfolioConceptsLessons(),
      ...RiskManagementModules.modules,
      ...TradingTerminologyModules.modules,
      ...CryptocurrencyModules.modules,
      ...BuildingPermitModules.modules,
    ];

    return allModules.map((module) => _localizeModule(module, locale)).toList();
  }

  /// Get modules by category with localization
  List<LessonContent> getModulesByCategory(String category, {String? locale}) {
    List<LessonContent> modules;
    
    switch (category.toLowerCase()) {
      case 'financial_literacy':
        modules = FinancialLiteracyModules.getFinancialLiteracyLessons();
        break;
      case 'portfolio_concepts':
        modules = PortfolioConceptsModules.getPortfolioConceptsLessons();
        break;
      case 'risk_management':
        modules = RiskManagementModules.modules;
        break;
      case 'trading_terminology':
        modules = TradingTerminologyModules.modules;
        break;
      case 'cryptocurrency':
        modules = CryptocurrencyModules.modules;
        break;
      case 'building_permits':
        modules = BuildingPermitModules.modules;
        break;
      default:
        modules = [];
    }

    return modules.map((module) => _localizeModule(module, locale)).toList();
  }

  /// Get a specific module by ID with localization
  LessonContent? getLocalizedModuleById(String id, {String? locale}) {
    final allModules = getAllLocalizedModules(locale: locale);
    try {
      return allModules.firstWhere((module) => module.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get modules by type with localization
  List<LessonContent> getLocalizedModulesByType(LessonType type, {String? locale}) {
    final allModules = getAllLocalizedModules(locale: locale);
    return allModules.where((module) => module.type == type).toList();
  }

  /// Get localized category names
  Map<String, String> getLocalizedCategories({String? locale}) {
    return {
      'financial_literacy': _localizationService.getLocalizedContent('categories.financialLiteracy', locale: locale),
      'portfolio_concepts': _localizationService.getLocalizedContent('categories.portfolioConcepts', locale: locale),
      'risk_management': _localizationService.getLocalizedContent('categories.riskManagement', locale: locale),
      'trading_terminology': _localizationService.getLocalizedContent('categories.tradingTerminology', locale: locale),
      'cryptocurrency': _localizationService.getLocalizedContent('categories.cryptoBasics', locale: locale),
      'building_permits': _localizationService.getLocalizedContent('categories.buildingPermits', locale: locale),
    };
  }

  /// Get total duration for all modules
  Duration getTotalLocalizedDuration({String? locale}) {
    final allModules = getAllLocalizedModules(locale: locale);
    final totalMinutes = allModules.fold(0, (sum, module) => sum + module.estimatedMinutes);
    return Duration(minutes: totalMinutes);
  }

  /// Private method to localize a single module
  LessonContent _localizeModule(LessonContent originalModule, String? locale) {
    final localizedModuleData = _localizationService.getLocalizedModule(originalModule.id, locale: locale);
    
    if (localizedModuleData == null) {
      // Return original if no localization found
      return originalModule;
    }

    // Create localized module with updated content
    Map<String, dynamic> localizedData = Map.from(originalModule.data);
    
    // Update the main content
    if (localizedModuleData['content'] != null) {
      localizedData['content'] = localizedModuleData['content'];
    }

    // Localize quiz questions if they exist
    if (originalModule.type == LessonType.quiz && localizedData['questions'] != null) {
      localizedData['questions'] = _localizeQuizQuestions(
        localizedData['questions'] as List,
        originalModule.id,
        locale,
      );
    }

    // Localize interactive parameters if they exist
    if (localizedData['parameters'] != null) {
      localizedData['parameters'] = _localizeInteractiveParameters(
        localizedData['parameters'] as Map<String, dynamic>,
        originalModule.id,
        locale,
      );
    }

    return LessonContent(
      id: originalModule.id,
      title: localizedModuleData['title'] ?? originalModule.title,
      description: localizedModuleData['description'] ?? originalModule.description,
      type: originalModule.type,
      data: localizedData,
      estimatedMinutes: originalModule.estimatedMinutes,
    );
  }

  /// Localize quiz questions
  List<Map<String, dynamic>> _localizeQuizQuestions(
    List questions,
    String moduleId,
    String? locale,
  ) {
    // For now, return original questions
    // In a full implementation, you would have quiz translations
    return questions.cast<Map<String, dynamic>>();
  }

  /// Localize interactive parameters
  Map<String, dynamic> _localizeInteractiveParameters(
    Map<String, dynamic> parameters,
    String moduleId,
    String? locale,
  ) {
    // For now, return original parameters
    // In a full implementation, you would localize interactive content
    return parameters;
  }

  /// Get common localized terms
  Map<String, String> getCommonLocalizedTerms({String? locale}) {
    return {
      'kingdomWisdom': _localizationService.getLocalizedContent('common.kingdomWisdom', locale: locale),
      'example': _localizationService.getLocalizedContent('common.example', locale: locale),
      'important': _localizationService.getLocalizedContent('common.important', locale: locale),
      'note': _localizationService.getLocalizedContent('common.note', locale: locale),
      'tip': _localizationService.getLocalizedContent('common.tip', locale: locale),
      'warning': _localizationService.getLocalizedContent('common.warning', locale: locale),
      'learnMore': _localizationService.getLocalizedContent('common.learnMore', locale: locale),
      'getStarted': _localizationService.getLocalizedContent('common.getStarted', locale: locale),
      'practiceMode': _localizationService.getLocalizedContent('common.practiceMode', locale: locale),
      'testYourKnowledge': _localizationService.getLocalizedContent('common.testYourKnowledge', locale: locale),
    };
  }

  /// Check if localization is available for a specific locale
  bool isLocalizationAvailable(String locale) {
    return _localizationService.isLocaleSupported(locale);
  }

  /// Get list of supported locales
  List<String> getSupportedLocales() {
    return _localizationService.getSupportedLocales();
  }

  /// Initialize localization for a specific locale
  Future<void> initializeLocalization(String locale) async {
    await _localizationService.loadLocalization(locale);
  }

  /// Get current locale
  String getCurrentLocale() {
    return _localizationService.currentLocale;
  }
}

/// Extension to make it easier to use in widgets
extension LocalizedLessonExtension on BuildContext {
  LocalizedLessonService get localizedLessons => LocalizedLessonService();
}