import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/collection_system.dart';

class CollectionNotifier extends StateNotifier<CollectionState> {
  CollectionNotifier() : super(const CollectionState()) {
    _loadInitialCollection();
  }

  void _loadInitialCollection() {
    final mockData = MockCollectionData.createMockCollection();
    state = state.copyWith(
      collectionData: mockData,
      isLoading: false,
    );
  }

  Future<void> refreshCollection() async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final updatedData = MockCollectionData.createMockCollection();
    state = state.copyWith(
      collectionData: updatedData,
      isLoading: false,
      lastRefresh: DateTime.now(),
    );
  }

  void unlockItem(String itemId) {
    final currentData = state.collectionData;
    if (currentData == null) return;
    
    final updatedItems = currentData.items.map((item) {
      if (item.id == itemId && item.isLocked) {
        final unlockedItem = item.copyWith(
          isLocked: false,
          unlockedAt: DateTime.now(),
        );
        
        // Add to recent unlocks
        state = state.copyWith(
          recentUnlocks: [...state.recentUnlocks, unlockedItem],
        );
        
        return unlockedItem;
      }
      return item;
    }).toList();
    
    final updatedData = currentData.copyWith(
      items: updatedItems,
      lastUpdated: DateTime.now(),
    );
    
    state = state.copyWith(collectionData: updatedData);
    
    // Check for completed sets
    _checkCompletedSets();
  }

  void _checkCompletedSets() {
    final currentData = state.collectionData;
    if (currentData == null) return;
    
    final newlyCompletedSets = <CollectionSet>[];
    
    for (final set in currentData.sets) {
      final wasCompleted = state.completedSets.contains(set.name);
      final isNowCompleted = set.isCompleted(currentData.items);
      
      if (!wasCompleted && isNowCompleted) {
        newlyCompletedSets.add(set);
      }
    }
    
    if (newlyCompletedSets.isNotEmpty) {
      state = state.copyWith(
        completedSets: [...state.completedSets, ...newlyCompletedSets.map((s) => s.name)],
        newlyCompletedSets: [...state.newlyCompletedSets, ...newlyCompletedSets],
      );
    }
  }

  void changeCategory(CollectionCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void changeSortOrder(CollectionSortOrder sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
  }

  void toggleShowLocked() {
    state = state.copyWith(showLocked: !state.showLocked);
  }

  void clearRecentUnlocks() {
    state = state.copyWith(recentUnlocks: []);
  }

  void clearNewlyCompletedSets() {
    state = state.copyWith(newlyCompletedSets: []);
  }

  List<CollectionItem> getFilteredItems() {
    final data = state.collectionData;
    if (data == null) return [];
    
    var items = data.items;
    
    // Filter by category
    if (state.selectedCategory != null) {
      items = items.where((item) => item.category == state.selectedCategory).toList();
    }
    
    // Filter by lock status
    if (!state.showLocked) {
      items = items.where((item) => item.isUnlocked).toList();
    }
    
    // Sort items
    switch (state.sortOrder) {
      case CollectionSortOrder.nameAsc:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case CollectionSortOrder.nameDesc:
        items.sort((a, b) => b.name.compareTo(a.name));
        break;
      case CollectionSortOrder.rarityAsc:
        items.sort((a, b) => a.rarity.index.compareTo(b.rarity.index));
        break;
      case CollectionSortOrder.rarityDesc:
        items.sort((a, b) => b.rarity.index.compareTo(a.rarity.index));
        break;
      case CollectionSortOrder.unlockedDate:
        items.sort((a, b) {
          if (a.unlockedAt == null && b.unlockedAt == null) return 0;
          if (a.unlockedAt == null) return 1;
          if (b.unlockedAt == null) return -1;
          return b.unlockedAt!.compareTo(a.unlockedAt!);
        });
        break;
      case CollectionSortOrder.category:
        items.sort((a, b) => a.category.index.compareTo(b.category.index));
        break;
    }
    
    return items;
  }

  List<CollectionSet> getAvailableSets() {
    final data = state.collectionData;
    if (data == null) return [];
    return data.sets;
  }

  Map<String, dynamic> getCollectionStats() {
    final data = state.collectionData;
    if (data == null) return {};
    
    final totalItems = data.items.length;
    final unlockedItems = data.unlockedItems.length;
    final completedSets = data.completedSets.length;
    final totalSets = data.sets.length;
    
    // Rarity breakdown
    final rarityBreakdown = <CollectionRarity, int>{};
    for (final rarity in CollectionRarity.values) {
      rarityBreakdown[rarity] = data.unlockedItems
          .where((item) => item.rarity == rarity)
          .length;
    }
    
    // Category breakdown
    final categoryBreakdown = <CollectionCategory, int>{};
    for (final category in CollectionCategory.values) {
      categoryBreakdown[category] = data.unlockedItems
          .where((item) => item.category == category)
          .length;
    }
    
    return {
      'totalItems': totalItems,
      'unlockedItems': unlockedItems,
      'completionPercentage': totalItems > 0 ? unlockedItems / totalItems : 0.0,
      'completedSets': completedSets,
      'totalSets': totalSets,
      'setCompletionPercentage': totalSets > 0 ? completedSets / totalSets : 0.0,
      'totalValue': data.totalValue,
      'rarityBreakdown': rarityBreakdown,
      'categoryBreakdown': categoryBreakdown,
      'recentUnlocks': state.recentUnlocks.length,
    };
  }

  void simulateItemUnlock(CollectionRarity rarity) {
    final data = state.collectionData;
    if (data == null) return;
    
    // Find a locked item of the specified rarity
    final lockedItems = data.items
        .where((item) => item.isLocked && item.rarity == rarity)
        .toList();
    
    if (lockedItems.isNotEmpty) {
      final randomItem = lockedItems.first;
      unlockItem(randomItem.id);
    }
  }

  void simulateSetCompletion(String setName) {
    final data = state.collectionData;
    if (data == null) return;
    
    final set = data.sets.firstWhere(
      (s) => s.name == setName,
      orElse: () => data.sets.first,
    );
    
    // Unlock all items in the set
    for (final itemId in set.itemIds) {
      unlockItem(itemId);
    }
  }

  // Search functionality
  List<CollectionItem> searchItems(String query) {
    final data = state.collectionData;
    if (data == null || query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    
    return data.items.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
             item.description.toLowerCase().contains(lowercaseQuery) ||
             item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Favorites functionality
  void toggleFavorite(String itemId) {
    final favorites = Set<String>.from(state.favoriteItems);
    
    if (favorites.contains(itemId)) {
      favorites.remove(itemId);
    } else {
      favorites.add(itemId);
    }
    
    state = state.copyWith(favoriteItems: favorites.toList());
  }

  bool isFavorite(String itemId) {
    return state.favoriteItems.contains(itemId);
  }

  List<CollectionItem> getFavoriteItems() {
    final data = state.collectionData;
    if (data == null) return [];
    
    return data.items
        .where((item) => state.favoriteItems.contains(item.id))
        .toList();
  }
}

enum CollectionSortOrder {
  nameAsc,
  nameDesc,
  rarityAsc,
  rarityDesc,
  unlockedDate,
  category,
}

class CollectionState {
  final CollectionData? collectionData;
  final CollectionCategory? selectedCategory;
  final CollectionSortOrder sortOrder;
  final bool showLocked;
  final bool isLoading;
  final DateTime? lastRefresh;
  final List<CollectionItem> recentUnlocks;
  final List<String> completedSets;
  final List<CollectionSet> newlyCompletedSets;
  final List<String> favoriteItems;
  final String? error;

  const CollectionState({
    this.collectionData,
    this.selectedCategory,
    this.sortOrder = CollectionSortOrder.unlockedDate,
    this.showLocked = true,
    this.isLoading = true,
    this.lastRefresh,
    this.recentUnlocks = const [],
    this.completedSets = const [],
    this.newlyCompletedSets = const [],
    this.favoriteItems = const [],
    this.error,
  });

  CollectionState copyWith({
    CollectionData? collectionData,
    CollectionCategory? selectedCategory,
    CollectionSortOrder? sortOrder,
    bool? showLocked,
    bool? isLoading,
    DateTime? lastRefresh,
    List<CollectionItem>? recentUnlocks,
    List<String>? completedSets,
    List<CollectionSet>? newlyCompletedSets,
    List<String>? favoriteItems,
    String? error,
  }) {
    return CollectionState(
      collectionData: collectionData ?? this.collectionData,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortOrder: sortOrder ?? this.sortOrder,
      showLocked: showLocked ?? this.showLocked,
      isLoading: isLoading ?? this.isLoading,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      recentUnlocks: recentUnlocks ?? this.recentUnlocks,
      completedSets: completedSets ?? this.completedSets,
      newlyCompletedSets: newlyCompletedSets ?? this.newlyCompletedSets,
      favoriteItems: favoriteItems ?? this.favoriteItems,
      error: error ?? this.error,
    );
  }
}

// Providers
final collectionProvider = StateNotifierProvider<CollectionNotifier, CollectionState>((ref) {
  return CollectionNotifier();
});

final currentCollectionProvider = Provider<CollectionData?>((ref) {
  return ref.watch(collectionProvider).collectionData;
});

final filteredItemsProvider = Provider<List<CollectionItem>>((ref) {
  final notifier = ref.read(collectionProvider.notifier);
  return notifier.getFilteredItems();
});

final collectionSetsProvider = Provider<List<CollectionSet>>((ref) {
  final notifier = ref.read(collectionProvider.notifier);
  return notifier.getAvailableSets();
});

final collectionStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(collectionProvider.notifier);
  return notifier.getCollectionStats();
});

final recentUnlocksProvider = Provider<List<CollectionItem>>((ref) {
  return ref.watch(collectionProvider).recentUnlocks;
});

final newlyCompletedSetsProvider = Provider<List<CollectionSet>>((ref) {
  return ref.watch(collectionProvider).newlyCompletedSets;
});

final favoriteItemsProvider = Provider<List<CollectionItem>>((ref) {
  final notifier = ref.read(collectionProvider.notifier);
  return notifier.getFavoriteItems();
});