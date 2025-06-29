import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_content.dart';
import '../data/financial_literacy_modules.dart';
import '../data/portfolio_concepts_modules.dart';
import '../data/cryptocurrency_modules.dart';
import '../data/risk_management_modules.dart';
import '../data/trading_terminology_modules.dart';
import '../data/building_permit_modules.dart';
import '../services/education_service.dart';

class EducationModule {
  final String id;
  final String title;
  final String description;
  final double progress;
  final bool isLocked;
  final int requiredXp;
  final String category;

  const EducationModule({
    required this.id,
    required this.title,
    required this.description,
    this.progress = 0.0,
    this.isLocked = false,
    this.requiredXp = 0,
    required this.category,
  });

  EducationModule copyWith({
    String? id,
    String? title,
    String? description,
    double? progress,
    bool? isLocked,
    int? requiredXp,
    String? category,
  }) {
    return EducationModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      isLocked: isLocked ?? this.isLocked,
      requiredXp: requiredXp ?? this.requiredXp,
      category: category ?? this.category,
    );
  }
}

class EducationState {
  final List<EducationModule> modules;
  final Map<String, double> moduleProgress;
  final int totalXpEarned;
  final String currentTier;
  final Map<String, List<LessonContent>> moduleContent;
  final bool isLoading;
  final String? error;

  const EducationState({
    this.modules = const [],
    this.moduleProgress = const {},
    this.totalXpEarned = 0,
    this.currentTier = 'Village',
    this.moduleContent = const {},
    this.isLoading = false,
    this.error,
  });

