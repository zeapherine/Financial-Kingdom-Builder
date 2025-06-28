import '../../../kingdom/domain/models/kingdom_state.dart';

/// Types of educational milestones that can be tracked
enum MilestoneType {
  lessonCompletion,
  moduleCompletion,
  quizPassing,
  skillMastery,
  certificateEarning,
  practicalApplication,
  timeBasedProgress,
  streakAchievement,
}

/// Individual educational milestone definition
class EducationalMilestone {
  final String id;
  final String title;
  final String description;
  final MilestoneType type;
  final KingdomTier requiredTier;
  final int xpReward;
  final List<String> prerequisites;
  final Map<String, dynamic> criteria;
  final bool isRequired;
  final Duration? timeLimit;
  final String category;

  const EducationalMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requiredTier,
    required this.xpReward,
    required this.prerequisites,
    required this.criteria,
    required this.isRequired,
    this.timeLimit,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'requiredTier': requiredTier.name,
      'xpReward': xpReward,
      'prerequisites': prerequisites,
      'criteria': criteria,
      'isRequired': isRequired,
      'timeLimit': timeLimit?.inMilliseconds,
      'category': category,
    };
  }

  static EducationalMilestone fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final type = MilestoneType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => MilestoneType.lessonCompletion,
    );

    final tierName = json['requiredTier'] as String;
    final tier = KingdomTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => KingdomTier.village,
    );

    final timeLimitMs = json['timeLimit'] as int?;
    final timeLimit = timeLimitMs != null ? Duration(milliseconds: timeLimitMs) : null;

    return EducationalMilestone(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: type,
      requiredTier: tier,
      xpReward: json['xpReward'] as int,
      prerequisites: List<String>.from(json['prerequisites'] as List),
      criteria: Map<String, dynamic>.from(json['criteria'] as Map),
      isRequired: json['isRequired'] as bool,
      timeLimit: timeLimit,
      category: json['category'] as String,
    );
  }
}

/// User's progress on a specific milestone
class MilestoneProgress {
  final String milestoneId;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime startedAt;
  final double progressPercentage;
  final Map<String, dynamic> progressData;
  final List<String> completedSteps;
  final String? failureReason;

  const MilestoneProgress({
    required this.milestoneId,
    required this.isCompleted,
    this.completedAt,
    required this.startedAt,
    required this.progressPercentage,
    required this.progressData,
    required this.completedSteps,
    this.failureReason,
  });

  MilestoneProgress copyWith({
    String? milestoneId,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? startedAt,
    double? progressPercentage,
    Map<String, dynamic>? progressData,
    List<String>? completedSteps,
    String? failureReason,
  }) {
    return MilestoneProgress(
      milestoneId: milestoneId ?? this.milestoneId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      startedAt: startedAt ?? this.startedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      progressData: progressData ?? this.progressData,
      completedSteps: completedSteps ?? this.completedSteps,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestoneId': milestoneId,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'startedAt': startedAt.toIso8601String(),
      'progressPercentage': progressPercentage,
      'progressData': progressData,
      'completedSteps': completedSteps,
      'failureReason': failureReason,
    };
  }

  static MilestoneProgress fromJson(Map<String, dynamic> json) {
    final completedAtStr = json['completedAt'] as String?;
    final completedAt = completedAtStr != null ? DateTime.parse(completedAtStr) : null;

    return MilestoneProgress(
      milestoneId: json['milestoneId'] as String,
      isCompleted: json['isCompleted'] as bool,
      completedAt: completedAt,
      startedAt: DateTime.parse(json['startedAt'] as String),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      progressData: Map<String, dynamic>.from(json['progressData'] as Map),
      completedSteps: List<String>.from(json['completedSteps'] as List),
      failureReason: json['failureReason'] as String?,
    );
  }
}

