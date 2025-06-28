import '../../../kingdom/domain/models/kingdom_state.dart';

/// Types of competency that can be verified
enum CompetencyType {
  basicTrading,
  riskManagement,
  technicalAnalysis,
  portfolioManagement,
  optionsTrading,
  marginTrading,
  perpetualsTrading,
  marketPsychology,
  fundamentalAnalysis,
  derivativesTrading,
}

/// Difficulty levels for competency verification
enum CompetencyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Types of verification methods
enum VerificationMethod {
  quiz,
  practicalTest,
  simulation,
  portfolio,
  tradeReview,
  interview,
  certification,
}

/// Individual competency verification requirement
class CompetencyVerification {
  final String id;
  final String title;
  final String description;
  final CompetencyType type;
  final CompetencyLevel level;
  final KingdomTier requiredTier;
  final VerificationMethod method;
  final Map<String, dynamic> criteria;
  final List<String> prerequisites;
  final Duration? timeLimit;
  final int maxAttempts;
  final int passingScore;
  final bool isRequired;
  final String category;

  const CompetencyVerification({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.level,
    required this.requiredTier,
    required this.method,
    required this.criteria,
    required this.prerequisites,
    this.timeLimit,
    required this.maxAttempts,
    required this.passingScore,
    required this.isRequired,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'level': level.name,
      'requiredTier': requiredTier.name,
      'method': method.name,
      'criteria': criteria,
      'prerequisites': prerequisites,
      'timeLimit': timeLimit?.inMilliseconds,
      'maxAttempts': maxAttempts,
      'passingScore': passingScore,
      'isRequired': isRequired,
      'category': category,
    };
  }

  static CompetencyVerification fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final type = CompetencyType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => CompetencyType.basicTrading,
    );

    final levelName = json['level'] as String;
    final level = CompetencyLevel.values.firstWhere(
      (l) => l.name == levelName,
      orElse: () => CompetencyLevel.beginner,
    );

    final tierName = json['requiredTier'] as String;
    final tier = KingdomTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => KingdomTier.village,
    );

    final methodName = json['method'] as String;
    final method = VerificationMethod.values.firstWhere(
      (m) => m.name == methodName,
      orElse: () => VerificationMethod.quiz,
    );

    final timeLimitMs = json['timeLimit'] as int?;
    final timeLimit = timeLimitMs != null ? Duration(milliseconds: timeLimitMs) : null;

    return CompetencyVerification(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: type,
      level: level,
      requiredTier: tier,
      method: method,
      criteria: Map<String, dynamic>.from(json['criteria'] as Map),
      prerequisites: List<String>.from(json['prerequisites'] as List),
      timeLimit: timeLimit,
      maxAttempts: json['maxAttempts'] as int,
      passingScore: json['passingScore'] as int,
      isRequired: json['isRequired'] as bool,
      category: json['category'] as String,
    );
  }
}

/// User's progress on a competency verification
class CompetencyProgress {
  final String competencyId;
  final bool isPassed;
  final DateTime? passedAt;
  final DateTime startedAt;
  final int bestScore;
  final int attemptCount;
  final List<CompetencyAttempt> attempts;
  final Map<String, dynamic> progressData;
  final String? failureReason;
  final DateTime? nextAttemptAllowed;

  const CompetencyProgress({
    required this.competencyId,
    required this.isPassed,
    this.passedAt,
    required this.startedAt,
    required this.bestScore,
    required this.attemptCount,
    required this.attempts,
    required this.progressData,
    this.failureReason,
    this.nextAttemptAllowed,
  });

