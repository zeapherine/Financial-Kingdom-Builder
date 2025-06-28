import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/tier_progression_system.dart';
import '../../kingdom/domain/models/kingdom_state.dart';
// Note: These imports will be used when integrating with other providers
// import '../../education/providers/education_provider.dart';
// import 'xp_provider.dart';
// import 'streak_provider.dart';
// import 'achievement_provider.dart';

/// Provider for managing tier progression state and validation
class TierProgressionNotifier extends StateNotifier<TierProgress> {
  TierProgressionNotifier() : super(_getInitialProgress());

  static TierProgress _getInitialProgress() {
    return TierProgress(
      currentTier: KingdomTier.village,
      tierStartDate: DateTime.now(),
      currentXp: 0,
      virtualTradesCompleted: 0,
      educationModulesCompleted: 0,
      currentStreak: 0,
      unlockedAchievements: [],
      masteredSkills: [],
      currentCapitalRetention: 1.0,
      hasPassedRiskAssessment: false,
      competencyChecks: {},
      milestoneCompletionDates: {},
    );
  }

  /// Update XP and check for tier progression
  void updateXp(int newXp) {
    state = state.copyWith(currentXp: newXp);
    _checkTierProgression();
  }

  /// Update virtual trades count
  void incrementVirtualTrades() {
    state = state.copyWith(
      virtualTradesCompleted: state.virtualTradesCompleted + 1,
    );
    _checkTierProgression();
  }

  /// Update education modules completed
  void updateEducationModules(int completed) {
    state = state.copyWith(educationModulesCompleted: completed);
    _checkTierProgression();
  }

  /// Update current streak
  void updateStreak(int newStreak) {
    state = state.copyWith(currentStreak: newStreak);
    _checkTierProgression();
  }

  /// Add unlocked achievement
  void unlockAchievement(String achievementId) {
    if (!state.unlockedAchievements.contains(achievementId)) {
      final updatedAchievements = [...state.unlockedAchievements, achievementId];
      state = state.copyWith(unlockedAchievements: updatedAchievements);
      _checkTierProgression();
    }
  }

  /// Add mastered skill
  void masterSkill(String skillId) {
    if (!state.masteredSkills.contains(skillId)) {
      final updatedSkills = [...state.masteredSkills, skillId];
      state = state.copyWith(masteredSkills: updatedSkills);
      _checkTierProgression();
    }
  }

  /// Update capital retention percentage
  void updateCapitalRetention(double retention) {
    state = state.copyWith(currentCapitalRetention: retention);
    _checkTierProgression();
  }

  /// Mark risk assessment as passed
  void passRiskAssessment() {
    state = state.copyWith(hasPassedRiskAssessment: true);
    _checkTierProgression();
  }

  /// Update competency check status
  void updateCompetencyCheck(String competencyId, bool passed) {
    final updatedChecks = {...state.competencyChecks};
    updatedChecks[competencyId] = passed;
    state = state.copyWith(competencyChecks: updatedChecks);
    _checkTierProgression();
  }

  /// Record milestone completion
  void completeMilestone(String milestoneId) {
    final updatedMilestones = {...state.milestoneCompletionDates};
    updatedMilestones[milestoneId] = DateTime.now();
    state = state.copyWith(milestoneCompletionDates: updatedMilestones);
    _checkTierProgression();
  }

  /// Check if user can advance to next tier and advance if eligible
  void _checkTierProgression() {
    if (TierProgressionSystem.canAdvanceToNextTier(state)) {
      _advanceToNextTier();
    }
  }

  /// Advance user to next tier
  void _advanceToNextTier() {
    final tiers = KingdomTier.values;
    final currentIndex = tiers.indexOf(state.currentTier);
    
    if (currentIndex >= 0 && currentIndex < tiers.length - 1) {
      final nextTier = tiers[currentIndex + 1];
      state = state.copyWith(
        currentTier: nextTier,
        tierStartDate: DateTime.now(),
      );
      
      // Record tier advancement milestone
      completeMilestone('tier_${nextTier.name}_unlocked');
    }
  }