/// Educational milestone tracking system
class EducationalMilestoneSystem {
  /// All available educational milestones organized by tier
  static final Map<KingdomTier, List<EducationalMilestone>> _tierMilestones = {
    // Village Tier Milestones (Tier 1)
    KingdomTier.village: [
      EducationalMilestone(
        id: 'financial_literacy_basics',
        title: 'Financial Literacy Foundation',
        description: 'Complete basic financial literacy modules',
        type: MilestoneType.moduleCompletion,
        requiredTier: KingdomTier.village,
        xpReward: 100,
        prerequisites: [],
        criteria: {
          'modulesRequired': 3,
          'minimumScore': 80,
          'topics': ['budgeting', 'saving', 'debt_management'],
        },
        isRequired: true,
        category: 'Financial Literacy',
      ),
      EducationalMilestone(
        id: 'first_virtual_trade',
        title: 'First Virtual Trade',
        description: 'Execute your first virtual trade successfully',
        type: MilestoneType.practicalApplication,
        requiredTier: KingdomTier.village,
        xpReward: 50,
        prerequisites: ['financial_literacy_basics'],
        criteria: {
          'tradesRequired': 1,
          'virtual': true,
          'successful': true,
        },
        isRequired: true,
        category: 'Trading',
      ),
      EducationalMilestone(
        id: 'seven_day_streak',
        title: 'Seven Day Learning Streak',
        description: 'Maintain 7 consecutive days of learning activity',
        type: MilestoneType.streakAchievement,
        requiredTier: KingdomTier.village,
        xpReward: 75,
        prerequisites: [],
        criteria: {
          'streakDays': 7,
          'activitiesPerDay': 1,
        },
        isRequired: true,
        timeLimit: Duration(days: 14),
        category: 'Engagement',
      ),
      EducationalMilestone(
        id: 'risk_awareness_quiz',
        title: 'Risk Awareness Certification',
        description: 'Pass the basic risk awareness quiz',
        type: MilestoneType.quizPassing,
        requiredTier: KingdomTier.village,
        xpReward: 60,
        prerequisites: ['financial_literacy_basics'],
        criteria: {
          'minimumScore': 85,
          'maxAttempts': 3,
          'topics': ['risk_tolerance', 'diversification', 'loss_acceptance'],
        },
        isRequired: true,
        category: 'Risk Management',
      ),
      EducationalMilestone(
        id: 'portfolio_simulator',
        title: 'Portfolio Building Simulation',
        description: 'Build and manage a virtual portfolio for 14 days',
        type: MilestoneType.practicalApplication,
        requiredTier: KingdomTier.village,
        xpReward: 90,
        prerequisites: ['first_virtual_trade', 'risk_awareness_quiz'],
        criteria: {
          'durationDays': 14,
          'minimumAssets': 3,
          'maxLoss': 0.10, // Max 10% loss
          'dailyCheckins': 10, // At least 10 days of activity
        },
        isRequired: true,
        timeLimit: Duration(days: 21),
        category: 'Portfolio Management',
      ),
    ],

    // Town Tier Milestones (Tier 2)
    KingdomTier.town: [
      EducationalMilestone(
        id: 'advanced_risk_management',
        title: 'Advanced Risk Management',
        description: 'Master advanced risk management concepts',
        type: MilestoneType.moduleCompletion,
        requiredTier: KingdomTier.town,
        xpReward: 150,
        prerequisites: ['risk_awareness_quiz'],
        criteria: {
          'modulesRequired': 5,
          'minimumScore': 85,
          'topics': ['position_sizing', 'stop_losses', 'risk_reward_ratios', 'correlation', 'volatility'],
        },
        isRequired: true,
        category: 'Risk Management',
      ),
      EducationalMilestone(
        id: 'stop_loss_mastery',
        title: 'Stop Loss Implementation',
        description: 'Successfully use stop losses in 10 trades',
        type: MilestoneType.practicalApplication,
        requiredTier: KingdomTier.town,
        xpReward: 100,
        prerequisites: ['advanced_risk_management'],
        criteria: {
          'tradesWithStopLoss': 10,
          'stopLossHitRate': 0.0, // Stop losses should NOT be hit frequently
          'successfulPreventions': 2, // At least 2 times stop loss prevented major loss
        },
        isRequired: true,
        category: 'Trading',
      ),
      EducationalMilestone(
        id: 'real_money_readiness',
        title: 'Real Money Trading Readiness',
        description: 'Pass comprehensive assessment for real money trading',
        type: MilestoneType.certificateEarning,
        requiredTier: KingdomTier.town,
        xpReward: 200,
        prerequisites: ['advanced_risk_management', 'stop_loss_mastery'],
        criteria: {
          'quizScore': 90,
          'practicalAssessment': true,
          'riskToleranceAssessment': true,
          'psychologyEvaluation': true,
        },
        isRequired: true,
        category: 'Certification',
      ),
      EducationalMilestone(
        id: 'capital_preservation',
        title: 'Capital Preservation Expert',
        description: 'Maintain 90%+ of capital over 30 days of trading',
        type: MilestoneType.practicalApplication,
        requiredTier: KingdomTier.town,
        xpReward: 120,
        prerequisites: ['real_money_readiness'],
        criteria: {
          'durationDays': 30,
          'minCapitalRetention': 0.90,
          'realMoney': true,
          'minimumTrades': 5,
        },
        isRequired: true,
        timeLimit: Duration(days: 45),
        category: 'Performance',
      ),
    ],

    // City Tier Milestones (Tier 3)
    KingdomTier.city: [
      EducationalMilestone(
        id: 'technical_analysis_mastery',
        title: 'Technical Analysis Mastery',
        description: 'Master advanced technical analysis techniques',
        type: MilestoneType.moduleCompletion,
        requiredTier: KingdomTier.city,
        xpReward: 200,
        prerequisites: ['capital_preservation'],
        criteria: {
          'modulesRequired': 8,
          'minimumScore': 85,
          'topics': ['chart_patterns', 'indicators', 'fibonacci', 'elliott_wave', 'volume_analysis'],
        },
        isRequired: true,
        category: 'Technical Analysis',
      ),
      EducationalMilestone(
        id: 'options_education',
        title: 'Options Trading Foundation',
        description: 'Complete comprehensive options education',
        type: MilestoneType.moduleCompletion,
        requiredTier: KingdomTier.city,
        xpReward: 250,
        prerequisites: ['technical_analysis_mastery'],
        criteria: {
          'modulesRequired': 10,
          'minimumScore': 90,
          'topics': ['calls', 'puts', 'spreads', 'greeks', 'strategies'],
          'simulationTrades': 15,
        },
        isRequired: true,
        category: 'Options',
      ),
      EducationalMilestone(
        id: 'portfolio_optimization',
        title: 'Portfolio Optimization',
        description: 'Demonstrate advanced portfolio management skills',
        type: MilestoneType.practicalApplication,
        requiredTier: KingdomTier.city,
        xpReward: 180,
        prerequisites: ['options_education'],
        criteria: {
          'portfolioValue': 5000.0,
          'assetDiversification': 5,
          'riskAdjustedReturn': 0.15, // 15% risk-adjusted return
          'maxDrawdown': 0.15, // Max 15% drawdown
          'durationDays': 60,
        },
        isRequired: true,
        timeLimit: Duration(days: 90),
        category: 'Portfolio Management',
      ),
      EducationalMilestone(
        id: 'margin_trading_certification',
        title: 'Margin Trading Certification',
        description: 'Pass comprehensive margin trading assessment',
        type: MilestoneType.certificateEarning,
        requiredTier: KingdomTier.city,
        xpReward: 220,
        prerequisites: ['portfolio_optimization'],
        criteria: {
          'marginQuizScore': 95,
          'riskAssessment': true,
          'leverageUnderstanding': true,
          'liquidationPrevention': true,
        },
        isRequired: true,
        category: 'Certification',
      ),
    ],

    // Kingdom Tier Milestones (Tier 4)
    KingdomTier.kingdom: [
      EducationalMilestone(
        id: 'derivatives_mastery',
        title: 'Advanced Derivatives Mastery',
        description: 'Master complex derivatives trading',
        type: MilestoneType.moduleCompletion,
        requiredTier: KingdomTier.kingdom,
        xpReward: 300,
        prerequisites: ['margin_trading_certification'],
        criteria: {
          'modulesRequired': 12,
          'minimumScore': 90,
          'topics': ['futures', 'perpetuals', 'swaps', 'exotic_options', 'structured_products'],
        },
        isRequired: true,
        category: 'Derivatives',
      ),
      EducationalMilestone(
        id: 'perpetuals_certification',
        title: 'Perpetuals Trading Certification',
        description: 'Complete advanced perpetuals trading program',
        type: MilestoneType.certificateEarning,
        requiredTier: KingdomTier.kingdom,
        xpReward: 350,
        prerequisites: ['derivatives_mastery'],
        criteria: {
          'perpetualsQuizScore': 95,
          'leverageManagement': true,
          'fundingRateUnderstanding': true,
          'liquidationPrevention': true,
          'starknetOptimization': true,
        },
        isRequired: true,
        category: 'Certification',
      ),
      EducationalMilestone(
        id: 'risk_management_expert',
        title: 'Risk Management Expert',
        description: 'Demonstrate expert-level risk management',
        type: MilestoneType.practicalApplication,
        requiredTier: KingdomTier.kingdom,
        xpReward: 400,
        prerequisites: ['perpetuals_certification'],
        criteria: {
          'portfolioValue': 25000.0,
          'maxLeverage': 5.0,
          'riskAdjustedReturn': 0.25, // 25% risk-adjusted return
          'maxDrawdown': 0.10, // Max 10% drawdown
          'durationDays': 90,
          'volatilityManagement': true,
        },
        isRequired: true,
        timeLimit: Duration(days: 120),
        category: 'Risk Management',
      ),
      EducationalMilestone(
        id: 'community_leadership',
        title: 'Community Leadership',
        description: 'Demonstrate leadership in the trading community',
        type: MilestoneType.practicalApplication,
        requiredTier: KingdomTier.kingdom,
        xpReward: 250,
        prerequisites: ['risk_management_expert'],
        criteria: {
          'mentorStudents': 3,
          'communityContributions': 10,
          'helpfulVotes': 50,
          'qualityContent': 5,
        },
        isRequired: false,
        category: 'Social',
      ),
    ],
  };