  CompetencyProgress copyWith({
    String? competencyId,
    bool? isPassed,
    DateTime? passedAt,
    DateTime? startedAt,
    int? bestScore,
    int? attemptCount,
    List<CompetencyAttempt>? attempts,
    Map<String, dynamic>? progressData,
    String? failureReason,
    DateTime? nextAttemptAllowed,
  }) {
    return CompetencyProgress(
      competencyId: competencyId ?? this.competencyId,
      isPassed: isPassed ?? this.isPassed,
      passedAt: passedAt ?? this.passedAt,
      startedAt: startedAt ?? this.startedAt,
      bestScore: bestScore ?? this.bestScore,
      attemptCount: attemptCount ?? this.attemptCount,
      attempts: attempts ?? this.attempts,
      progressData: progressData ?? this.progressData,
      failureReason: failureReason ?? this.failureReason,
      nextAttemptAllowed: nextAttemptAllowed ?? this.nextAttemptAllowed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competencyId': competencyId,
      'isPassed': isPassed,
      'passedAt': passedAt?.toIso8601String(),
      'startedAt': startedAt.toIso8601String(),
      'bestScore': bestScore,
      'attemptCount': attemptCount,
      'attempts': attempts.map((attempt) => attempt.toJson()).toList(),
      'progressData': progressData,
      'failureReason': failureReason,
      'nextAttemptAllowed': nextAttemptAllowed?.toIso8601String(),
    };
  }

  static CompetencyProgress fromJson(Map<String, dynamic> json) {
    final passedAtStr = json['passedAt'] as String?;
    final passedAt = passedAtStr != null ? DateTime.parse(passedAtStr) : null;

    final nextAttemptStr = json['nextAttemptAllowed'] as String?;
    final nextAttemptAllowed = nextAttemptStr != null ? DateTime.parse(nextAttemptStr) : null;

    final attemptsData = json['attempts'] as List? ?? [];
    final attempts = attemptsData.map((data) => CompetencyAttempt.fromJson(data as Map<String, dynamic>)).toList();

    return CompetencyProgress(
      competencyId: json['competencyId'] as String,
      isPassed: json['isPassed'] as bool,
      passedAt: passedAt,
      startedAt: DateTime.parse(json['startedAt'] as String),
      bestScore: json['bestScore'] as int,
      attemptCount: json['attemptCount'] as int,
      attempts: attempts,
      progressData: Map<String, dynamic>.from(json['progressData'] as Map),
      failureReason: json['failureReason'] as String?,
      nextAttemptAllowed: nextAttemptAllowed,
    );
  }
}

/// Individual attempt at a competency verification
class CompetencyAttempt {
  final DateTime attemptedAt;
  final int score;
  final bool passed;
  final Duration timeTaken;
  final Map<String, dynamic> details;
  final String? feedback;

  const CompetencyAttempt({
    required this.attemptedAt,
    required this.score,
    required this.passed,
    required this.timeTaken,
    required this.details,
    this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'attemptedAt': attemptedAt.toIso8601String(),
      'score': score,
      'passed': passed,
      'timeTaken': timeTaken.inMilliseconds,
      'details': details,
      'feedback': feedback,
    };
  }

  static CompetencyAttempt fromJson(Map<String, dynamic> json) {
    return CompetencyAttempt(
      attemptedAt: DateTime.parse(json['attemptedAt'] as String),
      score: json['score'] as int,
      passed: json['passed'] as bool,
      timeTaken: Duration(milliseconds: json['timeTaken'] as int),
      details: Map<String, dynamic>.from(json['details'] as Map),
      feedback: json['feedback'] as String?,
    );
  }
}

