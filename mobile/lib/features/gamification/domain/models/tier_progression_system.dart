import '../../../kingdom/domain/models/kingdom_state.dart';

/// Educational tier progression requirements and unlock system
/// Following PLANNING.md tier implementation guidelines
class TierProgressionRequirements {
  final KingdomTier tier;
  final String tierName;
  final String description;
  final int daysRequired;
  final int minimumXp;
  final int requiredVirtualTrades;
  final int requiredEducationModules;
  final int requiredStreak;
  final List<String> requiredAchievements;
  final List<String> requiredSkills;
  final double minimumCapitalRetention;
  final bool realMoneyAllowed;
  final int maxPositionSize;
  final List<String> availableFeatures;
  final Map<String, dynamic> specialRequirements;

  const TierProgressionRequirements({
    required this.tier,
    required this.tierName,
    required this.description,
    required this.daysRequired,
    required this.minimumXp,
    required this.requiredVirtualTrades,
    required this.requiredEducationModules,
    required this.requiredStreak,
    required this.requiredAchievements,
    required this.requiredSkills,
    required this.minimumCapitalRetention,
    required this.realMoneyAllowed,
    required this.maxPositionSize,
    required this.availableFeatures,
    this.specialRequirements = const {},
  });
}

/// User's progress toward tier advancement
class TierProgress {
  final KingdomTier currentTier;
  final DateTime tierStartDate;
  final int currentXp;
  final int virtualTradesCompleted;
  final int educationModulesCompleted;
  final int currentStreak;
  final List<String> unlockedAchievements;
  final List<String> masteredSkills;
  final double currentCapitalRetention;
  final bool hasPassedRiskAssessment;
  final Map<String, bool> competencyChecks;
  final Map<String, DateTime> milestoneCompletionDates;

  const TierProgress({
    required this.currentTier,
    required this.tierStartDate,
    required this.currentXp,
    required this.virtualTradesCompleted,
    required this.educationModulesCompleted,
    required this.currentStreak,
    required this.unlockedAchievements,
    required this.masteredSkills,
    required this.currentCapitalRetention,
    required this.hasPassedRiskAssessment,
    required this.competencyChecks,
    required this.milestoneCompletionDates,
  });

  TierProgress copyWith({
    KingdomTier? currentTier,
    DateTime? tierStartDate,
    int? currentXp,
    int? virtualTradesCompleted,
    int? educationModulesCompleted,
    int? currentStreak,
    List<String>? unlockedAchievements,
    List<String>? masteredSkills,
    double? currentCapitalRetention,
    bool? hasPassedRiskAssessment,
    Map<String, bool>? competencyChecks,
    Map<String, DateTime>? milestoneCompletionDates,
  }) {
    return TierProgress(
      currentTier: currentTier ?? this.currentTier,
      tierStartDate: tierStartDate ?? this.tierStartDate,
      currentXp: currentXp ?? this.currentXp,
      virtualTradesCompleted: virtualTradesCompleted ?? this.virtualTradesCompleted,
      educationModulesCompleted: educationModulesCompleted ?? this.educationModulesCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      masteredSkills: masteredSkills ?? this.masteredSkills,
      currentCapitalRetention: currentCapitalRetention ?? this.currentCapitalRetention,
      hasPassedRiskAssessment: hasPassedRiskAssessment ?? this.hasPassedRiskAssessment,
      competencyChecks: competencyChecks ?? this.competencyChecks,
      milestoneCompletionDates: milestoneCompletionDates ?? this.milestoneCompletionDates,
    );
  }

  /// Calculate days since tier started
  int get daysInCurrentTier {
    return DateTime.now().difference(tierStartDate).inDays;
  }

  /// Check if minimum time requirement is met
  bool meetsTimeRequirement(TierProgressionRequirements requirements) {
    return daysInCurrentTier >= requirements.daysRequired;
  }