  /// Get milestones for a specific tier
  static List<EducationalMilestone> getMilestonesForTier(KingdomTier tier) {
    return _tierMilestones[tier] ?? [];
  }

  /// Get all milestones up to and including a tier
  static List<EducationalMilestone> getMilestonesUpToTier(KingdomTier tier) {
    final List<EducationalMilestone> milestones = [];
    final tiers = KingdomTier.values;
    final tierIndex = tiers.indexOf(tier);
    
    for (int i = 0; i <= tierIndex; i++) {
      milestones.addAll(getMilestonesForTier(tiers[i]));
    }
    
    return milestones;
  }

  /// Get required milestones for tier progression
  static List<EducationalMilestone> getRequiredMilestonesForTier(KingdomTier tier) {
    return getMilestonesForTier(tier).where((milestone) => milestone.isRequired).toList();
  }

  /// Check if a milestone's prerequisites are met
  static bool arePrerequisitesMet(String milestoneId, List<String> completedMilestones) {
    final milestone = _findMilestoneById(milestoneId);
    if (milestone == null) return false;
    
    return milestone.prerequisites.every((prerequisite) => completedMilestones.contains(prerequisite));
  }

  /// Check if milestone can be started given current tier and completed milestones
  static bool canStartMilestone(String milestoneId, KingdomTier currentTier, List<String> completedMilestones) {
    final milestone = _findMilestoneById(milestoneId);
    if (milestone == null) return false;
    
    // Check tier requirement
    final tiers = KingdomTier.values;
    final currentTierIndex = tiers.indexOf(currentTier);
    final requiredTierIndex = tiers.indexOf(milestone.requiredTier);
    
    if (currentTierIndex < requiredTierIndex) return false;
    
    // Check prerequisites
    return arePrerequisitesMet(milestoneId, completedMilestones);
  }

