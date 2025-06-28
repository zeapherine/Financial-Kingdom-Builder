import '../../../kingdom/domain/models/kingdom_state.dart';

/// Types of events that could potentially cause tier rollback
enum RollbackTriggerType {
  tradingLoss,
  capitalDepletion,
  riskViolation,
  inactivity,
  competencyFailure,
  policyViolation,
  systemError,
  manualAdjustment,
}

/// Severity levels for rollback triggers
enum RollbackSeverity {
  minor,    // Warning only
  moderate, // Probation/reduced features
  major,    // Temporary suspension
  critical, // Potential tier impact
}

/// Actions that can be taken instead of rollback
enum PreventionAction {
  warning,
  education,
  mentorship,
  probation,
  featureRestriction,
  additionalRequirements,
  counseling,
  supportPlan,
}

/// Rollback trigger event
class RollbackTrigger {
  final String id;
  final RollbackTriggerType type;
  final RollbackSeverity severity;
  final DateTime triggeredAt;
  final String description;
  final Map<String, dynamic> data;
  final KingdomTier affectedTier;
  final bool isResolved;
  final DateTime? resolvedAt;
  final List<PreventionAction> actionsRequired;

  const RollbackTrigger({
    required this.id,
    required this.type,
    required this.severity,
    required this.triggeredAt,
    required this.description,
    required this.data,
    required this.affectedTier,
    required this.isResolved,
    this.resolvedAt,
    required this.actionsRequired,
  });

  RollbackTrigger copyWith({
    String? id,
    RollbackTriggerType? type,
    RollbackSeverity? severity,
    DateTime? triggeredAt,
    String? description,
    Map<String, dynamic>? data,
    KingdomTier? affectedTier,
    bool? isResolved,
    DateTime? resolvedAt,
    List<PreventionAction>? actionsRequired,
  }) {
    return RollbackTrigger(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      description: description ?? this.description,
      data: data ?? this.data,
      affectedTier: affectedTier ?? this.affectedTier,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      actionsRequired: actionsRequired ?? this.actionsRequired,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'triggeredAt': triggeredAt.toIso8601String(),
      'description': description,
      'data': data,
      'affectedTier': affectedTier.name,
      'isResolved': isResolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'actionsRequired': actionsRequired.map((a) => a.name).toList(),
    };
  }

  static RollbackTrigger fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final type = RollbackTriggerType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => RollbackTriggerType.systemError,
    );

    final severityName = json['severity'] as String;
    final severity = RollbackSeverity.values.firstWhere(
      (s) => s.name == severityName,
      orElse: () => RollbackSeverity.minor,
    );

    final tierName = json['affectedTier'] as String;
    final tier = KingdomTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => KingdomTier.village,
    );

    final resolvedAtStr = json['resolvedAt'] as String?;
    final resolvedAt = resolvedAtStr != null ? DateTime.parse(resolvedAtStr) : null;

    final actionsData = List<String>.from(json['actionsRequired'] as List? ?? []);
    final actions = actionsData.map((name) => 
      PreventionAction.values.firstWhere(
        (a) => a.name == name,
        orElse: () => PreventionAction.warning,
      )
    ).toList();

    return RollbackTrigger(
      id: json['id'] as String,
      type: type,
      severity: severity,
      triggeredAt: DateTime.parse(json['triggeredAt'] as String),
      description: json['description'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      affectedTier: tier,
      isResolved: json['isResolved'] as bool,
      resolvedAt: resolvedAt,
      actionsRequired: actions,
    );
  }
}

/// Prevention plan for addressing rollback triggers
class PreventionPlan {
  final String triggerId;
  final List<PreventionAction> actions;
  final DateTime createdAt;
  final Duration timeframe;
  final Map<String, dynamic> requirements;
  final bool isCompleted;
  final DateTime? completedAt;
  final double progressPercentage;

  const PreventionPlan({
    required this.triggerId,
    required this.actions,
    required this.createdAt,
    required this.timeframe,
    required this.requirements,
    required this.isCompleted,
    this.completedAt,
    required this.progressPercentage,
  });

  PreventionPlan copyWith({
    String? triggerId,
    List<PreventionAction>? actions,
    DateTime? createdAt,
    Duration? timeframe,
    Map<String, dynamic>? requirements,
    bool? isCompleted,
    DateTime? completedAt,
    double? progressPercentage,
  }) {
    return PreventionPlan(
      triggerId: triggerId ?? this.triggerId,
      actions: actions ?? this.actions,
      createdAt: createdAt ?? this.createdAt,
      timeframe: timeframe ?? this.timeframe,
      requirements: requirements ?? this.requirements,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'triggerId': triggerId,
      'actions': actions.map((a) => a.name).toList(),
      'createdAt': createdAt.toIso8601String(),
      'timeframe': timeframe.inMilliseconds,
      'requirements': requirements,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'progressPercentage': progressPercentage,
    };
  }