/// Competency verification system
class CompetencyVerificationSystem {
  /// All available competency verifications organized by tier
  static final Map<KingdomTier, List<CompetencyVerification>> _tierCompetencies = {
    // Village Tier Competencies (Tier 1)
    KingdomTier.village: [
      CompetencyVerification(
        id: 'basic_trading_quiz',
        title: 'Basic Trading Fundamentals',
        description: 'Verify understanding of basic trading concepts',
        type: CompetencyType.basicTrading,
        level: CompetencyLevel.beginner,
        requiredTier: KingdomTier.village,
        method: VerificationMethod.quiz,
        criteria: {
          'questions': 20,
          'timePerQuestion': 60, // seconds
          'topics': ['order_types', 'market_basics', 'bid_ask', 'spread', 'volume'],
        },
        prerequisites: [],
        timeLimit: Duration(minutes: 20),
        maxAttempts: 3,
        passingScore: 80,
        isRequired: true,
        category: 'Trading Basics',
      ),
      CompetencyVerification(
        id: 'risk_awareness_assessment',
        title: 'Risk Awareness Assessment',
        description: 'Demonstrate understanding of investment risks',
        type: CompetencyType.riskManagement,
        level: CompetencyLevel.beginner,
        requiredTier: KingdomTier.village,
        method: VerificationMethod.quiz,
        criteria: {
          'questions': 15,
          'scenarios': 5,
          'topics': ['risk_tolerance', 'diversification', 'volatility', 'loss_acceptance'],
        },
        prerequisites: ['basic_trading_quiz'],
        timeLimit: Duration(minutes: 15),
        maxAttempts: 3,
        passingScore: 85,
        isRequired: true,
        category: 'Risk Management',
      ),
      CompetencyVerification(
        id: 'virtual_portfolio_simulation',
        title: 'Virtual Portfolio Management',
        description: 'Demonstrate portfolio management skills through simulation',
        type: CompetencyType.portfolioManagement,
        level: CompetencyLevel.beginner,
        requiredTier: KingdomTier.village,
        method: VerificationMethod.simulation,
        criteria: {
          'startingBalance': 10000.0,
          'duration': 14, // days
          'minimumTrades': 5,
          'maxDrawdown': 0.10, // 10%
          'diversificationRequired': true,
          'riskMetrics': ['sharpe_ratio', 'max_drawdown', 'total_return'],
        },
        prerequisites: ['risk_awareness_assessment'],
        timeLimit: Duration(days: 21),
        maxAttempts: 2,
        passingScore: 75, // Based on risk-adjusted performance
        isRequired: true,
        category: 'Portfolio Management',
      ),
    ],

    // Town Tier Competencies (Tier 2)
    KingdomTier.town: [
      CompetencyVerification(
        id: 'advanced_risk_management_cert',
        title: 'Advanced Risk Management Certification',
        description: 'Master advanced risk management techniques',
        type: CompetencyType.riskManagement,
        level: CompetencyLevel.intermediate,
        requiredTier: KingdomTier.town,
        method: VerificationMethod.certification,
        criteria: {
          'modules': ['position_sizing', 'stop_losses', 'correlation', 'volatility_management'],
          'practicalTests': 3,
          'questions': 30,
          'scenarios': 10,
        },
        prerequisites: ['virtual_portfolio_simulation'],
        timeLimit: Duration(minutes: 45),
        maxAttempts: 2,
        passingScore: 90,
        isRequired: true,
        category: 'Risk Management',
      ),
      CompetencyVerification(
        id: 'stop_loss_mastery_test',
        title: 'Stop Loss Implementation Mastery',
        description: 'Demonstrate effective stop loss usage',
        type: CompetencyType.riskManagement,
        level: CompetencyLevel.intermediate,
        requiredTier: KingdomTier.town,
        method: VerificationMethod.practicalTest,
        criteria: {
          'testTrades': 10,
          'stopLossRequired': true,
          'maxLossPerTrade': 0.02, // 2%
          'successRate': 0.80, // 80% of stop losses should be effective
        },
        prerequisites: ['advanced_risk_management_cert'],
        timeLimit: Duration(days: 30),
        maxAttempts: 2,
        passingScore: 85,
        isRequired: true,
        category: 'Risk Management',
      ),
      CompetencyVerification(
        id: 'real_money_readiness_interview',
        title: 'Real Money Trading Readiness',
        description: 'Comprehensive assessment for real money trading',
        type: CompetencyType.marketPsychology,
        level: CompetencyLevel.intermediate,
        requiredTier: KingdomTier.town,
        method: VerificationMethod.interview,
        criteria: {
          'psychologyAssessment': true,
          'riskToleranceEvaluation': true,
          'tradingPlanReview': true,
          'scenarioQuestions': 15,
        },
        prerequisites: ['stop_loss_mastery_test'],
        maxAttempts: 1,
        passingScore: 90,
        isRequired: true,
        category: 'Psychology & Readiness',
      ),
      CompetencyVerification(
        id: 'capital_preservation_track_record',
        title: 'Capital Preservation Track Record',
        description: 'Maintain capital over extended trading period',
        type: CompetencyType.portfolioManagement,
        level: CompetencyLevel.intermediate,
        requiredTier: KingdomTier.town,
        method: VerificationMethod.portfolio,
        criteria: {
          'duration': 30, // days
          'realMoney': true,
          'minimumCapitalRetention': 0.90, // 90%
          'minimumTrades': 10,
          'consistencyRequired': true,
        },
        prerequisites: ['real_money_readiness_interview'],
        timeLimit: Duration(days: 45),
        maxAttempts: 1,
        passingScore: 90,
        isRequired: true,
        category: 'Performance',
      ),
    ],

    // City Tier Competencies (Tier 3)
    KingdomTier.city: [
      CompetencyVerification(
        id: 'technical_analysis_mastery',
        title: 'Technical Analysis Mastery',
        description: 'Master advanced technical analysis techniques',
        type: CompetencyType.technicalAnalysis,
        level: CompetencyLevel.advanced,
        requiredTier: KingdomTier.city,
        method: VerificationMethod.certification,
        criteria: {
          'modules': ['chart_patterns', 'indicators', 'fibonacci', 'elliott_wave'],
          'chartAnalysis': 10,
          'questions': 40,
          'practicalTests': 5,
        },
        prerequisites: ['capital_preservation_track_record'],
        timeLimit: Duration(hours: 2),
        maxAttempts: 2,
        passingScore: 85,
        isRequired: true,
        category: 'Technical Analysis',
      ),
      CompetencyVerification(
        id: 'options_fundamentals_cert',
        title: 'Options Trading Fundamentals',
        description: 'Comprehensive options trading certification',
        type: CompetencyType.optionsTrading,
        level: CompetencyLevel.intermediate,
        requiredTier: KingdomTier.city,
        method: VerificationMethod.certification,
        criteria: {
          'modules': ['calls_puts', 'greeks', 'strategies', 'risk_management'],
          'simulationTrades': 15,
          'questions': 50,
          'scenarios': 10,
        },
        prerequisites: ['technical_analysis_mastery'],
        timeLimit: Duration(hours: 3),
        maxAttempts: 2,
        passingScore: 90,
        isRequired: true,
        category: 'Options Trading',
      ),
      CompetencyVerification(
        id: 'portfolio_optimization_test',
        title: 'Portfolio Optimization Mastery',
        description: 'Advanced portfolio optimization techniques',
        type: CompetencyType.portfolioManagement,
        level: CompetencyLevel.advanced,
        requiredTier: KingdomTier.city,
        method: VerificationMethod.portfolio,
        criteria: {
          'portfolioValue': 5000.0,
          'duration': 60, // days
          'optimizationRequired': true,
          'riskAdjustedReturn': 0.15, // 15%
          'maxDrawdown': 0.15, // 15%
          'diversificationScore': 0.80, // 80%
        },
        prerequisites: ['options_fundamentals_cert'],
        timeLimit: Duration(days: 90),
        maxAttempts: 1,
        passingScore: 85,
        isRequired: true,
        category: 'Portfolio Management',
      ),
      CompetencyVerification(
        id: 'margin_trading_certification',
        title: 'Margin Trading Certification',
        description: 'Advanced margin trading and leverage management',
        type: CompetencyType.marginTrading,
        level: CompetencyLevel.advanced,
        requiredTier: KingdomTier.city,
        method: VerificationMethod.certification,
        criteria: {
          'modules': ['leverage', 'margin_calls', 'liquidation', 'risk_management'],
          'simulationTrades': 20,
          'questions': 35,
          'leverageScenarios': 8,
        },
        prerequisites: ['portfolio_optimization_test'],
        timeLimit: Duration(hours: 2),
        maxAttempts: 2,
        passingScore: 95,
        isRequired: true,
        category: 'Margin Trading',
      ),
    ],

    // Kingdom Tier Competencies (Tier 4)
    KingdomTier.kingdom: [
      CompetencyVerification(
        id: 'derivatives_mastery_cert',
        title: 'Advanced Derivatives Mastery',
        description: 'Master complex derivatives and structured products',
        type: CompetencyType.derivativesTrading,
        level: CompetencyLevel.expert,
        requiredTier: KingdomTier.kingdom,
        method: VerificationMethod.certification,
        criteria: {
          'modules': ['futures', 'perpetuals', 'swaps', 'exotic_options'],
          'questions': 60,
          'scenarios': 15,
          'practicalTests': 8,
        },
        prerequisites: ['margin_trading_certification'],
        timeLimit: Duration(hours: 4),
        maxAttempts: 2,
        passingScore: 90,
        isRequired: true,
        category: 'Derivatives',
      ),
      CompetencyVerification(
        id: 'perpetuals_expert_certification',
        title: 'Perpetuals Trading Expert',
        description: 'Advanced perpetuals trading with StarkNet optimization',
        type: CompetencyType.perpetualsTrading,
        level: CompetencyLevel.expert,
        requiredTier: KingdomTier.kingdom,
        method: VerificationMethod.certification,
        criteria: {
          'modules': ['perpetuals_mechanics', 'funding_rates', 'liquidation_prevention'],
          'starknetOptimization': true,
          'simulationTrades': 25,
          'questions': 40,
          'leverageManagement': true,
        },
        prerequisites: ['derivatives_mastery_cert'],
        timeLimit: Duration(hours: 3),
        maxAttempts: 1,
        passingScore: 95,
        isRequired: true,
        category: 'Perpetuals',
      ),
      CompetencyVerification(
        id: 'risk_management_expert_track_record',
        title: 'Risk Management Expert',
        description: 'Expert-level risk management over extended period',
        type: CompetencyType.riskManagement,
        level: CompetencyLevel.expert,
        requiredTier: KingdomTier.kingdom,
        method: VerificationMethod.portfolio,
        criteria: {
          'portfolioValue': 25000.0,
          'duration': 90, // days
          'maxLeverage': 5.0,
          'riskAdjustedReturn': 0.25, // 25%
          'maxDrawdown': 0.10, // 10%
          'consistencyScore': 0.90, // 90%
          'volatilityManagement': true,
        },
        prerequisites: ['perpetuals_expert_certification'],
        timeLimit: Duration(days: 120),
        maxAttempts: 1,
        passingScore: 90,
        isRequired: true,
        category: 'Risk Management',
      ),
      CompetencyVerification(
        id: 'community_leadership_assessment',
        title: 'Community Leadership Assessment',
        description: 'Leadership and mentorship in trading community',
        type: CompetencyType.marketPsychology,
        level: CompetencyLevel.expert,
        requiredTier: KingdomTier.kingdom,
        method: VerificationMethod.portfolio,
        criteria: {
          'mentorStudents': 3,
          'communityContributions': 10,
          'helpfulVotes': 50,
          'qualityContent': 5,
          'leadershipDuration': 30, // days
        },
        prerequisites: ['risk_management_expert_track_record'],
        timeLimit: Duration(days: 60),
        maxAttempts: 1,
        passingScore: 85,
        isRequired: false,
        category: 'Leadership',
      ),
    ],
  };

