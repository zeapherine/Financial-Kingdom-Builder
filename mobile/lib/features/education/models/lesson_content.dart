enum LessonType {
  text,
  chart,
  interactive,
  quiz,
  video,
}

enum ChartType {
  pieChart,
  barChart,
  lineChart,
  riskMeter,
  progressBar,
  custom,
}

class LessonContent {
  final String id;
  final String title;
  final String description;
  final LessonType type;
  final Map<String, dynamic> data;
  final int estimatedMinutes;
  final List<String> learningObjectives;

  const LessonContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.data,
    this.estimatedMinutes = 5,
    this.learningObjectives = const [],
  });
}

class ChartLessonData {
  final ChartType chartType;
  final Map<String, dynamic> chartData;
  final String explanation;
  final List<String> keyTakeaways;

  const ChartLessonData({
    required this.chartType,
    required this.chartData,
    required this.explanation,
    this.keyTakeaways = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'chartType': chartType.toString(),
      'chartData': chartData,
      'explanation': explanation,
      'keyTakeaways': keyTakeaways,
    };
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String kingdomMetaphor;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.kingdomMetaphor = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'kingdomMetaphor': kingdomMetaphor,
    };
  }
}

class InteractiveLessonData {
  final String interactionType;
  final Map<String, dynamic> parameters;
  final String instructions;
  final String successMessage;

  const InteractiveLessonData({
    required this.interactionType,
    required this.parameters,
    required this.instructions,
    required this.successMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'interactionType': interactionType,
      'parameters': parameters,
      'instructions': instructions,
      'successMessage': successMessage,
    };
  }
}