  static PreventionPlan fromJson(Map<String, dynamic> json) {
    final actionsData = List<String>.from(json['actions'] as List);
    final actions = actionsData.map((name) => 
      PreventionAction.values.firstWhere(
        (a) => a.name == name,
        orElse: () => PreventionAction.warning,
      )
    ).toList();

    final completedAtStr = json['completedAt'] as String?;
    final completedAt = completedAtStr != null ? DateTime.parse(completedAtStr) : null;

    return PreventionPlan(
      triggerId: json['triggerId'] as String,
      actions: actions,
      createdAt: DateTime.parse(json['createdAt'] as String),
      timeframe: Duration(milliseconds: json['timeframe'] as int),
      requirements: Map<String, dynamic>.from(json['requirements'] as Map),
      isCompleted: json['isCompleted'] as bool,
      completedAt: completedAt,
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
    );
  }
}

/// Rollback prevention system
class RollbackPreventionSystem {
  /// Thresholds for different rollback triggers by tier
  static final Map<KingdomTier, Map<RollbackTriggerType, Map<String, dynamic>>> _tierThresholds = {
    KingdomTier.village: {
      RollbackTriggerType.tradingLoss: {
        'minor': 0.05,    // 5% loss triggers warning
        'moderate': 0.10, // 10% loss triggers education
        'major': 0.20,    // 20% loss triggers probation
        'critical': 0.30, // 30% loss could affect tier (but prevented)
      },
      RollbackTriggerType.capitalDepletion: {
        'minor': 0.90,    // Below 90% triggers warning
        'moderate': 0.85, // Below 85% triggers education
        'major': 0.75,    // Below 75% triggers probation
        'critical': 0.60, // Below 60% could affect tier
      },
      RollbackTriggerType.riskViolation: {
        'minor': 1,       // First violation
        'moderate': 2,    // Second violation
        'major': 3,       // Third violation
        'critical': 4,    // Fourth violation
      },
      RollbackTriggerType.inactivity: {
        'minor': 7,       // 7 days inactive
        'moderate': 14,   // 14 days inactive
        'major': 21,      // 21 days inactive
        'critical': 30,   // 30 days inactive
      },
    },
    
    KingdomTier.town: {
      RollbackTriggerType.tradingLoss: {
        'minor': 0.08,    // 8% loss triggers warning
        'moderate': 0.15, // 15% loss triggers education
        'major': 0.25,    // 25% loss triggers probation
        'critical': 0.35, // 35% loss could affect tier
      },
      RollbackTriggerType.capitalDepletion: {
        'minor': 0.88,    // Below 88% triggers warning
        'moderate': 0.80, // Below 80% triggers education
        'major': 0.70,    // Below 70% triggers probation
        'critical': 0.55, // Below 55% could affect tier
      },
      RollbackTriggerType.riskViolation: {
        'minor': 1,
        'moderate': 2,
        'major': 3,
        'critical': 4,
      },
      RollbackTriggerType.inactivity: {
        'minor': 10,      // 10 days inactive
        'moderate': 20,   // 20 days inactive
        'major': 30,      // 30 days inactive
        'critical': 45,   // 45 days inactive
      },
    },
    
    KingdomTier.city: {
      RollbackTriggerType.tradingLoss: {
        'minor': 0.10,    // 10% loss triggers warning
        'moderate': 0.20, // 20% loss triggers education
        'major': 0.30,    // 30% loss triggers probation
        'critical': 0.40, // 40% loss could affect tier
      },
      RollbackTriggerType.capitalDepletion: {
        'minor': 0.85,    // Below 85% triggers warning
        'moderate': 0.75, // Below 75% triggers education
        'major': 0.65,    // Below 65% triggers probation
        'critical': 0.50, // Below 50% could affect tier
      },
      RollbackTriggerType.riskViolation: {
        'minor': 1,
        'moderate': 2,
        'major': 3,
        'critical': 4,
      },
      RollbackTriggerType.inactivity: {
        'minor': 14,      // 14 days inactive
        'moderate': 30,   // 30 days inactive
        'major': 45,      // 45 days inactive
        'critical': 60,   // 60 days inactive
      },
    },
    
    KingdomTier.kingdom: {
      RollbackTriggerType.tradingLoss: {
        'minor': 0.12,    // 12% loss triggers warning
        'moderate': 0.25, // 25% loss triggers education
        'major': 0.35,    // 35% loss triggers probation
        'critical': 0.45, // 45% loss could affect tier
      },
      RollbackTriggerType.capitalDepletion: {
        'minor': 0.80,    // Below 80% triggers warning
        'moderate': 0.70, // Below 70% triggers education
        'major': 0.60,    // Below 60% triggers probation
        'critical': 0.45, // Below 45% could affect tier
      },
      RollbackTriggerType.riskViolation: {
        'minor': 1,
        'moderate': 2,
        'major': 3,
        'critical': 4,
      },
      RollbackTriggerType.inactivity: {
        'minor': 21,      // 21 days inactive
        'moderate': 45,   // 45 days inactive
        'major': 60,      // 60 days inactive
        'critical': 90,   // 90 days inactive
      },
    },
  };

