enum CollectionCategory {
  badges,
  cards,
  trophies,
  artifacts,
  skills,
  titles,
}

enum CollectionRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
}

enum CollectionItemType {
  achievement,
  milestone,
  special,
  seasonal,
  social,
  trading,
}

class CollectionItem {
  final String id;
  final String name;
  final String description;
  final CollectionCategory category;
  final CollectionRarity rarity;
  final CollectionItemType type;
  final String iconName;
  final List<String> tags;
  final DateTime? unlockedAt;
  final DateTime? expiresAt;
  final bool isLocked;
  final Map<String, dynamic> metadata;
  final String? setName; // For grouped collections

  const CollectionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.type,
    required this.iconName,
    this.tags = const [],
    this.unlockedAt,
    this.expiresAt,
    this.isLocked = true,
    this.metadata = const {},
    this.setName,
  });

  bool get isUnlocked => unlockedAt != null;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isActive => isUnlocked && !isExpired;
  bool get isTimeLimited => expiresAt != null;

  CollectionItem copyWith({
    String? id,
    String? name,
    String? description,
    CollectionCategory? category,
    CollectionRarity? rarity,
    CollectionItemType? type,
    String? iconName,
    List<String>? tags,
    DateTime? unlockedAt,
    DateTime? expiresAt,
    bool? isLocked,
    Map<String, dynamic>? metadata,
    String? setName,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      tags: tags ?? this.tags,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isLocked: isLocked ?? this.isLocked,
      metadata: metadata ?? this.metadata,
      setName: setName ?? this.setName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category.name,
    'rarity': rarity.name,
    'type': type.name,
    'iconName': iconName,
    'tags': tags,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'isLocked': isLocked,
    'metadata': metadata,
    'setName': setName,
  };

  factory CollectionItem.fromJson(Map<String, dynamic> json) => CollectionItem(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    category: CollectionCategory.values.byName(json['category']),
    rarity: CollectionRarity.values.byName(json['rarity']),
    type: CollectionItemType.values.byName(json['type']),
    iconName: json['iconName'],
    tags: List<String>.from(json['tags'] ?? []),
    unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    isLocked: json['isLocked'] ?? true,
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    setName: json['setName'],
  );
}

class CollectionSet {
  final String name;
  final String description;
  final List<String> itemIds;
  final CollectionRarity rarity;
  final String? bonusDescription;
  final Map<String, dynamic>? setBonusMetadata;

  const CollectionSet({
    required this.name,
    required this.description,
    required this.itemIds,
    required this.rarity,
    this.bonusDescription,
    this.setBonusMetadata,
  });

  bool isCompleted(List<CollectionItem> userItems) {
    final userItemIds = userItems.where((item) => item.isUnlocked).map((item) => item.id).toSet();
    return itemIds.every((id) => userItemIds.contains(id));
  }

  double getCompletionPercentage(List<CollectionItem> userItems) {
    final userItemIds = userItems.where((item) => item.isUnlocked).map((item) => item.id).toSet();
    final completedCount = itemIds.where((id) => userItemIds.contains(id)).length;
    return completedCount / itemIds.length;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'itemIds': itemIds,
    'rarity': rarity.name,
    'bonusDescription': bonusDescription,
    'setBonusMetadata': setBonusMetadata,
  };

  factory CollectionSet.fromJson(Map<String, dynamic> json) => CollectionSet(
    name: json['name'],
    description: json['description'],
    itemIds: List<String>.from(json['itemIds']),
    rarity: CollectionRarity.values.byName(json['rarity']),
    bonusDescription: json['bonusDescription'],
    setBonusMetadata: json['setBonusMetadata'] != null 
        ? Map<String, dynamic>.from(json['setBonusMetadata'])
        : null,
  );
}

class CollectionData {
  final List<CollectionItem> items;
  final List<CollectionSet> sets;
  final Map<CollectionCategory, int> categoryProgress;
  final Map<CollectionRarity, int> rarityBreakdown;
  final DateTime lastUpdated;