  /// Get competencies for a specific tier
  static List<CompetencyVerification> getCompetenciesForTier(KingdomTier tier) {
    return _tierCompetencies[tier] ?? [];
  }

  /// Get all competencies up to and including a tier
  static List<CompetencyVerification> getCompetenciesUpToTier(KingdomTier tier) {
    final List<CompetencyVerification> competencies = [];
    final tiers = KingdomTier.values;
    final tierIndex = tiers.indexOf(tier);
    
    for (int i = 0; i <= tierIndex; i++) {
      competencies.addAll(getCompetenciesForTier(tiers[i]));
    }
    
    return competencies;
  }

  /// Get required competencies for tier progression
  static List<CompetencyVerification> getRequiredCompetenciesForTier(KingdomTier tier) {
    return getCompetenciesForTier(tier).where((competency) => competency.isRequired).toList();
  }

  /// Check if competency prerequisites are met
  static bool arePrerequisitesMet(String competencyId, List<String> passedCompetencies) {
    final competency = _findCompetencyById(competencyId);
    if (competency == null) return false;
    
    return competency.prerequisites.every((prerequisite) => passedCompetencies.contains(prerequisite));
  }

  /// Check if competency can be attempted
  static bool canAttemptCompetency(String competencyId, KingdomTier currentTier, List<String> passedCompetencies) {
    final competency = _findCompetencyById(competencyId);
    if (competency == null) return false;
    
    // Check tier requirement
    final tiers = KingdomTier.values;
    final currentTierIndex = tiers.indexOf(currentTier);
    final requiredTierIndex = tiers.indexOf(competency.requiredTier);
    
    if (currentTierIndex < requiredTierIndex) return false;
    
    // Check prerequisites
    return arePrerequisitesMet(competencyId, passedCompetencies);
  }