  /// Find milestone by ID
  static EducationalMilestone? _findMilestoneById(String milestoneId) {
    for (final tierMilestones in _tierMilestones.values) {
      for (final milestone in tierMilestones) {
        if (milestone.id == milestoneId) return milestone;
      }
    }
    return null;
  }

  /// Get milestone by ID
  static EducationalMilestone? getMilestoneById(String milestoneId) {
    return _findMilestoneById(milestoneId);
  }

  /// Calculate milestone progress based on criteria and current data
  static double calculateMilestoneProgress(EducationalMilestone milestone, Map<String, dynamic> currentData) {
    double totalProgress = 0.0;
    int criteriaCount = 0;

    switch (milestone.type) {
      case MilestoneType.moduleCompletion:
        final modulesRequired = milestone.criteria['modulesRequired'] as int? ?? 1;
        final modulesCompleted = currentData['modulesCompleted'] as int? ?? 0;
        totalProgress += (modulesCompleted / modulesRequired).clamp(0.0, 1.0);
        criteriaCount++;
        
        final minimumScore = milestone.criteria['minimumScore'] as int? ?? 0;
        final currentScore = currentData['averageScore'] as int? ?? 0;
        if (minimumScore > 0) {
          totalProgress += (currentScore / minimumScore).clamp(0.0, 1.0);
          criteriaCount++;
        }
        break;

      case MilestoneType.quizPassing:
        final minimumScore = milestone.criteria['minimumScore'] as int? ?? 0;
        final currentScore = currentData['quizScore'] as int? ?? 0;
        totalProgress += (currentScore / minimumScore).clamp(0.0, 1.0);
        criteriaCount++;
        break;

      case MilestoneType.practicalApplication:
        if (milestone.criteria.containsKey('tradesRequired')) {
          final tradesRequired = milestone.criteria['tradesRequired'] as int? ?? 1;
          final tradesCompleted = currentData['tradesCompleted'] as int? ?? 0;
          totalProgress += (tradesCompleted / tradesRequired).clamp(0.0, 1.0);
          criteriaCount++;
        }
        
        if (milestone.criteria.containsKey('durationDays')) {
          final durationRequired = milestone.criteria['durationDays'] as int? ?? 1;
          final daysElapsed = currentData['daysElapsed'] as int? ?? 0;
          totalProgress += (daysElapsed / durationRequired).clamp(0.0, 1.0);
          criteriaCount++;
        }
        break;

      case MilestoneType.streakAchievement:
        final streakRequired = milestone.criteria['streakDays'] as int? ?? 1;
        final currentStreak = currentData['currentStreak'] as int? ?? 0;
        totalProgress += (currentStreak / streakRequired).clamp(0.0, 1.0);
        criteriaCount++;
        break;

      case MilestoneType.skillMastery:
      case MilestoneType.certificateEarning:
      case MilestoneType.lessonCompletion:
      case MilestoneType.timeBasedProgress:
        // These require custom logic based on specific criteria
        final completed = currentData['completed'] as bool? ?? false;
        totalProgress += completed ? 1.0 : 0.0;
        criteriaCount++;
        break;
    }

    return criteriaCount > 0 ? totalProgress / criteriaCount : 0.0;
  }

  /// Get all milestones
  static List<EducationalMilestone> getAllMilestones() {
    final List<EducationalMilestone> allMilestones = [];
    for (final tierMilestones in _tierMilestones.values) {
      allMilestones.addAll(tierMilestones);
    }
    return allMilestones;
  }

  /// Get milestones by category
  static List<EducationalMilestone> getMilestonesByCategory(String category) {
    return getAllMilestones().where((milestone) => milestone.category == category).toList();
  }

  /// Get all unique categories
  static List<String> getAllCategories() {
    final categories = <String>{};
    for (final milestone in getAllMilestones()) {
      categories.add(milestone.category);
    }
    return categories.toList()..sort();
  }
}