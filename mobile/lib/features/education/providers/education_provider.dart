import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_content.dart';
import '../data/financial_literacy_modules.dart';
import '../data/portfolio_concepts_modules.dart';

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

  const EducationState({
    this.modules = const [],
    this.moduleProgress = const {},
    this.totalXpEarned = 0,
    this.currentTier = 'Village',
    this.moduleContent = const {},
  });

  EducationState copyWith({
    List<EducationModule>? modules,
    Map<String, double>? moduleProgress,
    int? totalXpEarned,
    String? currentTier,
    Map<String, List<LessonContent>>? moduleContent,
  }) {
    return EducationState(
      modules: modules ?? this.modules,
      moduleProgress: moduleProgress ?? this.moduleProgress,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      currentTier: currentTier ?? this.currentTier,
      moduleContent: moduleContent ?? this.moduleContent,
    );
  }
}

class EducationNotifier extends StateNotifier<EducationState> {
  EducationNotifier() : super(EducationState(
    modules: _getInitialModules(),
    moduleContent: _getInitialModuleContent(),
  ));

  static List<EducationModule> _getInitialModules() {
    return [
      const EducationModule(
        id: 'financial-basics',
        title: 'Financial Literacy Basics',
        description: 'Learn the fundamentals of personal finance',
        category: 'Financial Literacy',
        isLocked: false,
      ),
      const EducationModule(
        id: 'risk-basics',
        title: 'Understanding Risk',
        description: 'Learn about investment risk and reward',
        category: 'Risk Management',
        isLocked: true,
        requiredXp: 100,
      ),
      const EducationModule(
        id: 'trading-basics',
        title: 'Trading Fundamentals',
        description: 'Basic trading concepts and strategies',
        category: 'Trading',
        isLocked: true,
        requiredXp: 200,
      ),
      const EducationModule(
        id: 'portfolio-management',
        title: 'Portfolio Management',
        description: 'Learn to build and manage investment portfolios',
        category: 'Portfolio Management',
        isLocked: true,
        requiredXp: 500,
      ),
    ];
  }

  static Map<String, List<LessonContent>> _getInitialModuleContent() {
    return {
      'financial-basics': FinancialLiteracyModules.getFinancialLiteracyLessons(),
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
    // Simulate loading user progress from API
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data for demonstration
    final mockProgress = {
      'financial-basics': 0.6,
      'risk-basics': 0.3,
    };
    
    final currentState = state;
    final updatedModules = currentState.modules.map((module) {
      final progress = mockProgress[module.id] ?? 0.0;
      return module.copyWith(progress: progress);
    }).toList();
    
    state = currentState.copyWith(
      modules: updatedModules,
      moduleProgress: mockProgress,
      totalXpEarned: 250, // Mock total XP
    );
    
    _checkUnlockModules();
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