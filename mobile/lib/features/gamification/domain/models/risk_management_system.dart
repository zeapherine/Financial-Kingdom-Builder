import '../../../kingdom/domain/models/kingdom_state.dart';

/// Types of risk management demonstrations
enum RiskDemoType {
  stopLossImplementation,
  positionSizing,
  portfolioDiversification,
  volatilityManagement,
  correlationAwareness,
  drawdownControl,
  capitalPreservation,
  leverageManagement,
  liquidationPrevention,
  emotionalControl,
}

/// Risk scenario types for testing
enum RiskScenarioType {
  marketCrash,
  flashCrash,
  highVolatility,
  blackSwan,
  correlation,
  leverageTest,
  liquidationRisk,
  marginCall,
  emotionalStress,
  timeDecay,
}

/// Individual risk management requirement
class RiskManagementRequirement {
  final String id;
  final String title;
  final String description;
  final RiskDemoType type;
  final KingdomTier requiredTier;
  final Map<String, dynamic> criteria;
  final List<String> prerequisites;
  final Duration? timeLimit;
  final bool isRequired;
  final int difficultyLevel; // 1-5 scale
  final List<RiskScenarioType> testScenarios;

  const RiskManagementRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requiredTier,
    required this.criteria,
    required this.prerequisites,
    this.timeLimit,
    required this.isRequired,
    required this.difficultyLevel,
    required this.testScenarios,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'requiredTier': requiredTier.name,
      'criteria': criteria,
      'prerequisites': prerequisites,
      'timeLimit': timeLimit?.inMilliseconds,
      'isRequired': isRequired,
      'difficultyLevel': difficultyLevel,
      'testScenarios': testScenarios.map((s) => s.name).toList(),
    };
  }

  static RiskManagementRequirement fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final type = RiskDemoType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => RiskDemoType.stopLossImplementation,
    );

    final tierName = json['requiredTier'] as String;
    final tier = KingdomTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => KingdomTier.village,
    );

    final timeLimitMs = json['timeLimit'] as int?;
    final timeLimit = timeLimitMs != null ? Duration(milliseconds: timeLimitMs) : null;

    final scenarioNames = List<String>.from(json['testScenarios'] as List? ?? []);
    final scenarios = scenarioNames.map((name) => 
      RiskScenarioType.values.firstWhere(
        (s) => s.name == name,
        orElse: () => RiskScenarioType.marketCrash,
      )
    ).toList();

    return RiskManagementRequirement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: type,
      requiredTier: tier,
      criteria: Map<String, dynamic>.from(json['criteria'] as Map),
      prerequisites: List<String>.from(json['prerequisites'] as List),
      timeLimit: timeLimit,
      isRequired: json['isRequired'] as bool,
      difficultyLevel: json['difficultyLevel'] as int,
      testScenarios: scenarios,
    );
  }
}

/// User's progress on risk management demonstrations
class RiskDemoProgress {
  final String requirementId;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime startedAt;
  final double progressPercentage;
  final Map<String, dynamic> performanceData;
  final List<RiskScenarioResult> scenarioResults;
  final double overallRiskScore;
  final List<String> passedScenarios;
  final String? feedback;

  const RiskDemoProgress({
    required this.requirementId,
    required this.isCompleted,
    this.completedAt,
    required this.startedAt,
    required this.progressPercentage,
    required this.performanceData,
    required this.scenarioResults,
    required this.overallRiskScore,
    required this.passedScenarios,
    this.feedback,
  });

  RiskDemoProgress copyWith({
    String? requirementId,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? startedAt,
    double? progressPercentage,
    Map<String, dynamic>? performanceData,
    List<RiskScenarioResult>? scenarioResults,
    double? overallRiskScore,
    List<String>? passedScenarios,
    String? feedback,
  }) {
    return RiskDemoProgress(
      requirementId: requirementId ?? this.requirementId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      startedAt: startedAt ?? this.startedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      performanceData: performanceData ?? this.performanceData,
      scenarioResults: scenarioResults ?? this.scenarioResults,
      overallRiskScore: overallRiskScore ?? this.overallRiskScore,
      passedScenarios: passedScenarios ?? this.passedScenarios,
      feedback: feedback ?? this.feedback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requirementId': requirementId,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'startedAt': startedAt.toIso8601String(),
      'progressPercentage': progressPercentage,
      'performanceData': performanceData,
      'scenarioResults': scenarioResults.map((r) => r.toJson()).toList(),
      'overallRiskScore': overallRiskScore,
      'passedScenarios': passedScenarios,
      'feedback': feedback,
    };
  }

