enum StreakType {
  daily,
  weekly,
  monthly,
}

enum StreakMilestone {
  bronze(7, 'Bronze Streak'),
  silver(14, 'Silver Streak'),
  gold(30, 'Gold Streak'),
  platinum(60, 'Platinum Streak'),
  diamond(100, 'Diamond Streak'),
  legendary(365, 'Legendary Streak');

  const StreakMilestone(this.days, this.title);
  final int days;
  final String title;
}

class StreakData {
  final StreakType type;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivity;
  final DateTime? streakStartDate;
  final List<DateTime> activityDates;
  final bool isActive;

  const StreakData({
    required this.type,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivity,
    this.streakStartDate,
    this.activityDates = const [],
    this.isActive = false,
  });

  bool get canExtendToday {
    if (lastActivity == null) return true;
    final today = DateTime.now();
    final lastDate = DateTime(lastActivity!.year, lastActivity!.month, lastActivity!.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return !lastDate.isAtSameMomentAs(todayDate);
  }

  bool get isInDanger {
    if (lastActivity == null) return false;
    final now = DateTime.now();
    final daysSinceLastActivity = now.difference(lastActivity!).inDays;
    return daysSinceLastActivity >= 1 && currentStreak > 0;
  }

  bool get isBroken {
    if (lastActivity == null) return false;
    final now = DateTime.now();
    final daysSinceLastActivity = now.difference(lastActivity!).inDays;
    return daysSinceLastActivity > 1;
  }

  StreakMilestone? get currentMilestone {
    return StreakMilestone.values
        .where((m) => currentStreak >= m.days)
        .fold<StreakMilestone?>(null, (prev, current) {
      if (prev == null || current.days > prev.days) {
        return current;
      }
      return prev;
    });
  }

  StreakMilestone? get nextMilestone {
    return StreakMilestone.values
        .where((m) => currentStreak < m.days)
        .fold<StreakMilestone?>(null, (prev, current) {
      if (prev == null || current.days < prev.days) {
        return current;
      }
      return prev;
    });
  }

  int get daysToNextMilestone {
    final next = nextMilestone;
    return next != null ? next.days - currentStreak : 0;
  }

  StreakData copyWith({
    StreakType? type,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivity,
    DateTime? streakStartDate,
    List<DateTime>? activityDates,
    bool? isActive,
  }) {
    return StreakData(
      type: type ?? this.type,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivity: lastActivity ?? this.lastActivity,
      streakStartDate: streakStartDate ?? this.streakStartDate,
      activityDates: activityDates ?? this.activityDates,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastActivity': lastActivity?.toIso8601String(),
    'streakStartDate': streakStartDate?.toIso8601String(),
    'activityDates': activityDates.map((d) => d.toIso8601String()).toList(),
    'isActive': isActive,
  };

  factory StreakData.fromJson(Map<String, dynamic> json) => StreakData(
    type: StreakType.values.byName(json['type']),
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    lastActivity: json['lastActivity'] != null 
        ? DateTime.parse(json['lastActivity']) 
        : null,
    streakStartDate: json['streakStartDate'] != null 
        ? DateTime.parse(json['streakStartDate']) 
        : null,
    activityDates: (json['activityDates'] as List<dynamic>?)
        ?.map((d) => DateTime.parse(d))
        .toList() ?? [],
    isActive: json['isActive'] ?? false,
  );
}

class StreakCalculationService {
  static StreakData recordActivity(StreakData current, DateTime activityTime) {
    final today = DateTime(activityTime.year, activityTime.month, activityTime.day);
    
    // Check if already recorded activity today
    if (current.lastActivity != null) {
      final lastDate = DateTime(
        current.lastActivity!.year, 
        current.lastActivity!.month, 
        current.lastActivity!.day
      );
      if (lastDate.isAtSameMomentAs(today)) {
        return current; // Already recorded today
      }
    }

    // Calculate new streak
    int newStreak = current.currentStreak;
    DateTime? newStreakStart = current.streakStartDate;
    
    if (current.lastActivity == null) {
      // First activity ever
      newStreak = 1;
      newStreakStart = today;
    } else {
      final daysSinceLastActivity = today.difference(
        DateTime(current.lastActivity!.year, current.lastActivity!.month, current.lastActivity!.day)
      ).inDays;
      
      if (daysSinceLastActivity == 1) {
        // Consecutive day - extend streak
        newStreak = current.currentStreak + 1;
        newStreakStart ??= today;
      } else if (daysSinceLastActivity > 1) {
        // Streak broken - start new streak
        newStreak = 1;
        newStreakStart = today;
      }
    }

    final newActivityDates = [...current.activityDates, activityTime];
    final newLongestStreak = newStreak > current.longestStreak 
        ? newStreak 
        : current.longestStreak;

    return current.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActivity: activityTime,
      streakStartDate: newStreakStart,
      activityDates: newActivityDates,
      isActive: true,
    );
  }

  static StreakData checkStreakStatus(StreakData current) {
    if (current.isBroken && current.isActive) {
      return current.copyWith(
        currentStreak: 0,
        isActive: false,
      );
    }
    return current;
  }

  static List<DateTime> getActivityCalendar(StreakData streak, {int days = 30}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    
    return List.generate(days, (index) {
      final date = startDate.add(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    });
  }

  static bool hasActivityOnDate(StreakData streak, DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return streak.activityDates.any((activity) {
      final activityDate = DateTime(activity.year, activity.month, activity.day);
      return activityDate.isAtSameMomentAs(targetDate);
    });
  }

  static double getStreakHealthPercentage(StreakData streak) {
    if (streak.currentStreak == 0) return 0.0;
    
    final now = DateTime.now();
    final lastActivity = streak.lastActivity;
    
    if (lastActivity == null) return 0.0;
    
    final hoursSinceLastActivity = now.difference(lastActivity).inHours;
    
    // Consider streak healthy if activity was within 24 hours
    if (hoursSinceLastActivity <= 24) return 1.0;
    
    // Declining health after 24 hours
    if (hoursSinceLastActivity <= 48) {
      return 1.0 - ((hoursSinceLastActivity - 24) / 24);
    }
    
    return 0.0; // Streak is broken
  }
}