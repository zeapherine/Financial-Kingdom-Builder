enum XPAction {
  completeLesson(10),
  dailyLogin(5),
  streakMaintained(20),
  firstTrade(50),
  profitableTrade(25),
  riskManagementUsed(15),
  quizPassed(30),
  moduleCompleted(100),
  achievementUnlocked(200),
  socialInteraction(5),
  tutorialCompleted(75),
  kingdomUpgrade(150);

  const XPAction(this.baseXp);
  final int baseXp;
}

class XPGainEvent {
  final XPAction action;
  final int xpGained;
  final double multiplier;
  final DateTime timestamp;
  final String? description;

  const XPGainEvent({
    required this.action,
    required this.xpGained,
    this.multiplier = 1.0,
    required this.timestamp,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'action': action.name,
    'xpGained': xpGained,
    'multiplier': multiplier,
    'timestamp': timestamp.toIso8601String(),
    'description': description,
  };

  factory XPGainEvent.fromJson(Map<String, dynamic> json) => XPGainEvent(
    action: XPAction.values.byName(json['action']),
    xpGained: json['xpGained'],
    multiplier: json['multiplier'] ?? 1.0,
    timestamp: DateTime.parse(json['timestamp']),
    description: json['description'],
  );
}

class UserLevel {
  final int level;
  final int currentXp;
  final int xpForCurrentLevel;
  final int xpForNextLevel;
  final String title;
  final List<String> unlockedFeatures;

  const UserLevel({
    required this.level,
    required this.currentXp,
    required this.xpForCurrentLevel,
    required this.xpForNextLevel,
    required this.title,
    required this.unlockedFeatures,
  });

  double get progressToNextLevel {
    final xpNeededForNext = xpForNextLevel - xpForCurrentLevel;
    final xpGainedInLevel = currentXp - xpForCurrentLevel;
    return xpGainedInLevel / xpNeededForNext;
  }

  int get xpToNextLevel => xpForNextLevel - currentXp;

  Map<String, dynamic> toJson() => {
    'level': level,
    'currentXp': currentXp,
    'xpForCurrentLevel': xpForCurrentLevel,
    'xpForNextLevel': xpForNextLevel,
    'title': title,
    'unlockedFeatures': unlockedFeatures,
  };

  factory UserLevel.fromJson(Map<String, dynamic> json) => UserLevel(
    level: json['level'],
    currentXp: json['currentXp'],
    xpForCurrentLevel: json['xpForCurrentLevel'],
    xpForNextLevel: json['xpForNextLevel'],
    title: json['title'],
    unlockedFeatures: List<String>.from(json['unlockedFeatures']),
  );
}

class XPMultiplier {
  final String type;
  final double value;
  final DateTime? expiresAt;
  final String description;

  const XPMultiplier({
    required this.type,
    required this.value,
    this.expiresAt,
    required this.description,
  });

  bool get isActive => expiresAt == null || DateTime.now().isBefore(expiresAt!);

  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    'expiresAt': expiresAt?.toIso8601String(),
    'description': description,
  };

  factory XPMultiplier.fromJson(Map<String, dynamic> json) => XPMultiplier(
    type: json['type'],
    value: json['value'],
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    description: json['description'],
  );
}