  /// Find competency by ID
  static CompetencyVerification? _findCompetencyById(String competencyId) {
    for (final tierCompetencies in _tierCompetencies.values) {
      for (final competency in tierCompetencies) {
        if (competency.id == competencyId) return competency;
      }
    }
    return null;
  }

  /// Get competency by ID
  static CompetencyVerification? getCompetencyById(String competencyId) {
    return _findCompetencyById(competencyId);
  }

  /// Get all competencies
  static List<CompetencyVerification> getAllCompetencies() {
    final List<CompetencyVerification> allCompetencies = [];
    for (final tierCompetencies in _tierCompetencies.values) {
      allCompetencies.addAll(tierCompetencies);
    }
    return allCompetencies;
  }

  /// Get competencies by type
  static List<CompetencyVerification> getCompetenciesByType(CompetencyType type) {
    return getAllCompetencies().where((competency) => competency.type == type).toList();
  }

  /// Get competencies by level
  static List<CompetencyVerification> getCompetenciesByLevel(CompetencyLevel level) {
    return getAllCompetencies().where((competency) => competency.level == level).toList();
  }

  /// Get competencies by category
  static List<CompetencyVerification> getCompetenciesByCategory(String category) {
    return getAllCompetencies().where((competency) => competency.category == category).toList();
  }

