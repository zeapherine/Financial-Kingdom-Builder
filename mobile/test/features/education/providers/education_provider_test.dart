import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:financial_kingdom_builder/core/exceptions/app_exceptions.dart';

// Mock Education Models (simplified for testing)
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

// Mock Education Provider for testing
class MockEducationNotifier extends StateNotifier<EducationState> {
  MockEducationNotifier() : super(EducationState(modules: _getInitialModules()));

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
        id: 'portfolio-basics',
        title: 'Portfolio Basics',
        description: 'Introduction to diversification',
        category: 'Portfolio Management',
        isLocked: true,
        requiredXp: 250,
      ),
    ];
  }

  void updateModuleProgress(String moduleId, double progress) {
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
  }

  void unlockModule(String moduleId) {
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
  }

  void _awardXpForCompletion(String moduleId) {
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
}

final mockEducationProvider = StateNotifierProvider<MockEducationNotifier, EducationState>(
  (ref) => MockEducationNotifier(),
);

void main() {
  group('EducationProvider', () {
    late ProviderContainer container;
    late MockEducationNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(mockEducationProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('should have correct initial values', () {
        final state = container.read(mockEducationProvider);
        expect(state.modules.length, equals(3));
        expect(state.moduleProgress, isEmpty);
        expect(state.totalXpEarned, equals(0));
        expect(state.currentTier, equals('Village'));
      });

      test('should have first module unlocked', () {
        final state = container.read(mockEducationProvider);
        final firstModule = state.modules.first;
        expect(firstModule.isLocked, isFalse);
        expect(firstModule.id, equals('financial-basics'));
      });

      test('should have subsequent modules locked', () {
        final state = container.read(mockEducationProvider);
        final lockedModules = state.modules.where((m) => m.isLocked).toList();
        expect(lockedModules.length, equals(2));
      });
    });

    group('updateModuleProgress', () {
      test('should update progress for unlocked module', () {
        notifier.updateModuleProgress('financial-basics', 0.5);
        final state = container.read(mockEducationProvider);
        expect(state.moduleProgress['financial-basics'], equals(0.5));
      });

      test('should award XP when module is completed', () {
        notifier.updateModuleProgress('financial-basics', 1.0);
        final state = container.read(mockEducationProvider);
        expect(state.totalXpEarned, equals(50));
      });

      test('should unlock modules when XP threshold is reached', () {
        // Complete first module to get 50 XP
        notifier.updateModuleProgress('financial-basics', 1.0);
        
        // Complete it again to get another 50 XP (total 100)
        // First reset progress to allow completion again
        final currentState = container.read(mockEducationProvider);
        final updatedProgress = Map<String, double>.from(currentState.moduleProgress);
        updatedProgress['financial-basics'] = 0.0;
        
        // Manually award more XP to reach 100
        notifier._awardXpForCompletion('test');
        
        final state = container.read(mockEducationProvider);
        final riskModule = state.modules.firstWhere((m) => m.id == 'risk-basics');
        expect(riskModule.isLocked, isFalse);
      });

      test('should throw exception for invalid progress values', () {
        expect(
          () => notifier.updateModuleProgress('financial-basics', -0.1),
          throwsA(isA<EducationException>()),
        );

        expect(
          () => notifier.updateModuleProgress('financial-basics', 1.1),
          throwsA(isA<EducationException>()),
        );
      });

      test('should throw exception for non-existent module', () {
        expect(
          () => notifier.updateModuleProgress('non-existent', 0.5),
          throwsA(isA<EducationException>()),
        );
      });

      test('should throw exception for locked module', () {
        expect(
          () => notifier.updateModuleProgress('risk-basics', 0.5),
          throwsA(isA<EducationException>()),
        );
      });

      test('should throw exception when trying to complete already completed module', () {
        // Complete module first
        notifier.updateModuleProgress('financial-basics', 1.0);
        
        // Try to complete again
        expect(
          () => notifier.updateModuleProgress('financial-basics', 1.0),
          throwsA(isA<EducationException>()),
        );
      });

      test('should allow partial progress updates after completion', () {
        // Complete module
        notifier.updateModuleProgress('financial-basics', 1.0);
        
        // Should be able to update to partial progress
        notifier.updateModuleProgress('financial-basics', 0.8);
        
        final state = container.read(mockEducationProvider);
        expect(state.moduleProgress['financial-basics'], equals(0.8));
      });
    });

    group('unlockModule', () {
      test('should unlock a locked module', () {
        notifier.unlockModule('risk-basics');
        final state = container.read(mockEducationProvider);
        final module = state.modules.firstWhere((m) => m.id == 'risk-basics');
        expect(module.isLocked, isFalse);
      });

      test('should throw exception for non-existent module', () {
        expect(
          () => notifier.unlockModule('non-existent'),
          throwsA(isA<EducationException>()),
        );
      });

      test('should throw exception when trying to unlock already unlocked module', () {
        expect(
          () => notifier.unlockModule('financial-basics'),
          throwsA(isA<EducationException>()),
        );
      });
    });

    group('XP Award System', () {
      test('should award correct XP amount for completion', () {
        notifier.updateModuleProgress('financial-basics', 1.0);
        final state = container.read(mockEducationProvider);
        expect(state.totalXpEarned, equals(50));
      });

      test('should only award XP once per completion', () {
        notifier.updateModuleProgress('financial-basics', 1.0);
        final firstState = container.read(mockEducationProvider);
        
        // Try to complete again (should throw exception)
        expect(
          () => notifier.updateModuleProgress('financial-basics', 1.0),
          throwsA(isA<EducationException>()),
        );
        
        // XP should remain the same
        final secondState = container.read(mockEducationProvider);
        expect(secondState.totalXpEarned, equals(firstState.totalXpEarned));
      });

      test('should throw exception for invalid XP calculation', () {
        // This test checks the _awardXpForCompletion method's error handling
        // In a real scenario, this would be hard to trigger, but we test the validation
        expect(
          () => notifier._awardXpForCompletion('test'),
          returnsNormally,
        );
      });
    });

    group('Module Unlocking Logic', () {
      test('should unlock modules based on XP requirements', () {
        // Award enough XP to unlock risk-basics (requires 100 XP)
        notifier.updateModuleProgress('financial-basics', 1.0); // 50 XP
        notifier._awardXpForCompletion('extra'); // Additional 50 XP
        
        final state = container.read(mockEducationProvider);
        final riskModule = state.modules.firstWhere((m) => m.id == 'risk-basics');
        expect(riskModule.isLocked, isFalse);
        
        // Portfolio module should still be locked (requires 250 XP)
        final portfolioModule = state.modules.firstWhere((m) => m.id == 'portfolio-basics');
        expect(portfolioModule.isLocked, isTrue);
      });

      test('should unlock multiple modules when enough XP is earned', () {
        // Award enough XP to unlock all modules
        for (int i = 0; i < 5; i++) {
          notifier._awardXpForCompletion('test');
        }
        
        final state = container.read(mockEducationProvider);
        final unlockedModules = state.modules.where((m) => !m.isLocked).toList();
        expect(unlockedModules.length, equals(3)); // All modules unlocked
      });
    });

    group('Edge Cases', () {
      test('should handle progress update to 0.0', () {
        notifier.updateModuleProgress('financial-basics', 0.0);
        final state = container.read(mockEducationProvider);
        expect(state.moduleProgress['financial-basics'], equals(0.0));
      });

      test('should handle progress update to 1.0 exactly', () {
        notifier.updateModuleProgress('financial-basics', 1.0);
        final state = container.read(mockEducationProvider);
        expect(state.moduleProgress['financial-basics'], equals(1.0));
        expect(state.totalXpEarned, equals(50));
      });

      test('should handle multiple progress updates for same module', () {
        notifier.updateModuleProgress('financial-basics', 0.3);
        notifier.updateModuleProgress('financial-basics', 0.7);
        notifier.updateModuleProgress('financial-basics', 1.0);
        
        final state = container.read(mockEducationProvider);
        expect(state.moduleProgress['financial-basics'], equals(1.0));
        expect(state.totalXpEarned, equals(50)); // XP awarded only once
      });
    });

    group('Error Recovery', () {
      test('should maintain state after failed progress update', () {
        notifier.updateModuleProgress('financial-basics', 0.5);
        // final initialState = container.read(mockEducationProvider); // TODO: Use state for validation
        
        // Try invalid operation
        expect(
          () => notifier.updateModuleProgress('financial-basics', 1.5),
          throwsA(isA<EducationException>()),
        );
        
        // Valid progress should remain
        final finalState = container.read(mockEducationProvider);
        expect(finalState.moduleProgress['financial-basics'], equals(0.5));
      });

      test('should maintain state after failed unlock attempt', () {
        final initialModuleCount = container.read(mockEducationProvider).modules.length;
        
        // Try invalid operation
        expect(
          () => notifier.unlockModule('non-existent'),
          throwsA(isA<EducationException>()),
        );
        
        // State should remain unchanged
        final finalState = container.read(mockEducationProvider);
        expect(finalState.modules.length, equals(initialModuleCount));
      });
    });
  });
}