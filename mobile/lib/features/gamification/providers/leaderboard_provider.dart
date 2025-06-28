import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/leaderboard_system.dart';

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier() : super(const LeaderboardState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load mock data for now
    final mockData = MockLeaderboardData.createMockLeaderboard();
    state = state.copyWith(
      currentLeaderboard: mockData,
      isLoading: false,
    );
  }

  Future<void> refreshLeaderboard() async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final updatedData = MockLeaderboardData.createMockLeaderboard(
      type: state.selectedType,
      category: state.selectedCategory,
    );
    
    state = state.copyWith(
      currentLeaderboard: updatedData,
      isLoading: false,
      lastRefresh: DateTime.now(),
    );
  }

  void changeType(LeaderboardType type) {
    if (state.selectedType != type) {
      state = state.copyWith(
        selectedType: type,
        isLoading: true,
      );
      _loadLeaderboardData();
    }
  }

  void changeCategory(LeaderboardCategory category) {
    if (state.selectedCategory != category) {
      state = state.copyWith(
        selectedCategory: category,
        isLoading: true,
      );
      _loadLeaderboardData();
    }
  }

  Future<void> _loadLeaderboardData() async {
    // Simulate API call with delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final newData = MockLeaderboardData.createMockLeaderboard(
      type: state.selectedType,
      category: state.selectedCategory,
    );
    
    state = state.copyWith(
      currentLeaderboard: newData,
      isLoading: false,
    );
  }

  List<LeaderboardEntry> getCurrentUserHistory() {
    // Mock user history for rank changes
    return List.generate(30, (index) {
      final daysAgo = 29 - index;
      final baseRank = 8;
      final variance = (index % 7) - 3; // -3 to +3 variance
      
      return LeaderboardEntry(
        userId: 'current_user',
        username: 'You',
        rank: (baseRank + variance).clamp(1, 50),
        score: 10000 - (daysAgo * 50) + (index * 25),
        level: ((10000 - (daysAgo * 50)) / 500).floor() + 1,
        title: 'Town Scholar',
        isCurrentUser: true,
        lastActive: DateTime.now().subtract(Duration(days: daysAgo)),
      );
    });
  }

  Map<String, dynamic> getLeaderboardStats() {
    final leaderboard = state.currentLeaderboard;
    if (leaderboard == null) return {};
    
    final currentUser = leaderboard.currentUserEntry;
    final topThree = leaderboard.topThree;
    
    return {
      'currentUserRank': currentUser?.rank ?? 0,
      'currentUserScore': currentUser?.score ?? 0,
      'totalParticipants': leaderboard.totalParticipants,
      'topScore': topThree.isNotEmpty ? topThree.first.score : 0,
      'averageScore': _calculateAverageScore(leaderboard.entries),
      'userPercentile': _calculatePercentile(currentUser, leaderboard),
      'lastUpdated': leaderboard.lastUpdated,
    };
  }

  double _calculateAverageScore(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) return 0.0;
    final total = entries.fold(0, (sum, entry) => sum + entry.score);
    return total / entries.length;
  }

  double _calculatePercentile(LeaderboardEntry? user, LeaderboardData leaderboard) {
    if (user == null || leaderboard.totalParticipants == 0) return 0.0;
    
    final betterThanCount = leaderboard.totalParticipants - user.rank;
    return (betterThanCount / leaderboard.totalParticipants) * 100;
  }

  void simulateRankChange(String userId, int newRank) {
    final currentData = state.currentLeaderboard;
    if (currentData == null) return;
    
    final updatedEntries = currentData.entries.map((entry) {
      if (entry.userId == userId) {
        return entry.copyWith(
          previousRank: entry.rank,
          rank: newRank,
        );
      }
      return entry;
    }).toList();
    
    // Re-sort by rank
    updatedEntries.sort((a, b) => a.rank.compareTo(b.rank));
    
    final updatedData = currentData.copyWith(
      entries: updatedEntries,
      lastUpdated: DateTime.now(),
    );
    
    state = state.copyWith(currentLeaderboard: updatedData);
  }

  void addScoreToUser(String userId, int additionalScore) {
    final currentData = state.currentLeaderboard;
    if (currentData == null) return;
    
    final updatedEntries = currentData.entries.map((entry) {
      if (entry.userId == userId) {
        return entry.copyWith(score: entry.score + additionalScore);
      }
      return entry;
    }).toList();
    
    // Re-sort by score (descending) and update ranks
    updatedEntries.sort((a, b) => b.score.compareTo(a.score));
    for (int i = 0; i < updatedEntries.length; i++) {
      updatedEntries[i] = updatedEntries[i].copyWith(
        previousRank: updatedEntries[i].rank,
        rank: i + 1,
      );
    }
    
    final updatedData = currentData.copyWith(
      entries: updatedEntries,
      lastUpdated: DateTime.now(),
    );
    
    state = state.copyWith(currentLeaderboard: updatedData);
  }

  // Social features
  Future<void> followUser(String userId) async {
    // Implement follow functionality
    state = state.copyWith(
      followedUsers: [...state.followedUsers, userId],
    );
  }

  Future<void> unfollowUser(String userId) async {
    state = state.copyWith(
      followedUsers: state.followedUsers.where((id) => id != userId).toList(),
    );
  }

  bool isUserFollowed(String userId) {
    return state.followedUsers.contains(userId);
  }

  List<LeaderboardEntry> getFriendsLeaderboard() {
    final currentData = state.currentLeaderboard;
    if (currentData == null) return [];
    
    return currentData.entries
        .where((entry) => 
            entry.isCurrentUser || 
            state.followedUsers.contains(entry.userId))
        .toList();
  }
}