  static RiskDemoProgress fromJson(Map<String, dynamic> json) {
    final completedAtStr = json['completedAt'] as String?;
    final completedAt = completedAtStr != null ? DateTime.parse(completedAtStr) : null;

    final scenarioResultsData = json['scenarioResults'] as List? ?? [];
    final scenarioResults = scenarioResultsData
        .map((data) => RiskScenarioResult.fromJson(data as Map<String, dynamic>))
        .toList();

    return RiskDemoProgress(
      requirementId: json['requirementId'] as String,
      isCompleted: json['isCompleted'] as bool,
      completedAt: completedAt,
      startedAt: DateTime.parse(json['startedAt'] as String),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      performanceData: Map<String, dynamic>.from(json['performanceData'] as Map),
      scenarioResults: scenarioResults,
      overallRiskScore: (json['overallRiskScore'] as num).toDouble(),
      passedScenarios: List<String>.from(json['passedScenarios'] as List),
      feedback: json['feedback'] as String?,
    );
  }
}

/// Result of a risk scenario test
class RiskScenarioResult {
  final RiskScenarioType scenario;
  final DateTime testedAt;
  final bool passed;
  final double score;
  final Duration responseTime;
  final Map<String, dynamic> details;
  final String? feedback;

  const RiskScenarioResult({
    required this.scenario,
    required this.testedAt,
    required this.passed,
    required this.score,
    required this.responseTime,
    required this.details,
    this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'scenario': scenario.name,
      'testedAt': testedAt.toIso8601String(),
      'passed': passed,
      'score': score,
      'responseTime': responseTime.inMilliseconds,
      'details': details,
      'feedback': feedback,
    };
  }

  static RiskScenarioResult fromJson(Map<String, dynamic> json) {
    final scenarioName = json['scenario'] as String;
    final scenario = RiskScenarioType.values.firstWhere(
      (s) => s.name == scenarioName,
      orElse: () => RiskScenarioType.marketCrash,
    );

    return RiskScenarioResult(
      scenario: scenario,
      testedAt: DateTime.parse(json['testedAt'] as String),
      passed: json['passed'] as bool,
      score: (json['score'] as num).toDouble(),
      responseTime: Duration(milliseconds: json['responseTime'] as int),
      details: Map<String, dynamic>.from(json['details'] as Map),
      feedback: json['feedback'] as String?,
    );
  }
}

