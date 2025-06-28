import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/educational_milestone_system.dart';
import '../../kingdom/domain/models/kingdom_state.dart';
import 'tier_progression_provider.dart';

/// State for managing all milestone progress
class EducationalMilestoneState {
  final Map<String, MilestoneProgress> milestoneProgress;
  final List<String> completedMilestones;
  final List<String> availableMilestones;
  final int totalXpEarned;
  final DateTime lastUpdated;

  const EducationalMilestoneState({
    required this.milestoneProgress,
    required this.completedMilestones,
    required this.availableMilestones,
    required this.totalXpEarned,
    required this.lastUpdated,
  });

  EducationalMilestoneState copyWith({
    Map<String, MilestoneProgress>? milestoneProgress,
    List<String>? completedMilestones,
    List<String>? availableMilestones,
    int? totalXpEarned,
    DateTime? lastUpdated,
  }) {
    return EducationalMilestoneState(
      milestoneProgress: milestoneProgress ?? this.milestoneProgress,
      completedMilestones: completedMilestones ?? this.completedMilestones,
      availableMilestones: availableMilestones ?? this.availableMilestones,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestoneProgress': milestoneProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'completedMilestones': completedMilestones,
      'availableMilestones': availableMilestones,
      'totalXpEarned': totalXpEarned,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static EducationalMilestoneState fromJson(Map<String, dynamic> json) {
    final milestoneProgressMap = (json['milestoneProgress'] as Map<String, dynamic>? ?? {})
        .map<String, MilestoneProgress>((key, value) {
      return MapEntry(key, MilestoneProgress.fromJson(value as Map<String, dynamic>));
    });

    return EducationalMilestoneState(
      milestoneProgress: milestoneProgressMap,
      completedMilestones: List<String>.from(json['completedMilestones'] as List? ?? []),
      availableMilestones: List<String>.from(json['availableMilestones'] as List? ?? []),
      totalXpEarned: json['totalXpEarned'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Provider for managing educational milestone progress
class EducationalMilestoneNotifier extends StateNotifier<EducationalMilestoneState> {
  final Ref ref;

  EducationalMilestoneNotifier(this.ref) : super(_getInitialState());

  static EducationalMilestoneState _getInitialState() {
    return EducationalMilestoneState(
      milestoneProgress: {},
      completedMilestones: [],
      availableMilestones: [],
      totalXpEarned: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Initialize milestones for current tier
  void initializeMilestones(KingdomTier currentTier) {
    final availableMilestones = EducationalMilestoneSystem.getMilestonesUpToTier(currentTier);
    final availableIds = availableMilestones
        .where((milestone) => EducationalMilestoneSystem.canStartMilestone(
              milestone.id,
              currentTier,
              state.completedMilestones,
            ))
        .map((milestone) => milestone.id)
        .toList();

    state = state.copyWith(
      availableMilestones: availableIds,
      lastUpdated: DateTime.now(),
    );
  }

  /// Start tracking a milestone
  void startMilestone(String milestoneId) {
    final milestone = EducationalMilestoneSystem.getMilestoneById(milestoneId);
    if (milestone == null) return;

    // Check if already tracking this milestone
    if (state.milestoneProgress.containsKey(milestoneId)) return;

    final progress = MilestoneProgress(
      milestoneId: milestoneId,
      isCompleted: false,
      startedAt: DateTime.now(),
      progressPercentage: 0.0,
      progressData: {},
      completedSteps: [],
    );

    final updatedProgress = {...state.milestoneProgress};
    updatedProgress[milestoneId] = progress;

    state = state.copyWith(
      milestoneProgress: updatedProgress,
      lastUpdated: DateTime.now(),
    );
  }

  /// Update milestone progress
  void updateMilestoneProgress(String milestoneId, Map<String, dynamic> progressData) {
    final milestone = EducationalMilestoneSystem.getMilestoneById(milestoneId);
    if (milestone == null) return;

    final currentProgress = state.milestoneProgress[milestoneId];
    if (currentProgress == null) {
      startMilestone(milestoneId);
      return updateMilestoneProgress(milestoneId, progressData);
    }

    if (currentProgress.isCompleted) return; // Already completed

    // Calculate new progress percentage
    final newProgressPercentage = EducationalMilestoneSystem.calculateMilestoneProgress(
      milestone,
      progressData,
    );

    // Check if milestone is now completed
    final isCompleted = newProgressPercentage >= 1.0 && _validateMilestoneCompletion(milestone, progressData);

    final updatedProgress = currentProgress.copyWith(
      progressPercentage: newProgressPercentage,
      progressData: {...currentProgress.progressData, ...progressData},
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );

    final updatedProgressMap = {...state.milestoneProgress};
    updatedProgressMap[milestoneId] = updatedProgress;

    final updatedCompletedMilestones = [...state.completedMilestones];
    if (isCompleted && !updatedCompletedMilestones.contains(milestoneId)) {
      updatedCompletedMilestones.add(milestoneId);
      
      // Award XP for completion
      _awardMilestoneXp(milestone);
      
      // Update tier progression with milestone completion
      _updateTierProgression(milestoneId);
    }

    state = state.copyWith(
      milestoneProgress: updatedProgressMap,
      completedMilestones: updatedCompletedMilestones,
      lastUpdated: DateTime.now(),
    );

    // Check for newly available milestones
    _updateAvailableMilestones();
  }

  /// Validate that milestone completion criteria are met
  bool _validateMilestoneCompletion(EducationalMilestone milestone, Map<String, dynamic> progressData) {
    switch (milestone.type) {
      case MilestoneType.moduleCompletion:
        final modulesRequired = milestone.criteria['modulesRequired'] as int? ?? 1;
        final modulesCompleted = progressData['modulesCompleted'] as int? ?? 0;
        final minimumScore = milestone.criteria['minimumScore'] as int? ?? 0;
        final averageScore = progressData['averageScore'] as int? ?? 0;
        
        return modulesCompleted >= modulesRequired && averageScore >= minimumScore;

      case MilestoneType.quizPassing:
        final minimumScore = milestone.criteria['minimumScore'] as int? ?? 0;
        final quizScore = progressData['quizScore'] as int? ?? 0;
        
        return quizScore >= minimumScore;

      case MilestoneType.practicalApplication:
        bool allCriteriaMet = true;
        
        if (milestone.criteria.containsKey('tradesRequired')) {
          final tradesRequired = milestone.criteria['tradesRequired'] as int? ?? 1;
          final tradesCompleted = progressData['tradesCompleted'] as int? ?? 0;
          allCriteriaMet &= tradesCompleted >= tradesRequired;
        }
        
        if (milestone.criteria.containsKey('durationDays')) {
          final durationRequired = milestone.criteria['durationDays'] as int? ?? 1;
          final daysElapsed = progressData['daysElapsed'] as int? ?? 0;
          allCriteriaMet &= daysElapsed >= durationRequired;
        }
        
        if (milestone.criteria.containsKey('minimumAssets')) {
          final assetsRequired = milestone.criteria['minimumAssets'] as int? ?? 1;
          final assetsHeld = progressData['assetsHeld'] as int? ?? 0;
          allCriteriaMet &= assetsHeld >= assetsRequired;
        }
        
        if (milestone.criteria.containsKey('minCapitalRetention')) {
          final retentionRequired = milestone.criteria['minCapitalRetention'] as double? ?? 0.0;
          final currentRetention = progressData['capitalRetention'] as double? ?? 0.0;
          allCriteriaMet &= currentRetention >= retentionRequired;
        }
        
        return allCriteriaMet;

      case MilestoneType.streakAchievement:
        final streakRequired = milestone.criteria['streakDays'] as int? ?? 1;
        final currentStreak = progressData['currentStreak'] as int? ?? 0;
        
        return currentStreak >= streakRequired;

      case MilestoneType.skillMastery:
      case MilestoneType.certificateEarning:
      case MilestoneType.lessonCompletion:
      case MilestoneType.timeBasedProgress:
        return progressData['completed'] as bool? ?? false;
    }
  }

  /// Award XP for milestone completion
  void _awardMilestoneXp(EducationalMilestone milestone) {
    final newTotalXp = state.totalXpEarned + milestone.xpReward;
    state = state.copyWith(totalXpEarned: newTotalXp);
    
    // Update tier progression provider with new XP
    ref.read(tierProgressionProvider.notifier).updateXp(newTotalXp);
  }

  /// Update tier progression with milestone completion
  void _updateTierProgression(String milestoneId) {
    ref.read(tierProgressionProvider.notifier).completeMilestone(milestoneId);
  }

  /// Update available milestones based on current state
  void _updateAvailableMilestones() {
    final currentTier = ref.read(tierProgressionProvider).currentTier;
    final allMilestones = EducationalMilestoneSystem.getMilestonesUpToTier(currentTier);
    
    final availableIds = allMilestones
        .where((milestone) => EducationalMilestoneSystem.canStartMilestone(
              milestone.id,
              currentTier,
              state.completedMilestones,
            ))
        .map((milestone) => milestone.id)
        .toList();

    state = state.copyWith(availableMilestones: availableIds);
  }

  /// Complete milestone manually (for testing or admin purposes)
  void completeMilestone(String milestoneId) {
    final milestone = EducationalMilestoneSystem.getMilestoneById(milestoneId);
    if (milestone == null) return;

    // Create completion data based on milestone type
    Map<String, dynamic> completionData = {'completed': true};
    
    switch (milestone.type) {
      case MilestoneType.moduleCompletion:
        completionData.addAll({
          'modulesCompleted': milestone.criteria['modulesRequired'] ?? 1,
          'averageScore': milestone.criteria['minimumScore'] ?? 100,
        });
        break;
      case MilestoneType.quizPassing:
        completionData.addAll({
          'quizScore': milestone.criteria['minimumScore'] ?? 100,
        });
        break;
      case MilestoneType.practicalApplication:
        completionData.addAll({
          'tradesCompleted': milestone.criteria['tradesRequired'] ?? 1,
          'daysElapsed': milestone.criteria['durationDays'] ?? 1,
          'capitalRetention': milestone.criteria['minCapitalRetention'] ?? 1.0,
        });
        break;
      case MilestoneType.streakAchievement:
        completionData.addAll({
          'currentStreak': milestone.criteria['streakDays'] ?? 1,
        });
        break;
      default:
        break;
    }

    updateMilestoneProgress(milestoneId, completionData);
  }

  /// Get milestone progress by ID
  MilestoneProgress? getMilestoneProgress(String milestoneId) {
    return state.milestoneProgress[milestoneId];
  }

  /// Get all completed milestones
  List<EducationalMilestone> getCompletedMilestones() {
    return state.completedMilestones
        .map((id) => EducationalMilestoneSystem.getMilestoneById(id))
        .where((milestone) => milestone != null)
        .cast<EducationalMilestone>()
        .toList();
  }

  /// Get available milestones
  List<EducationalMilestone> getAvailableMilestones() {
    return state.availableMilestones
        .map((id) => EducationalMilestoneSystem.getMilestoneById(id))
        .where((milestone) => milestone != null)
        .cast<EducationalMilestone>()
        .toList();
  }

  /// Load milestone progress from storage/API
  Future<void> loadMilestoneProgress(String userId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data for demonstration
    final mockProgress = {
      'financial_literacy_basics': MilestoneProgress(
        milestoneId: 'financial_literacy_basics',
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        startedAt: DateTime.now().subtract(const Duration(days: 10)),
        progressPercentage: 1.0,
        progressData: {
          'modulesCompleted': 3,
          'averageScore': 85,
        },
        completedSteps: ['budgeting', 'saving', 'debt_management'],
      ),
      'first_virtual_trade': MilestoneProgress(
        milestoneId: 'first_virtual_trade',
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        startedAt: DateTime.now().subtract(const Duration(days: 8)),
        progressPercentage: 1.0,
        progressData: {
          'tradesCompleted': 1,
          'successful': true,
        },
        completedSteps: ['trade_executed'],
      ),
      'seven_day_streak': MilestoneProgress(
        milestoneId: 'seven_day_streak',
        isCompleted: false,
        startedAt: DateTime.now().subtract(const Duration(days: 5)),
        progressPercentage: 0.7,
        progressData: {
          'currentStreak': 5,
        },
        completedSteps: [],
      ),
    };

    final completedMilestones = mockProgress.values
        .where((progress) => progress.isCompleted)
        .map((progress) => progress.milestoneId)
        .toList();

    final mockState = EducationalMilestoneState(
      milestoneProgress: mockProgress,
      completedMilestones: completedMilestones,
      availableMilestones: ['financial_literacy_basics', 'first_virtual_trade', 'seven_day_streak', 'risk_awareness_quiz'],
      totalXpEarned: 150, // 100 + 50 from completed milestones
      lastUpdated: DateTime.now(),
    );

    state = mockState;
  }

  /// Save milestone progress to storage/API
  Future<void> saveMilestoneProgress(String userId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Implementation would save state.toJson() to backend
    // TODO: Implement actual API call to save milestone progress
  }

  /// Reset all milestone progress (for testing)
  void resetProgress() {
    state = _getInitialState();
  }
}

/// Main educational milestone provider
final educationalMilestoneProvider = StateNotifierProvider<EducationalMilestoneNotifier, EducationalMilestoneState>((ref) {
  return EducationalMilestoneNotifier(ref);
});

/// Computed providers for milestone tracking

/// Available milestones for current tier
final availableMilestonesProvider = Provider<List<EducationalMilestone>>((ref) {
  final notifier = ref.read(educationalMilestoneProvider.notifier);
  return notifier.getAvailableMilestones();
});

/// Completed milestones
final completedMilestonesProvider = Provider<List<EducationalMilestone>>((ref) {
  final notifier = ref.read(educationalMilestoneProvider.notifier);
  return notifier.getCompletedMilestones();
});

/// Total XP earned from milestones
final milestoneXpProvider = Provider<int>((ref) {
  final state = ref.watch(educationalMilestoneProvider);
  return state.totalXpEarned;
});

/// Milestone completion percentage for current tier
final tierMilestoneCompletionProvider = Provider<double>((ref) {
  final currentTier = ref.watch(tierProgressionProvider).currentTier;
  final state = ref.watch(educationalMilestoneProvider);
  
  final tierMilestones = EducationalMilestoneSystem.getMilestonesForTier(currentTier);
  if (tierMilestones.isEmpty) return 1.0;
  
  final completed = tierMilestones.where((milestone) => 
    state.completedMilestones.contains(milestone.id)
  ).length;
  
  return completed / tierMilestones.length;
});

/// Required milestones completion for current tier
final requiredMilestonesCompletionProvider = Provider<double>((ref) {
  final currentTier = ref.watch(tierProgressionProvider).currentTier;
  final state = ref.watch(educationalMilestoneProvider);
  
  final requiredMilestones = EducationalMilestoneSystem.getRequiredMilestonesForTier(currentTier);
  if (requiredMilestones.isEmpty) return 1.0;
  
  final completed = requiredMilestones.where((milestone) => 
    state.completedMilestones.contains(milestone.id)
  ).length;
  
  return completed / requiredMilestones.length;
});

/// In-progress milestones
final inProgressMilestonesProvider = Provider<List<MilestoneProgress>>((ref) {
  final state = ref.watch(educationalMilestoneProvider);
  return state.milestoneProgress.values
      .where((progress) => !progress.isCompleted)
      .toList();
});

/// Recent milestone completions (last 7 days)
final recentMilestoneCompletionsProvider = Provider<List<MilestoneProgress>>((ref) {
  final state = ref.watch(educationalMilestoneProvider);
  final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
  
  return state.milestoneProgress.values
      .where((progress) => 
        progress.isCompleted && 
        progress.completedAt != null && 
        progress.completedAt!.isAfter(cutoffDate)
      )
      .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
});

/// Milestones by category
final milestonesByCategoryProvider = Provider.family<List<EducationalMilestone>, String>((ref, category) {
  return EducationalMilestoneSystem.getMilestonesByCategory(category);
});

/// All milestone categories
final milestoneCategoriesProvider = Provider<List<String>>((ref) {
  return EducationalMilestoneSystem.getAllCategories();
});

/// Individual milestone progress provider
final milestoneProgressProvider = Provider.family<MilestoneProgress?, String>((ref, milestoneId) {
  final notifier = ref.read(educationalMilestoneProvider.notifier);
  return notifier.getMilestoneProgress(milestoneId);
});