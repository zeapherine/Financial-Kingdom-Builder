import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/streak_system.dart';

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier() : super(const StreakState()) {
    _initializeStreaks();
  }

  void _initializeStreaks() {
    final dailyStreak = StreakData(type: StreakType.daily);
    final weeklyStreak = StreakData(type: StreakType.weekly);
    final monthlyStreak = StreakData(type: StreakType.monthly);
    
    state = state.copyWith(
      dailyStreak: dailyStreak,
      weeklyStreak: weeklyStreak,
      monthlyStreak: monthlyStreak,
    );
  }

  void recordActivity(StreakType type, {DateTime? activityTime}) {
    final activity = activityTime ?? DateTime.now();
    
    switch (type) {
      case StreakType.daily:
        final newStreak = StreakCalculationService.recordActivity(
          state.dailyStreak,
          activity,
        );
        state = state.copyWith(dailyStreak: newStreak);
        break;
        
      case StreakType.weekly:
        final newStreak = StreakCalculationService.recordActivity(
          state.weeklyStreak,
          activity,
        );
        state = state.copyWith(weeklyStreak: newStreak);
        break;
        
      case StreakType.monthly:
        final newStreak = StreakCalculationService.recordActivity(
          state.monthlyStreak,
          activity,
        );
        state = state.copyWith(monthlyStreak: newStreak);
        break;
    }
    
    _checkForMilestones();
  }

  void recordDailyActivity() {
    recordActivity(StreakType.daily);
  }

  void recordWeeklyActivity() {
    recordActivity(StreakType.weekly);
  }

  void recordMonthlyActivity() {
    recordActivity(StreakType.monthly);
  }

  void checkAllStreakStatuses() {
    final updatedDaily = StreakCalculationService.checkStreakStatus(state.dailyStreak);
    final updatedWeekly = StreakCalculationService.checkStreakStatus(state.weeklyStreak);
    final updatedMonthly = StreakCalculationService.checkStreakStatus(state.monthlyStreak);
    
    state = state.copyWith(
      dailyStreak: updatedDaily,
      weeklyStreak: updatedWeekly,
      monthlyStreak: updatedMonthly,
    );
  }

  void _checkForMilestones() {
    final milestones = <StreakMilestone>[];
    
    // Check daily streak milestones
    final dailyMilestone = state.dailyStreak.currentMilestone;
    if (dailyMilestone != null && 
        state.dailyStreak.currentStreak == dailyMilestone.days &&
        !state.achievedMilestones.contains(dailyMilestone)) {
      milestones.add(dailyMilestone);
    }
    
    if (milestones.isNotEmpty) {
      state = state.copyWith(
        achievedMilestones: [...state.achievedMilestones, ...milestones],
        newMilestones: [...state.newMilestones, ...milestones],
      );
    }
  }

  void clearNewMilestones() {
    state = state.copyWith(newMilestones: []);
  }

  bool canExtendStreakToday(StreakType type) {
    switch (type) {
      case StreakType.daily:
        return state.dailyStreak.canExtendToday;
      case StreakType.weekly:
        return state.weeklyStreak.canExtendToday;
      case StreakType.monthly:
        return state.monthlyStreak.canExtendToday;
    }
  }

  bool isStreakInDanger(StreakType type) {
    switch (type) {
      case StreakType.daily:
        return state.dailyStreak.isInDanger;
      case StreakType.weekly:
        return state.weeklyStreak.isInDanger;
      case StreakType.monthly:
        return state.monthlyStreak.isInDanger;
    }
  }

  double getStreakHealth(StreakType type) {
    switch (type) {
      case StreakType.daily:
        return StreakCalculationService.getStreakHealthPercentage(state.dailyStreak);
      case StreakType.weekly:
        return StreakCalculationService.getStreakHealthPercentage(state.weeklyStreak);
      case StreakType.monthly:
        return StreakCalculationService.getStreakHealthPercentage(state.monthlyStreak);
    }
  }

  int getLongestStreak() {
    return [
      state.dailyStreak.longestStreak,
      state.weeklyStreak.longestStreak,
      state.monthlyStreak.longestStreak,
    ].reduce((a, b) => a > b ? a : b);
  }

  Map<StreakType, int> getCurrentStreaks() {
    return {
      StreakType.daily: state.dailyStreak.currentStreak,
      StreakType.weekly: state.weeklyStreak.currentStreak,
      StreakType.monthly: state.monthlyStreak.currentStreak,
    };
  }

  // Educational activity triggers
  void onLessonCompleted() {
    recordDailyActivity();
  }

  void onQuizCompleted() {
    recordDailyActivity();
  }

  void onModuleCompleted() {
    recordDailyActivity();
    recordWeeklyActivity();
  }

  void onDailyGoalMet() {
    recordDailyActivity();
  }

  void onWeeklyGoalMet() {
    recordWeeklyActivity();
  }

  void onMonthlyGoalMet() {
    recordMonthlyActivity();
  }

  // Special streak events
  void onEarlyMorningActivity() {
    // Bonus for early morning learning (before 8 AM)
    if (DateTime.now().hour < 8) {
      recordDailyActivity();
    }
  }

  void onLateNightActivity() {
    // Bonus for late night learning (after 10 PM)
    if (DateTime.now().hour >= 22) {
      recordDailyActivity();
    }
  }

  void onWeekendActivity() {
    // Bonus for weekend learning
    final now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      recordDailyActivity();
    }
  }

  void simulateStreakActivity({
    required int days,
    bool includeWeekends = true,
  }) {
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final activityDate = now.subtract(Duration(days: days - i));
      
      // Skip weekends if specified
      if (!includeWeekends && 
          (activityDate.weekday == DateTime.saturday || 
           activityDate.weekday == DateTime.sunday)) {
        continue;
      }
      
      recordActivity(StreakType.daily, activityTime: activityDate);
    }
  }
}

