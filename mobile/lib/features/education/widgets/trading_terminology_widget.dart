import 'package:flutter/material.dart';
import '../../../core/config/duolingo_theme.dart';

class TermDefinitionWidget extends StatefulWidget {
  final Map<String, dynamic> termData;
  final Function(String)? onTermSelected;

  const TermDefinitionWidget({
    super.key,
    required this.termData,
    this.onTermSelected,
  });

  @override
  State<TermDefinitionWidget> createState() => _TermDefinitionWidgetState();
}

class _TermDefinitionWidgetState extends State<TermDefinitionWidget>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _textController;
  late Animation<double> _cardAnimation;
  late Animation<double> _textAnimation;
  
  String? selectedTerm;
  Map<String, dynamic>? selectedTermData;

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));
    
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _cardController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _selectTerm(String term, Map<String, dynamic> termData) {
    setState(() {
      selectedTerm = term;
      selectedTermData = termData;
    });
    
    _cardController.reset();
    _textController.reset();
    
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });
    
    if (widget.onTermSelected != null) {
      widget.onTermSelected!(term);
    }
  }

  @override
  Widget build(BuildContext context) {
    final terms = widget.termData['terms'] as List<dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trading Terms Glossary',
            style: DuolingoTheme.h2.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          Text(
            'Tap on any term to see its definition and examples',
            style: DuolingoTheme.bodyMedium.copyWith(
              color: DuolingoTheme.darkGray,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Terms Grid
          Wrap(
            spacing: DuolingoTheme.spacingSm,
            runSpacing: DuolingoTheme.spacingSm,
            children: terms.map<Widget>((term) {
              final termName = term['term'] as String;
              final isSelected = selectedTerm == termName;
              
              return GestureDetector(
                onTap: () => _selectTerm(termName, term),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DuolingoTheme.spacingMd,
                    vertical: DuolingoTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DuolingoTheme.duoGreen
                        : DuolingoTheme.duoGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                    border: Border.all(
                      color: DuolingoTheme.duoGreen,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    termName,
                    style: DuolingoTheme.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : DuolingoTheme.duoGreen,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Definition Card
          if (selectedTermData != null)
            AnimatedBuilder(
              animation: _cardAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _cardAnimation.value,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DuolingoTheme.duoBlue.withValues(alpha: 0.1),
                          DuolingoTheme.duoPurple.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
                      border: Border.all(
                        color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _textAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textAnimation.value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: DuolingoTheme.duoBlue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: DuolingoTheme.spacingSm),
                                  Text(
                                    selectedTermData!['term'],
                                    style: DuolingoTheme.h3.copyWith(
                                      color: DuolingoTheme.duoBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: DuolingoTheme.spacingMd),
                              
                              Container(
                                padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                                ),
                                child: Text(
                                  selectedTermData!['definition'],
                                  style: DuolingoTheme.bodyLarge.copyWith(
                                    color: DuolingoTheme.charcoal,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: DuolingoTheme.spacingMd),
                              
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: DuolingoTheme.duoYellow,
                                    size: 20,
                                  ),
                                  const SizedBox(width: DuolingoTheme.spacingSm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Example:',
                                          style: DuolingoTheme.bodyMedium.copyWith(
                                            color: DuolingoTheme.duoYellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: DuolingoTheme.spacingXs),
                                        Text(
                                          selectedTermData!['example'],
                                          style: DuolingoTheme.bodyMedium.copyWith(
                                            color: DuolingoTheme.darkGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: DuolingoTheme.spacingMd),
                              
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.castle,
                                    color: DuolingoTheme.duoPurple,
                                    size: 20,
                                  ),
                                  const SizedBox(width: DuolingoTheme.spacingSm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kingdom Analogy:',
                                          style: DuolingoTheme.bodyMedium.copyWith(
                                            color: DuolingoTheme.duoPurple,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: DuolingoTheme.spacingXs),
                                        Text(
                                          selectedTermData!['kingdomAnalogy'],
                                          style: DuolingoTheme.bodyMedium.copyWith(
                                            color: DuolingoTheme.darkGray,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class OrderSimulationWidget extends StatefulWidget {
  final Map<String, dynamic> simulationData;
  final Function(Map<String, dynamic>)? onSimulationComplete;

  const OrderSimulationWidget({
    super.key,
    required this.simulationData,
    this.onSimulationComplete,
  });

  @override
  State<OrderSimulationWidget> createState() => _OrderSimulationWidgetState();
}

class _OrderSimulationWidgetState extends State<OrderSimulationWidget>
    with TickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  
  int currentScenarioIndex = 0;
  int correctAnswers = 0;
  bool showFeedback = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _feedbackAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _selectOrder(String selectedOrder) {
    final scenarios = widget.simulationData['scenarios'] as List;
    final currentScenario = scenarios[currentScenarioIndex];
    final correctOrder = currentScenario['correctOrder'];
    
    setState(() {
      showFeedback = true;
      isCorrect = selectedOrder == correctOrder;
      if (isCorrect) {
        correctAnswers++;
      }
    });
    
    _feedbackController.forward();
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      _nextScenario();
    });
  }

  void _nextScenario() {
    final scenarios = widget.simulationData['scenarios'] as List;
    
    if (currentScenarioIndex < scenarios.length - 1) {
      setState(() {
        currentScenarioIndex++;
        showFeedback = false;
      });
      _feedbackController.reset();
    } else {
      _completeSimulation();
    }
  }

  void _completeSimulation() {
    if (widget.onSimulationComplete != null) {
      widget.onSimulationComplete!({
        'totalScenarios': widget.simulationData['scenarios'].length,
        'correctAnswers': correctAnswers,
        'accuracy': correctAnswers / widget.simulationData['scenarios'].length,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = widget.simulationData['scenarios'] as List;
    final currentScenario = scenarios[currentScenarioIndex];
    
    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (currentScenarioIndex + 1) / scenarios.length,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(DuolingoTheme.duoGreen),
                ),
              ),
              const SizedBox(width: DuolingoTheme.spacingMd),
              Text(
                '${currentScenarioIndex + 1}/${scenarios.length}',
                style: DuolingoTheme.bodyMedium.copyWith(
                  color: DuolingoTheme.darkGray,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Stock Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: DuolingoTheme.duoBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              border: Border.all(
                color: DuolingoTheme.duoBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: DuolingoTheme.duoBlue,
                  size: 32,
                ),
                const SizedBox(width: DuolingoTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentScenario['stock'],
                        style: DuolingoTheme.h3.copyWith(
                          color: DuolingoTheme.duoBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Current Price: \$${currentScenario['currentPrice']}',
                        style: DuolingoTheme.bodyLarge.copyWith(
                          color: DuolingoTheme.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          // Scenario
          Text(
            'Scenario:',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingSm),
          
          Text(
            currentScenario['scenario'],
            style: DuolingoTheme.bodyLarge.copyWith(
              color: DuolingoTheme.darkGray,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingLg),
          
          Text(
            'Which order type should you use?',
            style: DuolingoTheme.h4.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: DuolingoTheme.spacingMd),
          
          // Order Type Options
          if (!showFeedback) ...[
            ..._buildOrderOptions(),
          ] else ...[
            // Feedback
            AnimatedBuilder(
              animation: _feedbackAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _feedbackAnimation.value,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? DuolingoTheme.duoGreen.withValues(alpha: 0.1)
                          : DuolingoTheme.duoRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                      border: Border.all(
                        color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                              size: 32,
                            ),
                            const SizedBox(width: DuolingoTheme.spacingMd),
                            Text(
                              isCorrect ? 'Correct!' : 'Incorrect',
                              style: DuolingoTheme.h3.copyWith(
                                color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DuolingoTheme.spacingMd),
                        Text(
                          currentScenario['explanation'],
                          style: DuolingoTheme.bodyLarge.copyWith(
                            color: DuolingoTheme.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildOrderOptions() {
    final orderTypes = ['Market Order', 'Limit Order', 'Stop-Loss Order', 'Take-Profit Order'];
    
    return orderTypes.map((orderType) {
      return Padding(
        padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _selectOrder(orderType),
            style: ElevatedButton.styleFrom(
              backgroundColor: DuolingoTheme.duoGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
              ),
            ),
            child: Text(
              orderType,
              style: DuolingoTheme.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class ConceptQuizWidget extends StatefulWidget {
  final Map<String, dynamic> quizData;
  final Function(Map<String, dynamic>)? onQuizComplete;

  const ConceptQuizWidget({
    super.key,
    required this.quizData,
    this.onQuizComplete,
  });

  @override
  State<ConceptQuizWidget> createState() => _ConceptQuizWidgetState();
}

class _ConceptQuizWidgetState extends State<ConceptQuizWidget> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  bool showFeedback = false;
  bool isCorrect = false;

  void _selectAnswer(int selectedIndex) {
    final concepts = widget.quizData['concepts'] as List;
    final currentConcept = concepts[currentQuestionIndex];
    final correctIndex = currentConcept['correct'];

    setState(() {
      showFeedback = true;
      isCorrect = selectedIndex == correctIndex;
      if (isCorrect) {
        correctAnswers++;
      }
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    final concepts = widget.quizData['concepts'] as List;

    if (currentQuestionIndex < concepts.length - 1) {
      setState(() {
        currentQuestionIndex++;
        showFeedback = false;
      });
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    if (widget.onQuizComplete != null) {
      widget.onQuizComplete!({
        'totalQuestions': widget.quizData['concepts'].length,
        'correctAnswers': correctAnswers,
        'accuracy': correctAnswers / widget.quizData['concepts'].length,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final concepts = widget.quizData['concepts'] as List;
    final currentConcept = concepts[currentQuestionIndex];

    return Container(
      padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
      decoration: BoxDecoration(
        color: DuolingoTheme.white,
        borderRadius: BorderRadius.circular(DuolingoTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / concepts.length,
            backgroundColor: Colors.grey.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(DuolingoTheme.duoGreen),
          ),

          const SizedBox(height: DuolingoTheme.spacingLg),

          // Concept
          Container(
            padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
            decoration: BoxDecoration(
              color: DuolingoTheme.duoYellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
            ),
            child: Text(
              'Concept: ${currentConcept['concept']}',
              style: DuolingoTheme.bodyLarge.copyWith(
                color: DuolingoTheme.charcoal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: DuolingoTheme.spacingLg),

          // Question
          Text(
            currentConcept['question'],
            style: DuolingoTheme.h3.copyWith(
              color: DuolingoTheme.charcoal,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: DuolingoTheme.spacingLg),

          // Options or Feedback
          if (!showFeedback) ...[
            ...List.generate(
              currentConcept['options'].length,
              (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: DuolingoTheme.spacingMd),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _selectAnswer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DuolingoTheme.duoBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(DuolingoTheme.spacingMd),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                        ),
                      ),
                      child: Text(
                        currentConcept['options'][index],
                        style: DuolingoTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            // Feedback
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DuolingoTheme.spacingLg),
              decoration: BoxDecoration(
                color: isCorrect
                    ? DuolingoTheme.duoGreen.withValues(alpha: 0.1)
                    : DuolingoTheme.duoRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DuolingoTheme.radiusMedium),
                border: Border.all(
                  color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                        size: 32,
                      ),
                      const SizedBox(width: DuolingoTheme.spacingMd),
                      Text(
                        isCorrect ? 'Correct!' : 'Incorrect',
                        style: DuolingoTheme.h3.copyWith(
                          color: isCorrect ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DuolingoTheme.spacingMd),
                  Text(
                    currentConcept['explanation'],
                    style: DuolingoTheme.bodyLarge.copyWith(
                      color: DuolingoTheme.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}