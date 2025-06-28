import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/xp_system.dart';
import '../services/xp_calculation_service.dart';

class XPNotifier extends StateNotifier<XPState> {
  XPNotifier() : super(const XPState());

  void gainXP(XPAction action, {String? description}) {
    final currentState = state;
    final activeMultipliers = currentState.activeMultipliers;
    final streakDays = currentState.currentStreak;
    
    final xpGained = XPCalculationService.calculateXpGain(
      action,
      activeMultipliers: activeMultipliers,
      currentStreak: streakDays,
      isFirstTimeToday: !currentState.hasGainedXpToday,
    );
    
    final xpEvent = XPGainEvent(
      action: action,
      xpGained: xpGained,
      multiplier: _calculateTotalMultiplier(activeMultipliers, streakDays),
      timestamp: DateTime.now(),
      description: description,
    );
    
    final newTotalXp = currentState.totalXp + xpGained;
    final newLevel = XPCalculationService.calculateLevel(newTotalXp);
    final leveledUp = newLevel.level > currentState.userLevel.level;
    
    state = currentState.copyWith(
      totalXp: newTotalXp,
      userLevel: newLevel,
      recentXpEvents: [...currentState.recentXpEvents, xpEvent],
      hasGainedXpToday: true,
      lastXpGainTime: DateTime.now(),
    );
    
    if (leveledUp) {
      _handleLevelUp(currentState.userLevel.level, newLevel.level);
    }
  }

  void updateStreak(int streakDays) {
    final streakMultiplier = XPCalculationService.getStreakMultiplier(streakDays);
    final updatedMultipliers = [
      ...state.activeMultipliers.where((m) => m.type != 'streak_legendary' && 
          m.type != 'streak_fire' && m.type != 'streak_hot'),
      if (streakMultiplier.value > 1.0) streakMultiplier,
    ];
    
    state = state.copyWith(
      currentStreak: streakDays,
      activeMultipliers: updatedMultipliers,
    );
  }

  void addXpMultiplier(XPMultiplier multiplier) {
    state = state.copyWith(
      activeMultipliers: [...state.activeMultipliers, multiplier],
    );
  }

  void removeExpiredMultipliers() {
    final activeMultipliers = state.activeMultipliers
        .where((m) => m.isActive)
        .toList();
    
    state = state.copyWith(
      activeMultipliers: activeMultipliers,
    );
  }

  void clearRecentEvents() {
    state = state.copyWith(recentXpEvents: []);
  }

  void resetDailyXpFlag() {
    state = state.copyWith(hasGainedXpToday: false);
  }

  double _calculateTotalMultiplier(List<XPMultiplier> multipliers, int streak) {
    final baseMultiplier = multipliers
        .where((m) => m.isActive)
        .fold(1.0, (total, m) => total * m.value);
    
    final streakBonus = 1.0 + (streak * 0.02).clamp(0.0, 0.5);
    return baseMultiplier * streakBonus;
  }

  void _handleLevelUp(int oldLevel, int newLevel) {
    // Level up bonus XP
    final bonusXp = newLevel * 50;
    
    final levelUpEvent = XPGainEvent(
      action: XPAction.achievementUnlocked,
      xpGained: bonusXp,
      timestamp: DateTime.now(),
      description: 'Level $newLevel achieved!',
    );
    
    state = state.copyWith(
      totalXp: state.totalXp + bonusXp,
      recentXpEvents: [...state.recentXpEvents, levelUpEvent],
    );
  }
}

class XPState {
  final int totalXp;
  final UserLevel userLevel;
  final List<XPGainEvent> recentXpEvents;
  final List<XPMultiplier> activeMultipliers;
  final int currentStreak;
  final bool hasGainedXpToday;
  final DateTime? lastXpGainTime;

  const XPState({
    this.totalXp = 0,
    this.userLevel = const UserLevel(
      level: 1,
      currentXp: 0,
      xpForCurrentLevel: 0,
      xpForNextLevel: 100,
      title: 'Village Apprentice',
      unlockedFeatures: [],
    ),
    this.recentXpEvents = const [],
    this.activeMultipliers = const [],
    this.currentStreak = 0,
    this.hasGainedXpToday = false,
    this.lastXpGainTime,
  });

  XPState copyWith({
    int? totalXp,
    UserLevel? userLevel,
    List<XPGainEvent>? recentXpEvents,
    List<XPMultiplier>? activeMultipliers,
    int? currentStreak,
    bool? hasGainedXpToday,
    DateTime? lastXpGainTime,
  }) {
    return XPState(
      totalXp: totalXp ?? this.totalXp,
      userLevel: userLevel ?? this.userLevel,
      recentXpEvents: recentXpEvents ?? this.recentXpEvents,
      activeMultipliers: activeMultipliers ?? this.activeMultipliers,
      currentStreak: currentStreak ?? this.currentStreak,
      hasGainedXpToday: hasGainedXpToday ?? this.hasGainedXpToday,
      lastXpGainTime: lastXpGainTime ?? this.lastXpGainTime,
    );
  }
}

// Providers
final xpProvider = StateNotifierProvider<XPNotifier, XPState>((ref) {
  return XPNotifier();
});

final latestXpEventProvider = Provider<XPGainEvent?>((ref) {
  final xpState = ref.watch(xpProvider);
  return xpState.recentXpEvents.isEmpty ? null : xpState.recentXpEvents.last;
});

final hasLeveledUpRecentlyProvider = Provider<bool>((ref) {
  final xpState = ref.watch(xpProvider);
  if (xpState.lastXpGainTime == null) return false;
  
  final timeSinceLastGain = DateTime.now().difference(xpState.lastXpGainTime!);
  return timeSinceLastGain.inSeconds < 5; // Recent if within 5 seconds
});

final currentXpMultiplierProvider = Provider<double>((ref) {
  final xpState = ref.watch(xpProvider);
  return xpState.activeMultipliers
      .where((m) => m.isActive)
      .fold(1.0, (total, m) => total * m.value);
});