  /// Prevention strategies for different trigger types and severities
  static final Map<RollbackTriggerType, Map<RollbackSeverity, List<PreventionAction>>> _preventionStrategies = {
    RollbackTriggerType.tradingLoss: {
      RollbackSeverity.minor: [PreventionAction.warning, PreventionAction.education],
      RollbackSeverity.moderate: [PreventionAction.education, PreventionAction.mentorship],
      RollbackSeverity.major: [PreventionAction.probation, PreventionAction.education, PreventionAction.mentorship],
      RollbackSeverity.critical: [PreventionAction.probation, PreventionAction.counseling, PreventionAction.supportPlan],
    },
    RollbackTriggerType.capitalDepletion: {
      RollbackSeverity.minor: [PreventionAction.warning, PreventionAction.education],
      RollbackSeverity.moderate: [PreventionAction.education, PreventionAction.featureRestriction],
      RollbackSeverity.major: [PreventionAction.probation, PreventionAction.mentorship, PreventionAction.featureRestriction],
      RollbackSeverity.critical: [PreventionAction.probation, PreventionAction.counseling, PreventionAction.supportPlan],
    },
    RollbackTriggerType.riskViolation: {
      RollbackSeverity.minor: [PreventionAction.warning, PreventionAction.education],
      RollbackSeverity.moderate: [PreventionAction.education, PreventionAction.additionalRequirements],
      RollbackSeverity.major: [PreventionAction.probation, PreventionAction.mentorship],
      RollbackSeverity.critical: [PreventionAction.probation, PreventionAction.counseling, PreventionAction.additionalRequirements],
    },
    RollbackTriggerType.inactivity: {
      RollbackSeverity.minor: [PreventionAction.warning],
      RollbackSeverity.moderate: [PreventionAction.education, PreventionAction.supportPlan],
      RollbackSeverity.major: [PreventionAction.probation, PreventionAction.mentorship],
      RollbackSeverity.critical: [PreventionAction.probation, PreventionAction.counseling, PreventionAction.additionalRequirements],
    },
    RollbackTriggerType.competencyFailure: {
      RollbackSeverity.minor: [PreventionAction.warning, PreventionAction.education],
      RollbackSeverity.moderate: [PreventionAction.education, PreventionAction.mentorship],
      RollbackSeverity.major: [PreventionAction.additionalRequirements, PreventionAction.mentorship],
      RollbackSeverity.critical: [PreventionAction.additionalRequirements, PreventionAction.counseling],
    },
    RollbackTriggerType.policyViolation: {
      RollbackSeverity.minor: [PreventionAction.warning, PreventionAction.education],
      RollbackSeverity.moderate: [PreventionAction.probation, PreventionAction.education],
      RollbackSeverity.major: [PreventionAction.probation, PreventionAction.featureRestriction],
      RollbackSeverity.critical: [PreventionAction.probation, PreventionAction.counseling, PreventionAction.additionalRequirements],
    },
    RollbackTriggerType.systemError: {
      RollbackSeverity.minor: [PreventionAction.warning],
      RollbackSeverity.moderate: [PreventionAction.supportPlan],
      RollbackSeverity.major: [PreventionAction.supportPlan],
      RollbackSeverity.critical: [PreventionAction.supportPlan],
    },
    RollbackTriggerType.manualAdjustment: {
      RollbackSeverity.minor: [PreventionAction.warning, PreventionAction.education],
      RollbackSeverity.moderate: [PreventionAction.education, PreventionAction.mentorship],
      RollbackSeverity.major: [PreventionAction.additionalRequirements, PreventionAction.mentorship],
      RollbackSeverity.critical: [PreventionAction.additionalRequirements, PreventionAction.counseling],
    },
  };