class LeaderboardState {
  final LeaderboardData? currentLeaderboard;
  final LeaderboardType selectedType;
  final LeaderboardCategory selectedCategory;
  final bool isLoading;
  final DateTime? lastRefresh;
  final List<String> followedUsers;
  final String? error;

  const LeaderboardState({
    this.currentLeaderboard,
    this.selectedType = LeaderboardType.weekly,
    this.selectedCategory = LeaderboardCategory.totalXp,
    this.isLoading = true,
    this.lastRefresh,
    this.followedUsers = const [],
    this.error,
  });

  LeaderboardState copyWith({
    LeaderboardData? currentLeaderboard,
    LeaderboardType? selectedType,
    LeaderboardCategory? selectedCategory,
    bool? isLoading,
    DateTime? lastRefresh,
    List<String>? followedUsers,
    String? error,
  }) {
    return LeaderboardState(
      currentLeaderboard: currentLeaderboard ?? this.currentLeaderboard,
      selectedType: selectedType ?? this.selectedType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      followedUsers: followedUsers ?? this.followedUsers,
      error: error ?? this.error,
    );
  }
}

// Providers
final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier();
});

final currentLeaderboardProvider = Provider<LeaderboardData?>((ref) {
  return ref.watch(leaderboardProvider).currentLeaderboard;
});

final topThreeProvider = Provider<List<LeaderboardEntry>>((ref) {
  final leaderboard = ref.watch(currentLeaderboardProvider);
  return leaderboard?.topThree ?? [];
});

final currentUserRankProvider = Provider<int?>((ref) {
  final leaderboard = ref.watch(currentLeaderboardProvider);
  return leaderboard?.currentUserEntry?.rank;
});

final leaderboardStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(leaderboardProvider.notifier);
  return notifier.getLeaderboardStats();
});

final friendsLeaderboardProvider = Provider<List<LeaderboardEntry>>((ref) {
  final notifier = ref.read(leaderboardProvider.notifier);
  return notifier.getFriendsLeaderboard();
});

final userRankHistoryProvider = Provider<List<LeaderboardEntry>>((ref) {
  final notifier = ref.read(leaderboardProvider.notifier);
  return notifier.getCurrentUserHistory();
});