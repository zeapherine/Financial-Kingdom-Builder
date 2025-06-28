// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Constructor del Reino Financiero';

  @override
  String get education => 'Educación';

  @override
  String get lessons => 'Lecciones';

  @override
  String get progress => 'Progreso';

  @override
  String get achievements => 'Logros';

  @override
  String get experiencePoints => 'Puntos de Experiencia';

  @override
  String get overallProgress => 'Progreso General';

  @override
  String get learningPath => 'Ruta de Aprendizaje';

  @override
  String get currentMilestone => 'Hito Actual';

  @override
  String get achievementUnlocked => '¡Logro Desbloqueado!';

  @override
  String get startAnimation => 'Iniciar Animación';

  @override
  String get playing => 'Reproduciendo...';

  @override
  String get reset => 'Reiniciar';

  @override
  String get blockchainProcessVisualization =>
      'Visualización del Proceso Blockchain';

  @override
  String get blockStructure => 'Estructura del Bloque';

  @override
  String get financialConstructionPermits =>
      'Permisos de Construcción Financiera';

  @override
  String get buildYourFinancialKnowledge =>
      'Construye tu conocimiento financiero paso a paso, como construir un edificio';

  @override
  String get requirements => 'Requisitos:';

  @override
  String get buildingAnalogy => 'Analogía de Construcción:';

  @override
  String get unlocks => 'Desbloquea:';

  @override
  String get finalBuildingInspection => 'Inspección Final del Edificio';

  @override
  String get inspectionScore => 'Puntuación de Inspección:';

  @override
  String needToPass(int score) {
    return 'Necesitas $score para aprobar';
  }

  @override
  String get inspectionPassed => '¡Inspección Aprobada!';

  @override
  String get riskMeter => 'Medidor de Riesgo';

  @override
  String riskLevel(String level) {
    return 'Nivel de Riesgo: $level';
  }

  @override
  String get lowRisk => 'Riesgo Bajo';

  @override
  String get moderateRisk => 'Riesgo Moderado';

  @override
  String get highRisk => 'Riesgo Alto';

  @override
  String minutes(int count) {
    return '$count minutos';
  }

  @override
  String estimatedTime(String minutes) {
    return 'Tiempo estimado: $minutes';
  }

  @override
  String get continueButton => 'Continuar';

  @override
  String get complete => 'Completar';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get skip => 'Saltar';

  @override
  String get retry => 'Reintentar';

  @override
  String get correct => '¡Correcto!';

  @override
  String get incorrect => 'Incorrecto';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Intentar de Nuevo';
}