/// Risk management demonstration system
class RiskManagementSystem {
  /// All risk management requirements organized by tier
  static final Map<KingdomTier, List<RiskManagementRequirement>> _tierRequirements = {
    // Village Tier Requirements (Tier 1)
    KingdomTier.village: [
      RiskManagementRequirement(
        id: 'basic_stop_loss_demo',
        title: 'Basic Stop Loss Implementation',
        description: 'Demonstrate proper stop loss placement and usage',
        type: RiskDemoType.stopLossImplementation,
        requiredTier: KingdomTier.village,
        criteria: {
          'requiredTrades': 5,
          'stopLossUsage': 1.0, // 100% usage required
          'maxLossPerTrade': 0.02, // Max 2% loss per trade
          'averageLoss': 0.015, // Average loss should be 1.5% or less
          'preventedLargerLosses': 2, // At least 2 times stop loss prevented larger loss
        },
        prerequisites: [],
        timeLimit: Duration(days: 14),
        isRequired: true,
        difficultyLevel: 1,
        testScenarios: [RiskScenarioType.marketCrash, RiskScenarioType.highVolatility],
      ),
      RiskManagementRequirement(
        id: 'position_sizing_basics',
        title: 'Basic Position Sizing',
        description: 'Show understanding of appropriate position sizing',
        type: RiskDemoType.positionSizing,
        requiredTier: KingdomTier.village,
        criteria: {
          'maxPositionSize': 0.05, // Max 5% of portfolio per position
          'diversificationRequired': true,
          'minimumPositions': 3,
          'riskPerPosition': 0.02, // Max 2% risk per position
          'totalPortfolioRisk': 0.06, // Max 6% total portfolio risk
        },
        prerequisites: ['basic_stop_loss_demo'],
        timeLimit: Duration(days: 21),
        isRequired: true,
        difficultyLevel: 2,
        testScenarios: [RiskScenarioType.correlation, RiskScenarioType.marketCrash],
      ),
      RiskManagementRequirement(
        id: 'capital_preservation_demo',
        title: 'Capital Preservation Demonstration',
        description: 'Maintain capital over extended period',
        type: RiskDemoType.capitalPreservation,
        requiredTier: KingdomTier.village,
        criteria: {
          'duration': 30, // days
          'minimumCapitalRetention': 0.95, // Retain 95% of capital
          'maxDrawdown': 0.10, // Max 10% drawdown
          'consistentPerformance': true,
          'riskAdjustment': true,
        },
        prerequisites: ['position_sizing_basics'],
        timeLimit: Duration(days: 45),
        isRequired: true,
        difficultyLevel: 2,
        testScenarios: [RiskScenarioType.blackSwan, RiskScenarioType.emotionalStress],
      ),
    ],

    // Town Tier Requirements (Tier 2)
    KingdomTier.town: [
      RiskManagementRequirement(
        id: 'advanced_stop_loss_strategies',
        title: 'Advanced Stop Loss Strategies',
        description: 'Master various stop loss techniques and trailing stops',
        type: RiskDemoType.stopLossImplementation,
        requiredTier: KingdomTier.town,
        criteria: {
          'requiredTrades': 15,
          'trailingStopUsage': 0.60, // 60% of trades should use trailing stops
          'dynamicStopAdjustment': true,
          'volatilityBasedStops': true,
          'averageLoss': 0.012, // Average loss should be 1.2% or less
          'winRateDuringDrawdowns': 0.40, // 40% win rate during market stress
        },
        prerequisites: ['capital_preservation_demo'],
        timeLimit: Duration(days: 30),
        isRequired: true,
        difficultyLevel: 3,
        testScenarios: [RiskScenarioType.flashCrash, RiskScenarioType.highVolatility],
      ),
      RiskManagementRequirement(
        id: 'portfolio_diversification_mastery',
        title: 'Portfolio Diversification Mastery',
        description: 'Demonstrate advanced portfolio diversification techniques',
        type: RiskDemoType.portfolioDiversification,
        requiredTier: KingdomTier.town,
        criteria: {
          'minimumAssetClasses': 4,
          'correlationManagement': true,
          'sectorDiversification': true,
          'geographicDiversification': false, // Not required at this level
          'maxConcentration': 0.20, // Max 20% in any single asset
          'rebalancingFrequency': 7, // Rebalance at least weekly
        },
        prerequisites: ['advanced_stop_loss_strategies'],
        timeLimit: Duration(days: 60),
        isRequired: true,
        difficultyLevel: 3,
        testScenarios: [RiskScenarioType.correlation, RiskScenarioType.marketCrash],
      ),
      RiskManagementRequirement(
        id: 'volatility_management',
        title: 'Volatility Management',
        description: 'Show ability to manage portfolio volatility effectively',
        type: RiskDemoType.volatilityManagement,
        requiredTier: KingdomTier.town,
        criteria: {
          'targetVolatility': 0.15, // Target 15% annualized volatility
          'volatilityAdjustment': true,
          'riskParityPrinciples': true,
          'downsideProtection': true,
          'sharpeRatioImprovement': 0.20, // 20% improvement in Sharpe ratio
        },
        prerequisites: ['portfolio_diversification_mastery'],
        timeLimit: Duration(days: 45),
        isRequired: true,
        difficultyLevel: 4,
        testScenarios: [RiskScenarioType.highVolatility, RiskScenarioType.blackSwan],
      ),
      RiskManagementRequirement(
        id: 'real_money_risk_management',
        title: 'Real Money Risk Management',
        description: 'Apply risk management principles with real money',
        type: RiskDemoType.capitalPreservation,
        requiredTier: KingdomTier.town,
        criteria: {
          'realMoney': true,
          'duration': 30, // days
          'minimumCapitalRetention': 0.90, // Retain 90% of capital
          'maxDrawdown': 0.08, // Max 8% drawdown
          'riskAdjustedReturns': 0.10, // 10% annualized risk-adjusted returns
          'emotionalControl': true,
        },
        prerequisites: ['volatility_management'],
        timeLimit: Duration(days: 45),
        isRequired: true,
        difficultyLevel: 4,
        testScenarios: [RiskScenarioType.emotionalStress, RiskScenarioType.marginCall],
      ),
    ],

    // City Tier Requirements (Tier 3)
    KingdomTier.city: [
      RiskManagementRequirement(
        id: 'options_risk_management',
        title: 'Options Risk Management',
        description: 'Demonstrate advanced options risk management',
        type: RiskDemoType.volatilityManagement,
        requiredTier: KingdomTier.city,
        criteria: {
          'greeksManagement': true,
          'impliedVolatilityUnderstanding': true,
          'timeDecayManagement': true,
          'deltaHedging': true,
          'portfolioGreeks': true,
          'vega': 0.05, // Max portfolio vega exposure
          'theta': -0.02, // Max daily theta decay
        },
        prerequisites: ['real_money_risk_management'],
        timeLimit: Duration(days: 60),
        isRequired: true,
        difficultyLevel: 4,
        testScenarios: [RiskScenarioType.timeDecay, RiskScenarioType.highVolatility],
      ),
      RiskManagementRequirement(
        id: 'margin_risk_control',
        title: 'Margin Risk Control',
        description: 'Master margin trading risk management',
        type: RiskDemoType.leverageManagement,
        requiredTier: KingdomTier.city,
        criteria: {
          'maxLeverage': 2.0, // Max 2x leverage initially
          'marginUtilization': 0.50, // Max 50% margin utilization
          'leverageAdjustment': true,
          'marginCallPrevention': true,
          'hedgingStrategies': true,
          'liquidationDistance': 0.30, // Maintain 30% buffer from liquidation
        },
        prerequisites: ['options_risk_management'],
        timeLimit: Duration(days: 45),
        isRequired: true,
        difficultyLevel: 5,
        testScenarios: [RiskScenarioType.leverageTest, RiskScenarioType.liquidationRisk],
      ),
      RiskManagementRequirement(
        id: 'correlation_risk_mastery',
        title: 'Correlation Risk Mastery',
        description: 'Advanced understanding of correlation risks',
        type: RiskDemoType.correlationAwareness,
        requiredTier: KingdomTier.city,
        criteria: {
          'correlationMonitoring': true,
          'dynamicCorrelation': true,
          'tailRiskManagement': true,
          'crossAssetCorrelation': true,
          'regimeChangeDetection': true,
          'maxPortfolioCorrelation': 0.60, // Max 60% portfolio correlation
        },
        prerequisites: ['margin_risk_control'],
        timeLimit: Duration(days: 60),
        isRequired: true,
        difficultyLevel: 5,
        testScenarios: [RiskScenarioType.correlation, RiskScenarioType.blackSwan],
      ),
    ],

    // Kingdom Tier Requirements (Tier 4)
    KingdomTier.kingdom: [
      RiskManagementRequirement(
        id: 'perpetuals_risk_mastery',
        title: 'Perpetuals Risk Mastery',
        description: 'Master risk management for perpetual contracts',
        type: RiskDemoType.leverageManagement,
        requiredTier: KingdomTier.kingdom,
        criteria: {
          'maxLeverage': 10.0, // Max 10x leverage
          'fundingRateManagement': true,
          'liquidationPrevention': true,
          'dynamicHedging': true,
          'crossMarginOptimization': true,
          'starknetOptimization': true,
          'liquidationDistance': 0.40, // Maintain 40% buffer
        },
        prerequisites: ['correlation_risk_mastery'],
        timeLimit: Duration(days: 90),
        isRequired: true,
        difficultyLevel: 5,
        testScenarios: [RiskScenarioType.leverageTest, RiskScenarioType.liquidationRisk],
      ),
      RiskManagementRequirement(
        id: 'portfolio_risk_optimization',
        title: 'Portfolio Risk Optimization',
        description: 'Optimize portfolio risk across all asset classes',
        type: RiskDemoType.portfolioDiversification,
        requiredTier: KingdomTier.kingdom,
        criteria: {
          'portfolioValue': 25000.0,
          'riskBudgeting': true,
          'factorExposure': true,
          'tailRiskHedging': true,
          'dynamicAllocation': true,
          'riskAdjustedAlpha': 0.15, // 15% risk-adjusted alpha
          'maxDrawdown': 0.08, // Max 8% drawdown
        },
        prerequisites: ['perpetuals_risk_mastery'],
        timeLimit: Duration(days: 120),
        isRequired: true,
        difficultyLevel: 5,
        testScenarios: [RiskScenarioType.blackSwan, RiskScenarioType.correlation],
      ),
      RiskManagementRequirement(
        id: 'expert_risk_leadership',
        title: 'Expert Risk Leadership',
        description: 'Demonstrate expert-level risk management and leadership',
        type: RiskDemoType.emotionalControl,
        requiredTier: KingdomTier.kingdom,
        criteria: {
          'mentorRiskManagement': true,
          'riskFrameworkDevelopment': true,
          'stressTestDesign': true,
          'riskCommunication': true,
          'portfolioOptimization': true,
          'systemicRiskUnderstanding': true,
        },
        prerequisites: ['portfolio_risk_optimization'],
        timeLimit: Duration(days: 60),
        isRequired: false, // Optional leadership requirement
        difficultyLevel: 5,
        testScenarios: [RiskScenarioType.emotionalStress, RiskScenarioType.blackSwan],
      ),
    ],
  };