  /// Get all unique categories
  static List<String> getAllCategories() {
    final categories = <String>{};
    for (final competency in getAllCompetencies()) {
      categories.add(competency.category);
    }
    return categories.toList()..sort();
  }

  /// Calculate competency score based on performance
  static int calculateCompetencyScore(CompetencyVerification competency, Map<String, dynamic> performanceData) {
    switch (competency.method) {
      case VerificationMethod.quiz:
        final correctAnswers = performanceData['correctAnswers'] as int? ?? 0;
        final totalQuestions = competency.criteria['questions'] as int? ?? 1;
        return ((correctAnswers / totalQuestions) * 100).round();

      case VerificationMethod.practicalTest:
        final successRate = performanceData['successRate'] as double? ?? 0.0;
        return (successRate * 100).round();

      case VerificationMethod.simulation:
        final totalReturn = performanceData['totalReturn'] as double? ?? 0.0;
        final sharpeRatio = performanceData['sharpeRatio'] as double? ?? 0.0;
        final maxDrawdown = performanceData['maxDrawdown'] as double? ?? 1.0;
        
        // Calculate composite score
        double score = 0.0;
        score += (totalReturn * 0.4).clamp(0.0, 40.0); // 40% weight for returns
        score += (sharpeRatio * 20).clamp(0.0, 30.0); // 30% weight for risk-adjusted returns
        score += ((1.0 - maxDrawdown) * 30).clamp(0.0, 30.0); // 30% weight for risk management
        
        return score.round();

      case VerificationMethod.portfolio:
        final riskAdjustedReturn = performanceData['riskAdjustedReturn'] as double? ?? 0.0;
        final capitalRetention = performanceData['capitalRetention'] as double? ?? 0.0;
        final consistency = performanceData['consistency'] as double? ?? 0.0;
        
        // Portfolio score calculation
        double score = 0.0;
        score += (riskAdjustedReturn * 50).clamp(0.0, 50.0); // 50% weight for performance
        score += (capitalRetention * 30).clamp(0.0, 30.0); // 30% weight for preservation
        score += (consistency * 20).clamp(0.0, 20.0); // 20% weight for consistency
        
        return score.round();

      case VerificationMethod.tradeReview:
        final reviewScore = performanceData['reviewScore'] as int? ?? 0;
        return reviewScore;

      case VerificationMethod.interview:
        final interviewScore = performanceData['interviewScore'] as int? ?? 0;
        return interviewScore;

      case VerificationMethod.certification:
        final certificationScore = performanceData['certificationScore'] as int? ?? 0;
        return certificationScore;
    }
  }