  /// Check if an event should trigger rollback prevention
  static RollbackTrigger? evaluateEvent({
    required String eventId,
    required RollbackTriggerType type,
    required KingdomTier currentTier,
    required Map<String, dynamic> eventData,
    required String description,
  }) {
    final thresholds = _tierThresholds[currentTier]?[type];
    if (thresholds == null) return null;

    RollbackSeverity? severity;
    
    switch (type) {
      case RollbackTriggerType.tradingLoss:
        final lossPercentage = eventData['lossPercentage'] as double? ?? 0.0;
        severity = _evaluateLossThreshold(lossPercentage, thresholds);
        break;
        
      case RollbackTriggerType.capitalDepletion:
        final capitalRetention = eventData['capitalRetention'] as double? ?? 1.0;
        severity = _evaluateCapitalThreshold(capitalRetention, thresholds);
        break;
        
      case RollbackTriggerType.riskViolation:
        final violationCount = eventData['violationCount'] as int? ?? 0;
        severity = _evaluateViolationThreshold(violationCount, thresholds);
        break;
        
      case RollbackTriggerType.inactivity:
        final inactiveDays = eventData['inactiveDays'] as int? ?? 0;
        severity = _evaluateInactivityThreshold(inactiveDays, thresholds);
        break;
        
      default:
        // For other types, determine severity based on event data
        severity = eventData['severity'] as RollbackSeverity? ?? RollbackSeverity.minor;
        break;
    }

    if (severity == null) return null;

    final actions = _preventionStrategies[type]?[severity] ?? [PreventionAction.warning];

    return RollbackTrigger(
      id: eventId,
      type: type,
      severity: severity,
      triggeredAt: DateTime.now(),
      description: description,
      data: eventData,
      affectedTier: currentTier,
      isResolved: false,
      actionsRequired: actions,
    );
  }

  static RollbackSeverity? _evaluateLossThreshold(double lossPercentage, Map<String, dynamic> thresholds) {
    if (lossPercentage >= thresholds['critical']) return RollbackSeverity.critical;
    if (lossPercentage >= thresholds['major']) return RollbackSeverity.major;
    if (lossPercentage >= thresholds['moderate']) return RollbackSeverity.moderate;
    if (lossPercentage >= thresholds['minor']) return RollbackSeverity.minor;
    return null;
  }

  static RollbackSeverity? _evaluateCapitalThreshold(double capitalRetention, Map<String, dynamic> thresholds) {
    if (capitalRetention <= thresholds['critical']) return RollbackSeverity.critical;
    if (capitalRetention <= thresholds['major']) return RollbackSeverity.major;
    if (capitalRetention <= thresholds['moderate']) return RollbackSeverity.moderate;
    if (capitalRetention <= thresholds['minor']) return RollbackSeverity.minor;
    return null;
  }

  static RollbackSeverity? _evaluateViolationThreshold(int violationCount, Map<String, dynamic> thresholds) {
    if (violationCount >= thresholds['critical']) return RollbackSeverity.critical;
    if (violationCount >= thresholds['major']) return RollbackSeverity.major;
    if (violationCount >= thresholds['moderate']) return RollbackSeverity.moderate;
    if (violationCount >= thresholds['minor']) return RollbackSeverity.minor;
    return null;
  }

  static RollbackSeverity? _evaluateInactivityThreshold(int inactiveDays, Map<String, dynamic> thresholds) {
    if (inactiveDays >= thresholds['critical']) return RollbackSeverity.critical;
    if (inactiveDays >= thresholds['major']) return RollbackSeverity.major;
    if (inactiveDays >= thresholds['moderate']) return RollbackSeverity.moderate;
    if (inactiveDays >= thresholds['minor']) return RollbackSeverity.minor;
    return null;
  }

  /// Create a prevention plan for a rollback trigger
  static PreventionPlan createPreventionPlan(RollbackTrigger trigger) {
    final requirements = _generateRequirements(trigger);
    final timeframe = _calculateTimeframe(trigger);

    return PreventionPlan(
      triggerId: trigger.id,
      actions: trigger.actionsRequired,
      createdAt: DateTime.now(),
      timeframe: timeframe,
      requirements: requirements,
      isCompleted: false,
      progressPercentage: 0.0,
    );
  }