  /// Get risk requirements for a specific tier
  static List<RiskManagementRequirement> getRequirementsForTier(KingdomTier tier) {
    return _tierRequirements[tier] ?? [];
  }

  /// Get all risk requirements up to and including a tier
  static List<RiskManagementRequirement> getRequirementsUpToTier(KingdomTier tier) {
    final List<RiskManagementRequirement> requirements = [];
    final tiers = KingdomTier.values;
    final tierIndex = tiers.indexOf(tier);
    
    for (int i = 0; i <= tierIndex; i++) {
      requirements.addAll(getRequirementsForTier(tiers[i]));
    }
    
    return requirements;
  }

  /// Get required risk demonstrations for tier progression
  static List<RiskManagementRequirement> getRequiredRequirementsForTier(KingdomTier tier) {
    return getRequirementsForTier(tier).where((requirement) => requirement.isRequired).toList();
  }

  /// Find requirement by ID
  static RiskManagementRequirement? getRequirementById(String requirementId) {
    for (final tierRequirements in _tierRequirements.values) {
      for (final requirement in tierRequirements) {
        if (requirement.id == requirementId) return requirement;
      }
    }
    return null;
  }

  /// Calculate risk score based on performance
  static double calculateRiskScore(RiskManagementRequirement requirement, Map<String, dynamic> performanceData) {
    double score = 0.0;
    int criteriaCount = 0;

    switch (requirement.type) {
      case RiskDemoType.stopLossImplementation:
        final stopLossUsage = performanceData['stopLossUsage'] as double? ?? 0.0;
        final averageLoss = performanceData['averageLoss'] as double? ?? 1.0;
        final maxLossPerTrade = requirement.criteria['maxLossPerTrade'] as double? ?? 0.02;
        
        score += stopLossUsage * 40; // 40 points for usage
        score += ((maxLossPerTrade - averageLoss) / maxLossPerTrade * 30).clamp(0.0, 30.0); // 30 points for effectiveness
        score += (performanceData['preventedLargerLosses'] as int? ?? 0) * 15; // 15 points each for prevention
        criteriaCount = 1;
        break;

      case RiskDemoType.positionSizing:
        final maxPosition = performanceData['maxPositionSize'] as double? ?? 1.0;
        final targetMaxPosition = requirement.criteria['maxPositionSize'] as double? ?? 0.05;
        final diversification = performanceData['diversificationScore'] as double? ?? 0.0;
        
        score += ((targetMaxPosition / maxPosition) * 50).clamp(0.0, 50.0); // 50 points for position sizing
        score += diversification * 50; // 50 points for diversification
        criteriaCount = 1;
        break;

      case RiskDemoType.portfolioDiversification:
        final correlationScore = performanceData['correlationScore'] as double? ?? 0.0;
        final diversificationScore = performanceData['diversificationScore'] as double? ?? 0.0;
        final concentrationScore = performanceData['concentrationScore'] as double? ?? 0.0;
        
        score += (1.0 - correlationScore) * 33; // Lower correlation is better
        score += diversificationScore * 33;
        score += concentrationScore * 34;
        criteriaCount = 1;
        break;

      case RiskDemoType.volatilityManagement:
        final targetVol = requirement.criteria['targetVolatility'] as double? ?? 0.15;
        final actualVol = performanceData['portfolioVolatility'] as double? ?? 1.0;
        final sharpeImprovement = performanceData['sharpeRatioImprovement'] as double? ?? 0.0;
        
        score += ((targetVol / actualVol) * 60).clamp(0.0, 60.0); // 60 points for volatility control
        score += (sharpeImprovement * 200).clamp(0.0, 40.0); // 40 points for Sharpe improvement
        criteriaCount = 1;
        break;

      case RiskDemoType.capitalPreservation:
        final capitalRetention = performanceData['capitalRetention'] as double? ?? 0.0;
        final maxDrawdown = performanceData['maxDrawdown'] as double? ?? 1.0;
        final targetRetention = requirement.criteria['minimumCapitalRetention'] as double? ?? 0.90;
        final targetDrawdown = requirement.criteria['maxDrawdown'] as double? ?? 0.10;
        
        score += (capitalRetention / targetRetention * 60).clamp(0.0, 60.0); // 60 points for capital retention
        score += ((targetDrawdown / maxDrawdown) * 40).clamp(0.0, 40.0); // 40 points for drawdown control
        criteriaCount = 1;
        break;

      case RiskDemoType.leverageManagement:
        final leverageControl = performanceData['leverageControl'] as double? ?? 0.0;
        final liquidationDistance = performanceData['liquidationDistance'] as double? ?? 0.0;
        final marginUtilization = performanceData['marginUtilization'] as double? ?? 1.0;
        
        score += leverageControl * 40; // 40 points for leverage control
        score += liquidationDistance * 30; // 30 points for liquidation distance
        score += ((1.0 - marginUtilization) * 30).clamp(0.0, 30.0); // 30 points for margin efficiency
        criteriaCount = 1;
        break;

      case RiskDemoType.correlationAwareness:
      case RiskDemoType.drawdownControl:
      case RiskDemoType.liquidationPrevention:
      case RiskDemoType.emotionalControl:
        final overallScore = performanceData['overallScore'] as double? ?? 0.0;
        score += overallScore;
        criteriaCount = 1;
        break;
    }

    return criteriaCount > 0 ? score.clamp(0.0, 100.0) : 0.0;
  }