class StreakState {
  final StreakData dailyStreak;
  final StreakData weeklyStreak;
  final StreakData monthlyStreak;
  final List<StreakMilestone> achievedMilestones;
  final List<StreakMilestone> newMilestones;

  const StreakState({
    this.dailyStreak = const StreakData(type: StreakType.daily),
    this.weeklyStreak = const StreakData(type: StreakType.weekly),
    this.monthlyStreak = const StreakData(type: StreakType.monthly),
    this.achievedMilestones = const [],
    this.newMilestones = const [],
  });

  StreakState copyWith({
    StreakData? dailyStreak,
    StreakData? weeklyStreak,
    StreakData? monthlyStreak,
    List<StreakMilestone>? achievedMilestones,
    List<StreakMilestone>? newMilestones,
  }) {
    return StreakState(
      dailyStreak: dailyStreak ?? this.dailyStreak,
      weeklyStreak: weeklyStreak ?? this.weeklyStreak,
      monthlyStreak: monthlyStreak ?? this.monthlyStreak,
      achievedMilestones: achievedMilestones ?? this.achievedMilestones,
      newMilestones: newMilestones ?? this.newMilestones,
    );
  }

  int get totalCurrentStreaks => 
      dailyStreak.currentStreak + 
      weeklyStreak.currentStreak + 
      monthlyStreak.currentStreak;

  bool get hasActiveStreaks => 
      dailyStreak.isActive || 
      weeklyStreak.isActive || 
      monthlyStreak.isActive;
}

// Providers
final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier();
});

final dailyStreakProvider = Provider<StreakData>((ref) {
  return ref.watch(streakProvider).dailyStreak;
});

final weeklyStreakProvider = Provider<StreakData>((ref) {
  return ref.watch(streakProvider).weeklyStreak;
});

final monthlyStreakProvider = Provider<StreakData>((ref) {
  return ref.watch(streakProvider).monthlyStreak;
});

final streakHealthProvider = Provider.family<double, StreakType>((ref, type) {
  final notifier = ref.read(streakProvider.notifier);
  return notifier.getStreakHealth(type);
});

final newMilestonesProvider = Provider<List<StreakMilestone>>((ref) {
  return ref.watch(streakProvider).newMilestones;
});

final streakStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(streakProvider);
  
  return {
    'currentDaily': state.dailyStreak.currentStreak,
    'currentWeekly': state.weeklyStreak.currentStreak,
    'currentMonthly': state.monthlyStreak.currentStreak,
    'longestDaily': state.dailyStreak.longestStreak,
    'longestWeekly': state.weeklyStreak.longestStreak,
    'longestMonthly': state.monthlyStreak.longestStreak,
    'totalActive': state.totalCurrentStreaks,
    'hasActive': state.hasActiveStreaks,
    'milestonesAchieved': state.achievedMilestones.length,
  };
});