  static Map<String, dynamic> _generateRequirements(RollbackTrigger trigger) {
    final Map<String, dynamic> requirements = {};

    for (final action in trigger.actionsRequired) {
      switch (action) {
        case PreventionAction.warning:
          requirements['acknowledgeWarning'] = false;
          break;
          
        case PreventionAction.education:
          requirements['completEducationModules'] = {
            'required': _getEducationModulesForTrigger(trigger.type),
            'completed': [],
          };
          break;
          
        case PreventionAction.mentorship:
          requirements['mentorshipSessions'] = {
            'required': _getMentorshipSessionsRequired(trigger.severity),
            'completed': 0,
          };
          break;
          
        case PreventionAction.probation:
          requirements['probationPeriod'] = {
            'duration': _getProbationDuration(trigger.severity),
            'startDate': DateTime.now().toIso8601String(),
            'restrictions': _getProbationRestrictions(trigger.type),
          };
          break;
          
        case PreventionAction.featureRestriction:
          requirements['restrictedFeatures'] = _getRestrictedFeatures(trigger.type, trigger.affectedTier);
          break;
          
        case PreventionAction.additionalRequirements:
          requirements['additionalCompetencies'] = _getAdditionalCompetencies(trigger.type);
          break;
          
        case PreventionAction.counseling:
          requirements['counselingSessions'] = {
            'required': _getCounselingSessionsRequired(trigger.severity),
            'completed': 0,
          };
          break;
          
        case PreventionAction.supportPlan:
          requirements['supportPlan'] = {
            'personalizedPlan': true,
            'checkInFrequency': _getCheckInFrequency(trigger.severity),
            'supportResources': _getSupportResources(trigger.type),
          };
          break;
      }
    }

    return requirements;
  }

  static Duration _calculateTimeframe(RollbackTrigger trigger) {
    switch (trigger.severity) {
      case RollbackSeverity.minor:
        return const Duration(days: 7);
      case RollbackSeverity.moderate:
        return const Duration(days: 14);
      case RollbackSeverity.major:
        return const Duration(days: 30);
      case RollbackSeverity.critical:
        return const Duration(days: 45);
    }
  }

  static List<String> _getEducationModulesForTrigger(RollbackTriggerType type) {
    switch (type) {
      case RollbackTriggerType.tradingLoss:
        return ['risk_management_advanced', 'loss_psychology', 'position_sizing'];
      case RollbackTriggerType.capitalDepletion:
        return ['capital_preservation', 'portfolio_management', 'diversification'];
      case RollbackTriggerType.riskViolation:
        return ['risk_compliance', 'trading_rules', 'risk_assessment'];
      default:
        return ['general_risk_management'];
    }
  }

  static int _getMentorshipSessionsRequired(RollbackSeverity severity) {
    switch (severity) {
      case RollbackSeverity.minor:
        return 1;
      case RollbackSeverity.moderate:
        return 2;
      case RollbackSeverity.major:
        return 4;
      case RollbackSeverity.critical:
        return 6;
    }
  }

  static Duration _getProbationDuration(RollbackSeverity severity) {
    switch (severity) {
      case RollbackSeverity.minor:
        return const Duration(days: 7);
      case RollbackSeverity.moderate:
        return const Duration(days: 14);
      case RollbackSeverity.major:
        return const Duration(days: 30);
      case RollbackSeverity.critical:
        return const Duration(days: 60);
    }
  }

  static List<String> _getProbationRestrictions(RollbackTriggerType type) {
    switch (type) {
      case RollbackTriggerType.tradingLoss:
        return ['reduced_position_size', 'mandatory_stop_loss', 'limited_leverage'];
      case RollbackTriggerType.capitalDepletion:
        return ['trading_suspended', 'education_required', 'mentor_approval'];
      case RollbackTriggerType.riskViolation:
        return ['supervised_trading', 'pre_trade_approval', 'limited_features'];
      default:
        return ['general_restrictions'];
    }
  }

  static List<String> _getRestrictedFeatures(RollbackTriggerType type, KingdomTier tier) {
    final List<String> restrictions = [];
    
    switch (type) {
      case RollbackTriggerType.tradingLoss:
        restrictions.addAll(['margin_trading', 'options_trading', 'high_leverage']);
        break;
      case RollbackTriggerType.capitalDepletion:
        restrictions.addAll(['real_money_trading', 'withdrawals', 'leverage']);
        break;
      case RollbackTriggerType.riskViolation:
        restrictions.addAll(['advanced_features', 'autonomous_trading', 'high_risk_assets']);
        break;
      default:
        break;
    }
    
    return restrictions;
  }