  /// Calculate progress percentage towards next tier
  double getProgressPercentage(TierProgressionRequirements requirements) {
    double totalProgress = 0.0;
    int totalRequirements = 0;

    // Time requirement (25% weight)
    if (requirements.daysRequired > 0) {
      totalProgress += (daysInCurrentTier / requirements.daysRequired).clamp(0.0, 1.0) * 0.25;
      totalRequirements++;
    }

    // XP requirement (20% weight)
    if (requirements.minimumXp > 0) {
      totalProgress += (currentXp / requirements.minimumXp).clamp(0.0, 1.0) * 0.20;
      totalRequirements++;
    }

    // Virtual trades requirement (15% weight)
    if (requirements.requiredVirtualTrades > 0) {
      totalProgress += (virtualTradesCompleted / requirements.requiredVirtualTrades).clamp(0.0, 1.0) * 0.15;
      totalRequirements++;
    }

    // Education modules requirement (20% weight)
    if (requirements.requiredEducationModules > 0) {
      totalProgress += (educationModulesCompleted / requirements.requiredEducationModules).clamp(0.0, 1.0) * 0.20;
      totalRequirements++;
    }

    // Streak requirement (10% weight)
    if (requirements.requiredStreak > 0) {
      totalProgress += (currentStreak / requirements.requiredStreak).clamp(0.0, 1.0) * 0.10;
      totalRequirements++;
    }

    // Capital retention requirement (10% weight)
    if (requirements.minimumCapitalRetention > 0) {
      totalProgress += (currentCapitalRetention / requirements.minimumCapitalRetention).clamp(0.0, 1.0) * 0.10;
      totalRequirements++;
    }

    return totalRequirements > 0 ? totalProgress : 0.0;
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'currentTier': currentTier.name,
      'tierStartDate': tierStartDate.toIso8601String(),
      'currentXp': currentXp,
      'virtualTradesCompleted': virtualTradesCompleted,
      'educationModulesCompleted': educationModulesCompleted,
      'currentStreak': currentStreak,
      'unlockedAchievements': unlockedAchievements,
      'masteredSkills': masteredSkills,
      'currentCapitalRetention': currentCapitalRetention,
      'hasPassedRiskAssessment': hasPassedRiskAssessment,
      'competencyChecks': competencyChecks,
      'milestoneCompletionDates': milestoneCompletionDates.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  static TierProgress fromJson(Map<String, dynamic> json) {
    final tierName = json['currentTier'] as String? ?? 'village';
    final tier = KingdomTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => KingdomTier.village,
    );

    final milestoneMap = (json['milestoneCompletionDates'] as Map<String, dynamic>? ?? {})
        .map<String, DateTime>((key, value) {
      return MapEntry(key, DateTime.parse(value as String));
    });

    return TierProgress(
      currentTier: tier,
      tierStartDate: DateTime.parse(json['tierStartDate'] as String? ?? DateTime.now().toIso8601String()),
      currentXp: json['currentXp'] as int? ?? 0,
      virtualTradesCompleted: json['virtualTradesCompleted'] as int? ?? 0,
      educationModulesCompleted: json['educationModulesCompleted'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      unlockedAchievements: List<String>.from(json['unlockedAchievements'] as List? ?? []),
      masteredSkills: List<String>.from(json['masteredSkills'] as List? ?? []),
      currentCapitalRetention: (json['currentCapitalRetention'] as num?)?.toDouble() ?? 1.0,
      hasPassedRiskAssessment: json['hasPassedRiskAssessment'] as bool? ?? false,
      competencyChecks: Map<String, bool>.from(json['competencyChecks'] as Map? ?? {}),
      milestoneCompletionDates: milestoneMap,
    );
  }
}

/// Tier progression system managing all tier requirements and advancement logic
class TierProgressionSystem {
  static const Map<KingdomTier, TierProgressionRequirements> _tierRequirements = {
    // Tier 1: Village Foundations (Days 1-30)
    KingdomTier.village: TierProgressionRequirements(
      tier: KingdomTier.village,
      tierName: 'Village Foundations',
      description: 'Master basic financial literacy through virtual trading and educational modules',
      daysRequired: 30,
      minimumXp: 500,
      requiredVirtualTrades: 5,
      requiredEducationModules: 3,
      requiredStreak: 7,
      requiredAchievements: ['first_trade', 'education_starter', 'week_streak'],
      requiredSkills: ['basic_trading', 'risk_awareness', 'portfolio_basics'],
      minimumCapitalRetention: 0.95, // Must retain 95% of starting virtual capital
      realMoneyAllowed: false,
      maxPositionSize: 0, // Virtual only
      availableFeatures: [
        'virtual_trading',
        'basic_education',
        'community_access',
        'achievement_system',
        'kingdom_building_basic'
      ],
      specialRequirements: {
        'paperTradingOnly': true,
        'startingVirtualBalance': 10000.0,
        'mustCompleteQuiz': true,
        'riskAssessmentRequired': false,
      },
    ),

    // Tier 2: Town Development (Days 31-90)
    KingdomTier.town: TierProgressionRequirements(
      tier: KingdomTier.town,
      tierName: 'Town Development',
      description: 'Limited real money trading unlocked with enhanced risk management education',
      daysRequired: 60,
      minimumXp: 1500,
      requiredVirtualTrades: 10,
      requiredEducationModules: 8,
      requiredStreak: 14,
      requiredAchievements: [
        'risk_master',
        'stop_loss_user',
        'diversification_expert',
        'capital_preserver'
      ],
      requiredSkills: [
        'risk_management',
        'stop_loss_usage',
        'technical_analysis_basic',
        'portfolio_diversification'
      ],
      minimumCapitalRetention: 0.90, // Must maintain 90% of capital
      realMoneyAllowed: true,
      maxPositionSize: 500, // $500 max position size
      availableFeatures: [
        'limited_real_trading',
        'advanced_education',
        'risk_management_tools',
        'stop_loss_automation',
        'portfolio_analytics',
        'social_features_basic'
      ],
      specialRequirements: {
        'maxDailyLoss': 100.0, // $100 max daily loss
        'autoStopLossRequired': true,
        'riskAssessmentRequired': true,
        'kycRequired': true,
        'initialCapitalLimit': 2000.0, // Start with max $2000
      },
    ),

    // Tier 3: City Expansion (Days 91-180)
    KingdomTier.city: TierProgressionRequirements(
      tier: KingdomTier.city,
      tierName: 'City Expansion',
      description: 'Options education and trading with graduated margin capabilities',
      daysRequired: 90,
      minimumXp: 3500,
      requiredVirtualTrades: 25,
      requiredEducationModules: 15,
      requiredStreak: 21,
      requiredAchievements: [
        'options_ready',
        'margin_master',
        'advanced_trader',
        'portfolio_optimizer',
        'consistent_performer'
      ],
      requiredSkills: [
        'options_trading',
        'margin_management',
        'advanced_technical_analysis',
        'derivatives_understanding',
        'portfolio_optimization'
      ],
      minimumCapitalRetention: 0.85, // Must maintain 85% of capital
      realMoneyAllowed: true,
      maxPositionSize: 2000, // $2000 max position size
      availableFeatures: [
        'options_trading',
        'margin_trading_basic',
        'advanced_charting',
        'portfolio_optimization',
        'social_trading',
        'mentor_access'
      ],
      specialRequirements: {
        'optionsQuizRequired': true,
        'marginEducationRequired': true,
        'diversificationRequired': true,
        'maxLeverage': 2.0, // 2x max leverage
        'portfolioDiversificationMin': 3, // Min 3 different assets
      },
    ),

    // Tier 4: Kingdom Mastery (Days 181+)
    KingdomTier.kingdom: TierProgressionRequirements(
      tier: KingdomTier.kingdom,
      tierName: 'Kingdom Mastery',
      description: 'Full platform access with perpetuals trading and advanced derivatives',
      daysRequired: 90,
      minimumXp: 7500,
      requiredVirtualTrades: 50,
      requiredEducationModules: 25,
      requiredStreak: 30,
      requiredAchievements: [
        'perpetuals_master',
        'risk_management_expert',
        'community_leader',
        'advanced_strategist',
        'kingdom_ruler'
      ],
      requiredSkills: [
        'perpetuals_trading',
        'advanced_derivatives',
        'risk_management_expert',
        'market_analysis_advanced',
        'social_trading_leader'
      ],
      minimumCapitalRetention: 0.80, // Must maintain 80% of capital
      realMoneyAllowed: true,
      maxPositionSize: 10000, // $10,000 max position size
      availableFeatures: [
        'perpetuals_trading',
        'advanced_derivatives',
        'full_margin_access',
        'algorithmic_trading',
        'social_trading_leader',
        'mentorship_program',
        'premium_analytics'
      ],
      specialRequirements: {
        'perpetualsEducationRequired': true,
        'advancedRiskCertification': true,
        'communityContributionRequired': true,
        'maxLeverage': 10.0, // 10x max leverage (StarkNet optimized)
        'socialTradingLeaderRequired': true,
      },
    ),
  };

