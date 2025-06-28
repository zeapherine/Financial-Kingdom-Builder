enum AchievementCategory {
  education,
  trading,
  social,
  streaks,
  kingdom,
  milestones,
}

enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int xpReward;
  final List<String> requirements;
  final DateTime? unlockedAt;
  final double progress;
  final int totalSteps;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    required this.rarity,
    required this.xpReward,
    required this.requirements,
    this.unlockedAt,
    this.progress = 0.0,
    this.totalSteps = 1,
  });

  bool get isUnlocked => unlockedAt != null;
  bool get isCompleted => progress >= 1.0;
  
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    AchievementCategory? category,
    AchievementRarity? rarity,
    int? xpReward,
    List<String>? requirements,
    DateTime? unlockedAt,
    double? progress,
    int? totalSteps,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      xpReward: xpReward ?? this.xpReward,
      requirements: requirements ?? this.requirements,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'iconName': iconName,
    'category': category.name,
    'rarity': rarity.name,
    'xpReward': xpReward,
    'requirements': requirements,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'progress': progress,
    'totalSteps': totalSteps,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    iconName: json['iconName'],
    category: AchievementCategory.values.byName(json['category']),
    rarity: AchievementRarity.values.byName(json['rarity']),
    xpReward: json['xpReward'],
    requirements: List<String>.from(json['requirements']),
    unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    progress: json['progress'] ?? 0.0,
    totalSteps: json['totalSteps'] ?? 1,
  );
}