  /// Force tier advancement (for testing purposes)
  void forceAdvanceToTier(KingdomTier targetTier) {
    state = state.copyWith(
      currentTier: targetTier,
      tierStartDate: DateTime.now(),
    );
    completeMilestone('tier_${targetTier.name}_unlocked');
  }

  /// Validate specific requirement for current tier
  bool validateRequirement(String requirementType) {
    final nextTierRequirements = TierProgressionSystem.getNextTierRequirements(state.currentTier);
    if (nextTierRequirements == null) return true;

    switch (requirementType) {
      case 'time':
        return state.meetsTimeRequirement(nextTierRequirements);
      case 'xp':
        return state.currentXp >= nextTierRequirements.minimumXp;
      case 'virtual_trades':
        return state.virtualTradesCompleted >= nextTierRequirements.requiredVirtualTrades;
      case 'education':
        return state.educationModulesCompleted >= nextTierRequirements.requiredEducationModules;
      case 'streak':
        return state.currentStreak >= nextTierRequirements.requiredStreak;
      case 'capital_retention':
        return state.currentCapitalRetention >= nextTierRequirements.minimumCapitalRetention;
      case 'achievements':
        return nextTierRequirements.requiredAchievements.every(
          (achievement) => state.unlockedAchievements.contains(achievement),
        );
      case 'skills':
        return nextTierRequirements.requiredSkills.every(
          (skill) => state.masteredSkills.contains(skill),
        );
      case 'risk_assessment':
        final riskRequired = nextTierRequirements.specialRequirements['riskAssessmentRequired'] == true;
        return !riskRequired || state.hasPassedRiskAssessment;
      default:
        return false;
    }
  }

  /// Get detailed progress breakdown
  Map<String, dynamic> getProgressBreakdown() {
    return TierProgressionSystem.getProgressBreakdown(state);
  }

  /// Check if specific feature is unlocked for current tier
  bool isFeatureUnlocked(String feature) {
    final currentTierRequirements = TierProgressionSystem.getRequirementsForTier(state.currentTier);
    return currentTierRequirements?.availableFeatures.contains(feature) ?? false;
  }

  /// Get maximum position size for current tier
  int getMaxPositionSize() {
    final currentTierRequirements = TierProgressionSystem.getRequirementsForTier(state.currentTier);
    return currentTierRequirements?.maxPositionSize ?? 0;
  }

  /// Check if real money trading is allowed
  bool isRealMoneyTradingAllowed() {
    final currentTierRequirements = TierProgressionSystem.getRequirementsForTier(state.currentTier);
    return currentTierRequirements?.realMoneyAllowed ?? false;
  }

  /// Load user progress from storage/API
  Future<void> loadUserProgress(String userId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data for demonstration
    final mockProgress = TierProgress(
      currentTier: KingdomTier.village,
      tierStartDate: DateTime.now().subtract(const Duration(days: 15)),
      currentXp: 250,
      virtualTradesCompleted: 3,
      educationModulesCompleted: 2,
      currentStreak: 5,
      unlockedAchievements: ['first_trade', 'education_starter'],
      masteredSkills: ['basic_trading'],
      currentCapitalRetention: 0.98,
      hasPassedRiskAssessment: false,
      competencyChecks: {
        'basic_trading_quiz': true,
        'risk_awareness_quiz': false,
      },
      milestoneCompletionDates: {
        'first_trade': DateTime.now().subtract(const Duration(days: 10)),
        'education_starter': DateTime.now().subtract(const Duration(days: 8)),
      },
    );
    
    state = mockProgress;
  }

  /// Save user progress to storage/API
  Future<void> saveUserProgress(String userId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Implementation would save state.toJson() to backend
    // TODO: Implement actual API call to save progress
  }

  /// Reset progress (for testing)
  void resetProgress() {
    state = _getInitialProgress();
  }
}

/// Main tier progression provider
final tierProgressionProvider = StateNotifierProvider<TierProgressionNotifier, TierProgress>((ref) {
  return TierProgressionNotifier();
});