  static List<String> _getAdditionalCompetencies(RollbackTriggerType type) {
    switch (type) {
      case RollbackTriggerType.tradingLoss:
        return ['advanced_risk_management_cert', 'loss_recovery_strategies'];
      case RollbackTriggerType.capitalDepletion:
        return ['capital_preservation_mastery', 'portfolio_optimization'];
      case RollbackTriggerType.riskViolation:
        return ['risk_compliance_certification', 'trading_ethics'];
      default:
        return ['general_competency_refresh'];
    }
  }

  static int _getCounselingSessionsRequired(RollbackSeverity severity) {
    switch (severity) {
      case RollbackSeverity.minor:
        return 1;
      case RollbackSeverity.moderate:
        return 2;
      case RollbackSeverity.major:
        return 4;
      case RollbackSeverity.critical:
        return 6;
    }
  }

  static String _getCheckInFrequency(RollbackSeverity severity) {
    switch (severity) {
      case RollbackSeverity.minor:
        return 'weekly';
      case RollbackSeverity.moderate:
        return 'bi_weekly';
      case RollbackSeverity.major:
        return 'weekly';
      case RollbackSeverity.critical:
        return 'daily';
    }
  }

  static List<String> _getSupportResources(RollbackTriggerType type) {
    switch (type) {
      case RollbackTriggerType.tradingLoss:
        return ['loss_recovery_guide', 'trading_psychology_resources', 'risk_management_tools'];
      case RollbackTriggerType.capitalDepletion:
        return ['capital_management_guide', 'financial_planning_tools', 'emergency_procedures'];
      case RollbackTriggerType.riskViolation:
        return ['compliance_guide', 'risk_assessment_tools', 'policy_documentation'];
      default:
        return ['general_support_resources'];
    }
  }

  /// Check if tier rollback would be prevented
  static bool wouldPreventRollback(RollbackTrigger trigger) {
    // Always prevent rollback - this is the core principle of the system
    return true;
  }

  /// Get prevention message for user
  static String getPreventionMessage(RollbackTrigger trigger) {
    switch (trigger.severity) {
      case RollbackSeverity.minor:
        return 'We\'ve noticed some concerns with your trading activity. Let\'s work together to address them and keep you on track.';
      case RollbackSeverity.moderate:
        return 'Your account needs some attention to maintain your current tier. We\'re here to help you through this process.';
      case RollbackSeverity.major:
        return 'We\'re implementing additional support measures to help you recover and maintain your tier status.';
      case RollbackSeverity.critical:
        return 'Your tier status is being protected through our comprehensive support program. Let\'s work together to get you back on track.';
    }
  }

  /// Calculate prevention plan progress
  static double calculatePreventionProgress(PreventionPlan plan, Map<String, dynamic> currentProgress) {
    double totalProgress = 0.0;
    int totalRequirements = plan.requirements.length;
    
    if (totalRequirements == 0) return 1.0;
    
    for (final entry in plan.requirements.entries) {
      final requirementKey = entry.key;
      final requirement = entry.value;
      final progress = currentProgress[requirementKey];
      
      double requirementProgress = 0.0;
      
      switch (requirementKey) {
        case 'acknowledgeWarning':
          requirementProgress = (progress as bool? ?? false) ? 1.0 : 0.0;
          break;
          
        case 'completEducationModules':
          final required = (requirement as Map)['required'] as List;
          final completed = (progress as Map?)?['completed'] as List? ?? [];
          requirementProgress = completed.length / required.length;
          break;
          
        case 'mentorshipSessions':
          final required = (requirement as Map)['required'] as int;
          final completed = (progress as int? ?? 0);
          requirementProgress = (completed / required).clamp(0.0, 1.0);
          break;
          
        case 'counselingSessions':
          final required = (requirement as Map)['required'] as int;
          final completed = (progress as int? ?? 0);
          requirementProgress = (completed / required).clamp(0.0, 1.0);
          break;
          
        default:
          // For other requirements, check if completed
          requirementProgress = (progress as bool? ?? false) ? 1.0 : 0.0;
          break;
      }
      
      totalProgress += requirementProgress;
    }
    
    return totalProgress / totalRequirements;
  }

  /// Check if prevention plan is completed
  static bool isPreventionPlanCompleted(PreventionPlan plan, Map<String, dynamic> currentProgress) {
    return calculatePreventionProgress(plan, currentProgress) >= 1.0;
  }
}