  const CollectionData({
    this.items = const [],
    this.sets = const [],
    this.categoryProgress = const {},
    this.rarityBreakdown = const {},
    required this.lastUpdated,
  });

  List<CollectionItem> get unlockedItems => 
      items.where((item) => item.isUnlocked).toList();

  List<CollectionItem> get lockedItems => 
      items.where((item) => item.isLocked).toList();

  List<CollectionSet> get completedSets => 
      sets.where((set) => set.isCompleted(items)).toList();

  double get overallCompletion => 
      items.isNotEmpty ? unlockedItems.length / items.length : 0.0;

  int get totalValue => unlockedItems.fold(0, (sum, item) => 
      sum + _getRarityValue(item.rarity));

  static int _getRarityValue(CollectionRarity rarity) {
    switch (rarity) {
      case CollectionRarity.common:
        return 1;
      case CollectionRarity.uncommon:
        return 3;
      case CollectionRarity.rare:
        return 5;
      case CollectionRarity.epic:
        return 10;
      case CollectionRarity.legendary:
        return 20;
      case CollectionRarity.mythic:
        return 50;
    }
  }

  CollectionData copyWith({
    List<CollectionItem>? items,
    List<CollectionSet>? sets,
    Map<CollectionCategory, int>? categoryProgress,
    Map<CollectionRarity, int>? rarityBreakdown,
    DateTime? lastUpdated,
  }) {
    return CollectionData(
      items: items ?? this.items,
      sets: sets ?? this.sets,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      rarityBreakdown: rarityBreakdown ?? this.rarityBreakdown,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MockCollectionData {
  static List<CollectionItem> generateMockItems() {
    final items = <CollectionItem>[];
    
    // Badge items
    items.addAll([
      const CollectionItem(
        id: 'first_steps',
        name: 'First Steps',
        description: 'Complete your first lesson',
        category: CollectionCategory.badges,
        rarity: CollectionRarity.common,
        type: CollectionItemType.achievement,
        iconName: 'directions_walk',
        isLocked: false,
        setName: 'Beginner Set',
      ),
      const CollectionItem(
        id: 'quick_learner',
        name: 'Quick Learner',
        description: 'Complete 5 lessons in one day',
        category: CollectionCategory.badges,
        rarity: CollectionRarity.uncommon,
        type: CollectionItemType.achievement,
        iconName: 'flash_on',
        isLocked: false,
        setName: 'Beginner Set',
      ),
      const CollectionItem(
        id: 'scholar',
        name: 'Scholar',
        description: 'Complete 50 lessons',
        category: CollectionCategory.badges,
        rarity: CollectionRarity.rare,
        type: CollectionItemType.milestone,
        iconName: 'school',
        isLocked: true,
        setName: 'Beginner Set',
      ),
    ]);
    
    // Trophy items
    items.addAll([
      const CollectionItem(
        id: 'trading_champion',
        name: 'Trading Champion',
        description: 'Win the weekly trading competition',
        category: CollectionCategory.trophies,
        rarity: CollectionRarity.epic,
        type: CollectionItemType.special,
        iconName: 'emoji_events',
        isLocked: true,
      ),
      const CollectionItem(
        id: 'streak_master',
        name: 'Streak Master',
        description: 'Maintain a 100-day streak',
        category: CollectionCategory.trophies,
        rarity: CollectionRarity.legendary,
        type: CollectionItemType.milestone,
        iconName: 'whatshot',
        isLocked: true,
      ),
    ]);
    
    // Card items (collectible trading cards)
    items.addAll([
      const CollectionItem(
        id: 'bull_market_card',
        name: 'Bull Market',
        description: 'Legendary market condition card',
        category: CollectionCategory.cards,
        rarity: CollectionRarity.legendary,
        type: CollectionItemType.special,
        iconName: 'trending_up',
        isLocked: false,
        metadata: {'power': 95, 'type': 'Market Condition'},
      ),
      const CollectionItem(
        id: 'diamond_hands_card',
        name: 'Diamond Hands',
        description: 'Epic trader trait card',
        category: CollectionCategory.cards,
        rarity: CollectionRarity.epic,
        type: CollectionItemType.trading,
        iconName: 'diamond',
        isLocked: true,
        metadata: {'power': 80, 'type': 'Trader Trait'},
      ),
    ]);
    
    // Skill items
    items.addAll([
      const CollectionItem(
        id: 'technical_analysis',
        name: 'Technical Analysis',
        description: 'Master chart reading and patterns',
        category: CollectionCategory.skills,
        rarity: CollectionRarity.rare,
        type: CollectionItemType.achievement,
        iconName: 'assessment',
        isLocked: false,
      ),
      const CollectionItem(
        id: 'risk_management',
        name: 'Risk Management',
        description: 'Expert in protecting capital',
        category: CollectionCategory.skills,
        rarity: CollectionRarity.epic,
        type: CollectionItemType.achievement,
        iconName: 'security',
        isLocked: true,
      ),
    ]);
    
    // Title items
    items.addAll([
      const CollectionItem(
        id: 'market_wizard',
        name: 'Market Wizard',
        description: 'A true master of the markets',
        category: CollectionCategory.titles,
        rarity: CollectionRarity.mythic,
        type: CollectionItemType.special,
        iconName: 'auto_awesome',
        isLocked: true,
      ),
    ]);
    
    // Artifact items
    items.addAll([
      const CollectionItem(
        id: 'golden_chart',
        name: 'Golden Chart',
        description: 'Ancient artifact of market wisdom',
        category: CollectionCategory.artifacts,
        rarity: CollectionRarity.legendary,
        type: CollectionItemType.special,
        iconName: 'show_chart',
        isLocked: true,
      ),
    ]);
    
    return items;
  }
  
  static List<CollectionSet> generateMockSets() {
    return [
      const CollectionSet(
        name: 'Beginner Set',
        description: 'Complete your first steps in trading',
        itemIds: ['first_steps', 'quick_learner', 'scholar'],
        rarity: CollectionRarity.common,
        bonusDescription: '+10% XP bonus for lessons',
      ),
      const CollectionSet(
        name: 'Trading Masters',
        description: 'Elite trading collection',
        itemIds: ['trading_champion', 'bull_market_card', 'diamond_hands_card'],
        rarity: CollectionRarity.epic,
        bonusDescription: '+25% trading XP bonus',
      ),
      const CollectionSet(
        name: 'Market Legends',
        description: 'The ultimate collection',
        itemIds: ['market_wizard', 'golden_chart', 'streak_master'],
        rarity: CollectionRarity.mythic,
        bonusDescription: 'Legendary status and exclusive features',
      ),
    ];
  }
  
  static CollectionData createMockCollection() {
    final items = generateMockItems();
    final sets = generateMockSets();
    
    // Simulate some unlocked items
    final unlockedItems = items.map((item) {
      if (['first_steps', 'quick_learner', 'technical_analysis', 'bull_market_card'].contains(item.id)) {
        return item.copyWith(
          isLocked: false,
          unlockedAt: DateTime.now().subtract(Duration(days: items.indexOf(item))),
        );
      }
      return item;
    }).toList();
    
    // Calculate progress
    final categoryProgress = <CollectionCategory, int>{};
    final rarityBreakdown = <CollectionRarity, int>{};
    
    for (final category in CollectionCategory.values) {
      final categoryItems = unlockedItems.where((item) => item.category == category);
      categoryProgress[category] = categoryItems.where((item) => item.isUnlocked).length;
    }
    
    for (final rarity in CollectionRarity.values) {
      final rarityItems = unlockedItems.where((item) => item.rarity == rarity);
      rarityBreakdown[rarity] = rarityItems.where((item) => item.isUnlocked).length;
    }
    
    return CollectionData(
      items: unlockedItems,
      sets: sets,
      categoryProgress: categoryProgress,
      rarityBreakdown: rarityBreakdown,
      lastUpdated: DateTime.now(),
    );
  }
}