  /// Validate competency completion
  static bool validateCompetencyCompletion(CompetencyVerification competency, Map<String, dynamic> performanceData) {
    final score = calculateCompetencyScore(competency, performanceData);
    return score >= competency.passingScore;
  }

  /// Get next competency in progression path
  static CompetencyVerification? getNextCompetency(String currentCompetencyId, List<String> passedCompetencies) {
    final allCompetencies = getAllCompetencies();
    final currentCompetency = getCompetencyById(currentCompetencyId);
    if (currentCompetency == null) return null;

    // Find competencies that have the current competency as a prerequisite
    final nextCompetencies = allCompetencies.where((competency) => 
      competency.prerequisites.contains(currentCompetencyId) &&
      !passedCompetencies.contains(competency.id)
    ).toList();

    // Return the first available next competency
    return nextCompetencies.isNotEmpty ? nextCompetencies.first : null;
  }

  /// Get competency progression path for a tier
  static List<CompetencyVerification> getProgressionPath(KingdomTier tier) {
    final tierCompetencies = getRequiredCompetenciesForTier(tier);
    
    // Sort by prerequisites to create a logical progression path
    final List<CompetencyVerification> progressionPath = [];
    final Set<String> processed = {};
    
    void addCompetencyAndPrerequisites(CompetencyVerification competency) {
      if (processed.contains(competency.id)) return;
      
      // Add prerequisites first
      for (final prerequisiteId in competency.prerequisites) {
        final prerequisite = getCompetencyById(prerequisiteId);
        if (prerequisite != null && !processed.contains(prerequisiteId)) {
          addCompetencyAndPrerequisites(prerequisite);
        }
      }
      
      // Add the competency itself
      if (!processed.contains(competency.id)) {
        progressionPath.add(competency);
        processed.add(competency.id);
      }
    }
    
    for (final competency in tierCompetencies) {
      addCompetencyAndPrerequisites(competency);
    }
    
    return progressionPath;
  }

  /// Check if all required competencies for tier are completed
  static bool areAllRequiredCompetenciesCompleted(KingdomTier tier, List<String> passedCompetencies) {
    final requiredCompetencies = getRequiredCompetenciesForTier(tier);
    return requiredCompetencies.every((competency) => passedCompetencies.contains(competency.id));
  }
}