// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Constructeur du Royaume Financier';

  @override
  String get education => 'Éducation';

  @override
  String get lessons => 'Leçons';

  @override
  String get progress => 'Progrès';

  @override
  String get achievements => 'Réalisations';

  @override
  String get experiencePoints => 'Points d\'Expérience';

  @override
  String get overallProgress => 'Progrès Global';

  @override
  String get learningPath => 'Parcours d\'Apprentissage';

  @override
  String get currentMilestone => 'Étape Actuelle';

  @override
  String get achievementUnlocked => 'Réalisation Débloquée !';

  @override
  String get startAnimation => 'Démarrer l\'Animation';

  @override
  String get playing => 'En cours...';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get blockchainProcessVisualization =>
      'Visualisation du Processus Blockchain';

  @override
  String get blockStructure => 'Structure du Bloc';

  @override
  String get financialConstructionPermits =>
      'Permis de Construction Financière';

  @override
  String get buildYourFinancialKnowledge =>
      'Construisez vos connaissances financières étape par étape, comme construire un bâtiment';

  @override
  String get requirements => 'Exigences :';

  @override
  String get buildingAnalogy => 'Analogie de Construction :';

  @override
  String get unlocks => 'Débloque :';

  @override
  String get finalBuildingInspection => 'Inspection Finale du Bâtiment';

  @override
  String get inspectionScore => 'Score d\'Inspection :';

  @override
  String needToPass(int score) {
    return 'Besoin de $score pour réussir';
  }

  @override
  String get inspectionPassed => 'Inspection Réussie !';

  @override
  String get riskMeter => 'Indicateur de Risque';

  @override
  String riskLevel(String level) {
    return 'Niveau de Risque : $level';
  }

  @override
  String get lowRisk => 'Risque Faible';

  @override
  String get moderateRisk => 'Risque Modéré';

  @override
  String get highRisk => 'Risque Élevé';

  @override
  String minutes(int count) {
    return '$count minutes';
  }

  @override
  String estimatedTime(String minutes) {
    return 'Temps estimé : $minutes';
  }

  @override
  String get continueButton => 'Continuer';

  @override
  String get complete => 'Terminer';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get skip => 'Passer';

  @override
  String get retry => 'Réessayer';

  @override
  String get correct => 'Correct !';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get tryAgain => 'Réessayer';
}