  EducationState copyWith({
    List<EducationModule>? modules,
    Map<String, double>? moduleProgress,
    int? totalXpEarned,
    String? currentTier,
    Map<String, List<LessonContent>>? moduleContent,
    bool? isLoading,
    String? error,
  }) {
    return EducationState(
      modules: modules ?? this.modules,
      moduleProgress: moduleProgress ?? this.moduleProgress,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      currentTier: currentTier ?? this.currentTier,
      moduleContent: moduleContent ?? this.moduleContent,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EducationNotifier extends StateNotifier<EducationState> {
  final EducationService _educationService = EducationService();
  
  EducationNotifier() : super(EducationState(
    modules: _getInitialModules(),
    moduleContent: _getInitialModuleContent(),
  ));

  static List<EducationModule> _getInitialModules() {
    return [
      const EducationModule(
        id: 'financial-literacy',
        title: 'Financial Literacy Basics',
        description: 'Master the fundamentals of personal finance and money management',
        category: 'Financial Literacy',
        isLocked: false,
      ),
      const EducationModule(
        id: 'cryptocurrency-basics',
        title: 'Cryptocurrency Basics',
        description: 'Understand digital currencies and blockchain technology',
        category: 'Cryptocurrency',
        isLocked: false,
      ),
      const EducationModule(
        id: 'risk-management',
        title: 'Risk Management',
        description: 'Learn to identify, assess, and manage investment risks',
        category: 'Risk Management',
        isLocked: false,
      ),
      const EducationModule(
        id: 'trading-terminology',
        title: 'Trading Terminology',
        description: 'Master essential trading vocabulary and concepts',
        category: 'Trading',
        isLocked: false,
      ),
      const EducationModule(
        id: 'building-permits',
        title: 'Building Permits & Regulations',
        description: 'Understand financial regulations and compliance',
        category: 'Compliance',
        isLocked: true,
        requiredXp: 200,
      ),
      const EducationModule(
        id: 'portfolio-management',
        title: 'Portfolio Management',
        description: 'Learn to build and manage investment portfolios',
        category: 'Portfolio Management',
        isLocked: true,
        requiredXp: 300,
      ),
    ];
  }

  static Map<String, List<LessonContent>> _getInitialModuleContent() {
    return {
      'financial-literacy': FinancialLiteracyModules.getFinancialLiteracyLessons(),
      'cryptocurrency-basics': CryptocurrencyModules.modules,
      'risk-management': RiskManagementModules.modules,
      'trading-terminology': TradingTerminologyModules.modules,
      'building-permits': BuildingPermitModules.modules,
      'portfolio-management': PortfolioConceptsModules.getPortfolioConceptsLessons(),
    };
  }

  void completeLesson(String moduleId, String lessonId) {
    final currentState = state;
    final moduleIndex = currentState.modules.indexWhere((m) => m.id == moduleId);
    
    if (moduleIndex == -1) return;

    final module = currentState.modules[moduleIndex];
    final newProgress = (module.progress + 0.1).clamp(0.0, 1.0);
    
    final updatedModules = [...currentState.modules];
    updatedModules[moduleIndex] = module.copyWith(progress: newProgress);
    
    // Award XP for lesson completion
    final xpGained = 50;
    final newTotalXp = currentState.totalXpEarned + xpGained;
    
    state = currentState.copyWith(
      modules: updatedModules,
      totalXpEarned: newTotalXp,
      moduleProgress: {
        ...currentState.moduleProgress,
        moduleId: newProgress,
      },
    );
    
    // Check if we should unlock new modules
    _checkUnlockModules();
  }

  void _checkUnlockModules() {
    final currentState = state;
    final updatedModules = currentState.modules.map((module) {
      if (module.isLocked && currentState.totalXpEarned >= module.requiredXp) {
        return module.copyWith(isLocked: false);
      }
      return module;
    }).toList();
    
    state = currentState.copyWith(modules: updatedModules);
  }

  void updateProgress(String moduleId, double progress) {
    final currentState = state;
    final moduleIndex = currentState.modules.indexWhere((m) => m.id == moduleId);
    
    if (moduleIndex == -1) return;

    final updatedModules = [...currentState.modules];
    updatedModules[moduleIndex] = updatedModules[moduleIndex].copyWith(progress: progress);
    
    state = currentState.copyWith(
      modules: updatedModules,
      moduleProgress: {
        ...currentState.moduleProgress,
        moduleId: progress,
      },
    );
  }

  Future<void> loadUserProgress(String userId) async {
    // Set loading state
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Use education service to fetch user progress
      final progress = await _educationService.fetchUserProgress(userId);
      
      final currentState = state;
      final updatedModules = currentState.modules.map((module) {
        final moduleProgress = progress[module.id] ?? 0.0;
        return module.copyWith(progress: moduleProgress);
      }).toList();
      
      // Calculate total XP from progress
      final totalXp = _calculateTotalXpFromProgress(progress);
      
      state = currentState.copyWith(
        modules: updatedModules,
        moduleProgress: progress,
        totalXpEarned: totalXp,
        isLoading: false,
        error: null,
      );
      
      _checkUnlockModules();
    } catch (e) {
      // Handle error with user-friendly message
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load progress. Using offline data.',
      );
      // TODO: Replace with proper logging framework in production
      // Log error details for debugging
    }
  }

  void resetProgress() {
    state = EducationState(
      modules: _getInitialModules(),
      moduleContent: _getInitialModuleContent(),
    );
  }

  List<LessonContent> getLessonsForModule(String moduleId) {
    return state.moduleContent[moduleId] ?? [];
  }

  /// Calculate total XP earned from module progress
  int _calculateTotalXpFromProgress(Map<String, double> progress) {
    int totalXp = 0;
    for (final entry in progress.entries) {
      final moduleId = entry.key;
      final moduleProgress = entry.value;
      
      // Each module gives different XP amounts
      final xpPerModule = _getXpRewardForModule(moduleId);
      totalXp += (moduleProgress * xpPerModule).round();
    }
    return totalXp;
  }

  /// Get XP reward amount for a specific module
  int _getXpRewardForModule(String moduleId) {
    switch (moduleId) {
      case 'financial-literacy':
        return 100;
      case 'cryptocurrency-basics':
        return 120;
      case 'risk-management':
        return 150;
      case 'trading-terminology':
        return 180;
      case 'building-permits':
        return 200;
      case 'portfolio-management':
        return 250;
      default:
        return 50;
    }
  }

  /// Complete lesson using education service
  Future<void> completeLessonWithService({
    required String userId,
    required String moduleId,
    required String lessonId,
  }) async {
    try {
      // Call education service to complete lesson
      final result = await _educationService.completeLesson(
        userId: userId,
        moduleId: moduleId,
        lessonId: lessonId,
      );

      if (result['success'] == true) {
        // Update local state with new progress
        final currentState = state;
        final moduleIndex = currentState.modules.indexWhere((m) => m.id == moduleId);
        
        if (moduleIndex != -1) {
          final module = currentState.modules[moduleIndex];
          final newProgress = (module.progress + 0.1).clamp(0.0, 1.0);
          
          final updatedModules = [...currentState.modules];
          updatedModules[moduleIndex] = module.copyWith(progress: newProgress);
          
          // Update total XP from service response
          final newTotalXp = result['newTotalXp'] ?? currentState.totalXpEarned + 50;
          
          state = currentState.copyWith(
            modules: updatedModules,
            totalXpEarned: newTotalXp,
            moduleProgress: {
              ...currentState.moduleProgress,
              moduleId: newProgress,
            },
          );
          
          _checkUnlockModules();
        }
      }
    } catch (e) {
      // Fallback to local completion if service fails
      completeLesson(moduleId, lessonId);
      // In production, you might want to log this error or show a message
    }
  }

  /// Load modules from service
  Future<void> loadModulesFromService({String? userId}) async {
    try {
      final modules = await _educationService.fetchModules(userId: userId);
      
      state = state.copyWith(
        modules: modules,
      );
      
      // Also load module content
      final moduleContent = <String, List<LessonContent>>{};
      for (final module in modules) {
        try {
          final lessons = await _educationService.fetchModuleLessons(module.id);
          moduleContent[module.id] = lessons;
        } catch (e) {
          // If fetching specific module content fails, use fallback
          moduleContent[module.id] = state.moduleContent[module.id] ?? [];
        }
      }
      
      state = state.copyWith(
        moduleContent: moduleContent,
      );
    } catch (e) {
      // If service fails, keep using local data
      // In production, you might want to show an error message
    }
  }

  /// Initialize education system for a user
  Future<void> initializeForUser(String userId) async {
    // Set loading state
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Load modules from service
      await loadModulesFromService(userId: userId);
      
      // Load user progress
      await loadUserProgress(userId);
      
      // Success - loading state will be cleared by loadUserProgress
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize education system. Please check your connection.',
      );
    }
  }
}

// Providers
final educationProvider = StateNotifierProvider<EducationNotifier, EducationState>((ref) {
  return EducationNotifier();
});

// Computed providers
final availableModulesProvider = Provider<List<EducationModule>>((ref) {
  final educationState = ref.watch(educationProvider);
  return educationState.modules.where((module) => !module.isLocked).toList();
});

final completedModulesProvider = Provider<List<EducationModule>>((ref) {
  final educationState = ref.watch(educationProvider);
  return educationState.modules.where((module) => module.progress >= 1.0).toList();
});

final overallProgressProvider = Provider<double>((ref) {
  final educationState = ref.watch(educationProvider);
  if (educationState.modules.isEmpty) return 0.0;
  
  final totalProgress = educationState.modules.fold<double>(
    0.0,
    (sum, module) => sum + module.progress,
  );
  
  return totalProgress / educationState.modules.length;
});