import 'dart:math';
import '../domain/models/xp_system.dart';

/// Service for calculating XP gains with multipliers and bonuses
/// Implements the core XP calculation logic for the gamification system
class XPCalculationService {
  static const int _baseXpPerLevel = 100;
  static const double _levelMultiplier = 1.5;
  
  /// Calculate XP gained for a specific action with active multipliers
  static int calculateXpGain(
    XPAction action, {
    List<XPMultiplier> activeMultipliers = const [],
    int currentStreak = 0,
    bool isFirstTimeToday = false,
  }) {
    int baseXp = action.baseXp;
    
    // Apply streak bonus (up to 50% bonus at 30-day streak)
    double streakMultiplier = 1.0 + min(currentStreak * 0.02, 0.5);
    
    // First-time daily bonus
    double dailyBonus = isFirstTimeToday ? 1.5 : 1.0;
    
    // Apply active XP multipliers
    double combinedMultiplier = activeMultipliers
        .where((m) => m.isActive)
        .fold(1.0, (total, multiplier) => total * multiplier.value);
    
    // Calculate final XP
    double finalXp = baseXp * streakMultiplier * dailyBonus * combinedMultiplier;
    
    return finalXp.round();
  }
  
  /// Calculate the level based on total XP
  static UserLevel calculateLevel(int totalXp) {
    int level = 1;
    int xpForCurrentLevel = 0;
    int xpForNextLevel = _baseXpPerLevel;
    
    // Find the current level
    while (totalXp >= xpForNextLevel) {
      level++;
      xpForCurrentLevel = xpForNextLevel;
      xpForNextLevel = _calculateXpForLevel(level + 1);
    }
    
    return UserLevel(
      level: level,
      currentXp: totalXp,
      xpForCurrentLevel: xpForCurrentLevel,
      xpForNextLevel: xpForNextLevel,
      title: _getLevelTitle(level),
      unlockedFeatures: _getUnlockedFeatures(level),
    );
  }
  
  /// Calculate XP required for a specific level
  static int _calculateXpForLevel(int level) {
    if (level <= 1) return 0;
    
    int totalXp = 0;
    for (int i = 1; i < level; i++) {
      totalXp += (_baseXpPerLevel * pow(_levelMultiplier, i - 1)).round();
    }
    return totalXp;
  }
  
  /// Get the title for a specific level
  static String _getLevelTitle(int level) {
    if (level <= 5) return 'Village Apprentice';
    if (level <= 10) return 'Town Scholar';
    if (level <= 20) return 'City Merchant';
    if (level <= 35) return 'Kingdom Trader';
    if (level <= 50) return 'Master Investor';
    return 'Financial Lord';
  }
  
  /// Get features unlocked at a specific level
  static List<String> _getUnlockedFeatures(int level) {
    List<String> features = [];
    
    if (level >= 2) features.add('Daily Streaks');
    if (level >= 5) features.add('Advanced Tutorials');
    if (level >= 10) features.add('Paper Trading');
    if (level >= 15) features.add('Community Forums');
    if (level >= 20) features.add('Real Trading (Limited)');
    if (level >= 25) features.add('Technical Analysis Tools');
    if (level >= 30) features.add('Options Education');
    if (level >= 40) features.add('Margin Trading');
    if (level >= 50) features.add('Perpetuals Trading');
    
    return features;
  }
  
  /// Check if leveling up and return level-up rewards
  static bool checkLevelUp(int previousXp, int newXp) {
    final previousLevel = calculateLevel(previousXp);
    final newLevel = calculateLevel(newXp);
    return newLevel.level > previousLevel.level;
  }
  
  /// Get XP bonus for maintaining streaks
  static XPMultiplier getStreakMultiplier(int streakDays) {
    if (streakDays >= 30) {
      return const XPMultiplier(
        type: 'streak_legendary',
        value: 2.0,
        description: 'Legendary 30-day streak!',
      );
    } else if (streakDays >= 14) {
      return const XPMultiplier(
        type: 'streak_fire',
        value: 1.5,
        description: 'Fire streak! 14+ days',
      );
    } else if (streakDays >= 7) {
      return const XPMultiplier(
        type: 'streak_hot',
        value: 1.25,
        description: 'Hot streak! 7+ days',
      );
    }
    
    return const XPMultiplier(
      type: 'base',
      value: 1.0,
      description: 'Base XP rate',
    );
  }
  
  /// Calculate weekly XP bonus
  static int calculateWeeklyBonus(List<XPGainEvent> weeklyEvents) {
    final totalWeeklyXp = weeklyEvents
        .fold(0, (sum, event) => sum + event.xpGained);
    
    // 10% bonus for 500+ XP in a week
    if (totalWeeklyXp >= 500) {
      return (totalWeeklyXp * 0.1).round();
    }
    
    return 0;
  }
}