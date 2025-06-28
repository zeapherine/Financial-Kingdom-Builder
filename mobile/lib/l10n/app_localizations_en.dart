// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Financial Kingdom Builder';

  @override
  String get education => 'Education';

  @override
  String get lessons => 'Lessons';

  @override
  String get progress => 'Progress';

  @override
  String get achievements => 'Achievements';

  @override
  String get experiencePoints => 'Experience Points';

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get learningPath => 'Learning Path';

  @override
  String get currentMilestone => 'Current Milestone';

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String get startAnimation => 'Start Animation';

  @override
  String get playing => 'Playing...';

  @override
  String get reset => 'Reset';

  @override
  String get blockchainProcessVisualization =>
      'Blockchain Process Visualization';

  @override
  String get blockStructure => 'Block Structure';

  @override
  String get financialConstructionPermits => 'Financial Construction Permits';

  @override
  String get buildYourFinancialKnowledge =>
      'Build your financial knowledge step by step, just like constructing a building';

  @override
  String get requirements => 'Requirements:';

  @override
  String get buildingAnalogy => 'Building Analogy:';

  @override
  String get unlocks => 'Unlocks:';

  @override
  String get finalBuildingInspection => 'Final Building Inspection';

  @override
  String get inspectionScore => 'Inspection Score:';

  @override
  String needToPass(int score) {
    return 'Need $score to pass';
  }

  @override
  String get inspectionPassed => 'Inspection Passed!';

  @override
  String get riskMeter => 'Risk Meter';

  @override
  String riskLevel(String level) {
    return 'Risk Level: $level';
  }

  @override
  String get lowRisk => 'Low Risk';

  @override
  String get moderateRisk => 'Moderate Risk';

  @override
  String get highRisk => 'High Risk';

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String estimatedTime(String minutes) {
    return 'Estimated time: $minutes';
  }

  @override
  String get continueButton => 'Continue';

  @override
  String get complete => 'Complete';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get correct => 'Correct!';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Try Again';
}
