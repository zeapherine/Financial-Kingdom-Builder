import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/achievement_system.dart';

class AchievementNotifier extends StateNotifier<AchievementState> {
  AchievementNotifier() : super(const AchievementState()) {
    _initializeAchievements();
  }

  void _initializeAchievements() {
    final achievements = AchievementDefinitions.allAchievements
        .map((def) => def.copyWith())
        .toList();
    
    state = state.copyWith(achievements: achievements);
  }

  void updateProgress(String achievementId, double progress) {
    final achievements = state.achievements.map((achievement) {
      if (achievement.id == achievementId) {
        final newProgress = (progress).clamp(0.0, 1.0);
        final wasUnlocked = achievement.isUnlocked;
        
        final updatedAchievement = achievement.copyWith(
          progress: newProgress,
          unlockedAt: newProgress >= 1.0 && !wasUnlocked ? DateTime.now() : achievement.unlockedAt,
        );
        
        // Check if this is a new unlock
        if (!wasUnlocked && updatedAchievement.isUnlocked) {
          _handleAchievementUnlocked(updatedAchievement);
        }
        
        return updatedAchievement;
      }
      return achievement;
    }).toList();

    state = state.copyWith(achievements: achievements);
  }

  void unlockAchievement(String achievementId) {
    updateProgress(achievementId, 1.0);
  }

  void incrementProgress(String achievementId, {double increment = 1.0}) {
    final achievement = getAchievementById(achievementId);
    if (achievement != null) {
      final currentSteps = (achievement.progress * achievement.totalSteps).round();
      final newSteps = currentSteps + increment.round();
      final newProgress = newSteps / achievement.totalSteps;
      updateProgress(achievementId, newProgress);
    }
  }

  Achievement? getAchievementById(String id) {
    try {
      return state.achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Achievement> getUnlockedAchievements() {
    return state.achievements.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return state.achievements.where((a) => a.category == category).toList();
  }

  List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return state.achievements.where((a) => a.rarity == rarity).toList();
  }

  List<Achievement> getRecentlyUnlocked({Duration? within}) {
    final cutoff = DateTime.now().subtract(within ?? const Duration(days: 7));
    return state.achievements
        .where((a) => a.isUnlocked && a.unlockedAt!.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
  }

  void clearRecentUnlocks() {
    state = state.copyWith(recentlyUnlocked: []);
  }

  void _handleAchievementUnlocked(Achievement achievement) {
    final recentUnlocks = [...state.recentlyUnlocked, achievement];
    state = state.copyWith(recentlyUnlocked: recentUnlocks);
  }

  // Achievement trigger methods for different actions
  void onLessonCompleted() {
    incrementProgress('first_lesson');
    incrementProgress('perfect_quiz');
  }

  void onTradeExecuted({bool profitable = false, bool usedStopLoss = false}) {
    incrementProgress('first_trade');
    
    if (profitable) {
      incrementProgress('profitable_streak');
    } else {
      // Reset profitable streak if trade was not profitable
      updateProgress('profitable_streak', 0.0);
    }
    
    if (usedStopLoss) {
      incrementProgress('risk_manager');
    }
  }

  void onStreakUpdated(int streakDays) {
    if (streakDays >= 7) {
      unlockAchievement('week_warrior');
    }
    if (streakDays >= 30) {
      unlockAchievement('month_master');
    }
    if (streakDays >= 100) {
      unlockAchievement('century_scholar');
    }
  }

  void onLevelReached(int level) {
    if (level >= 10) {
      unlockAchievement('level_10');
    }
    if (level >= 25) {
      unlockAchievement('level_25');
    }
    if (level >= 50) {
      unlockAchievement('level_50');
    }
  }

  void onBuildingUpgraded() {
    incrementProgress('kingdom_founder');
    incrementProgress('master_builder');
  }

  void onFriendAdded() {
    incrementProgress('social_butterfly');
  }

  void onMentorshipCompleted() {
    incrementProgress('helpful_mentor');
  }

  void onFirstDayCompleted() {
    unlockAchievement('first_day');
  }

  void onEarlyLogin() {
    incrementProgress('early_bird');
  }

  void onNightStudy() {
    incrementProgress('night_owl');
  }

  int getTotalXpFromAchievements() {
    return getUnlockedAchievements()
        .fold(0, (total, achievement) => total + achievement.xpReward);
  }

  Map<AchievementRarity, int> getRarityBreakdown() {
    final breakdown = <AchievementRarity, int>{};
    for (final rarity in AchievementRarity.values) {
      breakdown[rarity] = getUnlockedAchievements()
          .where((a) => a.rarity == rarity)
          .length;
    }
    return breakdown;
  }
}

class AchievementState {
  final List<Achievement> achievements;
  final List<Achievement> recentlyUnlocked;

  const AchievementState({
    this.achievements = const [],
    this.recentlyUnlocked = const [],
  });

  AchievementState copyWith({
    List<Achievement>? achievements,
    List<Achievement>? recentlyUnlocked,
  }) {
    return AchievementState(
      achievements: achievements ?? this.achievements,
      recentlyUnlocked: recentlyUnlocked ?? this.recentlyUnlocked,
    );
  }

  int get totalUnlocked => achievements.where((a) => a.isUnlocked).length;
  int get totalAchievements => achievements.length;
  double get completionPercentage => totalAchievements > 0 ? totalUnlocked / totalAchievements : 0.0;
}

// Providers
final achievementProvider = StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
  return AchievementNotifier();
});

final unlockedAchievementsProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementProvider);
  return state.achievements.where((a) => a.isUnlocked).toList();
});

final recentlyUnlockedProvider = Provider<List<Achievement>>((ref) {
  final state = ref.watch(achievementProvider);
  return state.recentlyUnlocked;
});

final achievementsByCategoryProvider = Provider.family<List<Achievement>, AchievementCategory?>((ref, category) {
  final state = ref.watch(achievementProvider);
  if (category == null) {
    return state.achievements;
  }
  return state.achievements.where((a) => a.category == category).toList();
});

final achievementStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(achievementProvider);
  final unlockedAchievements = state.achievements.where((a) => a.isUnlocked).toList();
  
  final rarityBreakdown = <AchievementRarity, int>{};
  for (final rarity in AchievementRarity.values) {
    rarityBreakdown[rarity] = unlockedAchievements
        .where((a) => a.rarity == rarity)
        .length;
  }
  
  return {
    'totalUnlocked': state.totalUnlocked,
    'totalAchievements': state.totalAchievements,
    'completionPercentage': state.completionPercentage,
    'totalXpEarned': unlockedAchievements.fold(0, (sum, a) => sum + a.xpReward),
    'rarityBreakdown': rarityBreakdown,
  };
});