  /// Validate risk requirement completion
  static bool validateRequirementCompletion(RiskManagementRequirement requirement, Map<String, dynamic> performanceData) {
    final score = calculateRiskScore(requirement, performanceData);
    return score >= 75.0; // Require 75% score for completion
  }

  /// Check if all required risk demonstrations for tier are completed
  static bool areAllRequiredDemonstrationsCompleted(KingdomTier tier, List<String> completedRequirements) {
    final requiredDemos = getRequiredRequirementsForTier(tier);
    return requiredDemos.every((demo) => completedRequirements.contains(demo.id));
  }

  /// Get risk progression path for a tier
  static List<RiskManagementRequirement> getRiskProgressionPath(KingdomTier tier) {
    final tierRequirements = getRequiredRequirementsForTier(tier);
    
    // Sort by prerequisites and difficulty to create logical progression
    final List<RiskManagementRequirement> progressionPath = [];
    final Set<String> processed = {};
    
    void addRequirementAndPrerequisites(RiskManagementRequirement requirement) {
      if (processed.contains(requirement.id)) return;
      
      // Add prerequisites first
      for (final prerequisiteId in requirement.prerequisites) {
        final prerequisite = getRequirementById(prerequisiteId);
        if (prerequisite != null && !processed.contains(prerequisiteId)) {
          addRequirementAndPrerequisites(prerequisite);
        }
      }
      
      // Add the requirement itself
      if (!processed.contains(requirement.id)) {
        progressionPath.add(requirement);
        processed.add(requirement.id);
      }
    }
    
    // Sort by difficulty level first
    final sortedRequirements = List<RiskManagementRequirement>.from(tierRequirements)
      ..sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));
    
    for (final requirement in sortedRequirements) {
      addRequirementAndPrerequisites(requirement);
    }
    
    return progressionPath;
  }

  /// Get all risk requirements
  static List<RiskManagementRequirement> getAllRequirements() {
    final List<RiskManagementRequirement> allRequirements = [];
    for (final tierRequirements in _tierRequirements.values) {
      allRequirements.addAll(tierRequirements);
    }
    return allRequirements;
  }

  /// Get requirements by type
  static List<RiskManagementRequirement> getRequirementsByType(RiskDemoType type) {
    return getAllRequirements().where((requirement) => requirement.type == type).toList();
  }

  /// Generate risk scenario test
  static Map<String, dynamic> generateRiskScenario(RiskScenarioType scenario) {
    switch (scenario) {
      case RiskScenarioType.marketCrash:
        return {
          'type': 'market_crash',
          'description': '20% market drop in 2 days',
          'priceChange': -0.20,
          'timeframe': Duration(days: 2),
          'volatility': 0.40,
          'correlation': 0.85, // High correlation during crash
        };

      case RiskScenarioType.flashCrash:
        return {
          'type': 'flash_crash',
          'description': '10% drop in 30 minutes',
          'priceChange': -0.10,
          'timeframe': Duration(minutes: 30),
          'volatility': 0.80,
          'liquidityShock': true,
        };

      case RiskScenarioType.highVolatility:
        return {
          'type': 'high_volatility',
          'description': 'Extended high volatility period',
          'priceChange': 0.0, // No directional bias
          'timeframe': Duration(days: 14),
          'volatility': 0.60,
          'whipsaws': true,
        };

      case RiskScenarioType.blackSwan:
        return {
          'type': 'black_swan',
          'description': 'Extreme unexpected event',
          'priceChange': -0.35,
          'timeframe': Duration(hours: 6),
          'volatility': 1.00,
          'correlation': 0.95,
          'liquidityDry': true,
        };

      case RiskScenarioType.correlation:
        return {
          'type': 'correlation_breakdown',
          'description': 'Portfolio correlation changes dramatically',
          'correlationShift': 0.50, // Correlation increases by 50%
          'timeframe': Duration(days: 7),
          'diversificationLoss': true,
        };

      case RiskScenarioType.leverageTest:
        return {
          'type': 'leverage_stress',
          'description': 'Test leverage management under stress',
          'priceChange': -0.15,
          'timeframe': Duration(hours: 4),
          'marginPressure': true,
          'fundingCostIncrease': 0.05,
        };

      case RiskScenarioType.liquidationRisk:
        return {
          'type': 'liquidation_risk',
          'description': 'Approaching liquidation threshold',
          'marginLevel': 0.15, // 15% margin remaining
          'timeframe': Duration(hours: 2),
          'volatilitySpike': true,
        };

      case RiskScenarioType.marginCall:
        return {
          'type': 'margin_call',
          'description': 'Margin call situation',
          'marginDeficit': 0.20, // 20% margin deficit
          'timeframe': Duration(hours: 1),
          'liquidationThreat': true,
        };

      case RiskScenarioType.emotionalStress:
        return {
          'type': 'emotional_stress',
          'description': 'High stress trading environment',
          'lossStreak': 5,
          'timeframe': Duration(days: 3),
          'psychologicalPressure': true,
        };

      case RiskScenarioType.timeDecay:
        return {
          'type': 'time_decay',
          'description': 'Options time decay acceleration',
          'thetaDecay': 0.05, // 5% daily decay
          'timeframe': Duration(days: 5),
          'volatilityDrop': true,
        };
    }
  }
}