import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/error_handler_service.dart';

part 'education_provider.g.dart';

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

  const EducationState({
    this.modules = const [],
    this.moduleProgress = const {},
    this.totalXpEarned = 0,
    this.currentTier = 'Village',
  });

  EducationState copyWith({
    List<EducationModule>? modules,
    Map<String, double>? moduleProgress,
    int? totalXpEarned,
    String? currentTier,
  }) {
    return EducationState(
      modules: modules ?? this.modules,
      moduleProgress: moduleProgress ?? this.moduleProgress,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      currentTier: currentTier ?? this.currentTier,
    );
  }
}

@Riverpod(keepAlive: true)
class EducationNotifier extends _$EducationNotifier {
  @override
  EducationState build() {
    return EducationState(
      modules: _getInitialModules(),
    );
  }

  List<EducationModule> _getInitialModules() {
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
        id: 'portfolio-basics',
        title: 'Portfolio Basics',
        description: 'Introduction to diversification',
        category: 'Portfolio Management',
        isLocked: true,
        requiredXp: 250,
      ),
      const EducationModule(
        id: 'crypto-101',
        title: 'Cryptocurrency 101',
        description: 'Understanding digital assets',
        category: 'Cryptocurrency',
        isLocked: true,
        requiredXp: 400,
      ),
    ];
  }

  void updateModuleProgress(String moduleId, double progress) {
    ErrorHandlerService.safeExecute(
      () {
        // Validate inputs
        if (progress < 0.0 || progress > 1.0) {
          throw EducationException(
            'Invalid progress value: $progress. Progress must be between 0.0 and 1.0',
            code: 'INVALID_PROGRESS_VALUE',
          );
        }
        
        // Check if module exists
        final moduleExists = state.modules.any((module) => module.id == moduleId);
        if (!moduleExists) {
          throw AppExceptions.moduleNotFound(moduleId);
        }
        
        // Check if module is locked
        final module = state.modules.firstWhere((m) => m.id == moduleId);
        if (module.isLocked) {
          throw EducationException(
            'Cannot update progress for locked module: $moduleId',
            code: 'MODULE_LOCKED',
          );
        }
        
        // Check if module is already completed
        final currentProgress = state.moduleProgress[moduleId] ?? 0.0;
        if (currentProgress >= 1.0 && progress >= 1.0) {
          throw AppExceptions.moduleAlreadyCompleted(moduleId);
        }
        
        final updatedProgress = Map<String, double>.from(state.moduleProgress);
        updatedProgress[moduleId] = progress;
        
        state = state.copyWith(moduleProgress: updatedProgress);
        
        // Award XP for progress
        if (progress >= 1.0 && currentProgress < 1.0) {
          _awardXpForCompletion(moduleId);
        }
      },
      fallbackValue: null,
      context: 'EducationProvider.updateModuleProgress',
    );
  }

  void _awardXpForCompletion(String moduleId) {
    try {
      const xpPerModule = 50;
      final newTotalXp = state.totalXpEarned + xpPerModule;
      
      if (newTotalXp < 0) {
        throw AppExceptions.invalidXPValue(newTotalXp);
      }
      
      state = state.copyWith(
        totalXpEarned: newTotalXp,
      );
      
      // Check if any modules should be unlocked
      _checkAndUnlockModules();
    } catch (e) {
      ErrorHandlerService.handleException(
        e is Exception ? e : Exception('XP award failed: $e'),
        context: 'EducationProvider._awardXpForCompletion',
      );
    }
  }

  void _checkAndUnlockModules() {
    final updatedModules = state.modules.map((module) {
      if (module.isLocked && state.totalXpEarned >= module.requiredXp) {
        return module.copyWith(isLocked: false);
      }
      return module;
    }).toList();
    
    state = state.copyWith(modules: updatedModules);
  }

  void unlockModule(String moduleId) {
    ErrorHandlerService.safeExecute(
      () {
        // Check if module exists
        final moduleExists = state.modules.any((module) => module.id == moduleId);
        if (!moduleExists) {
          throw AppExceptions.moduleNotFound(moduleId);
        }
        
        // Check if module is already unlocked
        final module = state.modules.firstWhere((m) => m.id == moduleId);
        if (!module.isLocked) {
          throw EducationException(
            'Module $moduleId is already unlocked',
            code: 'MODULE_ALREADY_UNLOCKED',
          );
        }
        
        final updatedModules = state.modules.map((module) {
          if (module.id == moduleId) {
            return module.copyWith(isLocked: false);
          }
          return module;
        }).toList();
        
        state = state.copyWith(modules: updatedModules);
      },
      fallbackValue: null,
      context: 'EducationProvider.unlockModule',
    );
  }
}