  /// Get requirements for a specific tier
  static TierProgressionRequirements? getRequirementsForTier(KingdomTier tier) {
    return _tierRequirements[tier];
  }

  /// Get requirements for next tier
  static TierProgressionRequirements? getNextTierRequirements(KingdomTier currentTier) {
    final tiers = KingdomTier.values;
    final currentIndex = tiers.indexOf(currentTier);
    
    if (currentIndex >= 0 && currentIndex < tiers.length - 1) {
      return _tierRequirements[tiers[currentIndex + 1]];
    }
    
    return null; // Already at highest tier
  }

  /// Check if user can advance to next tier
  static bool canAdvanceToNextTier(TierProgress progress) {
    final nextTierRequirements = getNextTierRequirements(progress.currentTier);
    if (nextTierRequirements == null) return false;

    return _meetsAllRequirements(progress, nextTierRequirements);
  }

  /// Check if all requirements are met for a tier
  static bool _meetsAllRequirements(TierProgress progress, TierProgressionRequirements requirements) {
    // Time requirement
    if (!progress.meetsTimeRequirement(requirements)) return false;
    
    // XP requirement
    if (progress.currentXp < requirements.minimumXp) return false;
    
    // Virtual trades requirement
    if (progress.virtualTradesCompleted < requirements.requiredVirtualTrades) return false;
    
    // Education modules requirement
    if (progress.educationModulesCompleted < requirements.requiredEducationModules) return false;
    
    // Streak requirement
    if (progress.currentStreak < requirements.requiredStreak) return false;
    
    // Capital retention requirement
    if (progress.currentCapitalRetention < requirements.minimumCapitalRetention) return false;
    
    // Achievement requirements
    for (String achievement in requirements.requiredAchievements) {
      if (!progress.unlockedAchievements.contains(achievement)) return false;
    }
    
    // Skills requirements
    for (String skill in requirements.requiredSkills) {
      if (!progress.masteredSkills.contains(skill)) return false;
    }
    
    // Special requirements for certain tiers
    if (requirements.specialRequirements.containsKey('riskAssessmentRequired') &&
        requirements.specialRequirements['riskAssessmentRequired'] == true &&
        !progress.hasPassedRiskAssessment) {
      return false;
    }
    
    return true;
  }

