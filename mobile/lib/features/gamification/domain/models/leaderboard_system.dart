enum LeaderboardType {
  weekly,
  monthly,
  allTime,
  friends,
}

enum LeaderboardCategory {
  totalXp,
  streaks,
  achievements,
  tradingPerformance,
  socialContribution,
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int rank;
  final int previousRank;
  final int score;
  final int level;
  final String title;
  final List<String> badges;
  final bool isCurrentUser;
  final DateTime lastActive;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.rank,
    this.previousRank = 0,
    required this.score,
    required this.level,
    required this.title,
    this.badges = const [],
    this.isCurrentUser = false,
    required this.lastActive,
  });

  int get rankChange => previousRank != 0 ? previousRank - rank : 0;
  bool get hasRankImproved => rankChange > 0;
  bool get hasRankDeclined => rankChange < 0;
  bool get isNewEntry => previousRank == 0;

  LeaderboardEntry copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    int? rank,
    int? previousRank,
    int? score,
    int? level,
    String? title,
    List<String>? badges,
    bool? isCurrentUser,
    DateTime? lastActive,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rank: rank ?? this.rank,
      previousRank: previousRank ?? this.previousRank,
      score: score ?? this.score,
      level: level ?? this.level,
      title: title ?? this.title,
      badges: badges ?? this.badges,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'avatarUrl': avatarUrl,
    'rank': rank,
    'previousRank': previousRank,
    'score': score,
    'level': level,
    'title': title,
    'badges': badges,
    'isCurrentUser': isCurrentUser,
    'lastActive': lastActive.toIso8601String(),
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
    userId: json['userId'],
    username: json['username'],
    avatarUrl: json['avatarUrl'],
    rank: json['rank'],
    previousRank: json['previousRank'] ?? 0,
    score: json['score'],
    level: json['level'],
    title: json['title'],
    badges: List<String>.from(json['badges'] ?? []),
    isCurrentUser: json['isCurrentUser'] ?? false,
    lastActive: DateTime.parse(json['lastActive']),
  );
}

class LeaderboardData {
  final LeaderboardType type;
  final LeaderboardCategory category;
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;
  final int totalParticipants;
  final LeaderboardEntry? currentUserEntry;

  const LeaderboardData({
    required this.type,
    required this.category,
    required this.entries,
    required this.lastUpdated,
    required this.totalParticipants,
    this.currentUserEntry,
  });

  List<LeaderboardEntry> get topThree => entries.take(3).toList();
  
  LeaderboardEntry? get winner => entries.isNotEmpty ? entries.first : null;
  
  List<LeaderboardEntry> get restOfEntries => 
      entries.length > 3 ? entries.skip(3).toList() : [];

  LeaderboardData copyWith({
    LeaderboardType? type,
    LeaderboardCategory? category,
    List<LeaderboardEntry>? entries,
    DateTime? lastUpdated,
    int? totalParticipants,
    LeaderboardEntry? currentUserEntry,
  }) {
    return LeaderboardData(
      type: type ?? this.type,
      category: category ?? this.category,
      entries: entries ?? this.entries,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      currentUserEntry: currentUserEntry ?? this.currentUserEntry,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'category': category.name,
    'entries': entries.map((e) => e.toJson()).toList(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'totalParticipants': totalParticipants,
    'currentUserEntry': currentUserEntry?.toJson(),
  };

  factory LeaderboardData.fromJson(Map<String, dynamic> json) => LeaderboardData(
    type: LeaderboardType.values.byName(json['type']),
    category: LeaderboardCategory.values.byName(json['category']),
    entries: (json['entries'] as List)
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList(),
    lastUpdated: DateTime.parse(json['lastUpdated']),
    totalParticipants: json['totalParticipants'],
    currentUserEntry: json['currentUserEntry'] != null 
        ? LeaderboardEntry.fromJson(json['currentUserEntry'])
        : null,
  );
}

class MockLeaderboardData {
  static List<LeaderboardEntry> generateMockEntries({
    int count = 20,
    String currentUserId = 'current_user',
  }) {
    final usernames = [
      'CryptoKing', 'TradeWizard', 'FinanceGuru', 'InvestorPro', 'MarketMaster',
      'TradingNinja', 'BullRunner', 'ChartExpert', 'RiskTaker', 'ProfitSeeker',
      'DiamondHands', 'MoonTrader', 'PortfolioHero', 'MarketAnalyst', 'StockSage',
      'TrendFollower', 'ValueHunter', 'TechnicalPro', 'SwingMaster', 'DayTrader',
    ];

    final titles = [
      'Village Apprentice', 'Town Scholar', 'City Merchant', 'Kingdom Trader',
      'Master Investor', 'Financial Lord'
    ];

    final badges = [
      'streak_master', 'achievement_hunter', 'social_butterfly', 'risk_manager',
      'profit_maker', 'early_bird', 'night_owl', 'weekend_warrior'
    ];

    return List.generate(count, (index) {
      final score = 10000 - (index * 250) + (index * 10); // Slight variance
      final level = (score / 500).floor() + 1;
      final isCurrentUser = index == 7; // Put current user at rank 8
      
      return LeaderboardEntry(
        userId: isCurrentUser ? currentUserId : 'user_${index + 1}',
        username: isCurrentUser ? 'You' : usernames[index % usernames.length],
        rank: index + 1,
        previousRank: index > 0 ? index + (index % 3 == 0 ? -1 : index % 5 == 0 ? 1 : 0) : 1,
        score: score,
        level: level,
        title: titles[(level - 1).clamp(0, titles.length - 1)],
        badges: [
          badges[index % badges.length],
          if (index < 5) badges[(index + 1) % badges.length],
        ],
        isCurrentUser: isCurrentUser,
        lastActive: DateTime.now().subtract(Duration(hours: index % 24)),
      );
    });
  }

  static LeaderboardData createMockLeaderboard({
    LeaderboardType type = LeaderboardType.weekly,
    LeaderboardCategory category = LeaderboardCategory.totalXp,
    int entryCount = 20,
  }) {
    final entries = generateMockEntries(count: entryCount);
    final currentUser = entries.firstWhere((e) => e.isCurrentUser);
    
    return LeaderboardData(
      type: type,
      category: category,
      entries: entries,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
      totalParticipants: entryCount + 100, // More participants than shown
      currentUserEntry: currentUser,
    );
  }
}