class AchievementDefinitions {
  static const List<Achievement> allAchievements = [
    // Education Achievements
    Achievement(
      id: 'first_lesson',
      title: 'Scholar\'s Beginning',
      description: 'Complete your first educational module',
      iconName: 'school',
      category: AchievementCategory.education,
      rarity: AchievementRarity.common,
      xpReward: 50,
      requirements: ['Complete 1 educational module'],
    ),
    
    Achievement(
      id: 'education_graduate',
      title: 'Village Graduate',
      description: 'Complete all Tier 1 educational modules',
      iconName: 'school_outlined',
      category: AchievementCategory.education,
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
      requirements: ['Complete all Tier 1 modules'],
    ),
    
    Achievement(
      id: 'perfect_quiz',
      title: 'Perfect Scholar',
      description: 'Get 100% on 5 quizzes in a row',
      iconName: 'emoji_events',
      category: AchievementCategory.education,
      rarity: AchievementRarity.rare,
      xpReward: 150,
      requirements: ['Score 100% on 5 consecutive quizzes'],
      totalSteps: 5,
    ),
    
    // Trading Achievements
    Achievement(
      id: 'first_trade',
      title: 'Market Apprentice',
      description: 'Execute your first trade',
      iconName: 'trending_up',
      category: AchievementCategory.trading,
      rarity: AchievementRarity.common,
      xpReward: 75,
      requirements: ['Complete 1 trade'],
    ),
    
    Achievement(
      id: 'profitable_streak',
      title: 'Golden Touch',
      description: 'Make 10 profitable trades in a row',
      iconName: 'show_chart',
      category: AchievementCategory.trading,
      rarity: AchievementRarity.epic,
      xpReward: 500,
      requirements: ['10 consecutive profitable trades'],
      totalSteps: 10,
    ),
    
    Achievement(
      id: 'risk_manager',
      title: 'Risk Master',
      description: 'Use stop-loss orders in 20 trades',
      iconName: 'security',
      category: AchievementCategory.trading,
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
      requirements: ['Use stop-loss in 20 trades'],
      totalSteps: 20,
    ),
    
    // Streak Achievements
    Achievement(
      id: 'week_warrior',
      title: 'Week Warrior',
      description: 'Maintain a 7-day learning streak',
      iconName: 'local_fire_department',
      category: AchievementCategory.streaks,
      rarity: AchievementRarity.uncommon,
      xpReward: 100,
      requirements: ['7-day streak'],
      totalSteps: 7,
    ),
    
    Achievement(
      id: 'month_master',
      title: 'Month Master',
      description: 'Achieve a 30-day learning streak',
      iconName: 'whatshot',
      category: AchievementCategory.streaks,
      rarity: AchievementRarity.epic,
      xpReward: 1000,
      requirements: ['30-day streak'],
      totalSteps: 30,
    ),
    
    Achievement(
      id: 'century_scholar',
      title: 'Century Scholar',
      description: 'Reach a 100-day learning streak',
      iconName: 'celebration',
      category: AchievementCategory.streaks,
      rarity: AchievementRarity.legendary,
      xpReward: 5000,
      requirements: ['100-day streak'],
      totalSteps: 100,
    ),
    
    // Kingdom Achievements
    Achievement(
      id: 'kingdom_founder',
      title: 'Kingdom Founder',
      description: 'Upgrade your first building',
      iconName: 'account_balance',
      category: AchievementCategory.kingdom,
      rarity: AchievementRarity.common,
      xpReward: 100,
      requirements: ['Upgrade 1 building'],
    ),
    
    Achievement(
      id: 'master_builder',
      title: 'Master Builder',
      description: 'Fully upgrade all kingdom buildings',
      iconName: 'domain',
      category: AchievementCategory.kingdom,
      rarity: AchievementRarity.epic,
      xpReward: 1000,
      requirements: ['Fully upgrade all buildings'],
    ),
    
    Achievement(
      id: 'royal_kingdom',
      title: 'Royal Kingdom',
      description: 'Reach Kingdom tier (Level 4)',
      iconName: 'castle',
      category: AchievementCategory.kingdom,
      rarity: AchievementRarity.legendary,
      xpReward: 2000,
      requirements: ['Reach Kingdom tier'],
    ),
    
    // Social Achievements
    Achievement(
      id: 'social_butterfly',
      title: 'Social Butterfly',
      description: 'Make 10 friends',
      iconName: 'people',
      category: AchievementCategory.social,
      rarity: AchievementRarity.uncommon,
      xpReward: 150,
      requirements: ['Add 10 friends'],
      totalSteps: 10,
    ),
    
    Achievement(
      id: 'helpful_mentor',
      title: 'Helpful Mentor',
      description: 'Help 5 new traders',
      iconName: 'psychology',
      category: AchievementCategory.social,
      rarity: AchievementRarity.rare,
      xpReward: 300,
      requirements: ['Mentor 5 new traders'],
      totalSteps: 5,
    ),
    
    Achievement(
      id: 'community_leader',
      title: 'Community Leader',
      description: 'Reach top 10 on leaderboard',
      iconName: 'leaderboard',
      category: AchievementCategory.social,
      rarity: AchievementRarity.epic,
      xpReward: 500,
      requirements: ['Reach top 10 leaderboard'],
    ),
    
    // Milestone Achievements
    Achievement(
      id: 'level_10',
      title: 'Rising Star',
      description: 'Reach level 10',
      iconName: 'star',
      category: AchievementCategory.milestones,
      rarity: AchievementRarity.uncommon,
      xpReward: 200,
      requirements: ['Reach level 10'],
    ),
    
    Achievement(
      id: 'level_25',
      title: 'Expert Trader',
      description: 'Reach level 25',
      iconName: 'star_rate',
      category: AchievementCategory.milestones,
      rarity: AchievementRarity.rare,
      xpReward: 500,
      requirements: ['Reach level 25'],
    ),
    
    Achievement(
      id: 'level_50',
      title: 'Financial Master',
      description: 'Reach level 50',
      iconName: 'stars',
      category: AchievementCategory.milestones,
      rarity: AchievementRarity.legendary,
      xpReward: 2000,
      requirements: ['Reach level 50'],
    ),
    
    // Special Achievements
    Achievement(
      id: 'first_day',
      title: 'Welcome Aboard',
      description: 'Complete your first day',
      iconName: 'celebration',
      category: AchievementCategory.milestones,
      rarity: AchievementRarity.common,
      xpReward: 25,
      requirements: ['Login on first day'],
    ),
    
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Login before 8 AM for 7 days',
      iconName: 'wb_sunny',
      category: AchievementCategory.streaks,
      rarity: AchievementRarity.rare,
      xpReward: 300,
      requirements: ['Login before 8 AM for 7 days'],
      totalSteps: 7,
    ),
    
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Complete lessons after 10 PM for 5 days',
      iconName: 'nights_stay',
      category: AchievementCategory.education,
      rarity: AchievementRarity.rare,
      xpReward: 250,
      requirements: ['Study after 10 PM for 5 days'],
      totalSteps: 5,
    ),
  ];
  
  static Achievement? getById(String id) {
    try {
      return allAchievements.firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }
  
  static List<Achievement> getByCategory(AchievementCategory category) {
    return allAchievements.where((a) => a.category == category).toList();
  }
  
  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return allAchievements.where((a) => a.rarity == rarity).toList();
  }
}