  /// Get detailed progress breakdown for current tier
  static Map<String, dynamic> getProgressBreakdown(TierProgress progress) {
    final nextTierRequirements = getNextTierRequirements(progress.currentTier);
    if (nextTierRequirements == null) {
      return {'completed': true, 'message': 'Maximum tier reached'};
    }

    return {
      'completed': false,
      'overallProgress': progress.getProgressPercentage(nextTierRequirements),
      'timeProgress': progress.meetsTimeRequirement(nextTierRequirements) ? 1.0 : 
                     progress.daysInCurrentTier / nextTierRequirements.daysRequired,
      'xpProgress': (progress.currentXp / nextTierRequirements.minimumXp).clamp(0.0, 1.0),
      'tradesProgress': (progress.virtualTradesCompleted / nextTierRequirements.requiredVirtualTrades).clamp(0.0, 1.0),
      'educationProgress': (progress.educationModulesCompleted / nextTierRequirements.requiredEducationModules).clamp(0.0, 1.0),
      'streakProgress': (progress.currentStreak / nextTierRequirements.requiredStreak).clamp(0.0, 1.0),
      'capitalRetentionProgress': (progress.currentCapitalRetention / nextTierRequirements.minimumCapitalRetention).clamp(0.0, 1.0),
      'achievementsProgress': progress.unlockedAchievements.where(
        (achievement) => nextTierRequirements.requiredAchievements.contains(achievement)
      ).length / nextTierRequirements.requiredAchievements.length,
      'skillsProgress': progress.masteredSkills.where(
        (skill) => nextTierRequirements.requiredSkills.contains(skill)
      ).length / nextTierRequirements.requiredSkills.length,
      'requirements': nextTierRequirements,
    };
  }

  /// Get all tier requirements (for UI display)
  static Map<KingdomTier, TierProgressionRequirements> getAllTierRequirements() {
    return Map.from(_tierRequirements);
  }
}