/// Computed providers for specific tier progression aspects

/// Current tier requirements
final currentTierRequirementsProvider = Provider<TierProgressionRequirements?>((ref) {
  final progress = ref.watch(tierProgressionProvider);
  return TierProgressionSystem.getRequirementsForTier(progress.currentTier);
});

/// Next tier requirements
final nextTierRequirementsProvider = Provider<TierProgressionRequirements?>((ref) {
  final progress = ref.watch(tierProgressionProvider);
  return TierProgressionSystem.getNextTierRequirements(progress.currentTier);
});

/// Overall progress to next tier
final tierProgressPercentageProvider = Provider<double>((ref) {
  final progress = ref.watch(tierProgressionProvider);
  final nextTierRequirements = ref.watch(nextTierRequirementsProvider);
  
  if (nextTierRequirements == null) return 1.0; // Max tier reached
  
  return progress.getProgressPercentage(nextTierRequirements);
});

/// Can advance to next tier
final canAdvanceToNextTierProvider = Provider<bool>((ref) {
  final progress = ref.watch(tierProgressionProvider);
  return TierProgressionSystem.canAdvanceToNextTier(progress);
});

/// Available features for current tier
final availableFeaturesProvider = Provider<List<String>>((ref) {
  final currentTierRequirements = ref.watch(currentTierRequirementsProvider);
  return currentTierRequirements?.availableFeatures ?? [];
});

/// Days in current tier
final daysInCurrentTierProvider = Provider<int>((ref) {
  final progress = ref.watch(tierProgressionProvider);
  return progress.daysInCurrentTier;
});

/// Detailed progress breakdown
final progressBreakdownProvider = Provider<Map<String, dynamic>>((ref) {
  final progress = ref.watch(tierProgressionProvider);
  return TierProgressionSystem.getProgressBreakdown(progress);
});

/// Specific requirement validation providers
final timeRequirementMetProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.validateRequirement('time');
});

final xpRequirementMetProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.validateRequirement('xp');
});

final virtualTradesRequirementMetProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.validateRequirement('virtual_trades');
});

final educationRequirementMetProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.validateRequirement('education');
});

final streakRequirementMetProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.validateRequirement('streak');
});

final capitalRetentionRequirementMetProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.validateRequirement('capital_retention');
});

final achievementsRequirementMetProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.validateRequirement('achievements');
});

final skillsRequirementMetProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.validateRequirement('skills');
});

final riskAssessmentRequirementMetProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.validateRequirement('risk_assessment');
});

/// Trading permissions based on tier
final maxPositionSizeProvider = Provider<int>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.getMaxPositionSize();
});

final realMoneyTradingAllowedProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.isRealMoneyTradingAllowed();
});

/// Feature unlock providers
final virtualTradingUnlockedProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.isFeatureUnlocked('virtual_trading');
});

final realTradingUnlockedProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.isFeatureUnlocked('limited_real_trading') || 
         notifier.isFeatureUnlocked('options_trading') ||
         notifier.isFeatureUnlocked('perpetuals_trading');
});

final optionsTradingUnlockedProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.isFeatureUnlocked('options_trading');
});

final marginTradingUnlockedProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.isFeatureUnlocked('margin_trading_basic') ||
         notifier.isFeatureUnlocked('full_margin_access');
});

final perpetualsTradingUnlockedProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.isFeatureUnlocked('perpetuals_trading');
});

final socialFeaturesUnlockedProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.isFeatureUnlocked('social_features_basic') ||
         notifier.isFeatureUnlocked('social_trading') ||
         notifier.isFeatureUnlocked('social_trading_leader');
});

final mentorshipUnlockedProvider = Provider<bool>((ref) {
  final notifier = ref.read(tierProgressionProvider.notifier);
  return notifier.isFeatureUnlocked('mentor_access') ||
         notifier.isFeatureUnlocked('mentorship_program');
});